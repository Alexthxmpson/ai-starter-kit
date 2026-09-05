# Close CRM API — Activities Documentation

> **Source:** https://developer.close.com/resources/activities/
> **Date scraped:** 2026-03-30
> **API Base URL:** `https://api.close.com/api/v1`

---

## Table of Contents

1. [Authentication](#authentication)
2. [Rate Limits](#rate-limits)
3. [Pagination](#pagination)
4. [Rich Text Fields](#rich-text-fields)
5. [Activities Overview](#activities-overview)
6. [Call](#call)
7. [Created](#created)
8. [Email](#email)
9. [EmailThread](#emailthread)
10. [LeadStatusChange](#leadstatuschange)
11. [Meeting](#meeting)
12. [Note](#note)
13. [OpportunityStatusChange](#opportunitystatuschange)
14. [SMS](#sms)
15. [TaskCompleted](#taskcompleted)
16. [LeadMerge](#leadmerge)
17. [WhatsAppMessage](#whatsappmessage)
18. [FormSubmission](#formsubmission)

---

## Authentication

API keys use **HTTP Basic authentication**. The API key is the username; the password is always empty.

```bash
curl https://api.close.com/api/v1/me/ -u yourapikey:
```

This sends the header:

```
Authorization: Basic eW91cmFwaWtleTo=
```

Where `eW91cmFwaWtleTo=` is the base64-encoded string `yourapikey:`.

- API keys are **per-organization** and can be generated/deleted in Settings.
- For public applications, use **OAuth** instead (see `/topics/oauth/`).

---

## Rate Limits

- Rate limits are enforced **per endpoint group** and **per organization**.
- Per-API-key limit exists; the per-organization limit is **3x** the per-key limit.
- If you receive HTTP **429 (Too Many Requests)**, sleep for the number of seconds in `rate_reset` before retrying.

**Response header** (on most responses):

```
RateLimit: limit=100, remaining=50, reset=5
```

| Header Field | Meaning |
|---|---|
| `limit` | Request limit for this endpoint (some allow bursting) |
| `remaining` | Requests left in the enforcement window |
| `reset` | Seconds remaining before the window ends (decimal) |

On 429 responses, the `retry-after` header is also set (rounded up to next integer).

---

## Pagination

### Offset-Based Pagination (most list endpoints)

Uses `_limit` and `_skip` query parameters.

```
Page 1: /api/v1/lead/?_skip=0&_limit=100
Page 2: /api/v1/lead/?_skip=100&_limit=100
Page 3: /api/v1/lead/?_skip=200&_limit=100
```

**Response format:**

```json
{
  "data": [ ... ],
  "has_more": true
}
```

- `data` — array of objects
- `has_more` — boolean indicating if more pages exist

**Deep Pagination:** There is a maximum `_skip` limit per resource. For large datasets, paginate using `date_created` range filters instead, or use the Export API.

### Cursor-Based Pagination

Used by Advanced Filtering API (`cursor` + `_limit` in request body) and Events API (`_cursor` + `_limit` query params).

---

## Rich Text Fields

Rich text fields (`note_html`, `user_note_html`, etc.) accept a **restricted subset of XHTML**.

### Supported HTML Elements

| Element | Purpose |
|---|---|
| `<body>` | Required wrapper (beginning and end) |
| `<b>`, `<strong>` | Bold text |
| `<i>`, `<em>` | Italic text |
| `<u>` | Underlined text |
| `<s>` | Strikethrough text |
| `<code>` | Inline code |
| `<h1>` through `<h6>` | Heading levels |
| `<p>` | Paragraphs |
| `<ul>` | Unordered lists |
| `<li>` | List items |
| `<hr>` | Horizontal rules |
| `<a href="...">` | Links |
| `<img src="..." alt="...">` | Images |
| `<span>` | Generic inline container |

### Mentions

```html
<span data-type="mention" data-id="..." data-label="..." class="mention">@Name</span>
```

### Supported Attributes

- `href` (on `<a>`)
- `src`, `alt` (on `<img>`)
- `style` (inline styling, e.g. colors)
- `data-type`, `data-id`, `data-label`, `class` (for mentions)

### note_html vs note Parameter Behavior

Applies to Call, Note, and other activity types that have both fields:

- **`note_html`** (preferred) — supports rich text via HTML subset. Setting it populates `note` with a plaintext representation (formatting not guaranteed).
- **`note`** — plaintext only. Setting it populates `note_html` by escaping HTML entities (e.g. `<div>` becomes `&lt;div&gt;`) and replacing `\n` with `<br />`.
- **Setting one overwrites the other.** If both are in the same request, `note_html` takes precedence.

---

## Activities Overview

Activities belong to **Leads** and represent any action performed on a Lead or its Contacts (Calls, Emails, Notes, etc.).

### GET /activity/

List or filter all activity types.

```
GET /activity/{?lead_id, user_id, user_id__in, contact_id, contact_id__in, _type, _type__in, date_created__gt, date_created__lt, activity_at__gt, activity_at__lt, _order_by, _fields, _limit, _skip}
```

#### Query Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead ID |
| `user_id` | string | Optional | Filter by user (single lead only) |
| `user_id__in` | string | Optional | Filter by multiple users (single lead only) |
| `contact_id` | string | Optional | Filter by contact (single lead only) |
| `contact_id__in` | string | Optional | Filter by multiple contacts (single lead only) |
| `_type` | string | Optional | Filter by activity type (single lead only) |
| `_type__in` | string | Optional | Filter by multiple activity types (single lead only) |
| `date_created__gt` | datetime | Optional | Created after this timestamp |
| `date_created__lt` | datetime | Optional | Created before this timestamp |
| `activity_at__gt` | datetime | Optional | Activity occurred after this timestamp |
| `activity_at__lt` | datetime | Optional | Activity occurred before this timestamp |
| `_order_by` | string | Optional | Sort field (e.g. `-activity_at`) |
| `_fields` | string | Optional | Specify which response fields to return |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |
| `thread_emails` | string | Optional | `true` or `only` (see below) |

#### Restrictions

- `user_id`, `user_id__in`, `contact_id`, `contact_id__in`, `_type`, `_type__in` can **only** be used when `lead_id` is specified.
- Sorting by `-activity_at` requires `lead_id` parameter.
- Date-based filters must match the sort field (use `activity_at__lt`/`activity_at__gt` only with `_order_by=-activity_at`).

#### Datetime Fields

| Field | Meaning |
|---|---|
| `date_created` | When the activity was created or synced into Close |
| `activity_at` | When the activity actually occurred (e.g. email sent time, meeting start time) |

#### thread_emails Parameter

| Value | Behavior |
|---|---|
| *(not set)* | Returns individual `Email` objects for each email message |
| `true` | Returns `EmailThread` objects + stripped-down `Email` objects |
| `only` | Returns only `EmailThread` objects; no `Email` objects |

#### Custom Activities

`_type` and `_type__in` accept:
- Custom Activity Type IDs (e.g. `actitype_1h5m6uHM9BZOpwVhyRJb4Y`) for a specific custom type
- `Custom` to list all custom activities regardless of type

---

## Call

A Call represents phone interactions. Calls can be made via direct calling, power dialer, or predictive dialer.

### Call Methods

| Value | Description |
|---|---|
| `regular` | Direct calling or incoming calls |
| `power` | Power dialer calls |
| `predictive` | Predictive dialer calls |

### Call Dispositions

| Value | Description |
|---|---|
| `answered` | Call was answered |
| `no-answer` | Call was not answered |
| `vm-answer` | Voicemail reached, no message left (incoming only) |
| `vm-left` | Voicemail was left (incoming) or dropped (outgoing) |
| `busy` | Destination was busy |
| `blocked` | Close blocked the call (e.g. invalid number) |
| `error` | Unexpected error in Close or carrier |
| `abandoned` | Call abandoned (predictive dialer only — no rep available) |

### Call Fields

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique identifier |
| `_type` | string | Activity type (`Call`) |
| `organization_id` | string | Organization ID |
| `lead_id` | string | Associated lead |
| `user_id` | string | Associated user |
| `user_name` | string | User display name |
| `contact_id` | string | Associated contact |
| `created_by` | string | User ID who created |
| `created_by_name` | string | Creator display name |
| `updated_by` | string | User ID who last updated |
| `updated_by_name` | string | Updater display name |
| `date_created` | datetime | Creation timestamp |
| `date_updated` | datetime | Last update timestamp |
| `activity_at` | datetime | When the call occurred |
| `call_method` | string | `regular`, `power`, or `predictive` |
| `disposition` | string | Call outcome (see table above) |
| `outcome_id` | string | Custom user-defined outcome (optional) |
| `status` | string | Call status (defaults to `completed`) |
| `direction` | string | `outbound` or `inbound` |
| `duration` | integer | Call duration in seconds |
| `cost` | decimal | Call cost in US cents |
| `phone` | string | Phone number |
| `source` | string | Call source |
| `local_phone` | string | Local (Close) phone number |
| `remote_phone` | string | Remote (contact) phone number |
| `local_country_iso` | string | ISO country code of local number |
| `remote_country_iso` | string | ISO country code of remote number |
| `recording_url` | string | HTTPS URL to MP3 recording |
| `voicemail_url` | string | URL to voicemail recording |
| `voicemail_duration` | integer | Voicemail duration in seconds |
| `note_html` | string | Rich-text note (HTML subset) |
| `note` | string | Plaintext note |
| `transferred_from` | string | Transfer source |
| `transferred_to` | string | Transfer destination |
| `dialer_id` | string | Dialer session ID |
| `dialer_saved_search_id` | string | Saved search used by dialer |
| `recording_transcript` | object | Call recording transcript (optional, load via `_fields`) |
| `voicemail_transcript` | object | Voicemail transcript (optional, load via `_fields`) |

### Call Transcripts

Not loaded by default. Use `_fields` parameter with `recording_transcript` or `voicemail_transcript`.

**Transcript structure:**

```json
{
  "recording_transcript": {
    "utterances": [
      {
        "speaker_label": "John Lead",
        "speaker_side": "contact",
        "start": 0.1,
        "end": 1.2,
        "text": "Hey, what's up? How is it going?"
      },
      {
        "speaker_label": "Jane User",
        "speaker_side": "close-user",
        "start": 1.3,
        "end": 2.4,
        "text": "Hey John, I'm doing great. How about you?"
      }
    ],
    "summary_text": "Summary text",
    "summary_html": "<p>Summary text</p>"
  }
}
```

| Transcript Field | Type | Description |
|---|---|---|
| `utterances` | array | Array of utterance objects |
| `utterances[].speaker_label` | string | Speaker name |
| `utterances[].speaker_side` | string | `contact` or `close-user` |
| `utterances[].start` | float | Start time in seconds |
| `utterances[].end` | float | End time in seconds |
| `utterances[].text` | string | Spoken text |
| `summary_text` | string | Plaintext summary |
| `summary_html` | string | HTML-formatted summary |

### GET /activity/call/

List or filter all Call activities.

```
GET /activity/call/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

**Response:** `{ "data": [...], "has_more": bool }`

### POST /activity/call/

Log a Call activity manually (for calls made outside of the Close VoIP system).

```
POST /activity/call/
```

| Field | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Required | Lead to associate the call with |
| `status` | string | Optional | Defaults to `completed` |
| `direction` | string | Optional | `outbound` or `inbound` |
| `recording_url` | string | Optional | HTTPS URL to MP3 recording (must start with `https://`) |
| `note_html` | string | Optional | Rich-text note (preferred) |
| `note` | string | Optional | Plaintext note |
| `duration` | integer | Optional | Call duration in seconds |
| `phone` | string | Optional | Phone number called |
| `disposition` | string | Optional | Call outcome |
| `outcome_id` | string | Optional | Custom outcome ID |
| `contact_id` | string | Optional | Contact ID |
| `user_id` | string | Optional | User who made/received the call |

### GET /activity/call/{id}/

Fetch a single Call activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Call activity ID |

### PUT /activity/call/{id}/

Update a Call activity. Most commonly used to update `note_html` or `outcome_id`.

**Restriction:** Fields such as `status`, `duration`, or `direction` **cannot be updated** for internal calls (calls made through Close's VoIP system).

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Call activity ID |
| `note_html` | string | Optional | Rich-text note |
| `note` | string | Optional | Plaintext note |
| `outcome_id` | string | Optional | Custom outcome |

### DELETE /activity/call/{id}/

Delete a Call activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Call activity ID |

---

## Created

Created activities denote the time and method by which a lead was created.

### GET /activity/created/

List or filter all Created activities.

```
GET /activity/created/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### GET /activity/created/{id}/

Fetch a single Created activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Created activity ID |

---

## Email

Email activities represent individual email messages.

### GET /activity/email/

List or filter all Email activities. Returns one object per email message.

```
GET /activity/email/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### POST /activity/email/

Create an Email activity.

```
POST /activity/email/
```

#### Status Values

| Status | Description |
|---|---|
| `inbox` | Log an already received email |
| `draft` | Create a draft email |
| `scheduled` | Send at a scheduled date/time (requires `date_scheduled`) |
| `outbox` | Send immediately (optional `send_in` in seconds, must be < 60) |
| `sent` | Log an already sent email |

#### Request Body Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Required | Lead to associate the email with |
| `status` | string | Required | One of: `inbox`, `draft`, `scheduled`, `outbox`, `sent` |
| `sender` | string | Conditional | Format: `"\"John Smith\" <email@example.com>"`. Required for `inbox`, `scheduled`, `outbox`, `error`. Optional for `draft` and `sent`. |
| `to` | array | Optional | Array of recipient email addresses |
| `cc` | array | Optional | Array of CC email addresses |
| `bcc` | array | Optional | Array of BCC email addresses |
| `subject` | string | Optional | Email subject line |
| `body_text` | string | Optional | Plaintext email body |
| `body_html` | string | Optional | HTML email body |
| `template_id` | string | Optional | Email Template ID (renders server-side if `body_text`/`body_html` omitted) |
| `date_scheduled` | datetime | Conditional | Required when status is `scheduled` |
| `send_in` | integer | Optional | Delay sending by N seconds (max 60, use with `outbox` status) |
| `followup_date` | datetime | Optional | Creates email followup task if no response received |
| `attachments` | array | Optional | Array of attachment objects (see below) |
| `contact_id` | string | Optional | Contact ID |
| `user_id` | string | Optional | User ID |

#### Attachment Object

Files must be uploaded first via the Files API.

| Field | Type | Required | Description |
|---|---|---|---|
| `url` | string | Required | Must begin with `https://app.close.com/go/file/` |
| `filename` | string | Required | File name |
| `content_type` | string | Required | MIME type |
| `size` | integer | Required | File size in bytes |

#### Behavior Notes

- Only drafts can be modified.
- Draft status can change to `scheduled` or `outbox`.
- Scheduled or unsent outbox emails can be canceled by setting status back to `draft`.
- `sender` is required when changing a draft to `scheduled` or `outbox` if not already set.
- Email Templates render server-side when `template_id` is provided without `body_text`/`body_html`.
- `send_in` delays sending by a few seconds (to allow undo).
- `followup_date` triggers an email followup task if no response is received.

### GET /activity/email/{id}/

Fetch a single Email activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Email activity ID |

### PUT /activity/email/{id}/

Update an Email activity. Can modify a draft or send it.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Email activity ID |

**Allowed status changes:**
- Draft -> `scheduled` or `outbox`
- Scheduled/Outbox -> `draft` (to cancel)

### DELETE /activity/email/{id}/

Delete an Email activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Email activity ID |

---

## EmailThread

Email Threads are a collection of Email activities belonging to the same thread. Conversations are generally grouped by subject.

### GET /activity/emailthread/

List or filter all EmailThread activities. Returns one object per email conversation.

```
GET /activity/emailthread/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### GET /activity/emailthread/{id}/

Fetch a single EmailThread activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | EmailThread activity ID |

### DELETE /activity/emailthread/{id}/

Delete an EmailThread activity. **This will also delete all the email activities belonging to this thread.**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | EmailThread activity ID |

---

## LeadStatusChange

Lead Status Changes are created when you change the status of a Lead object.

### GET /activity/status_change/lead/

List or filter all LeadStatusChange activities.

```
GET /activity/status_change/lead/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### POST /activity/status_change/lead/

Create a new LeadStatusChange activity.

> **WARNING:** Creating a lead status change **does NOT change the status of the Lead**. It only logs the status change event in the Lead's activity feed. It should only be used to **import historical status changes** from another organization or system.

| Field | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Required | Lead ID |
| `old_status_id` | string | Required | Previous status ID |
| `new_status_id` | string | Required | New status ID |
| `old_status_label` | string | Optional | Previous status label |
| `new_status_label` | string | Optional | New status label |

### GET /activity/status_change/lead/{id}/

Fetch a single LeadStatusChange activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | LeadStatusChange activity ID |

### DELETE /activity/status_change/lead/{id}/

Delete a single LeadStatusChange activity.

> **WARNING:** Deleting a LeadStatusChange **does NOT change the status of the Lead**. It only removes the status change event from the activity feed. Use only when the change is irrelevant or causing integration problems.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | LeadStatusChange activity ID |

---

## Meeting

A Meeting activity represents calendar events synced with Close. Meetings track statuses, attendees, transcripts, and custom outcomes.

### Meeting Statuses

| Status | Description |
|---|---|
| `upcoming` | Meeting is in the future |
| `in-progress` | Meeting is currently occurring |
| `completed` | Meeting happened and has ended |
| `canceled` | Deleted from all synced calendars, all lead contacts removed, or moved to all-day event |
| `declined-by-lead` | At least one lead contact declined, no other lead contacts accepted |
| `declined-by-org` | All Close users declined to attend |

### Attendee Statuses

| Status | Description |
|---|---|
| `noreply` | Attendee has not replied to the invite |
| `yes` | Attendee accepted |
| `no` | Attendee declined |
| `maybe` | Attendee replied maybe/tentative |

### Meeting Fields

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique identifier |
| `_type` | string | Activity type (`Meeting`) |
| `organization_id` | string | Organization ID |
| `lead_id` | string | Associated lead |
| `user_id` | string | Associated user |
| `contact_id` | string | Associated contact |
| `date_created` | datetime | When the meeting object was created in Close |
| `date_updated` | datetime | When the meeting was last updated in Close |
| `starts_at` | datetime | When the meeting event starts |
| `ends_at` | datetime | When the meeting event ends |
| `activity_at` | datetime | Timeline position (defaults to `starts_at`) |
| `status` | string | Meeting status (see table above) |
| `attendees` | array | Array of attendee objects with status tracking |
| `is_recurring` | boolean | `true` if recurring on Google Calendar |
| `user_note_html` | string | Rich-text meeting notes |
| `outcome_id` | string | Custom user-defined outcome |
| `provider_calendar_event_id` | string | Provider event ID the meeting was synced from |
| `provider_calendar_ids` | array | Provider calendar IDs the meeting was synced from |
| `provider_calendar_type` | string | `"google"` or `"microsoft"` |
| `transcripts` | array | Array of transcript objects (load via `_fields=transcripts`) |

### Meeting Transcripts

Not loaded by default. Use `_fields` parameter with `transcripts` value.

```json
{
  "transcripts": [
    {
      "utterances": [
        {
          "speaker_label": "John Lead",
          "speaker_side": "contact",
          "start": 0.1,
          "end": 1.2,
          "text": "Hey, what's up? How is it going?"
        },
        {
          "speaker_label": "Jane User",
          "speaker_side": "close-user",
          "start": 1.3,
          "end": 2.4,
          "text": "Hey John, I'm doing great. How about you?"
        }
      ],
      "summary_text": "Summary text",
      "summary_html": "<p>Summary text</p>"
    }
  ]
}
```

The `transcripts` field is an array of objects for each Close Notetaker bot that joined. Typically there will be only one transcript. Ordered by time bots joined.

### GET /activity/meeting/

List or filter all Meeting activities.

```
GET /activity/meeting/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### GET /activity/meeting/{id}/

Fetch a single Meeting activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Meeting activity ID |

### PUT /activity/meeting/{id}/

Update a Meeting activity. Most commonly used to update `user_note_html` or `outcome_id`.

| Field | Type | Required | Description |
|---|---|---|---|
| `user_note_html` | string | Optional | Rich-text meeting notes |
| `outcome_id` | string | Optional | Custom outcome ID |

### DELETE /activity/meeting/{id}/

Delete a Meeting activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Meeting activity ID |

### POST /activity/meeting/{id}/integration/

Create or update a third-party Meeting integration.

> **IMPORTANT:** Only **OAuth apps** can perform this operation. Using an API key will result in an error. See Authentication with OAuth.

Third-party integrations appear as tabs titled with the OAuth app name in the activity feed. First invocation creates a new integration; subsequent calls with the same OAuth app update the existing one. Submitting an empty JSON body does nothing.

---

## Note

Note activities are freeform text notes attached to leads.

### Note Fields

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique identifier |
| `_type` | string | Activity type (`Note`) |
| `lead_id` | string | Associated lead |
| `user_id` | string | Associated user |
| `contact_id` | string | Associated contact |
| `note_html` | string | Rich-text note (HTML subset, preferred) |
| `note` | string | Plaintext note |
| `pinned` | boolean | Whether the note is pinned |
| `attachments` | array | Array of attachment objects |
| `date_created` | datetime | Creation timestamp |
| `date_updated` | datetime | Last update timestamp |
| `activity_at` | datetime | When the note occurred |

### GET /activity/note/

List or filter all Note activities.

```
GET /activity/note/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### POST /activity/note/

Create a Note activity.

```
POST /activity/note/
```

| Field | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Required | Lead to associate the note with |
| `note_html` | string | Optional | Rich-text note (preferred, see Rich Text Fields) |
| `note` | string | Optional | Plaintext note |
| `pinned` | boolean | Optional | Pin the note (`true`/`false`) |
| `contact_id` | string | Optional | Contact ID |
| `user_id` | string | Optional | User ID |
| `attachments` | array | Optional | Array of attachment objects |

#### Attachment Object

Files must be uploaded first via the Files API.

| Field | Type | Required | Description |
|---|---|---|---|
| `url` | string | Required | Must begin with `https://app.close.com/go/file/` |
| `filename` | string | Required | File name |
| `content_type` | string | Required | MIME type |

### GET /activity/note/{id}/

Fetch a single Note activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Note activity ID |

### PUT /activity/note/{id}/

Update a Note activity.

| Field | Type | Required | Description |
|---|---|---|---|
| `note_html` | string | Optional | Rich-text note |
| `note` | string | Optional | Plaintext note |
| `pinned` | boolean | Optional | Pin/unpin the note |

### DELETE /activity/note/{id}/

Delete a Note activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Note activity ID |

---

## OpportunityStatusChange

Opportunity Status Changes are created when you change the status of an Opportunity object.

### GET /activity/status_change/opportunity/

List or filter all OpportunityStatusChange activities.

```
GET /activity/status_change/opportunity/{?lead_id, opportunity_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `opportunity_id` | string | Optional | Filter by opportunity |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### POST /activity/status_change/opportunity/

Create a new OpportunityStatusChange activity.

> **WARNING:** Creating an opportunity status change **does NOT change the status of the Opportunity**. It only logs the status change event in the Lead's activity feed. It should only be used to **import historical status changes** from another organization or system.

| Field | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Required | Lead ID |
| `opportunity_id` | string | Required | Opportunity ID |
| `old_status_id` | string | Required | Previous status ID |
| `new_status_id` | string | Required | New status ID |
| `old_status_label` | string | Optional | Previous status label |
| `new_status_label` | string | Optional | New status label |

### GET /activity/status_change/opportunity/{id}/

Fetch a single OpportunityStatusChange activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | OpportunityStatusChange activity ID |

### DELETE /activity/status_change/opportunity/{id}/

Delete a single OpportunityStatusChange activity.

> **WARNING:** Deleting an OpportunityStatusChange **does NOT change the status of the Opportunity**. It only removes the status change event from the activity feed. Use only if the status change is irrelevant (such as records for a change that has been reverted) and having it in the activity feed is causing integration problems.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | OpportunityStatusChange activity ID |

---

## SMS

SMS activities represent text messages. MMS messages are treated as SMS messages with attachments.

### MMS Attachments

MMS messages have attachments with these fields (identical to email attachments plus extras):

| Field | Type | Description |
|---|---|---|
| `url` | string | Authenticated S3 URL (requires session) |
| `filename` | string | File name |
| `size` | integer | File size in bytes |
| `content_type` | string | MIME type |
| `media_id` | string | Unique attachment identifier |
| `thumbnail_url` | string | Thumbnail URL (if Close generated one; requires session) |

> **Note:** Accessing `url` or `thumbnail_url` requires an authenticated session and leads to a temporarily signed S3 URL.

### GET /activity/sms/

List or filter all SMS activities.

```
GET /activity/sms/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### POST /activity/sms/

Create an SMS activity.

```
POST /activity/sms/{?send_to_inbox}
```

#### Status Values

| Status | Description |
|---|---|
| `inbox` | Log an already received SMS |
| `draft` | Create a draft SMS |
| `scheduled` | Send at scheduled date/time (requires `date_scheduled`) |
| `outbox` | Send immediately (optional `send_in` in seconds, max 60) |
| `sent` | Log an already sent SMS |

#### Request Body Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Required | Lead to associate the SMS with |
| `status` | string | Required | One of: `inbox`, `draft`, `scheduled`, `outbox`, `sent` |
| `text` | string | Optional | SMS message content |
| `template_id` | string | Optional | SMS Template ID (renders instead of `text`) |
| `local_phone` | string | Required | Must be associated with a Phone Number of type `internal` |
| `remote_phone` | string | Optional | Recipient phone number |
| `direction` | string | Optional | Defaults to `inbound` when status=`inbox`, otherwise `outbound` |
| `date_scheduled` | datetime | Conditional | Required when status is `scheduled` |
| `send_in` | integer | Optional | Delay sending by N seconds (max 60) |
| `contact_id` | string | Optional | Contact ID |
| `user_id` | string | Optional | User ID |

#### Query Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `send_to_inbox` | boolean | Optional | Pass `true` to create Inbox Notification when status is `inbox` |

#### Behavior Notes

- Only drafts can be modified.
- Draft status can change to `scheduled` or `outbox`.
- Scheduled or unsent outbox SMS can be canceled by setting status back to `draft`.
- `local_phone` must be associated with a Phone Number of type `internal` (see Phone Numbers).
- `template_id` can be used instead of `text` to auto-render an SMS Template.
- When `direction` is not provided: defaults to `inbound` for `status="inbox"`, otherwise `outbound`.

### GET /activity/sms/{id}/

Fetch a single SMS activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | SMS activity ID |

### PUT /activity/sms/{id}/

Update an SMS activity. Can modify a draft or send it.

| Field | Type | Required | Description |
|---|---|---|---|
| `status` | string | Optional | Change to `outbox` (send now) or `scheduled` (send later) |
| `text` | string | Optional | Updated SMS text |
| `date_scheduled` | datetime | Conditional | Required when changing to `scheduled` |

### DELETE /activity/sms/{id}/

Delete an SMS activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | SMS activity ID |

---

## TaskCompleted

TaskCompleted activities are created when you complete a task on a lead.

### GET /activity/task_completed/

List or filter all TaskCompleted activities.

```
GET /activity/task_completed/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### GET /activity/task_completed/{id}/

Fetch a single TaskCompleted activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | TaskCompleted activity ID |

### DELETE /activity/task_completed/{id}/

Delete a TaskCompleted activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | TaskCompleted activity ID |

---

## LeadMerge

LeadMerge activities are created when you merge one lead into another.

- **Source lead** — the one being merged (will be deleted after merge completes)
- **Destination lead** — the one that remains after the merge
- The `status` field shows the progress of the lead merge

### GET /activity/lead_merge/

List or filter all LeadMerge activities.

```
GET /activity/lead_merge/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### GET /activity/lead_merge/{id}/

Fetch a single LeadMerge activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | LeadMerge activity ID |

> **Note:** LeadMerge activities are read-only. There is no POST, PUT, or DELETE endpoint.

---

## WhatsAppMessage

WhatsAppMessage activities represent messages in an external WhatsApp chat. These can be created by WhatsApp integrations to facilitate viewing ongoing WhatsApp conversations within the CRM.

### WhatsAppMessage Fields

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique identifier (format: `acti_...`) |
| `_type` | string | Activity type (`WhatsAppMessage`) |
| `lead_id` | string | Associated lead |
| `user_id` | string | Associated user |
| `contact_id` | string | Associated contact |
| `external_whatsapp_message_id` | string | WhatsApp native message ID |
| `message_markdown` | string | Message body in WhatsApp Markdown format |
| `message_html` | string | HTML representation (read-only) |
| `direction` | string | `incoming` or `outgoing` |
| `attachments` | array | Array of attachment objects |
| `integration_link` | string | URL linking to external system message |
| `response_to_id` | string | Close activity ID of parent WhatsApp message (threading) |
| `date_created` | datetime | Creation timestamp |
| `date_updated` | datetime | Last update timestamp |

### GET /activity/whatsapp_message/

List or filter all WhatsAppMessage activities.

```
GET /activity/whatsapp_message/{?lead_id, user_id, external_whatsapp_message_id, date_created__gt, date_created__lt}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `external_whatsapp_message_id` | string | Optional | Filter by WhatsApp message ID (for sync) |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |

### POST /activity/whatsapp_message/

Create a WhatsAppMessage activity.

```
POST /activity/whatsapp_message/{?send_to_inbox}
```

#### Request Body Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Required | Lead to associate the message with |
| `external_whatsapp_message_id` | string | Required | WhatsApp native message ID |
| `message_markdown` | string | Required | Message body in WhatsApp Markdown format |
| `direction` | string | Required | `incoming` or `outgoing` |
| `contact_id` | string | Optional | Contact ID |
| `user_id` | string | Optional | User ID |
| `attachments` | array | Optional | Array of attachment objects (see below) |
| `integration_link` | string | Optional | URL linking back to external system |
| `response_to_id` | string | Optional | Close activity ID of parent WhatsApp message for threading (must be `acti_...` format) |

#### Attachment Object

Files must be uploaded first via the Files API.

| Field | Type | Required | Description |
|---|---|---|---|
| `url` | string | Required | Must begin with `https://app.close.com/go/file/` |
| `filename` | string | Required | File name |
| `content_type` | string | Required | MIME type |

#### Query Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `send_to_inbox` | boolean | Optional | Pass `true` for incoming messages to create Inbox Notification |

#### Constraints

- Total attachment size per message cannot exceed **25MB**.
- Only WhatsApp Markdown messages and file attachments are supported.
- **No support** for Polls, Events, Locations, etc.
- `response_to_id` creates a thread relationship between messages for tracking conversation flow.
- `message_html` (read-only) is automatically generated from `message_markdown`.

### GET /activity/whatsapp_message/{id}/

Fetch a single WhatsAppMessage activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | WhatsAppMessage activity ID |

### PUT /activity/whatsapp_message/{id}/

Update a WhatsAppMessage activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | WhatsAppMessage activity ID |

### DELETE /activity/whatsapp_message/{id}/

Delete a WhatsAppMessage activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | WhatsAppMessage activity ID |

---

## FormSubmission

A FormSubmission activity is created automatically when someone submits a form through Close forms.

> **IMPORTANT:** FormSubmissions are created by the system when a form is submitted. They **cannot be created or modified** through the API. Only read (GET) and delete (DELETE) operations are available.

### FormSubmission Fields

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique identifier |
| `_type` | string | Activity type (`FormSubmission`) |
| `lead_id` | string | Associated lead |
| `contact_id` | string | Associated contact |
| `organization_id` | string | Organization ID |
| `form_id` | string | ID of the form that was submitted |
| `values` | object | Submitted form data as key-value pairs. Keys are form field IDs (e.g. `formfld_0325NAK2ePwMEBJrZZCk5F`), values are user submissions. |
| `ip_address` | string | IP address of the submitter |
| `origin` | string | Origin header from the submission request |
| `source_url` | string | Full URL where the form was submitted |
| `source_url_normalized` | string | Read-only. Computed domain + path from `source_url` |
| `date_created` | datetime | Creation timestamp |
| `date_updated` | datetime | Last update timestamp |

### GET /activity/form_submission/

List or filter all FormSubmission activities.

```
GET /activity/form_submission/{?lead_id, contact_id, organization_id, form_id, form_id__in, date_created__gt, date_created__lt, _limit, _skip, _fields}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `contact_id` | string | Optional | Filter by contact |
| `organization_id` | string | Optional | Filter by organization |
| `form_id` | string | Optional | Filter by specific form |
| `form_id__in` | string | Optional | Filter by multiple forms |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |
| `_fields` | string | Optional | Specify which fields to return |

### GET /activity/form_submission/{id}/

Fetch a single FormSubmission activity.

```
GET /activity/form_submission/{id}/{?_fields}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | FormSubmission activity ID |
| `_fields` | string (query) | Optional | Specify which fields to return |

### DELETE /activity/form_submission/{id}/

Delete a FormSubmission activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | FormSubmission activity ID |

---

## Endpoint Summary

| Activity Type | List (GET) | Create (POST) | Fetch (GET) | Update (PUT) | Delete (DELETE) |
|---|---|---|---|---|---|
| All Activities | `/activity/` | -- | -- | -- | -- |
| Call | `/activity/call/` | `/activity/call/` | `/activity/call/{id}/` | `/activity/call/{id}/` | `/activity/call/{id}/` |
| Created | `/activity/created/` | -- | `/activity/created/{id}/` | -- | -- |
| Email | `/activity/email/` | `/activity/email/` | `/activity/email/{id}/` | `/activity/email/{id}/` | `/activity/email/{id}/` |
| EmailThread | `/activity/emailthread/` | -- | `/activity/emailthread/{id}/` | -- | `/activity/emailthread/{id}/` |
| LeadStatusChange | `/activity/status_change/lead/` | `/activity/status_change/lead/` | `/activity/status_change/lead/{id}/` | -- | `/activity/status_change/lead/{id}/` |
| Meeting | `/activity/meeting/` | -- | `/activity/meeting/{id}/` | `/activity/meeting/{id}/` | `/activity/meeting/{id}/` |
| Note | `/activity/note/` | `/activity/note/` | `/activity/note/{id}/` | `/activity/note/{id}/` | `/activity/note/{id}/` |
| OpportunityStatusChange | `/activity/status_change/opportunity/` | `/activity/status_change/opportunity/` | `/activity/status_change/opportunity/{id}/` | -- | `/activity/status_change/opportunity/{id}/` |
| SMS | `/activity/sms/` | `/activity/sms/` | `/activity/sms/{id}/` | `/activity/sms/{id}/` | `/activity/sms/{id}/` |
| TaskCompleted | `/activity/task_completed/` | -- | `/activity/task_completed/{id}/` | -- | `/activity/task_completed/{id}/` |
| LeadMerge | `/activity/lead_merge/` | -- | `/activity/lead_merge/{id}/` | -- | -- |
| WhatsAppMessage | `/activity/whatsapp_message/` | `/activity/whatsapp_message/` | `/activity/whatsapp_message/{id}/` | `/activity/whatsapp_message/{id}/` | `/activity/whatsapp_message/{id}/` |
| FormSubmission | `/activity/form_submission/` | -- | `/activity/form_submission/{id}/` | -- | `/activity/form_submission/{id}/` |
| Meeting Integration | -- | `/activity/meeting/{id}/integration/` | -- | -- | -- |

---

## Common Query Parameters (All List Endpoints)

| Parameter | Type | Description |
|---|---|---|
| `lead_id` | string | Filter by lead ID |
| `user_id` | string | Filter by user ID |
| `date_created__gt` | datetime | Created after this timestamp |
| `date_created__lt` | datetime | Created before this timestamp |
| `_limit` | integer | Number of results per page |
| `_skip` | integer | Number of results to skip (offset) |

## Common Response Format

```json
{
  "has_more": false,
  "data": [
    { ... activity object ... }
  ]
}
```

## Authentication Example

```bash
# All endpoints require Basic Auth with API key
curl "https://api.close.com/api/v1/activity/call/" \
  -u "your_api_key:"
```

The colon after the API key is required (key is username, password is empty).
