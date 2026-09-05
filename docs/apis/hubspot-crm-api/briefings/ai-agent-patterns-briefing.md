# HubSpot CRM API — AI Agent Patterns Briefing
**Source:** agent5-search-ai-patterns.md, agent1-auth-core-objects.md, agent3-webhooks-rate-limits.md
**Date:** 2026-03-18

---

## Quick Summary

HubSpot CRM is well-suited as the backend state store for AI agents. Its object model, custom properties, and webhook system give agents a durable, queryable record of what has been processed, what decisions were made, and what needs follow-up. Two primary architectures exist: **webhook-driven** (reactive, event-based, lower API usage) and **polling** (simpler but less efficient). For production AI agents, webhook-driven is preferred. Key patterns: idempotency via `hs_unique_creation_key`, deduplication via contact email lookup before create, and using custom properties to persist agent state directly on CRM records.

---

## Architecture Overview

### Webhook-Driven Architecture (Recommended)

```
HubSpot CRM
    │
    │  Event occurs (contact created, deal moves stage, property changes)
    ▼
Webhook Payload
    │
    ▼
Your Endpoint ──► HMAC validation ──► Dedup check (event_id seen?) ──► Queue
                                                                          │
                                                                          ▼
                                                                  Worker / Agent
                                                                          │
                                                              ┌───────────┴───────────┐
                                                              ▼                       ▼
                                                        Fetch full record       Execute action
                                                        via CRM API             (email, AI, etc.)
                                                              │                       │
                                                              └───────────┬───────────┘
                                                                          ▼
                                                                 Update CRM record
                                                               (write agent decision
                                                                back as property)
```

