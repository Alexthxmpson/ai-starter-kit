# Close CRM API — Advanced Documentation

> Source: https://developer.close.com
> Scraped: 2026-03-30
> Covers: Event Log, Webhooks, Scheduling Links, Custom Fields, Custom Activities, Custom Objects, Changelog

---

# Table of Contents

1. [Event Log](#1-event-log)
   - [Event Object Structure](#11-event-object-structure)
   - [List of Events](#12-list-of-events)
   - [Retrieve Events](#13-retrieve-events)
2. [Webhook Subscriptions](#2-webhook-subscriptions)
   - [Webhook Endpoints](#21-webhook-endpoints)
   - [Webhook Filters](#22-webhook-filters)
3. [Scheduling Links](#3-scheduling-links)
   - [User Scheduling Links](#31-user-scheduling-links)
   - [Shared Scheduling Links](#32-shared-scheduling-links)
   - [Scheduling Link Associations](#33-scheduling-link-associations)
4. [Custom Fields](#4-custom-fields)
   - [Overview & Field Types](#40-overview--field-types)
   - [Lead Custom Fields](#41-lead-custom-fields)
   - [Contact Custom Fields](#42-contact-custom-fields)
   - [Opportunity Custom Fields](#43-opportunity-custom-fields)
   - [Activity Custom Fields](#44-activity-custom-fields)
   - [Custom Object Custom Fields](#45-custom-object-custom-fields)
   - [Shared Custom Fields](#46-shared-custom-fields)
   - [Custom Field Schemas](#47-custom-field-schemas)
5. [Custom Activities](#5-custom-activities)
   - [Custom Activity Types](#51-custom-activity-types)
   - [Custom Activity Instances](#52-custom-activity-instances)
6. [Custom Objects](#6-custom-objects)
   - [Custom Object Types](#61-custom-object-types)
   - [Custom Object Instances](#62-custom-object-instances)
7. [Changelog](#7-changelog)

---

# 1. Event Log

## 1.1 Event Object Structure

The Event Log API provides access to actions in Close that modify objects. Events are retained for up to **30 days** of historical data. Most actions in Close that change an object are logged in the event log.

### Event Fields

| Field | Type | Description |
|-------|------|-------------|
| `date_created` | Timestamp | When the event was created |
| `date_updated` | Timestamp | When the event was last updated; can change if multiple actions occur on the same object |
| `organization_id` | String | The organization identifier |
| `user_id` | String / Null | User who triggered the event, or null if not user-initiated |
| `request_id` | String | Unique request identifier for associating related events |
| `api_key_id` | String / Null | API key used if triggered via API, otherwise null |
| `object_type` | String | Type of affected object (e.g., `lead`, `activity.email`, `status_change.opportunity`) |
| `object_id` | String | ID of the affected object |
| `lead_id` | String / Null | Associated lead ID, or null if not applicable |
| `action` | String | Event type: `created`, `updated`, `deleted`, `merged`, `completed`, `sent`, etc. |
| `changed_fields` | Array | For updates: fields that changed |
| `data` | Object / Null | Current object payload; null for deletes |
| `previous_data` | Object / Null | Previous values for updates; all attributes for deletes |
| `meta` | Object | Additional context (see below) |

### Meta Object Fields

| Field | Description |
|-------|-------------|
| `bulk_action_id` | ID of the bulk action that triggered this event |
| `merge_source_lead_id` | Source lead ID in a merge operation |
| `merge_destination_lead_id` | Destination lead ID in a merge operation |
| `request_method` | HTTP method of the triggering request |
| `request_path` | HTTP path of the triggering request |

### Privacy Consideration

For privacy reasons, certain fields (`data` and `previous_data`) are only visible to non-admins for one hour after the event.

### Event Consolidation

Multiple update events for the same object may consolidate into a single event. The consolidated event retains the original `date_created` and gets a new `date_updated`. The `previous_data` reflects the original state before all consolidation changes.

---

## 1.2 List of Events

All events available through the Close API Event Log, organized by object type and action.

### Lead (`lead`)

| Action | Trigger |
|--------|---------|
| `created` | A lead is created in your organization (regardless of the method) |
| `updated` | Lead's basic fields change (name, description, url, status), contacts are added/removed, or addresses/custom fields are modified. Note: Activity, opportunity, task changes do NOT trigger this event. |
| `deleted` | A lead is deleted. Deleting a lead will cause additional `deleted` events on child objects. |
| `merged` | Two leads are merged; includes `merge_source_lead_id` and `merge_destination_lead_id` in event metadata |

### Contact (`contact`)

| Action | Trigger |
|--------|---------|
| `created` | A contact is created in your organization |
| `updated` | Changes to basic fields (name, title) or nested fields (email, phone, URL) |
| `deleted` | Contact removal |

### Opportunity (`opportunity`)

| Action | Trigger |
|--------|---------|
| `created` | An opportunity is created |
| `updated` | Changes to status, date_won, value, value_period, or confidence. Note: `value_currency` changes do NOT trigger this event as it's organization-wide. |
| `deleted` | Opportunity removal |

### Tasks (`task.SUBTYPE`)

| Action | Trigger |
|--------|---------|
| `created` | Task creation |
| `updated` | Changes to basic fields like `is_complete`, `date`, `text`, `subject` |
| `deleted` | Task removal |
| `completed` | A task is marked as done |

### Email (`activity.email`)

| Action | Trigger |
|--------|---------|
| `created` | Incoming synced email or outgoing email (scheduled/draft) |
| `updated` | Changes to subject, body, status, opens. **Discouraged** — many updates happen when a user is drafting. |
| `deleted` | Email removal |
| `sent` | An outgoing email is sent through the UI or API. Triggered when the email is actually _sent_. |

### Email Thread (`activity.email_thread`)

| Action | Trigger |
|--------|---------|
| `created` | New thread from synced email or API/UI creation |
| `updated` | Changes to emails, participants, or subject |
| `deleted` | Thread removal |

### Unsubscribed Email (`unsubscribed_email`)

| Action | Trigger |
|--------|---------|
| `created` | User email was unsubscribed from bulk and workflow emails |
| `deleted` | Email resubscription |

### Call (`activity.call`)

| Action | Trigger |
|--------|---------|
| `created` | User-initiated, transferred, inbound, or manually logged calls |
| `updated` | Changes to note, status, duration, recording_url. **Discouraged** — many updates happen when a user is writing. |
| `deleted` | Call removal |
| `answered` | A call is answered. Not triggered for calls made outside of Close. |
| `completed` | Call completion (not triggered for manually logged calls) |

### SMS (`activity.sms`)

| Action | Trigger |
|--------|---------|
| `created` | Inbound or outbound SMS creation |
| `updated` | Changes to status, text, phone numbers. **Discouraged** due to frequent draft updates. |
| `deleted` | SMS removal |
| `sent` | An outbound SMS is sent through the UI or API |

### WhatsApp Message (`activity.whatsapp_message`)

| Action | Trigger |
|--------|---------|
| `created` | WhatsApp message created |
| `updated` | WhatsApp message updated |
| `deleted` | WhatsApp message deleted |

### Note (`activity.note`)

| Action | Trigger |
|--------|---------|
| `created` | Note created |
| `updated` | Periodic during typing |
| `deleted` | Note deleted |

### Meeting (`activity.meeting`)

| Action | Trigger |
|--------|---------|
| `created` | Meeting created |
| `updated` | Meeting updated |
| `deleted` | Meeting deleted |
| `scheduled` | Future meeting created or rescheduled |
| `started` | Status moves to "in-progress" |
| `completed` | Status moves to "completed" |
| `canceled` | Status moves to "canceled" |

### Form Submission (`activity.form_submission`)

| Action | Trigger |
|--------|---------|
| `created` | Form submission created |
| `updated` | Form submission updated |
| `deleted` | Form submission deleted |

### Lead Status Change (`activity.lead_status_change`)

| Action | Trigger |
|--------|---------|
| `created` | Also triggers `lead.updated` event |
| `updated` | Consolidates consecutive status changes within short time |
| `deleted` | Reverted status change |

### Opportunity Status Change (`activity.opportunity_status_change`)

| Action | Trigger |
|--------|---------|
| `created` | Similar behavior to lead status changes |
| `updated` | Consolidates consecutive status changes within short time |
| `deleted` | Reverted status change |

### Task Completed (`activity.task_completed`)

| Action | Trigger |
|--------|---------|
| `created` | Also triggers `completed` and `updated` on task and `updated` on lead |
| `deleted` | Task marked incomplete again |

### Import (`import`)

| Action | Trigger |
|--------|---------|
| `created` | CSV import initiated |
| `updated` | Frequent updates during processing (status, progress metrics) |
| `completed` | Import completed |
| `reverting` | Import being reverted |
| `reverted` | Import reverted |

### Export (`export.lead`, `export.opportunity`)

| Action | Trigger |
|--------|---------|
| `created` | Export initiated |
| `updated` | Frequent during processing |
| `completed` | Export completed |

### Bulk Actions (`bulk_action.delete`, `bulk_action.edit`, `bulk_action.email`, `bulk_action.sequence_subscription`)

| Action | Trigger |
|--------|---------|
| `created` | Bulk action initiated |
| `updated` | Frequent during processing |
| `completed` | Bulk action completed |
| `paused` | Bulk action paused |

### Custom Fields

Object types: `custom_fields.lead`, `custom_fields.contact`, `custom_fields.opportunity`, `custom_fields.activity`, `custom_fields.custom_object`, `custom_fields.shared`

| Action | Trigger |
|--------|---------|
| `created` | Initial creation |
| `updated` | Changes to name, type, or choices |
| `deleted` | Field deleted |

### Custom Activity Type (`custom_activity_type`)

| Action | Trigger |
|--------|---------|
| `created` | Type created |
| `updated` | Field changes, ordering, associations |
| `deleted` | Type deleted |

### Custom Activity (`activity.custom_activity`)

| Action | Trigger |
|--------|---------|
| `created` | Custom activity instance created |
| `updated` | Custom activity instance updated |
| `deleted` | Custom activity instance deleted |

### Custom Object Type (`custom_object_type`)

| Action | Trigger |
|--------|---------|
| `created` | Type created |
| `updated` | Type updated |
| `deleted` | Type deleted |

### Custom Object (`custom_object`)

| Action | Trigger |
|--------|---------|
| `created` | Custom object instance created |
| `updated` | Custom object instance updated |
| `deleted` | Custom object instance deleted |

### Status (`status.lead`, `status.opportunity`)

| Action | Trigger |
|--------|---------|
| `created` | Status created |
| `updated` | Label changes |
| `deleted` | Status deleted |

### Membership (`membership`)

| Action | Trigger |
|--------|---------|
| `activated` | User accepts invitation or is re-added |
| `deactivated` | User removal |

### Group (`group`)

| Action | Trigger |
|--------|---------|
| `created` | Group created |
| `updated` | Including member changes |
| `deleted` | Group deleted |

### Saved Search (`saved_search`)

| Action | Trigger |
|--------|---------|
| `created` | Saved search created |
| `updated` | Name, query, sharing changed (not triggered by result changes) |
| `deleted` | Saved search deleted |

### Phone Number (`phone_number`)

| Action | Trigger |
|--------|---------|
| `created` | Phone number created |
| `updated` | Forwarding, participants, voicemail changed |
| `deleted` | Phone number deleted |

### Email Template (`email_template`)

| Action | Trigger |
|--------|---------|
| `created` | Template created |
| `updated` | Name, subject, body, attachments changed |
| `deleted` | Template deleted |

### SMS Template (`sms_template`)

| Action | Trigger |
|--------|---------|
| `created` | Template created |
| `updated` | Name, text, sharing changed |
| `deleted` | Template deleted |

### Sequence (`sequence`)

| Action | Trigger |
|--------|---------|
| `created` | Sequence created |
| `updated` | Including embedded steps |
| `deleted` | Sequence deleted |

### Sequence Subscription (`sequence_subscription`)

| Action | Trigger |
|--------|---------|
| `created` | Subscription created |
| `updated` | Status changes |
| `deleted` | Triggered by related object deletion |

### Comment (`comment`)

| Action | Trigger |
|--------|---------|
| `created` | Comment created |
| `updated` | Body changes or removal |
| `deleted` | Permanent deletion only |

### Comment Thread (`comment_thread`)

| Action | Trigger |
|--------|---------|
| `created` | First comment added |
| `updated` | Participant or count changes |
| `deleted` | Last comment removed |

### Lead Merge (`lead_merge`)

| Action | Trigger |
|--------|---------|
| `created` | Merge initiated |
| `updated` | Status changes |
| `deleted` | Merge deleted |

---

## 1.3 Retrieve Events

### Retrieve a Single Event by ID

```
GET /event/{id}/
```

Returns a single event by its ID using the standard event format.

### Retrieve a List of Events

```
GET /event/
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `date_updated__lt` | ISO datetime | Optional | Events updated before this time |
| `date_updated__gt` | ISO datetime | Optional | Events updated after this time |
| `date_updated__lte` | ISO datetime | Optional | Events updated at or before this time |
| `date_updated__gte` | ISO datetime | Optional | Events updated at or after this time |
| `object_type` | string | Optional | Filter by object type (e.g., `lead`) |
| `object_id` | string | Optional | Filter by specific object ID |
| `action` | string | Optional | Filter by action type (e.g., `deleted`) |
| `lead_id` | string | Optional | Filter by lead; returns events for the lead and its related objects (contacts, activities, opportunities, tasks) |
| `user_id` | string | Optional | Filter by user |
| `request_id` | string | Optional | Filter by API request ID |
| `_cursor` | string | Optional | Pagination cursor from previous response |
| `_limit` | integer | Optional | Maximum events to return (capped at 50, defaults to 50) |

### Supported Filter Combinations

- `object_type` + `object_id`
- `object_type` + `action`
- `object_id` + `action`
- `lead_id` + `object_type`
- `lead_id` + `object_type` + `action`
- `lead_id` + `user_id` + `object_type`
- `lead_id` + `user_id` + `object_type` + `action`
- `lead_id` + `user_id`
- `user_id` + `object_id`
- `user_id` + `object_id` + `action`
- `user_id` + `object_type`
- `user_id` + `object_type` + `action`
- `lead_id` alone
- `user_id` alone
- `request_id` alone

`date_updated` may optionally accompany any supported combination.

### Response Schema

| Field | Type | Description |
|-------|------|-------------|
| `data` | array | List of event objects using standard event format |
| `cursor_next` | string / null | Cursor for retrieving next page (earlier/older events) or null if unavailable |
| `cursor_previous` | string / null | Cursor for retrieving previous page (later/newer events) or null if unavailable |

### Ordering & Behavior

- Events are ordered by date, latest first (by `date_updated` field)
- Despite millisecond-precision limitations on timestamps, multiple events for the same object maintain guaranteed proper order
- Cursors provide reliable pagination; `date_updated` filtering may require accounting for simultaneous events
- Event consolidation of multiple recent events to the same object may occur
- Recommended practice: scan the latest five minutes of events to avoid missing recent entries when paginating
- The endpoint does **not** support the `_skip` parameter

### Pagination Notes

Cursors are a reliable way to go to the next or previous page of events (unlike filtering by `date_updated`, where you may need to account for and filter out multiple events happening in the same millisecond).

To retrieve the next older batch, use the `cursor_next` value from the previous response.

---

# 2. Webhook Subscriptions

## 2.1 Webhook Endpoints

### List Webhook Subscriptions

```
GET /webhook/
```

Returns all webhook subscriptions configured for your organization.

---

### Create New Webhook Subscription

```
POST /webhook/
```

**Request Body:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `url` | string | Yes | Destination URL for webhook delivery |
| `events` | array | Yes | List of events to subscribe to (each with `object_type` and `action` from the event log) |
| `verify_ssl` | boolean | No | SSL certificate validation (default: `true`) |

**Notes:**
- Set `verify_ssl` to `false` to disable SSL validation (not recommended without HTTPS)
- Use Webhook Filters for conditional event delivery
- Webhook subscriptions are automatically paused after 3 days of all event delivery failures

---

### Retrieve Single Webhook Subscription

```
GET /webhook/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Webhook subscription identifier |

---

### Update Webhook Subscription

```
PUT /webhook/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Webhook subscription identifier |
| `url` | string | No | Destination URL |
| `events` | array | No | Event list (same structure as creation) |
| `status` | string | No | `active` or `paused` |
| `verify_ssl` | boolean | No | SSL validation setting |

---

### Delete Webhook Subscription

```
DELETE /webhook/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Webhook subscription identifier |

---

## 2.2 Webhook Filters

More advanced event filtering can be achieved by specifying event filters when creating/modifying a webhook subscription. These filters use JSON to specify conditions on event fields.

### Filter Operators

| Operator | Syntax | Description |
|----------|--------|-------------|
| **Equals** | `{"type": "equals", "value": "<value>"}` | Matches when the entire value matches the provided value |
| **Not Equals** | `{"type": "not_equals", "value": "<value>"}` | Matches when the value does not match the provided value |
| **Is Null** | `{"type": "is_null"}` | Matches when the field value is null |
| **Non Null** | `{"type": "non_null"}` | Matches when the field value is non-null |
| **Contains** | `{"type": "contains", "value": "<value>"}` | Searches for a value in an array or partial string match |
| **And** | `{"type": "and", "filters": [<filter1>, ...]}` | Matches when ALL provided filters match |
| **Or** | `{"type": "or", "filters": [<filter1>, ...]}` | Matches when ONE OR MORE filters match |
| **Not** | `{"type": "not", "filter": <filter>}` | Matches when the provided filter does NOT match |

### Field Access Methods

| Method | Syntax | Description |
|--------|--------|-------------|
| **Field Accessor** | `{"type": "field_accessor", "field": "<field_name>", "filter": <filter>}` | Access specific fields in JSON documents |
| **Any Array Value** | `{"type": "any_array_value", "filter": <filter>}` | Search for matching values inside arrays/lists |

### Example: Match specific user_id

```json
{
  "type": "field_accessor",
  "field": "user_id",
  "filter": {
    "type": "equals",
    "value": "user_N6KhMpzHRCYQHdn4gRNIFNN5JExnsrprKA6ekxM63XA"
  }
}
```

### Example: Drill into nested data object

```json
{
  "type": "field_accessor",
  "field": "data",
  "filter": {
    "type": "field_accessor",
    "field": "user_id",
    "filter": {
      "type": "equals",
      "value": "user_N6KhMpzHRCYQHdn4gRNIFNN5JExnsrprKA6ekxM63XA"
    }
  }
}
```

### Example: Exclude events from specific user (using `not`)

```json
{
  "type": "field_accessor",
  "field": "data",
  "filter": {
    "type": "field_accessor",
    "field": "user_id",
    "filter": {
      "type": "not",
      "filter": {
        "type": "equals",
        "value": "user_N6KhMpzHRCYQHdn4gRNIFNN5JExnsrprKA6ekxM63XA"
      }
    }
  }
}
```

### Example: Exclude events from specific user (using `not_equals`)

```json
{
  "type": "field_accessor",
  "field": "data",
  "filter": {
    "type": "field_accessor",
    "field": "user_id",
    "filter": {
      "type": "not_equals",
      "value": "user_N6KhMpzHRCYQHdn4gRNIFNN5JExnsrprKA6ekxM63XA"
    }
  }
}
```

### Example: Match non-null user_id

```json
{
  "type": "field_accessor",
  "field": "user_id",
  "filter": {
    "type": "non_null"
  }
}
```

### Example: Match leads with "travel" in name

```json
{
  "type": "field_accessor",
  "field": "data",
  "filter": {
    "type": "field_accessor",
    "field": "name",
    "filter": {
      "type": "contains",
      "value": "travel"
    }
  }
}
```

### Example: Match events where name changed

```json
{
  "type": "field_accessor",
  "field": "changed_fields",
  "filter": {
    "type": "contains",
    "value": "name"
  }
}
```

### Example: Match name OR description changes

```json
{
  "type": "field_accessor",
  "field": "changed_fields",
  "filter": {
    "type": "or",
    "filters": [
      {
        "type": "contains",
        "value": "name"
      },
      {
        "type": "contains",
        "value": "description"
      }
    ]
  }
}
```

### Example: Match multiple custom fields (AND operation)

```json
{
  "type": "and",
  "filters": [
    {
      "type": "field_accessor",
      "field": "data",
      "filter": {
        "type": "field_accessor",
        "field": "custom.cf_rR9HjgjI4SYy1X1IlMOozK2VkxMgU5NnHquTR8DVxoQ",
        "filter": {
          "type": "equals",
          "value": "product_1234"
        }
      }
    },
    {
      "type": "field_accessor",
      "field": "data",
      "filter": {
        "type": "field_accessor",
        "field": "custom.cf_vwqYhEFwzPyfCErS8uQ77is1wFLvr9BgVi6cTfbFM48",
        "filter": {
          "type": "equals",
          "value": "sub_product_5678"
        }
      }
    }
  ]
}
```

### Example: Match addresses in specific state/country

```json
{
  "type": "field_accessor",
  "field": "data",
  "filter": {
    "type": "field_accessor",
    "field": "addresses",
    "filter": {
      "type": "any_array_value",
      "filter": {
        "type": "and",
        "filters": [
          {
            "type": "field_accessor",
            "field": "state",
            "filter": {
              "type": "equals",
              "value": "MD"
            }
          },
          {
            "type": "field_accessor",
            "field": "country",
            "filter": {
              "type": "equals",
              "value": "US"
            }
          }
        ]
      }
    }
  }
}
```

---

# 3. Scheduling Links

## Overview

Scheduling Links let you create arbitrary event links that make it easy to find/insert booking links directly from Close.

- **User Scheduling Links** — All users can create these; OAuth applications can create them on behalf of users
- **Shared Scheduling Links** — Available to users with "Manage Customizations" permission; creates template tags for email templates
- Shared Scheduling Links can be mapped to User Scheduling Links or URLs

---

## 3.1 User Scheduling Links

Close users can embed scheduling links in their communications sent through Close. The API supports three scheduling link types identified by their `source` attribute:

| Source | Description |
|--------|-------------|
| `MANUAL` | Created via Close application or `/scheduling_link/` endpoints |
| `THIRD_PARTY` | Created/managed by OAuth applications via `/scheduling_link/integration/` endpoints |
| `CALENDLY` | Close's first-party Calendly integration |

### Editable Attributes (all types)

| Attribute | Type | Description |
|-----------|------|-------------|
| `name` | string | Display name in Close application |
| `url` | string | External scheduling link URL |
| `description` | string | Description shown in Close application |

### Additional Attributes (THIRD_PARTY only)

| Attribute | Type | Description |
|-----------|------|-------------|
| `source_id` | string | Integrating application's identifier |
| `source_type` | string | Short descriptor for the link type |
| `duration_in_minutes` | integer | Meeting length in minutes |

### List User Scheduling Links

```
GET /scheduling_link/
```

Retrieves all user scheduling links.

### Create a User Scheduling Link

```
POST /scheduling_link/
```

Creates a new scheduling link with specified attributes.

### Fetch a User Scheduling Link

```
GET /scheduling_link/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Scheduling link identifier |

### Update a User Scheduling Link

```
PUT /scheduling_link/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Scheduling link identifier |

### Delete a User Scheduling Link

```
DELETE /scheduling_link/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Scheduling link identifier |

### Create or Update via OAuth Integration

```
POST /scheduling_link/integration/
```

**Authentication:** OAuth only (API key will produce an error).

Uses the integration-provided `source_id` field to identify and merge duplicate resources created by the same OAuth Application. If a scheduling link created by your OAuth application with the specified `source_id` does not exist, a new one will be created. Otherwise, the scheduling link resource will be updated.

### Delete via OAuth Integration

```
DELETE /scheduling_link/integration/{source_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `source_id` | string (path) | Yes | Source identifier from OAuth application |

**Authentication:** OAuth only (API key will produce an error).

Uses the `source_id` field to identify and delete the specified User Scheduling Link created by your OAuth Application.

---

## 3.2 Shared Scheduling Links

### List Shared Scheduling Links

```
GET /shared_scheduling_link/
```

Retrieves a list of all shared scheduling links.

### Create a Shared Scheduling Link

```
POST /shared_scheduling_link/
```

Creates a new shared scheduling link.

### Fetch a Shared Scheduling Link

```
GET /shared_scheduling_link/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Shared scheduling link identifier |

### Update a Shared Scheduling Link

```
PUT /shared_scheduling_link/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Shared scheduling link identifier |

### Delete a Shared Scheduling Link

```
DELETE /shared_scheduling_link/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Shared scheduling link identifier |

---

## 3.3 Scheduling Link Associations

Scheduling Link Associations enable mapping and unmapping of Shared Scheduling Links to either User Scheduling Links or URLs.

### Map a Shared Scheduling Link

```
POST /shared_scheduling_link_association/
```

Associates a Shared Scheduling Link with either a User Scheduling Link or a URL.

### Unmap a Shared Scheduling Link

```
POST /shared_scheduling_link_association/unmap
```

Removes an association between a Shared Scheduling Link and its mapped target.

---

# 4. Custom Fields

## 4.0 Overview & Field Types

Custom Fields enable storage of arbitrary data on Leads, Contacts, Opportunities, and Custom Activities. Organizations can define field names, data types, validation rules, and access permissions.

**Permission requirement:** Only users with the `manage_organization` permission can create, edit, or delete Custom Fields.

### API Endpoint Categories

| Endpoint | Resource | Path |
|----------|----------|------|
| Lead Custom Fields | Leads | `/custom_field/lead/` |
| Contact Custom Fields | Contacts | `/custom_field/contact/` |
| Opportunity Custom Fields | Opportunities | `/custom_field/opportunity/` |
| Activity Custom Fields | Custom Activities | `/custom_field/activity/` |
| Object Custom Fields | Custom Objects | `/custom_field/custom_object_type/` |
| Shared Custom Fields | Multiple objects | `/custom_field/shared/` |
| Schema Endpoint | All fields | `/custom_field_schema/{object_type}/` |

### Core Field Properties

| Attribute | Type | Description |
|-----------|------|-------------|
| `name` | string | User-readable field name |
| `description` | string / null | Context description (max 280 characters) |
| `type` | string | Data type (see types below) |
| `choices` | array | Valid values for `choices` type |
| `accepts_multiple_values` | boolean | Multiple values support |
| `editable_with_roles` | array | Roles permitted to edit |
| `referenced_custom_type_id` | string | Custom Object Type ID (for `custom_object` fields) |
| `back_reference_is_visible` | boolean | Display back-reference in UI |

### Supported Field Types

| Type | Description |
|------|-------------|
| `text` | Any text value |
| `number` | Integer or decimal values |
| `date` | Date only (e.g., `"2014-06-12"`) |
| `datetime` | Date with time (e.g., `"2014-06-27T22:00:00-08:00"`) |
| `choices` | Predefined values only |
| `user` | Active/former User IDs or exact names (returns IDs) |
| `contact` | Contact IDs (limited to Lead's contacts) |
| `custom_object` | Custom Object IDs (single type, limited to Lead's objects) |
| `textarea` | Multi-line text (Custom Activities only) |
| `hidden` | Any value, never displayed in UI |

### Multi-Value Support

Multiple values are only supported for: `user`, `choices`, `contact`, and `custom_object` types.

### Contact Field Restrictions

The `contact` type field accepts IDs limited to the relevant Lead's contacts:
- Lead editing: accepts Lead's contacts
- Contact editing: accepts Lead's contacts
- Opportunity editing: accepts Lead's contacts
- Custom Activity editing: accepts Lead's contacts
- Custom Object editing: accepts Lead's contacts

### Custom Field ID Format

New Custom Fields share common `cf_` prefix instead of type-specific prefixes. Existing Custom Field IDs are unchanged.

### Notes

- Custom Object fields reference only one Custom Object Type via `referenced_custom_type_id`
- The `hidden` type stores data useful primarily to API integrations
- URL for Custom Field API changed from `/custom_fields/*/` to `/custom_field/*/` (old endpoint continues working)

---

## 4.1 Lead Custom Fields

### List All Lead Custom Fields

```
GET /custom_field/lead/
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | Optional | Maximum number of results to return |
| `_skip` | integer | Optional | Number of results to skip for pagination |

### Create a New Lead Custom Field

```
POST /custom_field/lead/
```

### Fetch Lead Custom Field Details

```
GET /custom_field/lead/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The custom field ID |

### Update a Lead Custom Field

```
PUT /custom_field/lead/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The custom field ID to update |

**Updateable Fields:**
- Field name
- Field type
- Multiple values acceptance setting
- Role-based edit restrictions
- Options for "choices" field types

**Notes:**
- The updated name will immediately appear in the Close UI
- Only valid values for the updated `type` will be returned by the Lead API
- Type conversions may trigger a `converting_to_type` response field during processing

### Delete a Lead Custom Field

```
DELETE /custom_field/lead/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The custom field ID to delete |

The field will immediately disappear from any Lead API responses.

---

## 4.2 Contact Custom Fields

### List All Contact Custom Fields

```
GET /custom_field/contact/
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | Optional | Limit number of results |
| `_skip` | integer | Optional | Skip number of results |

### Create a New Contact Custom Field

```
POST /custom_field/contact/
```

### Fetch Contact Custom Field Details

```
GET /custom_field/contact/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The custom field ID |

### Update a Contact Custom Field

```
PUT /custom_field/contact/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The custom field ID |

**Updateable Fields:**
- Field name
- Field type
- Multiple values acceptance setting
- Role-based edit restrictions
- Options for "choices" field types

**Note:** Type conversions may require data transformation. During conversion, the response includes a `converting_to_type` field that disappears upon completion.

### Delete a Contact Custom Field

```
DELETE /custom_field/contact/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The custom field ID |

The field immediately disappears from Contact API responses.

---

## 4.3 Opportunity Custom Fields

### List All Opportunity Custom Fields

```
GET /custom_field/opportunity/
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | Optional | Maximum number of records to return |
| `_skip` | integer | Optional | Number of records to skip for pagination |

### Create a New Opportunity Custom Field

```
POST /custom_field/opportunity/
```

### Fetch Opportunity Custom Field Details

```
GET /custom_field/opportunity/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The custom field identifier |

### Update an Opportunity Custom Field

```
PUT /custom_field/opportunity/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The field identifier to update |

**Updateable Fields:**
- Field name
- Field type
- Multiple value acceptance setting
- Role-based editing restrictions
- Options for choice-type fields

**Note:** Type conversions may require processing indicated by a `converting_to_type` field in the response.

### Delete an Opportunity Custom Field

```
DELETE /custom_field/opportunity/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The field identifier to delete |

The field will immediately disappear from any Opportunity API responses.

---

## 4.4 Activity Custom Fields

Activity Custom Fields belong to Custom Activities and have two additional attributes beyond standard custom fields:
- `custom_activity_type_id` -- identifies the Custom Activity Type this field belongs to
- `required` -- specifies whether the field must be completed before publishing the activity

### List All Activity Custom Fields

```
GET /custom_field/activity/
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | No | Maximum number of records to return |
| `_skip` | integer | No | Number of records to skip for pagination |

### Create a New Activity Custom Field

```
POST /custom_field/activity/
```

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `custom_activity_type_id` | string | Yes | ID of the Custom Activity Type this field belongs to |
| `required` | boolean | No | Whether the field is required to publish the activity |
| `name` | string | Yes | Field name |
| `type` | string | Yes | Field data type (e.g., text, number, choices) |

### Fetch Activity Custom Field Details

```
GET /custom_field/activity/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The custom field identifier |

### Update an Activity Custom Field

```
PUT /custom_field/activity/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The custom field identifier |

**Updateable Fields:**
- Field name
- Multiple values acceptance setting
- `required` flag
- Role-based editing restrictions
- Options for "choices" field type

**Constraints:** The `custom_activity_type_id` and `type` values cannot be changed after creation.

### Delete an Activity Custom Field

```
DELETE /custom_field/activity/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The custom field identifier |

The field will immediately disappear from any Custom Activity API responses.

---

## 4.5 Custom Object Custom Fields

Custom Object Custom Fields are fields that belong to Custom Objects. They have additional attributes:
- `custom_object_type_id` -- ID of the Custom Object Type this field belongs to
- `required` -- whether the field is required to save the object

### List All Custom Object Custom Fields

```
GET /custom_field/custom_object_type/
```

### Create a New Custom Object Custom Field

```
POST /custom_field/custom_object_type/
```

**Request Body:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_object_type_id` | string | Yes | ID of the Custom Object Type this field belongs to |
| `required` | boolean | No | Whether the field is required to save the object |

### Fetch Custom Object Custom Field Details

```
GET /custom_field/custom_object_type/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The custom field identifier |

### Update a Custom Object Custom Field

```
PUT /custom_field/custom_object_type/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The custom field identifier |

**Updateable Fields:**
- Field name
- Multiple value acceptance setting
- Required flag
- Role-based editing restrictions
- Options for "choices" field type

**Restrictions:** The `custom_object_type_id` and `type` values cannot be changed. Updated names appear immediately in the Close UI.

### Delete a Custom Object Custom Field

```
DELETE /custom_field/custom_object_type/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The custom field identifier |

The field immediately disappears from Custom Object API responses.

---

## 4.6 Shared Custom Fields

Shared Custom Fields differ from regular Custom Fields by including an `associations` field that defines which object types the field can be used on.

### List All Shared Custom Fields

```
GET /custom_field/shared/
```

### Create a New Shared Custom Field

```
POST /custom_field/shared/
```

### Update a Shared Custom Field

```
PUT /custom_field/shared/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The shared custom field identifier |

**Updateable:**
- Field name
- Options for "choices" field types

**Constraints:**
- The `type` value cannot be changed
- Updated names appear immediately in the Close UI
- Only valid values for updated `choices` are returned by APIs

### Delete a Shared Custom Field

```
DELETE /custom_field/shared/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The shared custom field identifier |

The field immediately disappears from all associated objects and related APIs (Lead/Contact/Custom Activity).

### Associate a Shared Custom Field

```
POST /custom_field/shared/{shared_custom_field_id}/association/
```

**Request Body:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `object_type` | string | Yes | One of: `lead`, `contact`, `opportunity`, `custom_activity_type`, `custom_object_type` |
| `custom_activity_type_id` | string | Conditional | Required if `object_type` is `custom_activity_type` |
| `custom_object_type_id` | string | Conditional | Required if `object_type` is `custom_object_type` |
| `editable_with_roles` | array | No | List of Roles that can edit field values (per-association setting) |
| `required` | boolean | No | Whether a value must be provided (only for `custom_activity_type` or `custom_object_type`) |

### Update a Shared Custom Field Association

```
PUT /custom_field/shared/{shared_custom_field_id}/association/{object_type}/
```

**URL Parameters:**

| Parameter | Description |
|-----------|-------------|
| `shared_custom_field_id` | The shared custom field identifier |
| `object_type` | `lead`, `contact`, `opportunity`, `custom_activity_type/<catype_id>`, or `custom_object_type/<cotype_id>` |

**Updateable:** `required` and `editable_with_roles`

### Disassociate a Shared Custom Field

```
DELETE /custom_field/shared/{custom_field_id}/association/{object_type}/
```

**URL Parameters:**

| Parameter | Description |
|-----------|-------------|
| `custom_field_id` | The shared custom field identifier |
| `object_type` | `lead`, `contact`, `opportunity`, `custom_activity_type/<catype_id>`, or `custom_object_type/<cotype_id>` |

The field immediately disappears from the disassociated object type.

---

## 4.7 Custom Field Schemas

A Custom Field Schema presents you with _all_ (regular and shared) Custom Fields that belong on a given object (Lead, Contact, Opportunity, or some specific Custom Activity or Custom Object Type), in the specific order that you've defined.

This endpoint is recommended for answering "What Custom Fields can I set on this object?"

### Fetch a Custom Field Schema

```
GET /custom_field_schema/{object_type}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `object_type` | string (path) | Yes | One of: `lead`, `contact`, `opportunity`, `activity/<cat_id>`, `custom_object/<cotype_id>` |

Returns all custom fields belonging to the specified object type in defined order.

### Reorder Custom Fields within a Schema

```
PUT /custom_field_schema/{object_type}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `object_type` | string (path) | Yes | One of: `lead`, `contact`, `opportunity`, `activity/<cat_id>`, `custom_object/<cotype_id>` |

**Request Body:**

```json
{
  "fields": [
    {"id": "cf_xxx"},
    {"id": "cf_yyy"}
  ]
}
```

**Notes:**
- Supply a `fields` list containing `{"id": ...}` objects for each custom field
- IDs omitted from the list are automatically appended to the end
- To remove fields, delete the custom field or disassociate shared fields from the object

---

# 5. Custom Activities

Custom Activities let you create arbitrary activity types with user-defined fields. Implementation follows a three-step process:

1. Create a Custom Activity Type
2. Add Activity Custom Fields or associate Shared Custom Fields
3. Create and manage Custom Activity instances

---

## 5.1 Custom Activity Types

### List Custom Activity Types

```
GET /custom_activity/
```

Returns all Custom Activity Types for the organization, including Custom Field metadata.

### Create New Custom Activity Type

```
POST /custom_activity/
```

Creates a new Custom Activity Type. The type must exist before custom fields can be associated with it.

### Retrieve a Single Custom Activity Type

```
GET /custom_activity/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The Custom Activity Type ID |

Returns a specific Custom Activity Type with its Custom Field metadata.

### Update Existing Custom Activity Type

```
PUT /custom_activity/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The Custom Activity Type ID |

**Updateable Fields:**
- `name`
- `description`
- `api_create_only`
- `editable_with_roles`
- `is_archived`
- Field order (display property only)

**Note:** Adding, modifying, or removing fields must be done via the Custom Field API. Field order is a display property and does not affect API requests/responses.

### Delete a Custom Activity Type

```
DELETE /custom_activity/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The Custom Activity Type ID |

---

## 5.2 Custom Activity Instances

### List or Filter Custom Activity Instances

```
GET /activity/custom/
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `lead_id` | string | Optional | Filter by lead ID |
| `user_id` | string | Optional | Filter by user ID |
| `date_created__gt` | ISO datetime | Optional | Filter for activities created after a specific date |
| `date_created__lt` | ISO datetime | Optional | Filter for activities created before a specific date |
| `custom_activity_type_id` | string | Optional | Filter by custom activity type ID (**requires `lead_id`**) |
| `custom_activity_type_id__in` | string | Optional | Filter by multiple custom activity type IDs (**requires `lead_id`**) |

**Important Notes:**
- When filtering by `custom_activity_type_id` or `custom_activity_type_id__in`, the `lead_id` parameter is required
- To retrieve all Custom Activity instances of a specific type across all leads, use Advanced Filtering first to identify relevant leads, then query each lead individually
- Custom Fields appear as `custom.{custom_field_id}`

### Create Custom Activity Instance

```
POST /activity/custom/
```

**Behavior:**
- Custom Activity instances are created with "published" status by default
- All required fields are validated in "published" status
- Use "draft" status to create activities without setting all required fields
- A Custom Activity can be pinned via the `pinned` field (set to `true` or `false`)

### Retrieve Single Custom Activity Instance

```
GET /activity/custom/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The unique identifier of the Custom Activity instance |

### Update Custom Activity Instance

```
PUT /activity/custom/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The unique identifier of the Custom Activity instance |

**Updateable Fields:**
- Custom Fields (add, change, or remove)
- Status (toggle between "draft" and "published")
- `pinned` field (set to `true` or `false`)

### Delete Custom Activity Instance

```
DELETE /activity/custom/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The unique identifier of the Custom Activity instance |

---

# 6. Custom Objects

Custom Objects are flexible data structures associated with leads that support custom fields. Implementation follows a three-step process:

1. Create a Custom Object Type
2. Add Custom Object Custom Fields or associate Shared Custom Fields
3. Create and manage Custom Object instances on Leads

---

## 6.1 Custom Object Types

### List Custom Object Types

```
GET /custom_object_type/
```

Retrieves all Custom Object Types for your organization, including custom field metadata. The response includes two field lists:
- `fields` -- fields belonging to the type
- `back_reference_fields` -- objects referencing this type

### Create New Custom Object Type

```
POST /custom_object_type/
```

**Required Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | The name of the Custom Object Type |
| `name_plural` | string | Yes | Pluralized version for UI display |

**Optional Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `description` | string | No | Longer description of the type |
| `api_create_only` | boolean | No | If true, instances can only be created via API (default: false) |
| `editable_with_roles` | array | No | Restricts editing to users with specified roles |

### Retrieve Single Custom Object Type

```
GET /custom_object_type/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The Custom Object Type ID |

Returns a single Custom Object Type with associated custom field metadata.

### Update Custom Object Type

```
PUT /custom_object_type/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The Custom Object Type ID |

**Updatable Fields:**
- `name`
- `name_plural`
- `description`
- `api_create_only`
- `editable_with_roles`
- `is_archived` (for archiving)

**Note:** You cannot add, modify, remove or reorder fields from a Custom Object Type using this resource. Use Custom Object Custom Fields or Custom Field Schema APIs instead.

### Delete Custom Object Type

```
DELETE /custom_object_type/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The Custom Object Type ID |

---

## 6.2 Custom Object Instances

### List Custom Object Instances

```
GET /custom_object/
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `lead_id` | string | **Yes** | Filter instances by lead ID |
| `custom_object_type_id` | string | Optional | Filter by custom object type |

**Notes:**
- The `lead_id` parameter is required for listing operations without Advanced Filtering
- Custom field values appear as `custom.{custom_field_id}`
- For back references, use Advanced Filtering instead

### Create a New Custom Object Instance

```
POST /custom_object/
```

**Required Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `custom_object_type_id` | string | Yes | Determines available custom fields |
| `lead_id` | string | Yes | Associated lead identifier |
| `name` | string | Yes | Display name for the instance |

Custom fields are set using format `custom.{custom_field_id}`.

### Retrieve a Single Custom Object Instance

```
GET /custom_object/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Unique instance identifier |

### Update a Custom Object Instance

```
PUT /custom_object/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Unique instance identifier |

**Modifiable Fields:**
- Custom field values (add, change, or remove)
- `name` property

### Delete a Custom Object Instance

```
DELETE /custom_object/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Instance to delete |

---

# 7. Changelog

## March 6th, 2026 - `applies_to` field on Outcomes deprecated for write operations

The `applies_to` field on the Outcome API is now deprecated on write operations (create and update). Future updates will derive this field from the `type` field:
- When `type` is `custom`, `applies_to` will be `["calls", "meetings"]`
- When `type` is `vm-dropped`, `applies_to` will be `["calls"]`

The field continues to be returned in read responses.

## January 14th, 2026 - Form Submissions API

Form Submissions added as a new activity type, created when someone fills out a Close Form. New webhook events: `activity.form_submission.created`, `activity.form_submission.updated`, and `activity.form_submission.deleted`.

## December 17th, 2025 - `sender` field requirements for Email activities

Fixed bug allowing email creation without required `sender`. The `sender` field is now required for emails with status `inbox`, `scheduled`, `outbox`, or `error`. It may be omitted for `draft` status or defaults to user's email for `sent` status.

## August 25th, 2025 - Note titles and pinned_at timestamps

Added ability to set Note `title` field when creating or updating Notes. Added `title` and `pinned_at` fields to Note API responses.

## August 14th, 2025 - Transcription related fields in Meeting API

Added `transcripts` field to Meeting API responses.

## July 29th, 2025 - Outcome API

Introduced new Outcome API for organizing and managing outcomes -- standardized results applicable to activities like calls and meetings.

## July 16th, 2025 - Field Enrichment API

Introduced Field Enrichment API using AI to intelligently populate fields on leads and contacts.

## June 25th, 2025 - WhatsApp Messages API

Added WhatsApp Messages as new activity type for syncing WhatsApp conversations into Close. Supports inbound/outbound messages, file attachments (up to 25MB), integration links, and thread support via `response_to_id` field. New webhook events: `activity.whatsapp_message.created`, `activity.whatsapp_message.updated`, `activity.whatsapp_message.deleted`.

## Feb 14th, 2025 - `lead_id` is now optional when creating a Contact or Opportunity

Ability to create a Contact without specifying `lead_id` -- automatically creates new Lead named after the contact. Similarly, creating an Opportunity without `lead_id` creates untitled Lead and associates the opportunity.

## Jan 6th, 2025 - Updating Webhook Subscriptions

Webhook Subscription PUT endpoint now accepts `url`, new `events` list, and `verify_ssl` parameter to control SSL verification at destination URL.

## Dec 2nd, 2024 - `record_calls` field on memberships deprecated

Boolean `record_calls` field deprecated in favor of `auto_record_calls` enum field with values `'unset'`, `'enabled'`, or `'disabled'`.

## Nov 6th, 2024 - Date format in CSV Exports

Export API updated with new `date_format` parameter to control date object formatting in CSV exports.

## Sep 9th, 2024 - Archiving Custom Object Types

Custom Object Types can now be archived via `is_archived: true` flag during update operations.

## Aug 28th, 2024 - Custom Objects are now public

Custom Objects no longer in beta; available to everyone on corresponding billing plan.

## Jun 26th, 2024 - Delete Lead & Opportunity status change activities

Added ability to delete Lead and Opportunity Status Change activities. Deletion removes event from activity feed without changing Lead or Opportunity status.

## Jun 20th, 2024 - Create Lead & Opportunity status change activities

Added ability to create Lead and Opportunity Status Change activities. Creates log entries without changing status -- useful for importing historical changes.

## Jun 10th, 2024 - Disallow Membership creation via API Keys

Membership API no longer allows creation via API keys; possible only with OAuth.

## Jun 7th, 2024 - Lead API only returns incomplete tasks

Lead API now returns only incomplete tasks in "tasks" field. Completed tasks accessible via Task API filtering by `lead_id` and `view=archive`.

## Apr 24th, 2024 - Rate limit body deprecated

Rate limit information should be in headers (RFC spec compliant) rather than request body.

## Mar 28th, 2024 - Commenting API

New Commenting API added for commenting on objects within Close.

## Mar 27th, 2024 - Pipeline fields in Opportunities

Added `pipeline_id` and `pipeline_name` fields to Opportunity responses without requiring extra request.

## Feb 26th, 2024 - Files API, Email Attachments

New Files API for uploading files to Close for use as email attachments in activities and templates.

## Feb 21st, 2024 - Custom Objects (BETA)

Custom Objects API (BETA) added for managing Custom Object Types, Instances, and Custom Fields. Subject to change without notice.

## Feb 15th, 2024 - Email Unsubscribe

Contact resource now includes `emails[].is_unsubscribed` attribute. New webhook event: `unsubscribed_email.created`.

## Nov 13th, 2023 - Scheduling Link integrations

Two new OAuth endpoints added for integrating OAuth Applications to sync scheduling links into Close.

## Nov 10, 2023 - Returning single custom fields in the Leads API

Leads API now supports returning subset of custom fields when querying leads.

## Oct 26th, 2023 - Transcription related fields in Call API

Added `recording_transcript` and `voicemail_transcript` fields to Call API responses.

## Oct 2nd, 2023 - Change to Sequence Subscription API

Added `lead_id` field to Sequence Subscription API responses.

## Sept 21st, 2023 - Third party Meeting integrations & Meeting search

Ability to create/update third-party Meeting integrations (OAuth apps only). New Meeting search endpoint for filtering by calendar provider information.

## Aug 29th, 2023 - Change to the Sequence API

New `schedule` field added; existing `schedule_id` field removed from Sequence API.

## July 21st, 2023 - Rate limit headers updated

Rate limit headers updated to comply with current RFC specification.

## June 29th, 2023 - Lead visibility related fields in Role

Lead visibility-related fields added to Roles API.

## June 20th, 2023 - OAuth Applications

OAuth support added for authentication and authorization.

## May 1st, 2023 - Scheduling Links

Scheduling Links support added to the API.

## Dec 22nd, 2022 - "Hidden" type Custom Field values visible in Event Log

"Hidden" type Custom Field values now displayed in Event Log (previously hidden).

## Sept 26th, 2022 - SMS Templates

SMS Templates support added.

## Mar 10th, 2022 - Sequences

Support added for calling steps within Sequences.

## Feb 15th, 2022 - MMS support

Added MMS support for phone rentals (Canada/USA only) via `with_mms` parameter. Added `attachments` field to SMS activities and Incoming SMS tasks.

## Feb 14th, 2022 - Advanced Filtering API

New Advanced Filtering API functionality for filtering Lead objects. Lead endpoint `query` parameter now deprecated.

## Nov 16th, 2021 - New Webhook Filters

Four new webhook filters added: `is_null`, `non_null`, `not_equals`, and `not`.

## Nov 9th, 2021 - Undocumented an old endpoint for Activity Reporting

Removed documentation for old/deprecated Activity Reporting endpoint `/report/activity/{organization_id}/`.

## June 11th, 2021 - Custom Fields on Opportunities

Opportunities can now have Custom Fields. New Opportunity Custom Field API endpoint; Shared Custom Fields extended to support Opportunities.

## June 7th, 2021 - Automatically pause failing webhook subscriptions

Webhook subscriptions automatically paused after 3 days of all event delivery failures.

## May 17th, 2021 - Custom Field ID Format

New Custom Fields share common `cf_` prefix instead of type-specific prefixes. Existing Custom Field IDs unchanged.

## Apr 22th, 2021 - Shared Custom Fields

New endpoints for creating Shared Custom Fields, associating them across object types, and reordering Custom Fields.

## Apr 13th, 2021 - Contact Filtering

New endpoint for finding Contacts by arbitrary filter sets.

## Mar 31st, 2021 - Change to the Sequence API

Listing Sequence Subscriptions now requires filtering by `sequence_id`, `lead_id`, or `contact_id`.

## Jan 5th, 2021 - Changes to the Sequence API

Permission errors now return 403 instead of 401. Sequence Step errors simplified to high-level messages.

## Oct 29th, 2020 - Microsoft Connected Accounts

Microsoft Accounts now connectable via OAuth for Office 365 email.

## Oct 9th, 2020 - Send As API

Send As feature available through API using new Send As endpoint.

## Oct 3rd, 2020 - Active Calls on the Users Availability API

Users Availability API now indicates which users are currently on active phone calls.

## Sep 18th, 2020 - New URL for the Custom Field API

Custom Field API recommended URL changed from `/custom_fields/*/` to `/custom_field/*/`. Old endpoint continues working.

## Aug 13th, 2020 - Groups

Groups allow naming collections of Users for filtering and reporting.

## Aug 7th, 2020 - Custom Activities Beta

Limited beta launch of Custom Activities feature for defining arbitrary activity types. API may change before launch.

## Jun 30th, 2020 - Connected Accounts and clarification on field usage in integrations

Connected Accounts endpoint added for retrieving connected account information. Clarification added: non-custom fields not in sample responses shouldn't be used.

## May 19th, 2020 - HTTP/2 and Header Casing

New infrastructure supports HTTP/2. Headers normalized to lowercase in responses; case-insensitive in requests.

## Apr 30th, 2020 - Custom Field Description

Custom Fields now support optional description property for user context.

## Apr 6th, 2020 - Custom Fields on Contacts

Contacts can now have Custom Fields. New Contact Custom Field API endpoint added.

## Dec 10th, 2019 - Introducing Pipelines

Pipelines introduced as named/ordered groups of Opportunity Statuses. Opportunity Statuses field in Organization/Me APIs deprecated; use `pipelines` field instead.

## Nov 13th, 2019 - Deprecate old Activity Report endpoint

New Activity Report endpoint (POST to `/report/activity/`) should replace old version (GET to `/report/activity/{ORGANIZATION_ID}/`).

## Oct 31st, 2019 - Deprecate setting a status on an Opportunity via the `status` field

Use `status_id` field for Opportunity status operations; deprecated status label usage in `status` field.

## Oct 12th, 2019 - Add new endpoint for Meeting activities

New `/activity/meeting/` endpoint added for Google Calendar Meeting activities (beta).

## Aug 20th, 2019 - POST HTTP Status Code

Newer APIs return `201` HTTP status for POST requests with `Location` header. Existing APIs continue returning `200`.

## Jul 2nd, 2019 - Add multiple value support to the bulk edit action

`custom_field_values` and `custom_field_operation` support multiple values for bulk edit actions.

## June 18th, 2019 - Add event filtering to webhook subscriptions

Webhook subscriptions now support `extra_filter` field for filtering events by field/value changes.

## May 10th, 2019 - Add API key ID to events

Event log and webhook events now contain API key ID if changes made via API key.

## May 8th, 2019 - Add new activity report endpoint

New activity report endpoint fetches additional metrics; available metrics exposed in reporting API.

## Apr. 25th, 2019 - Support for Multi-Select Custom Fields

"Choices" and "User" type Custom Fields now accept multiple values via `accepts_multiple_values: true`.

## Apr. 9th, 2019 - All exports are now compressed with GZIP

All exports compressed with GZIP; headers set to `Content-Encoding: gzip` and appropriate `Content-Type`.

## Mar. 7th, 2019 - Drop the field `plan_type` from the `Membership` API

`plan_type` field dropped for organizations using new billing system.

## Feb. 22, 2019 - New Base URL

API base URL changed from `https://app.close.io/api/v1/` to `https://api.close.com/api/v1/`. Old URL deprecated.

## Feb. 18, 2019 - Additional country fields

Country information added to Contact API (phone numbers), Phone Number API (SMS countries), and SMS API responses.

## Jan. 25, 2019 - Event Log Fields

Non-admin events include `data` and `previous_data` fields for events not older than 1 hour; older events exclude these fields.

## Nov. 28, 2018 - Webhooks Subscription API

Webhooks Subscription API added.

---

# Quick Reference: All Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/event/{id}/` | Retrieve single event |
| `GET` | `/event/` | List/filter events |
| `GET` | `/webhook/` | List webhook subscriptions |
| `POST` | `/webhook/` | Create webhook subscription |
| `GET` | `/webhook/{id}/` | Get webhook subscription |
| `PUT` | `/webhook/{id}/` | Update webhook subscription |
| `DELETE` | `/webhook/{id}/` | Delete webhook subscription |
| `GET` | `/scheduling_link/` | List user scheduling links |
| `POST` | `/scheduling_link/` | Create user scheduling link |
| `GET` | `/scheduling_link/{id}/` | Get user scheduling link |
| `PUT` | `/scheduling_link/{id}/` | Update user scheduling link |
| `DELETE` | `/scheduling_link/{id}/` | Delete user scheduling link |
| `POST` | `/scheduling_link/integration/` | Create/update OAuth scheduling link |
| `DELETE` | `/scheduling_link/integration/{source_id}/` | Delete OAuth scheduling link |
| `GET` | `/shared_scheduling_link/` | List shared scheduling links |
| `POST` | `/shared_scheduling_link/` | Create shared scheduling link |
| `GET` | `/shared_scheduling_link/{id}/` | Get shared scheduling link |
| `PUT` | `/shared_scheduling_link/{id}/` | Update shared scheduling link |
| `DELETE` | `/shared_scheduling_link/{id}/` | Delete shared scheduling link |
| `POST` | `/shared_scheduling_link_association/` | Map shared scheduling link |
| `POST` | `/shared_scheduling_link_association/unmap` | Unmap shared scheduling link |
| `GET` | `/custom_field/lead/` | List lead custom fields |
| `POST` | `/custom_field/lead/` | Create lead custom field |
| `GET` | `/custom_field/lead/{id}/` | Get lead custom field |
| `PUT` | `/custom_field/lead/{id}/` | Update lead custom field |
| `DELETE` | `/custom_field/lead/{id}/` | Delete lead custom field |
| `GET` | `/custom_field/contact/` | List contact custom fields |
| `POST` | `/custom_field/contact/` | Create contact custom field |
| `GET` | `/custom_field/contact/{id}/` | Get contact custom field |
| `PUT` | `/custom_field/contact/{id}/` | Update contact custom field |
| `DELETE` | `/custom_field/contact/{id}/` | Delete contact custom field |
| `GET` | `/custom_field/opportunity/` | List opportunity custom fields |
| `POST` | `/custom_field/opportunity/` | Create opportunity custom field |
| `GET` | `/custom_field/opportunity/{id}/` | Get opportunity custom field |
| `PUT` | `/custom_field/opportunity/{id}/` | Update opportunity custom field |
| `DELETE` | `/custom_field/opportunity/{id}/` | Delete opportunity custom field |
| `GET` | `/custom_field/activity/` | List activity custom fields |
| `POST` | `/custom_field/activity/` | Create activity custom field |
| `GET` | `/custom_field/activity/{id}/` | Get activity custom field |
| `PUT` | `/custom_field/activity/{id}/` | Update activity custom field |
| `DELETE` | `/custom_field/activity/{id}/` | Delete activity custom field |
| `GET` | `/custom_field/custom_object_type/` | List custom object custom fields |
| `POST` | `/custom_field/custom_object_type/` | Create custom object custom field |
| `GET` | `/custom_field/custom_object_type/{id}/` | Get custom object custom field |
| `PUT` | `/custom_field/custom_object_type/{id}/` | Update custom object custom field |
| `DELETE` | `/custom_field/custom_object_type/{id}/` | Delete custom object custom field |
| `GET` | `/custom_field/shared/` | List shared custom fields |
| `POST` | `/custom_field/shared/` | Create shared custom field |
| `PUT` | `/custom_field/shared/{id}/` | Update shared custom field |
| `DELETE` | `/custom_field/shared/{id}/` | Delete shared custom field |
| `POST` | `/custom_field/shared/{id}/association/` | Associate shared field |
| `PUT` | `/custom_field/shared/{id}/association/{type}/` | Update association |
| `DELETE` | `/custom_field/shared/{id}/association/{type}/` | Disassociate shared field |
| `GET` | `/custom_field_schema/{object_type}/` | Get custom field schema |
| `PUT` | `/custom_field_schema/{object_type}/` | Reorder custom fields |
| `GET` | `/custom_activity/` | List custom activity types |
| `POST` | `/custom_activity/` | Create custom activity type |
| `GET` | `/custom_activity/{id}/` | Get custom activity type |
| `PUT` | `/custom_activity/{id}/` | Update custom activity type |
| `DELETE` | `/custom_activity/{id}/` | Delete custom activity type |
| `GET` | `/activity/custom/` | List custom activity instances |
| `POST` | `/activity/custom/` | Create custom activity instance |
| `GET` | `/activity/custom/{id}/` | Get custom activity instance |
| `PUT` | `/activity/custom/{id}/` | Update custom activity instance |
| `DELETE` | `/activity/custom/{id}/` | Delete custom activity instance |
| `GET` | `/custom_object_type/` | List custom object types |
| `POST` | `/custom_object_type/` | Create custom object type |
| `GET` | `/custom_object_type/{id}/` | Get custom object type |
| `PUT` | `/custom_object_type/{id}/` | Update custom object type |
| `DELETE` | `/custom_object_type/{id}/` | Delete custom object type |
| `GET` | `/custom_object/` | List custom object instances |
| `POST` | `/custom_object/` | Create custom object instance |
| `GET` | `/custom_object/{id}/` | Get custom object instance |
| `PUT` | `/custom_object/{id}/` | Update custom object instance |
| `DELETE` | `/custom_object/{id}/` | Delete custom object instance |

**Base URL:** `https://api.close.com/api/v1/`
**Authentication:** HTTP Basic Auth with API key as username, empty password. OAuth also supported.
