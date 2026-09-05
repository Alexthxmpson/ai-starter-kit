# HubSpot CRM API — Custom Objects, Advanced Features & Official SDKs

**Source**: developers.hubspot.com, github.com/HubSpot, npmjs.com/@hubspot/api-client, pypi.org/hubspot-api-client
**Date saved**: 2026-03-18
**Scope**: Custom Objects API, Python SDK (v12), Node.js SDK (v13.4), Import API, Lists API, CRM Extensions, Workflow Extensions, Batch Operations, Webhooks, Plan-based availability, Implementation patterns

---

## Table of Contents

1. [Custom Objects Overview](#1-custom-objects-overview)
2. [Creating a Custom Object Schema](#2-creating-a-custom-object-schema)
3. [Schema Definition: Full Reference](#3-schema-definition-full-reference)
4. [CRUD Operations on Custom Object Records](#4-crud-operations-on-custom-object-records)
5. [Custom Object Associations](#5-custom-object-associations)
6. [Custom Object Limitations by Plan](#6-custom-object-limitations-by-plan)
7. [Deleting Custom Object Schemas](#7-deleting-custom-object-schemas)
8. [Python SDK: hubspot-api-client](#8-python-sdk-hubspot-api-client)
9. [Node.js SDK: @hubspot/api-client](#9-nodejs-sdk-hubspotapi-client)
10. [Import API: Bulk Data Loading](#10-import-api-bulk-data-loading)
11. [Lists API (Segments)](#11-lists-api-segments)
12. [CRM Extensions: Timeline Events](#12-crm-extensions-timeline-events)
13. [CRM Extensions: Classic Cards & UI Extensions](#13-crm-extensions-classic-cards--ui-extensions)
14. [Workflow Extensions: Custom Actions](#14-workflow-extensions-custom-actions)
15. [Batch Operations](#15-batch-operations)
16. [Archiving vs Hard Delete](#16-archiving-vs-hard-delete)
17. [Webhooks API](#17-webhooks-api)
18. [Plan-Based Feature Availability](#18-plan-based-feature-availability)
19. [Rate Limits Reference](#19-rate-limits-reference)
20. [Implementation Recommendations for AI Agents](#20-implementation-recommendations-for-ai-agents)
21. [Error Codes Reference](#21-error-codes-reference)
22. [Common Gotchas and Pitfalls](#22-common-gotchas-and-pitfalls)

---

## 1. Custom Objects Overview

HubSpot's standard CRM objects — Contacts, Companies, Deals, Tickets, Products, Line Items, Quotes — cover most use cases. When your data model doesn't fit these buckets, **custom objects** let you define entirely new record types with custom properties and associations to any standard or other custom object.

**Examples of custom objects used in production:**
- A car dealership tracking `Car` records associated to contact buyer records
- A SaaS company tracking `Subscription` records tied to companies
- A law firm managing `Legal Case` records linked to contacts and deals
- An event company tracking `Attendee` records per event

Custom objects are **account-specific** — they are not shared between HubSpot portals. They require at least one Enterprise-tier hub (Marketing, Sales, Service, CMS, Operations, Commerce, or CRM Hub Enterprise).

**Required OAuth/Private App scopes:**
- `crm.schemas.custom.read` — read custom object schemas
- `crm.schemas.custom.write` — create/update/delete schemas
- `crm.objects.custom.read` — read custom object records
- `crm.objects.custom.write` — create/update/delete records

The schema API endpoint base is: `https://api.hubapi.com/crm-object-schemas/v3/schemas`
The records API uses the standard objects pattern: `https://api.hubapi.com/crm/v3/objects/{objectType}`

---

## 2. Creating a Custom Object Schema

To create a custom object, first `POST` to define its schema. The schema determines the object's name, display properties, searchable properties, and property definitions.

**Endpoint:**
```
POST https://api.hubapi.com/crm-object-schemas/v3/schemas
```

**Authentication header:**
```
Authorization: Bearer {your_access_token}
Content-Type: application/json
```

**Minimal valid request body:**
```json
{
  "name": "cars",
  "labels": {
    "singular": "Car",
    "plural": "Cars"
  },
  "primaryDisplayProperty": "car_name",
  "secondaryDisplayProperties": ["make", "model"],
  "searchableProperties": ["car_name", "vin"],
  "requiredProperties": ["car_name"],
  "properties": [
    {
      "name": "car_name",
      "label": "Car Name",
      "type": "string",
      "fieldType": "text"
    },
    {
      "name": "make",
      "label": "Make",
      "type": "string",
      "fieldType": "text"
    },
    {
      "name": "model",
      "label": "Model",
      "type": "string",
      "fieldType": "text"
    },
    {
      "name": "vin",
      "label": "VIN",
      "type": "string",
      "fieldType": "text"
    },
    {
      "name": "year",
      "label": "Year",
      "type": "number",
      "fieldType": "number"
    },
    {
      "name": "condition",
      "label": "Condition",
      "type": "enumeration",
      "fieldType": "select",
      "options": [
        {"label": "New", "value": "new", "displayOrder": 1, "hidden": false},
        {"label": "Used", "value": "used", "displayOrder": 2, "hidden": false}
      ]
    }
  ],
  "associatedObjects": ["CONTACT", "DEAL"]
}
```

**Successful response (HTTP 201):**
```json
{
  "id": "2-3456789",
  "name": "cars",
  "labels": {
    "singular": "Car",
    "plural": "Cars"
  },
  "primaryDisplayProperty": "car_name",
  "secondaryDisplayProperties": ["make", "model"],
  "searchableProperties": ["car_name", "vin"],
  "requiredProperties": ["car_name", "hs_object_id"],
  "properties": [...],
  "associations": [...],
  "objectTypeId": "2-3456789",
  "fullyQualifiedName": "p_cars",
  "createdAt": "2026-03-18T10:00:00.000Z",
  "updatedAt": "2026-03-18T10:00:00.000Z"
}
```

The `objectTypeId` returned (e.g., `2-3456789`) becomes the identifier for all subsequent API calls on this object type. The prefix `2-` indicates a custom object (standard objects use `0-1` for contacts, `0-2` for companies, etc.).

---

## 3. Schema Definition: Full Reference

### Naming Rules
- The first character of `name` must be a letter
- Only letters, numbers, and underscores are allowed in `name`
- **The name and label cannot be changed after creation** — choose carefully
- Long labels may be cut off in certain HubSpot UI areas
- `name` is used internally (API); `labels.singular` / `labels.plural` are user-facing

### System-Managed Properties
HubSpot automatically adds these properties to every custom object — you do not define them:
- `hs_object_id` — unique numeric ID for each record
- `hs_createdate` (alias: `createdate`) — timestamp when the record was created
- `hs_lastmodifieddate` (alias: `lastmodifieddate`) — timestamp of last update
- `hs_pipeline` — applicable if the object has pipeline support
- `hs_pipeline_stage` — current pipeline stage

### Property Type Reference
| `type` value | `fieldType` values | Notes |
|---|---|---|
| `string` | `text`, `textarea`, `html`, `file`, `phonenumber` | Stores text |
| `number` | `number` | Numeric values |
| `date` | `date` | Date only (YYYY-MM-DD) |
| `datetime` | `date` | Date + time (Unix ms) |
| `enumeration` | `select`, `radio`, `checkbox`, `booleancheckbox` | Requires `options` array |
| `bool` | `booleancheckbox` | True/false |

### Display Property Fields
- `primaryDisplayProperty` — the property shown as the record's "name" in the HubSpot UI and list views. Commonly a name field.
- `secondaryDisplayProperties` — array of property names shown beneath the primary on the record card. Max 2 properties.
- `searchableProperties` — properties indexed for full-text search in HubSpot's CRM search. Max 20.
- `requiredProperties` — properties that must have a value on every record.

### Unique Value Properties
Each custom object can have up to **10 unique value properties**. A unique value property enforces that no two records have the same value for that field (similar to a database UNIQUE constraint).

To mark a property as unique, include `"hasUniqueValue": true` in the property definition:
```json
{
  "name": "vin",
  "label": "VIN",
  "type": "string",
  "fieldType": "text",
  "hasUniqueValue": true
}
```

### Association Definitions in Schema
The `associatedObjects` field in the schema request sets up default association types between your custom object and other objects. Valid values include standard object type names (`CONTACT`, `COMPANY`, `DEAL`, `TICKET`, `PRODUCT`) or other custom object type IDs.

Associations defined at schema creation time are created as MANY_TO_MANY by default. As of early 2025, cardinality rules (one-to-many, one-to-one) cannot be set programmatically via the schema API — they must be configured in the HubSpot UI. This is a known limitation confirmed by HubSpot developer forum moderators.

---

## 4. CRUD Operations on Custom Object Records

Once the schema is created, use the standard CRM objects API pattern with your `objectTypeId` or `name`:

### Create a Record
```
POST https://api.hubapi.com/crm/v3/objects/{objectType}
```
```json
{
  "properties": {
    "car_name": "2024 Tesla Model S",
    "make": "Tesla",
    "model": "Model S",
    "vin": "5YJSA1E27MF123456",
    "year": "2024",
    "condition": "new"
  },
  "associations": [
    {
      "to": {"id": "1234"},
      "types": [{"associationCategory": "HUBSPOT_DEFINED", "associationTypeId": 1}]
    }
  ]
}
```

### Read Records
```
GET https://api.hubapi.com/crm/v3/objects/{objectType}
GET https://api.hubapi.com/crm/v3/objects/{objectType}/{recordId}
```

Optional query params for GET:
- `properties` — comma-separated list of properties to return
- `propertiesWithHistory` — return property value history
- `associations` — comma-separated list of object types to include associations for
- `archived` — `true` to include archived records

Example with property selection:
```
GET /crm/v3/objects/cars/12345?properties=car_name,make,model,vin
```

### Update a Record
```
PATCH https://api.hubapi.com/crm/v3/objects/{objectType}/{recordId}
```
```json
{
  "properties": {
    "condition": "used",
    "year": "2023"
  }
}
```

### Delete (Archive) a Record
```
DELETE https://api.hubapi.com/crm/v3/objects/{objectType}/{recordId}
```
This performs a soft delete (archive). Records can be restored within 90 days.

### Search Custom Object Records
```
POST https://api.hubapi.com/crm/v3/objects/{objectType}/search
```
```json
{
  "filterGroups": [
    {
      "filters": [
        {
          "propertyName": "make",
          "operator": "EQ",
          "value": "Tesla"
        }
      ]
    }
  ],
  "properties": ["car_name", "make", "model", "vin"],
  "sorts": [{"propertyName": "car_name", "direction": "ASCENDING"}],
  "limit": 100,
  "after": 0
}
```

**Search filter operators:**
- `EQ` — equals
- `NEQ` — not equals
- `LT`, `LTE`, `GT`, `GTE` — numeric/date comparisons
- `BETWEEN` — range (requires `highValue` and `value`)
- `IN` — value in list (requires `values` array)
- `NOT_IN` — not in list
- `HAS_PROPERTY` — field exists and is not empty
- `NOT_HAS_PROPERTY` — field is empty
- `CONTAINS_TOKEN` — partial match (string search)
- `NOT_CONTAINS_TOKEN` — does not contain

**Important search limits:**
- Max 10,000 records returned from search (use `after` cursor for pagination)
- Search API is rate-limited more aggressively: max 4 requests/second (separate from main rate limit)
- If you need to paginate beyond 10,000, use the `GET /crm/v3/objects/{type}` list endpoint with `limit` and `after` instead

---

## 5. Custom Object Associations

HubSpot's Associations v4 API (the current standard) defines typed, labeled associations between any two object types.

### Creating an Association Between Records
```
PUT https://api.hubapi.com/crm/v4/objects/{fromObjectType}/{fromObjectId}/associations/{toObjectType}/{toObjectId}
```
Request body defines the association type:
```json
[
  {
    "associationCategory": "HUBSPOT_DEFINED",
    "associationTypeId": 1
  }
]
```

For custom object associations, use `"associationCategory": "USER_DEFINED"` with the association type ID returned when you created the schema.

### Listing Associations for a Record
```
GET https://api.hubapi.com/crm/v4/objects/{fromObjectType}/{fromObjectId}/associations/{toObjectType}
```

### Batch Read Associations (Python SDK)
```python
from hubspot.crm.associations import BatchInputPublicObjectId

batch_ids = BatchInputPublicObjectId(
    inputs=[{'id': c.id} for c in contacts]
)
associations = api_client.crm.associations.batch_api.read(
    from_object_type="contact",
    to_object_type="cars",
    batch_input_public_object_id=batch_ids
)
```

### Association Label Limits
- Maximum 100 association label types per object pair
- All programmatically-created associations default to MANY_TO_MANY cardinality
- ONE_TO_MANY and ONE_TO_ONE cardinality require UI configuration (API limitation as of 2025)

---

## 6. Custom Object Limitations by Plan

Custom objects require Enterprise-tier access. The exact number of custom objects you can create depends on which Enterprise hub you have:

| Hub | Required Tier | Custom Objects Allowed |
|---|---|---|
| Marketing Hub | Enterprise | Up to 10 custom objects |
| Sales Hub | Enterprise | Up to 10 custom objects |
| Service Hub | Enterprise | Up to 10 custom objects |
| CMS Hub | Enterprise | Up to 10 custom objects |
| Operations Hub | Enterprise | Up to 10 custom objects |
| CRM Hub | Enterprise | Up to 10 custom objects |

**Per-custom-object limits:**
- Up to 1,000 properties per custom object
- Up to 10 unique value properties per custom object
- Up to 20 searchable properties
- Max 2 secondary display properties
- Association label cardinality: MANY_TO_MANY only via API; ONE_TO_MANY and ONE_TO_ONE via UI only

**Critical constraint:** Once you create an object schema, the `name` field is permanent and cannot be changed. Plan naming conventions before creating objects.

**Record limits:**
- Custom object records are subject to the same general CRM record limits as standard objects
- Deleted (archived) records count against limits until permanently purged (after 90-day recovery window)

---

## 7. Deleting Custom Object Schemas

To delete an entire custom object schema (including all its records), use:
```
DELETE https://api.hubapi.com/crm-object-schemas/v3/schemas/{objectType}
```

**Before deleting a schema:**
1. All records of that object type must be deleted first (archive them, then they expire after 90 days, or use the GDPR hard-delete endpoint)
2. All associations to/from that object type should be removed
3. Any workflows or lists referencing the custom object must be updated or deleted

This is a destructive, irreversible operation. There is no recovery after schema deletion. Deleting a schema does not immediately purge the records — they follow the 90-day archival window.

You can also **update** a schema (add new properties, change display labels) via:
```
PATCH https://api.hubapi.com/crm-object-schemas/v3/schemas/{objectType}
```
This supports modifying `labels`, `primaryDisplayProperty`, `secondaryDisplayProperties`, `requiredProperties`, and `searchableProperties`. You cannot rename the object `name` field.

To add a new property to an existing schema:
```
POST https://api.hubapi.com/crm-object-schemas/v3/schemas/{objectType}/properties
```

---

## 8. Python SDK: hubspot-api-client

### Installation & Version
```bash
pip install --upgrade hubspot-api-client
```
- Current version: **v12.0.0** (released May 2025)
- Requires Python 3.7+
- GitHub: `HubSpot/hubspot-api-python` (413 stars, Apache 2.0 license)
- The legacy `hapikey` (API key) authentication was removed in v5.1.0 — use Private App access tokens or OAuth only

### Initialization
```python
from hubspot import HubSpot

# Method 1: direct init
api_client = HubSpot(access_token='pat-na1-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx')

# Method 2: set token after init
api_client = HubSpot()
api_client.access_token = 'pat-na1-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
```

### Available API Client Namespaces
The SDK organizes all API clients under `api_client.*` namespaces:

| Namespace | Object Type |
|---|---|
| `api_client.crm.contacts` | Contacts CRUD, search, batch |
| `api_client.crm.companies` | Companies CRUD, search, batch |
| `api_client.crm.deals` | Deals CRUD, search, batch |
| `api_client.crm.tickets` | Tickets CRUD, search, batch |
| `api_client.crm.objects` | Generic objects (custom objects use this) |
| `api_client.crm.schemas` | Custom object schema CRUD |
| `api_client.crm.associations` | Association read/write |
| `api_client.crm.associations.v4` | Associations v4 (latest) |
| `api_client.crm.properties` | Property definitions |
| `api_client.crm.imports` | Import jobs |
| `api_client.crm.exports` | Export jobs |
| `api_client.crm.lists` | Lists / segments |
| `api_client.oauth` | OAuth token management |
| `api_client.webhooks` | Webhook subscription management |
| `api_client.automation` | Workflow management |
| `api_client.marketing.emails` | Marketing emails |
| `api_client.marketing.events` | Marketing events |
| `api_client.cms.blogs` | Blog post management |

### CRM Operations: Contacts

**Create a contact:**
```python
from hubspot.crm.contacts import SimplePublicObjectInputForCreate
from hubspot.crm.contacts.exceptions import ApiException

try:
    contact_input = SimplePublicObjectInputForCreate(
        properties={
            "email": "john.doe@example.com",
            "firstname": "John",
            "lastname": "Doe",
            "phone": "+31612345678",
            "company": "Acme Corp"
        }
    )
    response = api_client.crm.contacts.basic_api.create(
        simple_public_object_input_for_create=contact_input
    )
    contact_id = response.id
    print(f"Created contact ID: {contact_id}")
except ApiException as e:
    print(f"Error creating contact: {e.status} {e.reason} {e.body}")
```

**Get a contact by ID:**
```python
from hubspot.crm.contacts.exceptions import ApiException

try:
    contact = api_client.crm.contacts.basic_api.get_by_id(
        contact_id='12345',
        properties=['email', 'firstname', 'lastname', 'phone']
    )
    print(contact.properties)
except ApiException as e:
    print(f"Contact not found: {e}")
```

**Search contacts:**
```python
from hubspot.crm.contacts import PublicObjectSearchRequest, Filter, FilterGroup

search_request = PublicObjectSearchRequest(
    filter_groups=[
        FilterGroup(filters=[
            Filter(
                property_name='email',
                operator='CONTAINS_TOKEN',
                value='@example.com'
            )
        ])
    ],
    properties=['email', 'firstname', 'lastname'],
    limit=100
)

results = api_client.crm.contacts.search_api.do_search(
    public_object_search_request=search_request
)
for contact in results.results:
    print(contact.id, contact.properties.get('email'))
```

### CRM Operations: Deals

**Create a deal:**
```python
from hubspot.crm.deals import SimplePublicObjectInputForCreate
from hubspot.crm.deals.exceptions import ApiException

try:
    deal_input = SimplePublicObjectInputForCreate(
        properties={
            "dealname": "New Enterprise License",
            "amount": "50000",
            "dealstage": "appointmentscheduled",
            "pipeline": "default",
            "closedate": "1735689600000"  # Unix ms
        }
    )
    response = api_client.crm.deals.basic_api.create(
        simple_public_object_input_for_create=deal_input
    )
    print(f"Deal created: {response.id}")
except ApiException as e:
    print(f"Error: {e}")
```

**List all deals (paginated):**
```python
all_deals = []
after = None

while True:
    page = api_client.crm.deals.basic_api.get_page(
        limit=100,
        after=after,
        properties=['dealname', 'amount', 'dealstage', 'closedate']
    )
    all_deals.extend(page.results)
    if not page.paging or not page.paging.next:
        break
    after = page.paging.next.after

print(f"Total deals: {len(all_deals)}")
```

### CRM Operations: Custom Objects

**Create a custom object schema:**
```python
from hubspot.crm.schemas import ObjectSchemaEgg, ObjectTypePropertyCreate, AssociationDefinitionEgg
from hubspot.crm.schemas.exceptions import ApiException

try:
    schema = ObjectSchemaEgg(
        name="cars",
        labels={"singular": "Car", "plural": "Cars"},
        primary_display_property="car_name",
        secondary_display_properties=["make", "model"],
        searchable_properties=["car_name", "vin"],
        required_properties=["car_name"],
        properties=[
            ObjectTypePropertyCreate(
                name="car_name",
                label="Car Name",
                type="string",
                field_type="text"
            ),
            ObjectTypePropertyCreate(
                name="vin",
                label="VIN",
                type="string",
                field_type="text",
                has_unique_value=True
            ),
            ObjectTypePropertyCreate(
                name="year",
                label="Year",
                type="number",
                field_type="number"
            )
        ],
        associated_objects=["CONTACT"]
    )
    result = api_client.crm.schemas.core_api.create(object_schema_egg=schema)
    print(f"Schema created. Object type ID: {result.object_type_id}")
except ApiException as e:
    print(f"Schema creation failed: {e}")
```

**Get custom object records:**
```python
from hubspot.crm.objects import ApiException

try:
    page = api_client.crm.objects.basic_api.get_page(
        object_type="cars",
        limit=100,
        properties=["car_name", "make", "model", "vin"]
    )
    for record in page.results:
        print(record.id, record.properties)
except ApiException as e:
    print(f"Error: {e}")
```

### Error Handling Patterns
The SDK raises `ApiException` with structured attributes:
```python
from hubspot.crm.contacts.exceptions import ApiException

try:
    result = api_client.crm.contacts.basic_api.get_by_id('nonexistent')
except ApiException as e:
    print(f"Status: {e.status}")      # HTTP status code (e.g., 404)
    print(f"Reason: {e.reason}")      # HTTP reason phrase
    print(f"Body: {e.body}")          # Raw response body (JSON string)
    # Parse body for detailed error info:
    import json
    error_detail = json.loads(e.body)
    print(f"Message: {error_detail.get('message')}")
    print(f"Category: {error_detail.get('category')}")
```

### Async Requests
Every SDK method supports `async_req=True` for non-blocking calls:
```python
thread = api_client.crm.contacts.basic_api.get_by_id('12345', async_req=True)
# Do other work...
result = thread.get()  # blocks until complete
```

### OAuth Token Refresh in Python SDK
```python
from hubspot.oauth import ApiException as OAuthException

try:
    tokens = api_client.oauth.tokens_api.create(
        grant_type="authorization_code",
        redirect_uri='https://yourapp.com/callback',
        client_id='your_client_id',
        client_secret='your_client_secret',
        code='authorization_code_from_redirect'
    )
    api_client.access_token = tokens.access_token
except OAuthException as e:
    print(f"OAuth error: {e}")
```

---

## 9. Node.js SDK: @hubspot/api-client

### Installation
```bash
npm install @hubspot/api-client
```
- Current version: **v13.4.0** (September 2025)
- 707K weekly downloads, 130 dependents
- GitHub: `HubSpot/hubspot-api-nodejs`
- License: ISC

### Initialization (CommonJS)
```javascript
const hubspot = require('@hubspot/api-client')

const hubspotClient = new hubspot.Client({
  accessToken: process.env.HUBSPOT_ACCESS_TOKEN
})
```

### Initialization (ES Modules / TypeScript)
```javascript
import { Client } from "@hubspot/api-client";

const hubspotClient = new Client({
  accessToken: process.env.HUBSPOT_ACCESS_TOKEN
});
```

### Extended Client Options
```javascript
const hubspotClient = new hubspot.Client({
  accessToken: YOUR_ACCESS_TOKEN,

  // Add custom headers to every request
  defaultHeaders: { 'X-Custom-Header': 'my-value' },

  // Override base URL (e.g., for testing)
  basePath: 'https://api.hubapi.com',

  // Rate limiting via Bottleneck
  limiterOptions: {
    minTime: 1000 / 9,     // ~111ms between requests
    maxConcurrent: 6,       // max 6 parallel requests
    id: 'hubspot-client-limiter'
  },

  // Automatic retry on 429/5xx
  numberOfApiCallRetries: 3
})
```

### Rate Limiting (Built-in via Bottleneck)
The Node.js SDK uses the `bottleneck` library to automatically rate-limit requests. Default settings throttle to ~9 req/sec with max 6 concurrent. Search endpoints get a separate stricter limiter:

```javascript
const SEARCH_LIMITER_OPTIONS = {
  minTime: 550,        // ~1.8 req/sec for search
  maxConcurrent: 3,
  id: 'search-hubspot-client-limiter'
}
```

To disable rate limiting (not recommended for production):
```javascript
const hubspotClient = new hubspot.Client({
  accessToken: YOUR_ACCESS_TOKEN,
  limiterOptions: undefined   // disables limiter
})
```

### Node.js: Contacts Operations

**Create contact:**
```javascript
try {
  const contactObj = {
    properties: {
      email: 'jane.doe@example.com',
      firstname: 'Jane',
      lastname: 'Doe',
      phone: '+31687654321'
    }
  }
  const response = await hubspotClient.crm.contacts.basicApi.create(contactObj)
  console.log(`Created contact ID: ${response.id}`)
} catch (e) {
  console.error('HubSpot error:', e.message, e.statusCode)
}
```

**Get contact with associations:**
```javascript
const contact = await hubspotClient.crm.contacts.basicApi.getById(
  '12345',
  ['email', 'firstname', 'lastname'],   // properties
  undefined,                             // propertiesWithHistory
  ['companies', 'deals']               // associations to include
)
console.log(contact.associations)
```

**Batch create contacts:**
```javascript
const batchInput = {
  inputs: [
    { properties: { email: 'a@test.com', firstname: 'Alice' } },
    { properties: { email: 'b@test.com', firstname: 'Bob' } },
    { properties: { email: 'c@test.com', firstname: 'Carol' } }
  ]
}
const result = await hubspotClient.crm.contacts.batchApi.create(batchInput)
console.log(`Created ${result.results.length} contacts`)
```

### Node.js: OAuth Flow
```javascript
// Step 1: Get authorization URL
const authUrl = hubspotClient.oauth.getAuthorizationUrl(
  clientId,
  redirectUri,
  'crm.objects.contacts.read crm.objects.contacts.write'
)

// Step 2: Exchange code for tokens
const tokensResponse = await hubspotClient.oauth.tokensApi.create(
  'authorization_code',
  undefined,
  redirectUri,
  clientId,
  clientSecret,
  authCode
)

// Step 3: Set token and refresh when expired
hubspotClient.setAccessToken(tokensResponse.accessToken)

// Token refresh
const refreshed = await hubspotClient.oauth.tokensApi.create(
  'refresh_token',
  undefined,
  undefined,
  clientId,
  clientSecret,
  refreshToken
)
hubspotClient.setAccessToken(refreshed.accessToken)
```

### Node.js: Custom Objects
```javascript
// Create a custom object record
const customRecord = await hubspotClient.crm.objects.basicApi.create(
  'cars',   // objectType (name or objectTypeId)
  {
    properties: {
      car_name: '2024 BMW M3',
      make: 'BMW',
      model: 'M3',
      vin: 'WBS43AY05RFP12345',
      year: '2024',
      condition: 'new'
    }
  }
)
console.log(`Record ID: ${customRecord.id}`)

// Search custom objects
const searchResult = await hubspotClient.crm.objects.searchApi.doSearch(
  'cars',
  {
    filterGroups: [{
      filters: [{
        propertyName: 'make',
        operator: 'EQ',
        value: 'BMW'
      }]
    }],
    properties: ['car_name', 'make', 'model'],
    limit: 50
  }
)
```

---

## 10. Import API: Bulk Data Loading

The Import API allows batch loading of CRM records from CSV or XLSX files. This is the preferred mechanism for initial data migrations of large datasets (tens of thousands to millions of records).

**Key limits:**
- Single import file: max 1,048,576 rows or 512 MB
- File formats: CSV or Excel (XLSX/XLS)

### Start an Import
```
POST https://api.hubapi.com/crm/v3/imports
Content-Type: multipart/form-data
```

This is a **multipart/form-data** request (not JSON). Two fields are required:
- `files` — the actual file content
- `importRequest` — a JSON string describing the import mapping

**importRequest JSON structure:**
```json
{
  "name": "March 2026 Contact Import",
  "importOperations": {
    "0-1": "UPSERT"
  },
  "dateFormat": "DAY_MONTH_YEAR",
  "marketableContactImport": false,
  "createContactListFromImport": true,
  "files": [
    {
      "fileName": "contacts_march_2026.csv",
      "fileFormat": "CSV",
      "fileImportPage": {
        "hasHeader": true,
        "columnMappings": [
          {
            "columnObjectTypeId": "0-1",
            "columnName": "Email",
            "propertyName": "email",
            "idColumnType": "EMAIL"
          },
          {
            "columnObjectTypeId": "0-1",
            "columnName": "First Name",
            "propertyName": "firstname"
          },
          {
            "columnObjectTypeId": "0-1",
            "columnName": "Last Name",
            "propertyName": "lastname"
          },
          {
            "columnObjectTypeId": "0-1",
            "columnName": "Company",
            "propertyName": "company"
          }
        ]
      }
    }
  ]
}
```

### Object Type IDs for Import
| Object | objectTypeId |
|---|---|
| Contacts | `0-1` |
| Companies | `0-2` |
| Deals | `0-3` |
| Tickets | `0-5` |
| Products | `0-7` |
| Line Items | `0-8` |
| Custom Object | `2-{your_id}` |

### Import Operations
- `CREATE` — only create new records, skip if already exists
- `UPDATE` — only update existing records, skip if not found
- `UPSERT` — create if not found, update if found (uses `idColumnType` to match)

### ID Column Types (for matching existing records)
- `EMAIL` — match contacts by email
- `HUBSPOT_OBJECT_ID` — match by HubSpot record ID
- `UNIQUE_PROPERTY` — match by a unique custom property value

### Checking Import Status
Imports run asynchronously. Poll the status endpoint:
```
GET https://api.hubapi.com/crm/v3/imports/{importId}
```

**Response states:**
- `STARTED` — import queued
- `PROCESSING` — actively importing rows
- `DONE` — import complete
- `FAILED` — import failed (check `errors` array)
- `CANCELED` — manually canceled

**Response metadata example:**
```json
{
  "id": "29801094",
  "state": "DONE",
  "importName": "March 2026 Contact Import",
  "createdAt": "2026-03-18T10:00:00.000Z",
  "updatedAt": "2026-03-18T10:05:00.000Z",
  "metadata": {
    "objectLists": [{"listId": 331, "objectType": "0-1"}],
    "counters": {
      "TOTAL_ROWS": 5000,
      "PROPERTY_VALUES_EMITTED": 20000,
      "CREATED_OBJECTS": 4950,
      "UPDATED_OBJECTS": 50,
      "UNIQUE_OBJECTS_WRITTEN": 5000,
      "MAPPED_COLUMNS": 4,
      "ERRORS": 0
    },
    "fileIds": ["90375898510"]
  }
}
```

### Cancel an Import
```
POST https://api.hubapi.com/crm/v3/imports/{importId}/cancel
```

### List All Imports
```
GET https://api.hubapi.com/crm/v3/imports
```

### Python SDK Import Example
```python
import requests

url = "https://api.hubapi.com/crm/v3/imports"
headers = {"Authorization": f"Bearer {access_token}"}

import_request = {
    "name": "Q1 Contacts",
    "importOperations": {"0-1": "UPSERT"},
    "dateFormat": "YEAR_MONTH_DAY",
    "files": [{
        "fileName": "q1_contacts.csv",
        "fileFormat": "CSV",
        "fileImportPage": {
            "hasHeader": True,
            "columnMappings": [
                {"columnObjectTypeId": "0-1", "columnName": "email",
                 "propertyName": "email", "idColumnType": "EMAIL"},
                {"columnObjectTypeId": "0-1", "columnName": "first_name",
                 "propertyName": "firstname"},
                {"columnObjectTypeId": "0-1", "columnName": "last_name",
                 "propertyName": "lastname"}
            ]
        }
    }]
}

with open("q1_contacts.csv", "rb") as f:
    files = {"files": ("q1_contacts.csv", f, "text/csv")}
    data = {"importRequest": json.dumps(import_request)}
    response = requests.post(url, headers=headers, files=files, data=data)

import_id = response.json()["id"]

# Poll for completion
import time
while True:
    status_resp = requests.get(
        f"https://api.hubapi.com/crm/v3/imports/{import_id}",
        headers=headers
    )
    state = status_resp.json()["state"]
    if state in ("DONE", "FAILED", "CANCELED"):
        print(f"Import {state}: {status_resp.json()['metadata']['counters']}")
        break
    time.sleep(5)
```

---

## 11. Lists API (Segments)

HubSpot's Lists API (v3) manages collections of CRM records for segmentation, filtering, and bulk actions. As of 2026, HubSpot calls these "segments" in the UI but the API still uses "lists."

**Important:** The legacy v1 Lists API is sunset on **April 30, 2026**. All integrations must migrate to v3.

**Base endpoint:** `https://api.hubapi.com/crm/v3/lists`

### List Processing Types
| Type | Behavior | Use Case |
|---|---|---|
| `MANUAL` | Membership managed only by API or UI actions | Fixed sets (e.g., VIP customers) |
| `DYNAMIC` | Auto-updated as records match/unmatch filter criteria | Active segments (e.g., all contacts in Germany) |
| `SNAPSHOT` | Filters applied at creation; afterward membership is static | Point-in-time snapshots |

### Create a List
```
POST https://api.hubapi.com/crm/v3/lists
```
```json
{
  "name": "German Enterprise Contacts",
  "objectTypeId": "0-1",
  "processingType": "DYNAMIC",
  "filterBranch": {
    "filterBranchType": "AND",
    "filters": [
      {
        "filterType": "PROPERTY",
        "property": "country",
        "operation": {
          "operationType": "MULTISTRING",
          "operator": "IS_EQUAL_TO",
          "values": ["Germany"]
        }
      },
      {
        "filterType": "PROPERTY",
        "property": "jobtitle",
        "operation": {
          "operationType": "MULTISTRING",
          "operator": "CONTAINS",
          "values": ["CTO", "VP", "Director"]
        }
      }
    ],
    "filterBranches": []
  }
}
```

**Response includes:**
- `listId` — the v3 list ID (use this for all v3 API calls)
- `legacyListId` — the old v1 ID

### Create a Manual (Static) List
```json
{
  "name": "Tradeshow Leads March 2026",
  "objectTypeId": "0-1",
  "processingType": "MANUAL"
}
```

### Add/Remove Members from Manual List
```
PUT https://api.hubapi.com/crm/v3/lists/{listId}/memberships/add
```
```json
{
  "recordIdsToAdd": ["101", "102", "103"],
  "recordIdsToRemove": []
}
```

### Get List Members
```
GET https://api.hubapi.com/crm/v3/lists/{listId}/memberships
```

### Convert Dynamic to Static
```
POST https://api.hubapi.com/crm/v3/lists/{listId}/convert-to-static
```
This "freezes" the list at its current membership. Useful for audit trails.

### ID Mapping (v1 to v3 Migration)
```
GET https://api.hubapi.com/crm/v3/lists/idmapping?legacyListId={legacyId}
```
Batch mapping (POST):
```
POST https://api.hubapi.com/crm/v3/lists/idmapping
Body: ["64", "33", "22566"]
```

### Object Type IDs for Lists
Lists support any CRM object type:
- Contacts: `0-1`
- Companies: `0-2`
- Deals: `0-3`
- Custom object: `2-{objectTypeId}`

---

## 12. CRM Extensions: Timeline Events

Timeline events allow apps to inject custom activity entries into a CRM record's timeline — for example, "Contact viewed pricing page" or "Deal contract signed via DocuSign."

**Scope requirements:** Only available for public apps (not private apps). Partners must have existing v1/v3 timeline event definitions or request approval on the developer platform.

**Base endpoint:** `https://api.hubapi.com/crm/v3/timeline/events`

### Create an Event Template
Before creating events, define an event template (schema):
```
POST https://api.hubapi.com/crm/v3/timeline/{appId}/event-templates
```
```json
{
  "name": "Webinar Registration",
  "objectType": "CONTACT",
  "tokens": [
    {
      "name": "webinar_title",
      "type": "string",
      "label": "Webinar Title"
    },
    {
      "name": "registered_at",
      "type": "date",
      "label": "Registration Date"
    }
  ],
  "headerTemplate": "Registered for {{webinar_title}}",
  "detailTemplate": "Contact registered for {{webinar_title}} on {{registered_at}}"
}
```

- Max 750 event templates per app
- Templates can target: `CONTACT`, `COMPANY`, `DEAL`, `TICKET`

### Create a Timeline Event
```
POST https://api.hubapi.com/crm/v3/timeline/events
```
```json
{
  "eventTemplateId": "1234567",
  "email": "contact@example.com",
  "tokens": {
    "webinar_title": "AI for Sales Automation",
    "registered_at": "2026-03-18"
  },
  "objectId": "56789"
}
```

You can identify the contact by `email`, `objectId` (HubSpot ID), or `utk` (HubSpot tracking cookie).

---

## 13. CRM Extensions: Classic Cards & UI Extensions

### Classic CRM Cards (DEPRECATED)
Classic CRM cards are being sunset:
- No longer supported from June 16, 2025
- Officially deprecated October 31, 2026
- The Legacy CRM Card Converter tool is available for migration

Classic cards operated via a data fetch hook: when a user opened a CRM record, HubSpot called your configured URL and displayed the returned data in a card in the right sidebar.

Configure via:
```
GET/PATCH https://api.hubapi.com/crm/v3/extensions/cards-dev/{appId}/{cardId}
```

### UI Extensions (Current Standard)
Modern CRM cards are built with the developer platform using React-based UI Extensions. These support:
- Full React component rendering in the HubSpot UI
- Custom card layouts with HubSpot UI Components
- Data fetching via `hubspot.fetch()` API
- Available in both private apps (projects) and public apps

**`hubspot.fetch()` limits:**
- 15-second timeout per request
- 1MB max request and response payload
- Max 20 concurrent requests per account per app
- URLs must be declared in `permittedUrls` in app config

```javascript
import { hubspot } from '@hubspot/ui-extensions';

// Fetch external data in a UI extension
const response = await hubspot.fetch('https://api.yourapp.com/data', {
  method: 'POST',
  body: { contactId: extensionContext.contactId },
  timeout: 10000
});
const data = await response.json();
```

---

## 14. Workflow Extensions: Custom Actions

### Custom Workflow Actions (App-Based)
Custom workflow actions let your app add new action types to HubSpot's workflow builder. When a workflow runs the action, HubSpot sends an HTTPS POST to your configured `actionUrl`.

**Requirements:**
- Must have a public or private app
- `actionUrl` must be HTTPS
- Request validation via X-HubSpot-Signature (v2 format)

**Project file structure:**
```
src/app/
  app-hsmeta.json
  workflow-actions/
    my-action-hsmeta.json
```

**Action configuration JSON:**
```json
{
  "uid": "send_to_crm_action",
  "type": "workflow-action",
  "config": {
    "actionUrl": "https://api.yourapp.com/hubspot-action",
    "isPublished": true,
    "inputFields": [
      {
        "typeDefinition": {
          "name": "message",
          "type": "string",
          "fieldType": "textarea"
        },
        "supportedValueTypes": ["STATIC_VALUE", "OBJECT_PROPERTY"],
        "isRequired": true
      }
    ],
    "outputFields": [
      {
        "typeDefinition": {
          "name": "external_id",
          "type": "string"
        },
        "internalName": "external_id"
      }
    ],
    "objectRequestOptions": {
      "properties": ["email", "firstname", "lastname"]
    }
  }
}
```

**Payload HubSpot sends to your `actionUrl`:**
```json
{
  "callbackId": "ap-102670506-56777914962-11-0",
  "origin": {
    "portalId": 102670506,
    "actionDefinitionId": 10860211,
    "actionDefinitionVersion": 1
  },
  "context": {
    "source": "WORKFLOWS",
    "workflowId": 192814114
  },
  "object": {
    "objectId": 614,
    "objectType": "CONTACT"
  },
  "inputFields": {
    "message": "Hello from workflow!"
  }
}
```

**Your response to complete the action:**
```json
{
  "outputFields": {
    "external_id": "EXT-98765"
  }
}
```

### Custom Code Actions (Operations Hub)
If you have **Operations Hub Professional or Enterprise**, you can write JavaScript or Python directly inside workflow actions — no external server needed.

**Supported runtimes:**
- Node.js (all pre-installed: `@hubspot/api-client`, `axios`, `lodash`, `redis`, `mongoose`, `mysql`, `aws-sdk`, `googleapis`)
- Python (beta): `requests`, `redis`, `nltk`, `mysql-connector-python`, `google-api-python-client`

**Example Node.js custom code action:**
```javascript
const hubspot = require('@hubspot/api-client');

exports.main = async (event, callback) => {
  const client = new hubspot.Client({
    accessToken: process.env.HUBSPOT_ACCESS_TOKEN
  });

  const contactId = event.object.objectId;
  const contact = await client.crm.contacts.basicApi.getById(
    String(contactId),
    ['email', 'firstname']
  );

  // Perform your logic...
  const result = await fetch('https://api.yourservice.com/process', {
    method: 'POST',
    body: JSON.stringify({ email: contact.properties.email }),
    headers: { 'Content-Type': 'application/json' }
  });
  const data = await result.json();

  callback({
    outputFields: {
      external_reference_id: data.id
    }
  });
};
```

**Asynchronous custom actions** — for long-running operations, use the callback pattern:
1. Respond immediately with `{"callbackId": "..."}`
2. Perform async work
3. POST to `https://api.hubapi.com/automation/v4/action-callbacks/{callbackId}` when done

---

## 15. Batch Operations

All standard CRM objects (and custom objects) support batch endpoints for high-throughput operations. Batch calls reduce API call count and are essential for avoiding rate limits.

### Batch Endpoints Pattern
```
POST /crm/v3/objects/{objectType}/batch/create
POST /crm/v3/objects/{objectType}/batch/read
POST /crm/v3/objects/{objectType}/batch/update
POST /crm/v3/objects/{objectType}/batch/archive
POST /crm/v3/objects/{objectType}/batch/upsert
```

### Batch Create (100 records max per call)
```json
{
  "inputs": [
    {"properties": {"email": "a@test.com", "firstname": "Alice"}},
    {"properties": {"email": "b@test.com", "firstname": "Bob"}},
    {"properties": {"email": "c@test.com", "firstname": "Carol"}}
  ]
}
```

### Batch Read (up to 100 IDs)
```json
{
  "inputs": [
    {"id": "101"},
    {"id": "102"},
    {"id": "103"}
  ],
  "properties": ["email", "firstname", "lastname", "company"]
}
```

### Batch Update
```json
{
  "inputs": [
    {
      "id": "101",
      "properties": {"lifecycle_stage": "customer"}
    },
    {
      "id": "102",
      "properties": {"lifecycle_stage": "lead"}
    }
  ]
}
```

### Batch Archive (Soft Delete)
```json
{
  "inputs": [
    {"id": "101"},
    {"id": "102"}
  ]
}
```

### Batch Upsert
Upsert creates records that don't exist and updates those that do, matching by a unique identifier property:
```json
{
  "inputs": [
    {
      "idProperty": "email",
      "id": "alice@example.com",
      "properties": {"firstname": "Alice", "lifecyclestage": "lead"}
    },
    {
      "idProperty": "email",
      "id": "bob@example.com",
      "properties": {"firstname": "Bob", "lifecyclestage": "customer"}
    }
  ]
}
```

### Python SDK Batch Operations
```python
from hubspot.crm.contacts import BatchInputSimplePublicObjectInputForCreate
from hubspot.crm.contacts import SimplePublicObjectInputForCreate

batch_input = BatchInputSimplePublicObjectInputForCreate(
    inputs=[
        SimplePublicObjectInputForCreate(
            properties={"email": f"user{i}@example.com", "firstname": f"User{i}"}
        )
        for i in range(100)
    ]
)

result = api_client.crm.contacts.batch_api.create(
    batch_input_simple_public_object_input_for_create=batch_input
)
print(f"Created {len(result.results)} contacts")
# Check for partial failures
if result.status == "COMPLETE":
    print("All succeeded")
elif result.status == "PARTIAL":
    print(f"Some failed: {result.num_errors} errors")
    for error in result.errors:
        print(f"  - {error.message}")
```

### Node.js SDK Batch Read with Associations
A common pattern for fetching deals + their associated company data:
```javascript
// Step 1: batch read associations for a set of deal IDs
const dealIds = ['d1', 'd2', 'd3', 'd4', 'd5'];
const assocResult = await hubspotClient.crm.associations.batchApi.read(
  'deals',
  'companies',
  { inputs: dealIds.map(id => ({ id })) }
);

// Step 2: collect unique company IDs
const companyIds = [...new Set(
  assocResult.results.flatMap(r => r.to.map(t => t.id))
)];

// Step 3: batch read company records
const companiesResult = await hubspotClient.crm.companies.batchApi.read({
  inputs: companyIds.map(id => ({ id })),
  properties: ['name', 'domain', 'industry']
});
```

---

## 16. Archiving vs Hard Delete

### Soft Delete (Archive)
All standard batch archive and single record DELETE endpoints perform a **soft delete** (archive). Archived records:
- Are no longer returned in standard queries (`archived=false` default)
- Can be retrieved with `archived=true` parameter
- Can be **restored** within 90 days
- Still count against some account limits during the 90-day window

### Hard Delete (GDPR Purge)
For permanent, irrecoverable deletion (required for GDPR/data removal requests):
```
DELETE https://api.hubapi.com/crm/v3/objects/contacts/gdpr-delete
```
```json
{
  "objectId": "12345",
  "idProperty": "hs_object_id"
}
```

Or delete by email:
```json
{
  "objectId": "contact@example.com",
  "idProperty": "email"
}
```

The GDPR delete endpoint:
- Permanently removes the record and all associated data
- Also triggers a `contact.privacyDeletion` webhook event if subscribed
- Cannot be undone
- Requires the `crm.objects.contacts.write` scope plus GDPR functionality enabled

**Important**: HubSpot does not send deletion events via the standard change-event webhooks for GDPR deletes. Implement a separate reconciliation mechanism (periodic ID diff) if you need to track deleted records in external warehouses.

---

## 17. Webhooks API

Webhooks are the preferred mechanism for real-time synchronization with external systems instead of polling.

### Webhook Types
1. **Public App Webhooks** — configured via API or developer UI; applied to all accounts that install the app
2. **Private App Webhooks** — configured in private app settings UI only (not via API); single-account use

### Supported Event Types
| Event | Description |
|---|---|
| `object.creation` | New record created |
| `object.deletion` | Record archived/deleted |
| `object.propertyChange` | Specific property changed |
| `object.associationChange` | Association created or removed |
| `object.restore` | Archived record restored |
| `contact.privacyDeletion` | GDPR hard delete |

Objects supported: `contact`, `company`, `deal`, `ticket`, `product`, `line_item`, and any custom object type.

### Webhook Configuration (Developer Platform)
Create `src/app/webhooks/webhook-hsmeta.json`:
```json
{
  "uid": "crm-webhooks",
  "type": "webhooks",
  "config": {
    "settings": {
      "targetUrl": "https://api.yourapp.com/hubspot/webhook",
      "maxConcurrentRequests": 10
    },
    "subscriptions": {
      "crmObjects": [
        {
          "subscriptionType": "object.creation",
          "objectType": "contact",
          "active": true
        },
        {
          "subscriptionType": "object.propertyChange",
          "objectType": "contact",
          "propertyName": "lifecyclestage",
          "active": true
        }
      ]
    }
  }
}
```

### Webhook Payload Structure
HubSpot sends up to 100 events batched per POST:
```json
[
  {
    "eventId": 1234567890,
    "subscriptionId": 98765,
    "portalId": 12345678,
    "appId": 54321,
    "occurredAt": 1710756000000,
    "subscriptionType": "contact.creation",
    "attemptNumber": 0,
    "objectId": 6789,
    "changeFlag": "NEW",
    "changeSource": "CRM_UI"
  }
]
```

For property change events, additional fields are included:
```json
{
  "subscriptionType": "contact.propertyChange",
  "propertyName": "lifecyclestage",
  "propertyValue": "customer"
}
```

### Webhook Delivery Characteristics
| Feature | Value |
|---|---|
| Timeout | 5 seconds — must return 2xx within 5s |
| Retry attempts | Up to 10 retries over 24 hours |
| Retry backoff | Exponential doubling: 1s, 2s, 4s, 8s, ... |
| Events per POST | Up to 100 |
| Concurrency | Configurable (min 5, default 10) |
| Max subscriptions | 1,000 per app |
| Delivery guarantee | At-least-once (duplicates possible) |
| Event ordering | Not guaranteed |

### Signature Validation
HubSpot signs webhook payloads. Validate using HMAC SHA-256 (v3):
```python
import hmac
import hashlib

def validate_hubspot_webhook(client_secret: str, request_body: str,
                              signature_header: str, timestamp_header: str,
                              request_uri: str) -> bool:
    source = f"POST{request_uri}{request_body}{timestamp_header}"
    expected = hmac.new(
        client_secret.encode(),
        source.encode(),
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(expected, signature_header)
```

---

## 18. Plan-Based Feature Availability

### Custom Objects
| Feature | Free | Starter | Pro | Enterprise |
|---|---|---|---|---|
| Custom objects | No | No | No | Yes (up to 10) |
| Custom object API access | No | No | No | Yes |
| Custom object schema creation | No | No | No | Yes |

### API Access by Tier
| Feature | Free | Starter | Pro | Enterprise |
|---|---|---|---|---|
| CRM CRUD API | Yes | Yes | Yes | Yes |
| Batch operations | Yes | Yes | Yes | Yes |
| Search API | Yes | Yes | Yes | Yes |
| Import API | Yes | Yes | Yes | Yes |
| Lists/Segments API | Yes | Yes | Yes | Yes |
| Webhooks | No | No | Yes | Yes |
| Custom workflow actions | No | No | Yes | Yes |
| Custom code in workflows | No | No | Operations Hub Pro+ | Operations Hub Ent |
| Timeline events API | Partner apps only | — | — | — |
| UI Extensions | Projects (beta) | — | — | — |

### Rate Limits by Plan
| Plan | 10-second burst | Daily limit |
|---|---|---|
| Free | 100 req/10s | 250,000/day |
| Starter | 100 req/10s | 250,000/day |
| Professional | 150 req/10s | 500,000/day |
| Enterprise | 150 req/10s | 500,000/day |
| API Limit Increase add-on (+1) | +additional | +additional |
| OAuth apps | 100 req/10s (per account) | Shared |

**Note:** Apps using OAuth are subject to per-account limits. Private apps and API keys share the portal's limit pool.

### Private Apps vs OAuth Apps
| Capability | Private App | Public OAuth App |
|---|---|---|
| Single account access | Yes | Limited (up to 10 for private distribution) |
| Multi-account access | No | Yes |
| Marketplace listing | No | Yes |
| Webhook API management | UI only | API + UI |
| Timeline events | No | Yes (approved partners) |
| Classic CRM cards | No | Yes (legacy, deprecated) |
| UI Extensions | Yes (projects) | Yes (projects) |
| Custom workflow actions | No | Yes |

---

## 19. Rate Limits Reference

### Standard Rate Limits
```
10-second rolling window: 100-150 requests (depending on plan)
Daily limit: 250,000-500,000 requests (depending on plan)
Search API: ~4 requests/second (separate limit, more restrictive)
```

### Rate Limit Response Headers
When approaching limits, HubSpot returns these headers:
```
X-HubSpot-RateLimit-Daily: 250000
X-HubSpot-RateLimit-Daily-Remaining: 249850
X-HubSpot-RateLimit-Interval-Milliseconds: 10000
X-HubSpot-RateLimit-Max: 100
X-HubSpot-RateLimit-Remaining: 95
```

### HTTP 429 Error Body
```json
{
  "status": "error",
  "message": "You have reached your secondly limit.",
  "errorType": "RATE_LIMIT",
  "correlationId": "abc-123",
  "policyName": "TEN_SECONDLY_ROLLING",
  "requestId": "def-456"
}
```

`policyName` values: `TEN_SECONDLY_ROLLING`, `DAILY`

### Exponential Backoff Implementation
```python
import time
import requests
from functools import wraps

def with_retry(max_retries=5, base_delay=1.0):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_retries):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if hasattr(e, 'status') and e.status == 429:
                        delay = base_delay * (2 ** attempt)
                        print(f"Rate limited. Retrying in {delay}s...")
                        time.sleep(delay)
                    else:
                        raise
            raise Exception(f"Max retries ({max_retries}) exceeded")
        return wrapper
    return decorator

@with_retry(max_retries=5)
def create_contact(api_client, properties):
    from hubspot.crm.contacts import SimplePublicObjectInputForCreate
    return api_client.crm.contacts.basic_api.create(
        simple_public_object_input_for_create=SimplePublicObjectInputForCreate(
            properties=properties
        )
    )
```

---

## 20. Implementation Recommendations for AI Agents

### Architecture: AI Agent + HubSpot Integration

For an AI agent that reads and writes HubSpot data (e.g., an agent that qualifies leads, updates deals, or manages contact enrichment), use this architecture:

**Authentication:** Use a Private App access token stored as an environment variable. Never hardcode tokens. Private Apps have simpler setup than OAuth for single-account agent use.

```python
import os
from hubspot import HubSpot

hs = HubSpot(access_token=os.environ["HUBSPOT_ACCESS_TOKEN"])
```

**Read operations:**
- Use the Search API for filtered, targeted reads (e.g., "get all contacts created today with no owner")
- Use batch read when fetching records by known IDs (far more efficient than individual GETs)
- Cache property definitions (field names, enumeration labels) — they rarely change and the properties API adds API call overhead

**Write operations:**
- Always use batch upsert for bulk updates — reduces API calls by 100x vs individual PATCHes
- For initial data load, use the Import API with a CSV file — handles millions of rows more reliably than batch API calls
- For real-time triggers, use webhooks to receive events rather than polling

**Association pattern:**
When you need records + their associations in one workflow, use the two-step batch pattern:
1. Batch-read associations for a set of record IDs
2. Collect the associated IDs, then batch-read those records

This reduces the N+1 query problem common in HubSpot integrations.

### When to Use Webhooks vs Polling
| Scenario | Recommendation |
|---|---|
| Sync contact changes to external DB | Webhooks (real-time, lower API usage) |
| Daily reconciliation / audit | Polling with `lastmodifieddate` filter |
| Initial data migration | Import API or batch reads with pagination |
| AI agent monitoring deal stage changes | Webhooks |
| Reporting / analytics pipeline | Polling or Export API (scheduled) |
| Custom object updates trigger downstream action | Webhooks |

### When to Use Batch vs Individual Calls
| Scenario | Individual | Batch |
|---|---|---|
| Update 1-2 records | Yes | Overkill |
| Update 10+ records | No | Yes (up to 100 per call) |
| Read related records by ID | No | Yes — batch read |
| Create new records from external data | No | Yes — batch create |
| Search/filter records | Use Search API | Use Search API |
| First-time sync of 10k+ records | No | Import API |

### Recommended Agent Data Access Pattern
```python
class HubSpotAgent:
    """HubSpot integration for AI agent — optimized for rate limits."""

    def __init__(self, access_token: str):
        self.hs = HubSpot(access_token=access_token)
        self._property_cache = {}

    def get_contacts_modified_since(self, since_timestamp: int, limit: int = 100):
        """Poll for contacts modified since a Unix ms timestamp."""
        from hubspot.crm.contacts import PublicObjectSearchRequest, Filter, FilterGroup

        return self.hs.crm.contacts.search_api.do_search(
            PublicObjectSearchRequest(
                filter_groups=[FilterGroup(filters=[
                    Filter(
                        property_name='lastmodifieddate',
                        operator='GTE',
                        value=str(since_timestamp)
                    )
                ])],
                sorts=[{"propertyName": "lastmodifieddate", "direction": "ASCENDING"}],
                properties=['email', 'firstname', 'lastname', 'lastmodifieddate'],
                limit=limit
            )
        )

    def batch_upsert_contacts(self, contacts: list[dict]):
        """Upsert contacts in chunks of 100."""
        from hubspot.crm.contacts import BatchInputSimplePublicObjectBatchInput

        results = []
        for i in range(0, len(contacts), 100):
            chunk = contacts[i:i+100]
            batch = BatchInputSimplePublicObjectBatchInput(
                inputs=[{
                    "idProperty": "email",
                    "id": c["email"],
                    "properties": c
                } for c in chunk]
            )
            result = self.hs.crm.contacts.batch_api.upsert(
                batch_input_simple_public_object_batch_input=batch
            )
            results.extend(result.results)
        return results
```

---

## 21. Error Codes Reference

| HTTP Status | Meaning | Common Causes |
|---|---|---|
| `200` | OK | Successful read |
| `201` | Created | Successful create |
| `204` | No Content | Successful delete |
| `400` | Bad Request | Invalid request body, missing required fields, malformed JSON |
| `401` | Unauthorized | Invalid or expired access token |
| `403` | Forbidden | Token lacks required scope |
| `404` | Not Found | Record or object type does not exist |
| `409` | Conflict | Duplicate unique property value |
| `422` | Unprocessable Entity | Validation failure (invalid property value, wrong type) |
| `429` | Too Many Requests | Rate limit exceeded |
| `500` | Internal Server Error | HubSpot server error — retry with backoff |
| `502` | Bad Gateway | HubSpot infrastructure issue — retry |
| `504` | Gateway Timeout | Request too slow (heavy search query, large batch) |

**Error body structure:**
```json
{
  "status": "error",
  "message": "Property values were not valid: ...",
  "category": "VALIDATION_ERROR",
  "errors": [
    {
      "message": "Property 'email' is required",
      "in": "body",
      "code": "REQUIRED_FIELD"
    }
  ],
  "correlationId": "abc-123-def",
  "requestId": "ghi-456-jkl"
}
```

**`category` values:**
- `VALIDATION_ERROR` — request data is invalid
- `OBJECT_NOT_FOUND` — record doesn't exist
- `CONFLICT` — unique property violation
- `RATE_LIMIT` — exceeded rate limits
- `MISSING_SCOPES` — token doesn't have required scope
- `INVALID_AUTHENTICATION` — bad/expired token
- `SERVER_ERROR` — HubSpot internal error

---

## 22. Common Gotchas and Pitfalls

### Custom Objects
1. **Name is permanent.** Once set, the `name` field of a custom object schema cannot be changed. Test in a sandbox account before creating schemas in production.

2. **objectTypeId format.** Custom objects have IDs like `2-3456789`. The `2-` prefix is mandatory when referencing the object type in API calls (e.g., for associations or import column mappings).

3. **Schema deletion requires empty records.** You cannot delete a schema while records exist. You must delete all records first, then wait for the 90-day archive window, or use GDPR hard-delete on all records.

4. **Association cardinality via API defaults to MANY_TO_MANY.** If you need ONE_TO_MANY constraints, these must be set manually in the HubSpot UI after schema creation.

5. **Unique value properties count.** Each custom object allows max 10 unique value properties. Exceeding this limit results in a schema validation error.

### SDK Version Mismatches
6. **Python SDK v5.1.0+ removed hapikey support.** If you have legacy code using `api_key=` parameter, it will silently fail in v5.1.0+. Use `access_token=` only.

7. **Python SDK v9+ supports Associations v4.** The older `crm.associations` namespace (v3) is still present but limited. Use `crm.associations.v4` for typed association labels.

8. **Node.js SDK TypeScript notes.** The SDK README states some JavaScript examples won't work directly in TypeScript without adjustments (type assertions, import syntax).

### Imports
9. **Import API is multipart/form-data, not JSON.** Setting `Content-Type: application/json` causes the import to fail silently. Always use `multipart/form-data`.

10. **Import column mappings are zero-indexed file references.** The `columnObjectTypeId` in column mappings must match the file's object type or the mapping is ignored.

11. **Date format mismatch.** Specify `dateFormat` in your import request to match your CSV. Options: `YEAR_MONTH_DAY`, `MONTH_DAY_YEAR`, `DAY_MONTH_YEAR`. A mismatch causes dates to import as blank.

### Lists / Segments
12. **v1 Lists API sunset April 30, 2026.** Any code using `/contacts/v1/lists/*` endpoints will stop working after this date. Migrate to `/crm/v3/lists`.

13. **`listId` vs `legacyListId` are different values.** After migrating from v1 to v3, the IDs change. Don't assume the numeric ID will be the same.

### Webhooks
14. **Webhook events are not guaranteed to be in order.** Always store a `lastmodifieddate` or `occurredAt` timestamp and use it to handle out-of-order events.

15. **Duplicate events are possible.** Implement idempotency using the `eventId` field. Store processed event IDs and skip duplicates.

16. **5-second response timeout.** Your webhook handler must respond with a 2xx status within 5 seconds. If processing takes longer, respond immediately (202 Accepted) and process asynchronously.

17. **Private app webhooks cannot be managed via API.** Only public app webhooks support API-based management. Private app webhooks must be configured in the HubSpot UI.

### Rate Limits
18. **Search API has a separate, stricter rate limit.** Do not send search requests inside tight loops. The Node.js SDK has a built-in separate `SEARCH_LIMITER_OPTIONS` throttling to ~1.8 req/sec for search.

19. **Daily limit resets at midnight EST (UTC-5).** Build retry logic that gracefully handles daily limit resets rather than hard-failing.

20. **Batch operations still consume API calls.** Each batch endpoint call (regardless of how many records it processes) counts as 1 API call toward your limits. Using batch endpoints is about efficiency, not bypassing rate limits.

### Authentication
21. **Token scanning by GitHub/HubSpot.** HubSpot monitors GitHub for exposed tokens and auto-deactivates them. Never commit tokens to source control. Use `.env` files and environment variables exclusively.

22. **Private app tokens vs OAuth tokens scope differently.** A private app token can only access the account it was created in. OAuth tokens are scoped to the specific account that authorized the app during the OAuth flow.

---

*Last updated: 2026-03-18 | Source: developers.hubspot.com, github.com/HubSpot/hubspot-api-python, npmjs.com/@hubspot/api-client*
