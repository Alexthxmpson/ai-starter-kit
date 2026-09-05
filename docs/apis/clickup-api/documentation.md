# ClickUp API v2 & v3 -- Full Technical Documentation

**Source URL:** https://developer.clickup.com/
**Date Saved:** 2026-03-18 | **Last Updated:** 2026-03-29
**API Versions:** v2 (stable production), v3 (emerging -- select endpoints)
**Base URL:** `https://api.clickup.com/api`

> For deep-dive research, see: `MASTER-SYNTHESIS.md`
> For topic briefings, see: `briefings/`
> For gap analysis, see: `GAP-ANALYSIS.md`
> For all endpoints map, see: `KNOWLEDGE-MAP.md`

---

## API Versioning (v2 vs v3)

ClickUp is gradually migrating from v2 to v3. During transition, both versions coexist.

| Aspect | API v2 | API v3 |
|--------|--------|--------|
| Base path | `/api/v2/` | `/api/v3/` |
| Top-level entity | `team` (team_id) | `workspaces` (workspace_id) |
| User groups | `/team/{id}/group` | `/workspaces/{id}/...` |
| Status | Stable, full coverage | Partial -- select endpoints only |

**v3 endpoints available now:**
- `GET /api/v3/workspaces/{workspaceId}/docs` -- Search/list Docs
- `POST /api/v3/workspaces/{workspace_id}/auditlogs` -- Audit logs (Enterprise)
- `PUT /api/v3/workspaces/{workspace_id}/tasks/{task_id}/home_list/{list_id}` -- Move task

**Key v3 terminology change:** `team_id` -> `workspace_id`. Same numeric ID, different path naming.

---

## Authentication

Two methods supported:

### Personal Token
```http
Authorization: pk_YOUR_TOKEN
Content-Type: application/json
```
Never expires. Get from: ClickUp Settings -> Apps -> API Token.

### OAuth 2.0
```http
Authorization: Bearer {access_token}
```
- Auth URL: `https://app.clickup.com/api?client_id={id}&redirect_uri={uri}`
- Token URL: `POST https://api.clickup.com/api/v2/oauth/token`
- Body: `{client_id, client_secret, code}`
- No granular scopes (workspace-level)
- Tokens currently don't expire

---

## Data Hierarchy

```
Workspace (team_id / workspace_id: number)
  +-- Space (space_id: number)
  |     +-- Folder (folder_id: number)
  |     |     +-- List (list_id: number)
  |     |           +-- Task (task_id: string e.g. "9hz")
  |     +-- List [folderless]
  +-- Doc (v3 only)
```

**Note:** `team_id` in v2 = Workspace (legacy naming from v1). Same numeric ID used as `workspace_id` in v3.

---

## Rate Limits

| Plan | Req/Min/Token |
|------|--------------|
| Free/Unlimited/Business | 100 |
| Business Plus | 1,000 |
| Enterprise | 10,000 |

Headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`
No `Retry-After` header -- compute: `int(X-RateLimit-Reset) - time.time() + 2`

---

## Task Endpoints

### v2 Task CRUD

```
POST   /v2/list/{list_id}/task              Create task
GET    /v2/task/{task_id}                   Get task
PUT    /v2/task/{task_id}                   Update task
DELETE /v2/task/{task_id}                   Delete task
GET    /v2/list/{list_id}/task              List tasks (page=0, 100/page)
GET    /v2/team/{team_id}/task              Workspace-wide tasks
```

### v3 Task Endpoints

```
PUT    /v3/workspaces/{workspace_id}/tasks/{task_id}/home_list/{list_id}   Move task to new List
```

Move Task request body:
```json
{
  "move_custom_fields": true,
  "custom_fields_to_move": ["field_id_1", "field_id_2"],
  "status_mappings": [
    {"source_status_id": "abc", "destination_status_id": "xyz"}
  ]
}
```
**Note:** `status_mappings` required if the task's current status doesn't exist in the new List.

### Create Task Fields

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| name | string | YES | Task name |
| description | string | no | Plain text |
| markdown_content | string | no | Overrides description if both provided |
| assignees | integer[] | no | Flat array on CREATE |
| group_assignees | string[] | no | **NEW** -- Assign user groups to the task |
| tags | string[] | no | Tag names |
| status | string | no | Case-sensitive, must match list status |
| priority | integer or null | no | 1=Urgent 2=High 3=Normal 4=Low, null=none |
| due_date | integer | no | Unix ms timestamp |
| due_date_time | boolean | no | **NEW** -- Whether due_date includes time |
| start_date | integer | no | Unix ms timestamp |
| start_date_time | boolean | no | **NEW** -- Whether start_date includes time |
| time_estimate | integer | no | Milliseconds |
| points | number | no | **NEW** -- Sprint Points |
| parent | string or null | no | Creates subtask (must be in same List) |
| links_to | string or null | no | **NEW** -- Task ID to create linked dependency |
| custom_fields | array | no | [{id, value}] -- see Custom Fields section |
| custom_item_id | number | no | **NEW** -- Custom Task Type ID. null = standard "Task". Use Get Custom Task Types to list available IDs. 0=Task, 1=Milestone |
| notify_all | boolean | no | **NEW** -- If true, creator also gets notified |
| check_required_custom_fields | boolean | no | **NEW** -- Enforce required custom fields (default: false, they're ignored) |
| archived | boolean | no | **NEW** -- Create task in archived state |

### Update Task Fields

Same as create, EXCEPT:
- Assignees: `{"add": [uid], "rem": [uid]}`
- **Custom fields NOT updated via PUT /task. Use /task/{id}/field/{field_id}.**

### Task Query Params (GET /list/{id}/task)

| Parameter | Type | Description |
|-----------|------|-------------|
| page | integer | Page number (starts at 0) |
| order_by | string | `id`, `created`, `updated`, `due_date` (default: `created`) |
| reverse | boolean | Reverse order |
| subtasks | boolean | Include subtasks (default: excluded) |
| statuses[] | string[] | Filter by status names |
| include_closed | boolean | Include closed tasks (default: excluded) |
| include_timl | boolean | **NEW** -- Include Tasks in Multiple Lists (default: excluded) |
| assignees[] | string[] | Filter by assignee IDs |
| watchers[] | string[] | **NEW** -- Filter by watcher IDs |
| tags[] | string[] | Filter by tag names |
| due_date_gt | integer | Due date after (Unix ms) |
| due_date_lt | integer | Due date before (Unix ms) |
| date_created_gt | integer | Created after (Unix ms) |
| date_created_lt | integer | Created before (Unix ms) |
| date_updated_gt | integer | Updated after (Unix ms) |
| date_updated_lt | integer | Updated before (Unix ms) |
| custom_fields | string | JSON-encoded custom field filters |
| custom_items[] | integer[] | **NEW** -- Filter by Custom Task Type IDs. `0`=Task, `1`=Milestone, other=custom |
| custom_task_ids | boolean | Reference tasks by custom task ID |
| team_id | number | Required when `custom_task_ids=true` |
| include_markdown_description | boolean | **NEW** -- Return descriptions in Markdown |
| archived | boolean | Include archived tasks |

Response includes `last_page: boolean` -- use as pagination stop signal.

---

## Custom Task Types

**NEW FEATURE** -- Workspaces can define custom task types beyond the default "Task" and "Milestone".

```
GET /v2/team/{team_id}/custom_item   Get available Custom Task Types
```

- `custom_item_id: 0` = standard Task
- `custom_item_id: 1` = Milestone
- Other IDs = workspace-defined custom types

Use `custom_item_id` on CreateTask to specify the type. Use `custom_items[]` on GetTasks to filter.

---

## Custom Fields

```
GET    /v2/list/{list_id}/field                    Get field definitions + UUIDs
POST   /v2/task/{task_id}/field/{field_id}         Set value: {value: ...}
DELETE /v2/task/{task_id}/field/{field_id}         Remove value
```

### Field Response Schema

Each field includes: `id`, `name`, `type`, `type_config`, `date_created`, `hide_from_guests`.

`type_config` varies by type and may include: `options` (for dropdowns/labels), `default`, `precision`, `currency_type`, `placeholder`, `start`/`end` (for progress), `count`/`code_point` (for emoji), `tracking` (for automatic progress), `complete_on`.

### Value Formats by Type

| Type | Value |
|------|-------|
| text, short_text | string |
| number, currency | number |
| checkbox | boolean |
| drop_down | option UUID string |
| labels | string[] of option UUIDs |
| date | Unix ms integer |
| url, email, phone | string |
| emoji | integer 0..count |
| manual_progress | {"current": number} |
| users | {"add": [uid], "rem": [uid]} |
| tasks | {"add": [tid], "rem": [tid]} |

**Cannot create custom fields via API -- must be created in ClickUp UI.**
**Free plan: 60 lifetime custom field writes per workspace.**

---

## Spaces, Folders, Lists

```
GET/POST        /v2/team/{team_id}/space
GET/PUT/DELETE  /v2/space/{space_id}
GET/POST        /v2/space/{space_id}/folder
GET/PUT/DELETE  /v2/folder/{folder_id}
GET/POST        /v2/folder/{folder_id}/list      (in folder)
GET/POST        /v2/space/{space_id}/list        (folderless)
GET/PUT/DELETE  /v2/list/{list_id}
```

---

## Comments

```
POST /v2/task/{task_id}/comment            Create comment
GET  /v2/task/{task_id}/comment            Get comments (cursor-paged, 25/page)
GET  /v2/task/{task_id}/comment/threaded   Threaded comments (flat array)
PUT  /v2/comment/{comment_id}              Update comment
DELETE /v2/comment/{comment_id}            Delete comment
POST/GET /v2/list/{list_id}/comment        List comments
POST/GET /v2/view/{view_id}/comment        Chat view comments
```

### Chat View Comments (GET /v2/view/{view_id}/comment)

Query params: `start` (Unix ms timestamp), `start_id` (comment ID for pagination).
Returns most recent 25 comments if no pagination params given.
Response includes: `id`, `comment`, `comment_text`, `user`, `resolved`, `reactions`, `date`, `reply_count`.

Comment pagination: cursor-based with `start_id` + `start` params.

---

## Docs API (v3)

**NEW** -- Access and search Docs in your Workspace.

```
GET /v3/workspaces/{workspaceId}/docs    Search/list Docs
```

Returns Docs you have access to. Part of the emerging v3 API.

---

## Webhooks

```
GET    /v2/team/{team_id}/webhook          List webhooks (created by auth user)
POST   /v2/team/{team_id}/webhook          Create webhook
PUT    /v2/webhook/{webhook_id}            Update (reactivate: {status: "active"})
DELETE /v2/webhook/{webhook_id}            Delete webhook
```

Create body: `{endpoint, events, space_id?, folder_id?, list_id?, task_id?}`
Use `"events": ["*"]` for all. Response includes `webhook.secret` (shown once only).

**Only one location per hierarchy level per webhook.** The most specific location applies (e.g., if both space_id and list_id are given, events filter to the list).

### Webhook Health (in GET response)

```json
"health": {
  "status": "failing",
  "fail_count": 5
}
```

### 28 Event Types

**Task events:**
- taskCreated, taskUpdated, taskDeleted
- taskPriorityUpdated, taskStatusUpdated, taskAssigneeUpdated
- taskDueDateUpdated, taskTagUpdated, taskMoved
- taskCommentPosted, taskCommentUpdated
- taskTimeEstimateUpdated, taskTimeTrackedUpdated

**List events:** listCreated, listUpdated, listDeleted

**Folder events:** folderCreated, folderUpdated, folderDeleted

**Space events:** spaceCreated, spaceUpdated, spaceDeleted

**Goal/Target events:** goalCreated, goalUpdated, goalDeleted, keyResultCreated, keyResultUpdated, keyResultDeleted

**Note:** `taskTimeEstimateUpdated` and `taskTimeTrackedUpdated` are the current event names (replacing older `taskTimeTracked` naming in some older docs).

### Webhook Security

```python
import hashlib, hmac

