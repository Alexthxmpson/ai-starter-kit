# ClickUp API v2 — Knowledge Map

**Research Date:** 2026-03-18

```
ClickUp API v2
├── AUTHENTICATION
│   ├── Personal Token (pk_)
│   │   ├── Never expires
│   │   ├── Header: Authorization: pk_xxx (no Bearer)
│   │   └── Use: internal/personal automation
│   └── OAuth 2.0
│       ├── Authorization Code flow
│       ├── Auth URL: app.clickup.com/api
│       ├── Token URL: api.clickup.com/api/v2/oauth/token
│       ├── Header: Authorization: Bearer {token}
│       ├── No granular scopes (workspace-level)
│       └── Currently no expiry (subject to change)
│
├── DATA MODEL (Hierarchy)
│   ├── Workspace [team_id, numeric]
│   │   ├── Space [space_id, numeric]
│   │   │   ├── Folder [folder_id, numeric]
│   │   │   │   └── List [list_id, numeric]
│   │   │   │       └── Task [task_id, alphanumeric "9hz"]
│   │   │   │           └── Subtask [task with parent field]
│   │   │   └── List (folderless) [list_id, numeric]
│   │   └── Features: time_tracking, tags, sprints, etc.
│   └── ID Types: workspace/space/folder/list = integer; task = short string
│
├── TASKS
│   ├── CRUD
│   │   ├── CREATE: POST /list/{id}/task
│   │   │   └── Assignees: flat array [183, 224]
│   │   ├── READ: GET /task/{id}
│   │   ├── UPDATE: PUT /task/{id}
│   │   │   └── Assignees: {"add": [183], "rem": []}
│   │   └── DELETE: DELETE /task/{id}
│   ├── List Queries
│   │   ├── List-scoped: GET /list/{id}/task (page=0, 100/page)
│   │   ├── Workspace-scoped: GET /team/{id}/task
│   │   └── Pagination signal: last_page boolean
│   ├── Filtering
│   │   ├── statuses[], assignees[], tags[]
│   │   ├── due_date_gt/lt, date_created_gt/lt, date_updated_gt/lt
│   │   ├── subtasks, include_closed, include_timl
│   │   └── custom_fields (JSON filter array)
│   ├── Subtasks: parent field = task_id; same list as parent
│   └── Fields
│       ├── Dates: Unix MILLISECONDS (not seconds!)
│       ├── Priority: 1=Urgent, 2=High, 3=Normal, 4=Low
│       ├── Status: case-sensitive string matching list statuses
│       └── markdown_content overrides description if both sent
│
├── CUSTOM FIELDS
│   ├── 17 Types
│   │   ├── text, short_text → string value
│   │   ├── number, currency → numeric value
│   │   ├── checkbox → boolean
│   │   ├── drop_down → option UUID string
│   │   ├── labels → array of option UUIDs
│   │   ├── date → Unix ms integer
│   │   ├── url, email, phone → string
│   │   ├── emoji (rating) → integer 0..count
│   │   ├── manual_progress → {current: number}
│   │   ├── automatic_progress → READ ONLY
│   │   ├── users (people) → {add: [uid], rem: [uid]}
│   │   ├── tasks (relationship) → {add: [tid], rem: [tid]}
│   │   └── location → {location: {lat, lng}, formatted_address}
│   ├── Workflow
│   │   ├── 1. Create field in UI
│   │   ├── 2. GET /list/{id}/field → get UUIDs
│   │   ├── 3. POST /task/{id}/field/{field_id} → set value
│   │   └── 4. Task responses include custom_fields array
│   ├── Custom field IDs are UUIDs — must be pre-fetched, never guessed
│   └── Free plan: 60 lifetime custom field writes (per workspace, never resets)
│
├── SPACES / FOLDERS / LISTS
│   ├── Spaces: GET/POST/PUT/DELETE /team/{id}/space and /space/{id}
│   ├── Folders: GET/POST/PUT/DELETE /space/{id}/folder and /folder/{id}
│   ├── Lists (in folder): GET/POST /folder/{id}/list
│   ├── Lists (folderless): GET/POST /space/{id}/list
│   └── Statuses: must have at least 1 "open" + 1 "closed" type
│
├── COMMENTS
│   ├── Task comments: POST/GET /task/{id}/comment
│   ├── Threaded comments: GET /task/{id}/comment/threaded (flat array)
│   ├── List comments: POST/GET /list/{id}/comment
│   ├── Chat view: POST/GET /view/{id}/comment
│   ├── Update: PUT /comment/{id}
│   ├── Delete: DELETE /comment/{id}
│   └── Pagination: cursor-based (start_id + start params, 25/page)
│
├── WEBHOOKS
│   ├── CRUD: GET/POST /team/{id}/webhook, PUT/DELETE /webhook/{id}
│   ├── 27 Event Types
│   │   ├── Task: Created, Updated, Deleted, StatusUpdated, PriorityUpdated,
│   │   │         AssigneeUpdated, DueDateUpdated, TagUpdated, Moved,
│   │   │         CommentPosted, CommentUpdated, TimeTracked
│   │   ├── List: Created, Updated, Deleted
│   │   ├── Folder: Created, Updated, Deleted
│   │   ├── Space: Created, Updated, Deleted
│   │   └── Goal/KR: Created, Updated, Deleted (×2)
│   ├── Payload: {webhook_id, event, task_id, history_items: [{before, after}]}
│   ├── Security: HMAC-SHA256, X-Signature header (hex), raw body
│   ├── Reliability
│   │   ├── 7-second response timeout
│   │   ├── 5 retries per event
│   │   ├── fail_count ≥ 100 → suspension
│   │   ├── 401/410 response → instant suspension
│   │   └── Reactivate: PUT with {status: "active"}
│   └── Secret: shown only once at creation — store immediately
│
├── RATE LIMITS
│   ├── Per token, not per IP
│   ├── Free/Unlimited/Business: 100 req/min
│   ├── Business Plus: 1,000 req/min
│   ├── Enterprise: 10,000 req/min
│   ├── Headers: X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset
│   ├── 429 response: use X-RateLimit-Reset (NOT Retry-After)
│   └── Backoff: exponential with jitter
│
├── ADVANCED FEATURES
│   ├── Time Tracking: GET/POST/PATCH/DELETE /team/{id}/time_entries
│   │   └── Negative duration = running timer
│   ├── Goals: GET/POST/PUT/DELETE /team/{id}/goal + /goal/{id}/key_result
│   ├── Views: GET /space|folder|list|team/{id}/view → GET /view/{id}/task
│   ├── Checklists: POST /task/{id}/checklist → /checklist/{id}/checklist_item
│   ├── Dependencies: POST/DELETE /task/{id}/dependency
│   │   ├── depends_on: task that blocks this task
│   │   └── dependency_of: task blocked by this task
│   ├── Tags: GET /space/{id}/tag → POST /task/{id}/tag/{name}
│   ├── Attachments: POST /task/{id}/attachment (multipart/form-data ONLY)
│   └── Members: GET /team/{id}/member, /list/{id}/member, /task/{id}/member
│
└── AI AUTOMATION PATTERNS
    ├── ClickUp as Task Queue (poll status → AI process → update status)
    ├── NL → Structured Task (Claude extracts fields → POST task)
    ├── Webhook → AI Trigger (@ai in comment → AI responds)
    ├── AI Status Routing (classify description → move to correct status)
    ├── Custom Fields for AI Metadata (AI Score, AI Category, AI Summary)
    ├── Incremental Sync (date_updated_gt filter → only changed tasks)
    └── Batch Processing (async aiohttp + rate limit proactive throttle)
```

