# HubSpot CRM API: Associations & Engagements — Complete Technical Reference

**Source:** developers.hubspot.com
**Date Saved:** 2026-03-18
**Scope:** Associations v4 API, Engagements API (Notes, Tasks, Calls, Meetings, Emails), Timeline Events API, AI Agent Integration Patterns
**Minimum Version:** HubSpot NodeJS Client v9.0.0+ for v4 Associations

---

## Table of Contents

1. [Associations Overview](#associations-overview)
2. [Association Categories and Type IDs](#association-categories-and-type-ids)
3. [Association Schema Endpoints](#association-schema-endpoints)
4. [Creating Associations](#creating-associations)
5. [Reading Associations](#reading-associations)
6. [Deleting Associations](#deleting-associations)
7. [Custom Association Labels](#custom-association-labels)
8. [Association Limits and Constraints](#association-limits-and-constraints)
9. [Engagements Overview](#engagements-overview)
10. [Notes API](#notes-api)
11. [Tasks API](#tasks-api)
12. [Calls API](#calls-api)
13. [Meetings API](#meetings-api)
14. [Emails API](#emails-api)
15. [Timeline Events API](#timeline-events-api)
16. [Batch Operations](#batch-operations)
17. [AI Agent Use Cases and Integration Patterns](#ai-agent-use-cases-and-integration-patterns)

---

## Associations Overview

Associations in HubSpot represent the relationships between CRM objects and activities. They allow you to link records such as contacts to companies, deals to contacts, tickets to companies, or any activity (note, call, meeting) to any record.

The **v4 Associations API** is the current standard as of 2024–2025, replacing the deprecated v3 Associations API. The architectural shift in v4 is the explicit declaration of both `associationCategory` and `associationTypeId` in every association operation — this eliminates ambiguity about what kind of relationship is being expressed.

### v4 vs v3: What Changed

| Feature | v3 (Deprecated) | v4 (Current) |
|---|---|---|
| Association category required | No | Yes (`HUBSPOT_DEFINED` or `USER_DEFINED`) |
| Labeled associations | Not supported | Fully supported |
| Batch read limit | Lower | 1,000 inputs |
| Batch create limit | Lower | 2,000 inputs |
| Custom labels | Not supported | Create and manage via schema endpoints |
| High-usage reporting | Not available | Available |
| NodeJS client version required | Any | v9.0.0+ |

The v3 API remains documented for legacy implementations but new integrations should always use v4. The type IDs for `HUBSPOT_DEFINED` associations are identical between v3 and v4 — if you have existing v3 type IDs, they remain valid in v4.

### Two Sets of Endpoints

The v4 Associations API is split into two categories:

1. **Association schema endpoints** — manage your account's association definitions: view types, create custom labels, set association limits
2. **Association details endpoints** — create, edit, and remove associations between actual CRM records

This document covers both categories in full.

---

## Association Categories and Type IDs

Every association in HubSpot has two identifying fields:

- `associationCategory` — either `HUBSPOT_DEFINED` (built-in, same across all portals) or `USER_DEFINED` (custom labels unique to your portal)
- `associationTypeId` — a numeric ID identifying the specific relationship type and direction

### Important Note on Static Type ID Lists

There is no single exhaustive static list of all HubSpot association type IDs published in the documentation. The reasons:

1. Custom labels (`USER_DEFINED`) create new type IDs unique to your portal — a "Billing Contact" label might be ID `28` in your account and `47` in another
2. HubSpot has expanded the number of supported object types significantly over time, adding new default type IDs
3. The most reliable method to discover type IDs for your portal is always to call the labels endpoint directly (covered in the Schema Endpoints section)

That said, `HUBSPOT_DEFINED` type IDs are consistent across all HubSpot accounts. The commonly observed defaults for standard object pairs are documented below.

### Object Type IDs Reference

Before diving into association type IDs, here are the object type IDs used throughout the API (these appear in endpoint path variables as `{fromObjectType}` and `{toObjectType}`):

| Object | Type ID |
|---|---|
| Contacts | `0-1` |
| Companies | `0-2` |
| Deals | `0-3` |
| Tickets | `0-5` |
| Products | `0-7` |
| Line Items | `0-8` |
| Notes | `0-46` |
| Meetings | `0-47` |
| Calls | `0-48` |
| Emails | `0-49` |
| Tasks | `0-27` |
| Quotes | `0-14` |
| Marketing Events | `0-54` |
| Invoices | `0-53` |
| Postal Mail | `0-116` |
| Users | `0-115` |
| Orders | `0-123` |
| Leads | `0-136` |
| Custom Objects | `2-XXX` |

For named objects (contacts, companies, deals, tickets, notes), you can use the object name string directly in endpoint paths instead of the numeric type ID.

### Default HUBSPOT_DEFINED Association Type IDs

These IDs are consistent across all HubSpot portals. Always use the discovery endpoint to verify for edge cases.

#### Contact Associations

| From | To | Type ID | Notes |
|---|---|---|---|
| Contact | Company (primary) | `1` | Sets the contact's primary company |
| Company | Contact (primary) | `2` | Reverse of above |
| Contact | Company (unlabeled) | `279` | Non-primary company association |
| Company | Contact (unlabeled) | `280` | Reverse of above |
| Contact | Deal | `4` | |
| Deal | Contact | `3` | |
| Contact | Ticket | `15` | |
| Ticket | Contact | `16` | |
| Contact | Note | `202` | |
| Note | Contact | `201` | |
| Contact | Call | `194` | |
| Call | Contact | `193` | |
| Contact | Email | `198` | |
| Email | Contact | `197` | |
| Contact | Meeting | `200` | |
| Meeting | Contact | `199` | |
| Contact | Task | `204` | |
| Task | Contact | `203` | |

#### Company Associations

| From | To | Type ID | Notes |
|---|---|---|---|
| Company | Deal | `342` | |
| Deal | Company | `341` | |
| Company | Ticket | `25` | |
| Ticket | Company | `26` | |
| Company | Note | `190` | |
| Note | Company | `189` | |
| Company | Call | `182` | |
| Call | Company | `181` | |
| Company | Meeting | `188` | |
| Meeting | Company | `187` | |
| Company | Email | `186` | |
| Email | Company | `185` | |
| Company | Task | `192` | |
| Task | Company | `191` | |

#### Deal Associations

| From | To | Type ID | Notes |
|---|---|---|---|
| Deal | Ticket | `27` | |
| Ticket | Deal | `28` | |
| Deal | Line Item | `19` | |
| Line Item | Deal | `20` | |
| Deal | Note | `214` | |
| Note | Deal | `213` | |
| Deal | Call | `206` | |
| Call | Deal | `205` | |
| Deal | Meeting | `212` | |
| Meeting | Deal | `211` | |
| Deal | Email | `210` | |
| Email | Deal | `209` | |
| Deal | Task | `216` | |
| Task | Deal | `215` | |

#### Ticket Associations

| From | To | Type ID | Notes |
|---|---|---|---|
| Ticket | Note | `222` | |
| Note | Ticket | `221` | |
| Ticket | Call | `220` (approx) | Verify via labels endpoint |
| Ticket | Meeting | `220` | |
| Meeting | Ticket | `219` | |

### How to Discover Type IDs Programmatically

Always run this before hardcoding type IDs:

```bash
curl --request GET \
  --url 'https://api.hubapi.com/crm/v4/associations/{fromObjectType}/{toObjectType}/labels' \
  --header 'authorization: Bearer YOUR_ACCESS_TOKEN'
```

Example — get all types between deals and contacts:

```bash
curl --request GET \
  --url 'https://api.hubapi.com/crm/v4/associations/deals/contacts/labels' \
  --header 'authorization: Bearer YOUR_ACCESS_TOKEN'
```

Example response:

```json
{
  "results": [
    {
      "category": "HUBSPOT_DEFINED",
      "typeId": 3,
      "label": null
    },
    {
      "category": "HUBSPOT_DEFINED",
      "typeId": 4,
      "label": null
    },
    {
      "category": "USER_DEFINED",
      "typeId": 28,
      "label": "Decision Maker"
    }
  ]
}
```

The `typeId` values in this response are what you use in all association create/update operations.

---

## Association Schema Endpoints

Schema endpoints let you inspect, create, and manage the definitions (types and labels) of associations in your account.

### Get All Association Types Between Two Objects

```
GET /crm/v4/associations/{fromObjectType}/{toObjectType}/labels
```

Returns all association label definitions, both `HUBSPOT_DEFINED` and `USER_DEFINED`.

### Create a Custom Association Label

```
POST /crm/v4/associations/{fromObjectType}/{toObjectType}/labels
```

Request body:

```json
{
  "label": "Decision Maker",
  "name": "decision_maker"
}
```

Response:

```json
{
  "results": [
    {
      "category": "USER_DEFINED",
      "typeId": 28,
      "label": "Decision Maker"
    },
    {
      "category": "USER_DEFINED",
      "typeId": 29,
      "label": "Decision Maker"
    }
  ]
}
```

Note: HubSpot creates two type IDs for every custom label — one for each direction of the association (from → to and to → from).

### Update a Custom Association Label

```
PUT /crm/v4/associations/{fromObjectType}/{toObjectType}/labels
```

Request body:

```json
{
  "associationTypeId": 28,
  "label": "Primary Decision Maker"
}
```

### Delete a Custom Association Label

```
DELETE /crm/v4/associations/{fromObjectType}/{toObjectType}/labels/{associationTypeId}
```

### Set Association Limits

You can control the maximum number of associations a record can have toward a specific object type:

```
POST /crm/v4/associations/{fromObjectType}/{toObjectType}/schema/associate/default
```

---

## Creating Associations

### Individual Association Without a Label

The simplest form — create an unlabeled (default) association between two records:

```
PUT /crm/v4/objects/{fromObjectType}/{fromObjectId}/associations/default/{toObjectType}/{toObjectId}
```

Example — associate contact `12345` with company `67891`:

```
PUT /crm/v4/objects/contact/12345/associations/default/company/67891
```

No request body required. Returns `204 No Content` on success.

### Individual Association With a Label

Create an association with one or more custom labels:

```
PUT /crm/v4/objects/{fromObjectType}/{fromObjectId}/associations/{toObjectType}/{toObjectId}
```

Request body (array of association types):

```json
[
  {
    "associationCategory": "HUBSPOT_DEFINED",
    "associationTypeId": 1
  }
]
```

To add a custom label simultaneously:

```json
[
  {
    "associationCategory": "HUBSPOT_DEFINED",
    "associationTypeId": 1
  },
  {
    "associationCategory": "USER_DEFINED",
    "associationTypeId": 28
  }
]
```

Success response (200):

```json
{
  "fromObjectTypeId": "0-1",
  "fromObjectId": 29851,
  "toObjectTypeId": "0-2",
  "toObjectId": 67891,
  "labels": ["Decision Maker"]
}
```

### Batch Associate Without Labels (Default)

Associate multiple record pairs at once without labels:

```
POST /crm/v4/associations/{fromObjectType}/{toObjectType}/batch/associate/default
```

Request body:

```json
{
  "inputs": [
    {
      "from": {"id": "12345"},
      "to": {"id": "67891"}
    },
    {
      "from": {"id": "12346"},
      "to": {"id": "67892"}
    }
  ]
}
```

Maximum 2,000 inputs per request.

### Batch Associate With Labels

```
POST /crm/v4/associations/{fromObjectType}/{toObjectType}/batch/create
```

Request body:

```json
{
  "inputs": [
    {
      "from": {"id": "12345"},
      "to": {"id": "67891"},
      "types": [
        {
          "associationCategory": "HUBSPOT_DEFINED",
          "associationTypeId": 1
        },
        {
          "associationCategory": "USER_DEFINED",
          "associationTypeId": 28
        }
      ]
    }
  ]
}
```

Success response (200):

```json
{
  "status": "COMPLETE",
  "results": [
    {
      "fromObjectTypeId": "0-1",
      "fromObjectId": 12345,
      "toObjectTypeId": "0-2",
      "toObjectId": 67891,
      "labels": ["Decision Maker"]
    }
  ],
  "startedAt": "2024-10-21T20:22:42.152Z",
  "completedAt": "2024-10-21T20:22:42.167Z"
}
```

---

## Reading Associations

### Read Associations for a Single Record

```
GET /crm/v4/objects/{fromObjectType}/{objectId}/associations/{toObjectType}
```

Example — get all companies associated with contact `12345`:

```
GET /crm/v4/objects/contact/12345/associations/company
```

Response:

```json
{
  "results": [
    {
      "toObjectId": 67891,
      "associationTypes": [
        {
          "category": "HUBSPOT_DEFINED",
          "typeId": 1,
          "label": "Primary"
        },
        {
          "category": "USER_DEFINED",
          "typeId": 28,
          "label": "Decision Maker"
        }
      ]
    }
  ],
  "paging": {
    "next": {
      "after": "NTI1Cg=="
    }
  }
}
```

### Batch Read Associations

Get associations for multiple records simultaneously:

```
POST /crm/v4/associations/{fromObjectType}/{toObjectType}/batch/read
```

Request body:

```json
{
  "inputs": [
    {"id": "12345"},
    {"id": "12346"},
    {"id": "12347"}
  ]
}
```

Maximum 1,000 inputs per request.

Response:

```json
{
  "status": "COMPLETE",
  "results": [
    {
      "from": {"id": "12345"},
      "to": [
        {
          "toObjectId": 67891,
          "associationTypes": [
            {
              "category": "HUBSPOT_DEFINED",
              "typeId": 1,
              "label": "Primary"
            }
          ]
        }
      ]
    },
    {
      "from": {"id": "12346"},
      "to": []
    }
  ],
  "startedAt": "2024-10-21T20:22:42.152Z",
  "completedAt": "2024-10-21T20:22:42.167Z"
}
```

---

## Deleting Associations

### Delete All Associations Between Two Records

Removes all association types (both labeled and unlabeled) between two specific records:

```
DELETE /crm/v4/objects/{objectType}/{objectId}/associations/{toObjectType}/{toObjectId}
```

Example — remove all associations between contact `12345` and company `67891`:

```
DELETE /crm/v4/objects/contact/12345/associations/company/67891
```

Returns `204 No Content` on success.

### Batch Delete All Associations

Remove all associations for multiple record pairs at once:

```
POST /crm/v4/associations/{fromObjectType}/{toObjectType}/batch/archive
```

Request body:

```json
{
  "inputs": [
    {
      "from": {"id": "12345"},
      "to": {"id": "67891"}
    }
  ]
}
```

### Delete Specific Labels Only (Without Removing the Association)

Remove one or more specific labels while keeping the underlying association (and any other labels):

```
POST /crm/v4/associations/{fromObjectType}/{toObjectType}/batch/labels/archive
```

Request body:

```json
{
  "inputs": [
    {
      "from": {"id": "12345"},
      "to": {"id": "67891"},
      "types": [
        {
          "associationCategory": "USER_DEFINED",
          "associationTypeId": 28
        }
      ]
    }
  ]
}
```

This removes only the "Decision Maker" label from the contact-company association, leaving any other labels and the base association intact.

---

## Custom Association Labels

Custom labels allow you to add semantic meaning to associations beyond the default "related to" relationship. They're created at the account level and apply to specific object-type pairs.

### Key Behaviors

- When you create a custom label, HubSpot generates two `USER_DEFINED` type IDs (one per direction)
- Custom type IDs are unique per portal — do not hardcode them across environments
- A single record-to-record association can have multiple labels simultaneously
- Labels can be added to existing associations without disrupting other labels
- Labels can be removed individually without deleting the base association
- HubSpot limits labeled associations per record based on subscription tier

### Common Custom Label Examples for AI Agent Integrations

```
POST /crm/v4/associations/contacts/companies/labels

{
  "label": "AI Lead Source",
  "name": "ai_lead_source"
}
```

```
POST /crm/v4/associations/contacts/deals/labels

{
  "label": "AI Qualified",
  "name": "ai_qualified"
}
```

### Primary Company Association

Only one company can be marked as a contact's "primary" company. If you try to create a second primary company association, HubSpot replaces the previous one. Use `typeId: 1` for the primary contact-to-company relationship.

### Bidirectional vs. Unidirectional

All HubSpot associations are technically bidirectional — every association is stored in both directions. When you create a contact-to-company association with `typeId: 1`, HubSpot automatically creates the reverse `typeId: 2` (company-to-contact). Reading associations from the contact side returns `typeId: 1`; reading from the company side returns `typeId: 2`. This is why the labels endpoint always returns paired type IDs.

---

## Association Limits and Constraints

### Per-Request Limits

| Operation | Limit |
|---|---|
| Batch read inputs | 1,000 |
| Batch create inputs | 2,000 |
| Batch archive inputs | 2,000 |

### Rate Limits

| Plan | Daily Requests | Burst Rate |
|---|---|---|
| Free / Starter | 250,000 | 100 req / 10 seconds |
| Professional / Enterprise | 500,000 | 150 req / 10 seconds |
| With API rate limit add-on | Up to 1,000,000 | 200 req / 10 seconds |

### Per-Record Association Limits

The number of associations a single record can have depends on the object type and subscription tier. HubSpot provides a high-usage reporting endpoint to identify records approaching their limits:

```
POST /crm/v4/associations/usage/high-usage-report/{userId}
```

This returns records exceeding 80% of their association capacity, which is useful for proactive maintenance in high-volume AI agent deployments.

### Scope Requirements

All association operations require the read and write scopes for the object types involved:

- `crm.objects.contacts.read` / `crm.objects.contacts.write`
- `crm.objects.companies.read` / `crm.objects.companies.write`
- `crm.objects.deals.read` / `crm.objects.deals.write`
- `crm.objects.tickets.read` / `crm.objects.tickets.write`

---

## Engagements Overview

In HubSpot, "engagements" is the umbrella term for all tracked interactions between your team and CRM records. There are five core engagement types, each with its own dedicated API endpoint under the CRM v3 objects pattern:

| Type | Object Type ID | Endpoint Base |
|---|---|---|
| Notes | `0-46` | `/crm/v3/objects/notes` |
| Tasks | `0-27` | `/crm/v3/objects/tasks` |
| Calls | `0-48` | `/crm/v3/objects/calls` |
| Meetings | `0-47` | `/crm/v3/objects/meetings` |
| Emails | `0-49` | `/crm/v3/objects/emails` |

### Legacy v1 Engagements API

A legacy engagements API at `/engagements/v1/engagements` still exists and is documented, but HubSpot has redirected its documentation to the newer per-object endpoints. The v1 API used a single `engagements` endpoint with a `type` field to differentiate NOTE, TASK, CALL, MEETING, EMAIL. All new integrations should use the per-object v3 endpoints. The legacy v1 is primarily referenced for reading historical engagement data that predates the v3 migration.

### Common Patterns Across All Engagement Types

All five engagement types share a consistent structure:

1. **`hs_timestamp`** — required on all engagement types; sets the timestamp shown in the record timeline
2. **`properties`** object — contains all engagement-specific fields
3. **`associations`** object — links the engagement to CRM records on creation
4. **`hubspot_owner_id`** — assigns the engagement to a specific HubSpot user
5. **Pinning** — any engagement can be pinned to a record's top via `hs_pinned_engagement_id`
6. **Batch operations** — all types support batch create, batch read, batch update, batch delete
7. **Soft delete** — deleted engagements go to the record's recycling bin and can be restored

---

## Notes API

Notes are the most common engagement type for AI agent integrations. They allow you to record text-based information on any CRM record timeline.

### Endpoints

| Operation | Method | Endpoint |
|---|---|---|
| Create note | POST | `/crm/v3/objects/notes` |
| Get note | GET | `/crm/v3/objects/notes/{noteId}` |
| List all notes | GET | `/crm/v3/objects/notes` |
| Update note | PATCH | `/crm/v3/objects/notes/{noteId}` |
| Associate note | PUT | `/crm/v3/objects/notes/{noteId}/associations/{toObjectType}/{toObjectId}/{associationTypeId}` |
| Remove association | DELETE | `/crm/v3/objects/notes/{noteId}/associations/{toObjectType}/{toObjectId}/{associationTypeId}` |
| Delete note | DELETE | `/crm/v3/objects/notes/{noteId}` |
| Batch create | POST | `/crm/v3/objects/notes/batch/create` |
| Batch read | POST | `/crm/v3/objects/notes/batch/read` |
| Batch update | POST | `/crm/v3/objects/notes/batch/update` |

### Note Properties

| Property | Required | Type | Description |
|---|---|---|---|
| `hs_timestamp` | Yes | Unix ms or UTC string | Sets position on timeline |
| `hs_note_body` | No | String (max 65,536 chars) | Text content of the note |
| `hubspot_owner_id` | No | String | HubSpot user ID of note creator |
| `hs_attachment_ids` | No | String | Semicolon-separated attachment IDs |

### Create Note with Associations

```json
POST /crm/v3/objects/notes

{
  "properties": {
    "hs_timestamp": "2026-03-18T10:30:00Z",
    "hs_note_body": "AI agent completed qualification call. Lead scored as HOT. Key pain points: lack of automation, manual data entry overhead. Next step: send proposal by 2026-03-20.",
    "hubspot_owner_id": "14240720"
  },
  "associations": [
    {
      "to": {"id": "101"},
      "types": [
        {
          "associationCategory": "HUBSPOT_DEFINED",
          "associationTypeId": 202
        }
      ]
    },
    {
      "to": {"id": "5001"},
      "types": [
        {
          "associationCategory": "HUBSPOT_DEFINED",
          "associationTypeId": 214
        }
      ]
    }
  ]
}
```

This creates one note associated to both a contact (type `202`) and a deal (type `214`) simultaneously.

Success response (201):

```json
{
  "id": "987654321",
  "properties": {
    "hs_timestamp": "2026-03-18T10:30:00.000Z",
    "hs_note_body": "AI agent completed qualification call...",
    "hubspot_owner_id": "14240720",
    "hs_createdate": "2026-03-18T10:30:05.000Z",
    "hs_lastmodifieddate": "2026-03-18T10:30:05.000Z"
  },
  "createdAt": "2026-03-18T10:30:05.000Z",
  "updatedAt": "2026-03-18T10:30:05.000Z",
  "archived": false
}
```

### Batch Create Notes

```json
POST /crm/v3/objects/notes/batch/create

{
  "inputs": [
    {
      "properties": {
        "hs_timestamp": "2026-03-18T10:00:00Z",
        "hs_note_body": "First agent interaction logged.",
        "hubspot_owner_id": "14240720"
      },
      "associations": [
        {
          "to": {"id": "101"},
          "types": [{"associationCategory": "HUBSPOT_DEFINED", "associationTypeId": 202}]
        }
      ]
    },
    {
      "properties": {
        "hs_timestamp": "2026-03-18T10:05:00Z",
        "hs_note_body": "Second agent interaction logged.",
        "hubspot_owner_id": "14240720"
      },
      "associations": [
        {
          "to": {"id": "102"},
          "types": [{"associationCategory": "HUBSPOT_DEFINED", "associationTypeId": 202}]
        }
      ]
    }
  ]
}
```

### Retrieve Notes for a Contact

To get all notes associated with a contact, use the associations endpoint to first get note IDs, then retrieve the notes:

```
GET /crm/v3/objects/contacts/101/associations/notes
```

Then retrieve each note:

```
GET /crm/v3/objects/notes/987654321?properties=hs_note_body,hs_timestamp,hubspot_owner_id
```

Or retrieve multiple by passing IDs to the batch read endpoint.

### Pinning a Note

Pin a note to the top of a record's timeline by including the note ID in `hs_pinned_engagement_id` when updating the associated record:

```json
PATCH /crm/v3/objects/contacts/101

{
  "properties": {
    "hs_pinned_engagement_id": "987654321"
  }
}
```

---

## Tasks API

Tasks represent action items assigned to team members or AI agents with due dates, priorities, and completion status.

### Endpoints

| Operation | Method | Endpoint |
|---|---|---|
| Create task | POST | `/crm/v3/objects/tasks` |
| Get task | GET | `/crm/v3/objects/tasks/{taskId}` |
| List all tasks | GET | `/crm/v3/objects/tasks` |
| Update task | PATCH | `/crm/v3/objects/tasks/{taskId}` |
| Associate task | PUT | `/crm/v3/objects/tasks/{taskId}/associations/{toObjectType}/{toObjectId}/{associationTypeId}` |
| Remove association | DELETE | `/crm/v3/objects/tasks/{taskId}/associations/{toObjectType}/{toObjectId}/{associationTypeId}` |
| Delete task | DELETE | `/crm/v3/objects/tasks/{taskId}` |
| Batch create | POST | `/crm/v3/objects/tasks/batch/create` |
| Batch update | POST | `/crm/v3/objects/tasks/batch/update` |

### Task Properties

| Property | Required | Type | Values / Notes |
|---|---|---|---|
| `hs_timestamp` | Yes | Unix ms or UTC string | Due date — positions task on timeline |
| `hs_task_subject` | No | String | Task title (visible in UI) |
| `hs_task_body` | No | String | Task description / notes |
| `hs_task_status` | No | Enum | `NOT_STARTED`, `COMPLETED` |
| `hs_task_priority` | No | Enum | `LOW`, `MEDIUM`, `HIGH` |
| `hs_task_type` | No | Enum | `EMAIL`, `CALL`, `TODO` |
| `hubspot_owner_id` | No | String | User ID of assignee |
| `hs_task_reminders` | No | Unix ms | When to send the reminder alert |

### Create Task with Contact Association

```json
POST /crm/v3/objects/tasks

{
  "properties": {
    "hs_timestamp": "2026-03-20T09:00:00Z",
    "hs_task_subject": "Send proposal to Brian — AI follow-up",
    "hs_task_body": "AI agent qualified this lead as HOT on 2026-03-18. Proposal should include pricing tier 2 and enterprise onboarding. Remind about WBSO tax advantage.",
    "hs_task_status": "NOT_STARTED",
    "hs_task_priority": "HIGH",
    "hs_task_type": "TODO",
    "hubspot_owner_id": "64492917",
    "hs_task_reminders": "1742461200000"
  },
  "associations": [
    {
      "to": {"id": 101},
      "types": [
        {
          "associationCategory": "HUBSPOT_DEFINED",
          "associationTypeId": 204
        }
      ]
    }
  ]
}
```

### Create Follow-Up Call Task

```json
POST /crm/v3/objects/tasks

{
  "properties": {
    "hs_timestamp": "2026-03-21T14:00:00Z",
    "hs_task_subject": "Follow-up call — AI scheduled",
    "hs_task_body": "Contact expressed interest in Q2 rollout. Call to confirm budget approval from CFO. Key objection: integration complexity with legacy ERP.",
    "hs_task_status": "NOT_STARTED",
    "hs_task_priority": "MEDIUM",
    "hs_task_type": "CALL",
    "hubspot_owner_id": "64492917"
  },
  "associations": [
    {
      "to": {"id": 101},
      "types": [
        {
          "associationCategory": "HUBSPOT_DEFINED",
          "associationTypeId": 204
        }
      ]
    },
    {
      "to": {"id": 5001},
      "types": [
        {
          "associationCategory": "HUBSPOT_DEFINED",
          "associationTypeId": 216
        }
      ]
    }
  ]
}
```

### Complete a Task

```json
PATCH /crm/v3/objects/tasks/{taskId}

{
  "properties": {
    "hs_task_status": "COMPLETED"
  }
}
```

---

## Calls API

The calls API logs phone call interactions including duration, direction, recording URLs, and outcomes (dispositions).

### Endpoints

| Operation | Method | Endpoint |
|---|---|---|
| Create call | POST | `/crm/v3/objects/calls` |
| Get call | GET | `/crm/v3/objects/calls/{callId}` |
| List all calls | GET | `/crm/v3/objects/calls` |
| Update call | PATCH | `/crm/v3/objects/calls/{callId}` |
| Associate call | PUT | `/crm/v3/objects/calls/{callId}/associations/{toObjectType}/{toObjectId}/{associationTypeId}` |
| Remove association | DELETE | `/crm/v3/objects/calls/{callId}/associations/{toObjectType}/{toObjectId}/{associationTypeId}` |
| Delete call | DELETE | `/crm/v3/objects/calls/{callId}` |
| Get dispositions | GET | `/calling/v1/dispositions` |

### Call Properties

| Property | Required | Type | Description |
|---|---|---|---|
| `hs_timestamp` | Yes | Unix ms or UTC string | When the call occurred |
| `hs_call_direction` | No | Enum | `INBOUND` or `OUTBOUND` |
| `hs_call_duration` | No | Integer | Duration in milliseconds |
| `hs_call_status` | No | Enum | See status values below |
| `hs_call_body` | No | String | Call notes / description |
| `hs_call_title` | No | String | Call title |
| `hs_call_disposition` | No | GUID string | Call outcome — use GUID values |
| `hs_call_from_number` | No | String | Caller's phone number |
| `hs_call_to_number` | No | String | Recipient's phone number |
| `hs_call_recording_url` | No | HTTPS URL | URL to .mp3 or .wav recording |
| `hs_call_source` | No | String | Set to `INTEGRATIONS_PLATFORM` for recording pipeline |
| `hs_call_callee_object_id` | No | String | ID of the associated HubSpot record |
| `hs_call_callee_object_type` | No | String | Object type of the callee |
| `hubspot_owner_id` | No | String | HubSpot user ID of call creator |
| `hs_activity_type` | No | String | Call type from account settings |
| `hs_attachment_ids` | No | String | Semicolon-separated attachment IDs |

### Call Status Values

| Status | Description |
|---|---|
| `COMPLETED` | Call finished normally |
| `IN_PROGRESS` | Call currently active |
| `MISSED` | Inbound call not answered |
| `NO_ANSWER` | Outbound call not answered |
| `BUSY` | Line was busy |
| `FAILED` | Call failed |
| `CANCELED` | Call was canceled |
| `QUEUED` | Call is queued |
| `RINGING` | Phone is ringing |
| `CALLING_CRM_USER` | Connecting to CRM user |
| `CONNECTING` | Establishing connection |

### Call Disposition GUIDs (Default HubSpot Outcomes)

These GUIDs are consistent across all HubSpot accounts for the default disposition outcomes:

| Outcome Label | GUID |
|---|---|
| Busy | `9d9162e7-6cf3-4944-bf63-4dff82258764` |
| Connected | `f240bbac-87c9-4f6e-bf70-924b57d47db7` |
| Left live message | `a4c4c377-d246-4b32-a13b-75a56a4cd0ff` |
| Left voicemail | `b2cf5968-551e-4856-9783-52b3da59a7d0` |
| No answer | `73a0d17f-1163-4015-bdd5-ec830791da20` |
| Wrong number | `17b47fee-58de-441e-a44c-c6300d46f273` |

For custom call outcomes set in your HubSpot account, retrieve their GUIDs via:

```
GET /calling/v1/dispositions
```

### Create Call Engagement

```json
POST /crm/v3/objects/calls

{
  "properties": {
    "hs_timestamp": "2026-03-18T14:30:00Z",
    "hs_call_title": "Discovery Call — AI Voice Agent",
    "hs_call_body": "AI voice agent conducted initial discovery. Contact confirmed budget of $50K, decision timeline Q3 2026. Champions: Sarah (VP Sales) and Mark (IT Director). Objection: data privacy compliance.",
    "hs_call_direction": "OUTBOUND",
    "hs_call_duration": "1620000",
    "hs_call_from_number": "+31612345678",
    "hs_call_to_number": "+31698765432",
    "hs_call_status": "COMPLETED",
    "hs_call_disposition": "f240bbac-87c9-4f6e-bf70-924b57d47db7",
    "hs_call_recording_url": "https://recordings.example.com/calls/2026-03-18-discovery.mp3",
    "hs_call_source": "INTEGRATIONS_PLATFORM",
    "hubspot_owner_id": "64492917"
  },
  "associations": [
    {
      "to": {"id": 500},
      "types": [
        {
          "associationCategory": "HUBSPOT_DEFINED",
          "associationTypeId": 194
        }
      ]
    },
    {
      "to": {"id": 5001},
      "types": [
        {
          "associationCategory": "HUBSPOT_DEFINED",
          "associationTypeId": 206
        }
      ]
    }
  ]
}
```

### Voicemail Detection

For accounts with inbound calling, differentiate completed recorded calls from voicemails by requesting both `hs_call_status` and `hs_call_has_voicemail`:

- Voicemail: `hs_call_status = "missed"` and `hs_call_has_voicemail = true`
- Completed recorded call: `hs_call_status = "COMPLETED"` and `hs_call_has_voicemail = false`
- Other status: `hs_call_has_voicemail = null`

---

## Meetings API

Meetings log scheduled or completed meeting interactions with contacts. Useful for logging AI-booked appointments or calls that were logged as video meetings.

### Endpoints

| Operation | Method | Endpoint |
|---|---|---|
| Create meeting | POST | `/crm/v3/objects/meetings` |
| Get meeting | GET | `/crm/v3/objects/meetings/{meetingId}` |
| List all meetings | GET | `/crm/v3/objects/meetings` |
| Update meeting | PATCH | `/crm/v3/objects/meetings/{meetingId}` |
| Associate meeting | PUT | `/crm/v3/objects/meetings/{meetingId}/associations/{toObjectType}/{toObjectId}/{associationTypeId}` |
| Remove association | DELETE | `/crm/v3/objects/meetings/{meetingId}/associations/{toObjectType}/{toObjectId}/{associationTypeId}` |
| Delete meeting | DELETE | `/crm/v3/objects/meetings/{meetingId}` |

### Meeting Properties

| Property | Required | Type | Description |
|---|---|---|---|
| `hs_timestamp` | Yes | Unix ms or UTC string | When the meeting occurred |
| `hs_meeting_title` | No | String | Meeting title |
| `hs_meeting_body` | No | String | Meeting description |
| `hs_meeting_start_time` | No | ISO 8601 datetime | Meeting start time |
| `hs_meeting_end_time` | No | ISO 8601 datetime | Meeting end time |
| `hs_meeting_location` | No | String | Address, room, or video link |
| `hs_meeting_outcome` | No | Enum | `SCHEDULED`, `COMPLETED`, `RESCHEDULED`, `NO_SHOW`, `CANCELED` |
| `hs_internal_meeting_notes` | No | String | Internal team notes not shared with contact |
| `hs_meeting_external_url` | No | URL | Link to Google/Outlook calendar event |
| `hs_activity_type` | No | String | Meeting type from account settings |
| `hs_attachment_ids` | No | String | Semicolon-separated attachment IDs |
| `hubspot_owner_id` | No | String | User ID of meeting creator |

### Create Meeting

```json
POST /crm/v3/objects/meetings

{
  "properties": {
    "hs_timestamp": "2026-03-20T10:00:00Z",
    "hs_meeting_title": "Product Demo — AI Booked",
    "hs_meeting_body": "AI agent booked this demo via calendly integration after lead scored HOT. Contact wants to see enterprise CRM automation features.",
    "hs_meeting_start_time": "2026-03-20T10:00:00Z",
    "hs_meeting_end_time": "2026-03-20T11:00:00Z",
    "hs_meeting_location": "https://meet.google.com/abc-defg-hij",
    "hs_meeting_outcome": "SCHEDULED",
    "hs_internal_meeting_notes": "Prioritize: multi-user permissions, API rate limits, SOC2 compliance docs",
    "hubspot_owner_id": "64492917"
  },
  "associations": [
    {
      "to": {"id": 101},
      "types": [
        {
          "associationCategory": "HUBSPOT_DEFINED",
          "associationTypeId": 200
        }
      ]
    }
  ]
}
```

### Update Meeting Outcome After It Occurs

```json
PATCH /crm/v3/objects/meetings/{meetingId}

{
  "properties": {
    "hs_meeting_outcome": "COMPLETED",
    "hs_internal_meeting_notes": "Demo successful. Contact requested security questionnaire and pilot terms. Follow up within 48h."
  }
}
```

---

## Emails API

The emails engagement API logs email interactions as activities on CRM records. These are logged emails (not bulk marketing emails) — they represent individual 1:1 email communications.

### Endpoints

| Operation | Method | Endpoint |
|---|---|---|
| Create email | POST | `/crm/v3/objects/emails` |
| Get email | GET | `/crm/v3/objects/emails/{emailId}` |
| List all emails | GET | `/crm/v3/objects/emails` |
| Update email | PATCH | `/crm/v3/objects/emails/{emailId}` |
| Associate email | PUT | `/crm/v3/objects/emails/{emailId}/associations/{toObjectType}/{toObjectId}/{associationTypeId}` |
| Delete email | DELETE | `/crm/v3/objects/emails/{emailId}` |

### Email Properties

| Property | Type | Description |
|---|---|---|
| `hs_timestamp` | Required | When the email was sent/received |
| `hs_email_direction` | Enum | `EMAIL` (outbound), `INCOMING_EMAIL` (inbound), `FORWARDED_EMAIL` |
| `hs_email_subject` | String | Email subject line |
| `hs_email_text` | String | Plain text email body |
| `hs_email_html` | String | HTML email body |
| `hs_email_status` | Enum | `SENT`, `BOUNCED`, `SCHEDULED`, `FAILED` |
| `hs_email_from_firstname` | String | Sender first name |
| `hs_email_from_lastname` | String | Sender last name |
| `hs_email_from_email` | String | Sender email address |
| `hs_email_to_firstname` | String | Recipient first name |
| `hs_email_to_lastname` | String | Recipient last name |
| `hs_email_to_email` | String | Recipient email address |
| `hubspot_owner_id` | String | HubSpot user ID |
| `hs_attachment_ids` | String | Semicolon-separated attachment IDs |

### Create Email Engagement

```json
POST /crm/v3/objects/emails

{
  "properties": {
    "hs_timestamp": "2026-03-18T16:00:00Z",
    "hs_email_direction": "EMAIL",
    "hs_email_subject": "Proposal for Enterprise CRM Automation — Alexander Thompson",
    "hs_email_text": "Hi Brian,\n\nFollowing our discovery call today, I've prepared a customized proposal...",
    "hs_email_status": "SENT",
    "hs_email_from_email": "alexander@example.com",
    "hs_email_to_email": "brian@prospect.com",
    "hubspot_owner_id": "64492917"
  },
  "associations": [
    {
      "to": {"id": 101},
      "types": [
        {
          "associationCategory": "HUBSPOT_DEFINED",
          "associationTypeId": 198
        }
      ]
    }
  ]
}
```

---

## Timeline Events API

Timeline events allow external applications and AI agents to inject custom-formatted event data directly into CRM record timelines. Unlike notes and calls (which are first-party HubSpot objects), timeline events are owned by your app and display custom content defined via Handlebars templates.

### When to Use Timeline Events vs. Notes

| Use Case | Best Approach |
|---|---|
| Simple text log | Note (`/crm/v3/objects/notes`) |
| Structured event with custom properties | Timeline event |
| Event visible in HubSpot reports | Timeline event |
| Event linkable to external system | Timeline event (with iframe) |
| Batch logging for AI conversations | Note (simpler) or Timeline event (richer) |
| Custom segmentation by event type | Timeline event |

### Authentication Requirements

Timeline events have a split authentication model:

- **Event template management** (create, update, delete templates) — Developer API key or private app access token
- **Creating event instances** — OAuth 2.0 access token ONLY (developer API keys cannot create event instances)

### Scope Requirements

At least one of: `crm.objects.*.read/write`, `crm.schemas.*.read/write`, `tickets`, or `timeline`

### Event Template Endpoints

```
POST   /integrators/timeline/v3/{appId}/event-templates     — Create template
GET    /integrators/timeline/v3/{appId}/event-templates     — Get all templates
GET    /integrators/timeline/v3/{appId}/event-templates/{eventTemplateId}  — Get single template
PUT    /integrators/timeline/v3/{appId}/event-templates/{eventTemplateId}  — Update template
DELETE /integrators/timeline/v3/{appId}/event-templates/{eventTemplateId}  — Delete template
```

### Create Event Template

```json
POST /integrators/timeline/v3/{appId}/event-templates

{
  "name": "AI Agent Interaction",
  "objectType": "contacts",
  "headerTemplate": "{{agentName}} interacted with this contact — {{outcome}}",
  "detailTemplate": "**Session ID:** {{sessionId}}\n**Duration:** {{duration}} seconds\n**Confidence Score:** {{confidenceScore}}\n**Summary:** {{summary}}",
  "tokens": [
    {
      "name": "agentName",
      "label": "Agent Name",
      "type": "string"
    },
    {
      "name": "outcome",
      "label": "Interaction Outcome",
      "type": "enumeration",
      "options": [
        {"label": "Qualified", "value": "qualified"},
        {"label": "Not Qualified", "value": "not_qualified"},
        {"label": "Follow-up Needed", "value": "follow_up"},
        {"label": "Booked Meeting", "value": "booked_meeting"}
      ]
    },
    {
      "name": "sessionId",
      "label": "Session ID",
      "type": "string"
    },
    {
      "name": "duration",
      "label": "Duration (seconds)",
      "type": "number"
    },
    {
      "name": "confidenceScore",
      "label": "Confidence Score",
      "type": "number"
    },
    {
      "name": "summary",
      "label": "Interaction Summary",
      "type": "string"
    }
  ]
}
```

### Token Types

| Type | Description | Notes |
|---|---|---|
| `string` | Plain text | Up to 510 KB |
| `number` | Numeric value | |
| `enumeration` | Predefined options list | Include `options` array |
| `date` | Unix timestamp in milliseconds | Use `{{#formatDate token}}{{/formatDate}}` in template |

### Token Naming Rules

- Must be unique within the template
- Alphanumeric characters, periods, dashes, underscores only
- Can be mapped to CRM object properties via `objectPropertyName` field

### Create Event Instance

Once you have a template, create events (instances of that template) for specific records:

```json
POST /crm/v3/timeline/events

{
  "eventTemplateId": "1234567",
  "objectId": "101",
  "timestamp": "2026-03-18T14:30:00Z",
  "tokens": {
    "agentName": "Jarvis AI Agent v2",
    "outcome": "qualified",
    "sessionId": "sess_abc123xyz",
    "duration": 847,
    "confidenceScore": 0.92,
    "summary": "Contact confirmed $50K budget, Q3 timeline. Champions identified. No major blockers. Recommend demo within 5 business days."
  }
}
```

For contacts, you can identify by email instead of objectId:

```json
{
  "eventTemplateId": "1234567",
  "email": "brian@prospect.com",
  "timestamp": "2026-03-18T14:30:00Z",
  "tokens": { ... }
}
```

Or by HubSpot tracking token:

```json
{
  "eventTemplateId": "1234567",
  "utk": "hubspot_tracking_cookie_value",
  "timestamp": "2026-03-18T14:30:00Z",
  "tokens": { ... }
}
```

### Operational Limits

| Limit | Value |
|---|---|
| Event templates per app | 750 |
| Tokens per template | 500 |
| Event instance ID size | 500 bytes |
| Individual token size | 510 KB |
| Total event size | 1 MB |

### Handlebars Template Syntax

Templates support Markdown and Handlebars syntax:

```handlebars
## AI Interaction Summary

**Agent:** {{agentName}}
**Outcome:** {{outcome}}
**Duration:** {{duration}} seconds

{{#if summary}}
### Notes
{{summary}}
{{/if}}

{{#formatDate timestamp}}{{/formatDate}}
```

For complex data, pass a JSON object via `extraData` and iterate in the detail template:

```handlebars
{{#each extraData.objections}}
- **Objection:** {{this.text}} — **Handled:** {{this.handled}}
{{/each}}
```

### Timeline iFrame Integration

You can include a link that opens an external iframe in the timeline event, useful for linking AI agent conversation replays or external dashboards:

```json
{
  "eventTemplateId": "1234567",
  "objectId": "101",
  "timestamp": "2026-03-18T14:30:00Z",
  "tokens": { ... },
  "timelineIFrame": {
    "linkLabel": "View Full Conversation",
    "headerLabel": "AI Agent Conversation Replay",
    "url": "https://your-system.com/conversations/sess_abc123xyz",
    "width": 1000,
    "height": 700
  }
}
```

---

## Batch Operations

All engagement types support batch creation. This is critical for AI agent integrations that process interactions at volume.

### Batch Create Notes — Full Example

```json
POST /crm/v3/objects/notes/batch/create

{
  "inputs": [
    {
      "properties": {
        "hs_timestamp": "2026-03-18T09:00:00Z",
        "hs_note_body": "AI outreach sequence initiated. Email #1 sent. Open tracking enabled.",
        "hubspot_owner_id": "64492917"
      },
      "associations": [
        {
          "to": {"id": "201"},
          "types": [{"associationCategory": "HUBSPOT_DEFINED", "associationTypeId": 202}]
        }
      ]
    },
    {
      "properties": {
        "hs_timestamp": "2026-03-18T09:01:00Z",
        "hs_note_body": "AI outreach sequence initiated. Email #1 sent. Open tracking enabled.",
        "hubspot_owner_id": "64492917"
      },
      "associations": [
        {
          "to": {"id": "202"},
          "types": [{"associationCategory": "HUBSPOT_DEFINED", "associationTypeId": 202}]
        }
      ]
    }
  ]
}
```

### Batch Create Tasks

```json
POST /crm/v3/objects/tasks/batch/create

{
  "inputs": [
    {
      "properties": {
        "hs_timestamp": "2026-03-21T10:00:00Z",
        "hs_task_subject": "Follow-up — AI-identified hot lead",
        "hs_task_status": "NOT_STARTED",
        "hs_task_priority": "HIGH",
        "hs_task_type": "CALL",
        "hubspot_owner_id": "64492917"
      },
      "associations": [
        {
          "to": {"id": "201"},
          "types": [{"associationCategory": "HUBSPOT_DEFINED", "associationTypeId": 204}]
        }
      ]
    }
  ]
}
```

### Batch Read Engagements

Retrieve multiple notes by their IDs:

```json
POST /crm/v3/objects/notes/batch/read

{
  "inputs": [
    {"id": "987654321"},
    {"id": "987654322"},
    {"id": "987654323"}
  ],
  "properties": ["hs_note_body", "hs_timestamp", "hubspot_owner_id"]
}
```

### Filtering Engagements on List

The GET list endpoints support pagination and property filtering:

```
GET /crm/v3/objects/notes?limit=100&properties=hs_note_body,hs_timestamp
GET /crm/v3/objects/tasks?limit=100&properties=hs_task_subject,hs_task_status,hs_task_priority
GET /crm/v3/objects/calls?limit=100&properties=hs_call_body,hs_call_status,hs_call_duration
```

Use the CRM Search API to filter by specific properties:

```json
POST /crm/v3/objects/notes/search

{
  "filterGroups": [
    {
      "filters": [
        {
          "propertyName": "hubspot_owner_id",
          "operator": "EQ",
          "value": "64492917"
        }
      ]
    }
  ],
  "sorts": [{"propertyName": "hs_timestamp", "direction": "DESCENDING"}],
  "limit": 100,
  "properties": ["hs_note_body", "hs_timestamp"]
}
```

---

## AI Agent Use Cases and Integration Patterns

This section covers practical patterns for AI agents that interact with HubSpot CRM, with concrete code patterns and decision frameworks.

### Pattern 1: Auto-Logging AI Agent Interactions as Notes

The most common pattern. After every AI agent interaction (conversation, email draft review, data enrichment), create a note on the relevant CRM records.

**When to use notes vs. timeline events:**
- Notes when the content is simple text and no custom filtering is needed
- Timeline events when you need structured data, want to filter by event type in HubSpot, or need to link to external systems

**Implementation pattern:**

```python
import requests
import json
from datetime import datetime

HUBSPOT_API_KEY = "Bearer pat-xxx"
BASE_URL = "https://api.hubapi.com"

def log_ai_interaction(
    contact_id: str,
    deal_id: str | None,
    agent_name: str,
    summary: str,
    next_steps: str,
    owner_id: str
) -> dict:
    """Create a note logging an AI agent interaction."""

    note_body = f"""[AI Agent: {agent_name}]

INTERACTION SUMMARY:
{summary}

NEXT STEPS:
{next_steps}

Logged at: {datetime.utcnow().isoformat()}Z"""

    associations = [
        {
            "to": {"id": contact_id},
            "types": [
                {"associationCategory": "HUBSPOT_DEFINED", "associationTypeId": 202}
            ]
        }
    ]

    if deal_id:
        associations.append({
            "to": {"id": deal_id},
            "types": [
                {"associationCategory": "HUBSPOT_DEFINED", "associationTypeId": 214}
            ]
        })

    payload = {
        "properties": {
            "hs_timestamp": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
            "hs_note_body": note_body,
            "hubspot_owner_id": owner_id
        },
        "associations": associations
    }

    response = requests.post(
        f"{BASE_URL}/crm/v3/objects/notes",
        headers={
            "Authorization": HUBSPOT_API_KEY,
            "Content-Type": "application/json"
        },
        json=payload
    )

    return response.json()
```

### Pattern 2: Auto-Creating Follow-Up Tasks

AI agents often identify action items during interactions. This pattern auto-creates a task and associates it with both the contact and deal.

```python
def create_followup_task(
    contact_id: str,
    deal_id: str | None,
    task_subject: str,
    task_body: str,
    due_date_iso: str,
    priority: str = "MEDIUM",
    task_type: str = "TODO",
    owner_id: str = None
) -> dict:
    """Auto-create a follow-up task from AI agent output."""

    associations = [
        {
            "to": {"id": contact_id},
            "types": [{"associationCategory": "HUBSPOT_DEFINED", "associationTypeId": 204}]
        }
    ]

    if deal_id:
        associations.append({
            "to": {"id": deal_id},
            "types": [{"associationCategory": "HUBSPOT_DEFINED", "associationTypeId": 216}]
        })

    properties = {
        "hs_timestamp": due_date_iso,
        "hs_task_subject": f"[AI] {task_subject}",
        "hs_task_body": task_body,
        "hs_task_status": "NOT_STARTED",
        "hs_task_priority": priority,
        "hs_task_type": task_type
    }

    if owner_id:
        properties["hubspot_owner_id"] = owner_id

    response = requests.post(
        f"{BASE_URL}/crm/v3/objects/tasks",
        headers={"Authorization": HUBSPOT_API_KEY, "Content-Type": "application/json"},
        json={"properties": properties, "associations": associations}
    )

    return response.json()
```

### Pattern 3: Custom Timeline Events for Structured Agent Activity Tracking

When AI agents run qualification workflows, scoring sessions, or multi-step processes, timeline events provide richer tracking than plain notes.

**Step 1: Create the event template (one-time setup)**

```json
POST /integrators/timeline/v3/{appId}/event-templates

{
  "name": "AI Agent Qualification Session",
  "objectType": "contacts",
  "headerTemplate": "AI Qualification — {{outcome}} (Score: {{leadScore}})",
  "detailTemplate": "**Agent:** {{agentName}}\n**Session:** {{sessionId}}\n**Duration:** {{duration}}s\n\n**Lead Score:** {{leadScore}}/100\n\n**Summary:**\n{{summary}}\n\n**Identified Pain Points:**\n{{painPoints}}\n\n**Recommended Action:** {{recommendedAction}}",
  "tokens": [
    {"name": "agentName", "label": "Agent Name", "type": "string"},
    {"name": "outcome", "label": "Outcome", "type": "enumeration", "options": [
      {"label": "Hot Lead", "value": "hot"},
      {"label": "Warm Lead", "value": "warm"},
      {"label": "Cold Lead", "value": "cold"},
      {"label": "Not Qualified", "value": "not_qualified"},
      {"label": "Meeting Booked", "value": "meeting_booked"}
    ]},
    {"name": "sessionId", "label": "Session ID", "type": "string"},
    {"name": "leadScore", "label": "Lead Score", "type": "number"},
    {"name": "duration", "label": "Duration (s)", "type": "number"},
    {"name": "summary", "label": "Summary", "type": "string"},
    {"name": "painPoints", "label": "Pain Points", "type": "string"},
    {"name": "recommendedAction", "label": "Recommended Action", "type": "string"}
  ]
}
```

**Step 2: Create event instances after each agent session**

```python
def log_qualification_event(
    contact_id: str,
    template_id: str,
    session_data: dict,
    oauth_token: str  # Note: MUST be OAuth token, not private app token
) -> dict:
    """Log a structured AI qualification event to the contact timeline."""

    payload = {
        "eventTemplateId": template_id,
        "objectId": contact_id,
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "tokens": {
            "agentName": session_data["agent_name"],
            "outcome": session_data["outcome"],
            "sessionId": session_data["session_id"],
            "leadScore": session_data["lead_score"],
            "duration": session_data["duration_seconds"],
            "summary": session_data["summary"],
            "painPoints": "\n".join(session_data.get("pain_points", [])),
            "recommendedAction": session_data["recommended_action"]
        }
    }

    response = requests.post(
        f"{BASE_URL}/crm/v3/timeline/events",
        headers={
            "Authorization": f"Bearer {oauth_token}",
            "Content-Type": "application/json"
        },
        json=payload
    )

    return response.json()
```

### Pattern 4: Reading Engagement History for Context

Before an AI agent interacts with a contact, pull their engagement history to provide context:

```python
def get_contact_engagement_history(
    contact_id: str,
    limit: int = 20
) -> dict:
    """Pull recent engagement history for a contact."""

    history = {
        "notes": [],
        "calls": [],
        "meetings": [],
        "tasks": []
    }

    # Get note IDs
    notes_assoc = requests.get(
        f"{BASE_URL}/crm/v4/objects/contact/{contact_id}/associations/notes",
        headers={"Authorization": HUBSPOT_API_KEY}
    ).json()

    note_ids = [str(r["toObjectId"]) for r in notes_assoc.get("results", [])[:limit]]

    if note_ids:
        notes_resp = requests.post(
            f"{BASE_URL}/crm/v3/objects/notes/batch/read",
            headers={"Authorization": HUBSPOT_API_KEY, "Content-Type": "application/json"},
            json={
                "inputs": [{"id": nid} for nid in note_ids],
                "properties": ["hs_note_body", "hs_timestamp", "hubspot_owner_id"]
            }
        ).json()
        history["notes"] = notes_resp.get("results", [])

    # Repeat for calls, meetings, tasks...

    return history
```

### Pattern 5: Bulk Association After Creating Engagements

When creating many engagements for multiple contacts, use the batch association endpoint after bulk-creating the engagement objects:

```python
def batch_log_interactions(interactions: list[dict]) -> None:
    """Batch create notes and associate them to contacts."""

    # Step 1: Batch create notes
    note_inputs = [
        {
            "properties": {
                "hs_timestamp": item["timestamp"],
                "hs_note_body": item["body"],
                "hubspot_owner_id": item["owner_id"]
            }
        }
        for item in interactions
    ]

    create_resp = requests.post(
        f"{BASE_URL}/crm/v3/objects/notes/batch/create",
        headers={"Authorization": HUBSPOT_API_KEY, "Content-Type": "application/json"},
        json={"inputs": note_inputs}
    ).json()

    note_results = create_resp.get("results", [])

    # Step 2: Batch associate each note to its contact
    association_inputs = [
        {
            "from": {"id": note_results[i]["id"]},
            "to": {"id": interactions[i]["contact_id"]},
            "types": [
                {"associationCategory": "HUBSPOT_DEFINED", "associationTypeId": 202}
            ]
        }
        for i in range(len(note_results))
    ]

    requests.post(
        f"{BASE_URL}/crm/v4/associations/notes/contacts/batch/create",
        headers={"Authorization": HUBSPOT_API_KEY, "Content-Type": "application/json"},
        json={"inputs": association_inputs}
    )
```

### Best Practices for AI Agent CRM Integrations

**1. Always timestamp engagements accurately**
Use `hs_timestamp` to reflect when the interaction actually occurred, not when the API call is made. If an AI agent processes a backlog of calls overnight, each logged call should carry its actual call timestamp.

**2. Prefix AI-generated content**
Add `[AI]` or `[Agent: {name}]` prefixes to task subjects and note bodies so human reps can distinguish AI-logged entries from manual entries at a glance.

**3. Use structured notes for machine-readable history**
Format AI agent notes with consistent section headers (SUMMARY, NEXT STEPS, PAIN POINTS, SCORE). This makes retrieval and parsing by future AI sessions consistent.

**4. Prefer notes over timeline events for simplicity**
Timeline events require a public app with OAuth — this adds significant auth overhead. Unless you need custom segmentation or reporting based on event types, notes are simpler and sufficient.

**5. Use `hubspot_owner_id` deliberately**
Assigning engagements to a specific owner ensures they appear in that user's task queue and reports. Create a dedicated "AI Agent" user in HubSpot and use their ID for all AI-created engagements. This keeps AI activity clearly attributed and filterable.

**6. Handle rate limits with exponential backoff**
At 150 requests per 10 seconds for Professional/Enterprise, batch operations help. Implement backoff for `429 Too Many Requests` responses.

**7. Associate engagements to both contacts and deals**
When a deal exists, always associate engagements to both the contact (`typeId: 202` for notes) and the deal (`typeId: 214` for notes). This ensures the activity appears on both timelines and counts toward deal activity metrics.

**8. Use pinning for critical AI summaries**
If an AI agent produces a comprehensive contact analysis or qualification summary, pin that note to the contact record so it's immediately visible to human reps.

**9. Check association limits proactively**
Use the high-usage reporting endpoint (`POST /crm/v4/associations/usage/high-usage-report/{userId}`) periodically to catch records approaching their association limits before writes fail.

**10. OAuth for timeline events, private app token for everything else**
Timeline event instance creation requires OAuth. All other engagement APIs (notes, tasks, calls, meetings) work with private app access tokens. Structure your integration accordingly — use a private app token as the default and only implement OAuth if you need timeline events.

---

## Complete Endpoint Reference Summary

### Associations v4

| Operation | Method | Endpoint |
|---|---|---|
| Get association labels | GET | `/crm/v4/associations/{from}/{to}/labels` |
| Create custom label | POST | `/crm/v4/associations/{from}/{to}/labels` |
| Update custom label | PUT | `/crm/v4/associations/{from}/{to}/labels` |
| Delete custom label | DELETE | `/crm/v4/associations/{from}/{to}/labels/{typeId}` |
| Create association (individual) | PUT | `/crm/v4/objects/{from}/{fromId}/associations/{to}/{toId}` |
| Create unlabeled (individual) | PUT | `/crm/v4/objects/{from}/{fromId}/associations/default/{to}/{toId}` |
| Create unlabeled (batch) | POST | `/crm/v4/associations/{from}/{to}/batch/associate/default` |
| Create labeled (batch) | POST | `/crm/v4/associations/{from}/{to}/batch/create` |
| Read associations (individual) | GET | `/crm/v4/objects/{from}/{id}/associations/{to}` |
| Read associations (batch) | POST | `/crm/v4/associations/{from}/{to}/batch/read` |
| Delete all (individual) | DELETE | `/crm/v4/objects/{from}/{fromId}/associations/{to}/{toId}` |
| Delete all (batch) | POST | `/crm/v4/associations/{from}/{to}/batch/archive` |
| Delete labels only (batch) | POST | `/crm/v4/associations/{from}/{to}/batch/labels/archive` |
| High-usage report | POST | `/crm/v4/associations/usage/high-usage-report/{userId}` |

### Engagements (Notes, Tasks, Calls, Meetings, Emails)

All follow the same base pattern — substitute `{type}` with `notes`, `tasks`, `calls`, `meetings`, or `emails`:

| Operation | Method | Endpoint |
|---|---|---|
| Create | POST | `/crm/v3/objects/{type}` |
| Get single | GET | `/crm/v3/objects/{type}/{id}` |
| List all | GET | `/crm/v3/objects/{type}` |
| Update | PATCH | `/crm/v3/objects/{type}/{id}` |
| Delete | DELETE | `/crm/v3/objects/{type}/{id}` |
| Associate | PUT | `/crm/v3/objects/{type}/{id}/associations/{toType}/{toId}/{assocTypeId}` |
| Remove association | DELETE | `/crm/v3/objects/{type}/{id}/associations/{toType}/{toId}/{assocTypeId}` |
| Batch create | POST | `/crm/v3/objects/{type}/batch/create` |
| Batch read | POST | `/crm/v3/objects/{type}/batch/read` |
| Batch update | POST | `/crm/v3/objects/{type}/batch/update` |
| Batch delete | POST | `/crm/v3/objects/{type}/batch/archive` |
| Search | POST | `/crm/v3/objects/{type}/search` |

### Timeline Events

| Operation | Method | Endpoint |
|---|---|---|
| Create template | POST | `/integrators/timeline/v3/{appId}/event-templates` |
| Get all templates | GET | `/integrators/timeline/v3/{appId}/event-templates` |
| Get template | GET | `/integrators/timeline/v3/{appId}/event-templates/{templateId}` |
| Update template | PUT | `/integrators/timeline/v3/{appId}/event-templates/{templateId}` |
| Delete template | DELETE | `/integrators/timeline/v3/{appId}/event-templates/{templateId}` |
| Create event instance | POST | `/crm/v3/timeline/events` |
| Get dispositions | GET | `/calling/v1/dispositions` |

---

## Authentication Reference

All API calls use the `Authorization` header:

```
Authorization: Bearer {access_token}
```

For private apps (recommended for server-side AI agent integrations):

1. In HubSpot, go to Settings > Integrations > Private Apps
2. Create a private app with the required scopes
3. Copy the access token (starts with `pat-`)
4. Use this as the Bearer token in all requests

For public apps requiring OAuth (required for timeline event instances):

1. Implement the OAuth 2.0 authorization code flow
2. Store and refresh access tokens per account
3. Use the scoped access token in requests

Base URL for all API calls:
```
https://api.hubapi.com
```

---

*Sources: developers.hubspot.com/docs/api/crm/associations, developers.hubspot.com/docs/api/crm/engagements, developers.hubspot.com/docs/api/crm/timeline, developers.hubspot.com/docs/api-reference/crm-associations-v4/guide, developers.hubspot.com/docs/api-reference/crm-calls-v3/guide, san.is/posts/association-type-ids-demystified, community.hubspot.com*
