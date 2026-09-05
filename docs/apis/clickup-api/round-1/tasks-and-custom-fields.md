# ClickUp API v2 — Tasks & Custom Fields: Complete Reference

**Source:** https://developer.clickup.com
**Date Saved:** 2026-03-18
**API Version:** v2
**Base URL:** `https://api.clickup.com/api/v2`

---

## Table of Contents

1. [Authentication](#1-authentication)
2. [Task CRUD Operations](#2-task-crud-operations)
   - 2.1 [Create Task](#21-create-task)
   - 2.2 [Get Task](#22-get-task)
   - 2.3 [Update Task](#23-update-task)
   - 2.4 [Delete Task](#24-delete-task)
3. [Task Fields Reference](#3-task-fields-reference)
4. [Subtask Creation and Management](#4-subtask-creation-and-management)
5. [Bulk Task Operations](#5-bulk-task-operations)
6. [Task Filtering](#6-task-filtering)
   - 6.1 [Get Tasks (List-scoped)](#61-get-tasks-list-scoped)
   - 6.2 [Get Filtered Team Tasks (Workspace-scoped)](#62-get-filtered-team-tasks-workspace-scoped)
7. [Custom Fields](#7-custom-fields)
   - 7.1 [Custom Field Types Reference](#71-custom-field-types-reference)
   - 7.2 [Get List Custom Fields](#72-get-list-custom-fields)
   - 7.3 [Set Custom Field Value on a Task](#73-set-custom-field-value-on-a-task)
   - 7.4 [Remove Custom Field Value](#74-remove-custom-field-value)
   - 7.5 [Setting Custom Fields on Task Create](#75-setting-custom-fields-on-task-create)
   - 7.6 [Reading Custom Field Values from Task Responses](#76-reading-custom-field-values-from-task-responses)
   - 7.7 [Custom Field Filtering in Queries](#77-custom-field-filtering-in-queries)
   - 7.8 [type_config Details Per Field Type](#78-type_config-details-per-field-type)
8. [Task Dependencies and Relationships](#8-task-dependencies-and-relationships)
9. [Task Templates and Recurrence](#9-task-templates-and-recurrence)
10. [Rate Limits](#10-rate-limits)
11. [Python Client Class (Reusable)](#11-python-client-class-reusable)
12. [Endpoint Quick Reference Table](#12-endpoint-quick-reference-table)
13. [Error Codes](#13-error-codes)
14. [Sources](#14-sources)

---

## 1. Authentication

The ClickUp API supports two authentication methods.

### Personal API Token

Used for testing, personal integrations, and scripts. Retrieve it from **Settings > Apps > API Token** in the ClickUp UI.

```
Authorization: pk_XXXXXXXXXXXXXXXXXXXXXXXX
```

### OAuth 2.0

Required for building apps for other users. Uses the authorization code flow with access tokens.

```
Authorization: Bearer {access_token}
```

All examples in this document use the Personal API Token pattern.

```python
HEADERS = {
    "Authorization": "pk_YOUR_TOKEN_HERE",
    "Content-Type": "application/json"
}
```

```bash
# curl example
curl -H "Authorization: pk_YOUR_TOKEN_HERE" \
     -H "Content-Type: application/json" \
     https://api.clickup.com/api/v2/team
```

---

## 2. Task CRUD Operations

### 2.1 Create Task

**Endpoint:** `POST /v2/list/{list_id}/task`

Creates a new task in the specified list. `name` is the only required field.

**Path Parameters:**

| Parameter | Type   | Required | Description                     |
|-----------|--------|----------|---------------------------------|
| list_id   | number | Yes      | The numeric ID of the target list |

**Request Body Fields:**

| Field                        | Type           | Required | Description |
|------------------------------|----------------|----------|-------------|
| name                         | string         | Yes      | Task name |
| description                  | string         | No       | Plain text description |
| markdown_content             | string         | No       | Markdown description. If both `description` and `markdown_content` are provided, `markdown_content` wins |
| assignees                    | integer[]      | No       | Array of user IDs to assign |
| group_assignees              | string[]       | No       | Array of user group UUIDs to assign |
| tags                         | string[]       | No       | Array of tag name strings |
| status                       | string         | No       | Status name matching one defined in the list (e.g., `"Open"`, `"in progress"`) |
| priority                     | integer / null | No       | 1=Urgent, 2=High, 3=Normal, 4=Low. Send `null` to clear |
| due_date                     | integer (int64)| No       | Unix timestamp in milliseconds |
| due_date_time                | boolean        | No       | `true` to include time component in due_date display |
| start_date                   | integer (int64)| No       | Unix timestamp in milliseconds |
| start_date_time              | boolean        | No       | `true` to include time component in start_date display |
| time_estimate                | integer (int32)| No       | Time estimate in milliseconds |
| points                       | number         | No       | Sprint Points value |
| notify_all                   | boolean        | No       | If `true`, the task creator is also notified. All assignees and watchers are always notified regardless |
| parent                       | string / null  | No       | Task ID of the parent task. Set this to create a subtask. The parent must be in the same list |
| links_to                     | string / null  | No       | Task ID to create a linked dependency with the new task |
| check_required_custom_fields | boolean        | No       | Default `false`. Set `true` to enforce required Custom Fields on creation |
| custom_fields                | array          | No       | Array of `{id, value}` objects to set custom fields on creation |
| archived                     | boolean        | No       | Create the task in an archived state |
| custom_item_id               | number / null  | No       | Custom task type ID. `null` = standard "Task" type |

**Complete curl Example:**

```bash
curl -X POST "https://api.clickup.com/api/v2/list/123456/task" \
  -H "Authorization: pk_YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Task Name",
    "description": "New Task Description",
    "assignees": [183],
    "tags": ["feature", "sprint-1"],
    "status": "Open",
    "priority": 3,
    "due_date": 1508369194377,
    "due_date_time": false,
    "time_estimate": 8640000,
    "start_date": 1567780450202,
    "start_date_time": false,
    "points": 3,
    "notify_all": true,
    "parent": null,
    "links_to": null,
    "check_required_custom_fields": true,
    "custom_fields": [
      {"id": "0a52c486-5f05-403b-b4fd-c512ff05131c", "value": 23},
      {"id": "03efda77-c7a0-42d3-8afd-fd546353c2f5", "value": "Text field input"}
    ]
  }'
```

**Python Example:**

```python
import requests

def create_task(list_id, token, name, **kwargs):
    url = f"https://api.clickup.com/api/v2/list/{list_id}/task"
    headers = {
        "Authorization": token,
        "Content-Type": "application/json"
    }
    payload = {"name": name, **kwargs}
    response = requests.post(url, headers=headers, json=payload)
    response.raise_for_status()
    return response.json()

# Example usage
task = create_task(
    list_id=123456,
    token="pk_YOUR_TOKEN",
    name="Build login page",
    description="Create OAuth2 login with Google",
    assignees=[183, 224],
    priority=2,
    due_date=1720000000000,
    tags=["frontend", "auth"],
    status="Open",
    check_required_custom_fields=True
)
print(f"Created task ID: {task['id']}")
```

**Response (200 OK):**

```json
{
  "id": "9hx",
  "custom_id": null,
  "custom_item_id": null,
  "name": "New Task Name",
  "text_content": "New Task Content",
  "description": "New Task Content",
  "markdown_description": "New Task Content",
  "status": {
    "status": "in progress",
    "color": "#d3d3d3",
    "orderindex": 1,
    "type": "custom"
  },
  "orderindex": "1.00000000000000000000000000000000",
  "date_created": "1567780450202",
  "date_updated": "1567780450202",
  "date_closed": null,
  "date_done": null,
  "creator": {
    "id": 183,
    "username": "John Doe",
    "color": "#827718",
    "profilePicture": "https://attachments-public.clickup.com/profilePictures/183_abc.jpg"
  },
  "assignees": [],
  "archived": false,
  "group_assignees": [],
  "tags": [],
  "parent": "abc1234",
  "priority": {
    "color": "6fddff",
    "id": "3",
    "orderindex": "3",
    "priority": "normal"
  },
  "due_date": null,
  "start_date": null,
  "points": 3,
  "time_estimate": null,
  "time_spent": null,
  "custom_fields": [
    {
      "id": "0a52c486-5f05-403b-b4fd-c512ff05131c",
      "name": "My Text Custom field",
      "type": "text",
      "type_config": {},
      "date_created": "1622176979540",
      "hide_from_guests": false,
      "value": {"value": "This is a string of text added to a Custom Field."},
      "required": true
    }
  ],
  "list": {"id": "123"},
  "folder": {"id": "456"},
  "space": {"id": "789"},
  "url": "https://app.clickup.com/t/9hx"
}
```

---

### 2.2 Get Task

**Endpoint:** `GET /v2/task/{task_id}`

Retrieve a single task by its ID.

**Path Parameters:**

| Parameter | Type   | Required | Description                     |
|-----------|--------|----------|---------------------------------|
| task_id   | string | Yes      | The task ID (e.g., `"9hx"`) |

**Query Parameters:**

| Parameter       | Type    | Description |
|-----------------|---------|-------------|
| custom_task_ids | boolean | Set `true` to reference the task by Custom Task ID instead of system ID |
| team_id         | number  | Required when `custom_task_ids=true` — the Workspace ID |
| include_subtasks| boolean | Include subtask data in the response |

**curl Example:**

```bash
curl "https://api.clickup.com/api/v2/task/9hx" \
  -H "Authorization: pk_YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

**Python Example:**

```python
def get_task(task_id, token, include_subtasks=False):
    url = f"https://api.clickup.com/api/v2/task/{task_id}"
    headers = {"Authorization": token, "Content-Type": "application/json"}
    params = {}
    if include_subtasks:
        params["include_subtasks"] = True
    response = requests.get(url, headers=headers, params=params)
    response.raise_for_status()
    return response.json()
```

The response includes the full task object including its `custom_fields` array, `linked_tasks`, and `dependencies`.

---

### 2.3 Update Task

**Endpoint:** `PUT /v2/task/{task_id}`

Update one or more fields on an existing task. Include only the fields you want to change.

**Important:** The Update Task endpoint does NOT support updating Custom Fields. To update custom field values, use the `POST /v2/task/{task_id}/field/{field_id}` endpoint instead.

**Path Parameters:**

| Parameter | Type   | Required | Description |
|-----------|--------|----------|-------------|
| task_id   | string | Yes      | Task ID to update |

**Query Parameters:**

| Parameter       | Type    | Description |
|-----------------|---------|-------------|
| custom_task_ids | boolean | Reference by Custom Task ID |
| team_id         | number  | Workspace ID (required when `custom_task_ids=true`) |

**Request Body Fields:**

| Field             | Type           | Description |
|-------------------|----------------|-------------|
| name              | string         | New task name |
| description       | string         | New description. To clear, send `" "` (space) |
| markdown_content  | string         | Markdown description — overrides `description` if both sent |
| status            | string         | New status name |
| priority          | integer        | 1=Urgent, 2=High, 3=Normal, 4=Low |
| due_date          | integer (int64)| Unix ms timestamp |
| due_date_time     | boolean        | Show time on due date |
| start_date        | integer (int64)| Unix ms timestamp |
| start_date_time   | boolean        | Show time on start date |
| time_estimate     | integer (int32)| Time in milliseconds |
| points            | number         | Sprint Points |
| parent            | string         | Move task to a different parent (cannot set to `null` to un-subtask) |
| archived          | boolean        | Archive or unarchive |
| assignees         | object         | `{"add": [user_id], "rem": [user_id]}` — add/remove individual assignees |
| group_assignees   | object         | `{"add": [group_uuid], "rem": [group_uuid]}` |
| watchers          | object         | `{"add": [user_id], "rem": [user_id]}` |

**curl Example:**

```bash
curl -X PUT "https://api.clickup.com/api/v2/task/9hx" \
  -H "Authorization: pk_YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Task Name",
    "status": "in progress",
    "priority": 1,
    "due_date": 1508369194377,
    "assignees": {
      "add": [182],
      "rem": [183]
    }
  }'
```

**Python Example:**

```python
def update_task(task_id, token, **fields):
    url = f"https://api.clickup.com/api/v2/task/{task_id}"
    headers = {"Authorization": token, "Content-Type": "application/json"}
    response = requests.put(url, headers=headers, json=fields)
    response.raise_for_status()
    return response.json()

# Example: change status and add an assignee
update_task(
    task_id="9hx",
    token="pk_YOUR_TOKEN",
    status="in progress",
    priority=2,
    assignees={"add": [182], "rem": []}
)
```

---

### 2.4 Delete Task

**Endpoint:** `DELETE /v2/task/{task_id}`

Permanently delete a task from your Workspace.

**Path Parameters:**

| Parameter | Type   | Required | Description |
|-----------|--------|----------|-------------|
| task_id   | string | Yes      | Task ID to delete |

**Query Parameters:**

| Parameter       | Type    | Description |
|-----------------|---------|-------------|
| custom_task_ids | boolean | Reference by Custom Task ID |
| team_id         | number  | Workspace ID (required when `custom_task_ids=true`) |

**Response:** `204 No Content` on success with an empty JSON object `{}`.

**curl Example:**

```bash
curl -X DELETE "https://api.clickup.com/api/v2/task/9hx" \
  -H "Authorization: pk_YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

**Python Example:**

```python
def delete_task(task_id, token):
    url = f"https://api.clickup.com/api/v2/task/{task_id}"
    headers = {"Authorization": token, "Content-Type": "application/json"}
    response = requests.delete(url, headers=headers)
    response.raise_for_status()
    return True  # 204 = success

delete_task("9hx", "pk_YOUR_TOKEN")
```

---

## 3. Task Fields Reference

Complete field reference for Create/Update Task operations.

### Priority Mapping

| API Value | Label  |
|-----------|--------|
| 1         | Urgent |
| 2         | High   |
| 3         | Normal |
| 4         | Low    |
| null      | (none) |

Priority values cannot be customized — these four levels are fixed.

### Date Fields

All date fields accept Unix timestamps in **milliseconds** (int64). To get the current time in milliseconds in Python:

```python
import time
now_ms = int(time.time() * 1000)
```

The `due_date_time` and `start_date_time` flags control whether ClickUp displays the time component in the UI. Set to `false` to show date-only.

### Description Formatting

You can use either `description` (plain text) or `markdown_content` (Markdown). If both are provided in the same request, `markdown_content` takes precedence.

Supported Markdown features include: headers, emphasis (bold/italic), ordered/unordered lists, images, links, blockquotes, inline code.

To include literal double quotes in descriptions, escape them:

```json
"description": "She said \"hello\" to everyone."
```

### Assignees Behavior

- **On Create:** `assignees` is a flat array of user IDs — `[183, 224]`
- **On Update:** `assignees` is an add/remove object — `{"add": [182], "rem": [183]}`

This is a critical API inconsistency to be aware of.

### time_estimate

`time_estimate` values are in **milliseconds**. Common conversions:

| Duration | Milliseconds |
|----------|-------------|
| 1 hour   | 3,600,000   |
| 1 day (8h)| 28,800,000 |
| 1 week   | 144,000,000 |

### notify_all

When `notify_all` is `true`, the task creator is also notified. All assignees and watchers are always notified regardless of this flag.

---

## 4. Subtask Creation and Management

Subtasks are created the same as regular tasks, with the addition of the `parent` field pointing to the parent task's ID.

**Key rules:**
- The parent task must reside in the same list as the new subtask (specified in the path parameter)
- A subtask's parent can itself be a subtask (nested subtasks are supported)
- You cannot convert a subtask back to a top-level task by setting `parent` to `null` via the Update Task endpoint

### Creating a Subtask

```bash
curl -X POST "https://api.clickup.com/api/v2/list/123456/task" \
  -H "Authorization: pk_YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Subtask: Write unit tests",
    "parent": "9hx",
    "assignees": [183],
    "priority": 3
  }'
```

```python
def create_subtask(list_id, parent_task_id, token, name, **kwargs):
    return create_task(
        list_id=list_id,
        token=token,
        name=name,
        parent=parent_task_id,
        **kwargs
    )

subtask = create_subtask(
    list_id=123456,
    parent_task_id="9hx",
    token="pk_YOUR_TOKEN",
    name="Write unit tests",
    priority=3,
    assignees=[183]
)
```

### Retrieving Subtasks

When fetching the parent task, subtasks are not included by default. Use `include_subtasks=true` on the Get Task endpoint:

```bash
curl "https://api.clickup.com/api/v2/task/9hx?include_subtasks=true" \
  -H "Authorization: pk_YOUR_TOKEN"
```

When fetching a list of tasks, add `subtasks=true` to include subtasks of tasks in the response:

```bash
curl "https://api.clickup.com/api/v2/list/123456/task?subtasks=true" \
  -H "Authorization: pk_YOUR_TOKEN"
```

### Moving a Subtask to a Different Parent

Use the Update Task endpoint with the new `parent` task ID:

```python
update_task("subtask_id", token, parent="new_parent_task_id")
```

---

## 5. Bulk Task Operations

ClickUp API v2 does not provide a dedicated single-endpoint bulk create or bulk update operation for tasks. Bulk operations must be implemented at the application level by batching individual requests while respecting rate limits.

### Pattern: Bulk Create with Rate Limiting

```python
import requests
import time

def bulk_create_tasks(list_id, token, tasks, delay_seconds=0.1):
    """
    Create multiple tasks with a delay between requests to avoid rate limits.
    tasks: list of dicts, each with at minimum {"name": "..."}
    """
    created = []
    errors = []

    for task_data in tasks:
        try:
            result = create_task(list_id, token, **task_data)
            created.append(result)
            time.sleep(delay_seconds)  # 100ms delay between requests
        except requests.HTTPError as e:
            if e.response.status_code == 429:
                # Rate limited — wait and retry
                print("Rate limited, waiting 60 seconds...")
                time.sleep(60)
                result = create_task(list_id, token, **task_data)
                created.append(result)
            else:
                errors.append({"task": task_data, "error": str(e)})

    return created, errors

# Example
tasks_to_create = [
    {"name": "Task A", "priority": 2, "assignees": [183]},
    {"name": "Task B", "priority": 3, "tags": ["bug"]},
    {"name": "Task C", "priority": 1, "due_date": 1720000000000},
]

created, errors = bulk_create_tasks(123456, "pk_YOUR_TOKEN", tasks_to_create)
print(f"Created {len(created)} tasks, {len(errors)} errors")
```

### Pattern: Bulk Update Custom Field Across Many Tasks

A common pattern is setting the same custom field value on a large number of tasks. Use a paginated Get Tasks call to retrieve all task IDs, then iterate with Set Custom Field Value:

```python
def bulk_set_custom_field(list_id, field_id, value, token):
    """Set the same custom field value on all tasks in a list."""
    page = 0
    updated_count = 0

    while True:
        # Get page of tasks
        tasks_url = f"https://api.clickup.com/api/v2/list/{list_id}/task"
        headers = {"Authorization": token, "Content-Type": "application/json"}
        params = {"page": page, "include_closed": True}

        resp = requests.get(tasks_url, headers=headers, params=params)
        tasks = resp.json().get("tasks", [])

        if not tasks:
            break

        for task in tasks:
            field_url = f"https://api.clickup.com/api/v2/task/{task['id']}/field/{field_id}"
            requests.post(field_url, headers=headers, json={"value": value})
            updated_count += 1
            time.sleep(0.05)  # 50ms between requests

        page += 1

    return updated_count
```

---

## 6. Task Filtering

### 6.1 Get Tasks (List-scoped)

**Endpoint:** `GET /v2/list/{list_id}/task`

Returns tasks from a specific list. Responses are limited to **100 tasks per page**. Only returns tasks where `list_id` is their *home* list (tasks added from other lists are excluded by default; use `include_timl=true` to include them).

**Path Parameters:**

| Parameter | Type   | Required | Description |
|-----------|--------|----------|-------------|
| list_id   | number | Yes      | The list to retrieve tasks from |

**Query Parameters:**

| Parameter       | Type    | Default | Description |
|-----------------|---------|---------|-------------|
| archived        | boolean | false   | Return only archived tasks |
| page            | integer | 0       | Page number (0-indexed). Each page returns up to 100 tasks |
| order_by        | string  | —       | Field to order by: `id`, `created`, `updated`, `due_date` |
| reverse         | boolean | false   | Reverse the sort order |
| subtasks        | boolean | false   | Include subtasks in results |
| statuses[]      | string  | —       | Filter by status name(s) — repeatable: `?statuses[]=Open&statuses[]=In+Progress` |
| include_closed  | boolean | false   | Include tasks with a "closed" status type |
| assignees[]     | integer | —       | Filter by assignee user ID(s) — repeatable |
| due_date_gt     | integer | —       | Return tasks with due date after this Unix ms timestamp |
| due_date_lt     | integer | —       | Return tasks with due date before this Unix ms timestamp |
| date_created_gt | integer | —       | Created after Unix ms timestamp |
| date_created_lt | integer | —       | Created before Unix ms timestamp |
| date_updated_gt | integer | —       | Updated after Unix ms timestamp |
| date_updated_lt | integer | —       | Updated before Unix ms timestamp |
| custom_fields   | string  | —       | JSON array string of custom field filter objects (see Section 7.7) |
| include_timl    | boolean | false   | Include tasks added to this list that have a different home list |
| tags[]          | string  | —       | Filter by tag name(s) |

**curl Example — Filtered Tasks:**

```bash
curl "https://api.clickup.com/api/v2/list/123456/task?page=0&order_by=due_date&reverse=false&subtasks=true&include_closed=false&assignees[]=183&due_date_gt=1700000000000&due_date_lt=1730000000000&statuses[]=Open&statuses[]=in+progress" \
  -H "Authorization: pk_YOUR_TOKEN"
```

**Python Example — Paginated Retrieval:**

```python
def get_all_tasks(list_id, token, **filters):
    """Retrieve all tasks from a list, handling pagination."""
    headers = {"Authorization": token, "Content-Type": "application/json"}
    all_tasks = []
    page = 0

    while True:
        url = f"https://api.clickup.com/api/v2/list/{list_id}/task"
        params = {"page": page, **filters}

        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        data = response.json()

        tasks = data.get("tasks", [])
        if not tasks:
            break

        all_tasks.extend(tasks)
        page += 1
        time.sleep(0.1)

    return all_tasks

# Get all open tasks assigned to user 183, due in the next 30 days
import time
now = int(time.time() * 1000)
thirty_days = now + (30 * 24 * 60 * 60 * 1000)

tasks = get_all_tasks(
    list_id=123456,
    token="pk_YOUR_TOKEN",
    statuses=["Open", "in progress"],
    assignees=[183],
    due_date_gt=now,
    due_date_lt=thirty_days,
    subtasks=True
)
print(f"Found {len(tasks)} tasks")
```

---

### 6.2 Get Filtered Team Tasks (Workspace-scoped)

**Endpoint:** `GET /v2/team/{team_id}/task`

Search tasks across the entire Workspace (not limited to a single list). Also limited to **100 tasks per page**.

**Path Parameters:**

| Parameter | Type   | Required | Description |
|-----------|--------|----------|-------------|
| team_id   | number | Yes      | The Workspace (team) ID |

**Query Parameters (all optional):**

| Parameter        | Type    | Description |
|------------------|---------|-------------|
| page             | integer | 0-indexed page number |
| order_by         | string  | `id`, `created`, `updated`, `due_date` |
| reverse          | boolean | Reverse sort |
| subtasks         | boolean | Include subtasks |
| space_ids[]      | integer | Filter by Space ID(s) |
| project_ids[]    | integer | Filter by Folder ID(s) |
| list_ids[]       | integer | Filter by List ID(s) |
| statuses[]       | string  | Filter by status name(s) |
| include_closed   | boolean | Include closed tasks |
| assignees[]      | integer | Filter by assignee user ID(s) |
| tags[]           | string  | Filter by tag(s) |
| due_date_gt      | integer | Due after Unix ms |
| due_date_lt      | integer | Due before Unix ms |
| date_created_gt  | integer | Created after Unix ms |
| date_created_lt  | integer | Created before Unix ms |
| date_updated_gt  | integer | Updated after Unix ms |
| date_updated_lt  | integer | Updated before Unix ms |
| custom_fields[]  | string  | Stringified JSON array of custom field filter objects |
| me_mode          | boolean | When `true`, filter to only tasks assigned to the authenticated user |

**curl Example:**

```bash
curl "https://api.clickup.com/api/v2/team/9876543/task?page=0&list_ids[]=123456&list_ids[]=789012&assignees[]=183&statuses[]=Open&include_closed=false" \
  -H "Authorization: pk_YOUR_TOKEN"
```

---

## 7. Custom Fields

Custom fields in ClickUp allow you to attach arbitrary structured data to tasks. You cannot create new custom field *types* through the public API v2 — field definitions must be created in the ClickUp UI. Once created, you can read field metadata, set values on tasks, and filter by custom field values via the API.

The workflow for working with custom fields:

1. Create the custom field in the ClickUp UI (Space or List level)
2. Use `GET /v2/list/{list_id}/field` to discover available fields and retrieve their UUIDs
3. Set values using `POST /v2/task/{task_id}/field/{field_id}`
4. Read values from the `custom_fields` array in any task response

---

### 7.1 Custom Field Types Reference

| API Type Name       | UI Name           | Value Format |
|---------------------|-------------------|--------------|
| `text`              | Long Text         | string |
| `short_text`        | Short Text        | string |
| `number`            | Number            | number |
| `currency`          | Money             | number (amount only, not currency) |
| `checkbox`          | Checkbox          | boolean |
| `drop_down`         | Dropdown          | string (UUID of the chosen option) |
| `labels`            | Labels            | string[] (array of option UUIDs) |
| `date`              | Date              | integer (Unix ms) + optional `value_options.time` |
| `url`               | Website/URL       | string (valid URL) |
| `email`             | Email             | string (valid email) |
| `phone`             | Phone             | string (with country code) |
| `emoji`             | Rating (Emoji)    | integer (0 to field's `count`) |
| `manual_progress`   | Progress (Manual) | object: `{"current": number}` |
| `automatic_progress`| Progress (Auto)   | Read-only — cannot be set via API |
| `users`             | People            | object: `{"add": [user_id], "rem": [user_id]}` |
| `tasks`             | Task Relationship | object: `{"add": [task_id], "rem": [task_id]}` |
| `location`          | Location          | object: `{location: {lat, lng}, formatted_address}` |

**Notes:**
- Voting Custom Field values are returned in the API but **cannot be set** via the API
- Free Forever plans have a limit of 60 custom field uses total across the entire Workspace (uses do not reset)
- `automatic_progress` is calculated by ClickUp based on subtask/checklist completion — you cannot set it directly

---

### 7.2 Get List Custom Fields

**Endpoint:** `GET /v2/list/{list_id}/field`

Returns all custom fields accessible in the specified list.

**curl Example:**

```bash
curl "https://api.clickup.com/api/v2/list/123456/field" \
  -H "Authorization: pk_YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

**Python Example:**

```python
def get_custom_fields(list_id, token):
    url = f"https://api.clickup.com/api/v2/list/{list_id}/field"
    headers = {"Authorization": token, "Content-Type": "application/json"}
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json().get("fields", [])

fields = get_custom_fields(123456, "pk_YOUR_TOKEN")
for f in fields:
    print(f"Field: {f['name']} | Type: {f['type']} | ID: {f['id']}")
```

**Response Example:**

```json
{
  "fields": [
    {
      "id": "03efda77-c7a0-42d3-8afd-fd546353c2f5",
      "name": "Text Field",
      "type": "text",
      "type_config": {},
      "date_created": "1566400407303",
      "hide_from_guests": false
    },
    {
      "id": "5dc86497-098d-4bb0-87d6-cf28e43812e7",
      "name": "Priority Score",
      "type": "number",
      "type_config": {},
      "date_created": "1577378759142",
      "hide_from_guests": false
    },
    {
      "id": "a1b2c3d4-0000-0000-0000-111122223333",
      "name": "Quarter",
      "type": "drop_down",
      "type_config": {
        "sorting": "manual",
        "default": 0,
        "placeholder": "Select a quarter",
        "options": [
          {"id": "opt_uuid_q1", "name": "Q1 2025", "color": "#FF0000", "orderindex": "0"},
          {"id": "opt_uuid_q2", "name": "Q2 2025", "color": "#00FF00", "orderindex": "1"}
        ]
      },
      "date_created": "1622176979540",
      "hide_from_guests": false
    }
  ]
}
```

---

### 7.3 Set Custom Field Value on a Task

**Endpoint:** `POST /v2/task/{task_id}/field/{field_id}`

Set or update a custom field value on a specific task.

**Path Parameters:**

| Parameter | Type   | Required | Description |
|-----------|--------|----------|-------------|
| task_id   | string | Yes      | Task ID to update |
| field_id  | string | Yes      | UUID of the custom field to set |

**Query Parameters:**

| Parameter       | Type    | Description |
|-----------------|---------|-------------|
| custom_task_ids | boolean | Reference task by Custom Task ID |
| team_id         | number  | Workspace ID (required when `custom_task_ids=true`) |

**Request Body:** Always `{"value": <typed_value>}`. The exact format depends on the field type (see below).

**Python Helper:**

```python
def set_custom_field(task_id, field_id, value, token, value_options=None):
    url = f"https://api.clickup.com/api/v2/task/{task_id}/field/{field_id}"
    headers = {"Authorization": token, "Content-Type": "application/json"}
    payload = {"value": value}
    if value_options:
        payload["value_options"] = value_options
    response = requests.post(url, headers=headers, json=payload)
    response.raise_for_status()
    return response.json()
```

**Value Format by Field Type:**

#### Text / Short Text
```json
{"value": "Some text content here"}
```

#### Number
```json
{"value": -28}
```

#### Currency (Money)
```json
{"value": 8000}
```
Note: You can only set the amount, not the currency. Currency is configured in the field's `type_config`.

#### Checkbox
```json
{"value": true}
```

#### Dropdown
The value must be the UUID of an existing option from `type_config.options`. New options cannot be created via this endpoint.
```json
{"value": "opt_uuid_q1"}
```

#### Labels
Array of option UUIDs. Existing labels on the task are **overwritten** (not appended).
```json
{"value": ["uuid1234", "uuid9876"]}
```

#### Date
Unix timestamp in milliseconds. To display time in ClickUp UI, include `value_options.time: true`.
```json
{
  "value": 1667367645000,
  "value_options": {"time": true}
}
```

#### URL
```json
{"value": "https://example.com/page"}
```

#### Email
```json
{"value": "user@company.com"}
```

#### Phone
Must include country code.
```json
{"value": "+1 201 555 0123"}
```

#### Emoji / Rating
Integer from 0 to the field's `count` (max 5). Find `count` in `type_config`.
```json
{"value": 4}
```

#### Manual Progress
Send the current progress value. The percentage displayed = `(current - start) / (end - start)`. For a field with `start: 0, end: 100`, sending `current: 75` displays 75%.
```json
{"value": {"current": 75}}
```

#### People (Users Custom Field)
```json
{
  "value": {
    "add": [183, 224],
    "rem": [101]
  }
}
```

#### Task Relationship
```json
{
  "value": {
    "add": ["task_id_abc", "task_id_def"],
    "rem": ["task_id_xyz"]
  }
}
```

#### Location
Follows Google Maps Geocoding API format.
```json
{
  "value": {
    "location": {
      "lat": -28.016667,
      "lng": 153.4
    },
    "formatted_address": "Gold Coast QLD, Australia"
  }
}
```

**Complete curl Examples:**

```bash
# Set a text field
curl -X POST "https://api.clickup.com/api/v2/task/9hx/field/03efda77-c7a0-42d3-8afd-fd546353c2f5" \
  -H "Authorization: pk_YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value": "Sprint 7 deliverable"}'

# Set a dropdown field
curl -X POST "https://api.clickup.com/api/v2/task/9hx/field/a1b2c3d4-0000-0000-0000-111122223333" \
  -H "Authorization: pk_YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value": "opt_uuid_q2"}'

# Set a date field with time display
curl -X POST "https://api.clickup.com/api/v2/task/9hx/field/date-field-uuid-here" \
  -H "Authorization: pk_YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"value": 1667367645000, "value_options": {"time": true}}'
```

**Response:** `200 OK` with an empty JSON object `{}`.

---

### 7.4 Remove Custom Field Value

**Endpoint:** `DELETE /v2/task/{task_id}/field/{field_id}`

Clears the value of a custom field on a task. Does not delete the field definition itself — only clears the data for that task.

```bash
curl -X DELETE "https://api.clickup.com/api/v2/task/9hx/field/03efda77-c7a0-42d3-8afd-fd546353c2f5" \
  -H "Authorization: pk_YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

Some field types (Tasks, People, Manual Progress) are also nullable by passing `"value": null`:

```json
{"value": null}
```

---

### 7.5 Setting Custom Fields on Task Create

You can set multiple custom fields in the same request when creating a task via the `custom_fields` array. Each entry requires `id` (field UUID) and `value` (typed value for that field type):

```bash
curl -X POST "https://api.clickup.com/api/v2/list/123456/task" \
  -H "Authorization: pk_YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Client Onboarding",
    "check_required_custom_fields": true,
    "custom_fields": [
      {
        "id": "0a52c486-5f05-403b-b4fd-c512ff05131c",
        "value": "Acme Corp"
      },
      {
        "id": "b1c2d3e4-1111-2222-3333-444455556666",
        "value": 50000
      },
      {
        "id": "a1b2c3d4-0000-0000-0000-111122223333",
        "value": "opt_uuid_q2"
      }
    ]
  }'
```

Note: `check_required_custom_fields: true` enforces any fields marked as required. The default is `false` (required fields are ignored on creation via API).

---

### 7.6 Reading Custom Field Values from Task Responses

Every task response (Get Task, Get Tasks, Create Task, Update Task) includes a `custom_fields` array. Each element in the array contains:

```json
{
  "id": "0a52c486-5f05-403b-b4fd-c512ff05131c",
  "name": "Client Name",
  "type": "text",
  "type_config": {},
  "date_created": "1622176979540",
  "hide_from_guests": false,
  "value": "Acme Corp",
  "required": true
}
```

The `value` field's type and structure mirror what you set (see field type reference in Section 7.3). Fields with no value set will still appear in the array but will have `value` as `null` or absent.

**Python Example — Extract All Custom Field Values:**

```python
def extract_custom_fields(task):
    """Return a dict of {field_name: value} from a task object."""
    result = {}
    for field in task.get("custom_fields", []):
        name = field.get("name")
        value = field.get("value")
        result[name] = value
    return result

task = get_task("9hx", "pk_YOUR_TOKEN")
fields = extract_custom_fields(task)
print(fields)
# {"Client Name": "Acme Corp", "Budget": 50000, "Quarter": "opt_uuid_q2"}
```

**Important note on Date fields:** When retrieving a task with a Date Custom Field that does not display time (time display is off), the API returns the Unix timestamp set to 4:00 AM in the authorized user's timezone.

---

### 7.7 Custom Field Filtering in Queries

You can filter tasks by custom field values in both `GET /v2/list/{list_id}/task` and `GET /v2/team/{team_id}/task`.

The `custom_fields` query parameter accepts a **stringified JSON array** of filter objects. Each filter object requires three properties:

| Property | Description |
|----------|-------------|
| `field_id` | UUID of the custom field |
| `operator` | Comparison operator (see table below) |
| `value`    | The value to compare against |

**Supported Operators:**

| Operator  | Meaning |
|-----------|---------|
| `=`       | Contains (fuzzy match) — for text fields |
| `==`      | Exact match — for text fields |
| `!=`      | Does not contain — for text fields |
| `!==`     | Does not exactly match — for text fields |
| `>`       | Greater than — for number, currency, date fields |
| `>=`      | Greater than or equal to |
| `<`       | Less than |
| `<=`      | Less than or equal to |
| `ANY`     | Matches any of the values |
| `NOT ANY` | Does not match any of the values |
| `ALL`     | Matches all of the values |
| `NOT ALL` | Does not match all criteria |
| `RANGE`   | Is between (requires two values) |
| `IS NOT NULL` | Field has a value set |
| `IS NULL` | Field has no value set |

**Example: Filter by Number Field > 2**

```
GET /v2/list/123456/task?custom_fields=[{"field_id":"de761538-8ae0-42e8-91d9-f1a0cdfbd8b5","operator":">","value":2}]
```

**Example: Filter by Text Field Containing "project"**

```
GET /v2/list/123456/task?custom_fields=[{"field_id":"ac123456-8ae0-42e8-91d9-f1a0cdfb1ce7","operator":"=","value":"project"}]
```

**Example: Filter by People Custom Field (user IDs)**

```json
[{
  "field_id": "bd12538-4cf0-51f3-13h1-a1c0bedae3f7",
  "operator": "ANY",
  "value": ["user_id_1", "user_id_2"]
}]
```

**Python Example — Custom Field Filter in Get Tasks:**

```python
import json
import requests

def get_tasks_by_custom_field(list_id, field_id, operator, value, token):
    url = f"https://api.clickup.com/api/v2/list/{list_id}/task"
    headers = {"Authorization": token, "Content-Type": "application/json"}

    custom_field_filter = json.dumps([{
        "field_id": field_id,
        "operator": operator,
        "value": value
    }])

    params = {
        "custom_fields": custom_field_filter,
        "include_closed": True
    }

    response = requests.get(url, headers=headers, params=params)
    response.raise_for_status()
    return response.json().get("tasks", [])

# Find all tasks where "Budget" field is greater than 10000
tasks = get_tasks_by_custom_field(
    list_id=123456,
    field_id="b1c2d3e4-1111-2222-3333-444455556666",
    operator=">",
    value=10000,
    token="pk_YOUR_TOKEN"
)
```

---

### 7.8 type_config Details Per Field Type

The `type_config` object defines the configuration and acceptable values for a custom field. Returned by `GET /v2/list/{list_id}/field`.

**Dropdown:**
```json
{
  "sorting": "manual",
  "default": 0,
  "placeholder": "Select a value",
  "options": [
    {"id": "option_1_id", "name": "Option 1", "color": "#FFFFFF", "orderindex": "0"},
    {"id": "option_2_id", "name": "Option 2", "color": "#000000", "orderindex": "1"}
  ]
}
```

**Labels:**
```json
{
  "sorting": "manual",
  "options": [
    {"id": "option_1_id", "label": "Label 1", "color": "#123456", "orderindex": "0"}
  ]
}
```

**Currency (Money):**
```json
{
  "precision": 2,
  "currency_type": "USD",
  "default": 0
}
```

**Emoji (Rating):**
```json
{
  "code_point": "1f613",
  "count": 5
}
```
The `code_point` is a Unicode emoji hex without `U+` prefix. `count` is the maximum rating value (1–5).

**Manual Progress:**
```json
{
  "method": "manual",
  "start": 0,
  "end": 100,
  "current": 50
}
```

**Automatic Progress:**
```json
{
  "method": "automatic",
  "tracking": {
    "subtasks": true,
    "assigned_comments": true,
    "checklists": true
  }
}
```

**People:**
```json
{
  "single_user": false,
  "include_groups": true,
  "include_guests": true,
  "include_team_members": true
}
```

---

## 8. Task Dependencies and Relationships

Tasks in ClickUp support two kinds of connections:

1. **Dependencies** — a blocking/waiting-on relationship that controls task completion order
2. **Linked Tasks** — informal links between related tasks without enforcing completion order

### 8.1 Add Dependency

**Endpoint:** `POST /v2/task/{task_id}/dependency`

Sets a task as *waiting on* or *blocking* another task. Only one relationship type per request.

**Path Parameter:** `task_id` — this is the task that is waiting on or blocking another.

**Request Body:**

| Field          | Type   | Description |
|----------------|--------|-------------|
| depends_on     | string | Task ID that must be completed *before* `task_id` (task_id is waiting on this) |
| dependency_of  | string | Task ID that is waiting for `task_id` to be completed (task_id is blocking this) |

Only one of `depends_on` or `dependency_of` can be used per request.

**curl Example:**

```bash
# Task 9hv is waiting on task 9hw to be done first
curl -X POST "https://api.clickup.com/api/v2/task/9hv/dependency" \
  -H "Authorization: pk_YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"depends_on": "9hw"}'

# Task 9hv is blocking task 9hz (9hz must wait for 9hv)
curl -X POST "https://api.clickup.com/api/v2/task/9hv/dependency" \
  -H "Authorization: pk_YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"dependency_of": "9hz"}'
```

**Python Example:**

```python
def add_dependency(task_id, token, depends_on=None, dependency_of=None):
    """
    depends_on: task_id that must complete BEFORE this task
    dependency_of: task_id that is WAITING on this task to complete
    """
    if not depends_on and not dependency_of:
        raise ValueError("Must specify either depends_on or dependency_of")
    if depends_on and dependency_of:
        raise ValueError("Only one of depends_on or dependency_of per request")

    url = f"https://api.clickup.com/api/v2/task/{task_id}/dependency"
    headers = {"Authorization": token, "Content-Type": "application/json"}

    payload = {}
    if depends_on:
        payload["depends_on"] = depends_on
    if dependency_of:
        payload["dependency_of"] = dependency_of

    response = requests.post(url, headers=headers, json=payload)
    response.raise_for_status()
    return response.json()

# "Deploy to production" (9hv) must wait for "Write tests" (9hw) to complete
add_dependency("9hv", "pk_YOUR_TOKEN", depends_on="9hw")
```

### 8.2 Delete Dependency

**Endpoint:** `DELETE /v2/task/{task_id}/dependency`

Remove a dependency relationship.

```bash
curl -X DELETE "https://api.clickup.com/api/v2/task/9hv/dependency?depends_on=9hw&task_id=9hw" \
  -H "Authorization: pk_YOUR_TOKEN"
```

### 8.3 Reading Dependencies from Task Responses

The `GET /v2/task/{task_id}` response includes both `linked_tasks` and `dependencies` arrays:

```json
{
  "linked_tasks": [
    {
      "task_id": "8xdfdjbgd",
      "link_id": "8xdfm9vmz",
      "date_created": "1744930048464",
      "userid": "395492",
      "workspace_id": "333"
    }
  ],
  "dependencies": [
    {
      "task_id": "8xdfm9vmz",
      "depends_on": "8xdfe67cz",
      "type": 1,
      "date_created": "1744930371817",
      "userid": "395492",
      "workspace_id": "333",
      "chain_id": null
    }
  ]
}
```

The `type` field in a dependency: `1` = "depends on" (waiting on), `2` = "dependency of" (blocking).

### 8.4 Add/Remove Linked Task

Linked tasks are informal relationships with no enforcement semantics.

**Add link:** `POST /v2/task/{task_id}/link/{links_to_task_id}`

```bash
curl -X POST "https://api.clickup.com/api/v2/task/9hv/link/9hz" \
  -H "Authorization: pk_YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

**Remove link:** `DELETE /v2/task/{task_id}/link/{links_to_task_id}`

You can also set `links_to` when creating a task to establish an initial link.

---

## 9. Task Templates and Recurrence

### Task Templates

ClickUp does not expose a public API v2 endpoint for creating or listing task templates. Templates must be created and managed through the ClickUp UI. However, you can replicate "template" behavior programmatically by:

1. Maintaining a dictionary of template payloads in your code
2. Calling `POST /v2/list/{list_id}/task` with the full payload including pre-populated custom fields

```python
TASK_TEMPLATES = {
    "bug_report": {
        "status": "Open",
        "priority": 2,
        "tags": ["bug"],
        "custom_fields": [
            {"id": "severity-field-uuid", "value": "opt_high_uuid"},
            {"id": "environment-field-uuid", "value": "production"}
        ]
    },
    "feature_request": {
        "status": "Open",
        "priority": 3,
        "tags": ["feature", "backlog"]
    }
}

def create_from_template(list_id, token, template_name, name, **overrides):
    template = TASK_TEMPLATES.get(template_name, {})
    payload = {**template, "name": name, **overrides}
    return create_task(list_id, token, **payload)

# Create a bug report task
task = create_from_template(
    list_id=123456,
    token="pk_YOUR_TOKEN",
    template_name="bug_report",
    name="Login button not responding on Safari",
    assignees=[183]
)
```

### Recurrence

Recurring tasks are a feature in ClickUp's UI (available on Business plans and above), but there is no dedicated API v2 endpoint to programmatically set or retrieve recurrence rules on tasks.

To simulate recurrence via the API, you can use a scheduled job (e.g., Trigger.dev, cron) that creates new tasks on a schedule:

```python
# Example: create a weekly standup task every Monday
def create_weekly_task(list_id, token):
    import datetime
    monday = next_monday_timestamp()  # implement as needed

    return create_task(
        list_id=list_id,
        token=token,
        name=f"Weekly Standup - {datetime.date.today().strftime('%Y-%m-%d')}",
        status="Open",
        due_date=monday,
        assignees=[183, 224],
        tags=["standup", "recurring"]
    )
```

---

## 10. Rate Limits

| Scope              | Limit |
|--------------------|-------|
| Per workspace      | 100 requests per second |
| Per IP address     | 1,000 requests per 15 minutes |

When rate limited, the API returns HTTP `429 Too Many Requests`.

**Best Practice — Retry with Backoff:**

```python
import time
import requests

def api_call_with_retry(method, url, headers, json=None, params=None, max_retries=3):
    for attempt in range(max_retries):
        response = requests.request(method, url, headers=headers, json=json, params=params)

        if response.status_code == 429:
            wait = 2 ** attempt  # exponential backoff: 1s, 2s, 4s
            print(f"Rate limited. Waiting {wait}s before retry {attempt + 1}/{max_retries}")
            time.sleep(wait)
            continue

        response.raise_for_status()
        return response

    raise Exception(f"Failed after {max_retries} retries due to rate limiting")
```

---

## 11. Python Client Class (Reusable)

A minimal, production-ready Python client for the most common Task + Custom Field operations:

```python
import requests
import json
import time
from typing import Optional, List, Dict, Any


class ClickUpClient:
    BASE_URL = "https://api.clickup.com/api/v2"

    def __init__(self, token: str):
        self.headers = {
            "Authorization": token,
            "Content-Type": "application/json"
        }

    def _request(self, method: str, path: str, **kwargs) -> Dict:
        url = f"{self.BASE_URL}{path}"
        for attempt in range(3):
            response = requests.request(method, url, headers=self.headers, **kwargs)
            if response.status_code == 429:
                time.sleep(2 ** attempt)
                continue
            response.raise_for_status()
            return response.json() if response.content else {}
        raise Exception("Rate limit exceeded after 3 retries")

    # --- Tasks ---

    def create_task(self, list_id: int, name: str, **kwargs) -> Dict:
        return self._request("POST", f"/list/{list_id}/task", json={"name": name, **kwargs})

    def get_task(self, task_id: str, include_subtasks: bool = False) -> Dict:
        params = {"include_subtasks": True} if include_subtasks else {}
        return self._request("GET", f"/task/{task_id}", params=params)

    def update_task(self, task_id: str, **fields) -> Dict:
        return self._request("PUT", f"/task/{task_id}", json=fields)

    def delete_task(self, task_id: str) -> bool:
        self._request("DELETE", f"/task/{task_id}")
        return True

    def get_tasks(self, list_id: int, page: int = 0, **filters) -> List[Dict]:
        params = {"page": page, **filters}
        result = self._request("GET", f"/list/{list_id}/task", params=params)
        return result.get("tasks", [])

    def get_all_tasks(self, list_id: int, **filters) -> List[Dict]:
        all_tasks = []
        page = 0
        while True:
            tasks = self.get_tasks(list_id, page=page, **filters)
            if not tasks:
                break
            all_tasks.extend(tasks)
            page += 1
            time.sleep(0.1)
        return all_tasks

    # --- Subtasks ---

    def create_subtask(self, list_id: int, parent_task_id: str, name: str, **kwargs) -> Dict:
        return self.create_task(list_id, name, parent=parent_task_id, **kwargs)

    # --- Custom Fields ---

    def get_custom_fields(self, list_id: int) -> List[Dict]:
        result = self._request("GET", f"/list/{list_id}/field")
        return result.get("fields", [])

    def set_custom_field(self, task_id: str, field_id: str, value: Any,
                         value_options: Optional[Dict] = None) -> Dict:
        payload = {"value": value}
        if value_options:
            payload["value_options"] = value_options
        return self._request("POST", f"/task/{task_id}/field/{field_id}", json=payload)

    def remove_custom_field(self, task_id: str, field_id: str) -> Dict:
        return self._request("DELETE", f"/task/{task_id}/field/{field_id}")

    def get_tasks_by_custom_field(self, list_id: int, field_id: str,
                                   operator: str, value: Any) -> List[Dict]:
        cf_filter = json.dumps([{"field_id": field_id, "operator": operator, "value": value}])
        return self.get_tasks(list_id, custom_fields=cf_filter)

    # --- Dependencies ---

    def add_dependency(self, task_id: str, depends_on: str = None,
                       dependency_of: str = None) -> Dict:
        payload = {}
        if depends_on:
            payload["depends_on"] = depends_on
        elif dependency_of:
            payload["dependency_of"] = dependency_of
        else:
            raise ValueError("Must specify depends_on or dependency_of")
        return self._request("POST", f"/task/{task_id}/dependency", json=payload)


# Usage Example
if __name__ == "__main__":
    client = ClickUpClient("pk_YOUR_TOKEN_HERE")

    # Create a task
    task = client.create_task(
        list_id=123456,
        name="Integrate ClickUp API",
        description="Build the ClickUp integration module",
        priority=2,
        assignees=[183],
        tags=["integration", "backend"]
    )
    task_id = task["id"]
    print(f"Created: {task_id}")

    # Discover custom fields
    fields = client.get_custom_fields(123456)
    sprint_field = next(f for f in fields if f["name"] == "Sprint")

    # Set a custom field
    client.set_custom_field(task_id, sprint_field["id"], "opt_sprint_7_uuid")

    # Create a subtask
    subtask = client.create_subtask(
        list_id=123456,
        parent_task_id=task_id,
        name="Write integration tests",
        priority=3
    )

    # Add a dependency
    client.add_dependency(task_id, depends_on="blocker_task_id_here")

    # Filter tasks by custom field
    high_budget_tasks = client.get_tasks_by_custom_field(
        list_id=123456,
        field_id="budget-field-uuid",
        operator=">",
        value=50000
    )
    print(f"Found {len(high_budget_tasks)} high-budget tasks")
```

---

## 12. Endpoint Quick Reference Table

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/v2/list/{list_id}/task` | Create task |
| GET | `/v2/task/{task_id}` | Get single task |
| PUT | `/v2/task/{task_id}` | Update task |
| DELETE | `/v2/task/{task_id}` | Delete task |
| GET | `/v2/list/{list_id}/task` | Get tasks in a list (with filters) |
| GET | `/v2/team/{team_id}/task` | Get tasks across workspace (with filters) |
| GET | `/v2/list/{list_id}/field` | Get custom fields for a list |
| POST | `/v2/task/{task_id}/field/{field_id}` | Set custom field value on task |
| DELETE | `/v2/task/{task_id}/field/{field_id}` | Remove custom field value from task |
| POST | `/v2/task/{task_id}/dependency` | Add dependency (waiting on / blocking) |
| DELETE | `/v2/task/{task_id}/dependency` | Remove dependency |
| POST | `/v2/task/{task_id}/link/{links_to_task_id}` | Add linked task |
| DELETE | `/v2/task/{task_id}/link/{links_to_task_id}` | Remove linked task |

---

## 13. Error Codes

| HTTP Status | Meaning |
|-------------|---------|
| 200 | Success |
| 204 | Success, no content (Delete operations) |
| 400 | Bad Request — malformed JSON or invalid parameter values |
| 401 | Unauthorized — invalid or missing API token |
| 403 | Forbidden — token lacks permission for this resource |
| 404 | Not Found — task, list, or field ID does not exist |
| 429 | Too Many Requests — rate limit exceeded |
| 500 | Internal Server Error — ClickUp-side error |

**Example error response body:**

```json
{
  "err": "Team not found",
  "ECODE": "OAUTH_027"
}
```

---

## 14. Sources

| Resource | URL |
|----------|-----|
| ClickUp API Overview | https://developer.clickup.com/ |
| Tasks Overview Docs | https://developer.clickup.com/docs/tasks |
| Create Task Reference | https://developer.clickup.com/reference/createtask |
| Update Task Reference | https://developer.clickup.com/reference/updatetask |
| Delete Task Reference | https://developer.clickup.com/reference/deletetask |
| Get Tasks Reference | https://developer.clickup.com/reference/gettasks |
| Get Filtered Team Tasks | https://developer.clickup.com/reference/getfilteredteamtasks |
| Custom Fields Docs | https://developer.clickup.com/docs/customfields |
| Set Custom Field Value | https://developer.clickup.com/reference/setcustomfieldvalue |
| Get List Custom Fields | https://developer.clickup.com/reference/getaccessiblecustomfields |
| Filter by Custom Fields | https://developer.clickup.com/docs/taskfilters |
| Add Dependency | https://developer.clickup.com/reference/adddependency |
| Python Integration Guide | https://rollout.com/integration-guides/clickup/sdk/step-by-step-guide-to-building-a-clickup-api-integration-in-python |
| Custom Fields Practical Guide | https://consultevo.com/clickup-custom-fields-api-guide/ |
| ClickUp API Zuplo Guide | https://zuplo.com/learning-center/clickup-api |
