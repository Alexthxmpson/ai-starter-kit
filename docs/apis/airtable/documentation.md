# Airtable API — Technical Documentation

**Source:** https://airtable.com/developers/web/api/introduction | https://airtable.com/developers/web/api/field-model
**Date:** 2026-02-27
**API Version:** v0 (stable)

---

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Base URL & Headers](#base-url--headers)
4. [Rate Limits](#rate-limits)
5. [Pagination](#pagination)
6. [Error Codes](#error-codes)
7. [Bases](#bases)
8. [Tables](#tables)
9. [Records](#records)
10. [Fields](#fields)
11. [Views](#views)
12. [Webhooks](#webhooks)
13. [Field Model Reference](#field-model-reference)

---

## Overview

The Airtable Web API is a REST API that provides programmatic access to all Airtable bases your token has permission to access. The API supports reading, creating, updating, and deleting records across tables, as well as managing the schema (bases, tables, fields, views) and setting up real-time change notifications via webhooks.

**Two API surfaces:**
- **Records API** — CRUD operations on data within tables
- **Metadata API** — Read and modify schema (bases, tables, fields, views)

---

## Authentication

### Personal Access Tokens (Recommended)

Personal Access Tokens (PATs) are the standard authentication method. They are user-scoped tokens with explicitly defined permission scopes.

**Creating a PAT:**
1. Go to https://airtable.com/create/tokens
2. Give the token a name
3. Add scopes (permissions)
4. Add resource access (specific bases or all bases in a workspace)
5. Copy and store the token — it is shown only once

**Using a PAT:**
```http
Authorization: Bearer YOUR_PERSONAL_ACCESS_TOKEN
```

### OAuth 2.0 (For Third-Party Applications)

For apps that access other users' Airtable data. Follows standard OAuth 2.0 authorization code flow.

**Authorization URL:**
```
https://airtable.com/oauth2/v1/authorize
  ?client_id=YOUR_CLIENT_ID
  &redirect_uri=YOUR_REDIRECT_URI
  &response_type=code
  &scope=data.records:read data.records:write schema.bases:read
  &state=RANDOM_STATE_VALUE
  &code_challenge=CODE_CHALLENGE
  &code_challenge_method=S256
```

**Token exchange:**
```http
POST https://airtable.com/oauth2/v1/token

Content-Type: application/x-www-form-urlencoded
Authorization: Basic BASE64(client_id:client_secret)

grant_type=authorization_code
&code=AUTH_CODE
&redirect_uri=YOUR_REDIRECT_URI
&code_verifier=CODE_VERIFIER
```

**Response:**
```json
{
  "access_token": "...",
  "refresh_token": "...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_expires_in": 5184000,
  "scope": "data.records:read data.records:write schema.bases:read"
}
```

> OAuth access tokens expire after 1 hour. Refresh tokens expire after 60 days. Use the refresh token to get a new access token before expiry.

### Available OAuth Scopes

| Scope | Description |
|---|---|
| `data.records:read` | Read records in all accessible bases |
| `data.records:write` | Create, update, delete records |
| `data.recordComments:read` | Read record comments |
| `data.recordComments:write` | Create, update, delete record comments |
| `schema.bases:read` | Read base/table/field/view schema |
| `schema.bases:write` | Create and update bases, tables, and fields |
| `webhook:manage` | Create, list, and delete webhooks |
| `block.manage` | Manage interface/app configurations |
| `user.email:read` | Read the authenticated user's email |
| `workspacesAndBases.shares:manage` | Manage sharing settings |

---

## Base URL & Headers

```
Base URL: https://api.airtable.com/v0
Metadata Base URL: https://api.airtable.com/v0/meta
```

| Header | Required | Value |
|---|---|---|
| `Authorization` | Yes | `Bearer YOUR_PAT_OR_TOKEN` |
| `Content-Type` | Yes (POST/PATCH) | `application/json` |

---

## Rate Limits

| Authentication Type | Rate Limit |
|---|---|
| Personal Access Token (PAT) | 50 requests per second |
| OAuth connection | 5 requests per second per base |
| Legacy API key (deprecated) | 5 requests per second per base |

> The 5 req/s limit is per-base, not per-account. Multiple bases can be queried simultaneously within their own limits.

**When exceeded:** HTTP `429 Too Many Requests`

**Batch operations reduce calls:**
- Create up to **10 records** per request
- Update up to **10 records** per request (PATCH or PUT)
- Delete up to **10 records** per request
- This allows up to **500 record writes/second** with PATs using batch endpoints

**Retry strategy:**
```python
import time

def api_call_with_retry(func, max_retries=5):
    for attempt in range(max_retries):
        response = func()
        if response.status_code == 429:
            wait = 2 ** attempt  # Exponential backoff: 1, 2, 4, 8, 16 seconds
            time.sleep(wait)
            continue
        return response
    raise Exception("Max retries exceeded")
```

---

## Pagination

The Airtable API uses **offset-based pagination** for listing records.

| Parameter | Description |
|---|---|
| `pageSize` | Number of records per page. Default: 100. Max: 100. |
| `offset` | Opaque string from previous response. Pass to get next page. |

**Paginated response:**
```json
{
  "records": [ ... ],
  "offset": "itrM0DsRlFaEiZtKW/recXXXX"
}
```

If no `offset` field is present in the response, you have retrieved all records.

**Iteration pattern:**
```python
records = []
offset = None

while True:
    params = {"pageSize": 100}
    if offset:
        params["offset"] = offset

    response = requests.get(
        f"https://api.airtable.com/v0/{BASE_ID}/{TABLE_ID}",
        headers={"Authorization": f"Bearer {TOKEN}"},
        params=params
    )
    data = response.json()
    records.extend(data["records"])

    offset = data.get("offset")
    if not offset:
        break
```

---

## Error Codes

| HTTP Status | Description |
|---|---|
| `400 Bad Request` | Invalid parameters or malformed request body |
| `401 Unauthorized` | Missing or invalid token |
| `403 Forbidden` | Token lacks required scope or resource access |
| `404 Not Found` | Base, table, record, or field does not exist |
| `413 Request Entity Too Large` | Request body too large |
| `422 Unprocessable Entity` | Invalid field values (type mismatch, constraint violation) |
| `429 Too Many Requests` | Rate limit exceeded |
| `500 Internal Server Error` | Airtable server error — retry with backoff |
| `503 Service Unavailable` | Airtable is temporarily unavailable |

**Error response format:**
```json
{
  "error": {
    "type": "INVALID_PERMISSIONS_OR_MODEL_NOT_FOUND",
    "message": "Could not find what you are looking for"
  }
}
```

**Common error types:**

| Error Type | Meaning |
|---|---|
| `AUTHENTICATION_REQUIRED` | No token provided |
| `INVALID_PERMISSIONS_OR_MODEL_NOT_FOUND` | Token lacks permission or resource doesn't exist |
| `INVALID_REQUEST_UNKNOWN` | General invalid request |
| `INVALID_VALUE_FOR_COLUMN` | Value doesn't match field type |
| `UNKNOWN_FIELD_NAME` | Field name in request doesn't exist in table |
| `LIST_RECORDS_OFFSET_INVALID` | Stale or invalid pagination offset |
| `ROW_DOES_NOT_EXIST` | Record ID not found |

---

## Bases

### List Bases

```http
GET https://api.airtable.com/v0/meta/bases
```

**Query parameters:**
- `offset` — pagination offset

**Response:**
```json
{
  "bases": [
    {
      "id": "appXXXXXXXXXXXXXX",
      "name": "Project Tracker",
      "permissionLevel": "create"
    },
    {
      "id": "appYYYYYYYYYYYYYY",
      "name": "CRM",
      "permissionLevel": "editor"
    }
  ],
  "offset": "..."
}
```

**Permission levels:** `none`, `read`, `comment`, `editor`, `create`, `owner`

---

### Get Base Schema

Returns all tables, fields, and views for a base.

```http
GET https://api.airtable.com/v0/meta/bases/{baseId}/tables
```

**Response:**
```json
{
  "tables": [
    {
      "id": "tblXXXXXXXXXXXXXX",
      "name": "Tasks",
      "primaryFieldId": "fldXXXXXXXXXXXXXX",
      "fields": [
        { "id": "fldXXX", "name": "Name", "type": "singleLineText" },
        { "id": "fldYYY", "name": "Status", "type": "singleSelect",
          "options": { "choices": [
            { "id": "selA", "name": "Todo", "color": "grayLight2" },
            { "id": "selB", "name": "Done", "color": "greenLight2" }
          ]}
        },
        { "id": "fldZZZ", "name": "Due Date", "type": "date",
          "options": { "dateFormat": { "name": "iso", "format": "YYYY-MM-DD" } }
        }
      ],
      "views": [
        { "id": "viwXXX", "name": "Grid view", "type": "grid" }
      ]
    }
  ]
}
```

---

### Create a Base

```http
POST https://api.airtable.com/v0/meta/bases
```

**Request body:**
```json
{
  "name": "New Base",
  "workspaceId": "wspXXXXXXXXXXXXXX",
  "tables": [
    {
      "name": "Tasks",
      "fields": [
        { "name": "Name", "type": "singleLineText" },
        { "name": "Status", "type": "singleSelect",
          "options": { "choices": [
            { "name": "Todo", "color": "grayLight2" },
            { "name": "Done", "color": "greenLight2" }
          ]}
        }
      ]
    }
  ]
}
```

---

## Tables

### Create a Table

```http
POST https://api.airtable.com/v0/meta/bases/{baseId}/tables
```

```json
{
  "name": "Contacts",
  "description": "Company contacts",
  "fields": [
    { "name": "Name", "type": "singleLineText" },
    { "name": "Email", "type": "email" },
    { "name": "Company", "type": "singleLineText" },
    { "name": "Tags", "type": "multipleSelects",
      "options": { "choices": [
        { "name": "Prospect", "color": "blueLight2" },
        { "name": "Customer", "color": "greenLight2" }
      ]}
    }
  ]
}
```

---

### Update a Table

```http
PATCH https://api.airtable.com/v0/meta/bases/{baseId}/tables/{tableId}
```

```json
{
  "name": "Updated Table Name",
  "description": "Updated description"
}
```

> Tables cannot be deleted via the API.

---

## Records

Records are the rows in a table. Each record has a unique `id` (prefixed `rec`), a `createdTime` timestamp, and a `fields` object.

### List Records

```http
GET https://api.airtable.com/v0/{baseId}/{tableIdOrName}
```

**Query parameters:**

| Parameter | Type | Description |
|---|---|---|
| `fields[]` | array | Only return specified field names or IDs |
| `filterByFormula` | string | Airtable formula to filter records |
| `maxRecords` | integer | Maximum number of records total |
| `pageSize` | integer | Records per page (max 100) |
| `sort[]` | array | Sort objects with `field` and `direction` |
| `view` | string | View name or ID — returns only records in that view in view order |
| `cellFormat` | string | `"json"` (default) or `"string"` |
| `timeZone` | string | IANA timezone for date formatting |
| `userLocale` | string | Locale for string-formatted dates |
| `returnFieldsByFieldId` | boolean | Use field IDs instead of names in response |
| `recordMetadata[]` | array | `"commentCount"` to include comment counts |
| `offset` | string | Pagination cursor from previous response |

**Examples:**

```http
# Get all records, sorted by Name ascending
GET /v0/{baseId}/{tableId}?sort[0][field]=Name&sort[0][direction]=asc

# Get only specific fields
GET /v0/{baseId}/{tableId}?fields[]=Name&fields[]=Status&fields[]=Due+Date

# Filter by formula
GET /v0/{baseId}/{tableId}?filterByFormula=AND({Status}='In Progress',{Priority}='High')

# Filter records in a specific view
GET /v0/{baseId}/{tableId}?view=My+View+Name

# Get records with comment counts
GET /v0/{baseId}/{tableId}?recordMetadata[]=commentCount
```

**Response:**
```json
{
  "records": [
    {
      "id": "recXXXXXXXXXXXXXX",
      "createdTime": "2026-01-15T10:00:00.000Z",
      "fields": {
        "Name": "Build API integration",
        "Status": "In Progress",
        "Due Date": "2026-03-01",
        "Priority": "High",
        "Tags": ["Backend", "API"],
        "Assignee": [{ "id": "usrXXX", "email": "alex@example.com", "name": "Alexander Thompson" }]
      }
    }
  ],
  "offset": "itrM0DsRlFaEiZtKW/recXXXX"
}
```

---

### Get a Record

```http
GET https://api.airtable.com/v0/{baseId}/{tableIdOrName}/{recordId}
```

---

### Create Records

Create up to 10 records in a single request.

```http
POST https://api.airtable.com/v0/{baseId}/{tableIdOrName}
```

```json
{
  "records": [
    {
      "fields": {
        "Name": "Task One",
        "Status": "Todo",
        "Due Date": "2026-03-15",
        "Priority": 1,
        "Tags": ["Feature", "API"],
        "Assignee": [{ "id": "usrXXXXXXXXXXXXXX" }]
      }
    },
    {
      "fields": {
        "Name": "Task Two",
        "Status": "In Progress",
        "Due Date": "2026-03-20"
      }
    }
  ],
  "returnFieldsByFieldId": false
}
```

**Response:** Same structure as list records, with the created record objects.

---

### Update Records (PATCH — Partial Update)

Update specific fields on up to 10 records. Fields not included are left unchanged.

```http
PATCH https://api.airtable.com/v0/{baseId}/{tableIdOrName}
```

```json
{
  "records": [
    {
      "id": "recXXXXXXXXXXXXXX",
      "fields": {
        "Status": "Done",
        "Completed Date": "2026-02-27"
      }
    },
    {
      "id": "recYYYYYYYYYYYYYY",
      "fields": {
        "Priority": 2
      }
    }
  ]
}
```

---

### Replace Records (PUT — Full Replacement)

Replace all fields on records. Any fields not included are cleared.

```http
PUT https://api.airtable.com/v0/{baseId}/{tableIdOrName}
```

Same request structure as PATCH.

---

### Upsert Records

Find existing records by matching fields and update them, or create new ones if no match found.

```http
PATCH https://api.airtable.com/v0/{baseId}/{tableIdOrName}
```

```json
{
  "performUpsert": {
    "fieldsToMergeOn": ["Email"]
  },
  "records": [
    {
      "fields": {
        "Email": "alex@example.com",
        "Name": "Alexander Thompson",
        "Status": "Active"
      }
    }
  ]
}
```

**Response includes:**
```json
{
  "createdRecords": ["recNEW..."],
  "updatedRecords": ["recEXISTING..."],
  "records": [ ... ]
}
```

---

### Delete Records

Delete up to 10 records in a single request.

```http
DELETE https://api.airtable.com/v0/{baseId}/{tableIdOrName}
  ?records[]=recXXXXXXXXXXXXXX
  &records[]=recYYYYYYYYYYYYYY
```

**Response:**
```json
{
  "records": [
    { "id": "recXXXXXXXXXXXXXX", "deleted": true },
    { "id": "recYYYYYYYYYYYYYY", "deleted": true }
  ]
}
```

---

## Fields

### Create a Field

```http
POST https://api.airtable.com/v0/meta/bases/{baseId}/tables/{tableId}/fields
```

```json
{
  "name": "Priority",
  "type": "singleSelect",
  "description": "Task priority level",
  "options": {
    "choices": [
      { "name": "Low", "color": "grayLight2" },
      { "name": "Medium", "color": "yellowLight2" },
      { "name": "High", "color": "redLight2" }
    ]
  }
}
```

---

### Update a Field

```http
PATCH https://api.airtable.com/v0/meta/bases/{baseId}/tables/{tableId}/fields/{fieldId}
```

```json
{
  "name": "Updated Field Name",
  "description": "Updated description"
}
```

> Fields cannot be deleted via the API. The only changeable properties vary by field type.

---

## Views

### List Views

```http
GET https://api.airtable.com/v0/meta/bases/{baseId}/tables/{tableId}/views
```

**Response:**
```json
{
  "views": [
    { "id": "viwXXX", "name": "Grid view", "type": "grid" },
    { "id": "viwYYY", "name": "My Kanban", "type": "kanban" },
    { "id": "viwZZZ", "name": "Calendar", "type": "calendar" }
  ]
}
```

**View types:** `grid`, `gallery`, `kanban`, `calendar`, `gantt`, `form`

---

### Create a View

```http
POST https://api.airtable.com/v0/meta/bases/{baseId}/tables/{tableId}/views
```

```json
{
  "name": "My New View",
  "type": "grid"
}
```

---

### Delete a View

```http
DELETE https://api.airtable.com/v0/meta/bases/{baseId}/tables/{tableId}/views/{viewId}
```

---

## Webhooks

Webhooks notify your endpoint in real-time when data in a base changes. Airtable delivers payloads via HTTPS POST to your specified URL.

### Create a Webhook

```http
POST https://api.airtable.com/v0/bases/{baseId}/webhooks
```

```json
{
  "notificationUrl": "https://yourserver.com/airtable-webhook",
  "specification": {
    "options": {
      "filters": {
        "fromSources": ["client"],
        "dataTypes": ["tableData", "tableFields", "tableMetadata"],
        "recordChangeScope": "tblXXXXXXXXXXXXXX"
      }
    }
  }
}
```

**Filter options:**

| Filter | Values | Description |
|---|---|---|
| `fromSources` | `"client"`, `"publicApi"`, `"automation"`, `"system"` | Who triggered the change |
| `dataTypes` | `"tableData"`, `"tableFields"`, `"tableMetadata"`, `"viewData"` | What changed |
| `recordChangeScope` | Table ID | Limit to a specific table |

**Response:**
```json
{
  "id": "ach00000000XXXXXXX",
  "macSecretBase64": "BASE64_SECRET",
  "expirationTime": "2026-05-28T00:00:00.000Z",
  "cursorForNextPayload": 1
}
```

> Save `macSecretBase64` immediately — it is only returned once. Use it to validate incoming webhook payloads via HMAC-SHA256.

---

### List Webhooks

```http
GET https://api.airtable.com/v0/bases/{baseId}/webhooks
```

---

### Delete a Webhook

```http
DELETE https://api.airtable.com/v0/bases/{baseId}/webhooks/{webhookId}
```

---

### Refresh a Webhook

Webhooks expire after 7 days unless refreshed. Airtable will send a notification before expiry.

```http
POST https://api.airtable.com/v0/bases/{baseId}/webhooks/{webhookId}/refresh
```

---

### List Webhook Payloads

Retrieve stored payloads (useful if your endpoint was down).

```http
GET https://api.airtable.com/v0/bases/{baseId}/webhooks/{webhookId}/payloads
  ?cursor=1
```

**Webhook payload structure:**
```json
{
  "payloads": [
    {
      "timestamp": "2026-02-27T10:00:00.000Z",
      "baseTransactionNumber": 42,
      "actionMetadata": {
        "source": "client",
        "sourceMetadata": { "user": { "id": "usrXXX", "email": "alex@example.com", "name": "Alexander" } }
      },
      "changedTablesById": {
        "tblXXXXXXXXXXXXXX": {
          "changedFieldsById": {},
          "createdRecordsById": {},
          "changedRecordsById": {
            "recXXXXXXXXXXXXXX": {
              "current": {
                "cellValuesByFieldId": {
                  "fldXXX": "New Value",
                  "fldYYY": "Done"
                }
              },
              "previous": {
                "cellValuesByFieldId": {
                  "fldXXX": "Old Value",
                  "fldYYY": "In Progress"
                }
              }
            }
          },
          "destroyedRecordIds": []
        }
      }
    }
  ],
  "cursor": 2,
  "mightHaveMore": false
}
```

---

### Validating Webhook Payloads

```python
import hmac
import hashlib
import base64

def validate_webhook(mac_secret_base64: str, request_body: bytes, hmac_header: str) -> bool:
    secret = base64.b64decode(mac_secret_base64)
    expected_mac = hmac.new(secret, request_body, hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected_mac, hmac_header)
```

---

## Field Model Reference

### Simple Text & Number Fields

| Field Type | API Type String | Description | Read | Write |
|---|---|---|---|---|
| Single line text | `singleLineText` | Plain text, single line | Yes | Yes |
| Long text (rich) | `multilineText` | Multi-line, supports markdown | Yes | Yes |
| Number | `number` | Numeric value | Yes | Yes |
| Currency | `currency` | Number with currency symbol | Yes | Yes |
| Percent | `percent` | Number as percentage | Yes | Yes |
| Rating | `rating` | Star rating (1 to max) | Yes | Yes |
| Duration | `duration` | Time duration in seconds | Yes | Yes |
| Phone number | `phoneNumber` | Phone string | Yes | Yes |
| Email | `email` | Email string | Yes | Yes |
| URL | `url` | URL string | Yes | Yes |
| Checkbox | `checkbox` | Boolean | Yes | Yes |

### Date & Time Fields

| Field Type | API Type String | Cell Value Format |
|---|---|---|
| Date | `date` | `"YYYY-MM-DD"` |
| Date and time | `dateTime` | `"YYYY-MM-DDTHH:mm:ss.sssZ"` (ISO 8601) |
| Created time | `createdTime` | ISO 8601 — auto-set, read-only |
| Last modified time | `lastModifiedTime` | ISO 8601 — auto-set, read-only |

### Selection Fields

| Field Type | API Type String | Cell Value |
|---|---|---|
| Single select | `singleSelect` | String (option name) or `null` |
| Multiple select | `multipleSelects` | Array of strings |

**Select field options:**
```json
{
  "type": "singleSelect",
  "options": {
    "choices": [
      { "id": "selXXX", "name": "Option A", "color": "blueLight2" },
      { "id": "selYYY", "name": "Option B", "color": "greenLight2" }
    ]
  }
}
```

**Available colors:** `blueLight2`, `cyanLight2`, `tealLight2`, `greenLight2`, `yellowLight2`, `orangeLight2`, `redLight2`, `pinkLight2`, `purpleLight2`, `grayLight2`, `blue`, `cyan`, `teal`, `green`, `yellow`, `orange`, `red`, `pink`, `purple`, `gray`

### Relationship Fields

| Field Type | API Type String | Cell Value |
|---|---|---|
| Link to another record | `multipleRecordLinks` | Array of `{ "id": "recXXX" }` objects |
| Lookup | `multipleLookupValues` | Array of looked-up values — read-only |
| Count | `count` | Integer — read-only |
| Rollup | `rollup` | Computed value — read-only |

### User Fields

| Field Type | API Type String | Cell Value |
|---|---|---|
| Collaborator | `singleCollaborator` | `{ "id": "usrXXX", "email": "...", "name": "..." }` |
| Multiple collaborators | `multipleCollaborators` | Array of collaborator objects |
| Created by | `createdBy` | Collaborator object — auto-set, read-only |
| Last modified by | `lastModifiedBy` | Collaborator object — auto-set, read-only |

### Computed / Special Fields

| Field Type | API Type String | Writable | Notes |
|---|---|---|---|
| Formula | `formula` | No | Computed — read-only |
| Auto number | `autoNumber` | No | Auto-incrementing integer — read-only |
| Barcode | `barcode` | Yes | `{ "text": "...", "type": "..." }` |
| Button | `button` | No | UI-only — not writable via API |
| AI text | `aiText` | No | AI-generated — read-only |

### Attachment Field

| Field Type | API Type String | Description |
|---|---|---|
| Attachment | `multipleAttachments` | Files and images |

**Attachment cell value (read):**
```json
[
  {
    "id": "attXXXXXXXXXXXXXX",
    "url": "https://dl.airtable.com/...",
    "filename": "document.pdf",
    "size": 12345,
    "type": "application/pdf",
    "width": null,
    "height": null,
    "thumbnails": {
      "small": { "url": "...", "width": 36, "height": 36 },
      "large": { "url": "...", "width": 512, "height": 512 }
    }
  }
]
```

**Attachment cell value (write — by URL):**
```json
[
  {
    "url": "https://example.com/file.pdf",
    "filename": "document.pdf"
  }
]
```

> To add to existing attachments (not replace), include existing attachment objects alongside new ones. Writing only new objects replaces all current attachments.

---

## Complete Endpoint Reference

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/v0/meta/bases` | List all bases |
| `POST` | `/v0/meta/bases` | Create a base |
| `GET` | `/v0/meta/bases/{baseId}/tables` | Get base schema (tables, fields, views) |
| `POST` | `/v0/meta/bases/{baseId}/tables` | Create a table |
| `PATCH` | `/v0/meta/bases/{baseId}/tables/{tableId}` | Update a table |
| `POST` | `/v0/meta/bases/{baseId}/tables/{tableId}/fields` | Create a field |
| `PATCH` | `/v0/meta/bases/{baseId}/tables/{tableId}/fields/{fieldId}` | Update a field |
| `GET` | `/v0/meta/bases/{baseId}/tables/{tableId}/views` | List views |
| `POST` | `/v0/meta/bases/{baseId}/tables/{tableId}/views` | Create a view |
| `DELETE` | `/v0/meta/bases/{baseId}/tables/{tableId}/views/{viewId}` | Delete a view |
| `GET` | `/v0/{baseId}/{tableId}` | List records |
| `GET` | `/v0/{baseId}/{tableId}/{recordId}` | Get a record |
| `POST` | `/v0/{baseId}/{tableId}` | Create records (up to 10) |
| `PATCH` | `/v0/{baseId}/{tableId}` | Update records partially (up to 10) |
| `PUT` | `/v0/{baseId}/{tableId}` | Replace records fully (up to 10) |
| `DELETE` | `/v0/{baseId}/{tableId}?records[]=...` | Delete records (up to 10) |
| `GET` | `/v0/bases/{baseId}/webhooks` | List webhooks |
| `POST` | `/v0/bases/{baseId}/webhooks` | Create a webhook |
| `DELETE` | `/v0/bases/{baseId}/webhooks/{webhookId}` | Delete a webhook |
| `POST` | `/v0/bases/{baseId}/webhooks/{webhookId}/refresh` | Refresh webhook expiry |
| `GET` | `/v0/bases/{baseId}/webhooks/{webhookId}/payloads` | List webhook payloads |
