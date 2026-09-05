# ClickUp API v2 — Master Synthesis
## Complete Technical Reference for AI Automation

**Research Date:** 2026-03-18
**Coverage:** Authentication, Data Model, Tasks, Custom Fields, Lists, Spaces, Comments, Webhooks, Rate Limits, AI Integration Patterns
**Source Authority:** Official ClickUp Developer Docs (developer.clickup.com) + community research
**Round 1 Word Count:** ~33,000 words across 5 research documents

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Background & API Overview](#2-background--api-overview)
3. [Research Methodology](#3-research-methodology)
4. [Key Findings — Authentication & Data Model](#4-key-findings--authentication--data-model)
5. [Key Findings — Tasks & Custom Fields](#5-key-findings--tasks--custom-fields)
6. [Key Findings — Lists, Spaces & Advanced Features](#6-key-findings--lists-spaces--advanced-features)
7. [Key Findings — Comments & Webhooks](#7-key-findings--comments--webhooks)
8. [Key Findings — Rate Limits & AI Integration Patterns](#8-key-findings--rate-limits--ai-integration-patterns)
9. [Strategic Recommendations](#9-strategic-recommendations)
10. [Critical Gotchas & Edge Cases](#10-critical-gotchas--edge-cases)
11. [Quick Reference: All Endpoints](#11-quick-reference-all-endpoints)
12. [Conclusion](#12-conclusion)
13. [References](#13-references)

---

## 1. Executive Summary

ClickUp API v2 is a mature REST API providing programmatic access to the full ClickUp project management platform. This research synthesizes 5 deep-research documents covering 33,000+ words of technical documentation.

**Key facts for AI automation:**
- **Base URL:** `https://api.clickup.com/api/v2`
- **Auth:** Personal token (`pk_` prefix) for internal use; OAuth 2.0 for multi-user apps
- **Rate limits:** 100 req/min (Free/Unlimited/Business), 1,000/min (Business Plus), 10,000/min (Enterprise)
- **Hierarchy:** Workspace → Space → Folder → List → Task → Subtask
- **Webhooks:** 27 event types, HMAC-SHA256 verification, 7-second response window
- **Custom Fields:** 17 field types, must be created in UI first, no bulk update endpoint
- **Pagination:** 100 tasks/page (index-based), 25 comments/page (cursor-based)

**Critical limitation for AI automation:** No bulk task update endpoint exists. Each task/custom field update requires a separate API call. Plan batch processing with rate limiting from the start.

---

## 2. Background & API Overview

### API Versioning

ClickUp maintains two concurrent API versions:
- **v2** (`/api/v2/`): Stable production API. The focus of this document. All current SDKs and integrations use v2.
- **v3** (`/api/v3/`): In development. Improved consistency and standardized naming. Not production-ready for all endpoints.

**For all new integrations: use v2.** The v3 migration will require renaming `team_id` → `workspace_id` when it stabilizes.

### Base URL

```
https://api.clickup.com/api/v2
```

All requests are HTTPS-only. Standard HTTP verbs: GET, POST, PUT, DELETE. JSON for all request/response bodies. Always set `Content-Type: application/json` on POST/PUT requests (form-encoded not fully supported).

---

## 3. Research Methodology

**Round 1:** 5 parallel agents researched:
1. Authentication & Core Data Model (6,250 words)
2. Tasks & Custom Fields (6,633 words)
3. Lists, Spaces & Advanced Features (7,128 words)
4. Comments & Webhooks (6,555 words)
5. Rate Limits & AI Integration Patterns (6,806 words)

**Source evaluation composite: 4.8/5** — All sources passed the 3.0 minimum threshold.

**Convergence analysis:**
- VALIDATED (3+ sources agree): Rate limits, auth methods, hierarchy, task CRUD, pagination behavior
- CONTEXT-SPECIFIC: OAuth token vs personal token behavior nuances
- GAPS: ClickUp v3 Docs API (limited v2 coverage), automations API (not public in v2)

---

## 4. Key Findings — Authentication & Data Model

### 4.1 Authentication Methods

ClickUp API v2 supports exactly **two** authentication methods:

#### Personal API Token

- **Format:** Always starts with `pk_` (e.g., `pk_4753994_XXXXX...`)
- **Header:** `Authorization: pk_YOUR_TOKEN` (NO "Bearer" prefix — this is unusual)
- **Expiry:** Never expires (until manually regenerated)
- **Use case:** Internal scripts, personal automation, server-side tools for your own workspace
- **How to get:** ClickUp Settings → Apps → API Token → Generate

```bash
curl -H "Authorization: pk_YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     https://api.clickup.com/api/v2/team
```

#### OAuth 2.0

- **Flow:** Authorization Code grant type
- **Authorization URL:** `https://app.clickup.com/api?client_id={id}&redirect_uri={uri}`
- **Token URL:** `POST https://api.clickup.com/api/v2/oauth/token`
- **Token format:** `Authorization: Bearer {access_token}`
- **Expiry:** Currently **never expires** (this is documented but subject to change)
- **Scopes:** No granular scopes — token inherits the user's workspace-level permissions
- **Use case:** Public apps, multi-tenant SaaS, apps serving other users

```python
# OAuth token exchange
response = requests.post(
    "https://api.clickup.com/api/v2/oauth/token",
    json={
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "code": AUTH_CODE_FROM_REDIRECT
    }
)
access_token = response.json()["access_token"]
```

**Choosing the right method:**

| Scenario | Method |
|----------|--------|
| Internal automation, personal scripts | Personal Token |
| Multi-tenant SaaS, public app | OAuth 2.0 |
| Testing/prototyping | Personal Token |

### 4.2 Core Data Model

ClickUp uses a strict 6-level hierarchy:

```
Workspace (team_id in v2)
  └── Space (space_id)
        ├── Folder (folder_id)
        │     └── List (list_id)
        │           └── Task (task_id)
        │                 └── Subtask (task_id, parent != null)
        └── List [Folderless] (list_id)
```

**ID format reference:**

| Level | ID Field | Type | Example |
|-------|----------|------|---------|
| Workspace | `team_id` | Numeric integer | `12345678` |
| Space | `space_id` | Numeric integer | `87654321` |
| Folder | `folder_id` | Numeric integer | `11223344` |
| List | `list_id` | Numeric integer | `99887766` |
| Task | `task_id` | Short alphanumeric string | `"9hz"` |

**Critical naming trap:** In v2, `team_id` = Workspace ID (legacy naming). `group_id` = User Group ID. These are different things.

**v2 vs v3 terminology:**

| v2 Term | v3 Term |
|---------|---------|
| `team_id` | `workspace_id` |
| Team | Workspace |
| Space | Space (unchanged) |

### 4.3 Permissions Model

| Role | Numeric Value |
|------|--------------|
| Owner | 1 |
| Admin | 2 |
| Member | 3 |
| Guest | 4 (Enterprise only) |

No granular OAuth scopes in v2 — the token inherits the user's role permissions.

**Get all workspaces:**
```bash
GET https://api.clickup.com/api/v2/team
```

---

## 5. Key Findings — Tasks & Custom Fields

### 5.1 Task CRUD

#### Create Task
```
POST /v2/list/{list_id}/task
```

Only `name` is required. Key fields:

| Field | Type | Notes |
|-------|------|-------|
| `name` | string | **Required** |
| `description` | string | Plain text |
| `markdown_content` | string | Markdown (overrides description if both sent) |
| `assignees` | integer[] | **Flat array** of user IDs on CREATE |
| `status` | string | Must match status name in list (case-sensitive) |
| `priority` | integer | 1=Urgent, 2=High, 3=Normal, 4=Low, null=none |
| `due_date` | integer | Unix timestamp in **milliseconds** |
| `start_date` | integer | Unix timestamp in **milliseconds** |
| `time_estimate` | integer | Duration in **milliseconds** |
| `parent` | string | Task ID = creates subtask |
| `custom_fields` | array | `[{id, value}]` — set on creation |
| `check_required_custom_fields` | boolean | Enforce required fields on creation |

#### Update Task
```
PUT /v2/task/{task_id}
```

**CRITICAL DIFFERENCE:** Assignees on update use add/remove object, NOT flat array:
```python
# CREATE: flat array
"assignees": [183, 224]

# UPDATE: add/remove object
"assignees": {"add": [182], "rem": [183]}
```

**Custom fields cannot be updated via PUT /task/{task_id}.** Use the dedicated field endpoint instead.

#### Get Task
```
GET /v2/task/{task_id}?include_subtasks=true
```

#### Delete Task
```
DELETE /v2/task/{task_id}
```
Returns 204 No Content on success.

#### Get Tasks (List-scoped, paginated)
```
GET /v2/list/{list_id}/task
```

Key query params: `page` (0-indexed), `order_by`, `reverse`, `subtasks`, `statuses[]`, `include_closed`, `assignees[]`, `due_date_gt`, `due_date_lt`, `date_updated_gt`, `include_timl`, `tags[]`, `custom_fields`

Response includes `last_page: boolean` — use this as the stop signal, NOT item count.

#### Get Tasks (Workspace-scoped)
```
GET /v2/team/{team_id}/task
```

Supports `space_ids[]`, `project_ids[]`, `list_ids[]` for filtering across the workspace.

### 5.2 Subtasks

Subtasks are tasks with `parent` field set. Same endpoints as regular tasks. Rules:
- Parent must be in the same list
- Nested subtasks supported (subtask of a subtask)
- Cannot convert subtask to top-level task via `parent: null` on Update

### 5.3 Task Pagination

```python
def get_all_tasks(client, list_id):
    all_tasks = []
    page = 0
    while True:
        response = client.get(f"/list/{list_id}/task", params={"page": page, "include_closed": True})
        tasks = response.get("tasks", [])
        all_tasks.extend(tasks)
        if response.get("last_page", True) or not tasks:
            break
        page += 1
    return all_tasks
```

### 5.4 Custom Fields

**Workflow:** Create in UI → Get IDs via API → Set values via API

**17 custom field types:**

| API Type | Value Format |
|----------|-------------|
| `text` / `short_text` | string |
| `number` / `currency` | number |
| `checkbox` | boolean |
| `drop_down` | UUID string of option |
| `labels` | string[] of option UUIDs |
| `date` | Unix ms integer |
| `url` / `email` / `phone` | string |
| `emoji` (rating) | integer 0 to count |
| `manual_progress` | `{"current": number}` |
| `automatic_progress` | Read-only — cannot set |
| `users` (people) | `{"add": [uid], "rem": [uid]}` |
| `tasks` (relationship) | `{"add": [tid], "rem": [tid]}` |
| `location` | `{location: {lat, lng}, formatted_address}` |

**Get custom fields for a list:**
```
GET /v2/list/{list_id}/field
```

**Set custom field value:**
```
POST /v2/task/{task_id}/field/{field_id}
Body: {"value": <value_per_type_above>}
```

**Remove custom field value:**
```
DELETE /v2/task/{task_id}/field/{field_id}
```

**CRITICAL:** Custom field IDs are UUIDs. You cannot guess them — always pre-fetch with `GET /list/{list_id}/field` and cache.

**Free Forever plan limit:** 60 lifetime custom field writes. Use Business or higher for automation.

---

## 6. Key Findings — Lists, Spaces & Advanced Features

### 6.1 Spaces API

```
GET /team/{team_id}/space            # List all spaces
POST /team/{team_id}/space           # Create space
PUT /space/{space_id}                # Update space
DELETE /space/{space_id}             # Delete space
```

Space features object controls available capabilities:
```json
{
  "features": {
    "due_dates": {"enabled": true},
    "time_tracking": {"enabled": true},
    "tags": {"enabled": true},
    "time_estimates": {"enabled": true},
    "checklists": {"enabled": true},
    "custom_fields": {"enabled": true},
    "remap_dependencies": {"enabled": false},
    "dependency_warning": {"enabled": true},
    "portfolios": {"enabled": false},
    "milestones": {"enabled": false},
    "sprints": {"enabled": false},
    "emails": {"enabled": false},
    "native_automations": {"enabled": true}
  }
}
```

### 6.2 Folders API

```
GET /space/{space_id}/folder         # List folders
POST /space/{space_id}/folder        # Create folder
PUT /folder/{folder_id}              # Update folder
DELETE /folder/{folder_id}           # Delete folder
```

### 6.3 Lists API

```
GET /folder/{folder_id}/list         # Lists in folder
GET /space/{space_id}/list           # Folderless lists
POST /folder/{folder_id}/list        # Create list in folder
POST /space/{space_id}/list          # Create folderless list
PUT /list/{list_id}                  # Update list
DELETE /list/{list_id}               # Delete list
```

**Key list fields:** `name`, `content`, `due_date`, `priority`, `assignee`, `status`, `override_statuses`

### 6.4 Time Tracking (v2.0)

Time Tracking 2.0 endpoints (recommended over legacy):
```
GET /team/{team_id}/time_entries     # Get entries (filter by dates, user, task)
POST /team/{team_id}/time_entries    # Create entry
PATCH /team/{team_id}/time_entries/{id}  # Update entry
DELETE /team/{team_id}/time_entries/{id} # Delete entry
```

**Key note:** Negative `duration` value = currently running timer.

### 6.5 Tags API

```
GET /space/{space_id}/tag            # Get space tags
POST /space/{space_id}/tag           # Create tag
PUT /tag/{tag_name}                  # Update tag
DELETE /space/{space_id}/tag/{tag_name}  # Delete tag
POST /task/{task_id}/tag/{tag_name}  # Add tag to task
DELETE /task/{task_id}/tag/{tag_name}  # Remove tag from task
```

### 6.6 Goals API

```
GET /team/{team_id}/goal             # Get goals
POST /team/{team_id}/goal            # Create goal
PUT /goal/{goal_id}                  # Update goal
DELETE /goal/{goal_id}               # Delete goal
POST /goal/{goal_id}/key_result      # Add key result
PUT /key_result/{key_result_id}      # Update key result
DELETE /key_result/{key_result_id}   # Delete key result
```

Key result types: `number`, `currency`, `boolean`, `percentage`, `automatic`

### 6.7 Views API

```
GET /space/{space_id}/view           # Space views
GET /folder/{folder_id}/view         # Folder views
GET /list/{list_id}/view             # List views
GET /team/{team_id}/view             # Workspace views (Everything Level)
POST /space/{space_id}/view          # Create view
GET /view/{view_id}/task             # Get tasks in view
```

View types: `list`, `board`, `calendar`, `table`, `gantt`, `activity`, `map`, `conversation`, `workload`

Note: Docs views and Whiteboard views are not accessible via the v2 Views API.

### 6.8 Checklists API

```
POST /task/{task_id}/checklist                       # Create checklist
PUT /checklist/{checklist_id}                        # Update checklist
DELETE /checklist/{checklist_id}                     # Delete checklist
POST /checklist/{checklist_id}/checklist_item        # Add checklist item
PUT /checklist/{checklist_id}/checklist_item/{item_id}  # Update item
DELETE /checklist/{checklist_id}/checklist_item/{item_id}  # Delete item
```

### 6.9 Dependencies API

```
POST /task/{task_id}/dependency      # Add dependency
DELETE /task/{task_id}/dependency    # Remove dependency
```

Body fields:
- `depends_on`: task_id that BLOCKS the current task (task waits on this)
- `dependency_of`: task_id that is BLOCKED by the current task

### 6.10 Attachments API

```
POST /task/{task_id}/attachment     # Upload attachment (multipart/form-data)
```

**Must use multipart/form-data** — do NOT set `Content-Type: application/json`.

### 6.11 Members API

```
GET /team/{team_id}/member          # Workspace members
GET /list/{list_id}/member          # List members
GET /task/{task_id}/member          # Task members
POST /task/{task_id}/member         # Add task member
DELETE /task/{task_id}/member/{user_id}  # Remove task member
```

---

## 7. Key Findings — Comments & Webhooks

### 7.1 Comments API

**Task comments:**
```
POST /task/{task_id}/comment        # Create comment
GET /task/{task_id}/comment         # Get comments (cursor-paginated, 25/page)
GET /task/{task_id}/comment/threaded  # Get threaded comments (flat array)
PUT /comment/{comment_id}           # Update comment
DELETE /comment/{comment_id}        # Delete comment
```

**List comments:**
```
POST /list/{list_id}/comment        # Create list comment
GET /list/{list_id}/comment         # Get list comments
```

**Chat view comments:**
```
POST /view/{view_id}/comment        # Create chat comment
GET /view/{view_id}/comment         # Get chat comments
```

**Comment pagination** is cursor-based (NOT page-based):
```python
# First call: no params
comments = client.get(f"/task/{task_id}/comment")

# Subsequent calls: use last comment's id + date
params = {"start_id": last_comment_id, "start": last_comment_date}
```

### 7.2 Webhooks API

```
GET /team/{team_id}/webhook         # List webhooks
POST /team/{team_id}/webhook        # Create webhook
PUT /webhook/{webhook_id}           # Update webhook
DELETE /webhook/{webhook_id}        # Delete webhook
```

**Create webhook request:**
```json
{
  "endpoint": "https://your-server.com/clickup-webhook",
  "events": ["taskCreated", "taskStatusUpdated"],
  "space_id": 12345678,
  "list_id": null,
  "task_id": null
}
```

Use `"events": "*"` to subscribe to all events.

**Webhook response includes `secret`** — store it immediately. It is only shown once.

### 7.3 All 27 Webhook Event Types

| Domain | Events |
|--------|--------|
| Task | taskCreated, taskUpdated, taskDeleted, taskStatusUpdated, taskPriorityUpdated, taskAssigneeUpdated, taskDueDateUpdated, taskTagUpdated, taskMoved, taskCommentPosted, taskCommentUpdated, taskTimeTracked |
| List | listCreated, listUpdated, listDeleted |
| Folder | folderCreated, folderUpdated, folderDeleted |
| Space | spaceCreated, spaceUpdated, spaceDeleted |
| Goal/Key Result | goalCreated, goalUpdated, goalDeleted, goalKeyResultCreated, goalKeyResultUpdated, goalKeyResultDeleted |

**Note:** Older docs show `goalKeyResultCreated`; current API returns `keyResultCreated`. Verify from your own webhook object.

### 7.4 Webhook Payload Structure

```json
{
  "webhook_id": "7fa3ec74-69a8-4530-a251-8a13730bd204",
  "event": "taskStatusUpdated",
  "task_id": "9hx",
  "history_items": [
    {
      "id": "2800763136717140857",
      "type": 1,
      "date": "1566400646923",
      "field": "status",
      "parent_id": "159",
      "data": {
        "status_type": "open"
      },
      "source": null,
      "user": {"id": 183, "username": "John"},
      "before": {"status": "in progress", "color": "#d3d3d3", "type": "custom", "orderindex": "5.0"},
      "after": {"status": "Open", "color": "#d3d3d3", "type": "open", "orderindex": "4.0"}
    }
  ]
}
```

### 7.5 Webhook Security (HMAC-SHA256)

ClickUp sends an `X-Signature` header (hex-encoded HMAC-SHA256 of the raw body, using the webhook `secret` as key).

```python
import hashlib
import hmac

def verify_clickup_webhook(raw_body: bytes, signature: str, secret: str) -> bool:
    """Verify ClickUp webhook HMAC-SHA256 signature."""
    expected = hmac.new(
        secret.encode("utf-8"),
        raw_body,
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(expected, signature)
```

**Critical:** Compute HMAC on **raw bytes** before any JSON parsing. Always use constant-time comparison (`hmac.compare_digest`).

### 7.6 Webhook Reliability

- **Timeout:** 7 seconds. Respond immediately (200), process asynchronously.
- **Retries:** 5 retries per event, then dropped (no replay queue).
- **Suspension triggers:** `fail_count >= 100`, or your endpoint returns 401/410.
- **Reactivation:** `PUT /webhook/{webhook_id}` with `{"status": "active"}`.
- **Duplicate webhook error:** `OAUTH_171` — webhook already exists for that URL + location combination.

---

## 8. Key Findings — Rate Limits & AI Integration Patterns

### 8.1 Rate Limits by Plan

| Plan | Requests Per Minute (Per Token) |
|------|--------------------------------|
| Free Forever | 100 |
| Unlimited | 100 |
| Business | 100 |
| Business Plus | 1,000 |
| Enterprise | 10,000 |

Rate limits apply **per token**, not per IP. Multiple tokens from the same workspace each get their own limit.

### 8.2 Rate Limit Headers

Every response includes:
- `X-RateLimit-Limit`: Total limit for this window
- `X-RateLimit-Remaining`: Remaining requests
- `X-RateLimit-Reset`: Unix timestamp (seconds) when window resets

**No `Retry-After` header** — use `X-RateLimit-Reset` to calculate wait time:
```python
wait_seconds = int(reset_timestamp) - int(time.time()) + 2
```

### 8.3 Exponential Backoff Pattern

```python
class ClickUpClient:
    def __init__(self, api_token, max_retries=5):
        self.headers = {"Authorization": api_token, "Content-Type": "application/json"}
        self.max_retries = max_retries
        self.session = requests.Session()
        self.session.headers.update(self.headers)

    def request(self, method, endpoint, **kwargs):
        url = f"https://api.clickup.com/api/v2{endpoint}"
        for attempt in range(self.max_retries + 1):
            response = self.session.request(method, url, **kwargs)
            if response.status_code == 200:
                return response.json()
            elif response.status_code == 429:
                reset_at = response.headers.get("X-RateLimit-Reset")
                wait = max(1, int(reset_at) - int(time.time())) + 2 if reset_at else 60
                time.sleep(wait)
            elif response.status_code in (500, 502, 503):
                time.sleep(min(1.0 * (2 ** attempt), 64.0))
            else:
                response.raise_for_status()
```

### 8.4 AI Automation Integration Patterns

#### Pattern 1: ClickUp as AI Task Queue

```python
# Poll for tasks in specific status ("AI Review")
tasks = client.get("/list/{list_id}/task", params={
    "statuses[]": ["AI Review"],
    "include_closed": False
})
for task in tasks["tasks"]:
    # Process with AI
    ai_output = claude_client.analyze(task["description"])
    # Write result back as comment
    client.post(f"/task/{task['id']}/comment", data={
        "comment_text": f"AI Analysis:\n{ai_output}",
        "notify_all": False
    })
    # Update status
    client.put(f"/task/{task['id']}", data={"status": "Reviewed"})
```

#### Pattern 2: Natural Language → Structured Task

```python
def natural_language_to_task(text: str, list_id: str):
    """Use Claude to extract task fields from natural language, then create task."""
    extraction = claude_client.complete(f"""
    Extract task fields from: "{text}"
    Return JSON: name, description, priority (1-4), due_date (ISO), assignee_hint
    """)
    fields = json.loads(extraction)
    return client.post(f"/list/{list_id}/task", data=fields)
```

#### Pattern 3: Webhook → AI Trigger

```python
@app.post("/clickup-webhook")
async def handle_webhook(request: Request):
    body = await request.body()
    sig = request.headers.get("x-signature", "")
    if not verify_signature(body, sig, WEBHOOK_SECRET):
        raise HTTPException(401)

    event = json.loads(body)
    response_ok = JSONResponse({"received": True})

    # Process async after responding
    background_tasks.add_task(process_event, event)
    return response_ok

async def process_event(event):
    if event["event"] == "taskCommentPosted":
        for item in event.get("history_items", []):
            comment_text = item.get("comment", {}).get("comment_text", "")
            if "@ai" in comment_text.lower():
                await trigger_ai_response(event["task_id"], comment_text)
```

#### Pattern 4: AI Status Routing

```python
# Automatically route tasks to appropriate status based on AI analysis
def ai_route_task(task_id: str):
    task = client.get(f"/task/{task_id}")
    description = task.get("description", "")

    routing = claude_client.classify(description, categories=[
        "needs_review", "ready_to_start", "blocked", "completed"
    ])

    status_map = {
        "needs_review": "Review",
        "ready_to_start": "Open",
        "blocked": "Blocked",
        "completed": "Done"
    }

    client.put(f"/task/{task_id}", data={"status": status_map[routing]})
```

#### Pattern 5: Custom Fields for AI Metadata

```python
# Store AI-generated scores in custom fields
field_ids = get_custom_field_ids(list_id)

client.post(f"/task/{task_id}/field/{field_ids['AI Score']}",
            data={"value": 8.5})
client.post(f"/task/{task_id}/field/{field_ids['AI Category']}",
            data={"value": dropdown_option_uuid})
client.post(f"/task/{task_id}/field/{field_ids['AI Summary']}",
            data={"value": "Claude-generated summary text"})
```

### 8.5 Python SDK Options

| SDK | PyPI | Status | Notes |
|-----|------|--------|-------|
| `clickup-python-sdk` | `pip install clickup-python-sdk` | Community | Basic CRUD |
| `clickupython` | `pip install clickupython` | Community | More complete |
| Custom | — | Recommended | Build your own with the ClickUpClient pattern above |

For production AI automation, building a custom client (as shown in this document) gives full control over error handling, rate limiting, and async operations.

### 8.6 No-SDK Direct Integration (Recommended for AI Agents)

For AI automation pipelines, a direct requests-based client with built-in rate limiting is more reliable than community SDKs, which may lag behind API changes.

### 8.7 Incremental Sync for AI Agents

```python
# Get only tasks updated since last check (efficient for AI monitoring)
def get_tasks_updated_since(list_id, since_ms):
    all_tasks = []
    page = 0
    while True:
        resp = client.get(f"/list/{list_id}/task", params={
            "page": page,
            "date_updated_gt": since_ms,
            "order_by": "updated",
            "include_closed": True,
            "subtasks": True
        })
        tasks = resp.get("tasks", [])
        all_tasks.extend(tasks)
        if resp.get("last_page", True) or not tasks:
            break
        page += 1
    return all_tasks
```

---

## 9. Strategic Recommendations

### For AI Automation Projects

1. **Use webhooks over polling** — webhooks are real-time and don't consume rate limit. Polling a list every minute at 100 req/min is unsustainable on lower plans.

2. **Design around the rate limit from day one** — Free/Business plan at 100 req/min = 1.67 req/sec. For any workflow touching >50 tasks, you need async batch processing (see Pattern in Section 8.3).

3. **Business Plus minimum for meaningful automation** — 1,000 req/min gives enough headroom for real workflows. Free/Unlimited is prototyping only.

4. **Pre-fetch and cache custom field IDs** — These are UUIDs that don't change. Fetch once per session with `GET /list/{list_id}/field`, build a `name → id` map, cache it.

5. **Use `date_updated_gt` filtering for incremental sync** — Don't re-process all tasks on every run. Store the last-run timestamp and filter to only changed tasks.

6. **Always respond to webhooks within 7 seconds** — Put webhook processing in a background queue. If your handler does API calls, those eat into the 7-second window.

7. **Build idempotent webhook handlers** — Events can be delivered multiple times. Use `webhook_id` + `event` + `task_id` + `date` as a composite key for deduplication.

8. **Status names are case-sensitive** — "Open" ≠ "open". Fetch status names from `GET /list/{list_id}` and use exact strings.

---

## 10. Critical Gotchas & Edge Cases

| Gotcha | Detail |
|--------|--------|
| Personal token: NO Bearer prefix | `Authorization: pk_xxx` not `Authorization: Bearer pk_xxx` |
| All dates are Unix ms | Not seconds. `int(time.time() * 1000)` in Python |
| Assignees differ on create vs update | CREATE: flat array `[183]`. UPDATE: `{"add": [183], "rem": []}` |
| Custom fields: separate endpoint | `PUT /task/{id}` does NOT update custom fields. Use `POST /task/{id}/field/{field_id}` |
| Custom fields: must be created in UI | API cannot create custom field definitions. Only set/read values |
| Custom field IDs are UUIDs | Must be fetched via `GET /list/{list_id}/field`. Cannot be guessed |
| Free plan: 60 custom field writes lifetime | Permanent limit that never resets. Use Business+ for automation |
| No bulk task update endpoint | Confirmed "not on roadmap". Each task requires a separate API call |
| Subtasks need same list as parent | Cannot create subtask in different list than parent |
| Cannot un-subtask via `parent: null` | Use the dedicated reparent operation |
| team_id = workspace_id | In v2, "team" = workspace. Don't confuse with "group" (user groups) |
| Comment pagination is cursor-based | Uses `start_id` + `start` params, NOT `page` number |
| Webhook: raw body for HMAC | Parse HMAC on raw bytes. JSON whitespace changes break verification |
| Webhook: X-Signature is hex only | Never base64. Use `.hexdigest()` not `.digest()` |
| Webhook: secret shown only once | Store it at creation. If lost, delete and recreate the webhook |
| Webhook: 401/410 = instant suspend | Returning these status codes from your endpoint suspends the webhook |
| Webhook: no replay queue | Events dropped after 5 retries are gone. Build your own audit trail |
| Folderless lists: different endpoint | `GET /space/{id}/list` NOT `GET /folder/{id}/list` |
| status is case-sensitive | Must match exact string from the list's status definitions |
| Time tracking: negative duration | Means a timer is currently running (not an error) |
| Attachment: use multipart/form-data | Not JSON. Don't set Content-Type header manually |
| CORS blocks browser requests | Never call ClickUp API from frontend JS. Always proxy through backend |
| OAuth tokens don't expire (yet) | Documented as subject to change. Handle revocation gracefully |

---

## 11. Quick Reference: All Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/team` | Get authorized workspaces |
| POST | `/oauth/token` | Exchange OAuth code for token |

### Hierarchy
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/team/{team_id}/space` | Get spaces in workspace |
| POST | `/team/{team_id}/space` | Create space |
| PUT | `/space/{space_id}` | Update space |
| DELETE | `/space/{space_id}` | Delete space |
| GET | `/space/{space_id}/folder` | Get folders in space |
| POST | `/space/{space_id}/folder` | Create folder |
| PUT | `/folder/{folder_id}` | Update folder |
| DELETE | `/folder/{folder_id}` | Delete folder |
| GET | `/folder/{folder_id}/list` | Get lists in folder |
| GET | `/space/{space_id}/list` | Get folderless lists |
| POST | `/folder/{folder_id}/list` | Create list in folder |
| POST | `/space/{space_id}/list` | Create folderless list |
| PUT | `/list/{list_id}` | Update list |
| DELETE | `/list/{list_id}` | Delete list |

### Tasks
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/list/{list_id}/task` | Get tasks (paginated, 100/page) |
| GET | `/team/{team_id}/task` | Get tasks workspace-wide (paginated) |
| GET | `/task/{task_id}` | Get single task |
| POST | `/list/{list_id}/task` | Create task |
| PUT | `/task/{task_id}` | Update task |
| DELETE | `/task/{task_id}` | Delete task |

### Custom Fields
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/list/{list_id}/field` | Get custom field definitions |
| GET | `/space/{space_id}/field` | Get space-level custom fields |
| POST | `/task/{task_id}/field/{field_id}` | Set custom field value |
| DELETE | `/task/{task_id}/field/{field_id}` | Remove custom field value |

### Comments
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/task/{task_id}/comment` | Create task comment |
| GET | `/task/{task_id}/comment` | Get task comments (cursor-paged) |
| GET | `/task/{task_id}/comment/threaded` | Get threaded comments |
| PUT | `/comment/{comment_id}` | Update comment |
| DELETE | `/comment/{comment_id}` | Delete comment |
| POST | `/list/{list_id}/comment` | Create list comment |
| GET | `/list/{list_id}/comment` | Get list comments |
| POST | `/view/{view_id}/comment` | Create chat view comment |
| GET | `/view/{view_id}/comment` | Get chat view comments |

### Webhooks
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/team/{team_id}/webhook` | List webhooks |
| POST | `/team/{team_id}/webhook` | Create webhook |
| PUT | `/webhook/{webhook_id}` | Update webhook (reactivate with status:active) |
| DELETE | `/webhook/{webhook_id}` | Delete webhook |

### Members & Tags
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/team/{team_id}/member` | Get workspace members |
| GET | `/space/{space_id}/tag` | Get space tags |
| POST | `/task/{task_id}/tag/{tag_name}` | Add tag to task |
| DELETE | `/task/{task_id}/tag/{tag_name}` | Remove tag from task |

### Time Tracking
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/team/{team_id}/time_entries` | Get time entries |
| POST | `/team/{team_id}/time_entries` | Create time entry |
| PATCH | `/team/{team_id}/time_entries/{id}` | Update time entry |
| DELETE | `/team/{team_id}/time_entries/{id}` | Delete time entry |

### Views
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/team/{team_id}/view` | Get workspace views |
| GET | `/space/{space_id}/view` | Get space views |
| GET | `/folder/{folder_id}/view` | Get folder views |
| GET | `/list/{list_id}/view` | Get list views |
| GET | `/view/{view_id}/task` | Get tasks in view |

### Goals
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/team/{team_id}/goal` | Get goals |
| POST | `/team/{team_id}/goal` | Create goal |
| PUT | `/goal/{goal_id}` | Update goal |
| DELETE | `/goal/{goal_id}` | Delete goal |
| POST | `/goal/{goal_id}/key_result` | Add key result |

### Checklists & Dependencies
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/task/{task_id}/checklist` | Create checklist |
| POST | `/checklist/{id}/checklist_item` | Add checklist item |
| PUT | `/checklist/{id}/checklist_item/{item_id}` | Update item |
| DELETE | `/checklist/{id}` | Delete checklist |
| POST | `/task/{task_id}/dependency` | Add dependency |
| DELETE | `/task/{task_id}/dependency` | Remove dependency |
| POST | `/task/{task_id}/attachment` | Upload attachment (multipart) |

---

## 12. Conclusion

ClickUp API v2 is production-ready for AI automation with some important architectural constraints:

**Strengths:**
- Comprehensive REST API covering all platform features
- Webhooks with HMAC security and 27 event types
- Rich task model with custom fields, subtasks, dependencies
- No expiry on OAuth tokens (currently)
- Clear hierarchy with predictable endpoint patterns

**Constraints to design around:**
- No bulk operations — every task/field update is a separate API call
- 100 req/min on lower plans — requires careful batching for large workloads
- Custom fields must be created in UI — cannot provision via API
- Webhook events are not replayable — build audit trails
- Free plan: 60 lifetime custom field writes

**Recommended minimum plan for AI automation:** Business Plus (1,000 req/min)

**Best integration architecture:**
1. Webhook server for real-time triggers → AI processing queue
2. Custom `ClickUpClient` class with built-in rate limiting + backoff
3. Incremental sync using `date_updated_gt` filter (not full re-fetch)
4. Cache workspace/list/custom-field metadata (IDs don't change)
5. Write AI outputs to task comments (rich, searchable) and custom fields (structured, queryable)

---

## 13. References

| Source | URL | Type |
|--------|-----|------|
| ClickUp Authentication | https://developer.clickup.com/docs/authentication | Official |
| ClickUp OAuth Token | https://developer.clickup.com/reference/getaccesstoken | Official |
| ClickUp Rate Limits | https://developer.clickup.com/docs/rate-limits | Official |
| ClickUp Common Errors | https://developer.clickup.com/docs/common_errors | Official |
| ClickUp Tasks Docs | https://developer.clickup.com/docs/tasks | Official |
| ClickUp Create Task | https://developer.clickup.com/reference/createtask | Official |
| ClickUp Update Task | https://developer.clickup.com/reference/updatetask | Official |
| ClickUp Get Tasks | https://developer.clickup.com/reference/gettasks | Official |
| ClickUp Custom Fields | https://developer.clickup.com/docs/customfields | Official |
| ClickUp Set Custom Field | https://developer.clickup.com/reference/setcustomfieldvalue | Official |
| ClickUp Webhook Signature | https://developer.clickup.com/docs/webhooksignature | Official |
| ClickUp Webhook Health | https://developer.clickup.com/docs/webhookhealth | Official |
| ClickUp v2 vs v3 | https://developer.clickup.com/docs/general-v2-v3-api | Official |
| ClickUp FAQ | https://developer.clickup.com/docs/faq | Official |
| ClickUp Views | https://developer.clickup.com/docs/views | Official |
| ClickUp APIv2 Demo | https://github.com/clickup/clickup-APIv2-demo | Official GitHub |
| ConsultEvo Rate Limits | https://consultevo.com/clickup-api-rate-limits-guide/ | Community |
| ConsultEvo Webhooks | https://consultevo.com/clickup-webhooks-api-guide/ | Community |
| ConsultEvo Custom Fields | https://consultevo.com/clickup-custom-fields-api-guide/ | Community |
| Rollout Webhooks Guide | https://rollout.com/integration-guides/clickup/quick-guide-to-implementing-webhooks-in-clickup | Community |
| Python Integration Guide | https://rollout.com/integration-guides/clickup/sdk/step-by-step-guide-to-building-a-clickup-api-integration-in-python | Community |
| ClickUp Feedback (bulk ops) | https://feedback.clickup.com/public-api/p/update-multiple-task-fields-in-a-single-api-call | Community |
