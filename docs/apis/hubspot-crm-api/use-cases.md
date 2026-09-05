# HubSpot CRM API — Use Cases & Practical Summary

**Source:** Deep research synthesis, 2026-03-18
**Full docs:** `documentation.md`, `MASTER-SYNTHESIS.md`

---

## What You Can Do

### Free (No Cost, API key required)
| Capability | Notes |
|-----------|-------|
| Read/write Contacts, Companies, Deals, Tickets | Core CRM CRUD |
| Batch operations (100 records/call) | Major rate limit savings |
| Custom properties | Unlimited on all plans |
| Search API (10K record limit) | All plans |
| Associations (v4) | All plans |
| Engagements (notes, tasks, calls, meetings) | All plans |
| Pipelines API | All plans |
| Import/export API | All plans |

### Paid (Professional/Enterprise Required)
| Capability | Tier Required |
|-----------|--------------|
| Webhooks | Professional+ |
| Custom Objects | Enterprise only |
| Custom code workflow actions | Operations Hub Pro+ |
| Higher rate limits (190 burst, 625K-1M daily) | Professional+ |
| CRM Extensions (timeline events for apps) | Any |
| Lists API v3 | Any |

---

## Key Limits & Gotchas

| Limit | Value |
|-------|-------|
| Free/Starter burst rate | 100 req / 10 seconds |
| Professional burst rate | 190 req / 10 seconds |
| Free/Starter daily limit | 250,000 req/day |
| Search API rate | 5 req/sec (all plans) |
| Batch operation max | 100 records per call |
| Search results max | 10,000 records |
| Custom objects | Enterprise only |
| Private App token expiry | Never (until revoked) |
| OAuth token expiry | 30 minutes |
| Webhook retries | 10 retries over 24 hours |
| Custom schema name | Permanent (cannot change) |

---

## Practical Automation Ideas

| Idea | Complexity | Notes |
|------|-----------|-------|
| AI lead enrichment agent | Easy | Search contact → enrich properties → update |
| Webhook-driven deal stage automation | Medium | Trigger agent on deal.propertyChange |
| Bulk contact import from CSV | Easy | Use Import API or batch/upsert |
| Automated follow-up task creation | Easy | POST to /crm/v3/objects/tasks |
| Sync contacts from external database | Medium | Batch upsert by email, incremental polling |
| Auto-log AI conversations as notes | Easy | POST to /crm/v3/objects/notes + associate |
| AI-powered deal scoring | Medium | Custom property + PATCH on trigger |
| CRM as agent memory/state store | Medium | Custom properties store processing status |
| Real-time pipeline monitoring | Medium | Webhooks on deal.propertyChange (dealstage) |
| Company domain deduplication | Easy | Batch read by domain, upsert |
| Custom object for AI sessions | Complex | Enterprise only, stores agent run data |
| Ticket auto-routing by content | Complex | Read ticket → classify → update owner/stage |
| Webhook idempotent processor | Medium | Redis + eventId dedup, async queue |
| Incremental CRM sync (polling) | Medium | Filter lastmodifieddate GT cursor |
| Export all contacts to CSV | Medium | CRM export API or paginated search |

---

## Best Architecture Choices

**For AI agents interacting with HubSpot CRM:**

1. **Use Private App tokens** — no refresh logic needed, stable for automation
2. **Use webhooks (Pro+) for real-time triggers** — don't poll if you can webhook
3. **Use batch endpoints always** — 100x more efficient than individual calls
4. **Store agent state as custom properties** — e.g., `agent_status`, `agent_last_run`
5. **Deduplicate by email/domain** — use batch/upsert with `idProperty: "email"`
6. **Implement exponential backoff for 429s** — especially for Search API (5 req/sec)
7. **Use cursor pagination** — never use page offsets, always use `paging.next.after`

---

## Already Built Scripts / Tools

_(None yet — this is the initial documentation. Add scripts here as they are built.)_

---

## Key Authentication Steps

1. HubSpot Portal → Settings → Integrations → Private Apps
2. Create app, select scopes (minimum: `crm.objects.contacts.read/write`, etc.)
3. Generate token → store as `HUBSPOT_ACCESS_TOKEN` in `.env`
4. Usage: `Authorization: Bearer {HUBSPOT_ACCESS_TOKEN}`

**No webhook secret setup:** Configure in the Private App → Webhooks tab. Copy the "Client Secret" as `HUBSPOT_WEBHOOK_SECRET` for HMAC validation.

---

## Quick Start (Python)

```python
import os
import requests

HUBSPOT_TOKEN = os.environ["HUBSPOT_ACCESS_TOKEN"]
BASE_URL = "https://api.hubspot.com"

headers = {
    "Authorization": f"Bearer {HUBSPOT_TOKEN}",
    "Content-Type": "application/json"
}

# Create a contact
response = requests.post(
    f"{BASE_URL}/crm/v3/objects/contacts",
    headers=headers,
    json={"properties": {"email": "test@example.com", "firstname": "Test"}}
)

# Search contacts
response = requests.post(
    f"{BASE_URL}/crm/v3/objects/contacts/search",
    headers=headers,
    json={
        "filterGroups": [{"filters": [{"propertyName": "email", "operator": "EQ", "value": "test@example.com"}]}],
        "properties": ["email", "firstname", "lastname"],
        "limit": 10
    }
)
```

---

## Env Variables Needed

```bash
HUBSPOT_ACCESS_TOKEN=pat-na1-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
HUBSPOT_WEBHOOK_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  # For webhook HMAC validation
HUBSPOT_APP_ID=123456  # Only needed for webhook API management
HUBSPOT_PORTAL_ID=123456  # Your HubSpot portal/account ID
```
