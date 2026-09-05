# HubSpot CRM API — Pipelines, Properties & Custom Object Schemas
## Agent 2 Deep Research: Technical Reference for AI Agent Integration

**Source:** developers.hubspot.com
**Date Compiled:** 2026-03-18
**API Version:** v3 (stable) + 2025-09 (versioned endpoints)
**Coverage:** Pipelines, Stages, Custom Properties, Property Groups, CRM Object Schemas

---

## Table of Contents

1. [Overview and Authentication](#1-overview-and-authentication)
2. [Deal Pipelines API](#2-deal-pipelines-api)
3. [Ticket Pipelines API](#3-ticket-pipelines-api)
4. [Pipeline Stages — Deep Reference](#4-pipeline-stages--deep-reference)
5. [Stage Transitions: Moving Records Through Pipelines](#5-stage-transitions-moving-records-through-pipelines)
6. [Pipeline Audit Logs](#6-pipeline-audit-logs)
7. [Custom Properties API — Full Reference](#7-custom-properties-api--full-reference)
8. [Property Types and fieldType Matrix](#8-property-types-and-fieldtype-matrix)
9. [Creating Properties — All Variants](#9-creating-properties--all-variants)
10. [Enumeration Properties and Options](#10-enumeration-properties-and-options)
11. [Calculation Properties](#11-calculation-properties)
12. [Property Groups API](#12-property-groups-api)
13. [Reading and Updating Property Values on Records](#13-reading-and-updating-property-values-on-records)
14. [CRM Object Schemas — Standard and Custom Objects](#14-crm-object-schemas--standard-and-custom-objects)
15. [Custom Object Schema Creation — Full Walkthrough](#15-custom-object-schema-creation--full-walkthrough)
16. [Pipeline Forecasting and Deal Probability](#16-pipeline-forecasting-and-deal-probability)
17. [Best Practices for AI Agent Integration](#17-best-practices-for-ai-agent-integration)
18. [Error Reference and Common Gotchas](#18-error-reference-and-common-gotchas)

---

## 1. Overview and Authentication

The HubSpot CRM API is a RESTful API served from `https://api.hubapi.com`. All requests must be authenticated using one of two methods:

**Private App Token (recommended for agent integrations):**
```
Authorization: Bearer YOUR_PRIVATE_APP_TOKEN
Content-Type: application/json
```

**OAuth 2.0:** Exchange a code for an access token using the standard OAuth flow. Required for public apps distributed to multiple HubSpot accounts.

### Base URL
```
https://api.hubapi.com
```

### Key API Families

| API Family | Base Path | Tier Required |
|---|---|---|
| Pipelines (deals/tickets) | `/crm/v3/pipelines/{objectType}` | Free |
| Properties v3 | `/crm/v3/properties/{objectType}` | Free |
| Properties 2025-09 | `/crm/properties/2025-09/{objectType}` | Free |
| Object CRUD | `/crm/v3/objects/{objectType}` | Free |
| Custom Object Schemas | `/crm-object-schemas/v3/schemas` | Enterprise |

### Scope Requirements Summary

For AI agent integrations, request the following scopes at minimum:

```
crm.objects.deals.read
crm.objects.deals.write
crm.objects.contacts.read
crm.objects.contacts.write
crm.objects.companies.read
crm.objects.companies.write
crm.schemas.deals.read
crm.schemas.deals.write
crm.schemas.contacts.read
crm.schemas.contacts.write
tickets
crm.pipelines.orders.read
crm.pipelines.orders.write
```

For custom objects (Enterprise):
```
crm.schemas.custom.write
crm.objects.custom.read
crm.objects.custom.write
```

---

## 2. Deal Pipelines API

A pipeline in HubSpot represents a workflow with defined stages through which records (deals, tickets, etc.) move. Every deal in HubSpot belongs to exactly one pipeline and is assigned to exactly one stage within that pipeline.

### Endpoint Summary

| Method | Endpoint | Description |
|---|---|---|
| GET | `/crm/v3/pipelines/deals` | List all deal pipelines |
| GET | `/crm/v3/pipelines/deals/{pipelineId}` | Get a specific deal pipeline |
| POST | `/crm/v3/pipelines/deals` | Create a deal pipeline |
| PATCH | `/crm/v3/pipelines/deals/{pipelineId}` | Partially update a deal pipeline |
| PUT | `/crm/v3/pipelines/deals/{pipelineId}` | Replace a deal pipeline entirely |
| DELETE | `/crm/v3/pipelines/deals/{pipelineId}` | Delete a deal pipeline |

### List All Deal Pipelines

**Request:**
```
GET https://api.hubapi.com/crm/v3/pipelines/deals
Authorization: Bearer YOUR_TOKEN
```

**Response (200 OK):**
```json
{
  "results": [
    {
      "id": "default",
      "label": "Sales Pipeline",
      "displayOrder": 0,
      "createdAt": "2019-08-05T20:47:36.164Z",
      "updatedAt": "2022-03-01T18:11:06.005Z",
      "archived": false,
      "stages": [
        {
          "id": "appointmentscheduled",
          "label": "Appointment Scheduled",
          "displayOrder": 0,
          "metadata": {
            "isClosed": "false",
            "probability": "0.2"
          },
          "createdAt": "2019-08-05T20:47:36.164Z",
          "updatedAt": "2022-03-01T18:11:06.005Z",
          "archived": false,
          "writePermissions": "CRM_PERMISSIONS_ENFORCEMENT"
        }
      ]
    }
  ]
}
```

### Create a Deal Pipeline

**Request:**
```
POST https://api.hubapi.com/crm/v3/pipelines/deals
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

**Request Body:**
```json
{
  "displayOrder": 3,
  "label": "New deal pipeline",
  "stages": [
    {
      "label": "In Progress",
      "metadata": {
        "probability": "0.2"
      },
      "displayOrder": 0
    },
    {
      "label": "Contract Sent",
      "metadata": {
        "probability": "0.6"
      },
      "displayOrder": 1
    },
    {
      "label": "Contract Signed",
      "metadata": {
        "probability": "0.8"
      },
      "displayOrder": 2
    },
    {
      "label": "Closed Won",
      "metadata": {
        "probability": "1.0"
      },
      "displayOrder": 3
    },
    {
      "label": "Closed Lost",
      "metadata": {
        "probability": "0.0"
      },
      "displayOrder": 4
    }
  ]
}
```

**Response (201 Created):**
```json
{
  "id": "2468135",
  "label": "New deal pipeline",
  "displayOrder": 3,
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-15T10:30:00.000Z",
  "archived": false,
  "stages": [
    {
      "id": "2468136",
      "label": "In Progress",
      "displayOrder": 0,
      "metadata": {
        "isClosed": "false",
        "probability": "0.2"
      },
      "createdAt": "2024-01-15T10:30:00.000Z",
      "updatedAt": "2024-01-15T10:30:00.000Z",
      "archived": false,
      "writePermissions": "CRM_PERMISSIONS_ENFORCEMENT"
    },
    {
      "id": "2468137",
      "label": "Closed Won",
      "displayOrder": 3,
      "metadata": {
        "isClosed": "true",
        "probability": "1.0"
      },
      "createdAt": "2024-01-15T10:30:00.000Z",
      "updatedAt": "2024-01-15T10:30:00.000Z",
      "archived": false,
      "writePermissions": "CRM_PERMISSIONS_ENFORCEMENT"
    }
  ]
}
```

### Partially Update a Deal Pipeline

Use PATCH to update only specific fields without replacing the entire pipeline definition.

**Request:**
```
PATCH https://api.hubapi.com/crm/v3/pipelines/deals/2468135
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

**Request Body:**
```json
{
  "label": "Enterprise Sales Pipeline",
  "displayOrder": 1
}
```

### Replace a Pipeline Entirely

Use PUT to replace all pipeline fields. Any fields not included in the request body are set to defaults. This is useful when you need to reorder all stages atomically.

**Request:**
```
PUT https://api.hubapi.com/crm/v3/pipelines/deals/2468135
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

### Delete a Pipeline

When deleting a pipeline that may still have active records, use the validation parameter to prevent data loss:

**Request:**
```
DELETE https://api.hubapi.com/crm/v3/pipelines/deals/2468135?validateReferencesBeforeDelete=true
Authorization: Bearer YOUR_TOKEN
```

**Validation Error Response (400):**
```json
{
  "status": "error",
  "message": "Stage IDs: [stage_abc, stage_xyz] referenced by object IDs",
  "category": "VALIDATION_ERROR",
  "subCategory": "PipelineError.STAGE_ID_IN_USE",
  "context": {
    "stageIds": ["[stage_abc, stage_xyz]"],
    "objectIds": ["[22901690010, 22901690011]"]
  }
}
```

---

## 3. Ticket Pipelines API

Ticket pipelines follow the same structural pattern as deal pipelines. The key difference is in the stage metadata: tickets use `ticketState` (`OPEN` or `CLOSED`) instead of `probability`.

### Endpoint Summary

| Method | Endpoint | Description |
|---|---|---|
| GET | `/crm/v3/pipelines/tickets` | List all ticket pipelines |
| GET | `/crm/v3/pipelines/tickets/{pipelineId}` | Get a specific ticket pipeline |
| POST | `/crm/v3/pipelines/tickets` | Create a ticket pipeline |
| PATCH | `/crm/v3/pipelines/tickets/{pipelineId}` | Partially update a ticket pipeline |
| PUT | `/crm/v3/pipelines/tickets/{pipelineId}` | Replace a ticket pipeline entirely |
| DELETE | `/crm/v3/pipelines/tickets/{pipelineId}` | Delete a ticket pipeline |

### Create a Ticket Pipeline

**Request Body:**
```json
{
  "displayOrder": 0,
  "label": "Customer Support Pipeline",
  "stages": [
    {
      "label": "New",
      "metadata": {
        "ticketState": "OPEN"
      },
      "displayOrder": 0
    },
    {
      "label": "In Progress",
      "metadata": {
        "ticketState": "OPEN"
      },
      "displayOrder": 1
    },
    {
      "label": "Waiting on Customer",
      "metadata": {
        "ticketState": "OPEN"
      },
      "displayOrder": 2
    },
    {
      "label": "Closed",
      "metadata": {
        "ticketState": "CLOSED"
      },
      "displayOrder": 3
    }
  ]
}
```

### Create a Ticket Record Assigned to a Pipeline

```
POST https://api.hubapi.com/crm/v3/objects/tickets
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

**Request Body:**
```json
{
  "properties": {
    "hs_pipeline": "0",
    "hs_pipeline_stage": "1",
    "hs_ticket_priority": "HIGH",
    "subject": "Customer reports billing error"
  }
}
```

**Important:** `hs_pipeline` and `hs_pipeline_stage` use the internal numeric IDs as strings, not display labels. Retrieve these IDs by calling `GET /crm/v3/pipelines/tickets` first.

---

## 4. Pipeline Stages — Deep Reference

### Stage CRUD Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/crm/v3/pipelines/{objectType}/{pipelineId}/stages` | List all stages in a pipeline |
| GET | `/crm/v3/pipelines/{objectType}/{pipelineId}/stages/{stageId}` | Get a specific stage |
| POST | `/crm/v3/pipelines/{objectType}/{pipelineId}/stages` | Create a new stage |
| PATCH | `/crm/v3/pipelines/{objectType}/{pipelineId}/stages/{stageId}` | Partially update a stage |
| PUT | `/crm/v3/pipelines/{objectType}/{pipelineId}/stages/{stageId}` | Replace a stage entirely |
| DELETE | `/crm/v3/pipelines/{objectType}/{pipelineId}/stages/{stageId}` | Delete a stage |

### Stage Object Structure

Every stage object returned by the API contains these fields:

| Field | Type | Description |
|---|---|---|
| `id` | string | Internal unique ID for the stage (auto-generated) |
| `label` | string | Human-readable display name. Must be unique within the pipeline. |
| `displayOrder` | integer | Determines the visual order in the HubSpot UI. Lower numbers appear first. |
| `metadata` | object | Stage-type-specific configuration. See below. |
| `createdAt` | ISO 8601 datetime | When the stage was created |
| `updatedAt` | ISO 8601 datetime | When the stage was last modified |
| `archived` | boolean | Whether the stage has been archived |
| `writePermissions` | string | Always `"CRM_PERMISSIONS_ENFORCEMENT"` for user-created stages |

### Stage Metadata by Object Type

**Deals — `probability` (required):**

The `probability` field is a string representation of a decimal between `0.0` and `1.0`. It represents the default win probability for any deal in this stage and drives weighted pipeline calculations.

```json
{
  "metadata": {
    "probability": "0.75",
    "isClosed": "false"
  }
}
```

Special values:
- `"probability": "1.0"` — Closed Won stage
- `"probability": "0.0"` — Closed Lost stage
- `"isClosed": "true"` — Automatically set by HubSpot for Closed Won/Lost stages

**Tickets — `ticketState` (optional):**

```json
{
  "metadata": {
    "ticketState": "OPEN"
  }
}
```

Valid values: `"OPEN"` or `"CLOSED"`. Determines whether tickets in this stage count toward open vs. closed metrics.

**Other Object Types (Appointments, Courses, Listings, Orders, Services, Leads):**

Metadata is optional and can be an empty object or omitted entirely.

### Create a Stage

**Request:**
```
POST https://api.hubapi.com/crm/v3/pipelines/deals/2468135/stages
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

**Request Body:**
```json
{
  "metadata": {
    "probability": "0.5"
  },
  "displayOrder": 2,
  "label": "Proposal Sent"
}
```

**Response (201 Created):**
```json
{
  "id": "2468140",
  "label": "Proposal Sent",
  "displayOrder": 2,
  "metadata": {
    "isClosed": "false",
    "probability": "0.5"
  },
  "createdAt": "2024-01-15T14:00:00.000Z",
  "updatedAt": "2024-01-15T14:00:00.000Z",
  "archived": false,
  "writePermissions": "CRM_PERMISSIONS_ENFORCEMENT"
}
```

### Update a Stage

Use PATCH for partial updates (preserving unlisted fields) or PUT for full replacement.

**PATCH Request:**
```
PATCH https://api.hubapi.com/crm/v3/pipelines/deals/2468135/stages/2468140
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

**Request Body:**
```json
{
  "label": "Proposal Reviewed",
  "metadata": {
    "probability": "0.6"
  }
}
```

### Stage Limits by Object Type

| Object Types | Maximum Stages |
|---|---|
| Deals, Tickets, Custom Objects | 100 stages per pipeline |
| Appointments, Courses, Listings, Leads, Orders, Services | 30 stages per pipeline |

---

## 5. Stage Transitions: Moving Records Through Pipelines

Moving a deal or ticket to a different pipeline stage is one of the most common operations for AI agents managing CRM data. This is done through the standard object update endpoint, not through the pipelines API.

### Move a Deal to a Different Stage

To advance or revert a deal's stage, PATCH the deal object with the new `dealstage` value. The value must be the internal stage ID (not the display label).

**Step 1: Get the pipeline and stage IDs**
```
GET https://api.hubapi.com/crm/v3/pipelines/deals
Authorization: Bearer YOUR_TOKEN
```

Parse the response to find your target pipeline ID and the stage ID for the desired stage.

**Step 2: Update the deal's stage**
```
PATCH https://api.hubapi.com/crm/v3/objects/deals/{dealId}
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

**Request Body:**
```json
{
  "properties": {
    "dealstage": "2468140"
  }
}
```

**Move a deal to a new pipeline AND stage simultaneously:**
```json
{
  "properties": {
    "pipeline": "2468135",
    "dealstage": "2468140"
  }
}
```

**Important behavior when changing pipelines:** When a deal is moved to a different pipeline via the API, it is placed in the first stage of the target pipeline by default unless `dealstage` is also explicitly set to a valid stage within the target pipeline in the same request. Always send both `pipeline` and `dealstage` together when changing pipelines.

### Move a Ticket to a Different Stage

```
PATCH https://api.hubapi.com/crm/v3/objects/tickets/{ticketId}
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

**Request Body:**
```json
{
  "properties": {
    "hs_pipeline_stage": "3"
  }
}
```

### Batch Stage Updates

For updating multiple deals at once (up to 100 per request):

```
POST https://api.hubapi.com/crm/v3/objects/deals/batch/update
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

**Request Body:**
```json
{
  "inputs": [
    {
      "id": "7891023",
      "properties": {
        "dealstage": "contractsent"
      }
    },
    {
      "id": "9876543",
      "properties": {
        "dealstage": "closedwon"
      }
    }
  ]
}
```

### Create a Deal Directly in a Specific Stage

```
POST https://api.hubapi.com/crm/v3/objects/deals
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

**Request Body:**
```json
{
  "properties": {
    "dealname": "New Enterprise Contract",
    "amount": "50000.00",
    "closedate": "2024-06-30T00:00:00.000Z",
    "pipeline": "default",
    "dealstage": "appointmentscheduled",
    "hubspot_owner_id": "910901"
  }
}
```

**Key properties for deal creation:**
- `dealname` — required
- `dealstage` — required (internal stage ID)
- `pipeline` — required if multiple pipelines exist; defaults to the primary pipeline
- `amount` — decimal string (e.g., `"50000.00"`)
- `closedate` — ISO 8601 datetime string
- `hubspot_owner_id` — the HubSpot owner's internal ID (not their email)

---

## 6. Pipeline Audit Logs

HubSpot maintains an audit trail of all modifications to pipelines and stages. This is valuable for AI agents that need to detect configuration changes and resync their internal state.

### Endpoints

```
GET /crm/v3/pipelines/{objectType}/{pipelineId}/audit
GET /crm/v3/pipelines/{objectType}/{pipelineId}/stages/{stageId}/audit
```

### Audit Response Structure

Results are returned in reverse chronological order (most recent first).

```json
{
  "results": [
    {
      "portalId": 12345678,
      "identifier": "2468135",
      "action": "UPDATE",
      "timestamp": "2024-03-10T14:23:00.000Z",
      "message": "Pipeline label updated",
      "fromUserId": "48291",
      "rawObject": {
        "id": "2468135",
        "label": "Enterprise Sales Pipeline",
        "displayOrder": 1,
        "stages": [ /* full stage array at time of change */ ]
      }
    },
    {
      "portalId": 12345678,
      "identifier": "2468135",
      "action": "CREATE",
      "timestamp": "2024-01-15T10:30:00.000Z",
      "message": "Pipeline created",
      "fromUserId": "48291",
      "rawObject": { /* initial pipeline state */ }
    }
  ]
}
```

**Audit action types:** `CREATE`, `UPDATE`

The `rawObject` field contains the full pipeline or stage definition as it existed after the recorded action was applied. AI agents can use this to reconstruct historical pipeline states or detect drift between expected and actual configurations.

---

## 7. Custom Properties API — Full Reference

Properties are the fields that store data on CRM records. Every CRM object type has a set of HubSpot-defined default properties plus any number of custom properties you create via API.

### Core Property Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/crm/v3/properties/{objectType}` | List all properties for an object type |
| GET | `/crm/v3/properties/{objectType}/{propertyName}` | Get a single property definition |
| POST | `/crm/v3/properties/{objectType}` | Create a new custom property |
| PATCH | `/crm/v3/properties/{objectType}/{propertyName}` | Update a property definition |
| DELETE | `/crm/v3/properties/{objectType}/{propertyName}` | Archive a property |
| POST | `/crm/v3/properties/{objectType}/batch/read` | Batch read property definitions |
| POST | `/crm/v3/properties/{objectType}/batch/create` | Batch create properties |
| POST | `/crm/v3/properties/{objectType}/batch/update` | Batch update properties |

### Supported Object Types for Properties

```
contacts
companies
deals
tickets
products
line_items
calls
emails
meetings
notes
tasks
leads
quotes
```

For custom objects, use the numeric `objectTypeId` (e.g., `2-3465404`) or the fully qualified name (e.g., `p7878787_my_object`).

### List All Properties for an Object Type

```
GET https://api.hubapi.com/crm/v3/properties/deals
Authorization: Bearer YOUR_TOKEN
```

**Response (200 OK):**
```json
{
  "results": [
    {
      "name": "dealname",
      "label": "Deal Name",
      "type": "string",
      "fieldType": "text",
      "groupName": "dealinformation",
      "description": "The name given to this deal.",
      "displayOrder": -1,
      "hasUniqueValue": false,
      "hidden": false,
      "hubspotDefined": true,
      "formField": true,
      "calculated": false,
      "archived": false,
      "createdAt": "2019-08-05T20:47:36.164Z",
      "updatedAt": "2019-08-05T20:47:36.164Z",
      "modificationMetadata": {
        "archivable": false,
        "readOnlyDefinition": true,
        "readOnlyOptions": false,
        "readOnlyValue": false
      }
    }
  ]
}
```

**Add `dataSensitivity=sensitive` query parameter (Enterprise only) to include sensitive property definitions in the response.**

### Get a Single Property Definition

```
GET https://api.hubapi.com/crm/v3/properties/contacts/favorite_food
Authorization: Bearer YOUR_TOKEN
```

---

## 8. Property Types and fieldType Matrix

Every property requires two interdependent fields: `type` (the data type) and `fieldType` (the UI representation). Only certain combinations are valid.

### Complete Type and fieldType Matrix

| `type` | Description | Valid `fieldType` Values |
|---|---|---|
| `string` | Text up to 65,536 characters | `text`, `textarea`, `html`, `phonenumber`, `file`, `calculation_equation` |
| `number` | Numeric value with at most one decimal place | `number`, `calculation_equation` |
| `enumeration` | A fixed set of options, stored as semicolon-separated values | `select`, `radio`, `checkbox`, `booleancheckbox`, `calculation_equation` |
| `bool` | Binary yes/no flag | `booleancheckbox`, `calculation_equation` |
| `date` | Day/month/year, stored in UTC midnight | `date` |
| `datetime` | Full timestamp (day/month/year/time) in UTC | `date` |
| `object_coordinates` | Internal reference type — read-only, cannot be created | `text` |
| `json` | Internal formatted JSON — read-only, cannot be created | `text` |

### fieldType Descriptions

| `fieldType` | Rendered As | Notes |
|---|---|---|
| `text` | Single-line text input | Default for string properties |
| `textarea` | Multi-line text area | For longer free-form text |
| `html` | Rich text editor | Output is sanitized HTML |
| `phonenumber` | Formatted phone number display | E.164 format recommended |
| `file` | File upload control | Stores the file ID, not a URL |
| `number` | Numeric input | Supports decimal and scientific notation |
| `select` | Single-select dropdown | Requires `options` array |
| `radio` | Radio buttons (single select) | Requires `options` array |
| `checkbox` | Multi-select checkboxes | Requires `options` array; values stored semicolon-delimited |
| `booleancheckbox` | Single Yes/No checkbox | Works with both `bool` and `enumeration` types |
| `date` | Date picker | For both `date` and `datetime` types |
| `calculation_equation` | Computed, read-only display | Requires `calculationFormula` field |

---

## 9. Creating Properties — All Variants

### Minimal Required Fields

Every property creation request must include these five fields:

```json
{
  "name": "internal_property_name",
  "label": "Display Label",
  "type": "string",
  "fieldType": "text",
  "groupName": "contactinformation"
}
```

**`name` rules:**
- Lowercase letters, numbers, and underscores only
- Cannot start with a number or underscore
- Cannot conflict with HubSpot internal names (prefixed with `hs_`)
- Cannot be changed after creation
- Maximum 60 characters

**`label` rules:**
- Human-readable display name shown in HubSpot UI
- Can be updated after creation via PATCH
- Maximum 200 characters

### Create a Text Property

```
POST https://api.hubapi.com/crm/v3/properties/contacts
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

```json
{
  "name": "ai_lead_score_reason",
  "label": "AI Lead Score Reason",
  "type": "string",
  "fieldType": "textarea",
  "groupName": "contactinformation",
  "description": "The reason provided by the AI scoring model for this lead's score",
  "displayOrder": 10,
  "formField": false,
  "hidden": false
}
```

### Create a Number Property

```json
{
  "name": "ai_lead_score",
  "label": "AI Lead Score",
  "type": "number",
  "fieldType": "number",
  "groupName": "contactinformation",
  "description": "Lead score from 0 to 100 assigned by the AI scoring agent",
  "displayOrder": 9
}
```

### Create a Date Property

```json
{
  "name": "last_ai_evaluation_date",
  "label": "Last AI Evaluation Date",
  "type": "date",
  "fieldType": "date",
  "groupName": "contactinformation"
}
```

### Create a DateTime Property

```json
{
  "name": "ai_last_contacted_at",
  "label": "AI Last Contacted At",
  "type": "datetime",
  "fieldType": "date",
  "groupName": "contactinformation"
}
```

### Create a Boolean Property

```json
{
  "name": "ai_qualified",
  "label": "AI Qualified",
  "type": "bool",
  "fieldType": "booleancheckbox",
  "groupName": "contactinformation",
  "description": "Whether the AI agent has qualified this contact as a lead"
}
```

### Create a Unique Identifier Property

Useful for linking HubSpot records to external system IDs. Maximum 10 unique-value properties per object type.

```json
{
  "name": "external_crm_id",
  "label": "External CRM ID",
  "type": "string",
  "fieldType": "text",
  "groupName": "contactinformation",
  "hasUniqueValue": true,
  "description": "ID from the upstream source system"
}
```

Once created, you can query records by this property:
```
GET https://api.hubapi.com/crm/v3/objects/contacts/ABC123?idProperty=external_crm_id
```

### Full Property Creation Response

```json
{
  "name": "ai_lead_score",
  "label": "AI Lead Score",
  "type": "number",
  "fieldType": "number",
  "groupName": "contactinformation",
  "description": "Lead score from 0 to 100",
  "displayOrder": 9,
  "hasUniqueValue": false,
  "hidden": false,
  "formField": false,
  "calculated": false,
  "hubspotDefined": false,
  "archived": false,
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-15T10:30:00.000Z",
  "modificationMetadata": {
    "archivable": true,
    "readOnlyDefinition": false,
    "readOnlyOptions": false,
    "readOnlyValue": false
  }
}
```

### Update a Property Definition

Use PATCH to change the label, description, display order, or options without redefining the whole property:

```
PATCH https://api.hubapi.com/crm/v3/properties/contacts/ai_lead_score
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

```json
{
  "label": "AI Engagement Score",
  "description": "Updated by AI pipeline v2 — scores engagement 0 to 100"
}
```

**Note:** The `name`, `type`, `fieldType`, and `hasUniqueValue` fields are immutable after creation. Attempting to change them via PATCH will return an error.

---

## 10. Enumeration Properties and Options

Enumeration properties represent a finite set of options (dropdown, radio, multi-select). They are among the most important property types for structured AI agent workflows because they enforce controlled vocabularies and enable filtering/segmentation.

### Single-Select Dropdown

```json
{
  "name": "deal_category",
  "label": "Deal Category",
  "type": "enumeration",
  "fieldType": "select",
  "groupName": "dealinformation",
  "options": [
    {
      "label": "New Business",
      "value": "new_business",
      "displayOrder": 0,
      "hidden": false,
      "description": "First-time customer acquisition"
    },
    {
      "label": "Expansion",
      "value": "expansion",
      "displayOrder": 1,
      "hidden": false,
      "description": "Upsell to existing customer"
    },
    {
      "label": "Renewal",
      "value": "renewal",
      "displayOrder": 2,
      "hidden": false,
      "description": "Contract renewal"
    }
  ]
}
```

### Multi-Select Checkboxes

```json
{
  "name": "pain_points_identified",
  "label": "Pain Points Identified",
  "type": "enumeration",
  "fieldType": "checkbox",
  "groupName": "dealinformation",
  "options": [
    {
      "label": "Cost reduction",
      "value": "cost_reduction",
      "displayOrder": 0,
      "hidden": false
    },
    {
      "label": "Efficiency improvement",
      "value": "efficiency",
      "displayOrder": 1,
      "hidden": false
    },
    {
      "label": "Compliance requirement",
      "value": "compliance",
      "displayOrder": 2,
      "hidden": false
    },
    {
      "label": "Growth support",
      "value": "growth",
      "displayOrder": 3,
      "hidden": false
    }
  ]
}
```

### Radio Button Property

```json
{
  "name": "qualification_status",
  "label": "Qualification Status",
  "type": "enumeration",
  "fieldType": "radio",
  "groupName": "dealinformation",
  "options": [
    {"label": "Qualified", "value": "qualified", "displayOrder": 0, "hidden": false},
    {"label": "Unqualified", "value": "unqualified", "displayOrder": 1, "hidden": false},
    {"label": "Needs Review", "value": "needs_review", "displayOrder": 2, "hidden": false}
  ]
}
```

### Option Schema Fields

Each option object in the `options` array supports:

| Field | Type | Required | Description |
|---|---|---|---|
| `value` | string | Yes | Internal value used when setting via API. Cannot be changed after creation. |
| `label` | string | Yes | Display label shown in HubSpot UI. Can be updated. |
| `hidden` | boolean | Yes | If `true`, the option is hidden from the UI but still valid via API. |
| `displayOrder` | integer | No | Ordering in the UI. Lower numbers appear first. `-1` places at end. |
| `description` | string | No | Tooltip text shown to users in HubSpot. |

### Setting Multi-Select Values on Records

When setting an enumeration `checkbox` property value on a record:

**To replace all values:**
```json
{
  "properties": {
    "pain_points_identified": "cost_reduction;efficiency"
  }
}
```

**To append values without overwriting existing ones (add semicolon prefix):**
```json
{
  "properties": {
    "pain_points_identified": ";compliance;growth"
  }
}
```

**To clear a multi-select property:**
```json
{
  "properties": {
    "pain_points_identified": ""
  }
}
```

### Adding Options to an Existing Enumeration Property

To add new options to an existing enumeration property, use PATCH and include the full updated options array (existing + new options):

```
PATCH https://api.hubapi.com/crm/v3/properties/deals/deal_category
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

```json
{
  "options": [
    {"label": "New Business", "value": "new_business", "displayOrder": 0, "hidden": false},
    {"label": "Expansion", "value": "expansion", "displayOrder": 1, "hidden": false},
    {"label": "Renewal", "value": "renewal", "displayOrder": 2, "hidden": false},
    {"label": "Partner Led", "value": "partner_led", "displayOrder": 3, "hidden": false}
  ]
}
```

**Critical:** The PATCH replaces the entire options array. Omitting an existing option from the array will hide it (`hidden: true` effectively) — it will no longer appear in the UI. Option `value` fields cannot be changed.

**Also note (from community reports, 2025):** Creating an enumeration property with an empty `options` array returns an error. Always include at least one option when creating an enumeration property.

---

## 11. Calculation Properties

Calculated properties are read-only properties whose values are derived from a formula applied to other property values. They are defined via API and cannot be edited in the HubSpot UI after creation.

### Create a Calculation Property

```json
{
  "name": "deal_age_days",
  "label": "Deal Age (Days)",
  "type": "number",
  "fieldType": "calculation_equation",
  "groupName": "dealinformation",
  "calculationFormula": "hs_lastmodifieddate - createdate"
}
```

### Formula Reference

**Literals:**
- String: `'constant'` or `"constant"`
- Number: `1005`, `1.5589`
- Boolean: `true` or `false`

**Property references:**
- String property: `string(property_name)`
- Number property: `property_name` (default, no cast needed)
- Boolean property: `bool(property_name)`

**Arithmetic operators:** `+`, `-`, `*`, `/`

**Comparison operators:** `<`, `>`, `<=`, `>=`, `=`, `equals`, `!=`

**Logical operators:** `and`, `or`, `not`

**Built-in functions:**

| Function | Signature | Description |
|---|---|---|
| `max` | `max(a, b, ...)` | Returns largest value from 2–100 inputs |
| `min` | `min(a, b, ...)` | Returns smallest value from 2–100 inputs |
| `is_present` | `is_present(expr)` | Returns true if the expression evaluates to a non-null value |
| `contains` | `contains(str, substr)` | Case-sensitive substring search |
| `concatenate` | `concatenate(a, b, ...)` | Joins 2–100 string values |
| `number_to_string` | `number_to_string(n)` | Converts number to string |
| `string_to_number` | `string_to_number(s)` | Converts string to number |

**Conditional syntax:**
```
if boolean_expression then statement
[elseif expression then statement]*
[else statement]
endif
```

**Real-world example — check if contact is actively enrolled in sequence:**
```json
{
  "calculationFormula": "if is_present(hs_latest_sequence_enrolled_date) then if is_present(hs_sequences_actively_enrolled_count) and hs_sequences_actively_enrolled_count >= 1 then true else false else ''"
}
```

**Calculate elapsed days between two date properties:**
```json
{
  "calculationFormula": "closed - started"
}
```

**Conditional deal tier based on amount:**
```json
{
  "calculationFormula": "if amount >= 100000 then 'enterprise' elseif amount >= 25000 then 'mid-market' else 'smb' endif"
}
```

---

## 12. Property Groups API

Property groups organize related properties into named sections. They are displayed as collapsible sections on CRM record pages. Every custom property must belong to a group.

### Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/crm/v3/properties/{objectType}/groups` | List all property groups |
| GET | `/crm/v3/properties/{objectType}/groups/{groupName}` | Get a specific group |
| POST | `/crm/v3/properties/{objectType}/groups` | Create a new property group |
| PATCH | `/crm/v3/properties/{objectType}/groups/{groupName}` | Update a property group |
| DELETE | `/crm/v3/properties/{objectType}/groups/{groupName}` | Delete a property group |

### Create a Property Group

```
POST https://api.hubapi.com/crm/v3/properties/contacts/groups
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

**Request Body:**
```json
{
  "name": "ai_agent_data",
  "label": "AI Agent Data",
  "displayOrder": -1
}
```

**Response (201 Created):**
```json
{
  "name": "ai_agent_data",
  "label": "AI Agent Data",
  "displayOrder": -1,
  "archived": false
}
```

**Field reference:**

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | string | Yes | Internal identifier. Lowercase, alphanumeric, underscores. Cannot be changed. |
| `label` | string | Yes | Human-readable display name. Shown as section header in HubSpot. |
| `displayOrder` | integer | No | UI ordering. `-1` places group after all positively-ordered groups. |

### List All Property Groups

```
GET https://api.hubapi.com/crm/v3/properties/deals/groups
Authorization: Bearer YOUR_TOKEN
```

**Response:**
```json
{
  "results": [
    {
      "name": "dealinformation",
      "label": "Deal information",
      "displayOrder": 0,
      "archived": false
    },
    {
      "name": "ai_agent_data",
      "label": "AI Agent Data",
      "displayOrder": -1,
      "archived": false
    }
  ]
}
```

### Update a Property Group

```
PATCH https://api.hubapi.com/crm/v3/properties/contacts/groups/ai_agent_data
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

```json
{
  "label": "AI Enrichment Data",
  "displayOrder": 5
}
```

### Best Practice for AI Integrations

Create a dedicated property group for every integration or AI system that adds properties. Example group names:
- `ai_scoring_v1` — for lead scoring agent properties
- `ai_enrichment` — for data enrichment pipeline properties
- `crm_integration_salesforce` — for Salesforce sync properties

This makes it easy to:
1. Identify which properties belong to your integration
2. Audit and manage properties by system
3. Avoid naming conflicts with other integrations
4. Clean up by group if the integration is removed

---

## 13. Reading and Updating Property Values on Records

### Read Properties from a Record

```
GET https://api.hubapi.com/crm/v3/objects/deals/{dealId}?properties=dealname,dealstage,amount,pipeline
Authorization: Bearer YOUR_TOKEN
```

**Response:**
```json
{
  "id": "7891023",
  "properties": {
    "dealname": "New Enterprise Contract",
    "dealstage": "contractsent",
    "amount": "50000.00",
    "pipeline": "default",
    "hs_lastmodifieddate": "2024-01-15T14:30:00.000Z",
    "createdate": "2024-01-10T09:00:00.000Z"
  },
  "createdAt": "2024-01-10T09:00:00.000Z",
  "updatedAt": "2024-01-15T14:30:00.000Z",
  "archived": false
}
```

### Read Property History

To retrieve the full edit history of specific properties on a record:

```
GET https://api.hubapi.com/crm/v3/objects/deals/{dealId}?propertiesWithHistory=dealstage,amount
Authorization: Bearer YOUR_TOKEN
```

**Response:**
```json
{
  "id": "7891023",
  "properties": {
    "dealstage": "closedwon"
  },
  "propertiesWithHistory": {
    "dealstage": [
      {
        "value": "closedwon",
        "timestamp": "2024-01-20T16:00:00.000Z",
        "sourceType": "API",
        "sourceId": "12345"
      },
      {
        "value": "contractsent",
        "timestamp": "2024-01-15T14:30:00.000Z",
        "sourceType": "CRM_UI",
        "sourceId": null
      }
    ]
  }
}
```

### Update Property Values

```
PATCH https://api.hubapi.com/crm/v3/objects/deals/{dealId}
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

**Request Body:**
```json
{
  "properties": {
    "ai_lead_score": "87",
    "ai_qualified": "true",
    "last_ai_evaluation_date": "2024-01-15",
    "ai_last_contacted_at": "2024-01-15T14:00:00.000Z",
    "qualification_status": "qualified",
    "pain_points_identified": "cost_reduction;efficiency"
  }
}
```

### Date and DateTime Formatting

**Date properties (`type: date`):**
- ISO 8601 format: `"2024-01-15"` (YYYY-MM-DD)
- UNIX milliseconds at midnight UTC: `"1705276800000"`
- The time portion is ignored — only the date is stored

**DateTime properties (`type: datetime`):**
- ISO 8601 with time: `"2024-01-15T14:30:00.000Z"`
- UNIX milliseconds (UTC): `"1705327800000"`
- Displayed in the user's local timezone in HubSpot

### Owner Assignment

Assign a HubSpot user as the record owner using their owner ID (an integer, not their email):

```json
{
  "properties": {
    "hubspot_owner_id": "41629779"
  }
}
```

To find owner IDs, call `GET https://api.hubapi.com/crm/v3/owners`.

### Clear a Property Value

Set the property to an empty string:

```json
{
  "properties": {
    "ai_lead_score_reason": ""
  }
}
```

### Batch Read Records with Properties

```
POST https://api.hubapi.com/crm/v3/objects/deals/batch/read
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

```json
{
  "properties": ["dealname", "dealstage", "amount", "pipeline", "ai_lead_score"],
  "inputs": [
    {"id": "7891023"},
    {"id": "9876543"},
    {"id": "1234567"}
  ]
}
```

---

## 14. CRM Object Schemas — Standard and Custom Objects

### Standard Object Type IDs

HubSpot's built-in objects have fixed numeric type IDs:

| Object | Type Name | Internal ID |
|---|---|---|
| Contacts | `contacts` | `0-1` |
| Companies | `companies` | `0-2` |
| Deals | `deals` | `0-3` |
| Tickets | `tickets` | `0-5` |
| Products | `products` | `0-7` |
| Line Items | `line_items` | `0-8` |
| Quotes | `quotes` | `0-14` |
| Calls | `calls` | `0-48` |
| Emails | `emails` | `0-49` |
| Meetings | `meetings` | `0-47` |
| Tasks | `tasks` | `0-27` |
| Notes | `notes` | `0-46` |
| Leads | `leads` | `0-136` |

### Custom Object Schemas Endpoints

| Method | Endpoint | Description |
|---|---|---|
| POST | `/crm-object-schemas/v3/schemas` | Create a new custom object schema |
| GET | `/crm-object-schemas/v3/schemas` | List all custom object schemas |
| GET | `/crm-object-schemas/v3/schemas/{objectTypeId}` | Get a specific schema by ID |
| GET | `/crm-object-schemas/v3/schemas/{fullyQualifiedName}` | Get by fully qualified name |
| PATCH | `/crm-object-schemas/v3/schemas/{objectTypeId}` | Update a schema |
| DELETE | `/crm-object-schemas/v3/schemas/{objectType}` | Soft delete (archive) |
| DELETE | `/crm-object-schemas/v3/schemas/{objectType}?archived=true` | Hard delete |
| POST | `/crm-object-schemas/v3/schemas/{objectTypeId}/associations` | Add an association |
| POST | `/crm/v3/properties/{objectTypeId}` | Add a property to a custom object |

**Required scope:** `crm.schemas.custom.write`
**Required tier:** Enterprise (all hub types)

### Custom Object Identifiers

After creating a custom object schema, it gets two stable identifiers:

- **`objectTypeId`:** A string like `"2-3465404"`. Use this in API calls.
- **`fullyQualifiedName`:** Formatted as `p{HubID}_{objectName}` (e.g., `p7878787_cars`). Used in some endpoints.

Standard object identifiers (contact, company, deal, ticket) can be referenced by their lowercase name string (e.g., `"CONTACT"`, `"COMPANY"`, `"DEAL"`, `"TICKET"`) in the `associatedObjects` array.

---

## 15. Custom Object Schema Creation — Full Walkthrough

This section provides a complete walkthrough for creating a custom object, adding properties, and defining associations — the typical setup sequence for an AI agent integration.

### Step 1: Create the Schema

```
POST https://api.hubapi.com/crm-object-schemas/v3/schemas
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

**Full request body (car dealership inventory example):**
```json
{
  "name": "cars",
  "description": "Cars currently or previously held in inventory.",
  "labels": {
    "singular": "Car",
    "plural": "Cars"
  },
  "primaryDisplayProperty": "model",
  "secondaryDisplayProperties": ["make", "year"],
  "searchableProperties": ["year", "make", "vin", "model"],
  "requiredProperties": ["year", "make", "vin", "model"],
  "properties": [
    {
      "name": "condition",
      "label": "Condition",
      "type": "enumeration",
      "fieldType": "select",
      "groupName": "car_information",
      "options": [
        {"label": "New", "value": "new", "displayOrder": 0, "hidden": false},
        {"label": "Used", "value": "used", "displayOrder": 1, "hidden": false},
        {"label": "Certified Pre-Owned", "value": "cpo", "displayOrder": 2, "hidden": false}
      ]
    },
    {
      "name": "year",
      "label": "Year",
      "type": "number",
      "fieldType": "number",
      "groupName": "car_information"
    },
    {
      "name": "make",
      "label": "Make",
      "type": "string",
      "fieldType": "text",
      "groupName": "car_information"
    },
    {
      "name": "model",
      "label": "Model",
      "type": "string",
      "fieldType": "text",
      "groupName": "car_information"
    },
    {
      "name": "vin",
      "label": "VIN",
      "type": "string",
      "fieldType": "text",
      "groupName": "car_information",
      "hasUniqueValue": true
    },
    {
      "name": "price",
      "label": "Price",
      "type": "number",
      "fieldType": "number",
      "groupName": "car_information"
    },
    {
      "name": "date_received",
      "label": "Date Received",
      "type": "date",
      "fieldType": "date",
      "groupName": "car_information"
    }
  ],
  "associatedObjects": ["CONTACT", "DEAL"]
}
```

**Response (201 Created):**
```json
{
  "id": "2-3465404",
  "name": "cars",
  "fullyQualifiedName": "p7878787_cars",
  "labels": {
    "singular": "Car",
    "plural": "Cars"
  },
  "primaryDisplayProperty": "model",
  "secondaryDisplayProperties": ["make", "year"],
  "searchableProperties": ["year", "make", "vin", "model"],
  "requiredProperties": ["year", "make", "vin", "model"],
  "properties": [ /* full property definitions with IDs */ ],
  "associations": [
    {
      "id": "121",
      "name": "cars_to_contact",
      "fromObjectTypeId": "2-3465404",
      "toObjectTypeId": "0-1"
    },
    {
      "id": "122",
      "name": "cars_to_deal",
      "fromObjectTypeId": "2-3465404",
      "toObjectTypeId": "0-3"
    }
  ],
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-15T10:30:00.000Z",
  "archived": false
}
```

### Step 2: Add a Property to an Existing Custom Object

After schema creation, add properties using the standard properties endpoint with the `objectTypeId`:

```
POST https://api.hubapi.com/crm/v3/properties/2-3465404
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

```json
{
  "name": "maintenance_package",
  "label": "Maintenance Package",
  "type": "enumeration",
  "fieldType": "select",
  "groupName": "car_information",
  "options": [
    {"label": "Basic", "value": "basic", "displayOrder": 0, "hidden": false},
    {"label": "Oil Change Only", "value": "oil_change_only", "displayOrder": 1, "hidden": false},
    {"label": "Scheduled Maintenance", "value": "scheduled", "displayOrder": 2, "hidden": false}
  ]
}
```

### Step 3: Add an Association to an Existing Schema

```
POST https://api.hubapi.com/crm-object-schemas/v3/schemas/2-3465404/associations
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

```json
{
  "fromObjectTypeId": "2-3465404",
  "toObjectTypeId": "0-5",
  "name": "cars_to_ticket"
}
```

**Response (201 Created):**
```json
{
  "id": "123",
  "name": "cars_to_ticket",
  "fromObjectTypeId": "2-3465404",
  "toObjectTypeId": "0-5",
  "createdAt": "2024-01-15T11:00:00.000Z",
  "updatedAt": "2024-01-15T11:00:00.000Z"
}
```

### Step 4: Create Records for the Custom Object

```
POST https://api.hubapi.com/crm/v3/objects/2-3465404
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

```json
{
  "properties": {
    "condition": "used",
    "date_received": "1582416000000",
    "year": "2019",
    "make": "Toyota",
    "model": "Camry",
    "vin": "4T1BF1FK4KU123456",
    "price": "18500",
    "maintenance_package": "scheduled"
  }
}
```

### Step 5: Associate the Custom Object Record with a Contact

```
PUT https://api.hubapi.com/crm/v3/objects/2-3465404/181308/associations/contacts/12345/121
Authorization: Bearer YOUR_TOKEN
```

Where `121` is the association type ID from the schema creation response.

### Schema Naming Rules Summary

- The `name` field can only contain letters, numbers, and underscores
- The first character must be a letter
- The `name` and `labels` cannot be changed after creation
- The full internal name in HubSpot will be `p{portalId}_{name}` (e.g., `p7878787_cars`)

### Schema Update

Use PATCH to update allowed schema fields (labels cannot be changed, but `secondaryDisplayProperties`, `searchableProperties`, and `description` can):

```
PATCH https://api.hubapi.com/crm-object-schemas/v3/schemas/2-3465404
Content-Type: application/json
Authorization: Bearer YOUR_TOKEN
```

```json
{
  "secondaryDisplayProperties": ["make", "year", "maintenance_package"],
  "description": "Updated inventory tracking object"
}
```

---

## 16. Pipeline Forecasting and Deal Probability

HubSpot's forecasting system connects pipeline stage probability values to higher-level forecast categories used by sales managers.

### How Probability Drives Forecasting

Each deal pipeline stage has a `probability` value (set via the pipelines API). This value has two uses:

1. **Weighted pipeline value:** `deal_amount × probability` gives the weighted value of any deal in that stage, used in pipeline reports.

2. **Forecast category assignment:** Each stage can be configured in the HubSpot UI to map to a forecast category. The stage `probability` is the main signal used to suggest the appropriate category.

### Forecast Categories

HubSpot's default forecast categories (available with Sales Hub Professional+):

| Category | Typical Probability Range | Meaning |
|---|---|---|
| `Omitted` | 0% or early-stage | Not included in forecasts (Closed Lost, very early stages) |
| `Pipeline` | ~10–30% | In pipeline but not yet reliably committed |
| `Best Case` | ~30–60% | Might close, optimistic scenario |
| `Most Likely` | ~60–80% | Expected to close, balanced estimate |
| `Commit` | ~80–90% | High confidence, committed to close |
| `Closed` | 100% or 0% | Closed Won or Closed Lost |

### Setting Probability on Stages

Set the `probability` field in the stage `metadata` object. The value must be a string between `"0.0"` and `"1.0"`:

```json
{
  "metadata": {
    "probability": "0.75"
  }
}
```

**Recommended probability scale for a standard B2B sales pipeline:**

| Stage | Probability |
|---|---|
| Prospecting | 0.1 |
| Qualification | 0.2 |
| Meeting Scheduled | 0.3 |
| Demo Delivered | 0.4 |
| Proposal Sent | 0.6 |
| Contract Sent | 0.75 |
| Contract Negotiation | 0.85 |
| Closed Won | 1.0 |
| Closed Lost | 0.0 |

### Deal-Level Probability Override

Individual deals have a `hs_deal_stage_probability` property that automatically reflects the stage probability. There is also a `hs_forecast_amount` and `hs_forecast_probability` that can be set independently by reps to override the stage default — useful for deals that are stronger or weaker than stage average.

To read a deal's current stage probability:
```
GET https://api.hubapi.com/crm/v3/objects/deals/{dealId}?properties=hs_deal_stage_probability,amount,hs_forecast_probability
```

---

## 17. Best Practices for AI Agent Integration

### Design Principles for AI Agents Managing HubSpot Pipelines

**1. Always resolve IDs before writing.**

Never hardcode stage IDs or pipeline IDs. Stage IDs can differ between HubSpot portals (accounts). At agent startup, fetch current pipeline definitions and cache them:

```python
def load_pipeline_map(access_token: str) -> dict:
    """Load all deal pipelines and build stage name → stage ID map."""
    resp = requests.get(
        "https://api.hubapi.com/crm/v3/pipelines/deals",
        headers={"Authorization": f"Bearer {access_token}"}
    )
    pipelines = resp.json()["results"]
    stage_map = {}
    for pipeline in pipelines:
        for stage in pipeline.get("stages", []):
            stage_map[stage["label"].lower()] = {
                "stageId": stage["id"],
                "pipelineId": pipeline["id"],
                "probability": stage["metadata"].get("probability", "0")
            }
    return stage_map
```

**2. Use dedicated property groups.**

Create a named property group for every AI agent or integration. Prefix all custom properties with an agent identifier (e.g., `ai_scoring_`, `enrich_`, `crm_sync_`). This prevents name collisions and makes cleanup trivial.

```python
def ensure_property_group(access_token: str, object_type: str, group_name: str, group_label: str):
    """Create property group if it doesn't already exist."""
    # Check existing
    existing = requests.get(
        f"https://api.hubapi.com/crm/v3/properties/{object_type}/groups/{group_name}",
        headers={"Authorization": f"Bearer {access_token}"}
    )
    if existing.status_code == 404:
        requests.post(
            f"https://api.hubapi.com/crm/v3/properties/{object_type}/groups",
            headers={"Authorization": f"Bearer {access_token}", "Content-Type": "application/json"},
            json={"name": group_name, "label": group_label, "displayOrder": -1}
        )
```

**3. Use unique identifier properties for cross-system linking.**

If your agent manages deals that correspond to records in an external system, create a unique identifier property and use it as the lookup key. This enables idempotent upsert patterns:

```python
def upsert_deal(access_token: str, external_id: str, properties: dict):
    """Create or update deal by external ID."""
    # Try to find existing deal
    resp = requests.get(
        f"https://api.hubapi.com/crm/v3/objects/deals/{external_id}?idProperty=external_crm_id",
        headers={"Authorization": f"Bearer {access_token}"}
    )
    if resp.status_code == 200:
        deal_id = resp.json()["id"]
        # Update existing
        requests.patch(
            f"https://api.hubapi.com/crm/v3/objects/deals/{deal_id}",
            headers={"Authorization": f"Bearer {access_token}", "Content-Type": "application/json"},
            json={"properties": properties}
        )
    elif resp.status_code == 404:
        # Create new
        properties["external_crm_id"] = external_id
        requests.post(
            "https://api.hubapi.com/crm/v3/objects/deals",
            headers={"Authorization": f"Bearer {access_token}", "Content-Type": "application/json"},
            json={"properties": properties}
        )
```

**4. Move deals through stages atomically.**

When advancing a deal's stage, optionally update related properties (close date, amount, notes) in the same PATCH request to reduce API calls and maintain data consistency:

```python
def advance_deal_stage(access_token: str, deal_id: str, target_stage_id: str, context: dict):
    """Advance a deal to a new stage with supporting data."""
    update_payload = {
        "properties": {
            "dealstage": target_stage_id,
            **context.get("properties", {})  # e.g., amount, closedate, notes
        }
    }
    requests.patch(
        f"https://api.hubapi.com/crm/v3/objects/deals/{deal_id}",
        headers={"Authorization": f"Bearer {access_token}", "Content-Type": "application/json"},
        json=update_payload
    )
```

**5. Use batch endpoints for high-volume operations.**

Individual PATCH calls are subject to rate limits (100 requests/10 seconds for private apps by default). For bulk updates, use batch endpoints:

```python
def batch_advance_deals(access_token: str, updates: list[dict]):
    """
    updates: [{"id": "12345", "dealstage": "closedwon"}, ...]
    """
    payload = {
        "inputs": [
            {"id": u["id"], "properties": {"dealstage": u["dealstage"]}}
            for u in updates
        ]
    }
    # Batch supports up to 100 records per call
    for i in range(0, len(payload["inputs"]), 100):
        batch = payload["inputs"][i:i+100]
        requests.post(
            "https://api.hubapi.com/crm/v3/objects/deals/batch/update",
            headers={"Authorization": f"Bearer {access_token}", "Content-Type": "application/json"},
            json={"inputs": batch}
        )
```

**6. Validate enumerations before writing.**

Before setting an enumeration property value, validate that the value is in the property's `options` array. Invalid enum values are silently accepted by the API but display as "Unknown value" in the HubSpot UI:

```python
def get_valid_enum_values(access_token: str, object_type: str, property_name: str) -> set:
    """Return set of valid option values for an enumeration property."""
    resp = requests.get(
        f"https://api.hubapi.com/crm/v3/properties/{object_type}/{property_name}",
        headers={"Authorization": f"Bearer {access_token}"}
    )
    options = resp.json().get("options", [])
    return {opt["value"] for opt in options if not opt.get("hidden", False)}
```

**7. Respect property immutability constraints.**

The following property fields cannot be changed after creation. Any PATCH request attempting to modify them will fail silently or with an error:

- `name` — internal name is permanent
- `type` — data type is permanent
- `fieldType` — UI type is permanent
- `hasUniqueValue` — uniqueness constraint is permanent
- Option `value` fields in enumeration properties are permanent (though labels can change)

**8. Handle deleted pipelines gracefully.**

If a pipeline is deleted and your agent still holds cached stage IDs from it, any attempt to set a deal to one of those stages will fail with a 404. Implement cache invalidation on 404 responses:

```python
def safe_update_deal_stage(access_token: str, deal_id: str, stage_id: str, pipeline_cache: dict):
    resp = requests.patch(
        f"https://api.hubapi.com/crm/v3/objects/deals/{deal_id}",
        headers={"Authorization": f"Bearer {access_token}", "Content-Type": "application/json"},
        json={"properties": {"dealstage": stage_id}}
    )
    if resp.status_code == 404:
        # Invalidate pipeline cache and reload
        pipeline_cache.clear()
        pipeline_cache.update(load_pipeline_map(access_token))
```

**9. Track property history for audit trails.**

For regulated or high-stakes AI decisions (e.g., marking a deal as qualified, changing close date), use `propertiesWithHistory` to retrieve the full change log as evidence:

```
GET /crm/v3/objects/deals/{dealId}?propertiesWithHistory=dealstage,amount,ai_qualified
```

**10. Architect custom objects before using them for AI agent state.**

If your AI agent needs to store session state, evaluation results, or workflow checkpoints in HubSpot, consider creating a custom object rather than adding dozens of properties to contacts or deals. Custom objects provide:
- Clean separation of concerns
- Independent pipelines and stages
- Dedicated search/filter capabilities
- Clear ownership in the HubSpot schema

---

## 18. Error Reference and Common Gotchas

### Common HTTP Status Codes

| Status | Meaning | Common Cause |
|---|---|---|
| 200 | OK | Successful read or update |
| 201 | Created | Successful create |
| 400 | Bad Request | Missing required field, invalid value, validation failure |
| 401 | Unauthorized | Invalid or expired token; missing required scope |
| 403 | Forbidden | Correct token but insufficient permissions (wrong scope or tier) |
| 404 | Not Found | Record, pipeline, stage, or property does not exist |
| 409 | Conflict | Duplicate unique property value |
| 429 | Too Many Requests | Rate limit exceeded |

### Standard Error Response Shape

```json
{
  "status": "error",
  "message": "Property value is not valid",
  "category": "VALIDATION_ERROR",
  "subCategory": "PropertyValidationError.INVALID_OPTION",
  "correlationId": "abc123",
  "context": {
    "propertyName": ["deal_category"],
    "value": ["unknown_value"]
  },
  "errors": [
    {
      "message": "Option 'unknown_value' is not defined for property 'deal_category'",
      "in": "body",
      "path": "properties.deal_category"
    }
  ]
}
```

### Known Gotchas

**Enumeration properties require at least one option at creation time.**
As of early 2025, creating an enumeration property with an empty `options: []` array returns a validation error. Always include at least a placeholder option and add more later via PATCH.

**Stage IDs are portal-specific.**
The stage IDs in the `default` pipeline (named `appointmentscheduled`, `qualifiedtobuy`, etc.) are HubSpot defaults that exist in every account. However, any additional pipeline stages use numeric IDs that differ between portals. Never hardcode stage IDs across accounts.

**`pipeline` property defaults to the primary pipeline.**
When creating a deal without specifying a `pipeline` property, it is placed in the portal's primary pipeline. If you have multiple pipelines, always specify `pipeline` explicitly to avoid ambiguity.

**Moving a deal between pipelines resets to the first stage unless `dealstage` is set.**
If you PATCH a deal with only `pipeline` (without `dealstage`), HubSpot automatically places the deal in the first stage of the new pipeline. Always send both `pipeline` and `dealstage` in the same request when changing pipelines.

**Multi-select enumeration values use semicolons as delimiters.**
When setting a `checkbox` (multi-select) enumeration property, use `"value1;value2;value3"`. A leading semicolon (`;value1;value2`) signals an append operation instead of replacement.

**`object_coordinates` and `json` types cannot be created via API.**
These are internal HubSpot types. Attempts to create properties with these types will fail with a validation error.

**`name`, `type`, `fieldType` are immutable.**
Once created, a property's internal name, data type, and field type cannot be changed. If you need to change the type, you must archive the old property and create a new one. All existing values on records are lost when a property is archived.

**Custom objects require Enterprise tier.**
The custom object schema API requires Enterprise tier across all applicable HubSpot hubs. Calls from non-Enterprise accounts return a 403 Forbidden error.

**`crm.schemas.custom.write` scope may not be recognized in public app configurations.**
A known issue (as of January 2026, per community reports) is that `crm.schemas.custom.write` fails to validate in some public app scope configurations during OAuth app review. For private apps and direct API access, this scope works correctly.

**Property group `name` cannot be changed after creation.**
Like property names, property group names are immutable. Only the `label` and `displayOrder` can be updated via PATCH.

**Delete operations are soft deletes by default.**
Deleting a property or pipeline archives it (sets `archived: true`) but does not permanently remove it. Archived properties retain their historical values. Hard deletes require special parameters (`?archived=true`) and may not be available for all resource types.

### Rate Limits

| Account Type | Limit |
|---|---|
| Private Apps | 110 requests per 10 seconds |
| OAuth Apps | 100 requests per 10 seconds per token |
| Batch endpoints | Count as 1 request; process up to 100 records |
| Daily limit | 250,000 API calls per day (private apps) |

For AI agents making frequent updates, use batch endpoints wherever possible and implement exponential backoff on 429 responses. HubSpot includes a `Retry-After` header on 429 responses indicating when to resume.

---

*Document compiled 2026-03-18 from developers.hubspot.com API documentation. API version: v3 (pipelines), v3 (properties), 2025-09 (versioned properties), v3 (custom object schemas). All tiers noted where applicable.*
