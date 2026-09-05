# Close CRM API — Features Documentation

> **Source:** https://developer.close.com
> **Date scraped:** 2026-03-30
> **Base URL:** `https://api.close.com/api/v1`
> **Auth:** Basic Auth with API key as username, empty password
> **Note:** The "Example Request/Response" sections on the Close developer site are rendered via client-side JavaScript and cannot be statically extracted. This document captures ALL endpoint definitions, parameters, field types, behavioral notes, and code examples that are present in the documentation.

---

## Table of Contents

1. [Email Templates](#1-email-templates)
2. [SMS Templates](#2-sms-templates)
3. [Connected Accounts](#3-connected-accounts)
4. [Send As](#4-send-as)
5. [Sequences](#5-sequences)
6. [Dialer](#6-dialer)
7. [Smart Views](#7-smart-views)
8. [Bulk Actions](#8-bulk-actions)
9. [Integration Links](#9-integration-links)
10. [Exports](#10-exports)
11. [Phone Numbers](#11-phone-numbers)
12. [Files](#12-files)
13. [Comments](#13-comments)
14. [Unsubscribe Email Address](#14-unsubscribe-email-address)
15. [Rich Text Fields](#15-rich-text-fields)
16. [Field Enrichment](#16-field-enrichment)

---

## 1. Email Templates

Email Templates are predefined emails that can be used over and over again when sending email. They save time when sending emails one at a time via the Close UI, and they are also used when initiating a single Bulk Email.

### List Email Templates

```
GET /email_template/{?is_archived, _limit, _skip}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `is_archived` | boolean | No | Filter by archived status |
| `_limit` | integer | No | Pagination limit |
| `_skip` | integer | No | Pagination offset |

### Create Email Template

```
POST /email_template/
```

Creates a new email template. Request body should include template name, subject, and body content.

### Fetch Email Template

```
GET /email_template/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Email template ID |

### Update Email Template

```
PUT /email_template/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Email template ID |

### Delete Email Template

```
DELETE /email_template/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Email template ID |

### Render Email Template

Render an email template for the given lead/contact using the current user context.

```
GET /email_template/{id}/render/{?lead_id, contact_id, query, entry, mode}
```

Accepts two forms of usage:

**Single lead/contact:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Email template ID |
| `lead_id` | string | Yes | Lead ID to render for |
| `contact_id` | string | Yes | Contact ID to render for |

**Preview results from a search query:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Email template ID |
| `query` | string | Yes | Search query string |
| `entry` | integer | No | Index (0-99) into search results |
| `mode` | string | No | `lead` (default) or `contact` |

**Mode behavior:**
- `lead` (default): The first contact of the lead with the index given by `entry` will be rendered (excluding leads that have no email addresses).
- `contact`: `entry` refers to the index of the contact (excluding contacts that have no emails). Will return an empty dict if there are no more entries.

---

## 2. SMS Templates

SMS Templates are predefined messages that can be used over and over again when sending SMS. They save time when sending sms one at a time via the Close UI.

### List SMS Templates

```
GET /sms_template/{?_limit, _skip}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | No | Pagination limit |
| `_skip` | integer | No | Pagination offset |

### Create SMS Template

```
POST /sms_template/
```

Creates a new SMS template.

### Fetch SMS Template

```
GET /sms_template/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | SMS template ID |

### Update SMS Template

```
PUT /sms_template/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | SMS template ID |

### Delete SMS Template

```
DELETE /sms_template/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | SMS template ID |

---

## 3. Connected Accounts

This endpoint can be used to pull information about the Email and Zoom accounts you currently have connected under Settings > Connected Accounts in Close and Email accounts you have the ability to send as via the Send As functionality.

### Account Types

Connected Accounts have the following possible values for `_type`:

| `_type` Value | Description |
|---------------|-------------|
| `google` | Gmail account using Google OAuth to connect to Close |
| `custom_email` | Non-Gmail email account (e.g. Mailgun, Sendgrid integrations) |
| `zoom` | Zoom account using the Zoom Integration |
| `microsoft` | Microsoft account using Microsoft OAuth to connect to Close |
| `calendly` | Calendly account using Calendly OAuth to connect to Close |

**Note:** `google` and `microsoft` connected accounts have a `synced_calendars` field that contains which calendars are synced in as part of Meetings Sync.

### List Connected Accounts

```
GET /connected_account/{?user_id}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `user_id` | string | No | Filter to a specific user's connected accounts |

Returns all connected accounts you can use in your organization.

### Fetch Connected Account

```
GET /connected_account/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Connected account ID |

---

## 4. Send As

The Send As feature allows a user to explicitly allow another user to send individual emails, bulk emails, and sequence emails as them. Send As permission must be explicitly granted by the user that's allowing another user to send as them. This permission can be revoked by the allowing user at any time.

### List Send As Associations

```
GET /send_as/{?allowing_user_id, allowed_user_id}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `allowing_user_id` | string | No | User ID of the person allowing others to send as them |
| `allowed_user_id` | string | No | User ID of the person allowed to send as another |

**Behavior:** A user only has access to associations they are involved in. This means `allowing_user_id` or `allowed_user_id` must be equal to your user ID. If neither filter is provided, `allowing_user_id` is assumed by default.

### Create Send As Association

```
POST /send_as/
```

**Constraint:** The `allowing_user_id` must be equal to your user ID.

### Delete Send As Association by Users

```
DELETE /send_as/{?allowing_user_id, allowed_user_id}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `allowing_user_id` | string | Yes | Must equal your user ID |
| `allowed_user_id` | string | Yes | User to revoke permission from |

### Retrieve Single Send As Association

```
GET /send_as/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Association ID |

### Delete Send As Association by ID

```
DELETE /send_as/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Association ID |

### Bulk Edit Send As Associations

```
POST /send_as/bulk/
```

You can allow and disallow many other users to send as you in a single command by supplying the user IDs you want to allow and disallow.

Once completed, this endpoint returns all existing associations where your user is the allowing user.

---

## 5. Sequences

A Sequence is a series of steps to be performed, one by one, in specified time gaps to specific subscribers until they reply. Steps may involve sending an email to or calling a subscriber.

### List Sequences

```
GET /sequence/{?_limit, _skip}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | No | Pagination limit |
| `_skip` | integer | No | Pagination offset |

### Create Sequence

```
POST /sequence/
```

Creates a new sequence with steps, schedule, and configuration.

### Fetch Sequence

```
GET /sequence/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Sequence ID |

### Update Sequence

```
PUT /sequence/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Sequence ID |

**IMPORTANT:** If you include `steps` in the payload and exclude some of the existing steps in your sequence, it will remove those steps from the sequence entirely.

### Delete Sequence

```
DELETE /sequence/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Sequence ID |

### List Sequence Subscriptions

```
GET /sequence_subscription/{?sequence_id, contact_id, lead_id}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `sequence_id` | string | Conditional | Sequence to filter by (at least one filter required) |
| `contact_id` | string | Conditional | Contact to filter by (at least one filter required) |
| `lead_id` | string | Conditional | Lead to filter by (at least one filter required) |

**Note:** At least one of `sequence_id`, `contact_id`, and `lead_id` is required.

### Subscribe Contact to Sequence

```
POST /sequence_subscription/
```

Subscribes a contact to a sequence.

### Fetch Sequence Subscription

```
GET /sequence_subscription/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Subscription ID |

### Update Sequence Subscription

```
PUT /sequence_subscription/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Subscription ID |

---

## 6. Dialer

A dialer is associated with a specific Smart View or Shared Entry and automatically calls each lead or contact in it for you. This allows you to call targets in a Smart View or Shared Entry faster.

Once the dialer for a Smart View or Shared Entry is initiated, it starts making calls to each target that belongs to it and connects you to the call once someone picks up.

### Dialer Types

| Type | Behavior |
|------|----------|
| `power` | Calls one lead in the Smart View at a time |
| `predictive` | Calls multiple leads simultaneously and connects you with the first lead that answers |

### Source Types

| `source_type` | Description |
|----------------|-------------|
| `saved-search` | Smart Views |
| `shared-entry` | Shared Entries |

### List or Filter Dialer Sessions

```
GET /dialer/{?status, status__in, source_value, source_type, user_id, _limit, _skip}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string | No | Filter by status |
| `status__in` | string | No | Filter by multiple statuses (comma-separated) |
| `source_value` | string | No | Filter by source value (Smart View or Shared Entry ID) |
| `source_type` | string | No | `saved-search` or `shared-entry` |
| `user_id` | string | No | Filter by user |
| `_limit` | integer | No | Pagination limit |
| `_skip` | integer | No | Pagination offset |

### Get Single Dialer Session

```
GET /dialer/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Dialer session ID |

**Note:** Once you have a `source_value` for a dialer session and `source_type=saved-search`, you can use the saved_search endpoint (`/saved_search/{id}/`) to find out more information about the Smart View being used.

**Response includes:** the `source_value` and `source_type` used in the dialer session, the type of the dialer sessions, the users included in the session, and more.

---

## 7. Smart Views

Smart Views are "saved search queries" in Close and show up in the sidebar in the UI. They can be private for a user or shared with an entire Organization. Smart Views can filter by leads or contacts.

### List Smart Views

```
GET /saved_search/{?type, type__in}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `type` | string | No | `lead` or `contact` (defaults to `lead`) |
| `type__in` | string | No | Comma-separated multiple types, e.g. `lead,contact` |

### Create Smart View

```
POST /saved_search/
```

Create a Lead or Contact Smart View.

For Lead Smart Views, the `type` field is optional (since `lead` is the default `type`).

**IMPORTANT:** When creating a Smart View, you must specify that you want to get objects of the appropriate type via an `object_type` clause as per the Advanced Filtering section.

### Get Single Smart View

```
GET /saved_search/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Smart View ID |

### Update Smart View

```
PUT /saved_search/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Smart View ID |

### Delete Smart View

```
DELETE /saved_search/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Smart View ID |

---

## 8. Bulk Actions

Bulk actions are used to perform an "action" (send an email, update a lead status, etc.) on a number of leads.

### Lead Filtering

To initiate bulk actions for a subset of leads you need to provide the structured filtering values that you would normally send to the Advanced Filtering API endpoint such as `query`, `results_limit`, and `sort` fields.

The only difference is that Bulk Actions endpoints require you to rename the `query` field to `s_query` (shorthand for structured query).

**Advanced Filtering API payload:**

```json
{
    "query": {
        "queries": [...]
    },
    "results_limit": 100,
    "sort": [
        { ... }
    ]
}
```

**Equivalent Bulk Actions payload (note `query` -> `s_query`):**

```json
{
    "s_query": {
        "queries": [...]
    },
    "results_limit": 100,
    "sort": [
        { ... }
    ]
}
```

### Pausing and Resuming

You can pause an in-progress bulk action by sending `{ "status": "paused" }`. You can also resume it afterwards (`{ "status": "resuming" }`), unless more than 7 days passed since you paused the action.

### Email Confirmation

Use `"send_done_email": false` if you don't want to get a confirmation email after a bulk action is done.

---

### Bulk Emails

#### List Bulk Emails

```
GET /bulk_action/email/
```

#### Initiate New Bulk Email

```
POST /bulk_action/email/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `contact_preference` | string | No | `lead` (only email the primary/first contact email of the lead) or `contact` (email the first contact email of each contact of the lead) |
| `s_query` | object | No | Structured query for lead filtering |
| `results_limit` | integer | No | Max number of leads to process |
| `sort` | array | No | Sort specification |
| `send_done_email` | boolean | No | Set to `false` to skip confirmation email |

#### Fetch Single Bulk Email

```
GET /bulk_action/email/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Bulk email action ID |

---

### Bulk Sequence Subscriptions

#### List Bulk Sequence Subscriptions

```
GET /bulk_action/sequence_subscription/
```

#### Initiate New Bulk Sequence Subscription

```
POST /bulk_action/sequence_subscription/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `action_type` | string | Yes | One of: `subscribe`, `resume`, `resume_finished`, `pause` |
| `sequence_id` | string | Conditional | Required if `action_type` is `subscribe`. Optional for resume/pause (if omitted, applies to all sequences) |
| `sender_account_id` | string | Conditional | Required if `action_type` is `subscribe` |
| `sender_name` | string | Conditional | Required if `action_type` is `subscribe` |
| `sender_email` | string | Conditional | Required if `action_type` is `subscribe` |
| `contact_preference` | string | Conditional | Required if `action_type` is `subscribe`. `lead` (only subscribe primary/first contact) or `contact` (subscribe primary email of each contact) |
| `s_query` | object | No | Structured query for lead filtering |
| `send_done_email` | boolean | No | Set to `false` to skip confirmation email |

**`action_type` values:**
- `subscribe` — create a new sequence subscription for contacts that have never received the given sequence
- `resume` — resume any paused sequence subscriptions for the given sequence or all sequences if `sequence_id` is not provided
- `resume_finished` — resume any finished sequence subscriptions for the given sequence or all sequences if `sequence_id` is not provided
- `pause` — pause any active sequence subscriptions for the given sequence or all sequences if `sequence_id` is not provided

#### Fetch Single Bulk Sequence Subscription

```
GET /bulk_action/sequence_subscription/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Bulk sequence subscription action ID |

---

### Bulk Deletes

#### List Bulk Deletes

```
GET /bulk_action/delete/
```

#### Initiate New Bulk Delete

```
POST /bulk_action/delete/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `s_query` | object | No | Structured query for lead filtering |
| `send_done_email` | boolean | No | Set to `false` to skip confirmation email |

#### Fetch Single Bulk Delete

```
GET /bulk_action/delete/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Bulk delete action ID |

---

### Bulk Edits

#### List Bulk Edits

```
GET /bulk_action/edit/
```

#### Initiate New Bulk Edit

```
POST /bulk_action/edit/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `type` | string | Yes | One of: `set_lead_status`, `clear_custom_field`, `set_custom_field` |
| `s_query` | object | No | Structured query for lead filtering |
| `send_done_email` | boolean | No | Set to `false` to skip confirmation email |

**Additional parameters by `type`:**

**`set_lead_status`** — Sets the Lead Status on all matching leads.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `lead_status_id` | string | Yes | ID of the Lead Status to use |

**`clear_custom_field`** — Clears/removes/unsets a specific custom field from all leads.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string | Conditional | ID of the custom field to remove (use this OR `custom_field_name`) |
| `custom_field_name` | string | Conditional | Exact name of the custom field to remove (use this OR `custom_field_id`) |

**`set_custom_field`** — Sets/updates/adds a specific custom field on all leads.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string | Conditional | ID of the custom field (use this OR `custom_field_name`) |
| `custom_field_name` | string | Conditional | Exact name of the custom field (use this OR `custom_field_id`) |
| `custom_field_value` | any | Yes | New value for the field. Use `custom_field_values` for multiple values |
| `custom_field_values` | array | No | Multiple values for fields that support it |
| `custom_field_operation` | string | No | `replace` (default), `add`, or `remove`. Only applicable for custom fields that accept multiple values |

#### Fetch Single Bulk Edit

```
GET /bulk_action/edit/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Bulk edit action ID |

---

## 9. Integration Links

This endpoint can be used to set up integration links available in Close. Each link has a `name` (displayed as link text), `url` template, and a `type`.

### Link Types

| Type | Description |
|------|-------------|
| `lead` | Link appears on lead pages |
| `contact` | Link appears on contact pages |
| `opportunity` | Link appears on opportunity pages |

**Note:** You can only create/edit/delete integration links if you're an admin.

### List Integration Links

```
GET /integration_link/
```

Returns all integration links for your organization.

### Create Integration Link

```
POST /integration_link/
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Display text for the link |
| `url` | string | Yes | URL template for the link |
| `type` | string | Yes | `lead`, `contact`, or `opportunity` |

### Get Single Integration Link

```
GET /integration_link/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Integration link ID |

### Update Integration Link

```
PUT /integration_link/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Integration link ID |

### Delete Integration Link

```
DELETE /integration_link/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Integration link ID |

---

## 10. Exports

This endpoint can be used to export data out of Close.

### Export Leads, Contacts, or Opportunities (by Lead Query)

```
POST /export/lead/
```

You will receive a link to the generated file via email once the export is done. The exported file is GZIP compressed. The `content-encoding` HTTP header will be set to `gzip` and the `content-type` HTTP header will be set to `text/csv` for CSV exports or `application/json` for JSON exports.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `format` | string | Yes | `csv` or `json` |
| `type` | string | Yes | `leads`, `contacts`, or `lead_opps` |
| `s_query` | object | No | Structured query for lead filtering (Advanced Filtering API format with `query` renamed to `s_query`) |
| `results_limit` | integer | No | Max number of results |
| `sort` | array | No | Sort specification |
| `date_format` | string | No | `original` (default), `iso8601`, or `excel`. Only works with CSV format |
| `fields` | array | No | Specific fields to export |
| `include_activities` | boolean | No | Include activities in export. JSON format only, `leads` type only |
| `include_smart_fields` | boolean | No | Include calculated/smart fields |
| `send_done_email` | boolean | No | Set to `false` to skip confirmation email (default: `true`) |

**`type` values:**
- `leads` — For CSV: one row per lead. For JSON: recommended type, superset of other types.
- `contacts` — For CSV: one row per contact.
- `lead_opps` — For CSV: one row per opportunity.

### Date Format Specifications

**`original` (default):**
- Date: `[YYYY]-[MM]-[DD]`
- Date with time: `[YYYY]-[MM]-[DD] [hh]:[mm]:[ss.sssss]+/-[hh]:[mm]`
- Includes microseconds and timezone information.

**`iso8601` (recommended):**
- Date: `[YYYY]-[MM]-[DD]`
- Date with time: `[YYYY]-[MM]-[DD]T[hh]:[mm]:[ss]+/-[hh]:[mm]`
- ISO 8601 compatible, no microseconds.

**`excel`:**
- Date: `[YYYY]-[MM]-[DD]`
- Date with time: `[YYYY]-[MM]-[DD] [hh]:[mm]:[ss] [AM|PM]`
- Always UTC, no timezone info, no microseconds, 12-hour clock.

### Export Opportunities (by Opportunity Filters)

```
POST /export/opportunity/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `format` | string | Yes | `csv` or `json` |
| `params` | object | No | Filter dictionary for the `/opportunity/` endpoint |
| `date_format` | string | No | `original` (default), `iso8601`, or `excel`. Only works with CSV format |
| `fields` | array | No | Specific fields to export |
| `send_done_email` | boolean | No | Set to `false` to skip confirmation email |

### Get Single Export

```
GET /export/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Export ID |

**Response fields:**

| Field | Type | Description |
|-------|------|-------------|
| `status` | string | One of: `created`, `started`, `in_progress`, `done`, `error` |
| `download_url` | string | Link to the exported file (available when status is `done`) |

### List All Exports

```
GET /export/{?_limit, _skip}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | No | Pagination limit |
| `_skip` | integer | No | Pagination offset |

---

## 11. Phone Numbers

This endpoint shows you all the phone numbers that exist in your organization and lets you rent new numbers. It lets you label them and configure their settings.

### Phone Number Types

| Type | Description |
|------|-------------|
| `internal` | Owned and controlled by Close |
| `external` | Owned by you, can only be used for outbound Close calls as a caller ID (e.g. your company cell phone number) |
| `virtual` | Owned by you, but calls are routed to Close via BYOC |

### Group Numbers

Whether a phone number belongs to an individual user or a group is determined by the `is_group_number` boolean. If a phone number is a group number, it will list all participating users' IDs in `participants` and all participating phone numbers in `phone_numbers`.

### List or Search Phone Numbers

```
GET /phone_number/{?number, user_id, is_group_number, _limit, _skip}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `number` | string | No | Filter by phone number |
| `user_id` | string | No | Filter by user ID |
| `is_group_number` | boolean | No | Filter by group number status |
| `_limit` | integer | No | Pagination limit |
| `_skip` | integer | No | Pagination offset |

### Retrieve Single Phone Number

```
GET /phone_number/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Phone number ID |

### Update Phone Number

```
PUT /phone_number/{id}/
```

**Permission:** You need the "Manage Group Phone Numbers" permission to update a group number. You can only update your own personal numbers.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `label` | string | No | Label for the number |
| `forward_to` | string | No | Call forwarding destination phone number |
| `forward_to_enabled` | boolean | No | Enable/disable call forwarding |
| `voicemail_greeting_url` | string | No | HTTPS URL to an MP3 recording for voicemail greeting |
| `participants` | array[string] | No | User IDs for group numbers |
| `phone_numbers` | array[string] | No | Phone numbers in E.164 format (e.g. `+16503334444`) for group numbers |

### Delete Phone Number

```
DELETE /phone_number/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Phone number ID |

**Permission:** You need the "Manage Group Phone Numbers" permission to delete a group number. You can only delete your own personal numbers.

### Rent Internal Phone Number

```
POST /phone_number/request/internal/
```

**Note:** Renting a phone number incurs a cost. You need the "Manage Group Phone Numbers" permission to rent group numbers.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `country` | string | Yes | Two-letter ISO country code (e.g. `US`) |
| `sharing` | string | Yes | `personal` (belongs to individual user) or `group` (group number) |
| `prefix` | string | No | Phone number prefix or area code, not including country code |
| `with_sms` | boolean | No | Force SMS capability. By default, SMS-capable numbers are rented if Close supports SMS for the country. Set to `false` to rent non-SMS numbers in SMS-supported countries |
| `with_mms` | boolean | No | Force MMS capability. By default, MMS-capable numbers are rented if Close supports MMS for the country. Set to `false` to rent non-MMS numbers |

**Response codes:**
- `201` — Number successfully rented, response contains the new number.
- `4xx` — Number not rented, response contains a `status` field.

**Error status values:**

| Status | Description |
|--------|-------------|
| `has-voice-only` | Country/prefix combination only has non-SMS-capable numbers. Retry with `with_sms: false` |
| `needs-more-info` | More information (e.g. proof of address) needed. Contact Close support |
| `billing-error` | Billing error (e.g. telephony budget reached, insufficient funds) |
| `error` | General error. Human-readable message in the `error` field |

---

## 12. Files

Close users wishing to attach files to outgoing emails or other objects via the Close API must first upload these files using the Files API. Files will be uploaded to a Close-provided Amazon S3 bucket.

### Upload Workflow

1. Make a POST request to `/files/upload/` with the `filename` and `content_type` of the file.
2. Use the response data to construct a `multipart/form-data` POST request to the S3 URL provided in `upload.url`. All fields in `upload.fields` must be included. This request must be made **within 60 seconds**.
3. Once uploaded successfully (201 HTTP status), the file is available for up to **24 hours**. Use the `download.url` value when referencing the file in other API endpoints.

**IMPORTANT:** Attempting to use a file before the S3 upload has been made successfully will result in a failed request to the Close API.

### Generate Signed S3 POST

```
POST /files/upload/
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `filename` | string | Yes | Name of the file being uploaded |
| `content_type` | string | Yes | MIME type of the file (e.g. `image/jpeg`) |

**Response schema:**

```json
{
    "upload": {
        "url": "string (S3 endpoint URL)",
        "fields": { "object (form fields for S3 request)" }
    },
    "download": {
        "url": "string (URL to reference this file in other API endpoints)"
    }
}
```

### Complete Code Example (Python)

```python
from closeio_api import Client
import requests

api = Client("YOUR_API_KEY")
files_upload_response = api.post("files/upload", {
    "filename": "image.jpg",
    "content_type": "image/jpeg"
})

# Use the data in the response to construct a multipart/form-data POST request
s3_upload_response = requests.post(
    files_upload_response["upload"]["url"],
    data=files_upload_response["upload"]["fields"],
    files={
      "file": ("image.jpg", open("path/to/image.jpg", "rb"), "image/jpeg")
    }
)
assert s3_upload_response.status_code == 201

# The file will be available for use in other API endpoints, for example below
# when creating an email activity.
email_create_response = api.post("activity/email", data={
    "attachments": [{
        "url": files_upload_response["download"]["url"],
        "filename": "image.jpg",
        "size": 1108447,
        "content_type": "image/jpeg"
    }],
    "contact_id": "cont_8NNOJnVwmHQEYuVOgJ4B4zU7g9RUxYH4JnPjza5Vr6t",
    "lead_id": "lead_KwD00BYbXCHiPWj68LxFkxaeWuULpZ7awzm6LqeFs0h",
    "user_id": "user_N6KhMpzHRCYQHdn4gRNIFNN5JExnsrprKA6ekxM63XA",
    "direction": "outgoing",
    ...
})
```

### Key Constraints

- S3 upload must be completed within **60 seconds** of the `/files/upload/` request.
- Files remain available for a maximum of **24 hours** after upload.
- The S3 upload must return HTTP status **201** to confirm success.
- File must be uploaded to S3 before referencing it in other API endpoints.

---

## 13. Comments

Comments may be left on a variety of object types in Close.

### Threading Model

The commenting feature is modeled as threads with comments, where:
- Each thread is associated with a specific object and has one or more comments.
- A comment may not exist without a thread.
- A thread may not exist without any comments.
- Threads are maintained automatically when creating or removing individual comments.

Comment bodies are formatted as rich text, and may include basic styling and user/group mentions. The `object_type` of the commented-on object is included in the thread, and should match up with the object types described in the event log docs.

### Fetch Multiple Comment Threads

```
GET /comment_thread/{?object_ids, ids, _limit, _skip}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `object_ids` | string | No | Comma-separated object IDs to filter threads |
| `ids` | string | No | Comma-separated thread IDs |
| `_limit` | integer | No | Pagination limit |
| `_skip` | integer | No | Pagination offset |

### Fetch Individual Comment Thread

```
GET /comment_thread/{thread_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `thread_id` | string | Yes | Comment thread ID |

### Fetch Multiple Comments

```
GET /comment/{?object_id, thread_id}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `object_id` | string | Conditional | Object ID to filter comments (exactly one of `object_id` or `thread_id` required) |
| `thread_id` | string | Conditional | Thread ID to filter comments (exactly one of `object_id` or `thread_id` required) |

**Note:** Comments may be fetched by `object_id` (the object that was commented on) or by `thread_id`. Exactly one of those filters must be provided.

### Create Comment

```
POST /comment/
```

Create a comment on an object. If a comment thread already exists on that object, a new comment is added to the existing thread. If no thread exists yet, one is created automatically.

### Fetch Individual Comment

```
GET /comment/{comment_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `comment_id` | string | Yes | Comment ID |

### Update Comment

```
PUT /comment/{comment_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `comment_id` | string | Yes | Comment ID |

**Note:** You can use this endpoint to edit a comment body. Users may only update their own comments.

### Remove Comment

```
DELETE /comment/{comment_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `comment_id` | string | Yes | Comment ID |

**Behavior:** Contrary to the HTTP verb, this does not necessarily delete a comment (but it will remove it). Comment bodies are removed, but the comment object still exists until all comments in a thread are removed (at which point the entire thread is deleted).

**Permissions:** Permissions around removing comments inherit from the user's permission to delete their own or other users' activities.

---

## 14. Unsubscribe Email Address

Unsubscribe email addresses from receiving messages from Close.

### List All Unsubscribed Emails

```
GET /unsubscribe/email/
```

Get a list of unsubscribed email addresses.

### Unsubscribe an Email Address

```
POST /unsubscribe/email/
```

This is useful for when you have an email address that has unsubscribed in another context (like a mailing list) and you want to unsubscribe them from messages from Close as well.

### Resubscribe an Email Address

```
DELETE /unsubscribe/email/{email_address}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `email_address` | string | Yes | The email address to resubscribe |

---

## 15. Rich Text Fields

In many places, the application allows users to compose using rich text. In particular, within note activities and notes on calls or meetings.

These rich text fields are exposed as strings, where the content is a restricted subset of XHTML.

### Format Requirements

All fields **must** begin and end with `<body></body>` tags.

### Supported HTML Elements

| Element | Description |
|---------|-------------|
| `<body>` | Required wrapper for all rich text content |
| `<h1>` | Heading level 1 |
| `<p>` | Paragraph |
| `<em>` | Emphasis (italic) |
| `<strong>` | Strong emphasis (bold) |
| `<b>` | Bold text |
| `<i>` | Italic text |
| `<u>` | Underlined text |
| `<s>` | Strikethrough text |
| `<span>` | Inline element with style attributes (e.g. color) |
| `<code>` | Code snippet |
| `<a>` | Hyperlink (with `href` attribute) |
| `<img>` | Image (with `src` and `alt` attributes) |
| `<hr>` | Horizontal rule |
| `<ul>` | Unordered list |
| `<li>` | List item |

### Mentions

Rich text fields support mentioning users or groups using a special `<span>` element:

```html
<span data-type="mention" data-id="group_xxxx" data-label="Engineers" class="mention">
  @Engineers
</span>
```

| Attribute | Description |
|-----------|-------------|
| `data-type` | Must be `"mention"` |
| `data-id` | ID of the user or group being mentioned (e.g. `group_xxxx`, `user_xxxx`) |
| `data-label` | Display label for the mention |
| `class` | Must be `"mention"` |

### Complete Example

```xml
<body>
  <h1>HTML Notes Example</h1>
  <p>
    This is an <em>example</em> note. It includes various elements like
    <strong>strong emphasis</strong>, images, and links.
  </p>
  <p>
    Here's a list of some inline elements you can use:
  </p>
  <ul>
    <li><b>Bold text</b></li>
    <li><i>Italic text</i></li>
    <li><u>Underlined text</u></li>
    <li><s>Strikethrough text</s></li>
    <li><span style="color: red;">Colored text</span></li>
    <li><code>example_function()</code></li>
  </ul>
  <p>
    And don't forget about links! Here's an example:
    <a href="http://www.example.com">Click me!</a>
  </p>
  <p>
    You can also include images:
    <img src="http://www.example.com/image.jpg" alt="Example Image" />
  </p>
  <hr />
  <p>
    Finally, many rich text fields support mentioning users or groups cc
    <span
      data-type="mention"
      data-id="group_xxxx"
      data-label="Engineers"
      class="mention"
    >
      @Engineers
    </span>
  </p>
</body>
```

---

## 16. Field Enrichment

Field Enrichment uses AI to intelligently populate fields on leads and contacts.

The Field Enrichment API waits for the enrichment process to complete before returning a response. Fields with complex guidance or requirements may time out / not complete. If this happens consistently, try to simplify the instructions or reduce the scope of the request.

### Supported Field Types

| Field Type | Examples |
|------------|----------|
| Text Fields | Company descriptions, job titles, notes |
| Choice Fields | Industry categories, lead sources, priorities |
| Number Fields | Employee counts, revenue estimates, scores |
| Date Fields | Founded dates, last contact dates |
| Multi-Choice Fields | Tags, categories, services offered |

**Tip:** For best results, configure guidance for each field within the field settings in the Close app.

### Update Strategy

By default, values are saved but only if the field does not already have a value. Saving values may be disabled by specifying `set_new_value: false`, or enrichment can be set to overwrite any existing values by specifying `overwrite_existing_value: true`.

### Enrich Field

```
POST /enrich_field/
```

This endpoint uses AI to enrich (populate or enhance) a specific field on a lead or contact. The enrichment process analyzes existing data and external sources to provide intelligent field values.

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `organization_id` | string | Yes | - | The organization ID |
| `object_type` | string | Yes | - | `"lead"` or `"contact"` |
| `object_id` | string | Yes | - | The ID of the lead or contact to enrich |
| `field_id` | string | Yes | - | The ID of the custom field to enrich |
| `set_new_value` | boolean | No | `true` | Whether to update the field with the enriched value |
| `overwrite_existing_value` | boolean | No | `false` | Whether to overwrite existing field values |

### Important Notes

- This endpoint waits for enrichment to complete, which may take several seconds.
- Complex field guidance may time out.
- Each enrichment request may consume credits or incur costs.
- Heavy usage may trigger rate limiting.

---

## Endpoint Summary

| # | Feature | Endpoints |
|---|---------|-----------|
| 1 | Email Templates | `GET /email_template/`, `POST /email_template/`, `GET /email_template/{id}/`, `PUT /email_template/{id}/`, `DELETE /email_template/{id}/`, `GET /email_template/{id}/render/` |
| 2 | SMS Templates | `GET /sms_template/`, `POST /sms_template/`, `GET /sms_template/{id}/`, `PUT /sms_template/{id}/`, `DELETE /sms_template/{id}/` |
| 3 | Connected Accounts | `GET /connected_account/`, `GET /connected_account/{id}/` |
| 4 | Send As | `GET /send_as/`, `POST /send_as/`, `DELETE /send_as/`, `GET /send_as/{id}/`, `DELETE /send_as/{id}/`, `POST /send_as/bulk/` |
| 5 | Sequences | `GET /sequence/`, `POST /sequence/`, `GET /sequence/{id}/`, `PUT /sequence/{id}/`, `DELETE /sequence/{id}/`, `GET /sequence_subscription/`, `POST /sequence_subscription/`, `GET /sequence_subscription/{id}/`, `PUT /sequence_subscription/{id}/` |
| 6 | Dialer | `GET /dialer/`, `GET /dialer/{id}/` |
| 7 | Smart Views | `GET /saved_search/`, `POST /saved_search/`, `GET /saved_search/{id}/`, `PUT /saved_search/{id}/`, `DELETE /saved_search/{id}/` |
| 8 | Bulk Actions | `GET /bulk_action/email/`, `POST /bulk_action/email/`, `GET /bulk_action/email/{id}/`, `GET /bulk_action/sequence_subscription/`, `POST /bulk_action/sequence_subscription/`, `GET /bulk_action/sequence_subscription/{id}/`, `GET /bulk_action/delete/`, `POST /bulk_action/delete/`, `GET /bulk_action/delete/{id}/`, `GET /bulk_action/edit/`, `POST /bulk_action/edit/`, `GET /bulk_action/edit/{id}/` |
| 9 | Integration Links | `GET /integration_link/`, `POST /integration_link/`, `GET /integration_link/{id}/`, `PUT /integration_link/{id}/`, `DELETE /integration_link/{id}/` |
| 10 | Exports | `POST /export/lead/`, `POST /export/opportunity/`, `GET /export/{id}/`, `GET /export/` |
| 11 | Phone Numbers | `GET /phone_number/`, `GET /phone_number/{id}/`, `PUT /phone_number/{id}/`, `DELETE /phone_number/{id}/`, `POST /phone_number/request/internal/` |
| 12 | Files | `POST /files/upload/` |
| 13 | Comments | `GET /comment_thread/`, `GET /comment_thread/{thread_id}/`, `GET /comment/`, `POST /comment/`, `GET /comment/{comment_id}/`, `PUT /comment/{comment_id}/`, `DELETE /comment/{comment_id}/` |
| 14 | Unsubscribe Email | `GET /unsubscribe/email/`, `POST /unsubscribe/email/`, `DELETE /unsubscribe/email/{email_address}/` |
| 15 | Rich Text Fields | N/A (format reference, not an endpoint) |
| 16 | Field Enrichment | `POST /enrich_field/` |

**Total unique endpoints: 57**
