# HubSpot CRM API — Authentication & Core Objects
## Technical Reference for AI Agent Integration

**Source:** HubSpot Developer Documentation (developers.hubspot.com)
**Date Saved:** 2026-03-18
**API Version:** v3 (CRM objects), v4 (Associations), v1 (OAuth tokens)
**Base URL:** `https://api.hubspot.com`

---

## Table of Contents

1. [Authentication Overview](#1-authentication-overview)
2. [Private Apps (Recommended)](#2-private-apps-recommended)
3. [OAuth 2.0 Flow](#3-oauth-20-flow)
4. [Deprecated API Keys](#4-deprecated-api-keys)
5. [Scopes Reference](#5-scopes-reference)
6. [Token Storage and Refresh for Automated Systems](#6-token-storage-and-refresh-for-automated-systems)
7. [Rate Limits](#7-rate-limits)
8. [Error Handling](#8-error-handling)
9. [CRM Architecture Overview](#9-crm-architecture-overview)
10. [Contacts API](#10-contacts-api)
11. [Companies API](#11-companies-api)
12. [Deals API](#12-deals-api)
13. [Tickets API](#13-tickets-api)
14. [Associations API v4](#14-associations-api-v4)
15. [CRM Search API](#15-crm-search-api)
16. [Properties API](#16-properties-api)
17. [Pipelines API](#17-pipelines-api)
18. [Best Practices for AI Agents](#18-best-practices-for-ai-agents)

---

## 1. Authentication Overview

HubSpot supports three authentication methods for its APIs, with varying levels of recommendation for different use cases:

| Method | Status | Best For |
|--------|--------|----------|
| Private Apps (access tokens) | Recommended | Internal tools, automation, AI agents |
| OAuth 2.0 | Recommended | Third-party apps, multi-account apps |
| API Keys (hapikey) | Deprecated | Legacy only, do not use for new builds |

All API requests must include authentication. The method depends on the integration type. For AI agents operating on a single HubSpot account, **Private Apps** are the correct approach. For multi-tenant SaaS products that connect to customers' HubSpot accounts, **OAuth 2.0** is required.

The HubSpot API base URL is:
```
https://api.hubspot.com
```

All CRM v3 endpoints follow the pattern:
```
https://api.hubspot.com/crm/v3/objects/{objectType}
```

---

## 2. Private Apps (Recommended)

### What Private Apps Are

Private Apps replace the deprecated API key system. A Private App is a HubSpot application scoped to a single portal (account). It generates a long-lived access token that grants the specific CRM permissions (scopes) you configure. This token is stable — it does not expire on a time schedule the way OAuth access tokens do — though it can be rotated.

For AI agent integration, Private Apps are ideal because:
- No OAuth handshake required
- Token is stable and long-lived
- Scopes are defined at creation time
- Token can be stored in environment variables
- No user interaction needed at runtime

### How to Create a Private App

1. Log into HubSpot. Only **super admins** can create Private Apps.
2. Navigate to: **Settings > Integrations > Private Apps**
3. Click **Create private app**
4. On the **Basic Info** tab: provide a name, optional logo, and description
5. On the **Scopes** tab: select all required scopes for your use case (see Section 5)
6. Click **Create app**
7. On the **Auth** tab: click **Show token** to copy your access token

### Token Format

Private App tokens begin with `pat-` followed by a region identifier and a random string:

```
pat-na1-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

The token length can vary. HubSpot states: "HubSpot access tokens are expected to fluctuate in size over time" and implementations should accommodate up to **512 characters**.

### Using the Token in API Calls

Pass the token as a Bearer token in the `Authorization` HTTP header:

```http
Authorization: Bearer pat-na1-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Content-Type: application/json
```

Example cURL request:
```bash
curl -X GET "https://api.hubspot.com/crm/v3/objects/contacts" \
  -H "Authorization: Bearer pat-na1-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" \
  -H "Content-Type: application/json"
```

Example Python request:
```python
import requests

HUBSPOT_TOKEN = "pat-na1-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

headers = {
    "Authorization": f"Bearer {HUBSPOT_TOKEN}",
    "Content-Type": "application/json"
}

response = requests.get(
    "https://api.hubspot.com/crm/v3/objects/contacts",
    headers=headers
)
```

### Token Rotation

If a token is lost or compromised, it must be rotated:
1. Navigate to the Private App in HubSpot settings
2. Select **Rotate token**
3. Choose immediate rotation or 7-day scheduled rotation (to allow existing integrations to update)
4. Super admins receive email notifications throughout the rotation lifecycle

HubSpot recommends rotating tokens every six months as a security best practice.

### Scope Modification

Scopes can be added or removed after app creation. If you need to add capabilities later, return to the **Scopes** tab in the app settings and update the selection.

### Rate Limits for Private Apps

Private App API calls count toward per-account daily limits:

| HubSpot Tier | Per 10 Seconds (per app) | Daily Account Limit |
|--------------|--------------------------|---------------------|
| Free / Starter | 100 requests | 250,000 |
| Professional | 190 requests | 625,000 |
| Enterprise | 190 requests | 1,000,000 |
| With API Limit Increase add-on | 200 requests | 1,000,000 |

Check current usage via:
```
GET /account-info/v3/api-usage/daily/private-apps
```

---

## 3. OAuth 2.0 Flow

### When to Use OAuth

OAuth 2.0 is required when your integration needs to connect to **multiple HubSpot accounts** (e.g., a SaaS product used by multiple customers). It is also appropriate when you need users to explicitly authorize your app's access to their HubSpot data.

### OAuth Flow Overview

The flow has three steps:

1. **Authorization Request**: Redirect user to HubSpot's authorization URL
2. **Token Exchange**: Exchange the authorization code for an access token + refresh token
3. **Token Refresh**: Use the refresh token to obtain new access tokens when they expire

### Step 1: Authorization Request

Redirect the user to:
```
https://app.hubspot.com/oauth/authorize
  ?client_id={your_client_id}
  &redirect_uri={your_redirect_uri}
  &scope={space_separated_scopes}
```

Example URL:
```
https://app.hubspot.com/oauth/authorize
  ?client_id=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  &redirect_uri=https://yourapp.com/oauth/callback
  &scope=crm.objects.contacts.read%20crm.objects.contacts.write
```

After authorization, HubSpot redirects back to your `redirect_uri` with a `code` parameter:
```
https://yourapp.com/oauth/callback?code=xxxxxxxxxxxxxxxx
```

### Step 2: Token Exchange

Exchange the code for tokens via POST to `/oauth/v1/token`:

```http
POST https://api.hubspot.com/oauth/v1/token
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code
&code={authorization_code}
&redirect_uri={your_redirect_uri}
&client_id={your_client_id}
&client_secret={your_client_secret}
```

Response:
```json
{
  "token_type": "bearer",
  "access_token": "CJqVpAIAAAAAAAABEAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAA...",
  "refresh_token": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "expires_in": 1800
}
```

Key fields:
- `access_token`: Use in `Authorization: Bearer {token}` header for API calls
- `refresh_token`: Store securely; use to get new access tokens when they expire
- `expires_in`: Lifetime in seconds (typically **1800 seconds = 30 minutes**)

### Step 3: Token Refresh

When the access token expires, use the refresh token to obtain a new one:

```http
POST https://api.hubspot.com/oauth/v1/token
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token
&refresh_token={your_refresh_token}
&client_id={your_client_id}
&client_secret={your_client_secret}
```

Response structure is the same as the initial token exchange. The response will include a new `access_token` and a new `expires_in` value.

### Token Introspection

Retrieve metadata about a token (user info, hub ID, scopes, expiry):

```http
GET https://api.hubspot.com/oauth/v1/access-tokens/{token}
```

Response includes:
- `user`: The HubSpot user who authorized the app
- `hub_id`: The portal (account) ID
- `scopes`: Array of granted scopes
- `expires_in`: Remaining lifetime in seconds

### Token Deletion (App Uninstall)

When a user uninstalls your app, delete their refresh token:

```http
DELETE https://api.hubspot.com/oauth/v1/refresh-tokens/{refresh_token}
```

Note: Existing access tokens remain valid until natural expiry even after refresh token deletion.

---

## 4. Deprecated API Keys

HubSpot previously supported a `hapikey` query parameter for authentication:
```
GET /crm/v3/objects/contacts?hapikey=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

This method is **deprecated and should not be used** for new integrations. Existing integrations using API keys should be migrated to Private Apps. The `hapikey` parameter may stop functioning at any time.

---

## 5. Scopes Reference

Scopes define what data an app can access. They are set at Private App creation time or requested during OAuth authorization. HubSpot uses a read/write split for most CRM objects.

### Core CRM Object Scopes

| Scope | Access Granted |
|-------|---------------|
| `crm.objects.contacts.read` | Read contact records |
| `crm.objects.contacts.write` | Create, update, delete contacts |
| `crm.objects.companies.read` | Read company records |
| `crm.objects.companies.write` | Create, update, delete companies |
| `crm.objects.deals.read` | Read deal records |
| `crm.objects.deals.write` | Create, update, delete deals |
| `tickets` | Read and write ticket records (single scope covers both) |
| `crm.objects.owners.read` | Read HubSpot user/owner records |
| `crm.objects.custom.read` | Read custom object records |
| `crm.objects.custom.write` | Create, update, delete custom object records |
| `crm.objects.line_items.read` | Read line item records |
| `crm.objects.line_items.write` | Create, update, delete line items |

### Schema / Property Scopes

| Scope | Access Granted |
|-------|---------------|
| `crm.schemas.contacts.read` | Read contact property definitions |
| `crm.schemas.contacts.write` | Create/modify contact property definitions |
| `crm.schemas.companies.read` | Read company property definitions |
| `crm.schemas.companies.write` | Create/modify company property definitions |
| `crm.schemas.deals.read` | Read deal property definitions |
| `crm.schemas.deals.write` | Create/modify deal property definitions |
| `crm.schemas.custom.read` | Read custom object schemas |
| `crm.schemas.custom.write` | Create/modify custom object schemas |

### Additional Scopes for Common Integrations

| Scope | Access Granted |
|-------|---------------|
| `content` | Marketing emails, landing pages, blog posts |
| `forms` | Create and manage HubSpot forms |
| `e-commerce` | Products, orders, carts |
| `sales-email-read` | Read 1:1 sales emails |
| `timeline` | Create custom timeline events |
| `automation` | Access workflows |
| `analytics.behavioral_events.send` | Send custom behavioral events |

### Minimum Scopes for AI Agent CRM Integration

For a typical AI agent that reads and writes Contacts, Companies, Deals, and Tickets:

```
crm.objects.contacts.read
crm.objects.contacts.write
crm.objects.companies.read
crm.objects.companies.write
crm.objects.deals.read
crm.objects.deals.write
tickets
crm.objects.owners.read
```

---

## 6. Token Storage and Refresh for Automated Systems

### Private App Token Storage

For AI agents using Private App tokens:

1. Store the token in an environment variable, never hardcode it:
   ```
   HUBSPOT_ACCESS_TOKEN=pat-na1-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   ```

2. Load it at runtime:
   ```python
   import os
   HUBSPOT_TOKEN = os.environ["HUBSPOT_ACCESS_TOKEN"]
   ```

3. Since Private App tokens do not expire on a schedule, no automatic refresh logic is needed. The token remains valid until manually rotated or revoked.

4. Implement token rotation into your deployment process: when rotating, update the environment variable and redeploy without downtime by using the 7-day scheduled rotation option.

### OAuth Token Management for Automated Systems

OAuth access tokens expire every 30 minutes. For automated systems, implement proactive token refresh:

```python
import time
import requests

class HubSpotTokenManager:
    def __init__(self, client_id, client_secret, refresh_token):
        self.client_id = client_id
        self.client_secret = client_secret
        self.refresh_token = refresh_token
        self.access_token = None
        self.expires_at = 0

    def get_token(self):
        # Refresh 60 seconds before expiry to avoid race conditions
        if time.time() >= self.expires_at - 60:
            self._refresh()
        return self.access_token

    def _refresh(self):
        response = requests.post(
            "https://api.hubspot.com/oauth/v1/token",
            data={
                "grant_type": "refresh_token",
                "refresh_token": self.refresh_token,
                "client_id": self.client_id,
                "client_secret": self.client_secret
            },
            headers={"Content-Type": "application/x-www-form-urlencoded"}
        )
        data = response.json()
        self.access_token = data["access_token"]
        self.expires_at = time.time() + data["expires_in"]
        # Store updated refresh token if provided
        if "refresh_token" in data:
            self.refresh_token = data["refresh_token"]
```

### Persisting OAuth Tokens

For long-running automated systems, persist token state to avoid re-authorization:

```python
import json
import os

TOKEN_FILE = ".hubspot_tokens.json"

def save_tokens(access_token, refresh_token, expires_at):
    with open(TOKEN_FILE, "w") as f:
        json.dump({
            "access_token": access_token,
            "refresh_token": refresh_token,
            "expires_at": expires_at
        }, f)

def load_tokens():
    if os.path.exists(TOKEN_FILE):
        with open(TOKEN_FILE) as f:
            return json.load(f)
    return None
```

---

## 7. Rate Limits

### General Rate Limits

HubSpot enforces rate limits at two levels: per-second burst limits and daily total limits. Rate limit behavior depends on subscription tier:

| Tier | Burst Limit | Daily Limit |
|------|------------|-------------|
| Free / Starter | 100 req / 10 sec per app | 250,000 / day |
| Professional | 190 req / 10 sec per app | 625,000 / day |
| Enterprise | 190 req / 10 sec per app | 1,000,000 / day |
| With Limit Increase add-on | 200 req / 10 sec | 1,000,000 / day |

### Search-Specific Rate Limits

The CRM Search endpoint has a stricter rate limit:
- **5 requests per second per account**

This applies to `POST /crm/v3/objects/{object}/search` calls.

### Associations API Rate Limits

The Associations v4 API has its own limits:
- **500,000 requests/day** (Professional/Enterprise)
- **150 requests per 10 seconds** (Professional/Enterprise)
- Batch read: maximum **1,000 inputs** per request
- Batch create: maximum **2,000 inputs** per request

### Handling Rate Limit Errors

When rate limits are exceeded, HubSpot returns HTTP `429 Too Many Requests`. The response includes a `Retry-After` header indicating how many seconds to wait before retrying.

Implement exponential backoff for 429 responses:

```python
import time
import requests

def hubspot_request_with_retry(method, url, headers, json=None, max_retries=5):
    for attempt in range(max_retries):
        response = requests.request(method, url, headers=headers, json=json)
        if response.status_code == 429:
            retry_after = int(response.headers.get("Retry-After", 10))
            time.sleep(retry_after)
            continue
        elif response.status_code in (502, 503, 504):
            # Server errors — brief pause and retry
            time.sleep(2 ** attempt)
            continue
        return response
    raise Exception(f"Max retries exceeded for {url}")
```

---

## 8. Error Handling

### Error Response Format

HubSpot returns structured error responses:

```json
{
  "status": "error",
  "message": "Property values were not valid",
  "correlationId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "category": "VALIDATION_ERROR",
  "errors": [
    {
      "message": "No property named 'invalid_property' exists",
      "code": "PROPERTY_DOESNT_EXIST",
      "context": {
        "propertyName": ["invalid_property"]
      }
    }
  ]
}
```

Key fields:
- `correlationId`: Unique request identifier for support tickets
- `category`: Error classification (e.g., `VALIDATION_ERROR`, `RATE_LIMIT`, `AUTHENTICATION_ERROR`)
- `errors[].code`: Machine-readable error code
- `errors[].context`: Additional context about the specific failure

### HTTP Status Code Reference

| Status Code | Meaning | Action |
|-------------|---------|--------|
| `200 OK` | Success | Process response |
| `201 Created` | Record created | Use returned `id` |
| `204 No Content` | Successful delete | No body to parse |
| `207 Multi-Status` | Batch partial success | Check each result's status |
| `400 Bad Request` | Invalid request payload | Fix request body |
| `401 Unauthorized` | Invalid/missing authentication | Check token validity |
| `403 Forbidden` | Missing required scope | Add scope to Private App |
| `404 Not Found` | Record does not exist | Verify the record ID |
| `409 Conflict` | Duplicate record (e.g., email exists) | Handle deduplication |
| `414 URI Too Long` | Request URL too long | Reduce query params |
| `422 Unprocessable Entity` | Validation error | Check property values |
| `423 Locked` | High-volume data sync in progress | Wait 2+ seconds and retry |
| `429 Too Many Requests` | Rate limit exceeded | Use Retry-After header |
| `477` | Account migrating between data centers | Use Retry-After header |
| `500 Internal Server Error` | HubSpot server error | Retry with backoff |
| `502 / 504` | Processing limit or gateway timeout | Brief pause, then retry |
| `503 Service Unavailable` | Temporary unavailability | Pause and retry |

### Batch Operation Error Handling

Batch endpoints return HTTP `207` when some operations succeed and some fail. Each result in the response array has its own status. Include a unique `objectWriteTraceId` in batch create requests to correlate failures:

```json
{
  "inputs": [
    {
      "objectWriteTraceId": "trace-001",
      "properties": { "email": "user@example.com", "firstname": "John" }
    },
    {
      "objectWriteTraceId": "trace-002",
      "properties": { "email": "duplicate@example.com", "firstname": "Jane" }
    }
  ]
}
```

The response will contain both successful and failed entries with the `objectWriteTraceId` to identify which failed.

---

## 9. CRM Architecture Overview

### Object Model

HubSpot CRM is structured around **objects** (entity types), **records** (individual instances), and **properties** (data fields). Objects are identified by an `objectTypeId`:

| Object | objectTypeId | Description |
|--------|-------------|-------------|
| Contacts | `0-1` | Individual persons |
| Companies | `0-2` | Business organizations |
| Deals | `0-3` | Sales opportunities |
| Tickets | `0-5` | Customer support requests |
| Products | `0-7` | Goods or services catalog |
| Custom objects | `2-XXX` | User-defined entity types |

### Record Identifiers

Every CRM record receives an automatically generated `hs_object_id` (Record ID). This is the primary identifier for most API operations.

Additional identifiers per object type:
- **Contacts**: `email` — the primary deduplication identifier
- **Companies**: `domain` — the primary deduplication identifier
- **Deals / Tickets**: `hs_object_id` only (no natural unique key)

Custom unique identifier properties can be created via the Properties API (`hasUniqueValue: true`) and used in place of `hs_object_id` for reads and updates.

### Associations

Records can be linked across object types via the Associations API. Common relationships:
- Contact → Company (primary company, additional companies)
- Contact → Deal
- Contact → Ticket
- Company → Deal
- Company → Ticket
- Deal → Ticket

Associations use numeric `associationTypeId` values. The v4 Associations API supports labeled associations for richer relationship modeling.

### Pipelines

Deals and Tickets flow through **Pipelines**, which contain ordered **Stages**. Stage assignment uses internal numeric IDs, not display names. Retrieve pipeline and stage IDs via the Pipelines API before creating records.

---

## 10. Contacts API

**Base path:** `/crm/v3/objects/contacts`
**Required scopes:** `crm.objects.contacts.read`, `crm.objects.contacts.write`

### 10.1 Create a Contact

```http
POST https://api.hubspot.com/crm/v3/objects/contacts
Authorization: Bearer {token}
Content-Type: application/json
```

**Minimum request body (at least one field required):**
```json
{
  "properties": {
    "email": "john.doe@example.com",
    "firstname": "John",
    "lastname": "Doe"
  }
}
```

**Full request body with associations:**
```json
{
  "properties": {
    "email": "jane@example.com",
    "firstname": "Jane",
    "lastname": "Doe",
    "phone": "+18884827768",
    "mobilephone": "+18885551234",
    "jobtitle": "Marketing Manager",
    "company": "Acme Corp",
    "website": "acmecorp.com",
    "lifecyclestage": "marketingqualifiedlead",
    "address": "123 Main St",
    "city": "Boston",
    "state": "Massachusetts",
    "country": "United States",
    "zip": "02101"
  },
  "associations": [
    {
      "to": {
        "id": 123456
      },
      "types": [
        {
          "associationCategory": "HUBSPOT_DEFINED",
          "associationTypeId": 279
        }
      ]
    }
  ]
}
```

**Response (HTTP 201):**
```json
{
  "id": "33451",
  "properties": {
    "createdate": "2024-01-17T19:55:04.281Z",
    "email": "jane@example.com",
    "firstname": "Jane",
    "hs_object_id": "33451",
    "lastmodifieddate": "2024-01-17T19:55:04.281Z",
    "lastname": "Doe"
  },
  "createdAt": "2024-01-17T19:55:04.281Z",
  "updatedAt": "2024-01-17T19:55:04.281Z",
  "archived": false
}
```

### 10.2 Retrieve a Contact

**By Record ID:**
```http
GET https://api.hubspot.com/crm/v3/objects/contacts/{recordId}
  ?properties=email,firstname,lastname,phone,jobtitle,lifecyclestage
  &associations=companies,deals
```

**By Email Address:**
```http
GET https://api.hubspot.com/crm/v3/objects/contacts/{email}?idProperty=email
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `properties` | string | Comma-separated list of properties to return |
| `propertiesWithHistory` | string | Properties to return with historical values |
| `associations` | string | Comma-separated associated object types to include |

### 10.3 List All Contacts

```http
GET https://api.hubspot.com/crm/v3/objects/contacts
  ?limit=100
  &properties=email,firstname,lastname
  &after={cursor}
```

**Query Parameters:**

| Parameter | Type | Default | Max |
|-----------|------|---------|-----|
| `limit` | integer | 100 | 100 |
| `after` | string | — | — |
| `properties` | string | — | — |

**Response:**
```json
{
  "results": [
    {
      "id": "33451",
      "properties": {
        "createdate": "2022-06-01T14:31:48.469Z",
        "email": "lorelai@thedragonfly.com",
        "firstname": "Lorelai",
        "hs_object_id": "33451",
        "lastmodifieddate": "2025-07-07T20:27:17.947Z",
        "lastname": "Gilmore"
      },
      "createdAt": "2022-06-01T14:31:48.469Z",
      "updatedAt": "2025-07-07T20:27:17.947Z",
      "archived": false
    }
  ],
  "paging": {
    "next": {
      "after": "33452",
      "link": "https://api.hubspot.com/crm/objects/v3/contacts?limit=1"
    }
  }
}
```

The `paging.next.after` value is the Record ID of the next batch. Pass it as the `after` parameter in the next request. If `paging.next` is absent, you have reached the last page.

### 10.4 Update a Contact

**By Record ID:**
```http
PATCH https://api.hubspot.com/crm/v3/objects/contacts/{contactId}
Content-Type: application/json

{
  "properties": {
    "jobtitle": "Senior Marketing Manager",
    "lifecyclestage": "salesqualifiedlead"
  }
}
```

**By Email Address:**
```http
PATCH https://api.hubspot.com/crm/v3/objects/contacts/{email}?idProperty=email
```

To **clear a property value**, set it to an empty string:
```json
{ "properties": { "phone": "" } }
```

**Lifecycle Stage Constraint:** Lifecycle stages can only move forward in the default order. To move a contact backward, first clear the lifecycle stage (`"lifecyclestage": ""`), then set the desired stage.

### 10.5 Delete a Contact

```http
DELETE https://api.hubspot.com/crm/v3/objects/contacts/{contactId}
```

Deleted contacts move to the HubSpot recycling bin and can be restored within HubSpot.

### 10.6 Batch Create Contacts

```http
POST https://api.hubspot.com/crm/v3/objects/contacts/batch/create
Content-Type: application/json

{
  "inputs": [
    {
      "objectWriteTraceId": "trace-001",
      "properties": {
        "email": "alice@example.com",
        "firstname": "Alice",
        "lastname": "Smith"
      }
    },
    {
      "objectWriteTraceId": "trace-002",
      "properties": {
        "email": "bob@example.com",
        "firstname": "Bob",
        "lastname": "Jones"
      }
    }
  ]
}
```

Maximum: **100 records** per batch request.

### 10.7 Batch Read Contacts

**By Record ID:**
```json
{
  "properties": ["email", "lifecyclestage", "jobtitle"],
  "inputs": [
    { "id": "1234567" },
    { "id": "987456" }
  ]
}
```

**By Email Address:**
```json
{
  "properties": ["email", "lifecyclestage", "jobtitle"],
  "idProperty": "email",
  "inputs": [
    { "id": "alice@example.com" },
    { "id": "bob@example.com" }
  ]
}
```

**By Custom Unique Property:**
```json
{
  "properties": ["email", "lifecyclestage"],
  "idProperty": "internalcustomerid",
  "inputs": [
    { "id": "CUST-12345" },
    { "id": "CUST-67891" }
  ]
}
```

Endpoint: `POST /crm/v3/objects/contacts/batch/read`

### 10.8 Batch Update Contacts

```http
POST https://api.hubspot.com/crm/v3/objects/contacts/batch/update
Content-Type: application/json

{
  "inputs": [
    {
      "id": "123456789",
      "properties": {
        "lifecyclestage": "customer"
      }
    },
    {
      "id": "56789123",
      "properties": {
        "lifecyclestage": "customer"
      }
    }
  ]
}
```

### 10.9 Batch Upsert Contacts

Creates contacts if they don't exist; updates them if they do. Uses email (or a custom unique property) as the identifier:

```http
POST https://api.hubspot.com/crm/v3/objects/contacts/batch/upsert
Content-Type: application/json

{
  "inputs": [
    {
      "properties": { "phone": "+18884827768", "firstname": "Alice" },
      "id": "alice@example.com",
      "idProperty": "email"
    },
    {
      "properties": { "phone": "+18888888888", "firstname": "Bob" },
      "id": "bob@example.com",
      "idProperty": "email"
    }
  ]
}
```

**Note:** Partial upserts are not supported when using email as the identifier. If the contact already exists by email, all provided properties are updated.

### 10.10 Key Contact Properties

| Property | Type | Description |
|----------|------|-------------|
| `email` | string | Primary unique identifier |
| `hs_additional_emails` | string | Additional email addresses (semicolon-separated) |
| `firstname` | string | First name |
| `lastname` | string | Last name |
| `phone` | string | Phone number |
| `mobilephone` | string | Mobile number |
| `jobtitle` | string | Job title |
| `company` | string | Company name (text, not linked) |
| `website` | string | Personal website |
| `lifecyclestage` | enumeration | subscriber → lead → marketingqualifiedlead → salesqualifiedlead → opportunity → customer → evangelist → other |
| `hubspot_owner_id` | string | Assigned HubSpot owner (user ID) |
| `hs_pinned_engagement_id` | number | Pinned activity record ID |
| `hs_object_id` | number | Auto-generated record ID |
| `createdate` | datetime | Record creation timestamp |
| `lastmodifieddate` | datetime | Last update timestamp |

---

## 11. Companies API

**Base path:** `/crm/v3/objects/companies`
**Required scopes:** `crm.objects.companies.read`, `crm.objects.companies.write`

### 11.1 Create a Company

```http
POST https://api.hubspot.com/crm/v3/objects/companies
Authorization: Bearer {token}
Content-Type: application/json
```

**Request body:**
```json
{
  "properties": {
    "name": "Acme Corporation",
    "domain": "acmecorp.com",
    "city": "Boston",
    "state": "Massachusetts",
    "country": "United States",
    "industry": "Technology",
    "phone": "+16175551234",
    "numberofemployees": 250,
    "annualrevenue": 5000000,
    "lifecyclestage": "customer"
  },
  "associations": [
    {
      "to": { "id": 33451 },
      "types": [
        {
          "associationCategory": "HUBSPOT_DEFINED",
          "associationTypeId": 280
        }
      ]
    }
  ]
}
```

`associationTypeId: 280` = Company to Contact. `associationTypeId: 2` = Company to Primary Contact.

**Deduplication:** Use `domain` as the primary identifier. HubSpot deduplicates companies by domain name. Always include `domain` when known.

**Multiple Domains:** Use `hs_additional_domains` with semicolon-separated values:
```json
{ "hs_additional_domains": "acme.co;acme.io" }
```

### 11.2 Retrieve a Company

```http
GET https://api.hubspot.com/crm/v3/objects/companies/{companyId}
  ?properties=name,domain,industry,numberofemployees
  &associations=contacts,deals
```

### 11.3 List All Companies

```http
GET https://api.hubspot.com/crm/v3/objects/companies
  ?limit=100
  &properties=name,domain
  &after={cursor}
```

### 11.4 Update a Company

```http
PATCH https://api.hubspot.com/crm/v3/objects/companies/{companyId}
Content-Type: application/json

{
  "properties": {
    "annualrevenue": 7500000,
    "numberofemployees": 320
  }
}
```

### 11.5 Delete a Company

```http
DELETE https://api.hubspot.com/crm/v3/objects/companies/{companyId}
```

### 11.6 Batch Read Companies

**By Record ID:**
```json
{
  "properties": ["name", "domain", "industry"],
  "inputs": [
    { "id": "56789" },
    { "id": "23456" }
  ]
}
```

**By Custom Unique Property:**
```json
{
  "properties": ["name", "domain"],
  "idProperty": "uniquepropertyexample",
  "inputs": [
    { "id": "abc" },
    { "id": "def" }
  ]
}
```

**Important:** The batch read endpoint cannot retrieve associations. Use the Associations API separately.

### 11.7 Key Company Properties

| Property | Type | Description |
|----------|------|-------------|
| `name` | string | Company name |
| `domain` | string | Primary domain (deduplication key) |
| `hs_additional_domains` | string | Additional domains (semicolon-separated) |
| `industry` | enumeration | Industry sector |
| `numberofemployees` | number | Employee count |
| `annualrevenue` | number | Annual revenue |
| `phone` | string | Main phone number |
| `city` | string | Headquarters city |
| `state` | string | Headquarters state |
| `country` | string | Headquarters country |
| `lifecyclestage` | enumeration | Pipeline stage (same values as contacts) |
| `hubspot_owner_id` | string | Assigned owner |
| `hs_pinned_engagement_id` | number | Pinned activity |
| `hs_object_id` | number | Auto-generated record ID |

---

## 12. Deals API

**Base path:** `/crm/v3/objects/deals`
**Required scopes:** `crm.objects.deals.read`, `crm.objects.deals.write`

### 12.1 Create a Deal

```http
POST https://api.hubspot.com/crm/v3/objects/deals
Authorization: Bearer {token}
Content-Type: application/json
```

**Critical note:** Deal stage and pipeline values must be the **internal IDs** (not display names). Retrieve these from the Pipelines API first:
```
GET /crm/v3/pipelines/deals
```

**Request body:**
```json
{
  "properties": {
    "dealname": "Enterprise License — Acme Corp",
    "pipeline": "default",
    "dealstage": "appointmentscheduled",
    "amount": "25000.00",
    "closedate": "2026-06-30T00:00:00.000Z",
    "hubspot_owner_id": "910901",
    "hs_all_collaborator_owner_ids": ";12345678;9101112"
  }
}
```

**With associations (linking contact and company at creation):**
```json
{
  "properties": {
    "dealname": "Enterprise License — Acme Corp",
    "pipeline": "default",
    "dealstage": "contractsent",
    "amount": "25000.00",
    "closedate": "2026-06-30T00:00:00.000Z",
    "hubspot_owner_id": "910901"
  },
  "associations": [
    {
      "to": { "id": 33451 },
      "types": [
        {
          "associationCategory": "HUBSPOT_DEFINED",
          "associationTypeId": 3
        }
      ]
    },
    {
      "to": { "id": 56789 },
      "types": [
        {
          "associationCategory": "HUBSPOT_DEFINED",
          "associationTypeId": 341
        }
      ]
    }
  ]
}
```

`associationTypeId: 3` = Deal to Contact. `associationTypeId: 341` = Deal to Company.

### 12.2 Retrieve a Deal

```http
GET https://api.hubspot.com/crm/v3/objects/deals/{dealId}
  ?properties=dealname,dealstage,pipeline,amount,closedate,hubspot_owner_id
  &associations=contacts,companies
```

### 12.3 Update a Deal (Stage Transition)

```http
PATCH https://api.hubspot.com/crm/v3/objects/deals/{dealId}
Content-Type: application/json

{
  "properties": {
    "dealstage": "closedwon",
    "amount": "27500.00"
  }
}
```

For stage transitions, always use the internal stage ID. The "closedwon" and "closedlost" stages are typically standard across all pipelines.

### 12.4 Batch Update Deals

```http
POST https://api.hubspot.com/crm/v3/objects/deals/batch/update

{
  "inputs": [
    {
      "id": "7891023",
      "properties": { "dealstage": "negotiation" }
    },
    {
      "id": "987654",
      "properties": { "dealstage": "closedwon", "amount": "15000" }
    }
  ]
}
```

### 12.5 Delete a Deal

```http
DELETE https://api.hubspot.com/crm/v3/objects/deals/{dealId}
```

**Batch delete:**
```http
POST https://api.hubspot.com/crm/v3/objects/deals/batch/archive

{
  "inputs": [
    { "id": "7891023" },
    { "id": "987654" }
  ]
}
```

### 12.6 Key Deal Properties

| Property | Type | Description |
|----------|------|-------------|
| `dealname` | string | Deal name (required) |
| `pipeline` | string | Pipeline internal ID (required) |
| `dealstage` | string | Stage internal ID (required) |
| `amount` | number | Deal value |
| `closedate` | datetime | Expected or actual close date |
| `hubspot_owner_id` | string | Primary deal owner |
| `hs_all_collaborator_owner_ids` | string | Collaborating owners (semicolon-prefixed) |
| `deal_currency_code` | string | ISO currency code |
| `hs_deal_stage_probability` | number | Close probability (set by stage) |
| `hs_pinned_engagement_id` | number | Pinned activity |
| `hs_object_id` | number | Auto-generated record ID |

### 12.7 Common Deal Stage Internal IDs (Default Pipeline)

The default pipeline typically uses these stage IDs (verify with your account's Pipelines API):

| Stage Label | Common Internal ID |
|------------|-------------------|
| Appointment Scheduled | `appointmentscheduled` |
| Qualified to Buy | `qualifiedtobuy` |
| Presentation Scheduled | `presentationscheduled` |
| Decision Maker Bought-In | `decisionmakerboughtin` |
| Contract Sent | `contractsent` |
| Closed Won | `closedwon` |
| Closed Lost | `closedlost` |

---

## 13. Tickets API

**Base path:** `/crm/v3/objects/tickets`
**Required scope:** `tickets`

Note: Unlike other CRM objects, tickets use a **single scope** (`tickets`) for both read and write access.

### 13.1 Create a Ticket

```http
POST https://api.hubspot.com/crm/v3/objects/tickets
Authorization: Bearer {token}
Content-Type: application/json
```

**Required fields:** `subject`, `hs_pipeline_stage`, optionally `hs_pipeline`

Pipeline and stage values must be the internal **numeric IDs**. Retrieve them from:
```
GET /crm/v3/pipelines/tickets
```

**Request body:**
```json
{
  "properties": {
    "subject": "Unable to log in to dashboard",
    "hs_pipeline": "0",
    "hs_pipeline_stage": "1",
    "hs_ticket_priority": "HIGH",
    "content": "The customer reports receiving a 403 error when attempting to log in. Reproduced on Chrome and Firefox.",
    "hubspot_owner_id": "910901"
  }
}
```

**With associations (linking contact and company):**
```json
{
  "properties": {
    "subject": "API integration failing",
    "hs_pipeline": "0",
    "hs_pipeline_stage": "1",
    "hs_ticket_priority": "MEDIUM"
  },
  "associations": [
    {
      "to": { "id": 33451 },
      "types": [
        {
          "associationCategory": "HUBSPOT_DEFINED",
          "associationTypeId": 16
        }
      ]
    },
    {
      "to": { "id": 56789 },
      "types": [
        {
          "associationCategory": "HUBSPOT_DEFINED",
          "associationTypeId": 26
        }
      ]
    }
  ]
}
```

`associationTypeId: 16` = Ticket to Contact. `associationTypeId: 26` = Ticket to Company.

### 13.2 Retrieve and Update Tickets

```http
GET https://api.hubspot.com/crm/v3/objects/tickets/{ticketId}
  ?properties=subject,hs_pipeline_stage,hs_ticket_priority,hubspot_owner_id

PATCH https://api.hubspot.com/crm/v3/objects/tickets/{ticketId}
Content-Type: application/json

{
  "properties": {
    "hs_pipeline_stage": "4",
    "hs_ticket_priority": "LOW"
  }
}
```

### 13.3 Batch Operations

```http
POST https://api.hubspot.com/crm/v3/objects/tickets/batch/read
POST https://api.hubspot.com/crm/v3/objects/tickets/batch/update
```

Same structure as other CRM object batch endpoints.

### 13.4 Key Ticket Properties

| Property | Type | Description |
|----------|------|-------------|
| `subject` | string | Ticket name/subject (required) |
| `hs_pipeline` | string | Pipeline ID (required) |
| `hs_pipeline_stage` | string | Stage numeric ID (required) |
| `hs_ticket_priority` | enumeration | LOW, MEDIUM, HIGH |
| `content` | string | Ticket description/body |
| `hubspot_owner_id` | string | Assigned support agent |
| `hs_resolution` | enumeration | Resolution type |
| `hs_pinned_engagement_id` | number | Pinned activity |
| `createdate` | datetime | Creation timestamp |
| `hs_lastmodifieddate` | datetime | Last update timestamp |

### 13.5 Ticket Pipeline Stage `ticketState` Values

When reading pipeline stages via the Pipelines API, ticket stages have a `ticketState` metadata field:
- `OPEN` — ticket is active
- `CLOSED` — ticket is resolved

---

## 14. Associations API v4

The Associations API v4 manages relationships between CRM records. It supports both unlabeled (default) and labeled associations.

**Base path:** `/crm/v4/`

### 14.1 Common Association Type IDs

| Relationship | associationTypeId |
|-------------|------------------|
| Contact → Primary Company | `1` |
| Company → Primary Contact | `2` |
| Deal → Contact | `3` |
| Contact → Deal | `4` |
| Ticket → Contact | `15` |
| Contact → Ticket | `16` |
| Company → Deal | `342` |
| Deal → Company | `341` |
| Contact → Company | `279` |
| Company → Contact | `280` |
| Ticket → Company | `25` |
| Company → Ticket | `26` |
| Deal → Ticket | `27` |

### 14.2 Associate Records (Default, No Label)

Single association without label:
```http
PUT https://api.hubspot.com/crm/v4/objects/{fromObjectType}/{fromObjectId}/associations/default/{toObjectType}/{toObjectId}
```

Example: Associate contact 33451 to company 56789:
```http
PUT https://api.hubspot.com/crm/v4/objects/contacts/33451/associations/default/companies/56789
```

### 14.3 Associate Records (With Label)

```http
PUT https://api.hubspot.com/crm/v4/objects/{objectType}/{objectId}/associations/{toObjectType}/{toObjectId}
Content-Type: application/json

[
  {
    "associationCategory": "HUBSPOT_DEFINED",
    "associationTypeId": 279
  }
]
```

`associationCategory` values:
- `HUBSPOT_DEFINED` — standard HubSpot association types
- `USER_DEFINED` — custom labels created in your account

### 14.4 Batch Associate Records

```http
POST https://api.hubspot.com/crm/v4/associations/{fromObjectType}/{toObjectType}/batch/create
Content-Type: application/json

{
  "inputs": [
    {
      "from": { "id": "33451" },
      "to": { "id": "56789" },
      "types": [
        {
          "associationCategory": "HUBSPOT_DEFINED",
          "associationTypeId": 279
        }
      ]
    }
  ]
}
```

Maximum: **2,000 inputs** per batch create request.

### 14.5 Retrieve Associations

```http
GET https://api.hubspot.com/crm/v4/objects/contacts/33451/associations/companies
```

**Batch read (up to 1,000 inputs):**
```http
POST https://api.hubspot.com/crm/v4/associations/contacts/companies/batch/read

{
  "inputs": [
    { "id": "33451" },
    { "id": "33452" }
  ]
}
```

### 14.6 Remove Associations

Single:
```http
DELETE https://api.hubspot.com/crm/v4/objects/contacts/33451/associations/companies/56789
```

Batch:
```http
POST https://api.hubspot.com/crm/v4/associations/contacts/companies/batch/archive

{
  "inputs": [
    {
      "from": { "id": "33451" },
      "to": { "id": "56789" }
    }
  ]
}
```

---

## 15. CRM Search API

**Endpoint:** `POST /crm/v3/objects/{objectType}/search`
**Rate limit:** 5 requests per second per account

### 15.1 Request Structure

```json
{
  "filterGroups": [
    {
      "filters": [
        {
          "propertyName": "email",
          "operator": "CONTAINS_TOKEN",
          "value": "*@hubspot.com"
        }
      ]
    }
  ],
  "properties": ["email", "firstname", "lastname", "phone"],
  "sorts": [
    {
      "propertyName": "createdate",
      "direction": "DESCENDING"
    }
  ],
  "limit": 50,
  "after": "0"
}
```

### 15.2 Filter Operators

| Operator | Use Case | Example |
|----------|----------|---------|
| `EQ` | Exact match | `{"propertyName": "firstname", "operator": "EQ", "value": "Alice"}` |
| `NEQ` | Not equal | `{"propertyName": "lifecyclestage", "operator": "NEQ", "value": "customer"}` |
| `LT` / `LTE` | Less than | `{"propertyName": "amount", "operator": "LT", "value": "10000"}` |
| `GT` / `GTE` | Greater than | `{"propertyName": "amount", "operator": "GT", "value": "5000"}` |
| `BETWEEN` | Range (inclusive) | `{"propertyName": "createdate", "operator": "BETWEEN", "value": "1609459200000", "highValue": "1640995200000"}` |
| `IN` | List membership | `{"propertyName": "lifecyclestage", "operator": "IN", "values": ["lead", "customer"]}` |
| `NOT_IN` | Not in list | `{"propertyName": "lifecyclestage", "operator": "NOT_IN", "values": ["subscriber"]}` |
| `HAS_PROPERTY` | Property exists | `{"propertyName": "phone", "operator": "HAS_PROPERTY"}` |
| `NOT_HAS_PROPERTY` | Property is empty | `{"propertyName": "email", "operator": "NOT_HAS_PROPERTY"}` |
| `CONTAINS_TOKEN` | Partial match / wildcard | `{"propertyName": "email", "operator": "CONTAINS_TOKEN", "value": "*@gmail.com"}` |
| `NOT_CONTAINS_TOKEN` | Does not contain | `{"propertyName": "company", "operator": "NOT_CONTAINS_TOKEN", "value": "test"}` |

**Notes:**
- `IN` / `NOT_IN` values must be **lowercase** for string properties
- `BETWEEN` requires both `value` (low) and `highValue` (high)
- `CONTAINS_TOKEN` supports wildcard `*` prefix/suffix
- Enumeration properties are **case-sensitive** (use exact internal values)
- All other text searches are **case-insensitive**

### 15.3 AND / OR Logic

**AND (multiple filters in one group):**
```json
{
  "filterGroups": [
    {
      "filters": [
        { "propertyName": "firstname", "operator": "EQ", "value": "Alice" },
        { "propertyName": "lifecyclestage", "operator": "EQ", "value": "customer" }
      ]
    }
  ]
}
```

**OR (multiple filter groups):**
```json
{
  "filterGroups": [
    {
      "filters": [
        { "propertyName": "lifecyclestage", "operator": "EQ", "value": "lead" }
      ]
    },
    {
      "filters": [
        { "propertyName": "lifecyclestage", "operator": "EQ", "value": "marketingqualifiedlead" }
      ]
    }
  ]
}
```

**Limits:** Maximum 5 filterGroups, maximum 6 filters per group, 18 total filters.

### 15.4 Search Response

```json
{
  "total": 2,
  "results": [
    {
      "id": "100451",
      "properties": {
        "createdate": "2024-01-17T19:55:04.281Z",
        "email": "testperson@hubspot.com",
        "firstname": "Test",
        "hs_object_id": "100451",
        "lastmodifieddate": "2024-09-11T13:27:39.356Z",
        "lastname": "Person"
      },
      "createdAt": "2024-01-17T19:55:04.281Z",
      "updatedAt": "2024-09-11T13:27:39.356Z",
      "archived": false
    }
  ],
  "paging": {
    "next": {
      "after": "10"
    }
  }
}
```

### 15.5 Pagination

- Default page size: 10 records
- Maximum page size: 200 records
- Hard result cap: **10,000 records** per query
- Use `paging.next.after` as the `after` parameter in the next request

For datasets exceeding 10,000 records, paginate using date range filters to slice through the full dataset.

### 15.6 Searchable Objects

Contacts, Companies, Deals, Tickets, Products, Quotes, Invoices, Orders, Carts, Payments, Subscriptions, Calls, Emails, Meetings, Notes, Tasks.

### 15.7 Association-Based Filtering

Search contacts associated with a specific company:
```json
{
  "filterGroups": [
    {
      "filters": [
        {
          "propertyName": "associations.company",
          "operator": "EQ",
          "value": "56789"
        }
      ]
    }
  ]
}
```

Custom object associations are not currently supported via search.

---

## 16. Properties API

**Base path:** `/crm/v3/properties/{objectType}`

### 16.1 List All Properties

```http
GET https://api.hubspot.com/crm/v3/properties/contacts
GET https://api.hubspot.com/crm/v3/properties/companies
GET https://api.hubspot.com/crm/v3/properties/deals
GET https://api.hubspot.com/crm/v3/properties/tickets
```

By default, sensitive properties are excluded. Add `?dataSensitivity=sensitive` to include them.

### 16.2 Get a Specific Property

```http
GET https://api.hubspot.com/crm/v3/properties/contacts/{propertyName}
```

### 16.3 Create a Custom Property

```http
POST https://api.hubspot.com/crm/v3/properties/contacts
Content-Type: application/json

{
  "groupName": "contactinformation",
  "name": "customer_tier",
  "label": "Customer Tier",
  "type": "enumeration",
  "fieldType": "select",
  "options": [
    { "label": "Tier 1", "value": "tier_1", "displayOrder": 1 },
    { "label": "Tier 2", "value": "tier_2", "displayOrder": 2 },
    { "label": "Tier 3", "value": "tier_3", "displayOrder": 3 }
  ]
}
```

### 16.4 Create a Unique ID Property

```http
POST https://api.hubspot.com/crm/v3/properties/contacts
Content-Type: application/json

{
  "groupName": "contactinformation",
  "name": "external_customer_id",
  "label": "External Customer ID",
  "type": "string",
  "fieldType": "text",
  "hasUniqueValue": true
}
```

Maximum 10 unique ID properties per object. Enables:
```
GET /crm/v3/objects/contacts/{value}?idProperty=external_customer_id
```

### 16.5 Property Types Reference

| type | fieldType options | Description |
|------|------------------|-------------|
| `string` | text, textarea, html, file, phonenumber | Text up to 65,536 chars |
| `number` | number, calculation_equation | Numeric values |
| `bool` | booleancheckbox | True/false |
| `enumeration` | select, radio, checkbox | Predefined options |
| `date` | date | Date only (UTC) |
| `datetime` | date | Date + time (UTC) |

---

## 17. Pipelines API

**Base path:** `/crm/v3/pipelines/{objectType}`

### 17.1 List All Pipelines

```http
GET https://api.hubspot.com/crm/v3/pipelines/deals
GET https://api.hubspot.com/crm/v3/pipelines/tickets
```

**Response:**
```json
{
  "results": [
    {
      "id": "default",
      "label": "Sales Pipeline",
      "displayOrder": 0,
      "stages": [
        {
          "id": "appointmentscheduled",
          "label": "Appointment Scheduled",
          "displayOrder": 0,
          "metadata": { "probability": "0.2" }
        },
        {
          "id": "closedwon",
          "label": "Closed Won",
          "displayOrder": 7,
          "metadata": { "probability": "1.0" }
        }
      ]
    }
  ]
}
```

### 17.2 Get Stages for a Specific Pipeline

```http
GET https://api.hubspot.com/crm/v3/pipelines/deals/{pipelineId}/stages
```

### 17.3 Pipeline Audit Trail

```http
GET https://api.hubspot.com/crm/v3/pipelines/deals/{pipelineId}/audit
```

Returns changes in reverse chronological order.

---

## 18. Best Practices for AI Agents

### 18.1 Initialization Checklist

Before making any CRM calls, an AI agent should:

1. **Verify credentials**: Test the token with a simple read call (e.g., `GET /crm/v3/objects/contacts?limit=1`)
2. **Fetch pipeline IDs**: Store deal and ticket pipeline IDs and stage IDs at startup to avoid repeated lookups
3. **Fetch owner IDs**: If assigning records to users, retrieve owner IDs via `GET /crm/v3/owners`
4. **Verify scopes**: Check that all required scopes are present before attempting operations

### 18.2 Deduplication Strategy

Contacts and companies can accumulate duplicates. AI agents should:

1. **Always search before creating**: Use the Search API to check for existing records before creating new ones
2. **Use email for contact deduplication**:
   ```json
   {
     "filterGroups": [
       { "filters": [{ "propertyName": "email", "operator": "EQ", "value": "user@example.com" }] }
     ]
   }
   ```
3. **Use domain for company deduplication**:
   ```json
   {
     "filterGroups": [
       { "filters": [{ "propertyName": "domain", "operator": "EQ", "value": "example.com" }] }
     ]
   }
   ```
4. **Use upsert for contacts** (`batch/upsert`) when you have the email — this handles create-or-update automatically

### 18.3 Batch Operations for Efficiency

For bulk operations, always use batch endpoints:

- Single record operations count as 1 API call each
- Batch operations count as 1 API call for up to 100 records
- Example: Syncing 500 contacts = 500 single calls vs. 5 batch calls

Always prefer:
- `POST /crm/v3/objects/contacts/batch/create` over individual POSTs
- `POST /crm/v3/objects/contacts/batch/read` over individual GETs
- `POST /crm/v3/objects/contacts/batch/upsert` for CRM sync scenarios

### 18.4 Pagination Pattern

Never assume all records fit in one response. Always implement pagination:

```python
def get_all_contacts(headers, properties=None):
    url = "https://api.hubspot.com/crm/v3/objects/contacts"
    params = {"limit": 100}
    if properties:
        params["properties"] = ",".join(properties)

    all_records = []
    while True:
        response = requests.get(url, headers=headers, params=params)
        data = response.json()
        all_records.extend(data.get("results", []))

        paging = data.get("paging", {})
        if "next" not in paging:
            break
        params["after"] = paging["next"]["after"]

    return all_records
```

For search, use the same pattern with `after` in the request body:
```python
body["after"] = paging["next"]["after"]
```

### 18.5 Rate Limit Handling

Implement rate limit handling at the HTTP client level, not per-endpoint:

```python
import time
import requests

class HubSpotClient:
    BASE_URL = "https://api.hubspot.com"

    def __init__(self, token):
        self.headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }

    def request(self, method, path, **kwargs):
        url = f"{self.BASE_URL}{path}"
        for attempt in range(5):
            resp = requests.request(method, url, headers=self.headers, **kwargs)
            if resp.status_code == 429:
                wait = int(resp.headers.get("Retry-After", 10))
                time.sleep(wait)
                continue
            if resp.status_code in (502, 503, 504):
                time.sleep(2 ** attempt)
                continue
            resp.raise_for_status()
            return resp
        raise Exception(f"Request failed after 5 retries: {method} {path}")

    def get(self, path, **kwargs):
        return self.request("GET", path, **kwargs)

    def post(self, path, **kwargs):
        return self.request("POST", path, **kwargs)

    def patch(self, path, **kwargs):
        return self.request("PATCH", path, **kwargs)

    def delete(self, path, **kwargs):
        return self.request("DELETE", path, **kwargs)
```

### 18.6 Property Fetching Strategy

Avoid fetching all properties by default — this increases response size and processing time. For AI agents:

1. Define a **property allowlist** for each object type based on your use case
2. Always request only the properties you need via the `properties` parameter
3. Cache property definitions locally — they rarely change

Example allowlist strategy:
```python
CONTACT_PROPERTIES = [
    "email", "firstname", "lastname", "phone", "jobtitle",
    "company", "lifecyclestage", "hubspot_owner_id", "createdate"
]

DEAL_PROPERTIES = [
    "dealname", "dealstage", "pipeline", "amount",
    "closedate", "hubspot_owner_id", "createdate"
]
```

### 18.7 Association Management

When creating related records (e.g., a contact + company + deal in a single workflow):

1. Create the company first
2. Create the contact, associating it to the company in the same request
3. Create the deal, associating it to both the contact and company in the same request

This approach minimizes API calls. Alternatively, create all records independently and use the Associations API batch endpoint to link them in a single call.

### 18.8 Error Logging for Debugging

Always capture `correlationId` from error responses. This identifier is required when contacting HubSpot support:

```python
response = client.post("/crm/v3/objects/contacts", json=payload)
if not response.ok:
    error = response.json()
    logger.error(
        "HubSpot API error",
        status=response.status_code,
        category=error.get("category"),
        message=error.get("message"),
        correlation_id=error.get("correlationId"),
        errors=error.get("errors", [])
    )
```

### 18.9 Known Limitations and Gotchas

1. **Lifecycle stage ordering**: Stages only advance forward by default. Clear the stage value before moving backward.
2. **Deal stage IDs are not universal**: The internal ID for a stage is account-specific. Never hardcode stage IDs — always retrieve from the Pipelines API.
3. **Batch read cannot return associations**: Use the Associations API separately or fetch associations on individual record reads.
4. **Search indexing delay**: Newly created or updated records may take several seconds to appear in search results. For immediate lookups after creation, use the direct record ID endpoint.
5. **Token length**: Access tokens can be up to 512 characters. Ensure your storage layer supports this.
6. **IN operator values must be lowercase**: When using the `IN` operator with string properties, all values in the array must be lowercase.
7. **Ticket scope is unified**: The `tickets` scope grants both read and write access. There is no separate read-only scope for tickets.
8. **Batch operation max sizes**: 100 records per batch create/update; 200 per batch read; 2,000 per associations batch create; 1,000 per associations batch read.
9. **Search hard limit**: The Search API returns a maximum of 10,000 results per query regardless of pagination. For larger exports, use the CRM Export API instead.
10. **Domain deduplication**: HubSpot automatically deduplicates companies by domain. Creating two companies with the same domain will merge them in some account configurations.

---

*Document compiled from official HubSpot Developer Documentation (developers.hubspot.com)*
*API Reference: https://developers.hubspot.com/docs/reference/api*
*Last updated: 2026-03-18*