---

## Endpoint Pattern Summary

```
Base: https://api.clickup.com/api/v2

Workspace:      /team                           GET → list workspaces
Space:          /team/{id}/space                GET/POST
                /space/{id}                     GET/PUT/DELETE
Folder:         /space/{id}/folder              GET/POST
                /folder/{id}                    GET/PUT/DELETE
List:           /folder/{id}/list               GET/POST   (in folder)
                /space/{id}/list                GET/POST   (folderless)
                /list/{id}                      GET/PUT/DELETE
Task:           /list/{id}/task                 GET/POST
                /task/{id}                      GET/PUT/DELETE
                /team/{id}/task                 GET        (workspace-wide)
Custom Field:   /list/{id}/field                GET
                /task/{id}/field/{field_id}     POST/DELETE
Comment:        /task/{id}/comment              GET/POST
                /task/{id}/comment/threaded     GET
                /comment/{id}                   PUT/DELETE
Webhook:        /team/{id}/webhook              GET/POST
                /webhook/{id}                   PUT/DELETE
Time:           /team/{id}/time_entries         GET/POST
                /team/{id}/time_entries/{id}    PATCH/DELETE
Goals:          /team/{id}/goal                 GET/POST
                /goal/{id}                      GET/PUT/DELETE
                /goal/{id}/key_result           POST
Views:          /{level}/{id}/view              GET/POST
                /view/{id}                      GET/PUT/DELETE
                /view/{id}/task                 GET
Tags:           /space/{id}/tag                 GET/POST
                /task/{id}/tag/{name}           POST/DELETE
Members:        /team/{id}/member               GET
                /task/{id}/member               GET/POST/DELETE
Checklist:      /task/{id}/checklist            POST
                /checklist/{id}                 PUT/DELETE
                /checklist/{id}/checklist_item  POST
                /checklist/{id}/checklist_item/{item_id} PUT/DELETE
Dependency:     /task/{id}/dependency           POST/DELETE
Attachment:     /task/{id}/attachment           POST (multipart)
OAuth:          /oauth/token                    POST
```