def verify(raw_body: bytes, x_signature: str, secret: str) -> bool:
    return hmac.compare_digest(
        hmac.new(secret.encode(), raw_body, hashlib.sha256).hexdigest(),
        x_signature
    )
```

Header: `X-Signature` (hex-encoded). Compute on raw bytes before JSON parse.

**Important notes:**
- No dedicated IP address for webhooks -- ClickUp uses domain name + dynamic addressing
- Non-SSL (http) may not be supported in future -- use https
- Use `{{webhook_id}}:{{history_item_id}}` as idempotency key
- `history_items[x].user.id` is integer, not string
- Unset booleans (e.g., Custom Field checkmarks) may be NULL not false
- Custom Field values not normalized -- cast to correct type

**Reliability:** 7-second response timeout. 5 retries. 401/410 = instant suspension. fail_count >= 100 = suspension. No replay queue.

### Automation Call Webhook

ClickUp automations can trigger external webhooks. Separate payload format from standard webhooks -- see ClickUp docs for automation webhook payload details.

---

## Time Tracking

```
GET    /v2/team/{team_id}/time_entries                 Get entries (date range)
POST   /v2/team/{team_id}/time_entries                 Create entry
GET    /v2/team/{team_id}/time_entries/{timer_id}      Get single entry
PUT    /v2/team/{team_id}/time_entries/{timer_id}      Update entry
DELETE /v2/team/{team_id}/time_entries/{timer_id}      Delete entry
POST   /v2/team/{team_id}/time_entries/start           Start timer
POST   /v2/team/{team_id}/time_entries/stop            Stop timer
GET    /v2/task/{task_id}/time                         Get task time entries (legacy)
POST   /v2/task/{task_id}/time                         Create task time entry (legacy)
```

Create body: `{tid: task_id, start: unix_ms, duration: ms}`. Negative duration = running timer.

### Time Entries Query Params (GET /v2/team/{id}/time_entries)

| Parameter | Type | Description |
|-----------|------|-------------|
| start_date | number | Unix ms -- filter start |
| end_date | number | Unix ms -- filter end |
| assignee | number | user_id (comma-separated for multiple). Owner/Admin only |
| include_task_tags | boolean | **NEW** -- Include task tags in response |
| include_location_names | boolean | **NEW** -- Include List/Folder/Space names |
| include_approval_history | boolean | **NEW** -- Include approval status change history |
| include_approval_details | boolean | **NEW** -- Include approver ID, approved time, approvers list |
| space_id | number | Filter to space (mutually exclusive with folder/list/task) |
| folder_id | number | Filter to folder |
| list_id | number | Filter to list |
| task_id | string | Filter to task |
| is_billable | boolean | **NEW** -- Filter billable/non-billable entries |
| custom_task_ids | boolean | Reference tasks by custom task ID |
| team_id | number | Required when custom_task_ids=true |

Default: returns last 30 days for authenticated user only.

### Time Entry Response Fields

Includes: `id`, `task` (with `custom_id`, `custom_type`), `wid`, `user`, `billable`, `start`, `end`, `duration`, `description`, `tags`, `source`, `at`, `task_location` (list_id, folder_id, space_id + names), `task_tags`, `task_url`, `approval_id`, `approval` (with status, approvers, history).

---

## Audit Logs (v3 -- Enterprise Only)

**NEW** -- Query workspace-level audit logs.

```
POST /v3/workspaces/{workspace_id}/auditlogs
```

Request body:
```json
{
  "applicability": "auth-and-security",
  "filter": {
    "workspaceId": "123456",
    "userId": ["182"],
    "userEmail": ["user@company.com"],
    "eventType": ["CHANGE_PASSWORD"],
    "eventStatus": "failed",
    "startTime": 1718754539000,
    "endTime": 1727221739000
  },
  "pagination": {
    "pageRows": 10,
    "pageTimestamp": 1727221739000,
    "pageDirection": "before"
  }
}
```

**Applicability types:** `agent-settings-activity`, `auth-and-security`, `custom-fields`, `hierarchy-activity`, `user-activity`, `other-activity`

**Event types (auth-and-security):** USER_LOGIN, USER_LOGOUT, CHANGE_2FA, CHANGE_EMAIL, CHANGE_PASSWORD, JOIN_WORKSPACE, LEAVE_WORKSPACE, RESET_PASSWORD, ROLE_CHANGE, SCIM_PROVISION/DEPROVISION/UPDATE, SECURE_LOGIN_EMAIL_SENT, ADVANCED_SETTINGS_UPDATED, CHANGE_2FA_POLICY, CHANGE_ROLE_PERMISSIONS, CHANGE_SSO_POLICY, CHANGE_USER_ROLE, CUSTOM_ROLE_CREATED/UPDATED/DELETED, TEAM_CREATED/DELETED/EDITED/MEMBER_ADDED/MEMBER_REMOVED, INVITE_TO_WORKSPACE, REMOVE_FROM_WORKSPACE, SCIM_GROUP_CREATED/DELETED/UPDATED, SSO_CONFIG_UPDATED

**Event types (hierarchy/tasks):** TASK_CREATED, TASK_ARCHIVED, TASK_DELETED, TASK_RESTORED, TASK_UNARCHIVED, TASK_STATUS_CHANGED, TASK_PRIORITY_CHANGED, TASK_ASSIGNEES_CHANGED, TASK_CUSTOM_FIELD_VALUES_CHANGED

**Event types (custom-fields):** FIELD_CONVERTED, FIELD_CREATED, FIELD_DROPDOWN_OPTIONS_CREATED/REMOVED/UPDATED, FIELD_DUPLICATED, FIELD_GROUP_MEMBER_PERMISSION_REMOVED/SET, FIELD_LABEL_OPTIONS_CREATED/REMOVED/UPDATED, FIELD_LOCATION_ADDED/REMOVED/UPDATED, FIELD_MEMBER_PERMISSION_REMOVED/SET, FIELD_MERGED, FIELD_PERMANENTLY_REMOVED, FIELD_REMOVED, FIELD_RESTORED, FIELD_UPDATED

**Event statuses:** success, failed, warn, skipped, started, completed, error, system_error

---

## Other Endpoints

```
Tags:         GET/POST /v2/space/{id}/tag, POST/DELETE /v2/task/{id}/tag/{name}
Goals:        GET/POST /v2/team/{id}/goal, PUT/DELETE /v2/goal/{id}
Key Results:  POST /v2/goal/{id}/key_result, PUT/DELETE /v2/key_result/{id}
Views:        GET /v2/team|space|folder|list/{id}/view, GET /v2/view/{id}/task
Checklists:   POST /v2/task/{id}/checklist, POST /v2/checklist/{id}/checklist_item
Dependencies: POST/DELETE /v2/task/{id}/dependency
Attachments:  POST /v2/task/{id}/attachment (multipart/form-data)
Members:      GET /v2/team/{id}/member, POST/DELETE /v2/task/{id}/member
Users:        GET /v2/team/{id}/user, POST /v2/team/{id}/user (invite)
Guests:       Enterprise -- add/remove guests at workspace/space/folder/list/task level
User Groups:  GET/POST /v2/team/{id}/group, PUT/DELETE /v2/group/{id}
Roles:        GET /v2/team/{id}/customroles
Templates:    GET /v2/team/{id}/task_template, POST /v2/list/{id}/taskTemplate/{template_id}
Shared:       GET /v2/team/{id}/shared
```

### MCP Server (AI Integration)

ClickUp provides an official MCP Server for connecting AI tools directly to ClickUp. See https://developer.clickup.com/ for details.

---

## Error Response Format

```json
{"err": "Human readable message", "ECODE": "MACHINE_CODE"}
```

v3 error format:
```json
{
  "status": 400,
  "message": "Generic error message",
  "trace_id": 123456789,
  "timestamp": 1671534256138
}
```

| Code | ECODE | Meaning |
|------|-------|---------|
| 401 | OAUTH_019/021/077 | Token revoked -- re-auth required |
| 403 | OAUTH_023/026/027 | Workspace not authorized |
| 429 | OAUTH_RATELIMIT | Rate limit exceeded |
| Any | OAUTH_171 | Duplicate webhook endpoint |
| Any | FIELD_375 | Invalid custom field value |

---

## Critical Gotchas

1. Personal token: NO Bearer prefix (`Authorization: pk_...`)
2. All dates: Unix milliseconds (not seconds)
3. Assignees: flat array on CREATE, `{add, rem}` object on UPDATE
4. Custom fields: separate endpoint, must pre-fetch UUID
5. Free plan: 60 custom field writes lifetime
6. No bulk task update endpoint
7. `team_id` = Workspace (not user group) -- same ID used as `workspace_id` in v3
8. Comment pagination: cursor-based (not page number)
9. Webhook: raw body for HMAC, hex only, secret shown once
10. Attachment: multipart/form-data (not JSON)
11. Status names: case-sensitive
12. Folderless lists: `/space/{id}/list` not `/folder/{id}/list`
13. **NEW**: `custom_item_id` on tasks -- null = "Task", 1 = Milestone, other = custom type
14. **NEW**: Webhook health object in GET response -- monitor `fail_count`
15. **NEW**: No dedicated webhook IP address -- use HMAC verification, not IP allowlisting
16. **NEW**: Time entries default to last 30 days for auth user only -- use `assignee` param for others
17. **NEW**: v3 endpoints use `workspace_id` not `team_id` in path -- same numeric value
