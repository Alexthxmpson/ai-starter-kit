# HubSpot CRM API — Webhooks Briefing
**Source:** agent3-webhooks-rate-limits.md, agent6-custom-objects-advanced.md
**Date:** 2026-03-18

---

## Quick Summary

HubSpot webhooks push CRM events to your endpoint in real-time. They are configured at the **app level** (not portal level) and fire whenever a subscribed object event occurs. The payload arrives as a JSON array of events, batched up to 100 per request. HubSpot signs payloads with HMAC-SHA256 using the app's client secret — always validate the signature before processing. Webhooks have at-least-once delivery semantics, so implement idempotency in your handler.

**Core use case:** Trigger AI agent workflows when contacts are created, deals advance, or properties change — without polling.

---

## Setup Process

Webhooks are app-level settings, configured either through the HubSpot developer portal UI or via the Webhooks API. You need a registered HubSpot app with a client secret.

**API setup:**

**1. Set the webhook target URL:**
```
PUT https://api.hubspot.com/webhooks/v3/{appId}/settings
Authorization: Bearer {DEVELOPER_HAPIKEY}   # Note: dev account key, not portal token
Content-Type: application/json

{
  "targetUrl": "https://your-domain.com/hubspot-webhook",
  "throttlingSettings": {
    "period": "SECONDLY",
    "maxConcurrentRequests": 10
  }
}
```

**2. Create a subscription:**
```
POST https://api.hubspot.com/webhooks/v3/{appId}/subscriptions
Authorization: Bearer {DEVELOPER_HAPIKEY}
Content-Type: application/json

{
  "eventType": "contact.creation",
  "propertyName": null,
  "active": true
}
```

**For property-change events, set propertyName:**
```json
{
  "eventType": "contact.propertyChange",
  "propertyName": "lifecyclestage",
  "active": true
}
```

**3. List existing subscriptions:**
```
GET https://api.hubspot.com/webhooks/v3/{appId}/subscriptions
```

**4. Delete a subscription:**
```
DELETE https://api.hubspot.com/webhooks/v3/{appId}/subscriptions/{subscriptionId}
```

---

## All Event Types

| Category | Event Type | Fires When |
|---|---|---|
| Contact | `contact.creation` | New contact created |
| Contact | `contact.deletion` | Contact archived |
| Contact | `contact.privacyDeletion` | GDPR deletion request |
| Contact | `contact.propertyChange` | Any/specific property updated |
| Company | `company.creation` | New company created |
| Company | `company.deletion` | Company archived |
| Company | `company.propertyChange` | Any/specific property updated |
| Deal | `deal.creation` | New deal created |
| Deal | `deal.deletion` | Deal archived |
| Deal | `deal.propertyChange` | Any/specific property updated |
| Ticket | `ticket.creation` | New ticket created |
| Ticket | `ticket.deletion` | Ticket archived |
| Ticket | `ticket.propertyChange` | Any/specific property updated |
| Line Item | `line_item.creation` | New line item created |
| Line Item | `line_item.deletion` | Line item deleted |
| Line Item | `line_item.propertyChange` | Line item updated |
| Product | `product.creation` | New product created |
| Product | `product.deletion` | Product deleted |
| Product | `product.propertyChange` | Product updated |
| Quote | `quote.creation` | New quote created |
| Quote | `quote.deletion` | Quote deleted |
| Quote | `quote.propertyChange` | Quote updated |
| Conversation | `conversation.creation` | New conversation created |
| Conversation | `conversation.deletion` | Conversation deleted |
| Conversation | `conversation.newMessage` | New message in conversation |
| Conversation | `conversation.propertyChange` | Conversation property updated |

**Custom objects also support:** `{objectTypeId}.creation`, `{objectTypeId}.deletion`, `{objectTypeId}.propertyChange`

---

## Payload Structure with Examples

HubSpot delivers a JSON array. Multiple events from the same subscription batch together.

**Single event payload:**
```json
[
  {
    "eventId": 1234567890,
    "subscriptionId": 98765,
    "portalId": 12345678,
    "appId": 11111,
    "occurredAt": 1700000000000,
    "subscriptionType": "contact.creation",
    "attemptNumber": 0,
    "objectId": 987654321,
    "changeSource": "CRM_UI",
    "changeFlag": "CREATED"
  }
]
```

**Property change event:**
```json
[
  {
    "eventId": 9876543210,
    "subscriptionId": 98766,
    "portalId": 12345678,
    "appId": 11111,
    "occurredAt": 1700000001000,
    "subscriptionType": "contact.propertyChange",
    "attemptNumber": 0,
    "objectId": 987654321,
    "propertyName": "lifecyclestage",
    "propertyValue": "customer",
    "changeSource": "AUTOMATION_PLATFORM",
    "changeFlag": "PROPERTY_CHANGED"
  }
]
```

