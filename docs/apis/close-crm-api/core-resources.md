# Close CRM API — Core Resources Documentation

> **Source:** https://developer.close.com
> **Date scraped:** 2026-03-30
> **Base URL:** `https://api.close.com/api/v1`

---

## Table of Contents

1. [Authentication](#authentication)
2. [Rate Limits](#rate-limits)
3. [Pagination](#pagination)
4. [HTTP Response Codes](#http-response-codes)
5. [Leads](#leads)
6. [Contacts](#contacts)
7. [Opportunities](#opportunities)
8. [Tasks](#tasks)
9. [Outcomes](#outcomes)
10. [Memberships](#memberships)
11. [Users](#users)
12. [Organizations](#organizations)
13. [Roles](#roles)
14. [Lead Statuses](#lead-statuses)
15. [Opportunity Statuses](#opportunity-statuses)
16. [Pipelines](#pipelines)
17. [Groups](#groups)
18. [Advanced Filtering](#advanced-filtering)
19. [Reporting](#reporting)
20. [Meeting Search](#meeting-search)

---

## Authentication

API keys use HTTP Basic authentication. The API key acts as the username and the password is always empty.

```bash
curl https://api.close.com/api/v1/me/ -u yourapikey:
```

Note the `:` at the end of the API key. This is required because the key is sent as the username with a blank password.

```
GET /api/v1/me/ HTTP/1.1
Authorization: Basic eW91cmFwaWtleTo=
Host: api.close.com
```

The base64-encoded string `yourapikey:` becomes `eW91cmFwaWtleTo=`.

API keys are per-organization and can be generated and deleted in the Settings page.

For public applications, use OAuth instead (see `/topics/authentication-oauth2/`).

---

## Rate Limits

Rate limits protect Close infrastructure from excessive request rates.

**If you receive a `429` (Too Many Requests) response**, sleep/pause for the number of seconds specified by the `rate_reset` value before making additional requests.

- Rate limits are enforced **per endpoint group** (URL path + HTTP method).
- Rate limits are enforced at a **per Organization level** across all API keys.
- A lower rate limit is also enforced **per API key**.
- The per-Organization limit is currently **3x higher** than individual API key rate limits.
  - Example: if per-key limit is 20 RPS, org limit is 60 RPS.

**RateLimit header** (included in most API responses):

```
RateLimit: limit=100, remaining=50, reset=5
```

| Field | Description |
|-------|-------------|
| `limit` | Request limit enforced for this endpoint (some endpoints allow bursting) |
| `remaining` | Requests left in the enforcement window |
| `reset` | Seconds remaining before enforcement window ends (decimal) |

Each `429` response includes the `RateLimit` header and a `retry-after` header (RFC 7231). Use the `rate_reset` value for more accurate wait times.

Some endpoints may have stricter, unpredictable rate limits that trigger 429 even within the enforcement window.

---

## Pagination

Close API uses two pagination methods.

### Offset-Based Pagination

Most list endpoints use `_limit` and `_skip` parameters.

```
Page 1: /api/v1/lead/?_skip=0&_limit=100
Page 2: /api/v1/lead/?_skip=100&_limit=100
Page 3: /api/v1/lead/?_skip=200&_limit=100
```

**Response fields:**
- `data` — list of objects
- `has_more` — boolean indicating if more pages exist

There is a maximum `_skip` limit that varies per resource. Exceeding it returns a `400`.

**Deep Pagination:** For iterating through large lists, use `date_created` as a range filter and make multiple requests with incrementing/decrementing dates. Alternatively, use the Export API.

### Cursor-Based Pagination

Used by:
- **Advanced Filtering API** — `cursor` and `_limit` in request body
- **Events API** — `_cursor` and `_limit` query parameters

Pass the cursor token from the previous response to fetch the next page.

---

## HTTP Response Codes

| Code | Description |
|------|-------------|
| `200` | Request was successful |
| `400` | Issue with the request |
| `401` | Request needs to be authenticated |
| `402` | Request could not be completed because a limit of the current plan was reached |
| `403` | Operation was not allowed |
| `404` | URL was not found |
| `405` | HTTP method was not supported |
| `415` | Request used an unsupported format |

---

## Leads

Leads are the most important object in Close. They represent a company or organization and can contain contacts, tasks, opportunities, and activities. These other objects must be children of a Lead. A Lead in Close is like both a "lead" and "account" in other CRM terminology.

When a lead is returned, its basic info as well as related tasks, opportunities, and custom fields are included. **Activities are excluded** and must be fetched separately via the activities endpoint.

**Custom Fields:** Returned as `custom.FIELD_ID`. Using the `custom` field dict is deprecated. When using `_fields`, specify `custom` to show all custom fields, or provide a comma-separated list of `custom.FIELD_ID` identifiers.

**Smart Fields:** Not included by default.
- Fetch a specific Smart Field: `?_fields=smart_field_name,other_lead_field_names`
- Fetch all fields including Smart Fields: `?_fields=_all`

Smart Fields are calculated fields (e.g., number of emails on a lead). Use specific field names rather than `_all` for performance.

**Filtering:** Use the [Advanced Filtering API](#advanced-filtering) to find leads matching specific conditions.

### GET /api/v1/lead/

List leads.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | No | Maximum number of results to return |
| `_skip` | integer | No | Number of results to skip (pagination) |
| `_fields` | string | No | Comma-separated field names. Use `custom` for all custom fields, `_all` for all fields including Smart Fields |

### POST /api/v1/lead/

Create a new lead. Contacts, addresses, and custom fields can all be nested in the lead. Activities, tasks, and opportunities must be posted separately.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `status` | string | No | Status label. Do not use with `status_id`. If neither provided, organization default is used |
| `status_id` | string | No | Status ID (recommended over `status` so users can rename statuses in UI) |
| `custom.FIELD_ID` | mixed | No | Custom field value where FIELD_ID is the custom field identifier |
| `contacts` | array | No | Nested contact objects |
| `addresses` | array | No | Nested address objects |

**Notes:**
- Post either `status` or `status_id`, not both.
- If neither exists, the organization's default (first) status is used.
- For multi-value custom fields (`accepts_multiple_values: true`), the entire value is replaced, not appended. E.g., given value `["A", "B"]`, adding `"C"` means setting to `["A", "B", "C"]`.
- Using `custom` field dict or `custom.FIELD_NAME` syntax is deprecated.

```json
{
    "custom.cf_v6S011I6MqcbVvB2FA5Nk8dr5MkL8sWuCiG8cUleO9c": "value",
    "custom.cf_8wtBWsdRU2Fur7GDnEeXQ7ra2Vu7R4hG1SNYdiEhh0F": "other value"
}
```

### GET /api/v1/lead/{id}/

Retrieve a single lead.

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Lead identifier |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_fields` | string | No | Comma-separated field names to include |

### PUT /api/v1/lead/{id}/

Update an existing lead. Supports non-destructive patches.

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Lead identifier |

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `status` | string | No | Updated status label |
| `status_id` | string | No | Updated status ID |
| `custom.FIELD_ID` | mixed | No | Custom field value |
| `custom.FIELD_ID` | null | No | Unset a field |
| `custom.FIELD_ID.add` | mixed | No | Add single value to multi-value field |
| `custom.FIELD_ID.remove` | mixed | No | Remove single value from multi-value field |

**Unset a custom field:**
```json
{ "custom.cf_v6S011I6MqcbVvB2FA5Nk8dr5MkL8sWuCiG8cUleO9c": null }
```

**Add to multi-value field:**
```json
{ "custom.cf_v6S011I6MqcbVvB2FA5Nk8dr5MkL8sWuCiG8cUleO9c.add": "Wednesday" }
```

### DELETE /api/v1/lead/{id}/

Delete a lead.

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Lead identifier |

### POST /api/v1/lead/merge/

Merge two leads.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `source` | string | Yes | Lead ID to merge from |
| `destination` | string | Yes | Lead ID to merge into |

For definitions of "source" and "destination", see the Merge Leads feature in the Close UI.

---

## Contacts

Contacts represent individual people within a company/organization. Each contact belongs to exactly one Lead and can contain multiple phone numbers, email addresses, URLs, and be associated with Contact Custom Fields.

Use the [Advanced Filtering API](#advanced-filtering) to find contacts matching specific conditions.

### GET /api/v1/contact/

List contacts.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | No | Maximum number of results to return |
| `_skip` | integer | No | Number of results to skip for pagination |

### POST /api/v1/contact/

Create a new contact.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `lead_id` | string | No | Lead ID. If not provided, a new lead is created named after the contact |
| `name` | string | No | Contact name |
| `title` | string | No | Contact title/position |
| `phones` | array | No | Array of phone objects `[{"phone": "+1...", "type": "office"}]` |
| `emails` | array | No | Array of email objects `[{"email": "...", "type": "office"}]` |
| `urls` | array | No | Array of URL objects `[{"url": "...", "type": "url"}]` |
| `custom.FIELD_ID` | mixed | No | Custom field value |

### GET /api/v1/contact/{id}/

Fetch a single contact.

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Contact ID |

### PUT /api/v1/contact/{id}/

Update an existing contact.

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Contact ID |

Supports the same custom field update syntax as leads:

```json
{ "custom.cf_v6S011I6MqcbVvB2FA5Nk8dr5MkL8sWuCiG8cUleO9c.add": "Wednesday" }
```

### DELETE /api/v1/contact/{id}/

Delete a contact.

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Contact ID |

---

## Opportunities

Opportunities represent a potential deal with a given company/lead. They have a customizable status (with `status_type` of `active`, `won`, or `lost`), and optionally a monetary amount. They can be associated with Opportunity Custom Fields or Shared Fields.

### GET /api/v1/opportunity/

List or filter opportunities.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `lead_id` | string | No | Filter by lead ID |
| `user_id` | string | No | Filter by user ID (supports `__in` for multiple) |
| `status_id` | string | No | Filter by status ID (supports `__in` for multiple) |
| `status_label` | string | No | Filter by status label (supports `__in` for multiple) |
| `status_type` | string | No | Filter by type: `active`, `won`, `lost` (supports `__in`) |
| `date_created__lt` | date | No | Date created less than |
| `date_created__gt` | date | No | Date created greater than |
| `date_created__lte` | date | No | Date created less than or equal |
| `date_created__gte` | date | No | Date created greater than or equal |
| `date_updated__lt` | date | No | Date updated less than |
| `date_updated__gt` | date | No | Date updated greater than |
| `date_updated__lte` | date | No | Date updated less than or equal |
| `date_updated__gte` | date | No | Date updated greater than or equal |
| `date_won__lt` | date | No | Date won less than |
| `date_won__gt` | date | No | Date won greater than |
| `date_won__lte` | date | No | Date won less than or equal |
| `date_won__gte` | date | No | Date won greater than or equal |
| `value_period` | string | No | Filter: `one_time`, `monthly`, `annual` (supports `__in`) |
| `query` | string | No | Search query filter (opportunity properties only). E.g., `note:important` or `status_change(old_status:active new_status:won date:yesterday)` |
| `_order_by` | string | No | Order by: `date_won`, `date_updated`, `date_created`, `confidence`, `user_name`, `value`, `annualized_value`, `annualized_expected_value` (prepend `-` for descending) |
| `_group_by` | string | No | Group by: `user_id`, `date_won__week`, `date_won__month`, `date_won__quarter`, `date_won__year` (prepend `-` to reverse group order) |
| `_fields` | string | No | Specify which fields to return |
| `lead_saved_search_id` | string | No | Lead Smart View filter ID |
| `_limit` | integer | No | Limit results |
| `_skip` | integer | No | Skip results |

**Aggregate Response Fields** (included regardless of pagination):

| Field | Type | Description |
|-------|------|-------------|
| `total_results` | integer | Total number of matching objects |
| `count_by_value_period` | object | Count by value period, e.g. `{'one_time': 2, 'annual': 1, 'monthly': 1}` |
| `total_value_one_time` | number | Sum of one-time opportunity values |
| `total_value_monthly` | number | Sum of monthly opportunity values |
| `total_value_annual` | number | Sum of annual opportunity values |
| `total_value_annualized` | number | Sum of all values (monthly x 12) |
| `expected_value_one_time` | number | One-time values x confidence |
| `expected_value_monthly` | number | Monthly values x confidence |
| `expected_value_annual` | number | Annual values x confidence |
| `expected_value_annualized` | number | All values x confidence (monthly x 12) |

**Grouping:**

When using `_group_by`, the `data` array contains groups instead of objects:

| Group Field | Description |
|-------------|-------------|
| `key` | Unique group key |
| `objects` | Array of objects in group |
| `total_results` | Count for the group |
| All aggregate values | Per-group aggregates |
| `year` | When grouping by year/month/quarter/week |
| `month` | When grouping by month (1-12) |
| `quarter` | When grouping by quarter (1-4) |
| `weekyear`, `week` | When grouping by week (ISO standard) |
| `user_id`, `user_name` | When grouping by user |

**Notes:**
- Pagination applies to objects, not groups. The last/first group may be cut off.
- Use `key` to combine groups across pages.
- `_order_by` sorts items within each group.
- When grouping by `user_id`, results are ordered by user's full name.
- `lead_query` parameter is deprecated; use `lead_saved_search_id` instead.

### POST /api/v1/opportunity/

Create an opportunity.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `status_id` | string | No | Status ID. If omitted, organization default (first) status used. Fetch available statuses from Opportunity Status API |
| `lead_id` | string | No | Lead ID. If omitted, new lead created (will appear as "Untitled") |
| `custom.FIELD_ID` | mixed | No | Custom field value |

```json
{
    "custom.cf_v6S011I6MqcbVvB2FA5Nk8dr5MkL8sWuCiG8cUleO9c": "value",
    "custom.cf_8wtBWsdRU2Fur7GDnEeXQ7ra2Vu7R4hG1SNYdiEhh0F": "other value"
}
```

**Notes:**
- For multi-value custom fields (`accepts_multiple_values: true`), the entire value is replaced.
- Using `custom` dict or `custom.FIELD_NAME` is deprecated.

### GET /api/v1/opportunity/{id}/

Retrieve an opportunity.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

### PUT /api/v1/opportunity/{id}/

Update an opportunity.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `status_id` | string | No | Setting to `won` status auto-sets `date_won` if not already set. Reverting from `won` does NOT auto-change `date_won` |
| `date_won` | date | No | Auto-set to today when `status_id` set to `won` (respects `x-tz-offset` header) |
| `custom.FIELD_ID` | mixed | No | Custom field update |
| `custom.FIELD_ID` | null | No | Unset a field |
| `custom.FIELD_ID.add` | mixed | No | Add value to multi-value field |
| `custom.FIELD_ID.remove` | mixed | No | Remove value from multi-value field |

### DELETE /api/v1/opportunity/{id}/

Delete an opportunity.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

---

## Tasks

Tasks are action items with a given date assigned to a sales rep. Incomplete tasks (`is_complete` is false) show in the rep's inbox; complete tasks (`is_complete` is true) are in the archive. Archived tasks of certain types are automatically deleted after a time.

The `date` field represents when the task is actionable. It can be date-only (e.g. `2015-01-05`) or datetime (e.g. `2015-01-10T05:00:00+00:00`). When ordering, date-only tasks are ordered before datetime tasks at the same date, taking timezone (`x-tz-offset`) into account.

**Task Types:**

| Type | object_type | Description |
|------|-------------|-------------|
| `lead` | null | To-do item for a lead. `object_type` and `object_id` are null (lead is in `lead_id`) |
| `incoming_email` | emailthread | One or multiple incoming emails on a thread. `emails` array has email activity IDs. `subject` has the thread subject. Multiple unread emails in one thread are consolidated |
| `email_followup` | emailthread | Follow-up reminder on sent email with no response. `email_id` references the original email. `subject` and `body_preview` contain data about the email |
| `missed_call` | call | Missed call. `phone` has remote party number, `local_phone` has the number that was called |
| `answered_detached_call` | call | Call from unassociated number. `phone` has remote party number |
| `voicemail` | call | Voicemail. Same as `missed_call` plus `voicemail_duration` and `voicemail_url` |
| `opportunity_due` | opportunity | Opportunity scheduled to close on this date |
| `incoming_sms` | sms | Incoming SMS/MMS. `remote_phone` has sender number, `local_phone` has the number texted. MMS has `attachments` field |
| `outgoing_call` | call | Outgoing call task |

**Note:** When not filtering by `_type`, only `lead` type tasks are returned. Use `_type=all` for all types, or `_type__in=missed_call,voicemail` for specific types.

### GET /api/v1/task/

List or filter tasks.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | No | Task ID |
| `id__in` | string | No | Comma-separated task IDs |
| `_type` | string | No | Task type filter. Default returns only `lead` type. Use `all` for all types, or `_type__in=type1,type2` |
| `lead_id` | string | No | Filter by lead ID |
| `is_complete` | boolean | No | Filter by completion status |
| `date__lt` | datetime | No | Date less than |
| `date__gt` | datetime | No | Date greater than |
| `date__lte` | datetime | No | Date less than or equal |
| `date__gte` | datetime | No | Date greater than or equal |
| `date_created__lt` | datetime | No | Creation date less than |
| `date_created__gt` | datetime | No | Creation date greater than |
| `date_created__lte` | datetime | No | Creation date less than or equal |
| `date_created__gte` | datetime | No | Creation date greater than or equal |
| `assigned_to` | string | No | Filter by assigned user |
| `view` | string | No | View type: `inbox`, `future`, `archive` |
| `_order_by` | string | No | Order by `date` or `date_created` (prepend `-` for descending) |
| `_limit` | integer | No | Limit results |
| `_skip` | integer | No | Skip results |

**View parameter values:**
- `inbox` — Incomplete tasks up to end of user's day (timezone-aware)
- `future` — Incomplete tasks from tomorrow onward (timezone-aware)
- `archive` — Complete tasks only

**Note:** `view` of `inbox` or `future` overrides any `date__lt` or `date__gte` parameters.

### POST /api/v1/task/

Create a task.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `_type` | string | Yes | Task type: `lead` or `outgoing_call` (only these two can be created) |
| `lead_id` | string | Yes | Lead to associate the task with |
| `assigned_to` | string | No | User ID to assign the task to |
| `date` | string | No | Date or datetime for the task |
| `text` | string | No | Task text (for `lead` type) |
| `is_complete` | boolean | No | Completion status |

### PUT /api/v1/task/

Bulk-update tasks. Any GET endpoint filters may be used (e.g. `id__in=A,B,C`).

**Updatable Fields (bulk):** Only `assigned_to`, `date`, and `is_complete`.

### GET /api/v1/task/{id}/

Fetch a task's details.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

### PUT /api/v1/task/{id}/

Update a task.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

**Updatable Fields:**

| Field | Task Types | Description |
|-------|-----------|-------------|
| `assigned_to` | All | Reassign the task |
| `date` | All | Date or datetime |
| `is_complete` | All | Mark complete/incomplete |
| `text` | `lead` only | Update task text |

### DELETE /api/v1/task/{id}/

Delete a task.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

---

## Outcomes

Outcomes represent standardized results applicable to activities such as calls and meetings. They help sales teams track and categorize interaction results.

Each outcome includes a name, optional description, and specifies which activity types it applies to. Outcomes can be `custom` (user-defined) or `vm-dropped` (automatically applied during voicemail drops).

### GET /api/v1/outcome/

List or filter outcomes.

### POST /api/v1/outcome/

Create a new outcome.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Displayed wherever outcomes can be selected |
| `applies_to` | array | Yes | Valid values: `calls`, `meetings` |
| `description` | string | No | Explains outcome meaning and usage |
| `type` | string | No | `custom` (default) or `vm-dropped` for voicemail drops |

**Note:** The `applies_to` field will be deprecated in a future update and derived from `type` instead. `custom` outcomes will apply to `["calls", "meetings"]`; `vm-dropped` outcomes will apply to `["calls"]`.

### GET /api/v1/outcome/{id}/

Fetch a single outcome.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

### PUT /api/v1/outcome/{id}/

Update an outcome.

**Request Body (all optional):**

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Update the outcome name |
| `description` | string | Update the description |
| `applies_to` | array | Change applicable activity types (will be ignored in future) |
| `type` | string | Change to `custom` or `vm-dropped` |

### DELETE /api/v1/outcome/{id}/

Delete an outcome.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

**Note:** Associated calls and meetings retain their outcome references, but the outcome cannot be set on new activities.

**Usage:** To apply an outcome to a call or meeting, send a PUT request to the respective activity endpoint with `outcome_id: "outcome_xyz"`.

---

## Memberships

Memberships connect a User with one or more Organizations. A Membership is created when a User is added to an organization, and becomes "inactive" when a User leaves or is removed.

### PUT /api/v1/membership/{id}/

Update a membership.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

**Updatable Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `role_id` | string | One of `'admin'`, `'superuser'`, `'user'`, `'restricteduser'`, or a custom Role ID |
| `auto_record_calls` | string | Call recording setting: `'unset'` (initial), `'disabled'`, or `'enabled'` |

### POST /api/v1/membership/

Create or activate a membership for a given email. Ensures an active membership will be provisioned.

- If the user already exists, they are added to the requestor's organization.
- If the user doesn't exist, a new user is provisioned.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes | Email address for the membership |
| `role_id` | string | No | One of `'admin'`, `'superuser'`, `'user'`, `'restricteduser'`, or custom Role ID |

**Authentication:** OAuth only.
**Permissions Required:** "Manage Organization".

### PUT /api/v1/membership/

Bulk-update memberships. Pass comma-separated IDs into `id__in` in query parameters.

**Updatable Fields:** Same as individual update (`role_id`, `auto_record_calls`).

### GET /api/v1/membership/{id}/pinned_views

Get the ordered list of pinned views for the given membership.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

### PUT /api/v1/membership/{id}/pinned_views

Set pinned views for the membership. Provide an ordered list that overwrites the entire current list.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

**Request Body:** Ordered array of view identifiers.

---

## Users

Users represent Close user accounts — typically co-workers or sales representatives.

### GET /api/v1/me/

Fetch information about yourself. This is a special instance of `/user/{your_user_id}/`. Useful for determining the `id` of the Organization you belong to.

### GET /api/v1/user/{id}/

Fetch a single user.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

### GET /api/v1/user/

List all users who are members of the same organizations as you.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | No | Maximum results |
| `_skip` | integer | No | Skip results |

### GET /api/v1/user/availability/

Fetch availability statuses of all users within an organization.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `organization_id` | string | No | Filter by organization ID |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `active_calls` | array | Call metadata for calls the user is currently participating in |

---

## Organizations

Organizations are "environments" in Close where teams collaborate. Most users belong to a single Organization. Leads/Contacts/Activities cannot be shared across organizations.

### GET /api/v1/organization/{id}/

Get organization details including current members (users), lead and opportunity statuses, etc.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_expand` | string | No | Expand nested fields. E.g., `memberships__user,inactive_memberships__user` |

**Response Notes:**
- By default, `memberships` and `inactive_memberships` are populated with user data prefixed with `user_`.
- Use `_expand` to get a nested `user` field instead.

### PUT /api/v1/organization/{id}/

Update organization settings.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | No | Organization name |
| `currency` | string | No | Currency code |
| `lead_statuses` | array | No | Reordered lead status list |

---

## Roles

Roles define what users in your organization can or cannot do. Each user has a single role set via the Memberships API. Every role has a set of permissions. Some roles (like "Admin") are system-maintained and cannot be edited.

**Note:** Lead visibility fields should be empty for roles with `view_all_leads` permission, and must be set otherwise.

### GET /api/v1/role/{id}/

Fetch a single role.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

### GET /api/v1/role/

List all roles defined for your organization.

### POST /api/v1/role/

Create a new custom role.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Role name |
| `permissions` | array | Yes | List of permission strings |
| `visibility_user_lcf_ids` | array | No | Lead Custom Field IDs defining visible leads. Empty if role has `view_all_leads` |
| `visibility_user_lcf_behavior` | string | No | Controls unassigned lead visibility. Empty if role has `view_all_leads`. Values: `require_assignment` (leads without assigned users not visible), `allow_unassigned` (leads without assigned users are visible) |

### PUT /api/v1/role/{role_id}/

Update an existing role.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `role_id` | string | Yes |

### DELETE /api/v1/role/{role_id}/

Delete a role.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `role_id` | string | Yes |

**Warning:** Make sure to move all users off this role first by updating their `role_id` attribute.

---

## Lead Statuses

Lead statuses are a customizable list of stages a Lead can be in.

### GET /api/v1/status/lead/

List all lead statuses for your organization.

### POST /api/v1/status/lead/

Create a new lead status.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `label` | string | Yes | Status name |

### PUT /api/v1/status/lead/{status_id}/

Rename a lead status.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `status_id` | string | Yes |

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `label` | string | Yes | New status name |

**Note:** To update the status of a particular lead, use `PUT /lead/{lead_id}/` instead.

### DELETE /api/v1/status/lead/{status_id}/

Delete a lead status.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `status_id` | string | Yes |

**Warning:** Make sure no leads are assigned this status first.

---

## Opportunity Statuses

Opportunity statuses are a customizable list of stages an Opportunity can be in. Each status always has a `status_type` of `active`, `won`, or `lost`.

### GET /api/v1/status/opportunity/

List all opportunity statuses for your organization.

**Response schema:** List of objects with `id`, `label`, `status_type`, `pipeline_id`.

### POST /api/v1/status/opportunity/

Create an opportunity status.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `label` | string | Yes | Status name |
| `status_type` | string | Yes | One of: `active`, `won`, `lost` |
| `pipeline_id` | string | No | Pipeline ID. If provided, status applies to specific pipeline |

### PUT /api/v1/status/opportunity/{status_id}/

Rename an opportunity status.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `status_id` | string | Yes |

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `label` | string | Yes | New status name |

### DELETE /api/v1/status/opportunity/{status_id}/

Delete an opportunity status.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `status_id` | string | Yes |

**Warning:** Make sure no opportunities are assigned this status first.

---

## Pipelines

Pipelines are named and ordered groups of Opportunity Statuses. They allow grouping statuses into separate categories for different teams and workflows (e.g., a "Sales" Pipeline and a "Professional Services" Pipeline).

### GET /api/v1/pipeline/

List all pipelines for your organization.

### POST /api/v1/pipeline/

Create a new pipeline.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Pipeline name |
| `statuses` | array | No | Initial statuses for the pipeline |

### PUT /api/v1/pipeline/{pipeline_id}/

Update a pipeline. Supports:
- Renaming
- Reordering opportunity statuses
- Moving a status from another pipeline by including `{"id": "id_of_the_status_from_another_pipeline"}` in the `statuses` list

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `pipeline_id` | string | Yes |

### DELETE /api/v1/pipeline/{pipeline_id}/

Delete a pipeline.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `pipeline_id` | string | Yes |

**Constraint:** Only allowed if the pipeline contains no Opportunity Statuses. Delete all statuses or move them to another pipeline first.

---

## Groups

Groups are named collections of Users. They allow referring to multiple Users as a unit in filtering and reporting. A group typically represents a team. Users can belong to multiple groups.

**Note:** Endpoints require `?_fields=name,members` to return corresponding field data. Specify only needed fields to reduce data.

**Filtering with groups:** Endpoints that support filtering for both groups and users use the `?user_id__in=user_abc,user_xyz` parameter. Include group IDs to filter by group membership. Mix individual users and groups: `?user_id__in=user_abc,group_xyz`.

### GET /api/v1/group/

List all groups in the organization.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_fields` | string | No | Comma-separated fields (e.g., `name,members`) |

**Note:** List endpoint does not support retrieving members for all groups. Use individual group endpoint instead.

### POST /api/v1/group/

Create a new group (created with no users; use member endpoint to add).

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_fields` | string | No | Fields to return |

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Group name |

### GET /api/v1/group/{group_id}/

Fetch an individual group.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `group_id` | string | Yes |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_fields` | string | No | Fields to return |

### PUT /api/v1/group/{group_id}/

Update (rename) a group. Error returned if name is not unique.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `group_id` | string | Yes |

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | New name |

### DELETE /api/v1/group/{group_id}/

Delete a group. Only allowed if the group is not referenced by saved reports or smart views.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `group_id` | string | Yes |

### POST /api/v1/group/{group_id}/member/

Add a user to a group. If already a member, nothing changes.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `group_id` | string | Yes |

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `user_id` | string | Yes | User ID to add |

### DELETE /api/v1/group/{group_id}/member/{user_id}/

Remove a user from a group. If not a member, nothing changes.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `group_id` | string | Yes |
| `user_id` | string | Yes |

---

## Advanced Filtering

The Advanced Filtering API enables searching for Leads or Contacts using arbitrary filter criteria.

### POST /api/v1/data/search/

**Top-Level Request Body Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | object | Yes | The filter query structure |
| `_fields` | object | No | Fields to return for matched objects |
| `_limit` | integer | No | Results per page |
| `cursor` | string | No | Pagination cursor from previous response |
| `results_limit` | integer | No | Maximum total results |
| `include_counts` | boolean | No | Include count information |
| `sort` | array | No | Sort configuration |

### Query Types

#### ID Query
Match a single object by ID:
```json
{
  "type": "id",
  "value": "cont_abcdef"
}
```

#### Object Type Query
Specify object type to return (`contact` or `lead`):
```json
{
  "type": "object_type",
  "object_type": "contact"
}
```

#### Text Query
Filter across text-like fields:
```json
{
  "type": "text",
  "value": "Bruce",
  "mode": "full_words"
}
```

**Modes:**
- `full_words` — searches all specified words anywhere in the text, disregards position
- `phrase` — searches words in specified order next to each other

#### Field Value Condition Query
Match based on specific field values:
```json
{
  "type": "field_condition",
  "field": {
    "type": "regular_field",
    "object_type": "contact",
    "field_name": "title"
  },
  "condition": {
    "type": "text",
    "mode": "full_words",
    "value": "CEO"
  }
}
```

**Field types:**

Regular field:
```json
{
  "type": "regular_field",
  "object_type": "contact",
  "field_name": "name"
}
```

Custom field:
```json
{
  "type": "custom_field",
  "custom_field_id": "cf_abcdef"
}
```

#### Has Related Query
Filter based on related object data (e.g., Contact based on Lead data):
```json
{
  "type": "has_related",
  "this_object_type": "contact",
  "related_object_type": "lead",
  "related_query": {
    "type": "field_condition",
    "field": {
      "type": "custom_field",
      "custom_field_id": "cf_B57sofuEB7OBneH86SJctTr7hfiAiQcgkGRbAQfha0Z"
    },
    "condition": {
      "type": "term",
      "values": ["Software as a service"]
    },
    "negate": false
  }
}
```

#### AND/OR Queries
Combine multiple conditions:
```json
{
  "type": "and",
  "queries": [query1, query2, query3]
}
```
```json
{
  "type": "or",
  "queries": [query1, query2, query3]
}
```

#### Query Negation
All queries support negation. Specify `"negate": true` to invert matching.

### Field Conditions

#### Boolean
```json
{ "type": "boolean", "value": true }
```

#### Current User
Reference the authenticated user (for fields like `created_by`):
```json
{ "type": "current_user" }
```

#### Exists
Match if field is set (not null/missing):
```json
{ "type": "exists" }
```

#### Text
```json
{
  "type": "text",
  "value": "Bruce",
  "mode": "full_words"
}
```

#### Term
Match enumeration or choice values:
```json
{
  "type": "term",
  "values": ["draft", "sent"]
}
```

#### Reference
Match object IDs in reference fields:
```json
{
  "type": "reference",
  "reference_type": "user",
  "object_ids": ["user_abc", "user_def"]
}
```

#### Number Range
```json
{
  "type": "number_range",
  "gt": 1
}
```

### Output Control

**Return specific fields:**
```json
{
  "query": {},
  "_fields": {
    "contact": ["id", "name", "title"]
  }
}
```

**Limit results:**
```json
{
  "query": {},
  "results_limit": 100
}
```

**Include counts:**
```json
{
  "query": {},
  "include_counts": true,
  "results_limit": 0
}
```

Response with counts:
```json
{
  "data": [],
  "count": {
    "limited": 0,
    "total": 3
  }
}
```

### Sorting

```json
{
  "query": {},
  "sort": [
    {
      "direction": "asc",
      "field": {
        "object_type": "contact",
        "type": "regular_field",
        "field_name": "title"
      }
    }
  ]
}
```

**Directions:** `asc` or `desc`

**Constraint:** Only numbers, dates, and text fields belonging directly to an object can be sorted. References/ID fields or fields from other objects cannot.

### Pagination

```json
{
  "query": {},
  "_limit": 10,
  "cursor": "<cursor_from_previous_response>"
}
```

**Notes:**
- Cursors expire after **30 seconds**
- Hard limit of **10,000 objects** per pagination sequence
- Use stable sort fields like `date_created` to avoid missing results
- When cursor is `null`, you've reached the last page

### Example: Find CEOs of SaaS companies with at least one email

```json
{
  "query": {
    "type": "and",
    "queries": [
      {
        "type": "object_type",
        "object_type": "contact"
      },
      {
        "type": "field_condition",
        "field": {
          "type": "regular_field",
          "object_type": "contact",
          "field_name": "emails_count"
        },
        "condition": {
          "type": "number_range",
          "gt": 1
        }
      },
      {
        "type": "field_condition",
        "field": {
          "type": "regular_field",
          "object_type": "contact",
          "field_name": "title"
        },
        "condition": {
          "type": "text",
          "mode": "full_words",
          "value": "CEO"
        }
      },
      {
        "type": "has_related",
        "this_object_type": "contact",
        "related_object_type": "lead",
        "related_query": {
          "type": "field_condition",
          "field": {
            "type": "custom_field",
            "custom_field_id": "cf_B57sofuEB7OBneH86SJctTr7hfiAiQcgkGRbAQfha0Z"
          },
          "condition": {
            "type": "term",
            "values": ["Software as a service"]
          },
          "negate": false
        }
      }
    ]
  }
}
```

### Example Response

```json
{
  "data": [
    {
      "__object_type": "contact",
      "id": "cont_HjTcJFiNli2AKf5fioygQDVSpA9nJILI9SkKv3nBk0A",
      "name": "Bruce Wayne",
      "title": "The Dark Knight"
    },
    {
      "__object_type": "contact",
      "id": "cont_LXQqW8mvD0BbCR6qhRPbzPZF7gCbXQIw6GD8vqKipss",
      "name": "Steli Efti",
      "title": "CEO & Co-Founder"
    }
  ]
}
```

### Commonly Used Fields

**Contact** (`object_type: "contact"`):

| Field | Type |
|-------|------|
| `created_by` | User ID |
| `date_created` | datetime |
| `date_updated` | datetime |
| `updated_by` | User ID |
| `emails_count` | integer |
| `phones_count` | integer |
| `urls_count` | integer |
| `title` | text |
| `lead_id` | Lead ID |

**Lead** (`object_type: "lead"`):

| Field | Type |
|-------|------|
| `addresses_count` | integer |
| `all_urls_count` | integer |
| `created_by` | User ID |
| `date_created` | datetime |
| `date_updated` | datetime |
| `updated_by` | User ID |
| `description` | text |
| `display_name` | text |
| `status_id` | Lead Status ID |
| `url` | url |

**Contact Phones** (`object_type: "contact_phone"`):

| Field | Type |
|-------|------|
| `type` | text |
| `phone` | text |

**Contact Emails** (`object_type: "contact_email"`):

| Field | Type |
|-------|------|
| `type` | text |
| `email` | email address |

**Contact URLs** (`object_type: "contact_url"`):

| Field | Type |
|-------|------|
| `type` | text |
| `url` | url |

**Addresses** (`object_type: "address"`):

| Field | Type |
|-------|------|
| `address_1` | text |
| `address_2` | text |
| `city` | text |
| `country` | text |
| `location` | text |
| `state` | text |
| `zipcode` | text |

**Tip:** Instead of composing JSON by hand, build your query visually on the Leads or Contacts page in Close, then click the triple-dot menu and select "Copy Filters".

---

## Reporting

These endpoints return aggregated and per-user data used by Close's Reporting features. Revenue fields are returned in **cents**. Duration values are returned in **seconds**.

### GET /api/v1/report/activity/metrics/

List predefined metrics available for activity reports.

### POST /api/v1/report/activity/

Get an activity report. Returns metrics per time period (overview) or per user (comparison).

**Request Body Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `datetime_range` | object | Conditional | Time range. Required if `relative_range` not provided |
| `relative_range` | string | Conditional | Relative time range. Required if `datetime_range` not provided. Values: `today`, `this-week`, `this-month`, `this-quarter`, `this-year`, `yesterday`, `last-week`, `last-month`, `last-quarter`, `last-year`, `all-time` |
| `query` | object | No | Filter. Key `type` with type-specific keys. Currently only `saved_search` type with `saved_search_id` |
| `users` | array | No | List of user IDs to limit results |
| `type` | string | Yes | Report type: `overview` or `comparison` |
| `metrics` | array | Yes | List of metrics to fetch |

**Response format:** JSON or CSV (specify via `accept` header).

### GET /api/v1/report/sent_emails/{ORGANIZATION_ID}/

Get sent emails report grouped by template.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `user_id` | string | No | Filter by user |
| `date_start` | string | No | Report period start |
| `date_end` | string | No | Report period end |

### GET /api/v1/report/statuses/lead/{ORGANIZATION_ID}/

Get a lead status change report.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `date_start` | string | No | Report period start |
| `date_end` | string | No | Report period end |
| `query` | string | No | Lead search query filter (cannot use with `smart_view_id`) |
| `smart_view_id` | string | No | Smart view filter (cannot use with `query`) |

**Response Fields:**

`status_overview` (array) — All lead statuses with:

| Field | Type | Description |
|-------|------|-------------|
| `status_id` | string | Status ID |
| `status_label` | string | Status label |
| `status_is_deleted` | boolean | Whether status was deleted |
| `started` | integer | Leads in this status at period start |
| `ended` | integer | Leads in this status at period end |
| `change` | integer | Net change (`ended` - `started`) |
| `change_percent` | number | Net change in percent |
| `gained` | integer | Leads not in status at start but in status at end |
| `lost` | integer | Leads in status at start but not at end |
| `entered` | integer | Leads that entered this status during period |
| `left` | integer | Leads that left this status during period |
| `_queries` | object | Search queries for different states (`started`, `ended`, `gained`, `lost`, `entered`, `left`) |
| `_leads_page_urls` | object | UI page paths for different states |

`status_transitions` (array) — Aggregated transitions:

| Field | Type | Description |
|-------|------|-------------|
| `from_status_id` | string | Starting status ID (null for created leads) |
| `from_status_label` | string | Starting status label (null for created leads) |
| `from_status_is_deleted` | boolean | Whether starting status was deleted |
| `to_status_id` | string | Ending status ID |
| `to_status_label` | string | Ending status label |
| `to_status_is_deleted` | boolean | Whether ending status was deleted |
| `count` | integer | Number of leads that transitioned |
| `_query` | string | Search query for these leads |
| `_leads_page_url` | string | UI page path |

### GET /api/v1/report/statuses/opportunity/{ORGANIZATION_ID}/

Get an opportunity status change report.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `user_id` | string | No | Filter by opportunity user |
| `date_start` | string | No | Report period start |
| `date_end` | string | No | Report period end |
| `smart_view_id` | string | No | Smart view filter |
| `query` | string | No | Search query filter |

**Response:** Similar to lead status report with these differences:
- `status_transitions_summary` — summarized transitions (e.g., A->B->C counted as A->C)
- Numbers refer to opportunities, not leads
- `_queries` wrapped in nested opportunity query `opportunity(...)` for leads endpoint; unwrap for opportunities endpoint
- `_opportunities_page_urls` and `_opportunities_page_url` fields for opportunity UI pages

### GET /api/v1/report/custom/{ORGANIZATION_ID}/

Get a custom report (powers "Explorer" in UI).

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | No | Search query filter. Defaults to `*`. When reporting on activities/opportunities, only properties of the chosen object type may be used (e.g., `direction:incoming` for email) |
| `x` | string | Yes | X-axis field (e.g., `lead.custom.MRR`, `opportunity.date_created`) |
| `y` | string | No | Y-axis metric (default: `lead.count`). Examples: `call.duration`, `opportunity.value`. Only `number` data type can be used |
| `interval` | string | No | Graph interval/precision. For date X: `auto`, `hour`, `day`, `week`, `month`, `quarter`, `year` (default: `auto`). For numeric X: integer for histogram interval |
| `transform_y` | string | No | Y transformation: `sum` (default), `avg`, `min`, `max`. Does not apply for `.count` y values if x is same object type |
| `group_by` | string | No | Field to group by (separate series per group) |
| `start` | string/integer | No | Range start. For dates, defaults to org creation date |
| `end` | string/integer | No | Range end. For dates, defaults to now |

**Note:** Get a full list of available fields via `GET /report/custom/fields/`.

### POST /api/v1/report/funnel/opportunity/totals/

Get a funnel report (totals). Returns pipeline funnel metrics aggregated and per-user.

**Request Body Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pipeline` | string | Yes | Pipeline ID defining funnel statuses |
| `type` | string | Yes | `created-cohort` or `active-stage-cohort` |
| `report_relative_range` | string | Conditional | Report time range (relative). Values: `today`, `this-week`, `this-month`, `this-quarter`, `this-year`, `yesterday`, `last-week`, `last-month`, `last-quarter`, `last-year`, `all-time` |
| `report_datetime_range` | object | Conditional | Report time range (absolute) |
| `cohort_relative_range` | string | Conditional | Cohort range (relative). Required for `created-cohort`. Ignored for `active-stage-cohort` |
| `cohort_datetime_range` | object | Conditional | Cohort range (absolute). Required for `created-cohort`. Ignored for `active-stage-cohort` |
| `compared_relative_range` | string | No | Comparison range (relative). Only with `report_relative_range` (active-stage-cohort) or `cohort_relative_range` (created-cohort) |
| `compared_datetime_range` | string | No | Comparison range. Only with `report_datetime_range` or `cohort_datetime_range`. Values: `same-days-last-week`, `same-days-last-month`, `same-days-last-quarter`, `same-days-last-year` |
| `compared_custom_range` | object | No | Custom comparison range |
| `query` | object | No | Filter with `type` and `saved_search_id` |
| `users` | array | No | User or group IDs (empty = all users) |

**Response format:** JSON (aggregated + per-user) or CSV (per-user only, via `accept` header).

**Note:** When `compared_*` ranges are used, the response is the compared report, not the base one.

### POST /api/v1/report/funnel/opportunity/stages/

Get a funnel report (stages). Same parameters and behavior as funnel totals.

---

## Meeting Search

Meetings can be searched by provider calendar information (the underlying calendar events they were created from).

**Searchable Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `provider_calendar_event_id` | string | Yes | Provider event ID the meeting was synced from. **Always required** |
| `provider_calendar_id` | string | No | Provider calendar ID |
| `provider_calendar_type` | string | No | `"google"` or `"microsoft"` |
| `starts_at` | datetime | No | Meeting start time. Supports exact match and range queries |
| `starts_at__gte` | datetime | No | Greater than or equal |
| `starts_at__lt` | datetime | No | Less than |
| `lead_id` | string | No | Filter to specific lead |

**Warning:** You must always provide at least `provider_calendar_event_id` or you will receive an error.

### Example Queries

Search by event ID:
```
GET /api/v1/activity/meeting/?provider_calendar_event_id=EVENT_ID
```

Search with start time:
```
GET /api/v1/activity/meeting/?provider_calendar_event_id=EVENT_ID&starts_at=2023-09-19T15:00:00
```

Search by event and calendar ID:
```
GET /api/v1/activity/meeting/?provider_calendar_event_id=EVENT_ID&provider_calendar_id=CALENDAR_ID
```

Search with date range:
```
GET /api/v1/activity/meeting/?provider_calendar_event_id=EVENT_ID&provider_calendar_type=google&starts_at__gte=2023-09-20&starts_at__lt=2023-09-21&lead_id=LEAD_ID
```

### Google Calendar Provider Information

- `provider_calendar_event_id` = `id` property on Event resource
- `provider_calendar_id` = `id` property on Calendar resource

**Extract from `htmlLink`:** Base64 decode the `eid` query parameter. Result is space-separated `event_id calendar_id`.

Example:
```
https://www.google.com/calendar/event?eid=ZDYzOWZhMWM3ZWEzNDRjNzk3ZGYxZDBmNTE2MDMxMTMgZXhhbXBsZUBjbG9zZS5jb2
```
Base64 decode `eid` -> `d639fa1c7ea344c797df1d0f51603113 example@close.com`

**Extract from edit link:** Base64 decode the last path component.

Example:
```
https://calendar.google.com/calendar/u/1/r/eventedit/ZDYzOWZhMWM3ZWEzNDRjNzk3ZGYxZDBmNTE2MDMxMTMgZXhhbXBsZUBjbG9zZS5jb20
```
Decodes to `d639fa1c7ea344c797df1d0f51603113 example@close.com`

**Note:** You may need to add `=` padding characters for base64 decoding (Google strips them).

### Microsoft Calendar Provider Information

- `provider_calendar_event_id` = `id` property on Event resource
- `provider_calendar_id` = `id` property on Calendar resource

**Extract from `webLink`:** Use the `itemid` query parameter.

Example:
```
https://outlook.office365.com/owa/?itemid=AAMkADdiYzg5OGRlLTY1MjktNDc2Ni05YmVkLWMxMzFlNTQ0MzU3YQBGAAAAAACi9RQWB%2FSNTZBuALM6KIOsBwBtf4g8yY%2BzTZgZh6x0X%2F50AAAAAAENAABtf4g8yY%2BzTZgZh6x0X%2F50AALLI4%2FVAAA%3D&exvsurl=1&path=/calendar/item
```
URL-decode `itemid` and pass as `provider_calendar_event_id`.

**Extract from details link:** Use the last path component.

Example:
```
https://outlook.office.com/calendar/item/AAMkADdiYzg5OGRlLTY1MjktNDc2Ni05YmVkLWMxMzFlNTQ0MzU3YQBGAAAAAACi9RQWB%2FSNTZBuALM6KIOsBwBtf4g8yY%2BzTZgZh6x0X%2F50AAAAAAENAABtf4g8yY%2BzTZgZh6x0X%2F50AALmRd2BAAA%3D
```
URL-decode and pass the last path component as `provider_calendar_event_id`.