**Advantages:**
- Near-real-time response
- No polling cost
- Natural retry mechanism via HubSpot's retry schedule
- Low API usage (only fetch what's needed, when needed)

### Polling Architecture

```
Scheduler (cron/Trigger.dev)
    │ Every N minutes
    ▼
Search API: find records where
agent_last_processed < now - N minutes
    │
    ▼
Process each record ──► Update agent_processed_at property
```

**When to use polling:**
- Simple periodic batch jobs (nightly reports, weekly digests)
- Environments where exposing a public webhook endpoint is not feasible
- During initial development/testing before webhooks are configured

---

## Idempotency Patterns

**Problem:** HubSpot webhooks have at-least-once delivery. Network errors, retries, and HubSpot's own retry schedule mean your handler can receive the same event multiple times.

**Solution 1: `hs_unique_creation_key` (for record creation)**

HubSpot provides a built-in idempotency key for create operations. If you send the same key twice, HubSpot returns the existing record instead of creating a duplicate.

```python
import hashlib
import json

def create_contact_idempotent(properties: dict) -> dict:
    """Generate a stable idempotency key from contact data."""
    # Key based on email — guaranteed unique
    key_source = properties.get("email", "")
    idempotency_key = hashlib.md5(key_source.encode()).hexdigest()

    payload = {
        "properties": properties,
        "idempotencyKey": idempotency_key  # hs_unique_creation_key
    }

    try:
        result = client.post("/crm/v3/objects/contacts", json=payload)
        return result
    except Exception as e:
        if "CONTACT_EXISTS" in str(e):
            # Already exists — safe to ignore or fetch existing
            return find_contact_by_email(properties["email"])
        raise
```

**Solution 2: Event-ID deduplication store**

Track processed `eventId` values to skip reprocessing:

```python
from typing import Set
import redis

dedup_store = redis.Redis(host="localhost", port=6379, db=1)

def process_webhook_event(event: dict) -> bool:
    """Returns True if processed, False if skipped (duplicate)."""
    event_id = str(event["eventId"])
    key = f"hs:event:{event_id}"

    # Atomic set-if-not-exists with 24h TTL
    was_new = dedup_store.set(key, "1", ex=86400, nx=True)
    if not was_new:
        return False  # Already processed

    # Process...
    return True
```

**Solution 3: CRM property as processing flag**

Use a custom boolean/datetime property on the record itself as a processing lock:

```python
AGENT_PROCESSED_PROP = "ai_agent_processed_at"

def is_already_processed(contact_id: str) -> bool:
    contact = client.get(f"/crm/v3/objects/contacts/{contact_id}",
                        params={"properties": AGENT_PROCESSED_PROP})
    value = contact["properties"].get(AGENT_PROCESSED_PROP)
    return value is not None

def mark_processed(contact_id: str):
    client.patch(f"/crm/v3/objects/contacts/{contact_id}", json={
        "properties": {
            AGENT_PROCESSED_PROP: str(int(time.time() * 1000))
        }
    })
```

---

## Deduplication Strategies

**Problem:** The same real-world entity (person, company) may arrive via multiple channels, creating duplicate CRM records that fragment your data.

**Strategy 1: Email lookup before create (contacts)**
```python
def upsert_contact(email: str, properties: dict) -> dict:
    """Create contact or update existing one by email."""
    # Search for existing
    search_payload = {
        "filterGroups": [{"filters": [
            {"propertyName": "email", "operator": "EQ", "value": email}
        ]}],
        "properties": list(properties.keys()) + ["email"],
        "limit": 1
    }

    result = client.post("/crm/v3/objects/contacts/search", json=search_payload)
    existing = result.get("results", [])

    if existing:
        contact_id = existing[0]["id"]
        # Update existing record
        client.patch(f"/crm/v3/objects/contacts/{contact_id}",
                    json={"properties": properties})
        return {"id": contact_id, "action": "updated"}
    else:
        # Create new record
        new_contact = client.post("/crm/v3/objects/contacts",
                                 json={"properties": {**properties, "email": email}})
        return {"id": new_contact["id"], "action": "created"}
```

**Strategy 2: Domain-based company deduplication**
```python
def upsert_company(domain: str, properties: dict) -> dict:
    search_payload = {
        "filterGroups": [{"filters": [
            {"propertyName": "domain", "operator": "EQ", "value": domain}
        ]}],
        "properties": ["domain", "name"],
        "limit": 1
    }

    result = client.post("/crm/v3/objects/companies/search", json=search_payload)
    existing = result.get("results", [])

    if existing:
        company_id = existing[0]["id"]
        client.patch(f"/crm/v3/objects/companies/{company_id}",
                    json={"properties": properties})
        return {"id": company_id, "action": "updated"}
    else:
        new_co = client.post("/crm/v3/objects/companies",
                            json={"properties": {**properties, "domain": domain}})
        return {"id": new_co["id"], "action": "created"}
```

---

## Error Handling Flowchart (Text)

```
API Request
    │
    ▼
Response received?
    │
    ├── NO ──► Network timeout/connection error
    │                │
    │                ▼
    │          Retry with backoff (max 5 attempts)
    │                │
    │                ├── Still failing after 5 → Log + alert + dead-letter queue
    │                └── Success → continue
    │
    └── YES ──► Check status code
                    │
                    ├── 200-299 ──► Parse response JSON → continue
                    │
                    ├── 400 ──► Bad request
                    │               │
                    │               ├── PROPERTY_DOESNT_EXIST → Log skip, don't retry
                    │               ├── VALIDATION_ERROR → Log + fix payload, don't retry
                    │               └── Other 400 → Log, investigate manually
                    │
                    ├── 401 ──► Auth error
                    │               │
                    │               ├── Private App: token revoked → Alert + halt
                    │               └── OAuth: refresh token → retry once
                    │
                    ├── 403 ──► Missing scope
                    │               │
                    │               └── Log scope name → add to Private App → retry
                    │
                    ├── 404 ──► Record not found
                    │               │
                    │               └── Record deleted between webhook fire and fetch
                    │                   → Skip gracefully (not an error condition)
                    │
                    ├── 429 ──► Rate limited
                    │               │
                    │               └── Read Retry-After header → sleep → retry
                    │                   (max 5 retries with exponential backoff)
                    │
                    └── 500-504 ──► HubSpot server error
                                        │
                                        └── Exponential backoff → retry
                                            After 5 fails → log + dead-letter
```

---

## CRM as State Store Pattern

HubSpot CRM can act as a durable state machine for AI workflows. Rather than maintaining separate state in a database, use custom properties on CRM records to track where each record is in the agent's workflow.

**Define agent state properties on contacts:**
```python
def setup_agent_properties():
    """Create custom properties for agent state tracking."""
    agent_properties = [
        {
            "name": "ai_processing_status",
            "label": "AI Processing Status",
            "type": "enumeration",
            "fieldType": "select",
            "options": [
                {"label": "Pending", "value": "pending", "displayOrder": 0},
                {"label": "In Progress", "value": "in_progress", "displayOrder": 1},
                {"label": "Completed", "value": "completed", "displayOrder": 2},
                {"label": "Failed", "value": "failed", "displayOrder": 3},
                {"label": "Skipped", "value": "skipped", "displayOrder": 4},
            ],
            "groupName": "contactinformation"
        },
        {
            "name": "ai_last_action",
            "label": "AI Last Action",
            "type": "string",
            "fieldType": "text",
            "groupName": "contactinformation"
        },
        {
            "name": "ai_processed_at",
            "label": "AI Processed At",
            "type": "datetime",
            "fieldType": "date",
            "groupName": "contactinformation"
        },
        {
            "name": "ai_agent_notes",
            "label": "AI Agent Notes",
            "type": "string",
            "fieldType": "textarea",
            "groupName": "contactinformation"
        }
    ]

    for prop in agent_properties:
        try:
            client.post("/crm/v3/properties/contacts", json=prop)
            print(f"Created property: {prop['name']}")
        except Exception as e:
            if "already exists" in str(e).lower():
                print(f"Property already exists: {prop['name']}")
            else:
                raise
```

**State machine update:**
```python
def update_agent_state(contact_id: str, status: str, action: str = None, notes: str = None):
    properties = {
        "ai_processing_status": status,
        "ai_processed_at": str(int(time.time() * 1000))
    }
    if action:
        properties["ai_last_action"] = action
    if notes:
        properties["ai_agent_notes"] = notes

    client.patch(f"/crm/v3/objects/contacts/{contact_id}",
                json={"properties": properties})

# Usage in agent workflow
def process_contact(contact_id: str):
    update_agent_state(contact_id, "in_progress", action="ai_enrichment_started")

    try:
        # Do AI work...
        enriched_data = ai_enrich_contact(contact_id)

        # Write results back to CRM
        client.patch(f"/crm/v3/objects/contacts/{contact_id}",
                    json={"properties": enriched_data})

        update_agent_state(contact_id, "completed", action="enrichment_complete",
                          notes=f"Added {len(enriched_data)} properties")

    except Exception as e:
        update_agent_state(contact_id, "failed",
                          notes=f"Error: {str(e)[:500]}")
        raise
```

---

## Production Code Examples

**Complete webhook-driven agent:**
```python
import asyncio
import json
import os
import time
from fastapi import FastAPI, Request, BackgroundTasks
import redis
import hubspot

app = FastAPI()
redis_client = redis.Redis.from_url(os.environ.get("REDIS_URL", "redis://localhost:6379"))
hs_client = hubspot.Client.create(access_token=os.environ["HUBSPOT_ACCESS_TOKEN"])

@app.post("/webhook/hubspot")
async def handle_webhook(request: Request, background: BackgroundTasks):
    # 1. Validate HMAC (see webhooks-briefing.md)
    body = await validate_hmac(request)
    events = json.loads(body)

    # 2. Immediately respond 200
    background.add_task(process_batch, events)
    return {"status": "ok"}

async def process_batch(events: list):
    for event in events:
        if not mark_seen(event["eventId"]):
            continue  # Dedup: already processed
        await handle_event(event)

async def handle_event(event: dict):
    event_type = event["subscriptionType"]
    object_id = str(event["objectId"])

    if event_type == "contact.creation":
        await on_contact_created(object_id)
    elif event_type == "deal.propertyChange":
        if event.get("propertyName") == "dealstage":
            await on_deal_stage_changed(object_id, event.get("propertyValue"))

async def on_contact_created(contact_id: str):
    """Fetch full contact and run enrichment."""
    contact = hs_client.crm.contacts.basic_api.get_by_id(
        contact_id,
        properties=["email", "firstname", "lastname", "company", "jobtitle"]
    )

    update_agent_state(contact_id, "in_progress")

    # AI enrichment logic here...
    enriched = await ai_enrich(contact.properties)

    hs_client.crm.contacts.basic_api.update(
        contact_id,
        simple_public_object_input={"properties": enriched}
    )
    update_agent_state(contact_id, "completed", notes="Enrichment applied")

def mark_seen(event_id: int) -> bool:
    """Returns True if new, False if duplicate."""
    key = f"hs:event:{event_id}"
    return bool(redis_client.set(key, 1, ex=86400, nx=True))

def update_agent_state(contact_id: str, status: str, notes: str = None):
    props = {"ai_processing_status": status,
             "ai_processed_at": str(int(time.time() * 1000))}
    if notes:
        props["ai_agent_notes"] = notes
    hs_client.crm.contacts.basic_api.update(
        contact_id,
        simple_public_object_input={"properties": props}
    )
```

---

## Anti-Patterns to Avoid

1. **Polling instead of webhooks for real-time triggers** — Polling every minute uses 1,440 API calls per day minimum, even when nothing changes. Use webhooks for event-driven logic.

2. **Creating duplicate records without dedup check** — Always search by email/domain before creating contacts/companies. HubSpot merging is manual and time-consuming.

3. **Synchronous webhook processing** — If your handler takes >5 seconds, HubSpot marks delivery as failed and retries. Always respond 200 immediately, process in a background task or queue.

4. **Ignoring `attemptNumber`** — Retried events (`attemptNumber > 0`) have already been attempted. Log these separately to detect systematic failures.

5. **Writing to CRM without checking current state** — Always read a record before patching to avoid overwriting data from other systems. Use `propertiesWithHistory` to understand what changed and when.

6. **Using search API for high-frequency polling** — The Search API limit is 5 req/s. Using it as a polling mechanism (check for new contacts every 10s) will hit this limit quickly. Use webhooks instead.

7. **Storing all state externally** — If you have a database tracking which contacts were processed, you've created a sync problem. Store agent state as custom properties on the CRM record itself — it's the authoritative source of truth, it's queryable, and it's visible in the HubSpot UI for human review.

8. **Hardcoding pipeline/stage IDs** — Pipeline and stage IDs are portal-specific UUIDs. Fetch them at startup via the Pipelines API and cache, or read from environment configuration. Never hardcode.

9. **Not handling 404 on webhook fetch** — A `contact.creation` webhook fires, but by the time your agent fetches the record, it may have been merged or deleted. Always handle 404 gracefully (skip, don't error).

10. **Using legacy v3 Associations API** — The v3 associations are deprecated. Use v4 for all new association work. v4 supports labels, higher limits, and cleaner batch operations.
