# ClickUp API v2 — Comments, Webhooks & Real-Time Events
**Source**: Official ClickUp Developer Docs (developer.clickup.com) + supplementary research
**Date Saved**: 2026-03-18
**API Version**: v2 (with notes on v3 where applicable)
**Base URL**: `https://api.clickup.com/api/v2`

---

## Table of Contents

1. [Authentication](#1-authentication)
2. [Comments API](#2-comments-api)
   - 2.1 Create Task Comment
   - 2.2 Get Task Comments
   - 2.3 Update Comment
   - 2.4 Delete Comment
   - 2.5 Threaded Comments & Replies
   - 2.6 Chat View Comments
   - 2.7 List Comments
3. [Task Attachments](#3-task-attachments)
4. [Webhooks API](#4-webhooks-api)
   - 4.1 Create Webhook
   - 4.2 List Webhooks
   - 4.3 Update Webhook
   - 4.4 Delete Webhook
5. [Webhook Event Types](#5-webhook-event-types)
6. [Webhook Payload Structure & Examples](#6-webhook-payload-structure--examples)
7. [Security — HMAC Signature Verification](#7-security--hmac-signature-verification)
8. [Webhook Health, Retry Behavior & Failure Handling](#8-webhook-health-retry-behavior--failure-handling)
9. [Filtering Webhooks by Scope](#9-filtering-webhooks-by-scope)
10. [Real-Time Use Cases for AI Automation](#10-real-time-use-cases-for-ai-automation)
11. [Activity Log / Audit Trail Endpoints](#11-activity-log--audit-trail-endpoints)
12. [Complete Python Implementation Reference](#12-complete-python-implementation-reference)
13. [Node.js Implementation Reference](#13-nodejs-implementation-reference)
14. [Gotchas & Known Limits](#14-gotchas--known-limits)
15. [Sources](#15-sources)

---

## 1. Authentication

ClickUp API v2 supports two authentication methods.

### Personal API Token
Used for testing and personal integrations. Obtain from: ClickUp Settings → Apps → API Token.

```
Authorization: pk_XXXXXXX
```

### OAuth 2.0
Required when building apps for other ClickUp users. Uses authorization code flow. Returns a Bearer token.

```
Authorization: Bearer {access_token}
```

Both token types are passed in the `Authorization` HTTP header. All requests must use HTTPS.

---

## 2. Comments API

Comments in ClickUp are associated with specific entities: tasks, lists, and chat views. The API provides full CRUD capabilities for task comments plus specialized endpoints for threaded replies and chat view comments.

### Endpoint Overview Table

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Create task comment | POST | `/v2/task/{task_id}/comment` |
| Get task comments | GET | `/v2/task/{task_id}/comment` |
| Update comment | PUT | `/v2/comment/{comment_id}` |
| Delete comment | DELETE | `/v2/comment/{comment_id}` |
| Get threaded comments | GET | `/v2/task/{task_id}/comment/threaded` |
| Create list comment | POST | `/v2/list/{list_id}/comment` |
| Get list comments | GET | `/v2/list/{list_id}/comment` |
| Create chat view comment | POST | `/v2/view/{view_id}/comment` |
| Get chat view comments | GET | `/v2/view/{view_id}/comment` |

---

### 2.1 Create Task Comment

**POST** `/v2/task/{task_id}/comment`

Adds a new comment to a task. Supports plain text, rich HTML content, and file attachments.

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `task_id` | string | Yes | The task ID (e.g., `9hz`) |

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_task_ids` | boolean | No | Set to `true` to reference tasks by custom task ID |
| `team_id` | number | No | Required when `custom_task_ids=true` |

#### Request Body

```json
{
  "comment_text": "This is the comment content",
  "assignee": 183,
  "notify_all": true
}
```

#### Request Body Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `comment_text` | string | Yes | The comment content (plain text or HTML) |
| `assignee` | integer | No | User ID to assign the comment to |
| `notify_all` | boolean | No | If `true`, notifies all watchers on the task |

#### Response (200)

```json
{
  "id": "458",
  "hist_id": "26508",
  "date": 1568037356074
}
```

#### cURL Example

```bash
curl -X POST \
  'https://api.clickup.com/api/v2/task/9hz/comment' \
  -H 'Authorization: pk_YOUR_API_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "comment_text": "Automated system check — all systems nominal.",
    "assignee": 183,
    "notify_all": true
  }'
```

#### Python Example

```python
import requests

task_id = "9hz"
url = f"https://api.clickup.com/api/v2/task/{task_id}/comment"

headers = {
    "Authorization": "pk_YOUR_API_TOKEN",
    "Content-Type": "application/json"
}

payload = {
    "comment_text": "Automated system check — all systems nominal.",
    "assignee": 183,
    "notify_all": True
}

response = requests.post(url, json=payload, headers=headers)
data = response.json()
print(f"Comment created: {data['id']}")
```

---

### 2.2 Get Task Comments

**GET** `/v2/task/{task_id}/comment`

Retrieves all comments for a specific task. Returns an array of comment objects.

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_task_ids` | boolean | No | Reference task by custom ID |
| `team_id` | number | No | Required when using custom task IDs |
| `start` | integer | No | Unix timestamp (ms) — return comments after this date |
| `start_id` | string | No | Comment ID to start the page from |

#### Response (200)

```json
{
  "comments": [
    {
      "id": "458",
      "comment": [
        {
          "text": "This is the comment content"
        }
      ],
      "comment_text": "This is the comment content",
      "user": {
        "id": 183,
        "username": "John Doe",
        "email": "john@example.com",
        "color": "#827718",
        "profilePicture": "https://attachments-public.clickup.com/profilePictures/183_abc.jpg",
        "initials": "JD"
      },
      "reactions": [],
      "date": "1568036964079",
      "reply_count": 2,
      "assignee": {
        "id": 183,
        "username": "John Doe",
        "email": "john@example.com",
        "color": "#827718",
        "profilePicture": null,
        "initials": "JD"
      },
      "assigned_by": {
        "id": 183,
        "username": "John Doe",
        "email": "john@example.com",
        "color": "#827718",
        "profilePicture": null,
        "initials": "JD"
      },
      "resolved": false
    }
  ]
}
```

#### Comment Object Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique comment ID |
| `comment` | array | Rich text comment body (array of content blocks) |
| `comment_text` | string | Plain-text version of the comment |
| `user` | object | Author of the comment |
| `reactions` | array | Array of emoji reactions with user IDs |
| `date` | string | Unix timestamp (ms) of creation |
| `reply_count` | integer | Number of threaded replies on this comment |
| `assignee` | object | User assigned via the comment (if any) |
| `assigned_by` | object | User who made the assignment |
| `resolved` | boolean | Whether the comment has been resolved |

#### cURL Example

```bash
curl -X GET \
  'https://api.clickup.com/api/v2/task/9hz/comment' \
  -H 'Authorization: pk_YOUR_API_TOKEN'
```

---

### 2.3 Update Comment

**PUT** `/v2/comment/{comment_id}`

Updates an existing comment's content. Targets task-level comments only (not list or space comments).

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `comment_id` | string | Yes | The unique comment ID |

#### Request Body

```json
{
  "comment_text": "Updated comment content — resolved at 14:32 UTC",
  "assignee": 183,
  "resolved": true
}
```

#### Request Body Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `comment_text` | string | Yes | New text content for the comment |
| `assignee` | integer | No | Update the comment assignee |
| `resolved` | boolean | No | Mark comment as resolved (`true`/`false`) |

#### Response (200)

```json
{}
```

The API returns an empty object on success.

#### Python Example

```python
import requests

comment_id = "458"
url = f"https://api.clickup.com/api/v2/comment/{comment_id}"

headers = {
    "Authorization": "pk_YOUR_API_TOKEN",
    "Content-Type": "application/json"
}

payload = {
    "comment_text": "Issue resolved — deployed to production at 14:32 UTC.",
    "resolved": True
}

response = requests.put(url, json=payload, headers=headers)
print(f"Status: {response.status_code}")
```

---

### 2.4 Delete Comment

**DELETE** `/v2/comment/{comment_id}`

Permanently removes a comment from a task. This operation is irreversible.

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `comment_id` | string | Yes | The unique comment ID |

#### Response (200)

```json
{}
```

#### cURL Example

```bash
curl -X DELETE \
  'https://api.clickup.com/api/v2/comment/458' \
  -H 'Authorization: pk_YOUR_API_TOKEN'
```

#### Python Example

```python
import requests

comment_id = "458"
url = f"https://api.clickup.com/api/v2/comment/{comment_id}"

headers = {"Authorization": "pk_YOUR_API_TOKEN"}

response = requests.delete(url, headers=headers)
if response.status_code == 200:
    print("Comment deleted successfully")
```

---

### 2.5 Threaded Comments & Replies

ClickUp supports threaded conversations — replies to top-level task comments. This endpoint was shipped in May 2024 and is the official way to retrieve reply chains.

**GET** `/v2/task/{task_id}/comment/threaded`

Returns all comments and their replies for a specific task. Results are grouped so you can identify which replies belong to which parent comment.

#### Important Known Behavior

The response returns comments as a flat array. Each item in the array includes:
- The parent comment object
- Reply comment objects (with no direct `parent_id` linkage in earlier API responses — rely on ordering)

According to ClickUp developer feedback, a comment's `reply_count` field on the parent indicates how many replies exist, and the threaded endpoint returns them interleaved in the array following the parent.

#### Query Parameters

Same as Get Task Comments: supports `start`, `start_id`, `custom_task_ids`, `team_id`.

#### cURL Example

```bash
curl -X GET \
  'https://api.clickup.com/api/v2/task/9hz/comment/threaded' \
  -H 'Authorization: pk_YOUR_API_TOKEN'
```

#### Python Example

```python
import requests

task_id = "9hz"
url = f"https://api.clickup.com/api/v2/task/{task_id}/comment/threaded"

headers = {"Authorization": "pk_YOUR_API_TOKEN"}

response = requests.get(url, headers=headers)
threaded_data = response.json()

# Group by parent/child
comments = threaded_data.get("comments", [])
for comment in comments:
    print(f"[{comment['id']}] {comment['comment_text']} (replies: {comment.get('reply_count', 0)})")
```

---

### 2.6 Chat View Comments

Chat views in ClickUp function as team messaging channels. The API exposes dedicated endpoints for reading and writing to these views.

**POST** `/v2/view/{view_id}/comment`
**GET** `/v2/view/{view_id}/comment`

#### Create Chat View Comment — Request Body

```json
{
  "comment_text": "Deployment complete. All services are green.",
  "notify_all": true
}
```

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `view_id` | string | Yes | The chat view ID (example: `105`) |

The response structure is identical to task comments. The `view_id` is the Chat view ID, not a task ID.

#### Note on v3 Chat API

ClickUp has introduced a newer Chat API under v3 (`/api/v3/workspaces/{workspace_id}/chat/channels/{channel_id}/messages`). This endpoint handles chat messages in ClickUp's newer channel-based chat system. For legacy Chat views created in v2, use the v2 endpoint above.

---

### 2.7 List Comments

You can also post comments directly on a ClickUp List (not on a specific task within it).

**POST** `/v2/list/{list_id}/comment`
**GET** `/v2/list/{list_id}/comment`

#### Request Body

```json
{
  "comment_text": "All items in this list reviewed for Q1 planning.",
  "assignee": 183,
  "notify_all": false
}
```

The response format mirrors task comment responses.

---

## 3. Task Attachments

**POST** `/v2/task/{task_id}/attachment`

Uploads a file attachment to a task. This endpoint uses `multipart/form-data` — not `application/json`.

### Key Requirements

- **Content-Type**: Must be `multipart/form-data` (not `application/json`)
- **Field name**: `attachment` (single file) or `attachment[0]`, `attachment[1]` for multiple
- **Maximum file size**: 1 GB
- **No file type restrictions**
- Returns error code `GBUSED_005` if workspace storage limit is exceeded

### cURL Example

```bash
curl -X POST \
  'https://api.clickup.com/api/v2/task/9hz/attachment' \
  -H 'Authorization: pk_YOUR_API_TOKEN' \
  -F 'attachment=@/path/to/your/file.pdf'
```

### Python Example

```python
import requests

task_id = "9hz"
url = f"https://api.clickup.com/api/v2/task/{task_id}/attachment"

headers = {"Authorization": "pk_YOUR_API_TOKEN"}
# Do NOT set Content-Type manually — requests sets it automatically for files

with open("/path/to/report.pdf", "rb") as f:
    files = {"attachment": ("report.pdf", f, "application/pdf")}
    response = requests.post(url, files=files, headers=headers)

attachment_data = response.json()
print(f"Attachment ID: {attachment_data.get('id')}")
print(f"URL: {attachment_data.get('url')}")
```

### Response Fields

| Field | Description |
|-------|-------------|
| `id` | Attachment UUID |
| `version` | Version string |
| `date` | Upload timestamp (Unix ms) |
| `title` | Filename |
| `extension` | File extension |
| `thumbnail_small` | Thumbnail URL (if applicable) |
| `thumbnail_large` | Thumbnail URL (if applicable) |
| `url` | Direct download URL |

---

## 4. Webhooks API

Webhooks allow your application to receive real-time HTTP POST notifications whenever specific events occur in a ClickUp Workspace. They eliminate polling and enable event-driven architectures.

### Architecture Overview

- Webhooks are scoped per **Workspace** (Team)
- ClickUp uses **dynamic IP addressing** — no dedicated IP for webhook delivery
- All webhook deliveries are sent as `POST` requests with `Content-Type: application/json`
- A secret is issued per webhook for HMAC signature verification

### Endpoint Overview Table

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Create webhook | POST | `/v2/team/{team_id}/webhook` |
| List webhooks | GET | `/v2/team/{team_id}/webhook` |
| Update webhook | PUT | `/v2/webhook/{webhook_id}` |
| Delete webhook | DELETE | `/v2/webhook/{webhook_id}` |

---

### 4.1 Create Webhook

**POST** `/v2/team/{team_id}/webhook`

Sets up a new webhook to monitor for specified events.

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `team_id` | number | Yes | The Workspace (Team) ID |

#### Request Body

```json
{
  "endpoint": "https://your-app.com/clickup-webhook",
  "events": ["taskCreated", "taskCommentPosted", "taskStatusUpdated"],
  "space_id": 812
}
```

To subscribe to ALL events, use the wildcard:

```json
{
  "endpoint": "https://your-app.com/clickup-webhook",
  "events": "*"
}
```

#### Request Body Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `endpoint` | string | Yes | Public HTTPS URL that will receive POST requests |
| `events` | array or `"*"` | Yes | Array of event names to subscribe to, or `"*"` for all |
| `space_id` | integer | No | Filter events to a specific Space |
| `folder_id` | integer | No | Filter events to a specific Folder |
| `list_id` | integer | No | Filter events to a specific List |
| `task_id` | string | No | Filter events to a specific Task |

#### Response (200)

```json
{
  "id": "4b67ac88-e506-4a29-9d42-26e504e3435e",
  "webhook": {
    "id": "4b67ac88-e506-4a29-9d42-26e504e3435e",
    "userid": 183,
    "team_id": 108,
    "endpoint": "https://your-app.com/clickup-webhook",
    "client_id": "QVOQP06ZXC6CMGVFKB0ZT7J9Y7APOYGO",
    "events": ["taskCreated", "taskCommentPosted", "taskStatusUpdated"],
    "task_id": null,
    "list_id": null,
    "folder_id": null,
    "space_id": null,
    "health": {
      "status": "active",
      "fail_count": 0
    },
    "secret": "O94IM25S7PXBPYTMNXLLET230SRP0S89COR7B1YOJ2ZIE8WQNK5UUKEF26W0Z5GA"
  }
}
```

**Critical**: Store the `secret` field from this response immediately. It is used for HMAC signature verification on all incoming webhook requests. It will not be shown again in plain form.

#### cURL Example

```bash
curl -X POST \
  'https://api.clickup.com/api/v2/team/108/webhook' \
  -H 'Authorization: pk_YOUR_API_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "endpoint": "https://your-app.com/clickup-webhook",
    "events": ["taskCreated", "taskUpdated", "taskCommentPosted"],
    "space_id": 812
  }'
```

#### Python Example

```python
import requests

team_id = 108
url = f"https://api.clickup.com/api/v2/team/{team_id}/webhook"

headers = {
    "Authorization": "pk_YOUR_API_TOKEN",
    "Content-Type": "application/json"
}

payload = {
    "endpoint": "https://your-app.com/clickup-webhook",
    "events": [
        "taskCreated",
        "taskUpdated",
        "taskCommentPosted",
        "taskStatusUpdated",
        "taskAssigneeUpdated"
    ],
    "space_id": 812
}

response = requests.post(url, json=payload, headers=headers)
data = response.json()

webhook_secret = data["webhook"]["secret"]
webhook_id = data["webhook"]["id"]

print(f"Webhook ID: {webhook_id}")
print(f"Secret (store securely): {webhook_secret}")
```

---

### 4.2 List Webhooks

**GET** `/v2/team/{team_id}/webhook`

Returns all webhooks for a Workspace, including their health status and configuration.

#### Response (200)

```json
{
  "webhooks": [
    {
      "id": "4b67ac88-e506-4a29-9d42-26e504e3435e",
      "userid": 183,
      "team_id": 108,
      "endpoint": "https://your-app.com/clickup-webhook",
      "client_id": "QVOQP06ZXC6CMGVFKB0ZT7J9Y7APOYGO",
      "events": ["taskCreated", "taskCommentPosted"],
      "task_id": null,
      "list_id": null,
      "folder_id": null,
      "space_id": null,
      "health": {
        "status": "active",
        "fail_count": 0
      },
      "secret": "O94IM25S7PXBPYTMNXLLET230SRP0S89COR7B1YOJ2ZIE8WQNK5UUKEF26W0Z5GA"
    }
  ]
}
```

---

### 4.3 Update Webhook

**PUT** `/v2/webhook/{webhook_id}`

Updates a webhook's endpoint URL, subscribed events, or status.

#### Request Body

```json
{
  "endpoint": "https://your-app.com/new-webhook-path",
  "events": "*",
  "status": "active"
}
```

#### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `endpoint` | string | New target URL |
| `events` | array or `"*"` | New event subscriptions |
| `status` | string | `"active"` or `"suspended"` |

The response mirrors the Create Webhook response, with the full updated webhook object.

---

### 4.4 Delete Webhook

**DELETE** `/v2/webhook/{webhook_id}`

Permanently removes a webhook. ClickUp will stop sending events to the endpoint immediately.

#### Response (200)

```json
{}
```

#### cURL Example

```bash
curl -X DELETE \
  'https://api.clickup.com/api/v2/webhook/4b67ac88-e506-4a29-9d42-26e504e3435e' \
  -H 'Authorization: pk_YOUR_API_TOKEN'
```

---

## 5. Webhook Event Types

ClickUp v2 webhooks support **27 distinct event types** covering the full lifecycle of all major entities in a Workspace. Below is the complete authoritative list as returned by the API.

### Task Events

| Event Name | Trigger |
|------------|---------|
| `taskCreated` | A new task is created |
| `taskUpdated` | Any field on a task is updated |
| `taskDeleted` | A task is deleted |
| `taskPriorityUpdated` | Task priority is changed |
| `taskStatusUpdated` | Task status changes (e.g., Open → In Progress → Closed) |
| `taskAssigneeUpdated` | Assignees are added or removed from a task |
| `taskDueDateUpdated` | Task due date is changed |
| `taskTagUpdated` | Tags are added or removed from a task |
| `taskMoved` | Task is moved to a different list |
| `taskCommentPosted` | A new comment is added to a task |
| `taskCommentUpdated` | An existing task comment is edited |
| `taskTimeEstimateUpdated` | Time estimate on a task is changed |
| `taskTimeTrackedUpdated` | Time tracked on a task changes (timer started/stopped/logged) |

### List Events

| Event Name | Trigger |
|------------|---------|
| `listCreated` | A new list is created |
| `listUpdated` | List properties are updated |
| `listDeleted` | A list is deleted |

### Folder Events

| Event Name | Trigger |
|------------|---------|
| `folderCreated` | A new folder is created |
| `folderUpdated` | Folder properties are updated |
| `folderDeleted` | A folder is deleted |

### Space Events

| Event Name | Trigger |
|------------|---------|
| `spaceCreated` | A new space is created |
| `spaceUpdated` | Space properties are updated |
| `spaceDeleted` | A space is deleted |

### Goal & Key Result Events

| Event Name | Trigger |
|------------|---------|
| `goalCreated` | A new goal is created |
| `goalUpdated` | A goal is updated |
| `goalDeleted` | A goal is deleted |
| `keyResultCreated` | A key result (target) is created on a goal |
| `keyResultUpdated` | A key result is updated |
| `keyResultDeleted` | A key result is deleted |

### Wildcard Subscription

Use `"*"` in the events array to subscribe to **all 27 events** simultaneously.

```json
{
  "endpoint": "https://your-app.com/webhook",
  "events": "*"
}
```

> **Note on goal events**: Some older ClickUp documentation uses `goalKeyResultCreated`, `goalKeyResultUpdated`, `goalKeyResultDeleted` as the event names for key results. The current API uses `keyResultCreated`, `keyResultUpdated`, `keyResultDeleted`. Verify against the webhook object returned when you create or list webhooks.

---

## 6. Webhook Payload Structure & Examples

All webhook deliveries are `POST` requests to your endpoint with `Content-Type: application/json`.

### Base Payload Structure

Every webhook payload contains these top-level fields:

```json
{
  "webhook_id": "7689a169-a000-4985-8676-6902b96d6627",
  "event": "eventName",
  "task_id": "abc123",
  "history_items": []
}
```

| Field | Type | Description |
|-------|------|-------------|
| `webhook_id` | string (UUID) | ID of the webhook that sent this request |
| `event` | string | The event type name (e.g., `taskCreated`) |
| `task_id` | string | ID of the affected task (for task events) |
| `history_items` | array | Array of change objects describing what changed |

---

### Event Payload Examples

#### taskCreated

```json
{
  "webhook_id": "7689a169-a000-4985-8676-6902b96d6627",
  "event": "taskCreated",
  "task_id": "c0j"
}
```

For `taskCreated`, the `task_id` is the newly created task. Fetch full task details via `GET /v2/task/{task_id}` if needed.

#### taskStatusUpdated

```json
{
  "webhook_id": "7689a169-a000-4985-8676-6902b96d6627",
  "event": "taskStatusUpdated",
  "task_id": "c0j",
  "history_items": [
    {
      "id": "2800763136717140480",
      "type": 1,
      "date": "1568036964079",
      "field": "status",
      "parent_id": "159",
      "data": {
        "status_type": "open"
      },
      "source": null,
      "user": {
        "id": 183,
        "username": "John Doe",
        "email": "john@example.com",
        "color": "#827718",
        "initials": "JD",
        "profilePicture": null
      },
      "before": {
        "status": "to do",
        "color": "#d3d3d3",
        "type": "open",
        "orderindex": 0
      },
      "after": {
        "status": "in progress",
        "color": "#a875ff",
        "type": "custom",
        "orderindex": 1
      }
    }
  ]
}
```

#### taskCommentPosted

```json
{
  "webhook_id": "7689a169-a000-4985-8676-6902b96d6627",
  "event": "taskCommentPosted",
  "task_id": "c0j",
  "history_items": [
    {
      "id": "2800763136717140999",
      "type": 12,
      "date": "1568037356074",
      "field": "comment",
      "parent_id": "159",
      "data": {},
      "source": null,
      "user": {
        "id": 183,
        "username": "Jane Smith",
        "email": "jane@example.com",
        "color": "#e50000",
        "initials": "JS",
        "profilePicture": "https://attachments.clickup.com/profilePictures/183_abc.jpg"
      },
      "comment": {
        "id": "458",
        "date": "1568037356074",
        "comment_text": "Client approved the mockup. Moving to implementation.",
        "user": {
          "id": 183
        },
        "resolved": false,
        "reply_count": 0,
        "reactions": []
      }
    }
  ]
}
```

#### taskCommentUpdated

```json
{
  "webhook_id": "7689a169-a000-4985-8676-6902b96d6627",
  "event": "taskCommentUpdated",
  "task_id": "c0j",
  "history_items": [
    {
      "id": "2800763136717141001",
      "type": 12,
      "date": "1568037500000",
      "field": "comment",
      "parent_id": "159",
      "user": {
        "id": 183,
        "username": "Jane Smith",
        "email": "jane@example.com",
        "color": "#e50000",
        "initials": "JS",
        "profilePicture": null
      },
      "before": {
        "comment_text": "Original comment text"
      },
      "after": {
        "comment_text": "Updated comment text — corrected typo"
      }
    }
  ]
}
```

#### taskAssigneeUpdated

```json
{
  "webhook_id": "7689a169-a000-4985-8676-6902b96d6627",
  "event": "taskAssigneeUpdated",
  "task_id": "c0j",
  "history_items": [
    {
      "id": "2800763136717142001",
      "type": 5,
      "date": "1568037400000",
      "field": "assignee_rem",
      "parent_id": "159",
      "data": {},
      "user": {
        "id": 183,
        "username": "John Doe",
        "email": "john@example.com",
        "color": "#827718",
        "initials": "JD",
        "profilePicture": null
      },
      "before": {
        "id": 200,
        "username": "Old Assignee"
      },
      "after": {
        "id": 183,
        "username": "New Assignee"
      }
    }
  ]
}
```

#### taskMoved

```json
{
  "webhook_id": "7689a169-a000-4985-8676-6902b96d6627",
  "event": "taskMoved",
  "task_id": "c0j",
  "history_items": [
    {
      "id": "2800763136717143001",
      "type": 9,
      "date": "1568038000000",
      "field": "section_moved",
      "parent_id": "159",
      "data": {
        "list_id": "456",
        "list_name": "New List Name"
      },
      "user": {
        "id": 183,
        "username": "John Doe",
        "email": "john@example.com",
        "color": "#827718",
        "initials": "JD",
        "profilePicture": null
      },
      "before": {
        "list_id": "123",
        "list_name": "Original List"
      },
      "after": {
        "list_id": "456",
        "list_name": "New List Name"
      }
    }
  ]
}
```

#### listCreated

```json
{
  "webhook_id": "7689a169-a000-4985-8676-6902b96d6627",
  "event": "listCreated",
  "list_id": "124"
}
```

#### goalCreated

```json
{
  "webhook_id": "7689a169-a000-4985-8676-6902b96d6627",
  "event": "goalCreated",
  "goal_id": "e53a033c-900e-4512-a09c-a6e8e5e3d401"
}
```

#### keyResultCreated

```json
{
  "webhook_id": "7689a169-a000-4985-8676-6902b96d6627",
  "event": "keyResultCreated",
  "goal_id": "e53a033c-900e-4512-a09c-a6e8e5e3d401",
  "key_result_id": "b9d13e8c-1234-5678-abcd-ef0123456789"
}
```

---

### history_items Object Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique history item ID |
| `type` | integer | Internal type code for the change |
| `date` | string | Unix timestamp (ms) of the change |
| `field` | string | Name of the field that changed |
| `parent_id` | string | ID of the parent container (list ID) |
| `data` | object | Additional context data for the change |
| `source` | string/null | Source of the change (e.g., automation) |
| `user` | object | User who made the change |
| `before` | object | Previous value(s) |
| `after` | object | New value(s) |

---

## 7. Security — HMAC Signature Verification

Every webhook request sent by ClickUp includes an `X-Signature` HTTP header. This signature is generated using HMAC-SHA256 with the webhook secret as the key and the raw request body as the message. The signature is encoded as a **hexadecimal string**.

### How It Works

1. When you create a webhook, ClickUp returns a `secret` in the response
2. Store this secret securely (e.g., in environment variables or a secrets manager)
3. For every incoming webhook request:
   - Extract the `X-Signature` header
   - Compute `HMAC-SHA256(secret, raw_request_body)` → hex encode
   - Compare the result against the header value
   - If they match: request is authentic, process it
   - If they don't match: reject with `401 Unauthorized`

### Example Webhook Request

```
POST /clickup-webhook HTTP/1.1
Content-Type: application/json
X-Signature: f7bc83f430538424b13298e6aa6fb2b460559e0c9c4a8217af3266dbe0e72ce1

{"webhook_id":"7689a169-a000-4985-8676-6902b96d6627","event":"taskCreated","task_id":"c0j"}
```

### Node.js Verification

```javascript
const crypto = require('crypto');
const express = require('express');

const app = express();

// IMPORTANT: Use raw body parser — do NOT parse JSON before signature check
app.use('/clickup-webhook', express.raw({ type: 'application/json' }));

app.post('/clickup-webhook', (req, res) => {
  const webhookSecret = process.env.CLICKUP_WEBHOOK_SECRET;
  const signature = req.headers['x-signature'];

  // req.body is a Buffer when using express.raw()
  const body = req.body.toString();

  const hash = crypto
    .createHmac('sha256', webhookSecret)
    .update(body)
    .digest('hex');

  if (hash !== signature) {
    return res.status(401).json({ error: 'Invalid signature' });
  }

  // Signature verified — parse and process event
  const event = JSON.parse(body);
  console.log(`Event received: ${event.event} for task ${event.task_id}`);

  // Always respond 200 quickly to prevent retry
  res.status(200).json({ received: true });

  // Process asynchronously after response
  processEvent(event);
});

async function processEvent(event) {
  switch (event.event) {
    case 'taskCommentPosted':
      await handleNewComment(event);
      break;
    case 'taskStatusUpdated':
      await handleStatusChange(event);
      break;
    default:
      console.log(`Unhandled event: ${event.event}`);
  }
}

app.listen(3000, () => console.log('Webhook server running on port 3000'));
```

### Python Verification (Flask)

```python
import hmac
import hashlib
import os
from flask import Flask, request, jsonify

app = Flask(__name__)

CLICKUP_WEBHOOK_SECRET = os.environ.get("CLICKUP_WEBHOOK_SECRET")

@app.route("/clickup-webhook", methods=["POST"])
def clickup_webhook():
    # Get raw body BEFORE any parsing
    raw_body = request.get_data()
    signature_header = request.headers.get("X-Signature", "")

    # Compute expected signature
    expected_signature = hmac.new(
        CLICKUP_WEBHOOK_SECRET.encode("utf-8"),
        raw_body,
        hashlib.sha256
    ).hexdigest()

    # Constant-time comparison to prevent timing attacks
    if not hmac.compare_digest(expected_signature, signature_header):
        return jsonify({"error": "Invalid signature"}), 401

    # Parse JSON after verification
    event_data = request.get_json()
    event_type = event_data.get("event")
    task_id = event_data.get("task_id")

    print(f"Verified event: {event_type}, task: {task_id}")

    # Respond immediately — process asynchronously if needed
    return jsonify({"received": True}), 200

if __name__ == "__main__":
    app.run(port=3000, debug=False)
```

### Critical Security Notes

1. **Use raw body**: Always verify the signature against the raw, unparsed request body. If your framework auto-parses JSON, you may alter whitespace or key ordering, which will break signature validation.
2. **Constant-time comparison**: Use `hmac.compare_digest()` (Python) or `crypto.timingSafeEqual()` (Node.js) to prevent timing attacks.
3. **HTTPS only**: ClickUp only sends webhooks to HTTPS endpoints. Plain HTTP endpoints will be rejected.
4. **Respond before processing**: Return `200` immediately, then process the event asynchronously. If processing takes longer than 7 seconds, ClickUp marks the delivery as failed.

---

## 8. Webhook Health, Retry Behavior & Failure Handling

ClickUp actively monitors the health of every registered webhook and uses a fail-count system to protect against permanently broken endpoints consuming resources.

### Webhook Health States

| Status | Description |
|--------|-------------|
| `active` | Endpoint returns 2xx within 7 seconds — events are delivered normally |
| `failing` | Endpoint returns non-2xx OR takes longer than 7 seconds — retries in progress |
| `suspended` | `fail_count` reached 100, or `401`/`410` received — no more events sent |

### Retry Behavior

- **Timeout threshold**: If an endpoint does not respond within **7 seconds**, the delivery is counted as failed
- **Retries per event**: ClickUp retries failed deliveries up to **5 times** per individual event
- **After 5 retries**: The specific event delivery is abandoned, and `fail_count` is incremented by 1
- **No backfill**: Failed events that exhaust retries are **permanently lost** — ClickUp does not re-queue them after recovery
- **Auto-recovery**: If your endpoint starts responding with 2xx again, the webhook automatically returns to `active` and `fail_count` resets to 0

### Special HTTP Status Codes

| Status Code | Behavior |
|-------------|----------|
| `200` (any 2xx) | Success — webhook remains active |
| `401` | Immediately suspends the webhook |
| `410` | Immediately suspends the webhook |
| Any other 4xx/5xx | Increments `fail_count`, retries up to 5 times |

### Monitoring Webhook Health

The `health` object is included in all webhook list/update responses:

```json
{
  "health": {
    "status": "active",
    "fail_count": 0
  }
}
```

To programmatically monitor and reactivate suspended webhooks:

```python
import requests

def check_and_reactivate_webhooks(team_id, api_token):
    url = f"https://api.clickup.com/api/v2/team/{team_id}/webhook"
    headers = {"Authorization": api_token}

    response = requests.get(url, headers=headers)
    webhooks = response.json().get("webhooks", [])

    for webhook in webhooks:
        health = webhook.get("health", {})
        if health.get("status") == "suspended":
            print(f"Reactivating suspended webhook: {webhook['id']}")
            reactivate_url = f"https://api.clickup.com/api/v2/webhook/{webhook['id']}"
            requests.put(reactivate_url, json={
                "endpoint": webhook["endpoint"],
                "events": webhook["events"],
                "status": "active"
            }, headers={**headers, "Content-Type": "application/json"})
```

### Best Practices for Reliability

1. **Respond with 200 within 2-3 seconds** — don't wait for processing completion
2. **Queue events for async processing** — use Redis Queue, Celery, or a background thread
3. **Implement idempotency** — webhooks can arrive out of order or duplicated; use `history_item.id` or `event.task_id + timestamp` as idempotency keys
4. **Monitor `fail_count`** — set up a daily job to check webhook health via `GET /v2/team/{team_id}/webhook`
5. **Never return 401 or 410** unless you actually want the webhook suspended

---

## 9. Filtering Webhooks by Scope

When creating a webhook, you can scope it to a specific ClickUp entity to reduce noise and only receive events for the relevant subset of your workspace.

### Scope Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `space_id` | integer | Only events within this Space |
| `folder_id` | integer | Only events within this Folder |
| `list_id` | integer | Only events within this List |
| `task_id` | string | Only events on this specific Task |

These are mutually exclusive at the top level — you can specify one scope per webhook.

### Example: Space-Scoped Webhook (Only Engineering Space)

```python
payload = {
    "endpoint": "https://your-app.com/webhook/engineering",
    "events": ["taskCreated", "taskStatusUpdated", "taskCommentPosted"],
    "space_id": 812
}
```

### Example: Task-Scoped Webhook (Monitor a single critical task)

```python
payload = {
    "endpoint": "https://your-app.com/webhook/critical-task",
    "events": ["taskStatusUpdated", "taskCommentPosted", "taskAssigneeUpdated"],
    "task_id": "abc123"
}
```

### Recommended Pattern: Multiple Scoped Webhooks

For large workspaces, create separate webhooks per space or per team to:
- Reduce payload volume on any single endpoint
- Enable independent failure handling per business unit
- Apply different routing logic per scope

---

## 10. Real-Time Use Cases for AI Automation

Webhooks + ClickUp Comments form a powerful combination for AI-driven project management automation. Below are high-value patterns.

### Pattern 1: AI Comment Responder

Listen for `taskCommentPosted` events. When a comment contains a question or keyword, trigger an AI agent to analyze the task context and post a reply.

```python
@app.route("/clickup-webhook", methods=["POST"])
def handle_webhook():
    # ... signature verification ...
    event = request.get_json()

    if event["event"] == "taskCommentPosted":
        task_id = event["task_id"]
        history = event.get("history_items", [])
        for item in history:
            comment = item.get("comment", {})
            comment_text = comment.get("comment_text", "")

            if "?" in comment_text or "@ai" in comment_text.lower():
                # Fetch full task for context
                task = get_task(task_id)
                # Generate AI response
                ai_response = generate_ai_response(task, comment_text)
                # Post reply as comment
                post_comment(task_id, ai_response)

    return jsonify({"ok": True}), 200
```

### Pattern 2: Status Change Notifier

When `taskStatusUpdated` fires and status moves to "Done", automatically:
- Post a completion comment with timestamp
- Notify stakeholders in a separate system (Slack, email)
- Update a Notion page or Google Sheet

```python
def handle_status_update(event):
    for item in event.get("history_items", []):
        after_status = item.get("after", {}).get("status", "").lower()
        if after_status in ["done", "complete", "closed"]:
            task_id = event["task_id"]
            post_comment(task_id, f"Task completed automatically at {datetime.utcnow().isoformat()}Z")
            notify_slack(f"Task {task_id} is now Done!")
```

### Pattern 3: Automated Triage on Task Creation

When `taskCreated` fires:
- Fetch the new task via `GET /v2/task/{task_id}`
- Run the description through an AI classifier to determine priority, assign to the right person, and add tags
- Post a triage summary comment on the task

### Pattern 4: SLA Monitor

Listen to `taskCreated` and `taskStatusUpdated`. If a task has been in "In Progress" for more than N hours without a comment, post an automated reminder comment.

### Pattern 5: Comment-to-Ticket Sync

Listen for `taskCommentPosted`. Sync comments from ClickUp to an external CRM, helpdesk (e.g., Zendesk, HubSpot), or Notion database in real-time.

### Pattern 6: Sprint Velocity Dashboard

Consume `taskStatusUpdated` events. Count status transitions to "Done" per day/week. Feed into a time-series database (InfluxDB, Supabase) for velocity charting without polling.

### Pattern 7: Goal Progress Updates

Listen for `keyResultUpdated` events. When a key result's progress changes, post an update comment on the associated goal task with percentage completion and trend.

### Pattern 8: Automated Audit Trail

Listen for all events using `"events": "*"`. Write every `history_items` payload to a database (e.g., PostgreSQL, Supabase) to create a full audit trail that persists independently of ClickUp's own activity log.

---

## 11. Activity Log / Audit Trail Endpoints

ClickUp does not have a dedicated "audit log" API endpoint in v2. The equivalent functionality is achieved through:

### 1. Task Activity Feed (via Task endpoint)

**GET** `/v2/task/{task_id}?include_subtasks=true`

The full task object contains the `activity` section when you include `?include_subtasks=true`. However, this is not a dedicated activity log endpoint.

### 2. History via Webhooks (Recommended)

The most reliable audit trail comes from consuming all webhook events with `"events": "*"` and persisting every `history_items` payload to your own database. Each `history_items` entry contains:
- `id` — unique history event ID
- `date` — exact timestamp
- `user` — who made the change
- `field` — what changed
- `before` / `after` — exact values before and after

### 3. Pulling Comments as Activity

Use `GET /v2/task/{task_id}/comment` with the `start` pagination parameter to pull all comments chronologically. This gives you a searchable discussion trail per task.

### Recommended Audit Trail Pattern

```python
import sqlite3
import json
import requests
from flask import Flask, request, jsonify

# Minimal event store using SQLite
conn = sqlite3.connect("clickup_audit.db", check_same_thread=False)
conn.execute("""
    CREATE TABLE IF NOT EXISTS events (
        id TEXT PRIMARY KEY,
        webhook_id TEXT,
        event_type TEXT,
        task_id TEXT,
        team_id TEXT,
        raw_payload TEXT,
        received_at INTEGER
    )
""")
conn.commit()

@app.route("/clickup-audit", methods=["POST"])
def audit_webhook():
    # ... signature verification ...
    event = request.get_json()
    raw = request.get_data(as_text=True)

    import time
    conn.execute(
        "INSERT OR IGNORE INTO events VALUES (?,?,?,?,?,?,?)",
        (
            event.get("webhook_id") + str(time.time()),
            event.get("webhook_id"),
            event.get("event"),
            event.get("task_id"),
            None,
            raw,
            int(time.time() * 1000)
        )
    )
    conn.commit()
    return jsonify({"ok": True}), 200
```

---

## 12. Complete Python Implementation Reference

A production-ready webhook handler skeleton:

```python
"""
ClickUp Webhook Handler — Production Skeleton
Handles all 27 ClickUp event types with HMAC verification,
async processing, and basic idempotency.
"""

import hmac
import hashlib
import os
import json
import threading
from datetime import datetime
from flask import Flask, request, jsonify
import requests as http_client

app = Flask(__name__)

# Config
CLICKUP_TOKEN = os.environ["CLICKUP_API_TOKEN"]
CLICKUP_WEBHOOK_SECRET = os.environ["CLICKUP_WEBHOOK_SECRET"]
BASE_URL = "https://api.clickup.com/api/v2"

# In-memory idempotency set (use Redis in production)
processed_events = set()


def verify_signature(raw_body: bytes, signature: str) -> bool:
    expected = hmac.new(
        CLICKUP_WEBHOOK_SECRET.encode(),
        raw_body,
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(expected, signature)


def get_task(task_id: str) -> dict:
    resp = http_client.get(
        f"{BASE_URL}/task/{task_id}",
        headers={"Authorization": CLICKUP_TOKEN}
    )
    return resp.json()


def post_comment(task_id: str, text: str, notify_all: bool = False) -> dict:
    resp = http_client.post(
        f"{BASE_URL}/task/{task_id}/comment",
        headers={"Authorization": CLICKUP_TOKEN, "Content-Type": "application/json"},
        json={"comment_text": text, "notify_all": notify_all}
    )
    return resp.json()


def create_webhook(team_id: int, endpoint: str, events: list, space_id: int = None) -> dict:
    payload = {"endpoint": endpoint, "events": events}
    if space_id:
        payload["space_id"] = space_id
    resp = http_client.post(
        f"{BASE_URL}/team/{team_id}/webhook",
        headers={"Authorization": CLICKUP_TOKEN, "Content-Type": "application/json"},
        json=payload
    )
    return resp.json()


def process_event_async(event: dict):
    event_type = event.get("event")
    task_id = event.get("task_id")
    history = event.get("history_items", [])

    handlers = {
        "taskCreated": on_task_created,
        "taskStatusUpdated": on_status_updated,
        "taskCommentPosted": on_comment_posted,
        "taskCommentUpdated": on_comment_updated,
        "taskAssigneeUpdated": on_assignee_updated,
        "taskMoved": on_task_moved,
        "taskDeleted": on_task_deleted,
    }

    handler = handlers.get(event_type)
    if handler:
        try:
            handler(task_id, history, event)
        except Exception as e:
            print(f"[ERROR] Handler for {event_type} failed: {e}")
    else:
        print(f"[SKIP] Unhandled event type: {event_type}")


def on_task_created(task_id, history, event):
    print(f"[taskCreated] New task: {task_id}")
    # Fetch task, run triage logic, assign, tag, post comment
    task = get_task(task_id)
    post_comment(task_id, f"Task auto-triaged at {datetime.utcnow().isoformat()}Z")


def on_status_updated(task_id, history, event):
    for item in history:
        after = item.get("after", {})
        if after.get("status", "").lower() in ["done", "complete", "closed"]:
            print(f"[taskStatusUpdated] Task {task_id} DONE")
            post_comment(task_id, f"Completed at {datetime.utcnow().isoformat()}Z")


def on_comment_posted(task_id, history, event):
    for item in history:
        comment = item.get("comment", {})
        text = comment.get("comment_text", "")
        if "@ai" in text.lower() or text.strip().endswith("?"):
            print(f"[taskCommentPosted] AI trigger detected on task {task_id}")
            # Insert AI processing here


def on_comment_updated(task_id, history, event):
    print(f"[taskCommentUpdated] Comment updated on task {task_id}")


def on_assignee_updated(task_id, history, event):
    print(f"[taskAssigneeUpdated] Assignees changed on task {task_id}")


def on_task_moved(task_id, history, event):
    for item in history:
        after = item.get("after", {})
        print(f"[taskMoved] Task {task_id} moved to list: {after.get('list_name')}")


def on_task_deleted(task_id, history, event):
    print(f"[taskDeleted] Task {task_id} was deleted")


@app.route("/clickup-webhook", methods=["POST"])
def clickup_webhook():
    raw_body = request.get_data()
    signature = request.headers.get("X-Signature", "")

    if not verify_signature(raw_body, signature):
        return jsonify({"error": "Invalid signature"}), 401

    event = json.loads(raw_body)
    event_key = f"{event.get('webhook_id')}_{event.get('event')}_{event.get('task_id')}"

    # Basic idempotency check
    if event_key in processed_events:
        return jsonify({"duplicate": True}), 200
    processed_events.add(event_key)

    # Respond immediately, process in background
    thread = threading.Thread(target=process_event_async, args=(event,))
    thread.daemon = True
    thread.start()

    return jsonify({"received": True}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=3000)
```

---

## 13. Node.js Implementation Reference

```javascript
/**
 * ClickUp Webhook Handler — Node.js / Express
 * Includes HMAC verification and full event routing
 */

const express = require('express');
const crypto = require('crypto');
const axios = require('axios');

const app = express();

const CLICKUP_TOKEN = process.env.CLICKUP_API_TOKEN;
const CLICKUP_WEBHOOK_SECRET = process.env.CLICKUP_WEBHOOK_SECRET;
const BASE_URL = 'https://api.clickup.com/api/v2';

// CRITICAL: Use raw body parser for signature verification
app.use('/clickup-webhook', express.raw({ type: 'application/json' }));

// Standard JSON parser for other routes
app.use(express.json());

function verifySignature(rawBody, signatureHeader) {
  const hmac = crypto.createHmac('sha256', CLICKUP_WEBHOOK_SECRET);
  hmac.update(rawBody);
  const computed = hmac.digest('hex');

  try {
    return crypto.timingSafeEqual(
      Buffer.from(computed, 'hex'),
      Buffer.from(signatureHeader, 'hex')
    );
  } catch {
    return false;
  }
}

async function getTask(taskId) {
  const res = await axios.get(`${BASE_URL}/task/${taskId}`, {
    headers: { Authorization: CLICKUP_TOKEN }
  });
  return res.data;
}

async function postComment(taskId, text, notifyAll = false) {
  const res = await axios.post(
    `${BASE_URL}/task/${taskId}/comment`,
    { comment_text: text, notify_all: notifyAll },
    { headers: { Authorization: CLICKUP_TOKEN, 'Content-Type': 'application/json' } }
  );
  return res.data;
}

const eventHandlers = {
  taskCreated: async (event) => {
    console.log(`Task created: ${event.task_id}`);
    const task = await getTask(event.task_id);
    await postComment(event.task_id, `Auto-triaged: ${new Date().toISOString()}`);
  },
  taskStatusUpdated: async (event) => {
    const items = event.history_items || [];
    for (const item of items) {
      const after = item.after || {};
      if (['done', 'complete', 'closed'].includes(after.status?.toLowerCase())) {
        await postComment(event.task_id, `Completed: ${new Date().toISOString()}`);
      }
    }
  },
  taskCommentPosted: async (event) => {
    const items = event.history_items || [];
    for (const item of items) {
      const text = item.comment?.comment_text || '';
      if (text.toLowerCase().includes('@ai') || text.includes('?')) {
        console.log(`AI trigger detected on task ${event.task_id}: "${text}"`);
        // Add AI processing here
      }
    }
  }
};

app.post('/clickup-webhook', async (req, res) => {
  const rawBody = req.body;
  const signature = req.headers['x-signature'] || '';

  if (!verifySignature(rawBody, signature)) {
    return res.status(401).json({ error: 'Invalid signature' });
  }

  const event = JSON.parse(rawBody.toString());

  // Respond immediately
  res.status(200).json({ received: true });

  // Process asynchronously
  const handler = eventHandlers[event.event];
  if (handler) {
    handler(event).catch(err => console.error(`Handler error: ${err.message}`));
  } else {
    console.log(`No handler for event: ${event.event}`);
  }
});

// Setup webhook registration helper
async function createWebhook(teamId, endpoint, events = '*', spaceId = null) {
  const payload = { endpoint, events };
  if (spaceId) payload.space_id = spaceId;

  const res = await axios.post(
    `${BASE_URL}/team/${teamId}/webhook`,
    payload,
    { headers: { Authorization: CLICKUP_TOKEN, 'Content-Type': 'application/json' } }
  );

  const { id, webhook } = res.data;
  console.log(`Webhook created: ${id}`);
  console.log(`STORE THIS SECRET: ${webhook.secret}`);
  return res.data;
}

app.listen(3000, () => console.log('ClickUp webhook server running on :3000'));

module.exports = { createWebhook };
```

---

## 14. Gotchas & Known Limits

| Issue | Detail |
|-------|--------|
| No dedicated IP | ClickUp uses dynamic IP addresses for webhook delivery. Do not whitelist by IP. Verify by HMAC signature only. |
| 7-second timeout | If your handler takes more than 7 seconds to respond, the delivery is marked as failed. Always respond immediately, process async. |
| 401 suspends immediately | Returning `401` from your endpoint immediately suspends the webhook, not just fails the delivery. |
| 410 suspends immediately | Returning `410` (Gone) also immediately suspends the webhook. |
| fail_count = 100 = suspend | Once fail_count reaches 100, the webhook is suspended. You must PUT status=active to reactivate. |
| Failed events not replayed | Events that exhaust 5 retries are permanently dropped. No replay queue. |
| Signature is raw body | Compute HMAC on the raw bytes before any JSON parsing. Whitespace differences will break the check. |
| Hex format only | The `X-Signature` is always hex-encoded, never base64. |
| Threaded comments flat | The `/comment/threaded` endpoint returns a flat array, not a nested tree. Use `reply_count` on parent comments to identify threads. |
| No list-comment threaded endpoint | The threaded endpoint only exists for task comments, not list comments. |
| Custom task IDs | If your workspace uses custom task IDs, pass `?custom_task_ids=true&team_id={team_id}` on comment endpoints. |
| Attachments multipart only | The attachment endpoint requires `multipart/form-data`. Using `application/json` will fail. |
| Storage limit error | If workspace storage is full, attachment upload returns `GBUSED_005` error code. |
| Webhook secret not re-shown | The `secret` is only returned once at creation. If lost, you must delete and recreate the webhook. |
| No built-in replay | There is no API to replay missed events or retrieve past webhook deliveries. Build your own audit trail. |
| keyResult vs goalKeyResult | Older docs show `goalKeyResultCreated` naming. Current API returns `keyResultCreated`. Verify from your own webhook object. |

---

## 15. Sources

- [ClickUp API v2 Reference — Create Task Comment](https://developer.clickup.com/reference/createtaskcomment)
- [ClickUp API v2 Reference — Create Webhook](https://developer.clickup.com/reference/createwebhook)
- [ClickUp API v2 Reference — Update Webhook](https://developer.clickup.com/reference/updatewebhook)
- [ClickUp API v2 Reference — Delete Webhook](https://developer.clickup.com/reference/deletewebhook)
- [ClickUp API v2 Reference — Create Chat View Comment](https://developer.clickup.com/reference/createchatviewcomment)
- [ClickUp API v2 Reference — Create Task Attachment](https://developer.clickup.com/reference/postentityattachment)
- [ClickUp Developer Docs — Webhook Signature](https://developer.clickup.com/docs/webhooksignature)
- [ClickUp Developer Docs — Webhook Health Status](https://developer.clickup.com/docs/webhookhealth)
- [ClickUp Developer Docs — Attachments](https://developer.clickup.com/docs/attachments)
- [ClickUp APIv2 Demo Repository (Official)](https://github.com/clickup/clickup-APIv2-demo)
- [Rollout.com — Quick Guide to ClickUp Webhooks](https://rollout.com/integration-guides/clickup/quick-guide-to-implementing-webhooks-in-clickup)
- [Consultevo — Create Task Comments API Guide](https://consultevo.com/clickup-create-task-comments-api-guide/)
- [Consultevo — Get Task Comments API Guide](https://consultevo.com/clickup-task-comments-api-guide/)
- [Consultevo — Update Comment API Guide](https://consultevo.com/clickup-update-comment-api-guide/)
- [Consultevo — Delete Task Comments API Guide](https://consultevo.com/clickup-delete-task-comments-api-guide/)
- [Consultevo — Threaded Comments API Guide](https://consultevo.com/clickup-threaded-comments-api-guide/)
- [Consultevo — ClickUp Webhooks Setup Guide](https://consultevo.com/clickup-webhooks-implementation-guide/)
- [ClickUp Feedback — Threaded Comments via API (shipped May 2024)](https://feedback.clickup.com/public-api/p/accessing-replies-to-comments-via-the-api-v2)
- [ClickUp Feedback — OAuth for Webhook Authentication](https://feedback.clickup.com/public-api/p/using-oauth-for-webhook-authentication)
