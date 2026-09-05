# HubSpot CRM API — Webhooks & Rate Limits
## Complete Technical Reference for AI Agent Integration

**Sources:** developers.hubspot.com, hookdeck.com, HubSpot Developer Changelog
**Date Compiled:** 2026-03-18
**Coverage:** Webhooks API v3 + v4 (beta), Rate Limits (2024–2025 tiers)

---

## Table of Contents

1. [Webhooks Overview](#1-webhooks-overview)
2. [Webhook Subscription Setup](#2-webhook-subscription-setup)
3. [Subscription Types and Event Catalog](#3-subscription-types-and-event-catalog)
4. [Webhook Payload Structure](#4-webhook-payload-structure)
5. [Webhook Security and HMAC Validation](#5-webhook-security-and-hmac-validation)
6. [Retry Logic and Delivery Guarantees](#6-retry-logic-and-delivery-guarantees)
7. [Batching Behavior](#7-batching-behavior)
8. [Filtering Webhooks by Property](#8-filtering-webhooks-by-property)
9. [Testing Webhooks](#9-testing-webhooks)
10. [Webhooks Journal API (Beta v4)](#10-webhooks-journal-api-beta-v4)
11. [Rate Limits Overview](#11-rate-limits-overview)
12. [Rate Limits by Plan Tier](#12-rate-limits-by-plan-tier)
13. [Private App vs. OAuth App Limits](#13-private-app-vs-oauth-app-limits)
14. [Rate Limit Response Headers](#14-rate-limit-response-headers)
15. [429 Error Response Structure](#15-429-error-response-structure)
16. [Retry-After and Exponential Backoff](#16-retry-after-and-exponential-backoff)
17. [Batch API for Rate Limit Management](#17-batch-api-for-rate-limit-management)
18. [Caching Strategies](#18-caching-strategies)
19. [AI Agent Integration Architecture](#19-ai-agent-integration-architecture)
20. [Quick Reference Tables](#20-quick-reference-tables)

---

## 1. Webhooks Overview

HubSpot Webhooks allow external systems to receive real-time HTTP notifications when CRM events occur in an account that has installed your integration. Instead of polling the HubSpot API on a schedule to check for changes, HubSpot pushes data to your endpoint the moment an event fires — contact created, deal stage changed, ticket deleted, and so on.

This event-driven pattern is foundational for AI agent integrations because it allows an agent system to react to CRM changes immediately, maintain up-to-date context, and avoid consuming API rate quota on repetitive polling.

**Key architectural facts:**
- Webhooks are configured at the application level (public app or private app), not per-account. Every account that installs the app receives the same subscriptions.
- HubSpot sends POST requests to a single HTTPS endpoint you configure in your app's webhook settings.
- Requests contain a JSON array of events. Up to 100 events may be batched into a single request.
- Webhook delivery does not count against your API rate limit quota (with the exception of workflow-triggered webhooks in certain plan configurations).
- Maximum 1,000 subscriptions per application.
- Concurrency cap: HubSpot sends at most 10 simultaneous in-flight requests to your endpoint per installed account.

**When to use webhooks vs. polling:**
Use webhooks whenever your integration needs to react to changes in near-real-time, when you have a high volume of CRM activity, or when API quota is a concern. Use polling only when your endpoint cannot receive inbound connections or when you need a historical backfill that webhooks cannot provide.

---

## 2. Webhook Subscription Setup

### 2.1 Setup via the Developer Dashboard (Public and Private Apps)

**For public apps:**
1. Log in to your HubSpot developer account at `app.hubspot.com/developer`.
2. Navigate to **Apps** and click the name of the app.
3. In the left sidebar, click **Webhooks**.
4. Enter the webhook **Target URL** — this must be a publicly accessible HTTPS endpoint.
5. Optionally configure the **Max concurrent requests** (default: 10, max: 10).
6. Click **Create subscription** to add a new subscription.
7. In the subscription panel, select the **Object type** (contacts, deals, companies, tickets, etc.) and the **Event type** (creation, deletion, propertyChange, etc.).
8. For `propertyChange` subscriptions, specify the exact property name to monitor.
9. New subscriptions are created in a **paused state** — you must activate each subscription for it to send events.

**For private apps:**
1. In your HubSpot account, click the **Settings** gear icon (top right).
2. Navigate to **Integrations > Private Apps** in the left sidebar.
3. Click the name of your private app.
4. Click the **Webhooks** tab.
5. Configure the target URL and add subscriptions. Private app webhook settings can only be edited through the UI, not through the API.

**Important timing note:** Changes to webhook URL, concurrency limits, or subscription settings may take up to **5 minutes** to propagate.

### 2.2 Setup via the Webhooks API (Public Apps Only)

Public app webhook subscriptions can be managed programmatically via the Webhooks API v3.

**Base path:** `https://api.hubapi.com/webhooks/v3/{appId}/`

**Authentication:** All Webhooks API calls use a HubSpot developer API key or private app token in the header.

**Create a subscription:**
```
POST https://api.hubapi.com/webhooks/v3/{appId}/subscriptions
Authorization: Bearer {your-private-app-token}
Content-Type: application/json

{
  "eventType": "contact.creation",
  "propertyName": null,
  "active": true
}
```

**Get all subscriptions:**
```
GET https://api.hubapi.com/webhooks/v3/{appId}/subscriptions
```

**Update webhook settings (target URL and concurrency):**
```
PUT https://api.hubapi.com/webhooks/v3/{appId}/settings
Content-Type: application/json

{
  "targetUrl": "https://your-endpoint.example.com/webhooks",
  "maxConcurrentRequests": 10
}
```

**Delete a subscription:**
```
DELETE https://api.hubapi.com/webhooks/v3/{appId}/subscriptions/{subscriptionId}
```

### 2.3 Setup via Developer Projects (New Framework — `webhooks-hsmeta.json`)

HubSpot's newer developer projects framework enables code-based webhook configuration. This is particularly useful for version-controlled, team-based development workflows.

**Project directory structure:**
```
/src
  /app
    /webhooks
      contact-changes-hsmeta.json
      deal-stage-changes-hsmeta.json
```

**Example `contact-changes-hsmeta.json`:**
```json
{
  "version": "0",
  "type": "WEBHOOK",
  "name": "contact-changes",
  "description": "Fires on contact creation and property changes",
  "subscriptions": [
    {
      "eventType": "contact.creation",
      "active": true
    },
    {
      "eventType": "contact.propertyChange",
      "propertyName": "lifecyclestage",
      "active": true
    }
  ]
}
```

Manage the full app lifecycle using the HubSpot CLI (`hs`). This enables source control (e.g., GitHub) collaboration and repeatable deployments of webhook configurations.

### 2.4 Required Scopes

Webhook subscriptions require the app to have the correct OAuth scopes authorized for each CRM object. If the scope is not present, HubSpot will not emit events for that object type.

| Object Type | Required Scope |
|---|---|
| Contacts | `crm.objects.contacts.read` |
| Companies | `crm.objects.companies.read` |
| Deals | `crm.objects.deals.read` |
| Tickets | `tickets` |
| Products | `e-commerce` |
| Line Items | `crm.objects.line_items.read` |
| Conversations | `conversations.read` (beta) |

---

## 3. Subscription Types and Event Catalog

### 3.1 Legacy vs. Generic Format

HubSpot originally used object-specific subscription type names. In August 2024, HubSpot introduced a generic format that standardizes naming and supports 24+ additional CRM object types.

| Format | Example | Notes |
|---|---|---|
| **Legacy** | `contact.creation` | Still supported, not deprecated |
| **Generic (new)** | `object.creation` | Object identified via `objectTypeId` in payload |

The generic format should be preferred for new integrations, as it will receive new object type support automatically.

### 3.2 Event Types Available for All CRM Objects

| Event Type | Trigger |
|---|---|
| `object.creation` / `{object}.creation` | A new record is created |
| `object.deletion` / `{object}.deletion` | A record is deleted (moved to recycle bin) |
| `object.propertyChange` / `{object}.propertyChange` | A specific property on a record changes value |
| `object.associationChange` / `{object}.associationChange` | An association between two records is created or removed |
| `object.restore` / `{object}.restore` | A deleted record is restored from the recycle bin |
| `object.merge` / `{object}.merge` | Two records are merged; one is the primary, others are merged in |
| `contact.privacyDeletion` | A contact is deleted for GDPR/privacy compliance reasons (contacts only) |

### 3.3 Supported CRM Object Types (2024)

The following object types are now supported for webhook subscriptions:

| Object | `objectTypeId` | Legacy Prefix | Notes |
|---|---|---|---|
| Contact | `0-1` | `contact.*` | Full event support including `privacyDeletion` |
| Company | `0-2` | `company.*` | |
| Deal | `0-3` | `deal.*` | |
| Ticket | `0-5` | `ticket.*` | |
| Product | `0-7` | `product.*` | |
| Line Item | `0-8` | `line_item.*` | |
| Note | `0-4` | — | Generic format only |
| Task | `0-27` | — | Generic format only |
| Meeting Event | `0-47` | — | Generic format only |
| Call | `0-48` | — | Generic format only |
| Email | `0-49` | — | `hs_email_html`, `hs_email_subject` restricted |
| Postal Mail | `0-116` | — | Generic format only |
| Communication | `0-18` | — | `hs_communication_body` restricted |
| Quote | `0-14` | — | Generic format only |
| Lead | `0-83` | — | Generic format only |
| Cart | — | — | Generic format only |
| Order | — | — | Generic format only |
| Invoice | — | — | Generic format only |
| Subscription | — | — | Generic format only |
| Discount | — | — | Generic format only |
| Fee | — | — | Generic format only |
| Tax | — | — | Generic format only |
| Commerce Payment | — | — | Generic format only |
| Feedback Submission | — | — | Generic format only |
| Goal Target | — | — | Generic format only |
| Quote Template | — | — | Generic format only |

**Note:** The `ENGAGEMENT` object type is no longer supported in generic webhook subscriptions. Use individual engagement subtypes (Call, Email, Note, Task, Meeting) instead.

### 3.4 Conversations-Specific Subscription Types

Conversations API webhooks (beta) fire on thread-level events. Property change subscriptions for conversations must specify which property to monitor:

| Property | Description |
|---|---|
| `assignedTo` | Thread reassigned or unassigned. `propertyValue` = actor ID (if assigned) or empty (if unassigned) |
| `status` | Thread status changed. `propertyValue` = `OPEN` or `CLOSED` |
| `isArchived` | Thread archived or restored from archive |

Conversation event types:
- `conversation.creation` — New thread created
- `conversation.deletion` — Thread deleted
- `conversation.privacyDeletion` — GDPR deletion
- `conversation.propertyChange` — Thread property changed
- `conversation.newMessage` — New message or comment added to thread (includes `messageId` and `messageType`)

---

## 4. Webhook Payload Structure

HubSpot sends webhook notifications as HTTP POST requests with a `Content-Type: application/json` body. The body is always a **JSON array** containing one or more event objects.

### 4.1 Base Payload Fields

Every webhook event object contains these fields:

| Field | Type | Description |
|---|---|---|
| `objectId` | integer | The ID of the modified CRM record |
| `eventId` | integer | An identifier for this event (not guaranteed unique across all retries) |
| `subscriptionId` | integer | The ID of the subscription that triggered this notification |
| `portalId` | integer | The HubSpot account (portal) ID where the event occurred |
| `appId` | integer | Your application's ID |
| `occurredAt` | integer | Unix timestamp in milliseconds of when the event occurred |
| `eventType` | string | The subscription type that was triggered (e.g., `contact.creation`) |
| `subscriptionType` | string | Alias for `eventType` — same value |
| `attemptNumber` | integer | How many times delivery has been attempted (starts at 0) |
| `changeSource` | string | What caused the change: `CRM`, `IMPORT`, `API`, `INTEGRATION`, `WORKFLOW`, `ACADEMY`, etc. |
| `objectTypeId` | string | Object type in raw ID format (e.g., `"0-1"` for contacts) — present in generic format events |

### 4.2 Property Change Event Payload

When subscribing to `propertyChange` events, two additional fields are present:

```json
[
  {
    "objectId": 1246965,
    "propertyName": "lifecyclestage",
    "propertyValue": "subscriber",
    "changeSource": "ACADEMY",
    "eventId": 3816279340,
    "subscriptionId": 25,
    "portalId": 33,
    "appId": 1160452,
    "occurredAt": 1462216307945,
    "subscriptionType": "contact.propertyChange",
    "eventType": "contact.propertyChange",
    "attemptNumber": 0
  }
]
```

| Additional Field | Description |
|---|---|
| `propertyName` | The internal name of the property that changed |
| `propertyValue` | The new value of the property after the change |

### 4.3 Creation Event Payload

```json
[
  {
    "objectId": 7654321,
    "eventId": 9871234560,
    "subscriptionId": 42,
    "portalId": 33,
    "appId": 1160452,
    "occurredAt": 1715000000000,
    "subscriptionType": "contact.creation",
    "eventType": "contact.creation",
    "changeSource": "CRM",
    "attemptNumber": 0,
    "objectTypeId": "0-1"
  }
]
```

### 4.4 Merge Event Payload

Merge events include additional fields describing which records were involved:

```json
[
  {
    "objectId": 100,
    "primaryObjectId": 100,
    "mergedObjectIds": [200, 300],
    "newObjectId": 100,
    "numberOfPropertiesMoved": 14,
    "eventId": 11112222333,
    "subscriptionId": 60,
    "portalId": 33,
    "appId": 1160452,
    "occurredAt": 1715050000000,
    "subscriptionType": "contact.merge",
    "eventType": "contact.merge",
    "changeSource": "CRM",
    "attemptNumber": 0,
    "objectTypeId": "0-1"
  }
]
```

| Merge Field | Description |
|---|---|
| `primaryObjectId` | The ID of the winning (surviving) record after merge |
| `mergedObjectIds` | Array of IDs for records that were merged into the primary |
| `newObjectId` | The newly assigned ID (may equal `primaryObjectId`) |
| `numberOfPropertiesMoved` | Count of properties copied from merged records to primary |

### 4.5 Association Change Event Payload

```json
[
  {
    "objectId": 1246965,
    "associationType": "CONTACT_TO_COMPANY",
    "fromObjectId": 1246965,
    "toObjectId": 7654321,
    "associationRemoved": false,
    "isPrimaryAssociation": true,
    "eventId": 44445555666,
    "subscriptionId": 75,
    "portalId": 33,
    "appId": 1160452,
    "occurredAt": 1715100000000,
    "subscriptionType": "contact.associationChange",
    "eventType": "contact.associationChange",
    "changeSource": "API",
    "attemptNumber": 0,
    "fromObjectTypeId": "0-1",
    "toObjectTypeId": "0-2",
    "associationTypeId": 1,
    "associationCategory": "HUBSPOT_DEFINED"
  }
]
```

| Association Field | Description |
|---|---|
| `associationType` | Relationship type label (e.g., `CONTACT_TO_COMPANY`) |
| `fromObjectId` | ID of the record from which the association originates |
| `toObjectId` | ID of the associated record |
| `associationRemoved` | `true` if this is a removal event, `false` if a creation event |
| `isPrimaryAssociation` | `true` if this is the primary association between the two records |
| `fromObjectTypeId` | Object type ID of the `fromObject` (generic format) |
| `toObjectTypeId` | Object type ID of the `toObject` (generic format) |
| `associationTypeId` | Numeric ID for the association type |
| `associationCategory` | `HUBSPOT_DEFINED` or `USER_DEFINED` |

### 4.6 Conversation New Message Payload

```json
[
  {
    "objectId": 9876543,
    "messageId": "AAA-BBB-CCC-12345",
    "messageType": "MESSAGE",
    "eventId": 77778888999,
    "subscriptionId": 90,
    "portalId": 33,
    "appId": 1160452,
    "occurredAt": 1715200000000,
    "subscriptionType": "conversation.newMessage",
    "eventType": "conversation.newMessage",
    "changeSource": "CRM",
    "attemptNumber": 0
  }
]
```

| Conversation Field | Description |
|---|---|
| `messageId` | Unique identifier for the new message |
| `messageType` | `MESSAGE` (customer/agent message) or `COMMENT` (internal note) |

### 4.7 Important Payload Limitations for AI Agents

HubSpot webhook payloads are intentionally minimal — they contain **only event metadata**, not the full CRM record. This is by design to keep payloads small and delivery fast.

An AI agent receiving a `contact.propertyChange` event knows:
- Which contact changed (`objectId`)
- Which property changed (`propertyName`)
- What the new value is (`propertyValue`)
- When it changed (`occurredAt`)
- What caused it (`changeSource`)

The agent does **not** receive the full contact record. If the agent needs additional context (other properties, associated records, full deal details), it must make a follow-up API call:

```
GET https://api.hubapi.com/crm/v3/objects/contacts/{objectId}?properties=email,firstname,lastname,dealstage
Authorization: Bearer {private-app-token}
```

This follow-up API call counts against rate limits. Design your agent to fetch only the properties it needs and cache the results where appropriate.

---

## 5. Webhook Security and HMAC Validation

HubSpot provides three versions of webhook signature validation. All involve comparing a computed hash of request details against a signature in the request headers. The shared secret used for hashing is the **client secret** of your app.

### 5.1 Signature Header Reference

| Header | Present In | Purpose |
|---|---|---|
| `X-HubSpot-Signature` | All requests | SHA-256 hash (v1 or v2 method) |
| `X-HubSpot-Signature-Version` | All requests | States which version: `v1`, `v2` |
| `X-HubSpot-Signature-v3` | OAuth apps | HMAC SHA-256 Base64 hash (v3 method) |
| `X-HubSpot-Request-Timestamp` | OAuth apps | Millisecond timestamp for replay protection |

### 5.2 Signature Version Selection

| Version | Used When | Key Difference |
|---|---|---|
| v1 | CRM object events via Webhooks API | Hash = SHA-256(client_secret + request_body) |
| v2 | Workflow webhook actions, custom CRM cards | Hash = SHA-256(client_secret + method + URI + request_body) |
| v3 | OAuth apps (recommended) | HMAC SHA-256 with timestamp replay protection |

### 5.3 Validating v1 Signatures

Used when `X-HubSpot-Signature-Version: v1`.

**Algorithm:**
1. Concatenate the app's client secret with the raw request body string.
2. Compute SHA-256 hash of the combined string.
3. Compare the hex-encoded hash to the value in `X-HubSpot-Signature`.

**Python example:**
```python
import hashlib

def validate_v1_signature(client_secret: str, request_body: str, signature: str) -> bool:
    source_string = client_secret + request_body
    computed = hashlib.sha256(source_string.encode("utf-8")).hexdigest()
    return computed == signature
```

### 5.4 Validating v2 Signatures

Used when `X-HubSpot-Signature-Version: v2` (workflow webhook actions, CRM card requests).

**Algorithm:**
1. Concatenate: `client_secret + HTTP_METHOD + FULL_URI + request_body`
2. The URI must exactly match the original request URI, including protocol (`https://`) and any query parameters in their original order.
3. Compute SHA-256 hash.
4. Compare hex-encoded result to `X-HubSpot-Signature`.

**Python example:**
```python
import hashlib

def validate_v2_signature(
    client_secret: str,
    method: str,
    uri: str,
    body: str,
    signature: str
) -> bool:
    source_string = client_secret + method + uri + body
    computed = hashlib.sha256(source_string.encode("utf-8")).hexdigest()
    return computed == signature
```

**Common gotcha:** Middleware that modifies or normalizes the request body (trimming whitespace, re-encoding JSON) will break signature validation. Always validate against the raw, unmodified request body bytes.

### 5.5 Validating v3 Signatures (Recommended)

Version 3 is the most secure. It adds timestamp-based replay attack protection. Present on OAuth app requests alongside the older `X-HubSpot-Signature` header.

**Algorithm:**
1. Read `X-HubSpot-Request-Timestamp` from request headers.
2. **Reject** the request if the timestamp is older than **5 minutes** from the current time.
3. Decode specific URL-encoded characters in the URI: `%3A` → `:`, `%2F` → `/`, `%3F` → `?`, `%40` → `@`.
4. Concatenate: `HTTP_METHOD + REQUEST_URI + REQUEST_BODY + TIMESTAMP`
5. Compute HMAC SHA-256 of the resulting string using the client secret as the key.
6. Base64 encode the raw HMAC output.
7. Compare the result to the value in `X-HubSpot-Signature-v3` using **constant-time string comparison** to prevent timing attacks.

**Python example:**
```python
import hashlib
import hmac
import base64
import time

def validate_v3_signature(
    client_secret: str,
    method: str,
    uri: str,
    body: str,
    signature_v3: str,
    timestamp_ms: str,
    max_age_seconds: int = 300
) -> bool:
    # Step 1: Check timestamp age
    now_ms = int(time.time() * 1000)
    if abs(now_ms - int(timestamp_ms)) > max_age_seconds * 1000:
        return False

    # Step 2: Build source string
    source_string = method + uri + body + timestamp_ms
    source_bytes = source_string.encode("utf-8")

    # Step 3: Compute HMAC SHA-256
    secret_bytes = client_secret.encode("utf-8")
    raw_hmac = hmac.new(secret_bytes, source_bytes, hashlib.sha256).digest()

    # Step 4: Base64 encode
    computed_signature = base64.b64encode(raw_hmac).decode("utf-8")

    # Step 5: Constant-time comparison
    return hmac.compare_digest(computed_signature, signature_v3)
```

### 5.6 Security Best Practices

1. **Always validate signatures** on every inbound webhook request before processing the payload. Unauthenticated endpoints accepting webhook data are a security risk.
2. **Use v3 for new integrations** — the timestamp check prevents replay attacks where an attacker captures and re-replays a valid webhook request.
3. **Validate on the raw request body** before any parsing or transformation. Most web frameworks provide access to the raw bytes — use them.
4. **Rotate client secrets periodically** (recommended: every 6 months). After rotation, update the secret in your webhook handler immediately.
5. **Use constant-time comparison** (`hmac.compare_digest` in Python) when comparing signatures to prevent timing side-channel attacks.
6. **Return 200 within 5 seconds** regardless of processing state. Process the event asynchronously after acknowledging receipt.
7. **Reject requests missing required headers.** If `X-HubSpot-Signature` is absent, return 401 or simply discard the request.

---

## 6. Retry Logic and Delivery Guarantees

### 6.1 Retry Conditions

HubSpot will retry a webhook delivery if:

- **Connection failure** — HubSpot cannot open an HTTP connection to the webhook target URL.
- **Timeout** — The target endpoint does not respond within **5 seconds** of receiving the batch.
- **HTTP error codes** — The endpoint returns any 4xx or 5xx HTTP status code.

This means returning a `400 Bad Request` or `401 Unauthorized` will trigger retries, not stop them. The correct approach for handling invalid or unwanted events is to return `200 OK` and discard the event in your application logic.

### 6.2 Retry Schedule

HubSpot retries failed deliveries up to **10 times** spread over a **24-hour window**. The exact schedule uses randomized delays (derived from exponential backoff with jitter) to prevent thundering-herd scenarios where many concurrent failures retry at the same moment.

| Attempt | Approximate Delay |
|---|---|
| 0 (initial) | Immediate |
| 1 (retry 1) | ~1–2 minutes |
| 2 | ~5–10 minutes |
| 3 | ~15–30 minutes |
| 4–9 | Progressively longer, distributed across remaining 24h window |
| 10 (final) | ~20–24 hours after initial attempt |

After all 10 retries are exhausted, the event is **silently dropped** with no way to inspect, replay, or recover it. HubSpot provides no dead-letter queue or retry dashboard in the standard Webhooks API v3.

The `attemptNumber` field in the payload indicates which attempt this delivery is. A value of `0` means the first delivery attempt. A value of `3` means this is the third retry.

### 6.3 Delivery Guarantees

HubSpot's webhook system provides **at-least-once** delivery, not exactly-once.

**What this means in practice:**
- You may receive the same event multiple times. Though rare, it is explicitly acknowledged as possible in HubSpot's documentation.
- Events within a batch and across batches may arrive **out of chronological order**.
- You must use `occurredAt` to reconstruct event ordering, not the order in which HTTP requests arrive.

**Deduplication strategy for AI agents:**

Store a short-lived cache (24 hours is sufficient to cover the retry window) keyed on a composite identifier:

```python
# Idempotency key construction
idempotency_key = f"{event['portalId']}-{event['eventId']}-{event['attemptNumber']}"

# Check cache before processing
if redis_client.get(idempotency_key):
    return  # Already processed, skip

# Process event
process_event(event)

# Mark as processed with 25-hour TTL
redis_client.setex(idempotency_key, 90000, "1")
```

Note: `eventId` alone is not sufficient for deduplication since the same event may have the same `eventId` across multiple `attemptNumber` values. Using all three fields provides a unique key per delivery attempt.

### 6.4 Timeout Handling

The **5-second response timeout** is strict and cannot be configured. For AI agent systems that need to enrich events with follow-up API calls, run inference on event data, or persist to databases, 5 seconds is insufficient for inline processing.

**Correct architecture:**
1. HTTP handler receives the webhook batch.
2. Validate the HMAC signature (~1ms).
3. Parse the JSON array (~1ms).
4. Push each event to an internal queue (Redis, SQS, RabbitMQ, etc.) (~5–10ms per event).
5. Return `200 OK` within the timeout window.
6. Queue workers process events asynchronously at whatever pace is needed.

This pattern decouples inbound delivery from processing logic and is essential for any non-trivial AI agent integration.

---

## 7. Batching Behavior

### 7.1 Batch Size

HubSpot delivers events in batches of up to **100 events per HTTP request**. The actual batch size varies based on event volume. During low-traffic periods, you may receive single-event batches. During high-volume events (e.g., a large contact import), HubSpot will aggregate events into batches and send multiple rapid-fire requests, each containing up to 100 events.

This means your handler must always treat the payload as an array and iterate over all items — never assume a single-event payload.

### 7.2 Event Ordering Within a Batch

Events within a batch are not guaranteed to be in chronological order. Two `contact.propertyChange` events for the same contact might appear in either order within the same batch. Always sort by `occurredAt` before applying sequential logic.

### 7.3 Concurrency

HubSpot sends at most **10 concurrent in-flight requests** to your endpoint per account that installed your app. If you have 1,000 accounts using your integration and all generate events simultaneously, you may receive up to 10,000 concurrent requests.

Your endpoint must be designed to handle this concurrency. Consider:
- Horizontal scaling behind a load balancer.
- A stateless request handler that offloads to a queue.
- Rate-aware queue workers that respect HubSpot API limits when making follow-up calls.

### 7.4 Multiple Subscriptions in a Single Request

If a single CRM action triggers multiple subscriptions (e.g., creating a contact triggers both `contact.creation` and if a property is set, a `contact.propertyChange`), HubSpot may send these as separate events within the same batch or in separate requests. Do not rely on related events always being co-batched.

---

## 8. Filtering Webhooks by Property

For `propertyChange` subscription types, you can subscribe to changes on a specific property rather than all property changes on an object.

**When creating a `propertyChange` subscription**, supply the `propertyName` field with the internal API name of the property you want to watch.

**Example — subscribe to deal stage changes only:**
```json
{
  "eventType": "deal.propertyChange",
  "propertyName": "dealstage",
  "active": true
}
```

**Example — subscribe to contact lifecycle stage changes:**
```json
{
  "eventType": "contact.propertyChange",
  "propertyName": "lifecyclestage",
  "active": true
}
```

**Properties that cannot be subscribed to:**
- `num_unique_conversion_events`
- `hs_lastmodifieddate`

These are excluded from property change subscriptions because they change too frequently and would generate excessive event volume.

For COMMUNICATION objects, `hs_communication_body` cannot be subscribed to. For EMAIL objects, `hs_email_html` and `hs_email_subject` cannot be subscribed to.

**Using `changeSource` to filter in your handler:**
Even after subscribing to a specific property, you may receive changes triggered by multiple sources. Use the `changeSource` field to filter out changes that originated from your own integration to avoid feedback loops:

```python
EXCLUDED_SOURCES = {"MY_INTEGRATION_NAME", "WORKFLOW"}

def should_process_event(event: dict) -> bool:
    return event.get("changeSource") not in EXCLUDED_SOURCES
```

---

## 9. Testing Webhooks

### 9.1 Using Webhook.site for Development

During development before your endpoint is publicly accessible, use [https://webhook.site](https://webhook.site) to capture and inspect incoming webhook payloads. Create a temporary URL, set it as your webhook target, trigger events in HubSpot, and inspect the raw JSON payload.

**Important:** Never configure webhook.site or similar public inspection services with a HubSpot account that contains real customer data.

### 9.2 Local Development with Tunnels

For local development with real webhook delivery to `localhost`:

1. Use a tunneling service: **ngrok**, **Tunnelmole**, or **Cloudflare Tunnel**.
2. Start your local webhook server (e.g., on port 8000).
3. Start the tunnel: `ngrok http 8000` → copies a public HTTPS URL.
4. Set the public tunnel URL as your HubSpot webhook target URL.
5. Trigger events in HubSpot (create a contact, update a deal, etc.).
6. Observe the request arriving at your local server.

**Express.js (Node.js) minimal webhook handler:**
```javascript
const express = require("express");
const crypto = require("crypto");
const app = express();

app.use(express.raw({ type: "application/json" }));

app.post("/webhooks", (req, res) => {
  const signature = req.headers["x-hubspot-signature"];
  const body = req.body.toString("utf8");
  const sourceString = process.env.HUBSPOT_CLIENT_SECRET + body;
  const computed = crypto.createHash("sha256").update(sourceString).digest("hex");

  if (computed !== signature) {
    return res.status(401).send("Invalid signature");
  }

  const events = JSON.parse(body);
  // Acknowledge immediately
  res.status(200).send("OK");

  // Process asynchronously
  events.forEach(event => processEventAsync(event));
});

app.listen(8000);
```

### 9.3 Using HubSpot's Built-in Test Function

Both private and public app webhook configurations provide a **Send test notification** button in the HubSpot developer dashboard. This triggers a sample event payload to your configured webhook URL, allowing you to verify that your endpoint is reachable and your signature validation is working correctly.

---

## 10. Webhooks Journal API (Beta v4)

HubSpot introduced a redesigned webhook system in the developer platform that addresses limitations of the v3 API.

**Key improvements:**
- **Lightweight notifications** — Instead of sending full event payloads, the new system sends a lightweight notification. You then query the **Webhooks Journal API** to retrieve full event details on demand.
- **Historical event retrieval** — Query past events within the Journal without needing to have received the original webhook.
- **CRM snapshots** — Retrieve the state of a CRM object at a specific point in time.
- **Granular subscriptions** — Subscribe per-portal, per-object, and per-property.
- **Custom and app object support** — Subscribe to events on custom objects, not just standard ones.

**Base path:** `https://api.hubapi.com/webhooks/v4/`

The v4 Webhooks Journal API is in **public beta** as of 2024–2025. Evaluate it for new integrations but verify beta stability before committing to production use.

---

## 11. Rate Limits Overview

HubSpot enforces two independent categories of rate limits:

1. **Burst (secondary) limits** — Maximum number of API calls within a rolling 10-second window. Prevents spike traffic from degrading service for other users.
2. **Daily limits** — Maximum total API calls per 24-hour period. Resets at midnight in the account's configured timezone.

Both limits are enforced simultaneously. Exceeding either one results in a `429 Too Many Requests` response for all subsequent calls until the limit window resets.

**Limits apply per account, not per endpoint.** All API calls made to any HubSpot endpoint by any integration authorized on an account consume from the same quota pool (with a few exempted endpoints).

**Exempted endpoints** (do not count toward daily or burst limits):
- Certain Marketing Single Send API calls
- Source Code API endpoints

These exempted endpoints will not appear in the HubSpot API usage dashboard.

**Important for AI agents:** Webhook POST requests that HubSpot sends to your endpoint do not count against your API rate limit. Only calls your integration makes *to* the HubSpot API consume quota.

---

## 12. Rate Limits by Plan Tier

### 12.1 Privately Distributed Apps (Private Apps and Restricted OAuth Apps)

| Plan Tier | Burst Limit (per 10 sec, per app) | Daily Limit (per account, across all apps) |
|---|---|---|
| Free | 100 requests | 250,000 requests |
| Starter | 100 requests | 250,000 requests |
| Professional | 190 requests | 625,000 requests |
| Enterprise | 190 requests | 1,000,000 requests |

**API Limit Increase Capacity Pack (add-on):**

| Pack | Additional Daily Calls | Burst Limit |
|---|---|---|
| 1x Capacity Pack | +1,000,000/day | 250 requests/10 sec |
| 2x Capacity Pack | +2,000,000/day | 250 requests/10 sec (does not stack above 250) |

The capacity pack daily limit stacks on top of the base plan. An Enterprise account with one capacity pack has `1,000,000 + 1,000,000 = 2,000,000` daily calls. With two packs: `1,000,000 + 2,000,000 = 3,000,000`.

The burst limit increase from the capacity pack (100 → 250) does **not** stack — two packs still gives 250, not 300.

### 12.2 Publicly Distributed OAuth Apps

| Metric | Limit |
|---|---|
| Burst limit | 110 requests per 10 seconds per HubSpot account |
| Daily limit | Not separately enumerated for OAuth apps; account's plan limit applies |

Public apps (those distributed through HubSpot Marketplace or via OAuth install flow) are limited to 110 requests per 10-second window **per connected HubSpot account**, regardless of the account's plan tier. The API Limit Increase capacity pack does not apply to publicly distributed apps.

### 12.3 CRM Search API Limits

The Search API (`/crm/v3/objects/{objectType}/search`) has a stricter burst limit:

| Metric | Limit |
|---|---|
| Burst limit | 5 requests per second (increased from 4 in 2024) |

This limit is enforced separately from the general burst limit. An agent that frequently searches HubSpot should implement dedicated throttling for search calls.

### 12.4 CRM Associations API

Due to an ongoing known issue (as of the latest available documentation), the CRM Associations API remains at its previous burst rate limits rather than the updated limits for other endpoints. Check the HubSpot developer changelog for current status.

### 12.5 Marketplace Certification Requirement

Apps listed on the HubSpot Marketplace must maintain an error rate below **5% of total daily requests**. This means: if your app makes 100,000 API calls in a day, no more than 5,000 of them can result in error responses. Consistently hitting rate limits (429s) will count against this threshold and may prevent marketplace certification.

---

## 13. Private App vs. OAuth App Limits

Understanding the difference between app types is essential for planning rate limit strategy.

| Characteristic | Private App | OAuth App (Public) |
|---|---|---|
| Distribution | Single HubSpot account only | Any HubSpot account via install flow |
| Burst limit | 100–190/10 sec (plan-dependent, per app) | 110/10 sec (per connected account) |
| Daily limit | Account plan's daily limit (shared across all apps on account) | Account plan's daily limit |
| Capacity pack eligible | Yes | No |
| Webhook setup | UI only (or developer projects JSON) | UI and Webhooks API |
| Rate limit headers | `X-HubSpot-RateLimit-Daily-Remaining` included | Headers **not** included for OAuth-authorized requests |

**Key implication for AI agents:** If your AI agent system uses OAuth to access multiple customer HubSpot accounts, each connected account has its own rate limit envelope. The burst limit of 110/10 sec is per-account. A single agent managing 100 customer accounts could theoretically make 11,000 requests per 10 seconds (110 × 100) — but must enforce per-account throttling to stay within the per-account limit.

If your agent operates on a single HubSpot account (internal tool), a private app is the correct choice and gives access to higher limits and the capacity pack.

---

## 14. Rate Limit Response Headers

Every API response from HubSpot includes rate limit headers (with exceptions noted below).

### 14.1 Current Headers

| Header | Type | Description |
|---|---|---|
| `X-HubSpot-RateLimit-Max` | integer | The maximum number of requests allowed in the current interval |
| `X-HubSpot-RateLimit-Remaining` | integer | Requests remaining in the current interval window |
| `X-HubSpot-RateLimit-Interval-Milliseconds` | integer | The length of the rolling window in milliseconds (10000 = 10 seconds) |
| `X-HubSpot-RateLimit-Daily-Remaining` | integer | Remaining daily API calls for the account |

### 14.2 Deprecated Headers (Still Present, No Longer Enforced)

| Header | Status |
|---|---|
| `X-HubSpot-RateLimit-Secondly` | Deprecated — still present, not enforced |
| `X-HubSpot-RateLimit-Secondly-Remaining` | Deprecated — still present, not enforced |

These per-second headers were deprecated when HubSpot moved to a 10-second rolling window model. Do not build throttling logic around them.

### 14.3 OAuth Exception

For API requests authorized via OAuth tokens, the `X-HubSpot-RateLimit-Daily` and `X-HubSpot-RateLimit-Daily-Remaining` headers are **not included** in responses. Implement an internal call counter to track daily usage for OAuth-authenticated agents.

### 14.4 Reading Headers for Proactive Throttling

Proactively reading rate limit headers allows your agent to slow down before receiving a 429, rather than reacting after the fact.

**Python example using requests:**
```python
import requests
import time

class HubSpotClient:
    def __init__(self, token: str):
        self.token = token
        self.session = requests.Session()
        self.session.headers.update({"Authorization": f"Bearer {token}"})

    def get(self, url: str, **kwargs) -> requests.Response:
        response = self.session.get(url, **kwargs)
        self._check_rate_limit(response)
        return response

    def _check_rate_limit(self, response: requests.Response):
        remaining = int(response.headers.get("X-HubSpot-RateLimit-Remaining", 999))
        interval_ms = int(response.headers.get("X-HubSpot-RateLimit-Interval-Milliseconds", 10000))

        # If fewer than 10 requests remain in the window, pause until window resets
        if remaining < 10:
            pause_seconds = interval_ms / 1000
            time.sleep(pause_seconds)
```

---

## 15. 429 Error Response Structure

When either the burst or daily limit is exceeded, HubSpot returns an HTTP `429 Too Many Requests` response with a JSON body.

### 15.1 Burst Limit Exceeded (10-second window)

```json
{
  "status": "error",
  "message": "You have exceeded your secondly limit.",
  "errorType": "RATE_LIMIT",
  "correlationId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "policyName": "TEN_SECONDLY_ROLLING",
  "requestId": "f9e8d7c6-b5a4-3210-fedc-ba9876543210"
}
```

### 15.2 Daily Limit Exceeded

```json
{
  "status": "error",
  "message": "You have reached your daily limit.",
  "errorType": "RATE_LIMIT",
  "correlationId": "c033cdaa-2c40-4a64-ae48-b4cec88dad24",
  "policyName": "DAILY",
  "requestId": "3d3e35b7-0dae-4b9f-a6e3-9c230cbcf8dd"
}
```

### 15.3 Response Body Fields

| Field | Description |
|---|---|
| `status` | Always `"error"` for rate limit responses |
| `message` | Human-readable description of which limit was hit |
| `errorType` | Always `"RATE_LIMIT"` |
| `correlationId` | HubSpot-generated ID for debugging — include when contacting support |
| `policyName` | `"DAILY"` or `"TEN_SECONDLY_ROLLING"` — identifies which limit was hit |
| `requestId` | Unique identifier for this specific request attempt |

### 15.4 Distinguishing Burst vs. Daily Limit Hits

Check the `policyName` field:
- `"TEN_SECONDLY_ROLLING"` → Burst limit hit. Wait for the 10-second window to reset (typically 10 seconds or less). Honor the `Retry-After` header if present.
- `"DAILY"` → Daily limit hit. Do not retry until midnight in the account's timezone. Implement graceful degradation — queue requests for the next day or prioritize the most critical operations.

### 15.5 5xx Errors Under High Load

Under extremely high request volume, HubSpot may return `500`, `502`, `503`, or `504` errors before issuing explicit 429s. These transient server errors should be treated the same way as 429s — implement exponential backoff and retry.

---

## 16. Retry-After and Exponential Backoff

### 16.1 Retry-After Header

HubSpot includes a `Retry-After` header on 429 responses indicating how many seconds to wait before retrying. Always read and honor this header. Ignoring it and retrying immediately will result in continued 429s and waste your daily quota.

```python
import time

def handle_429(response: requests.Response):
    retry_after = int(response.headers.get("Retry-After", 10))
    time.sleep(retry_after)
```

### 16.2 Exponential Backoff with Jitter

For transient errors (429, 500, 502, 503, 504), implement exponential backoff with jitter to avoid thundering herd problems when multiple concurrent agent processes retry simultaneously.

**Full implementation with tenacity (production-ready):**

```python
from tenacity import (
    retry,
    stop_after_attempt,
    wait_exponential,
    retry_if_exception_type,
    before_sleep_log,
)
import requests
import logging

logger = logging.getLogger(__name__)

class RateLimitError(Exception):
    pass

class TransientError(Exception):
    pass

def _classify_error(response: requests.Response):
    if response.status_code == 429:
        raise RateLimitError(f"Rate limit hit: {response.json().get('policyName')}")
    if response.status_code >= 500:
        raise TransientError(f"Server error: {response.status_code}")

@retry(
    stop=stop_after_attempt(6),
    wait=wait_exponential(multiplier=1, min=1, max=60),
    retry=retry_if_exception_type((RateLimitError, TransientError)),
    before_sleep=before_sleep_log(logger, logging.WARNING),
)
def hubspot_api_call(url: str, token: str, **kwargs) -> dict:
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(url, headers=headers, timeout=30, **kwargs)
    _classify_error(response)
    response.raise_for_status()
    return response.json()
```

**Manual implementation with jitter:**

```python
import time
import random
import requests

def hubspot_get_with_backoff(
    url: str,
    token: str,
    max_retries: int = 6,
    base_delay: float = 1.0,
    max_delay: float = 60.0,
) -> dict:
    headers = {"Authorization": f"Bearer {token}"}

    for attempt in range(max_retries):
        response = requests.get(url, headers=headers, timeout=30)

        if response.status_code == 200:
            return response.json()

        if response.status_code == 429:
            # Honor Retry-After if present
            retry_after = float(response.headers.get("Retry-After", 0))
            if retry_after > 0:
                time.sleep(retry_after)
                continue

        if response.status_code in (429, 500, 502, 503, 504):
            # Exponential backoff with full jitter
            delay = min(base_delay * (2 ** attempt), max_delay)
            jitter = random.uniform(0, delay)
            time.sleep(jitter)
            continue

        # Non-retryable error
        response.raise_for_status()

    raise Exception(f"Failed after {max_retries} attempts: {url}")
```

### 16.3 Token Bucket Pattern for AI Agent Systems

For multi-threaded or multi-process AI agent systems making concurrent API calls, a shared token bucket prevents coordinated rate limit spikes.

```python
import threading
import time

class HubSpotTokenBucket:
    """
    Token bucket throttle for HubSpot API calls.
    Default: 190 tokens per 10 seconds (Professional/Enterprise private app).
    """
    def __init__(self, rate: int = 190, per_seconds: float = 10.0):
        self.rate = rate
        self.per_seconds = per_seconds
        self.tokens = rate
        self.last_refill = time.monotonic()
        self._lock = threading.Lock()

    def _refill(self):
        now = time.monotonic()
        elapsed = now - self.last_refill
        new_tokens = elapsed * (self.rate / self.per_seconds)
        self.tokens = min(self.rate, self.tokens + new_tokens)
        self.last_refill = now

    def acquire(self, count: int = 1) -> float:
        """Acquire tokens, returning the wait time if throttled."""
        with self._lock:
            self._refill()
            if self.tokens >= count:
                self.tokens -= count
                return 0.0
            wait_time = (count - self.tokens) / (self.rate / self.per_seconds)
            return wait_time

    def wait_and_acquire(self, count: int = 1):
        wait = self.acquire(count)
        if wait > 0:
            time.sleep(wait)
```

**Usage:**
```python
throttle = HubSpotTokenBucket(rate=190, per_seconds=10.0)

def fetch_contact(contact_id: str, token: str) -> dict:
    throttle.wait_and_acquire()
    return hubspot_get_with_backoff(
        f"https://api.hubapi.com/crm/v3/objects/contacts/{contact_id}",
        token=token,
    )
```

---

## 17. Batch API for Rate Limit Management

HubSpot provides batch endpoints for most CRM operations. Using these dramatically reduces API call volume compared to individual record operations.

### 17.1 Batch Read

Instead of fetching 100 contacts with 100 individual GET requests (100 API calls), use the batch read endpoint (1 API call):

```
POST https://api.hubapi.com/crm/v3/objects/contacts/batch/read
Authorization: Bearer {token}
Content-Type: application/json

{
  "properties": ["email", "firstname", "lastname", "lifecyclestage"],
  "inputs": [
    {"id": "1001"},
    {"id": "1002"},
    {"id": "1003"}
  ]
}
```

Maximum 100 records per batch read request.

### 17.2 Batch Create

```
POST https://api.hubapi.com/crm/v3/objects/contacts/batch/create
Authorization: Bearer {token}
Content-Type: application/json

{
  "inputs": [
    {
      "properties": {
        "email": "contact1@example.com",
        "firstname": "Alice",
        "lifecyclestage": "lead"
      }
    },
    {
      "properties": {
        "email": "contact2@example.com",
        "firstname": "Bob",
        "lifecyclestage": "lead"
      }
    }
  ]
}
```

### 17.3 Batch Update

```
POST https://api.hubapi.com/crm/v3/objects/contacts/batch/update
Authorization: Bearer {token}
Content-Type: application/json

{
  "inputs": [
    {
      "id": "1001",
      "properties": {"lifecyclestage": "customer"}
    },
    {
      "id": "1002",
      "properties": {"lifecyclestage": "customer"}
    }
  ]
}
```

Up to 100 records per batch update call. Identification can be by `id` (HubSpot record ID), or for contacts, by `email`.

### 17.4 Rate Limit Savings with Batch API

| Operation | Individual Calls | Batch Calls | Savings |
|---|---|---|---|
| Read 100 contacts | 100 calls | 1 call | 99% |
| Update 100 contacts | 100 calls | 1 call | 99% |
| Create 50 contacts | 50 calls | 1 call | 98% |
| Update 500 deals | 500 calls | 5 calls (100/batch) | 99% |

For AI agents performing bulk enrichment, sync operations, or scheduled data processing, switching from individual to batch endpoints is the single highest-impact optimization available.

### 17.5 Batch API Response Structure

Batch responses include per-record results and may include partial failures:

```json
{
  "status": "COMPLETE",
  "results": [
    {
      "id": "1001",
      "properties": { "email": "contact1@example.com", ... },
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-06-01T12:00:00.000Z"
    }
  ],
  "errors": [],
  "numErrors": 0,
  "requestedAt": "2024-06-01T12:00:01.000Z",
  "completedAt": "2024-06-01T12:00:01.050Z"
}
```

If some records fail within a batch, the `status` will be `"ERRORS"` and the `errors` array will contain per-record error details. Your agent must handle partial batch failures gracefully.

---

## 18. Caching Strategies

Caching reduces API calls by storing previously fetched data locally and serving it from cache instead of re-querying HubSpot.

### 18.1 What to Cache

| Data Type | Recommended TTL | Notes |
|---|---|---|
| Contact properties list | 24 hours | Properties rarely change |
| Company properties list | 24 hours | |
| Deal pipeline stages | 1 hour | Stages change infrequently |
| Owner list (user IDs) | 1 hour | New users added rarely |
| Form configurations | 6 hours | |
| Individual contact/deal records | 5–15 minutes | Depends on event volume |
| Search results | 1–5 minutes | High-churn data |

### 18.2 Cache-Aside Pattern

For AI agents that react to webhook events and need full record context:

```python
import json
import redis

cache = redis.Redis(host="localhost", port=6379, db=0)
CONTACT_CACHE_TTL = 300  # 5 minutes

def get_contact(contact_id: str, token: str) -> dict:
    cache_key = f"hs:contact:{contact_id}"
    cached = cache.get(cache_key)

    if cached:
        return json.loads(cached)

    # Cache miss — fetch from HubSpot
    response = hubspot_get_with_backoff(
        f"https://api.hubapi.com/crm/v3/objects/contacts/{contact_id}"
        f"?properties=email,firstname,lastname,lifecyclestage,hs_lead_status",
        token=token,
    )

    # Cache with TTL
    cache.setex(cache_key, CONTACT_CACHE_TTL, json.dumps(response))
    return response
```

### 18.3 Cache Invalidation via Webhooks

Webhooks and caching work well together. Use webhook events to **invalidate** cached records when they change, rather than relying purely on TTL expiry:

```python
def process_property_change_event(event: dict):
    contact_id = str(event["objectId"])
    cache_key = f"hs:contact:{contact_id}"

    # Invalidate stale cache
    cache.delete(cache_key)

    # Optionally pre-warm the cache with the new value
    # (only if this property is the one we cache)
    if event.get("propertyName") == "lifecyclestage":
        # Will be re-fetched on next access
        pass
```

This pattern ensures cached data is never more than one event old, while dramatically reducing redundant API calls.

---

## 19. AI Agent Integration Architecture

### 19.1 Recommended Architecture for Webhook-Driven AI Agents

```
HubSpot CRM
    |
    | (webhook POST, up to 100 events, 10 concurrent)
    v
Webhook Receiver (FastAPI / Express / Lambda)
  - HMAC signature validation (v3 preferred)
  - 200 OK response within 5 seconds
  - Push events to message queue
    |
    v
Message Queue (Redis Streams / SQS / RabbitMQ)
  - At-least-once delivery
  - Dead-letter queue for failed processing
    |
    v
Event Processor Workers (N workers)
  - Deduplication (check idempotency key store)
  - Sort events by occurredAt
  - Enrich via HubSpot API (token bucket throttle)
  - Cache enriched data
    |
    v
AI Agent Logic
  - LLM reasoning over enriched event context
  - CRM write-back (batch API, throttled)
  - External integrations (email, Slack, calendar)
```

### 19.2 Multi-Account Agent Rate Limit Management

For agents managing multiple HubSpot accounts:

```python
from typing import Dict

class MultiAccountHubSpotAgent:
    """
    Manages per-account rate limit buckets for a multi-tenant agent.
    Each connected account gets its own token bucket at the OAuth app limit (110/10s).
    """
    def __init__(self):
        self._buckets: Dict[str, HubSpotTokenBucket] = {}

    def _get_bucket(self, portal_id: str) -> HubSpotTokenBucket:
        if portal_id not in self._buckets:
            # 110 requests per 10 seconds for public OAuth apps
            self._buckets[portal_id] = HubSpotTokenBucket(rate=110, per_seconds=10.0)
        return self._buckets[portal_id]

    def api_call(self, portal_id: str, url: str, token: str) -> dict:
        bucket = self._get_bucket(portal_id)
        bucket.wait_and_acquire()
        return hubspot_get_with_backoff(url, token=token)
```

### 19.3 Webhook-to-Action Pipeline for AI Agents

A concrete pattern for an AI agent that takes action based on HubSpot webhook events:

1. **Event arrives:** `deal.propertyChange` — `dealstage` changed to `closedwon`.
2. **Signature validated:** HMAC v3 check passes.
3. **Queued:** Event pushed to processing queue.
4. **Deduplication:** Check `portalId-eventId-attemptNumber` — not seen before.
5. **Enrichment:** Fetch full deal record (batch API if multiple deals changed). Fetch associated contact (batch read). Check cache first.
6. **AI reasoning:** LLM evaluates deal context — determines appropriate next action (send congratulations email, create onboarding task, notify Slack).
7. **Write-back:** Update HubSpot deal with `hs_pipeline_stage` = `onboarding`. Create task via batch create endpoint. Set `changeSource` awareness to avoid webhook feedback loop.
8. **Log result:** Write processing outcome to internal log for audit trail.

---

## 20. Quick Reference Tables

### 20.1 Webhook Subscription Types — Complete Catalog

| Subscription Type | Object(s) | Notes |
|---|---|---|
| `contact.creation` | Contact | |
| `contact.deletion` | Contact | |
| `contact.propertyChange` | Contact | Requires `propertyName` |
| `contact.associationChange` | Contact | |
| `contact.restore` | Contact | |
| `contact.merge` | Contact | |
| `contact.privacyDeletion` | Contact | GDPR deletion |
| `company.creation` | Company | |
| `company.deletion` | Company | |
| `company.propertyChange` | Company | Requires `propertyName` |
| `company.associationChange` | Company | |
| `company.restore` | Company | |
| `company.merge` | Company | |
| `deal.creation` | Deal | |
| `deal.deletion` | Deal | |
| `deal.propertyChange` | Deal | Requires `propertyName` |
| `deal.associationChange` | Deal | |
| `deal.restore` | Deal | |
| `deal.merge` | Deal | |
| `ticket.creation` | Ticket | |
| `ticket.deletion` | Ticket | |
| `ticket.propertyChange` | Ticket | Requires `propertyName` |
| `ticket.associationChange` | Ticket | |
| `ticket.restore` | Ticket | |
| `ticket.merge` | Ticket | |
| `product.creation` | Product | |
| `product.deletion` | Product | |
| `product.propertyChange` | Product | Requires `propertyName` |
| `product.restore` | Product | |
| `product.merge` | Product | |
| `line_item.creation` | Line Item | |
| `line_item.deletion` | Line Item | |
| `line_item.propertyChange` | Line Item | Requires `propertyName` |
| `line_item.associationChange` | Line Item | |
| `line_item.restore` | Line Item | |
| `line_item.merge` | Line Item | |
| `conversation.creation` | Conversation | Beta |
| `conversation.deletion` | Conversation | Beta |
| `conversation.privacyDeletion` | Conversation | Beta |
| `conversation.propertyChange` | Conversation | Beta, specific properties only |
| `conversation.newMessage` | Conversation | Beta |
| `object.*` (generic) | 24+ object types | Use `objectTypeId` in payload to identify object |

### 20.2 Rate Limits Summary

| App Type | Plan | Burst (per 10 sec) | Daily |
|---|---|---|---|
| Private / Restricted OAuth | Free / Starter | 100 | 250,000 |
| Private / Restricted OAuth | Professional | 190 | 625,000 |
| Private / Restricted OAuth | Enterprise | 190 | 1,000,000 |
| Private + 1x Capacity Pack | Any | 250 | +1,000,000 |
| Private + 2x Capacity Pack | Any | 250 | +2,000,000 |
| Public OAuth App | Any | 110 | Plan limit |
| CRM Search API | Any | 5/sec | Shared |

### 20.3 Webhook Headers Reference

| Header (Inbound on Your Endpoint) | Purpose |
|---|---|
| `X-HubSpot-Signature` | SHA-256 hash for v1/v2 validation |
| `X-HubSpot-Signature-Version` | Which signature version: `v1` or `v2` |
| `X-HubSpot-Signature-v3` | HMAC SHA-256 Base64 for v3 validation |
| `X-HubSpot-Request-Timestamp` | Millisecond timestamp for v3 replay protection |

### 20.4 Rate Limit Response Headers

| Header (On HubSpot API Responses) | Purpose |
|---|---|
| `X-HubSpot-RateLimit-Max` | Max requests allowed in current window |
| `X-HubSpot-RateLimit-Remaining` | Requests remaining in current window |
| `X-HubSpot-RateLimit-Interval-Milliseconds` | Window size in ms (10000 = 10 sec) |
| `X-HubSpot-RateLimit-Daily-Remaining` | Daily calls remaining (not present for OAuth) |
| `Retry-After` | Seconds to wait after a 429 |
| `X-HubSpot-RateLimit-Secondly` | Deprecated — present but not enforced |
| `X-HubSpot-RateLimit-Secondly-Remaining` | Deprecated — present but not enforced |

### 20.5 Webhook Delivery Characteristics

| Property | Value |
|---|---|
| Delivery model | At-least-once |
| Max retries | 10 |
| Retry window | 24 hours |
| Max events per request | 100 |
| Max concurrent requests (per account) | 10 |
| Response timeout | 5 seconds |
| Event ordering | Not guaranteed |
| Duplicate delivery | Possible (use idempotency keys) |
| Max subscriptions per app | 1,000 |
| Settings propagation delay | Up to 5 minutes |

---

*Sources: [HubSpot Webhooks API Guide](https://developers.hubspot.com/docs/api-reference/webhooks-webhooks-v3/guide) · [HubSpot API Usage Guidelines](https://developers.hubspot.com/docs/developer-tooling/platform/usage-guidelines) · [HubSpot Validating Requests](https://developers.hubspot.com/docs/guides/apps/authentication/validating-requests) · [HubSpot Private Apps Webhooks](https://developers.hubspot.com/docs/guides/crm/private-apps/webhooks) · [Generic Webhook Subscriptions Beta](https://developers.hubspot.com/changelog/public-beta-generic-webhook-subscriptions) · [Webhook Signature v3](https://developers.hubspot.com/changelog/introducing-version-3-of-webhook-signatures) · [HubSpot Developer Changelog](https://developers.hubspot.com/changelog) · [Hookdeck HubSpot Guide](https://hookdeck.com/webhooks/platforms/guide-to-hubspot-webhooks-features-and-best-practices)*
