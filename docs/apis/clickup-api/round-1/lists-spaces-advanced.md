# ClickUp API v2 — Lists, Spaces, Folders & Advanced Features
## Comprehensive Technical Reference

**Source URLs:** https://developer.clickup.com/reference/ | https://developer.clickup.com/docs/
**Date Saved:** 2026-03-18
**API Version:** v2 (base URL: `https://api.clickup.com/api/v2/`)

---

## Table of Contents

1. [Authentication & Fundamentals](#1-authentication--fundamentals)
2. [Hierarchy & Terminology](#2-hierarchy--terminology)
3. [Spaces API](#3-spaces-api)
4. [Space Features Object](#4-space-features-object)
5. [Folders API](#5-folders-api)
6. [Lists API](#6-lists-api)
7. [Statuses](#7-statuses)
8. [Members API](#8-members-api)
9. [Time Tracking API](#9-time-tracking-api)
10. [Tags API](#10-tags-api)
11. [Goals API](#11-goals-api)
12. [Views API](#12-views-api)
13. [Docs/Pages API (v3)](#13-docspages-api-v3)
14. [Automations API](#14-automations-api)
15. [Attachments API](#15-attachments-api)
16. [Checklists API](#16-checklists-api)
17. [Dependencies API](#17-dependencies-api)
18. [Custom Fields API](#18-custom-fields-api)
19. [Python Client Examples](#19-python-client-examples)
20. [Error Codes & Gotchas](#20-error-codes--gotchas)

---

## 1. Authentication & Fundamentals

### Base URL
```
https://api.clickup.com/api/v2/
```

### Authentication Methods

**Personal API Token (testing & personal use)**
```http
Authorization: pk_XXXXXXXXX
Content-Type: application/json
```

**OAuth 2.0 (production apps)**
- Authorization URL: `https://app.clickup.com/api`
- Token URL: `https://api.clickup.com/api/v2/oauth/token`
- Flow: Authorization Code

```python
import requests

CLICKUP_TOKEN = "pk_XXXXXXXXX"
HEADERS = {
    "Authorization": CLICKUP_TOKEN,
    "Content-Type": "application/json"
}
BASE_URL = "https://api.clickup.com/api/v2"
```

### Rate Limits
- **100 requests per minute** per token
- **429 Too Many Requests** returned when limit exceeded
- Retry-After header indicates wait time

### Getting Your Team (Workspace) ID
```bash
curl -H "Authorization: pk_XXXXXXXXX" \
     https://api.clickup.com/api/v2/team
```
Response includes `id` for each team — this is your `team_id` used throughout all v2 endpoints.

---

## 2. Hierarchy & Terminology

Understanding the ClickUp hierarchy is critical for correct API usage:

```
Workspace (team_id in v2)
  └── Space (space_id)
        ├── Folder (folder_id)
        │     └── List (list_id)
        │           └── Task (task_id)
        └── List [Folderless] (list_id)
              └── Task (task_id)
```

### v2 vs v3 Terminology Mapping

| v2 Term | v3 Term | Notes |
|---------|---------|-------|
| `team_id` | `workspace_id` | Same entity, different name |
| Team | Workspace | Top-level organizational unit |
| Space | Space | Unchanged |
| Folder | Folder | Unchanged |
| List | List | Unchanged |

**Important:** In all v2 endpoints, `team_id` refers to the Workspace ID, not a user group. Groups (user teams) are a separate concept accessed via `/v2/group`.

---

## 3. Spaces API

Spaces are the top-level containers within a Workspace. Each Space can have independent feature settings, statuses, and member access controls.

### Endpoint Table

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Get Spaces | GET | `/v2/team/{team_id}/space` |
| Get Space | GET | `/v2/space/{space_id}` |
| Create Space | POST | `/v2/team/{team_id}/space` |
| Update Space | PUT | `/v2/space/{space_id}` |
| Delete Space | DELETE | `/v2/space/{space_id}` |

---

### GET /v2/team/{team_id}/space — Get Spaces

**Description:** View all Spaces available in a Workspace. Member info is only visible for private Spaces.

**Path Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `team_id` | number | Yes | Workspace ID |

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `archived` | boolean | No | Include archived spaces (default: false) |

**Example Request:**
```bash
curl -H "Authorization: pk_XXXXXXXXX" \
     "https://api.clickup.com/api/v2/team/123456/space?archived=false"
```

```python
def get_spaces(team_id, archived=False):
    url = f"{BASE_URL}/team/{team_id}/space"
    params = {"archived": archived}
    response = requests.get(url, headers=HEADERS, params=params)
    return response.json()
```

**Example Response:**
```json
{
  "spaces": [
    {
      "id": "789",
      "name": "Engineering",
      "color": "#02BCD4",
      "avatar": null,
      "private": false,
      "multiple_assignees": true,
      "features": {
        "due_dates": {"enabled": true, "start_date": true, "remap_due_dates": true, "remap_closed_due_date": false},
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
        "emails": {"enabled": false}
      },
      "members": []
    }
  ]
}
```

---

### POST /v2/team/{team_id}/space — Create Space

**Description:** Create a new Space in a Workspace. Requires at minimum a `name`. All feature flags default to disabled unless specified.

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Space name |
| `multiple_assignees` | boolean | No | Allow multiple assignees per task |
| `features` | object | No | Feature flags for the space (see Section 4) |

**Example Request:**
```bash
curl -X POST \
     -H "Authorization: pk_XXXXXXXXX" \
     -H "Content-Type: application/json" \
     -d '{
       "name": "Product Development",
       "multiple_assignees": true,
       "features": {
         "due_dates": {
           "enabled": true,
           "start_date": true,
           "remap_due_dates": false,
           "remap_closed_due_date": false
         },
         "time_tracking": {"enabled": true},
         "tags": {"enabled": true},
         "time_estimates": {"enabled": true}
       }
     }' \
     "https://api.clickup.com/api/v2/team/123456/space"
```

```python
def create_space(team_id, name, multiple_assignees=True, features=None):
    url = f"{BASE_URL}/team/{team_id}/space"
    payload = {
        "name": name,
        "multiple_assignees": multiple_assignees,
        "features": features or {
            "due_dates": {"enabled": True, "start_date": False,
                          "remap_due_dates": False, "remap_closed_due_date": False},
            "time_tracking": {"enabled": True}
        }
    }
    response = requests.post(url, headers=HEADERS, json=payload)
    return response.json()
```

---

### PUT /v2/space/{space_id} — Update Space

**Description:** Update Space settings including name, color, privacy, multiple assignees, and feature flags.

**Path Parameters:**
| Parameter | Type | Required |
|-----------|------|----------|
| `space_id` | number | Yes |

**Request Body Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `name` | string | New space name |
| `color` | string | Hex color (e.g., `"#000000"`) |
| `private` | boolean | Make space private |
| `admin_can_manage` | boolean | Allow admins to manage private space |
| `multiple_assignees` | boolean | Allow multiple assignees |
| `features` | object | Feature configuration object |

**Example:**
```python
def update_space(space_id, **kwargs):
    url = f"{BASE_URL}/space/{space_id}"
    response = requests.put(url, headers=HEADERS, json=kwargs)
    return response.json()

# Usage:
update_space("789", name="Backend Team", color="#FF5733",
             private=False, multiple_assignees=True,
             features={"due_dates": {"enabled": True, "start_date": True,
                                     "remap_due_dates": True, "remap_closed_due_date": False},
                       "time_tracking": {"enabled": True}})
```

---

### DELETE /v2/space/{space_id} — Delete Space

```bash
curl -X DELETE \
     -H "Authorization: pk_XXXXXXXXX" \
     "https://api.clickup.com/api/v2/space/789"
```
Returns `{}` on success.

---

## 4. Space Features Object

The `features` object controls which ClickApp features are available within a Space. This object is used in both Create Space and Update Space requests.

### Full Features Object Schema

```json
{
  "features": {
    "due_dates": {
      "enabled": true,
      "start_date": true,
      "remap_due_dates": true,
      "remap_closed_due_date": false
    },
    "time_tracking": {
      "enabled": true
    },
    "tags": {
      "enabled": true
    },
    "time_estimates": {
      "enabled": true,
      "rollup": false
    },
    "checklists": {
      "enabled": true
    },
    "custom_fields": {
      "enabled": true
    },
    "remap_dependencies": {
      "enabled": false
    },
    "dependency_warning": {
      "enabled": true
    },
    "portfolios": {
      "enabled": false
    },
    "milestones": {
      "enabled": false
    },
    "sprints": {
      "enabled": false
    },
    "emails": {
      "enabled": false
    },
    "native_automations": {
      "enabled": true
    }
  }
}
```

### Feature Descriptions

| Feature Key | Description | Notes |
|-------------|-------------|-------|
| `due_dates.enabled` | Enable due dates on tasks | Required for most scheduling features |
| `due_dates.start_date` | Allow start dates on tasks | Requires `due_dates.enabled: true` |
| `due_dates.remap_due_dates` | Auto-remap dependent task due dates | Moves dates when parent shifts |
| `due_dates.remap_closed_due_date` | Remap dates even when closed | Use carefully — affects completed tasks |
| `time_tracking.enabled` | Enable time tracking in this Space | Enables time entry UI |
| `tags.enabled` | Enable task tags | Tags are Space-scoped |
| `time_estimates.enabled` | Enable time estimate fields | Set estimated hours on tasks |
| `time_estimates.rollup` | Roll up estimates from subtasks | Aggregates child estimates |
| `checklists.enabled` | Enable checklists on tasks | Task sub-items |
| `custom_fields.enabled` | Enable custom fields | Fields created at Space level |
| `remap_dependencies` | Auto-remap when dependencies shift | Cascading schedule updates |
| `dependency_warning` | Show warnings for dependency conflicts | Visual warning in UI |
| `portfolios.enabled` | Enable portfolio views | Business Plan+ |
| `milestones.enabled` | Enable milestone tasks | Milestone task type |
| `sprints.enabled` | Enable sprint management | Agile sprint support |
| `emails.enabled` | Enable email integration | Send emails from tasks |
| `native_automations.enabled` | Enable ClickUp native automations | Trigger-action rules |

---

## 5. Folders API

Folders organize Lists within a Space. They are optional — Lists can exist directly in Spaces as "folderless" lists.

### Endpoint Table

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Get Folders | GET | `/v2/space/{space_id}/folder` |
| Get Folder | GET | `/v2/folder/{folder_id}` |
| Create Folder | POST | `/v2/space/{space_id}/folder` |
| Update Folder | PUT | `/v2/folder/{folder_id}` |
| Delete Folder | DELETE | `/v2/folder/{folder_id}` |

---

### GET /v2/space/{space_id}/folder — Get Folders

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `archived` | boolean | Include archived folders |

**Example Response:**
```json
{
  "folders": [
    {
      "id": "457",
      "name": "Q1 Sprint",
      "orderindex": 0,
      "override_statuses": false,
      "hidden": false,
      "space": {
        "id": "789",
        "name": "Engineering",
        "access": true
      },
      "task_count": "14",
      "lists": [
        {
          "id": "124",
          "name": "Backlog",
          "orderindex": 0,
          "status": null,
          "priority": null,
          "assignee": null,
          "task_count": 7,
          "due_date": null,
          "start_date": null,
          "archived": false,
          "override_statuses": false
        }
      ]
    }
  ]
}
```

```python
def get_folders(space_id, archived=False):
    url = f"{BASE_URL}/space/{space_id}/folder"
    response = requests.get(url, headers=HEADERS, params={"archived": archived})
    return response.json()
```

---

### POST /v2/space/{space_id}/folder — Create Folder

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Folder display name |

**Example:**
```bash
curl -X POST \
     -H "Authorization: pk_XXXXXXXXX" \
     -H "Content-Type: application/json" \
     -d '{"name": "Q2 Sprint"}' \
     "https://api.clickup.com/api/v2/space/789/folder"
```

```python
def create_folder(space_id, name):
    url = f"{BASE_URL}/space/{space_id}/folder"
    response = requests.post(url, headers=HEADERS, json={"name": name})
    return response.json()
```

**Response includes:** `id`, `name`, `orderindex`, `override_statuses`, `hidden`, `space`, `task_count`, `lists`

---

### PUT /v2/folder/{folder_id} — Update Folder

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | New folder name |

```python
def update_folder(folder_id, name):
    url = f"{BASE_URL}/folder/{folder_id}"
    response = requests.put(url, headers=HEADERS, json={"name": name})
    return response.json()
```

---

### DELETE /v2/folder/{folder_id} — Delete Folder

Returns `{}` on success. All Lists and Tasks within the Folder are also deleted.

```bash
curl -X DELETE \
     -H "Authorization: pk_XXXXXXXXX" \
     "https://api.clickup.com/api/v2/folder/457"
```

---

## 6. Lists API

Lists are the containers for tasks. They exist either inside Folders or directly in Spaces (folderless). Lists can have their own statuses, priority, due dates, and assignees.

### Endpoint Table

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Get Lists (in Folder) | GET | `/v2/folder/{folder_id}/list` |
| Get Folderless Lists | GET | `/v2/space/{space_id}/list` |
| Get List | GET | `/v2/list/{list_id}` |
| Create List (in Folder) | POST | `/v2/folder/{folder_id}/list` |
| Create Folderless List | POST | `/v2/space/{space_id}/list` |
| Update List | PUT | `/v2/list/{list_id}` |
| Delete List | DELETE | `/v2/list/{list_id}` |

---

### GET /v2/folder/{folder_id}/list — Get Lists in Folder

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `archived` | boolean | Include archived lists |

**Example Response:**
```json
{
  "lists": [
    {
      "id": "124",
      "name": "Backlog",
      "orderindex": 0,
      "content": "Contains all backlog items",
      "status": {
        "status": "red",
        "color": "#e50000",
        "hide_label": true
      },
      "priority": {
        "priority": "high",
        "color": "#f50000"
      },
      "assignee": {
        "id": 183,
        "username": "johndoe",
        "email": "john@example.com",
        "color": "#7b68ee"
      },
      "task_count": 12,
      "due_date": "1568036964079",
      "due_datetime": false,
      "start_date": null,
      "start_date_time": false,
      "space": {
        "id": "789",
        "name": "Engineering",
        "access": true
      },
      "archived": false,
      "override_statuses": false,
      "statuses": [
        {"id": "sc", "status": "to do", "type": "open", "orderindex": 0, "color": "#d3d3d3"},
        {"id": "sc1", "status": "in progress", "type": "custom", "orderindex": 1, "color": "#4194f6"},
        {"id": "sc2", "status": "complete", "type": "closed", "orderindex": 2, "color": "#6bc950"}
      ],
      "permission_level": "create"
    }
  ]
}
```

---

### GET /v2/space/{space_id}/list — Get Folderless Lists

Returns only Lists that are directly in the Space, not inside any Folder.

```python
def get_folderless_lists(space_id, archived=False):
    url = f"{BASE_URL}/space/{space_id}/list"
    response = requests.get(url, headers=HEADERS, params={"archived": archived})
    return response.json()
```

---

### POST /v2/folder/{folder_id}/list — Create List

### POST /v2/space/{space_id}/list — Create Folderless List

Both endpoints share the same request body schema:

**Request Body Fields:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | List display name |
| `content` | string | No | Plain text description |
| `markdown_content` | string | No | Markdown-formatted description (use instead of `content`) |
| `due_date` | integer | No | Unix timestamp in milliseconds |
| `due_datetime` | boolean | No | Whether due_date includes time |
| `priority` | integer | No | Priority level (1=urgent, 2=high, 3=normal, 4=low) |
| `assignee` | integer | No | User ID to assign as List owner |
| `status` | string | No | Status name that exists on this list |

**Example — Create List in Folder:**
```bash
curl -X POST \
     -H "Authorization: pk_XXXXXXXXX" \
     -H "Content-Type: application/json" \
     -d '{
       "name": "Sprint 12",
       "content": "Q2 Sprint items",
       "due_date": 1750000000000,
       "due_datetime": false,
       "priority": 2,
       "assignee": 183,
       "status": "to do"
     }' \
     "https://api.clickup.com/api/v2/folder/457/list"
```

```python
def create_list(folder_id, name, content=None, due_date=None,
                priority=None, assignee=None, status=None):
    url = f"{BASE_URL}/folder/{folder_id}/list"
    payload = {"name": name}
    if content: payload["content"] = content
    if due_date: payload["due_date"] = due_date
    if priority: payload["priority"] = priority
    if assignee: payload["assignee"] = assignee
    if status: payload["status"] = status
    return requests.post(url, headers=HEADERS, json=payload).json()

def create_folderless_list(space_id, name, **kwargs):
    url = f"{BASE_URL}/space/{space_id}/list"
    payload = {"name": name, **kwargs}
    return requests.post(url, headers=HEADERS, json=payload).json()
```

---

### PUT /v2/list/{list_id} — Update List

**Description:** Rename a List, update description, set due date/time, priority, assignee, color, or override statuses.

**Request Body Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `name` | string | New list name (required in schema) |
| `content` | string | New description |
| `markdown_content` | string | Markdown description |
| `due_date` | integer | Unix ms timestamp |
| `due_datetime` | boolean | Include time in due date |
| `priority` | integer | 1-4 priority level |
| `assignee` | string | User ID or "none" to unassign |
| `status` | string | Status name |
| `unset_status` | boolean | Remove status |
| `override_statuses` | boolean | Use list-specific statuses (not inherited) |

```python
def update_list(list_id, **fields):
    url = f"{BASE_URL}/list/{list_id}"
    return requests.put(url, headers=HEADERS, json=fields).json()

# Examples:
update_list("124", name="Sprint 13 - Backlog", due_date=1760000000000)
update_list("124", override_statuses=True, assignee="none")
```

---

### DELETE /v2/list/{list_id} — Delete List

Returns `{}` on success. All tasks within the List are also deleted.

---

### List Response Object — Key Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | List identifier |
| `name` | string | Display name |
| `orderindex` | number | Sort order |
| `content` | string | Description text |
| `status` | object | Current status object |
| `priority` | object | Priority object with label and color |
| `assignee` | object | Owner user object |
| `task_count` | integer | Number of tasks |
| `due_date` | string | Unix ms timestamp string |
| `due_datetime` | boolean | Whether due date has time |
| `start_date` | string | Start date unix ms |
| `space` | object | Parent Space info |
| `archived` | boolean | Archived state |
| `override_statuses` | boolean | Using custom statuses |
| `statuses` | array | Status objects for this list |
| `permission_level` | string | Access level: create/edit/read |

---

## 7. Statuses

Statuses are configured at the Space level and inherited by Folders and Lists. Lists can override with their own statuses using `override_statuses: true`.

### Status Object Schema

```json
{
  "id": "sc",
  "status": "to do",
  "type": "open",
  "orderindex": 0,
  "color": "#d3d3d3"
}
```

### Status Types

| Type | Description |
|------|-------------|
| `open` | The starting/default status — tasks begin here |
| `custom` | Any intermediate status you define |
| `closed` | Marks task as complete; triggers automation closes |

### Get Space Statuses

Statuses are returned as part of the Space object from `GET /v2/space/{space_id}`. There is no dedicated statuses endpoint in v2 — they come embedded in Space and List responses.

### Status Colors (Common Examples)

```json
[
  {"status": "to do",      "type": "open",   "color": "#d3d3d3"},
  {"status": "in progress","type": "custom", "color": "#4194f6"},
  {"status": "review",     "type": "custom", "color": "#f9c74f"},
  {"status": "blocked",    "type": "custom", "color": "#e63946"},
  {"status": "complete",   "type": "closed", "color": "#6bc950"}
]
```

### Custom Status Rules
- Each Space must have exactly **one** `open` type status and **one** `closed` type status
- Any number of `custom` type statuses between them
- Colors are hex strings (`#RRGGBB`)
- Status names must be unique within a Space
- To use custom statuses on a List, set `override_statuses: true` on that List

---

## 8. Members API

### Endpoint Table

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Get Workspace Members | GET | `/v2/team/{team_id}/member` |
| Get List Members | GET | `/v2/list/{list_id}/member` |
| Get Task Members | GET | `/v2/task/{task_id}/member` |
| Add Task Assignee | POST | `/v2/task/{task_id}` (via update) |
| Remove Task Assignee | PUT | `/v2/task/{task_id}` |

---

### GET /v2/task/{task_id}/member — Get Task Members

**Description:** Get Workspace members who have explicit access to a task. Does **not** include people with access through a Group (Team), or people with inherited access from List, Folder, or Space.

**Response:**
```json
{
  "members": [
    {
      "id": 183,
      "username": "johndoe",
      "email": "john@example.com",
      "color": "#7b68ee",
      "initials": "JD",
      "profilePicture": "https://...",
      "profileInfo": {}
    }
  ]
}
```

```python
def get_task_members(task_id, custom_task_ids=False, team_id=None):
    url = f"{BASE_URL}/task/{task_id}/member"
    params = {}
    if custom_task_ids:
        params["custom_task_ids"] = True
        params["team_id"] = team_id
    return requests.get(url, headers=HEADERS, params=params).json()
```

### GET /v2/list/{list_id}/member — Get List Members

```python
def get_list_members(list_id):
    url = f"{BASE_URL}/list/{list_id}/member"
    return requests.get(url, headers=HEADERS).json()
```

### Adding/Removing Assignees (via Update Task)

Assignees are managed through the Update Task endpoint using `assignees.add` and `assignees.rem` arrays:

```python
def add_task_assignee(task_id, user_id):
    url = f"{BASE_URL}/task/{task_id}"
    payload = {"assignees": {"add": [user_id], "rem": []}}
    return requests.put(url, headers=HEADERS, json=payload).json()

def remove_task_assignee(task_id, user_id):
    url = f"{BASE_URL}/task/{task_id}"
    payload = {"assignees": {"add": [], "rem": [user_id]}}
    return requests.put(url, headers=HEADERS, json=payload).json()
```

### Guest Access (Enterprise Only)
- `POST /v2/task/{task_id}/guest/{guest_id}` — Share task with guest
- `DELETE /v2/task/{task_id}/guest/{guest_id}` — Remove guest from task
- Only available on **Enterprise Plan**

---

## 9. Time Tracking API

ClickUp has both a **legacy time tracking** endpoint (`/v2/task/{task_id}/time`) and the modern **Time Tracking 2.0** API (`/v2/team/{team_id}/time_entries`). Use Time Tracking 2.0 for all new integrations.

### Endpoint Table

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Get Time Entries (date range) | GET | `/v2/team/{team_id}/time_entries` |
| Get Single Time Entry | GET | `/v2/team/{team_id}/time_entries/{timer_id}` |
| Create Time Entry | POST | `/v2/team/{team_id}/time_entries` |
| Update Time Entry | PUT | `/v2/team/{team_id}/time_entries/{timer_id}` |
| Delete Time Entry | DELETE | `/v2/team/{team_id}/time_entries/{timer_id}` |
| Get Time Entry History | GET | `/v2/team/{team_id}/time_entries/{timer_id}/history` |
| Start Timer | POST | `/v2/team/{team_id}/time_entries/start` |
| Stop Timer | POST | `/v2/team/{team_id}/time_entries/stop` |
| Get Running Timer | GET | `/v2/team/{team_id}/time_entries/current` |
| Track Time (Legacy) | POST | `/v2/task/{task_id}/time` |

---

### GET /v2/team/{team_id}/time_entries — Get Time Entries Within a Date Range

**Description:** Returns time entries filtered by date range. By default returns last 30 days for authenticated user. To retrieve other users' entries, use the `assignee` parameter.

**Important:** Only one location filter (`space_id`, `folder_id`, `list_id`, or `task_id`) can be used at a time.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `start_date` | number | Unix time in milliseconds (start of range) |
| `end_date` | number | Unix time in milliseconds (end of range) |
| `assignee` | number | Filter by user ID |
| `include_task_tags` | boolean | Include task tag data |
| `include_location_names` | boolean | Include Space/Folder/List names |
| `space_id` | number | Filter by Space (mutually exclusive with folder/list/task) |
| `folder_id` | number | Filter by Folder |
| `list_id` | number | Filter by List |
| `task_id` | string | Filter by Task |
| `custom_task_ids` | boolean | Use custom task IDs |
| `team_id` (query) | number | Required when `custom_task_ids=true` |

**Note:** A time entry with a **negative duration** means that timer is currently running for that user.

**Example:**
```python
import time

def get_time_entries(team_id, start_date=None, end_date=None,
                     assignee=None, task_id=None, list_id=None):
    url = f"{BASE_URL}/team/{team_id}/time_entries"
    params = {}
    if start_date: params["start_date"] = start_date
    if end_date: params["end_date"] = end_date
    if assignee: params["assignee"] = assignee
    if task_id: params["task_id"] = task_id
    if list_id: params["list_id"] = list_id
    return requests.get(url, headers=HEADERS, params=params).json()

# Get last 7 days for current user
now_ms = int(time.time() * 1000)
seven_days_ago = now_ms - (7 * 24 * 60 * 60 * 1000)
entries = get_time_entries(team_id="123456",
                           start_date=seven_days_ago,
                           end_date=now_ms)
```

---

### POST /v2/team/{team_id}/time_entries — Create Time Entry

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `description` | string | No | Description/note for the entry |
| `tags` | array | No | Array of tag objects |
| `start` | number | Yes | Start time (Unix ms) |
| `stop` | number | No | Stop time (Unix ms) — omit for running timer |
| `duration` | number | No | Duration in milliseconds (alternative to stop) |
| `billable` | boolean | No | Mark as billable |
| `tid` | string | No | Task ID to associate with |
| `assignee` | number | No | User ID (admin only for other users) |

```python
def create_time_entry(team_id, task_id, start_ms, duration_ms,
                      description=None, billable=False):
    url = f"{BASE_URL}/team/{team_id}/time_entries"
    payload = {
        "description": description or "",
        "start": start_ms,
        "duration": duration_ms,
        "billable": billable,
        "tid": task_id
    }
    return requests.post(url, headers=HEADERS, json=payload).json()
```

---

### Legacy Time Tracking (Deprecated)

```bash
# POST /v2/task/{task_id}/time — Legacy endpoint, use Time Tracking 2.0 instead
curl -X POST \
     -H "Authorization: pk_XXXXXXXXX" \
     -H "Content-Type: application/json" \
     -d '{"start": 1571875200000, "end": 1571882400000, "time": 7200000}' \
     "https://api.clickup.com/api/v2/task/abc123/time"
```

---

## 10. Tags API

Tags are Space-scoped labels that can be applied to Tasks. Each tag has a name and customizable foreground/background colors.

### Endpoint Table

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Get Space Tags | GET | `/v2/space/{space_id}/tag` |
| Create Space Tag | POST | `/v2/space/{space_id}/tag` |
| Update Space Tag | PUT | `/v2/space/{space_id}/tag/{tag_name}` |
| Delete Space Tag | DELETE | `/v2/space/{space_id}/tag/{tag_name}` |
| Add Tag to Task | POST | `/v2/task/{task_id}/tag/{tag_name}` |
| Remove Tag from Task | DELETE | `/v2/task/{task_id}/tag/{tag_name}` |

---

### GET /v2/space/{space_id}/tag — Get Space Tags

**Example Response:**
```json
{
  "tags": [
    {
      "name": "bug",
      "tag_fg": "#FFFFFF",
      "tag_bg": "#FF0000",
      "creator": 183
    },
    {
      "name": "feature",
      "tag_fg": "#000000",
      "tag_bg": "#00C896"
    }
  ]
}
```

```python
def get_space_tags(space_id):
    url = f"{BASE_URL}/space/{space_id}/tag"
    return requests.get(url, headers=HEADERS).json()
```

---

### POST /v2/space/{space_id}/tag — Create Space Tag

```python
def create_space_tag(space_id, name, tag_fg="#FFFFFF", tag_bg="#000000"):
    url = f"{BASE_URL}/space/{space_id}/tag"
    payload = {"tag": {"name": name, "tag_fg": tag_fg, "tag_bg": tag_bg}}
    return requests.post(url, headers=HEADERS, json=payload).json()
```

---

### POST /v2/task/{task_id}/tag/{tag_name} — Add Tag to Task

```bash
curl -X POST \
     -H "Authorization: pk_XXXXXXXXX" \
     "https://api.clickup.com/api/v2/task/abc123/tag/bug"
```

```python
def add_tag_to_task(task_id, tag_name, custom_task_ids=False, team_id=None):
    url = f"{BASE_URL}/task/{task_id}/tag/{tag_name}"
    params = {}
    if custom_task_ids:
        params["custom_task_ids"] = True
        params["team_id"] = team_id
    return requests.post(url, headers=HEADERS, params=params).json()
```

---

### DELETE /v2/task/{task_id}/tag/{tag_name} — Remove Tag from Task

**Note:** This removes the tag from the task only. It does NOT delete the tag from the Space.

```python
def remove_tag_from_task(task_id, tag_name):
    url = f"{BASE_URL}/task/{task_id}/tag/{tag_name}"
    return requests.delete(url, headers=HEADERS).json()
```

---

## 11. Goals API

Goals allow you to track high-level objectives using Key Results (Targets). Each Goal can have multiple owners, a due date, and measurable Targets of various types.

### Endpoint Table

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Get Goals | GET | `/v2/team/{team_id}/goal` |
| Create Goal | POST | `/v2/team/{team_id}/goal` |
| Get Goal | GET | `/v2/goal/{goal_id}` |
| Update Goal | PUT | `/v2/goal/{goal_id}` |
| Delete Goal | DELETE | `/v2/goal/{goal_id}` |
| Create Key Result | POST | `/v2/goal/{goal_id}/key_result` |
| Update Key Result | PUT | `/v2/key_result/{key_result_id}` |
| Delete Key Result | DELETE | `/v2/key_result/{key_result_id}` |

---

### GET /v2/team/{team_id}/goal — Get Goals

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `include_completed` | boolean | Include completed goals (default: false) |

**Example Response:**
```json
{
  "goals": [
    {
      "id": "e53a033c",
      "pretty_id": "1",
      "name": "Q2 OKRs",
      "team_id": "123456",
      "creator": 183,
      "owner": 183,
      "color": "#7b68ee",
      "date_created": "1568000000000",
      "start_date": null,
      "due_date": "1750000000000",
      "description": "Q2 Objectives",
      "private": false,
      "archived": false,
      "multiple_owners": true,
      "editors": [],
      "owners": [{"id": 183}],
      "key_results": []
    }
  ],
  "folders": []
}
```

---

### POST /v2/team/{team_id}/goal — Create Goal

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Goal name |
| `due_date` | integer | Yes | Unix ms timestamp |
| `description` | string | Yes | Goal description |
| `multiple_owners` | boolean | Yes | Allow multiple owners |
| `owners` | array | Yes | Array of user IDs |
| `color` | string | Yes | Hex color string |

```python
def create_goal(team_id, name, due_date_ms, description="",
                owners=None, color="#7b68ee", multiple_owners=False):
    url = f"{BASE_URL}/team/{team_id}/goal"
    payload = {
        "name": name,
        "due_date": due_date_ms,
        "description": description,
        "multiple_owners": multiple_owners,
        "owners": owners or [],
        "color": color
    }
    return requests.post(url, headers=HEADERS, json=payload).json()
```

---

### PUT /v2/goal/{goal_id} — Update Goal

**Request Body:**
| Field | Type | Description |
|-------|------|-------------|
| `name` | string | New goal name |
| `due_date` | integer | New due date (Unix ms) |
| `description` | string | New description |
| `rem_owners` | array | Array of user IDs to remove |
| `add_owners` | array | Array of user IDs to add |
| `color` | string | New hex color |

```python
def update_goal(goal_id, name=None, due_date=None, description=None,
                add_owners=None, rem_owners=None, color=None):
    url = f"{BASE_URL}/goal/{goal_id}"
    payload = {}
    if name: payload["name"] = name
    if due_date: payload["due_date"] = due_date
    if description: payload["description"] = description
    if add_owners: payload["add_owners"] = add_owners
    if rem_owners: payload["rem_owners"] = rem_owners
    if color: payload["color"] = color
    return requests.put(url, headers=HEADERS, json=payload).json()
```

---

### Key Results (Targets)

Key Results are the measurable outcomes within a Goal. They support multiple tracking types.

**Key Result Types:**
| Type | Description | Fields |
|------|-------------|--------|
| `number` | Track a numeric value | `steps_start`, `steps_end`, `unit` |
| `currency` | Track monetary amount | `steps_start`, `steps_end`, `unit` (currency code) |
| `boolean` | True/False completion | N/A |
| `percentage` | 0-100% progress | `steps_start`, `steps_end` |
| `automatic` | Calculated from linked tasks | `task_ids` |

```python
def create_key_result(goal_id, name, result_type,
                      steps_start=0, steps_end=100, unit=None,
                      owners=None, task_ids=None):
    url = f"{BASE_URL}/goal/{goal_id}/key_result"
    payload = {
        "name": name,
        "owners": owners or [],
        "type": result_type,
        "steps_start": steps_start,
        "steps_end": steps_end
    }
    if unit: payload["unit"] = unit
    if task_ids: payload["task_ids"] = task_ids
    return requests.post(url, headers=HEADERS, json=payload).json()

# Examples:
create_key_result(goal_id="e53a033c", name="Revenue Target",
                  result_type="currency", steps_start=0,
                  steps_end=50000, unit="USD")

create_key_result(goal_id="e53a033c", name="Ship Feature X",
                  result_type="boolean")
```

---

### Goal Webhook Events

```json
{"event": "goalCreated",  "goal_id": "...", "webhook_id": "..."}
{"event": "goalUpdated",  "goal_id": "...", "webhook_id": "..."}
{"event": "goalDeleted",  "goal_id": "...", "webhook_id": "..."}
{"event": "keyResultCreated", "goal_id": "...", "key_result_id": "...", "webhook_id": "..."}
{"event": "keyResultUpdated", "goal_id": "...", "key_result_id": "...", "webhook_id": "..."}
{"event": "keyResultDeleted", "goal_id": "...", "key_result_id": "...", "webhook_id": "..."}
```

---

## 12. Views API

Views define how tasks are displayed, filtered, grouped, and sorted. Views can be created at any level of the hierarchy: Workspace (everything), Space, Folder, or List.

### View Types

| View Type | Description |
|-----------|-------------|
| `list` | Standard list view |
| `board` | Kanban board view |
| `calendar` | Calendar view |
| `gantt` | Gantt chart |
| `table` | Spreadsheet-like table |
| `timeline` | Timeline/roadmap |
| `workload` | Capacity/workload view |
| `activity` | Activity stream |
| `map` | Geographic map view |
| `conversation` | Chat view |

**Note:** Page views (Docs, Whiteboards) are NOT supported through the public API.

### View Parent Types

| `parent.type` value | Level |
|---------------------|-------|
| `6` | List |
| `5` | Folder |
| `4` | Space |
| `7` | Team (Workspace — "Everything" level) |

### Endpoint Table

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Get Space Views | GET | `/v2/space/{space_id}/view` |
| Get Folder Views | GET | `/v2/folder/{folder_id}/view` |
| Get List Views | GET | `/v2/list/{list_id}/view` |
| Get Team Views | GET | `/v2/team/{team_id}/view` |
| Get View | GET | `/v2/view/{view_id}` |
| Create Space View | POST | `/v2/space/{space_id}/view` |
| Create Folder View | POST | `/v2/folder/{folder_id}/view` |
| Create List View | POST | `/v2/list/{list_id}/view` |
| Create Team View | POST | `/v2/team/{team_id}/view` |
| Update View | PUT | `/v2/view/{view_id}` |
| Delete View | DELETE | `/v2/view/{view_id}` |
| Get View Tasks | GET | `/v2/view/{view_id}/task` |

---

### View Object Example

```json
{
  "id": "3c-106",
  "name": "Engineering Board",
  "type": "board",
  "parent": {
    "id": "789",
    "type": 4
  },
  "grouping": {
    "field": "status",
    "dir": 1,
    "collapsed": [],
    "ignore": false
  },
  "filters": {
    "op": "AND",
    "fields": [
      {
        "field": "assignee",
        "op": "EQ",
        "values": [183]
      }
    ],
    "search": "",
    "show_closed": false
  },
  "sorting": {
    "fields": [
      {"field": "dateCreated", "dir": -1}
    ]
  },
  "columns": {
    "fields": [
      {"field": "dateCreated"},
      {"field": "assignee"},
      {"field": "priority"}
    ]
  },
  "settings": {
    "show_task_locations": false,
    "show_subtasks": 3,
    "show_subtask_parent_names": false,
    "show_closed_subtasks": false,
    "show_assignees": true,
    "show_images": true,
    "me_comments": false
  }
}
```

---

### POST /v2/space/{space_id}/view — Create Space View

**Required Request Body Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `name` | string | View name |
| `type` | string | View type: list, board, calendar, table, timeline, workload, activity, map, conversation, gantt |
| `grouping` | object | Grouping configuration |
| `divide` | object | Divide configuration |
| `sorting` | object | Sorting configuration |
| `filters` | object | Filter rules |
| `columns` | object | Column visibility |
| `team_sidebar` | object | Team sidebar settings |
| `settings` | object | View display settings |

```python
def create_space_view(space_id, name, view_type="board"):
    url = f"{BASE_URL}/space/{space_id}/view"
    payload = {
        "name": name,
        "type": view_type,
        "grouping": {"field": "status", "dir": 1, "collapsed": [], "ignore": False},
        "divide": {"field": None, "dir": None, "collapsed": []},
        "sorting": {"fields": [{"field": "dateCreated", "dir": -1}]},
        "filters": {"op": "AND", "fields": [], "search": "", "show_closed": False},
        "columns": {"fields": []},
        "team_sidebar": {"assignees": [], "unassigned": False},
        "settings": {
            "show_task_locations": False,
            "show_subtasks": 3,
            "show_assignees": True,
            "show_images": True,
            "me_comments": False,
            "me_subtasks": False,
            "me_checklists": False
        }
    }
    return requests.post(url, headers=HEADERS, json=payload).json()
```

---

### GET /v2/view/{view_id}/task — Get View Tasks

Returns tasks visible in a given view, respecting the view's filters and grouping.

```python
def get_view_tasks(view_id, page=0):
    url = f"{BASE_URL}/view/{view_id}/task"
    return requests.get(url, headers=HEADERS, params={"page": page}).json()
```

---

## 13. Docs/Pages API (v3)

Docs and Pages are managed through the **v3 API**, not v2. The v3 endpoints use `workspace_id` instead of `team_id`.

### v3 Docs Endpoints

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Get Docs in Workspace | GET | `/v3/workspaces/{workspace_id}/docs` |
| Create Doc | POST | `/v3/workspaces/{workspace_id}/docs` |
| Get Doc | GET | `/v3/workspaces/{workspace_id}/docs/{doc_id}` |
| Get Doc Pages | GET | `/v3/workspaces/{workspace_id}/docs/{doc_id}/pages` |
| Create Page | POST | `/v3/workspaces/{workspace_id}/docs/{doc_id}/pages` |

```python
V3_BASE = "https://api.clickup.com/api/v3"

def get_workspace_docs(workspace_id):
    url = f"{V3_BASE}/workspaces/{workspace_id}/docs"
    return requests.get(url, headers=HEADERS).json()

def create_doc(workspace_id, title, parent=None):
    url = f"{V3_BASE}/workspaces/{workspace_id}/docs"
    payload = {"name": title}
    if parent: payload["parent"] = parent
    return requests.post(url, headers=HEADERS, json=payload).json()
```

**Note:** Page views and Whiteboard views in v2 Views API are read-only. To create/edit Docs, use the v3 Docs API.

---

## 14. Automations API

Native Automations in ClickUp (trigger → action rules) are accessible through the API at the Space level. As of v2, the Automations API provides **read access** via the `native_automations` feature flag, but full CRUD automation management is primarily done through the ClickUp interface.

**Feature flag to enable:**
```json
{"features": {"native_automations": {"enabled": true}}}
```

The Automations API is in a limited state in v2. For workflow automation use cases, consider:
- **Webhooks** (`POST /v2/team/{team_id}/webhook`) for event-driven triggers
- **Trigger.dev or Make.com** for external automation orchestration

---

## 15. Attachments API

### v2 Attachment (Task Files)

**POST /v2/task/{task_id}/attachment — Create Task Attachment**

**Important:** Uses `multipart/form-data`, NOT JSON. Files stored in the cloud cannot be used — must be local file uploads.

**Headers:**
```
Authorization: pk_XXXXXXXXX
Content-Type: multipart/form-data
```

**Form Fields:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `attachment` | file | Yes | The file binary to upload |

```bash
curl -X POST \
     -H "Authorization: pk_XXXXXXXXX" \
     -F "attachment=@/path/to/file.pdf" \
     "https://api.clickup.com/api/v2/task/abc123/attachment"
```

```python
def upload_task_attachment(task_id, file_path):
    url = f"{BASE_URL}/task/{task_id}/attachment"
    headers = {"Authorization": CLICKUP_TOKEN}  # No Content-Type — let requests set it
    with open(file_path, "rb") as f:
        files = {"attachment": (file_path.split("/")[-1], f)}
        response = requests.post(url, headers=headers, files=files)
    return response.json()
```

**Response:**
```json
{
  "id": "attach_123",
  "title": "document.pdf",
  "date": "1568036964079",
  "source": "api",
  "version": "0",
  "extension": "pdf",
  "thumbnail_small": "https://...",
  "thumbnail_large": "https://...",
  "url": "https://..."
}
```

### v3 Attachment API (Recommended)

The v3 API supports attachments for both tasks and File-type Custom Fields:

```
POST /v3/workspaces/{workspace_id}/{entity_type}/{entity_id}/attachments
```

Where `entity_type` is `task` or `custom_fields`.

---

## 16. Checklists API

Checklists are sub-items within a task, used to track completion of step-by-step processes.

### Endpoint Table

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Create Checklist | POST | `/v2/task/{task_id}/checklist` |
| Update Checklist | PUT | `/v2/checklist/{checklist_id}` |
| Delete Checklist | DELETE | `/v2/checklist/{checklist_id}` |
| Create Checklist Item | POST | `/v2/checklist/{checklist_id}/checklist_item` |
| Update Checklist Item | PUT | `/v2/checklist/{checklist_id}/checklist_item/{checklist_item_id}` |
| Delete Checklist Item | DELETE | `/v2/checklist/{checklist_id}/checklist_item/{checklist_item_id}` |

---

### POST /v2/task/{task_id}/checklist — Create Checklist

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Checklist display name |

```python
def create_checklist(task_id, name):
    url = f"{BASE_URL}/task/{task_id}/checklist"
    return requests.post(url, headers=HEADERS, json={"name": name}).json()
```

**Response includes:** `id`, `task_id`, `name`, `orderindex`, `resolved`, `unresolved`, `items`

---

### PUT /v2/checklist/{checklist_id} — Update Checklist

**Request Body:**
| Field | Type | Description |
|-------|------|-------------|
| `name` | string | New checklist name |
| `position` | integer | New order position among checklists |
| `assignee` | integer or null | User ID, or null to remove |

```python
def update_checklist(checklist_id, name=None, position=None, assignee=None):
    url = f"{BASE_URL}/checklist/{checklist_id}"
    payload = {}
    if name is not None: payload["name"] = name
    if position is not None: payload["position"] = position
    if assignee is not None: payload["assignee"] = assignee
    return requests.put(url, headers=HEADERS, json=payload).json()
```

---

### POST /v2/checklist/{checklist_id}/checklist_item — Create Checklist Item

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Item label text |
| `assignee` | integer | No | User ID to assign |

```python
def create_checklist_item(checklist_id, name, assignee=None):
    url = f"{BASE_URL}/checklist/{checklist_id}/checklist_item"
    payload = {"name": name}
    if assignee: payload["assignee"] = assignee
    return requests.post(url, headers=HEADERS, json=payload).json()
```

---

### PUT /v2/checklist/{checklist_id}/checklist_item/{checklist_item_id} — Update Item

**Request Body:**
| Field | Type | Description |
|-------|------|-------------|
| `name` | string | New item text |
| `assignee` | integer | User ID |
| `resolved` | boolean | Mark as complete (true) or incomplete (false) |
| `parent` | string | Item ID to nest under (subtask of checklist item) |

```python
def update_checklist_item(checklist_id, item_id, resolved=None,
                           name=None, assignee=None):
    url = f"{BASE_URL}/checklist/{checklist_id}/checklist_item/{item_id}"
    payload = {}
    if resolved is not None: payload["resolved"] = resolved
    if name: payload["name"] = name
    if assignee is not None: payload["assignee"] = assignee
    return requests.put(url, headers=HEADERS, json=payload).json()

# Mark complete:
update_checklist_item(checklist_id="abc", item_id="xyz", resolved=True)
```

---

### DELETE /v2/checklist/{checklist_id} — Delete Checklist

Permanently deletes the checklist and all its items. Cannot be undone.

```python
def delete_checklist(checklist_id):
    url = f"{BASE_URL}/checklist/{checklist_id}"
    return requests.delete(url, headers=HEADERS).json()
```

---

## 17. Dependencies API

Dependencies create relationships between tasks — one task must be completed before another can start, or one task is blocking another.

### Endpoint Table

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Add Dependency | POST | `/v2/task/{task_id}/dependency` |
| Delete Dependency | DELETE | `/v2/task/{task_id}/dependency` |

---

### POST /v2/task/{task_id}/dependency — Add Dependency

**Request Body:**
| Field | Type | Description |
|-------|------|-------------|
| `depends_on` | string | Task ID that must be completed first |
| `dependency_of` | string | Task ID that is blocked by the `depends_on` task |

**Note:** Provide either `depends_on` OR `dependency_of` in a single call to specify the direction.

```python
def add_dependency(task_id, depends_on=None, dependency_of=None,
                   custom_task_ids=False, team_id=None):
    url = f"{BASE_URL}/task/{task_id}/dependency"
    payload = {}
    if depends_on: payload["depends_on"] = depends_on
    if dependency_of: payload["dependency_of"] = dependency_of
    params = {}
    if custom_task_ids:
        params["custom_task_ids"] = True
        params["team_id"] = team_id
    return requests.post(url, headers=HEADERS,
                         json=payload, params=params).json()

# Task "task_B" is blocked until "task_A" completes:
add_dependency(task_id="task_B", depends_on="task_A")

# task_A blocks task_B (equivalent, from A's perspective):
add_dependency(task_id="task_A", dependency_of="task_B")
```

---

### DELETE /v2/task/{task_id}/dependency — Delete Dependency

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `depends_on` | string | ID of task that is depended on |
| `dependency_of` | string | ID of task that depends on this task |

```python
def delete_dependency(task_id, depends_on=None, dependency_of=None):
    url = f"{BASE_URL}/task/{task_id}/dependency"
    params = {}
    if depends_on: params["depends_on"] = depends_on
    if dependency_of: params["dependency_of"] = dependency_of
    return requests.delete(url, headers=HEADERS, params=params).json()
```

---

## 18. Custom Fields API

Custom Fields are additional data fields you can create in the ClickUp UI and then read/write via API.

**Important Limitation:** You **cannot create new Custom Field types** via the public API. Fields must first be created in the ClickUp web/desktop app. The API can then read field definitions and set values on tasks.

### Endpoint Table

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Get Space Custom Fields | GET | `/v2/space/{space_id}/field` |
| Get List Custom Fields | GET | `/v2/list/{list_id}/field` |
| Set Custom Field Value | POST | `/v2/task/{task_id}/field/{field_id}` |
| Remove Custom Field Value | DELETE | `/v2/task/{task_id}/field/{field_id}` |

---

### GET /v2/space/{space_id}/field — Get Space Custom Fields

Returns only Custom Fields created at the Space level. Fields at Folder or List level are not included.

```python
def get_space_custom_fields(space_id):
    url = f"{BASE_URL}/space/{space_id}/field"
    return requests.get(url, headers=HEADERS).json()
```

**Response structure:**
```json
{
  "fields": [
    {
      "id": "field_abc123",
      "name": "Client Name",
      "type": "text",
      "type_config": {},
      "date_created": "1568036964079",
      "hide_from_guests": false,
      "required": false
    },
    {
      "id": "field_def456",
      "name": "Budget",
      "type": "currency",
      "type_config": {"precision": 2, "default": 0, "currency_type": "USD"},
      "required": false
    }
  ]
}
```

### POST /v2/task/{task_id}/field/{field_id} — Set Custom Field Value

```python
def set_custom_field(task_id, field_id, value):
    url = f"{BASE_URL}/task/{task_id}/field/{field_id}"
    payload = {"value": value}
    return requests.post(url, headers=HEADERS, json=payload).json()

# Examples:
set_custom_field("task_xyz", "field_abc123", "Acme Corp")
set_custom_field("task_xyz", "field_def456", 5000)
set_custom_field("task_xyz", "field_bool789", True)
```

---

## 19. Python Client Examples

### Complete Python Client Class

```python
import requests
import time

class ClickUpClient:
    BASE_URL = "https://api.clickup.com/api/v2"

    def __init__(self, api_token):
        self.headers = {
            "Authorization": api_token,
            "Content-Type": "application/json"
        }

    def _get(self, path, params=None):
        return requests.get(f"{self.BASE_URL}{path}",
                            headers=self.headers, params=params).json()

    def _post(self, path, payload=None, files=None):
        headers = self.headers.copy()
        if files:
            del headers["Content-Type"]
            return requests.post(f"{self.BASE_URL}{path}",
                                 headers=headers, files=files).json()
        return requests.post(f"{self.BASE_URL}{path}",
                             headers=headers, json=payload).json()

    def _put(self, path, payload):
        return requests.put(f"{self.BASE_URL}{path}",
                            headers=self.headers, json=payload).json()

    def _delete(self, path, params=None):
        return requests.delete(f"{self.BASE_URL}{path}",
                               headers=self.headers, params=params).json()

    # Spaces
    def get_spaces(self, team_id, archived=False):
        return self._get(f"/team/{team_id}/space", {"archived": archived})

    def create_space(self, team_id, name, features=None, multiple_assignees=True):
        return self._post(f"/team/{team_id}/space", {
            "name": name,
            "multiple_assignees": multiple_assignees,
            "features": features or {}
        })

    # Folders
    def get_folders(self, space_id, archived=False):
        return self._get(f"/space/{space_id}/folder", {"archived": archived})

    def create_folder(self, space_id, name):
        return self._post(f"/space/{space_id}/folder", {"name": name})

    # Lists
    def get_lists(self, folder_id, archived=False):
        return self._get(f"/folder/{folder_id}/list", {"archived": archived})

    def get_folderless_lists(self, space_id, archived=False):
        return self._get(f"/space/{space_id}/list", {"archived": archived})

    def create_list(self, folder_id, name, **kwargs):
        return self._post(f"/folder/{folder_id}/list", {"name": name, **kwargs})

    def update_list(self, list_id, **fields):
        return self._put(f"/list/{list_id}", fields)

    # Time Tracking
    def get_time_entries(self, team_id, start_date=None, end_date=None,
                          assignee=None, task_id=None):
        params = {}
        if start_date: params["start_date"] = start_date
        if end_date: params["end_date"] = end_date
        if assignee: params["assignee"] = assignee
        if task_id: params["task_id"] = task_id
        return self._get(f"/team/{team_id}/time_entries", params)

    def create_time_entry(self, team_id, task_id, start_ms, duration_ms):
        return self._post(f"/team/{team_id}/time_entries", {
            "tid": task_id,
            "start": start_ms,
            "duration": duration_ms
        })

    # Goals
    def create_goal(self, team_id, name, due_date_ms, owners,
                    description="", color="#7b68ee"):
        return self._post(f"/team/{team_id}/goal", {
            "name": name, "due_date": due_date_ms, "description": description,
            "multiple_owners": len(owners) > 1, "owners": owners, "color": color
        })

    # Views
    def get_space_views(self, space_id):
        return self._get(f"/space/{space_id}/view")

    def get_view_tasks(self, view_id, page=0):
        return self._get(f"/view/{view_id}/task", {"page": page})

    # Checklists
    def create_checklist(self, task_id, name):
        return self._post(f"/task/{task_id}/checklist", {"name": name})

    def create_checklist_item(self, checklist_id, name, resolved=False):
        return self._post(f"/checklist/{checklist_id}/checklist_item",
                          {"name": name, "resolved": resolved})

    # Dependencies
    def add_dependency(self, task_id, depends_on=None, dependency_of=None):
        payload = {}
        if depends_on: payload["depends_on"] = depends_on
        if dependency_of: payload["dependency_of"] = dependency_of
        return self._post(f"/task/{task_id}/dependency", payload)

    # Tags
    def get_space_tags(self, space_id):
        return self._get(f"/space/{space_id}/tag")

    def add_tag_to_task(self, task_id, tag_name):
        return self._post(f"/task/{task_id}/tag/{tag_name}")

    # Attachments
    def upload_attachment(self, task_id, file_path):
        with open(file_path, "rb") as f:
            filename = file_path.split("/")[-1]
            return self._post(f"/task/{task_id}/attachment",
                              files={"attachment": (filename, f)})


# Usage
client = ClickUpClient("pk_XXXXXXXXX")
spaces = client.get_spaces(team_id="123456")
folders = client.get_folders(space_id="789")
lists = client.get_lists(folder_id="457")
```

---

## 20. Error Codes & Gotchas

### HTTP Status Codes

| Code | Meaning | Common Cause |
|------|---------|--------------|
| `200` | OK | Successful request |
| `400` | Bad Request | Invalid payload — check required fields |
| `401` | Unauthorized | Missing or invalid API token |
| `403` | Forbidden | Token lacks permission for this operation |
| `404` | Not Found | Invalid ID in URL path |
| `429` | Too Many Requests | Rate limit exceeded (100 req/min) |
| `500` | Internal Server Error | ClickUp-side issue |

### Common Gotchas

**1. team_id vs team_id confusion**
In v2, `team_id` in paths ALWAYS refers to the Workspace ID. The `/v2/group` endpoint deals with user Groups.

**2. Timestamps are Unix milliseconds**
All date/time values in ClickUp API are Unix timestamps in **milliseconds**, not seconds.
```python
import time
now_ms = int(time.time() * 1000)          # Current time
tomorrow_ms = now_ms + (24 * 60 * 60 * 1000)  # Tomorrow
```

**3. Negative duration = running timer**
When a time entry has a negative `duration` value, it means that timer is currently active.

**4. Custom Field types cannot be created via API**
Custom Fields must be created in the ClickUp web UI first. The API can only read definitions and set values.

**5. Space status must have exactly one open + one closed type**
When creating custom statuses, ensure at least one `"type": "open"` and one `"type": "closed"` status exists.

**6. Only one location filter for time entries**
`GET /v2/team/{team_id}/time_entries` only allows one of: `space_id`, `folder_id`, `list_id`, or `task_id` per request.

**7. Attachment upload uses multipart/form-data**
Do not set `Content-Type: application/json` for attachment uploads. Let the HTTP client handle the multipart boundary automatically.

**8. Views with page types are not API-accessible**
Docs views and Whiteboard views cannot be created or read through the v2 Views API.

**9. Custom task IDs require team_id query param**
When using `custom_task_ids=true`, you must also pass `team_id` as a query parameter in the same request.

**10. Folderless lists vs folder lists**
- Lists inside a Folder: `GET /v2/folder/{folder_id}/list`
- Lists directly in Space: `GET /v2/space/{space_id}/list`
- These are different endpoints returning different sets

### Authentication Header Format
```
Authorization: pk_XXXXXXXXXXX
```
Do NOT include "Bearer " prefix for personal tokens. For OAuth tokens, the format is the same (no "Bearer").

---

## Sources

- ClickUp API v2 Reference: https://developer.clickup.com/reference/
- ClickUp API Docs (Guides): https://developer.clickup.com/docs/
- ClickUp v2 vs v3 Terminology: https://developer.clickup.com/docs/general-v2-v3-api
- ClickUp Views Documentation: https://developer.clickup.com/docs/views
- Get Folders endpoint: https://developer.clickup.com/reference/getfolders
- Get Space Tags: https://developer.clickup.com/reference/getspacetags
- Remove Tag From Task: https://developer.clickup.com/reference/removetagfromtask
- Create Goal: https://developer.clickup.com/reference/creategoal
- Update Goal: https://developer.clickup.com/reference/updategoal
- Get Goals: https://developer.clickup.com/reference/getgoals
- Create Time Entry: https://developer.clickup.com/reference/createatimeentry
- Get Time Entries: https://developer.clickup.com/reference/gettimeentrieswithinadaterange
- Track Time (Legacy): https://developer.clickup.com/reference/tracktime
- Get Task Members: https://developer.clickup.com/reference/gettaskmembers
- Create Task Attachment: https://developer.clickup.com/reference/createtaskattachment
- Get Space Views: https://developer.clickup.com/reference/getspaceviews
- Create Space View: https://developer.clickup.com/reference/createspaceview
- Create Folder View: https://developer.clickup.com/reference/createfolderview
- Create Folderless List: https://developer.clickup.com/reference/createfolderlesslist
- Create List: https://developer.clickup.com/reference/createlist
- Update List: https://developer.clickup.com/reference/updatelist
- Get Folderless Lists: https://developer.clickup.com/reference/getfolderlesslists
- Get Space Custom Fields: https://developer.clickup.com/reference/getspaceavailablefields
- Goal/Target Webhook Payloads: https://developer.clickup.com/docs/webhookgoaltargetpayloads
- Composio ClickUp Space Benchmark: https://github.com/ComposioHQ/Composio-Function-Calling-Benchmark/blob/master/clickup_space_benchmark.json
- Consultevo ClickUp API Guides: https://consultevo.com/clickup-spaces-api-how-to/