**Field reference:**
| Field | Type | Description |
|---|---|---|
| `eventId` | long | Unique ID for this event — use for deduplication |
| `subscriptionId` | long | Which subscription triggered this |
| `portalId` | long | HubSpot portal (account) ID |
| `appId` | long | App ID that has the subscription |
| `occurredAt` | long | Unix timestamp in milliseconds |
| `subscriptionType` | string | Event type (e.g., `contact.creation`) |
| `attemptNumber` | int | 0 = first attempt; >0 = retry |
| `objectId` | long | CRM record ID that triggered the event |
| `propertyName` | string | Property that changed (propertyChange only) |
| `propertyValue` | string | New value after change |
| `changeSource` | string | What triggered the change (CRM_UI, API, AUTOMATION_PLATFORM, etc.) |

---

## HMAC Security Validation (Python)

HubSpot signs every webhook request with your app's client secret. Always validate before processing.

**Validation using X-HubSpot-Signature-v3 (recommended):**
```python
import hmac
import hashlib
import base64
import time
from fastapi import Request, HTTPException

HUBSPOT_CLIENT_SECRET = os.environ["HUBSPOT_CLIENT_SECRET"]
MAX_REQUEST_AGE_SECONDS = 300  # 5 minutes

async def validate_hubspot_webhook(request: Request) -> bytes:
    """Validate HubSpot HMAC signature. Returns raw body if valid."""
    body = await request.body()

    # Get signature components
    signature_v3 = request.headers.get("X-HubSpot-Signature-v3", "")
    timestamp = request.headers.get("X-HubSpot-Request-Timestamp", "")

    if not signature_v3 or not timestamp:
        raise HTTPException(status_code=401, detail="Missing HubSpot signature headers")

    # Check request age (prevents replay attacks)
    request_time = int(timestamp) / 1000  # convert ms to seconds
    if abs(time.time() - request_time) > MAX_REQUEST_AGE_SECONDS:
        raise HTTPException(status_code=401, detail="Request timestamp too old")

    # Build the signature source string
    method = request.method
    url = str(request.url)
    source_string = f"{method}{url}{body.decode('utf-8')}{timestamp}"

    # Compute HMAC-SHA256
    computed = hmac.new(
        HUBSPOT_CLIENT_SECRET.encode("utf-8"),
        source_string.encode("utf-8"),
        hashlib.sha256
    ).digest()
    computed_b64 = base64.b64encode(computed).decode("utf-8")

    # Constant-time comparison
    if not hmac.compare_digest(computed_b64, signature_v3):
        raise HTTPException(status_code=401, detail="Invalid HMAC signature")

    return body


# FastAPI webhook handler
from fastapi import FastAPI
import json

app = FastAPI()

@app.post("/hubspot-webhook")
async def hubspot_webhook(request: Request):
    body = await validate_hubspot_webhook(request)
    events = json.loads(body)

    for event in events:
        await process_event(event)

    return {"status": "ok"}

async def process_event(event: dict):
    event_type = event["subscriptionType"]
    object_id = event["objectId"]
    event_id = event["eventId"]

    # Idempotency check
    if await is_already_processed(event_id):
        return

    if event_type == "contact.creation":
        await handle_new_contact(object_id)
    elif event_type == "deal.propertyChange":
        prop = event.get("propertyName")
        value = event.get("propertyValue")
        await handle_deal_property_change(object_id, prop, value)

    await mark_as_processed(event_id)
```

**Legacy v1 signature (still supported):**
```python
def validate_v1_signature(client_secret: str, request_body: str, signature: str) -> bool:
    source = client_secret + request_body
    computed = hashlib.sha256(source.encode("utf-8")).hexdigest()
    return hmac.compare_digest(computed, signature)
```

---

## Retry Behavior and Idempotency

**HubSpot retry schedule:**
| Attempt | Wait Before |
|---|---|
| 1 (initial) | Immediate |
| 2 | 5 minutes |
| 3 | 1 hour |
| 4 | 4 hours |
| 5 | 8 hours |

After 5 failed attempts, the event is dropped. HubSpot considers a delivery successful if your endpoint returns any 2xx status code within a timeout window (typically 5 seconds). If your handler takes longer, respond with 200 immediately and process asynchronously.

**Batching behavior:** HubSpot batches up to 100 events per HTTP request. If your endpoint is slow or down, retried events may arrive in a different batch composition than the original delivery.

**Idempotency — handling duplicate deliveries:**
```python
import redis

redis_client = redis.Redis(host="localhost", port=6379, db=0)
DEDUP_WINDOW = 86400  # 24 hours

async def is_already_processed(event_id: int) -> bool:
    key = f"hs_event:{event_id}"
    return redis_client.exists(key) > 0

async def mark_as_processed(event_id: int):
    key = f"hs_event:{event_id}"
    redis_client.setex(key, DEDUP_WINDOW, "1")
```

**Important:** `attemptNumber` in the payload tells you if this is a retry (>0). Always check `eventId` for deduplication regardless of attempt number, as the same event can arrive multiple times due to network conditions even on attempt 0.

**Respond fast, process async:**
```python
import asyncio
from fastapi.background import BackgroundTasks

@app.post("/hubspot-webhook")
async def hubspot_webhook(request: Request, background_tasks: BackgroundTasks):
    body = await validate_hubspot_webhook(request)
    events = json.loads(body)

    # Queue processing in background — respond within 5s
    background_tasks.add_task(process_events_batch, events)

    return {"status": "queued"}  # Return 200 immediately
```
