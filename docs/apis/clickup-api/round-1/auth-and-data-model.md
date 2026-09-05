# ClickUp API v2 — Authentication & Core Data Model
**Round 1 Research Document**
Source: Official ClickUp Developer Docs + Community Resources
Date Saved: 2026-03-18
Primary Sources:
- https://developer.clickup.com/docs/authentication
- https://developer.clickup.com/reference/getaccesstoken
- https://developer.clickup.com/docs/faq
- https://developer.clickup.com/docs/rate-limits
- https://developer.clickup.com/docs/common_errors
- https://developer.clickup.com/docs/tasks
- https://developer.clickup.com/docs/general-v2-v3-api
- https://developer.clickup.com/docs/webhooksignature

---

## Table of Contents

1. [API Overview & Base URL](#1-api-overview--base-url)
2. [Authentication Methods](#2-authentication-methods)
   - 2.1 Personal API Token
   - 2.2 OAuth 2.0 Flow (Full Detail)
   - 2.3 Choosing the Right Method
3. [How to Authenticate Requests (Headers)](#3-how-to-authenticate-requests-headers)
4. [OAuth Token Details — Expiration, Refresh, Scopes](#4-oauth-token-details--expiration-refresh-scopes)
5. [Core Data Model — The ClickUp Hierarchy](#5-core-data-model--the-clickup-hierarchy)
   - 5.1 Workspace (Team)
   - 5.2 Space
   - 5.3 Folder
   - 5.4 List
   - 5.5 Task
   - 5.6 Subtask
6. [ID Format Reference](#6-id-format-reference)
7. [Key Endpoints per Hierarchy Level](#7-key-endpoints-per-hierarchy-level)
8. [Permissions Model — Roles, Access Levels, Guests](#8-permissions-model--roles-access-levels-guests)
9. [Rate Limits](#9-rate-limits)
10. [Common Auth Errors & How to Handle Them](#10-common-auth-errors--how-to-handle-them)
11. [Security Best Practices](#11-security-best-practices)
12. [Webhook Signatures](#12-webhook-signatures)
13. [Practical Code Examples](#13-practical-code-examples)
14. [Terminology Gotchas — v2 vs v3 Naming](#14-terminology-gotchas--v2-vs-v3-naming)
15. [Sources](#15-sources)

---

## 1. API Overview & Base URL

The ClickUp API v2 is a REST API that gives you programmatic access to all ClickUp resources: workspaces, spaces, folders, lists, tasks, comments, members, time tracking, and more.

**Base URL:**
```
https://api.clickup.com/api/v2/
```

All endpoints are HTTPS-only. Requests use standard HTTP verbs: `GET`, `POST`, `PUT`, `DELETE`. The API returns JSON responses and expects `Content-Type: application/json` on all POST/PUT requests. Using form-encoded data is not fully supported and can produce unexpected behavior.

**API versioning note:** ClickUp is actively building API v3 (base: `/api/v3/`). As of 2026, v2 remains the stable production API. v3 introduces updated terminology and addresses v2 performance limitations (notably for large task lists). This document covers v2 exclusively.

---

## 2. Authentication Methods

ClickUp API v2 supports exactly two authentication methods. There is no API key passed as a query parameter, no Basic Auth — only token-based authentication through a single `Authorization` header.

### 2.1 Personal API Token

**What it is:** A long-lived token tied to a single ClickUp user account. It never expires.

**Token format:** Always begins with `pk_`. Example:
```
pk_4753994_EXP7MPOJ7XQM5UJDV2M45MPF0YHH5YHO
```

**Use cases:**
- Rapid prototyping and testing
- Internal scripts and automation tools for your own workspace
- Server-side utilities where you are the sole operator
- Any scenario where you do not need to act on behalf of other users

**Limitations:**
- Grants the same permissions as the user who created the token — no more, no less
- Not suitable for multi-user or public applications where each user needs their own scoped access
- Tied to the creator's account: if that user is removed from the workspace, the token loses access

**How to generate a personal token:**
1. Log in to ClickUp
2. Click your avatar in the upper-right corner
3. Select Settings
4. In the sidebar, click Apps
5. Under "API Token", click Generate (or Regenerate to rotate the existing token)
6. Click Copy to copy the token to your clipboard

**Important:** Regenerating a token invalidates the previous token immediately. Any integrations using the old token will break.

Personal tokens never expire on their own — they remain valid until manually regenerated or the account is deleted.

---

### 2.2 OAuth 2.0 Flow (Full Detail)

OAuth 2.0 is the correct approach for any integration that will be used by multiple people or distributed publicly. Each user who connects your app gets their own individualized access token, scoped to the workspaces they explicitly authorize.

ClickUp uses the **Authorization Code grant type** — the standard secure server-side OAuth flow.

**OAuth specification values:**
```
Authorization URL:  https://app.clickup.com/api
Access Token URL:   https://api.clickup.com/api/v2/oauth/token
Grant Type:         Authorization Code
```

#### Step 1: Create an OAuth App

Only Workspace owners or admins can create OAuth apps.

1. Log in to ClickUp
2. Click your avatar → Settings
3. Select ClickUp API in the sidebar
4. Click "Create an App" in the upper-right corner
5. Enter your app's name and one or more redirect URLs
6. Click "Create App"
7. You will receive a `client_id` and a `client_secret`

**Security note:** Keep your `client_secret` private at all times. Never expose it in client-side code, mobile apps, or public repositories. It is a server-side credential only.

#### Step 2: Redirect the User to the Authorization URL

Construct the authorization URL and redirect the user's browser to it:

```
https://app.clickup.com/api?client_id={client_id}&redirect_uri={redirect_uri}
```

You can optionally include a `state` parameter for CSRF protection:

```
https://app.clickup.com/api?client_id={client_id}&redirect_uri={redirect_uri}&state={random_state_value}
```

**The `state` parameter is strongly recommended.** It should be a cryptographically random value that you store server-side and verify when the user returns. This prevents cross-site request forgery attacks during the auth flow.

The user will see a ClickUp authorization screen where they can:
- Log in (if not already logged in)
- Select which Workspace(s) to authorize your app to access
- Grant or deny the authorization

**Important:** Users can authorize one or more Workspaces in a single flow. Use the `Get Authorized Teams (Workspaces)` endpoint (`GET /api/v2/team`) after token exchange to discover which workspaces were authorized.

**Redirect URI requirements:**
- Must exactly match one of the redirect URIs registered with your app
- Non-SSL redirect URIs (plain HTTP) may not be supported in the future — use HTTPS in production
- The redirect URI is verified server-side on every authorization attempt

#### Step 3: Receive the Authorization Code

After the user authorizes your app, ClickUp redirects them back to your `redirect_uri` with the authorization code as a query parameter:

```
https://yourapp.com/callback?code=AUTHORIZATION_CODE_HERE
```

If you included a `state` parameter, it will also be returned:
```
https://yourapp.com/callback?code=AUTHORIZATION_CODE_HERE&state=your_state_value
```

**Verify the state value** before proceeding. If the returned state does not match what you stored, abort the flow — the request may be a CSRF attack.

#### Step 4: Exchange the Code for an Access Token

Make a POST request to the token endpoint:

**Endpoint:** `POST https://api.clickup.com/api/v2/oauth/token`

**Request body (JSON):**
```json
{
  "client_id": "your_client_id",
  "client_secret": "your_client_secret",
  "code": "AUTHORIZATION_CODE_FROM_REDIRECT"
}
```

The endpoint also accepts `application/x-www-form-urlencoded` format, though JSON is preferred.

**Successful response:**
```json
{
  "access_token": "the_oauth_access_token"
}
```

**The returned `access_token` is the bearer token** used for all subsequent API calls on behalf of that user. Store it securely (encrypted at rest, never in client-side code).

**Note:** OAuth tokens are not supported in the "Try It" feature of the ClickUp API reference docs. Personal tokens must be used for interactive testing in the documentation portal.

---

### 2.3 Choosing the Right Method

| Scenario | Recommended Method |
|---|---|
| Testing an endpoint quickly | Personal Token |
| Building an internal automation for your own workspace | Personal Token |
| Server-side script, one workspace | Personal Token |
| Public app used by multiple teams | OAuth 2.0 |
| Multi-tenant SaaS that integrates with ClickUp | OAuth 2.0 |
| App distributed to customers | OAuth 2.0 |
| Need per-user access control | OAuth 2.0 |

---

## 3. How to Authenticate Requests (Headers)

Every request to the ClickUp API v2 must include an `Authorization` header. There are two valid formats depending on which authentication method you are using.

### Personal Token Header

For personal API tokens, pass the token value directly — no `Bearer` prefix:

```http
Authorization: pk_4753994_EXP7MPOJ7XQM5UJDV2M45MPF0YHH5YHO
```

This is a notable difference from most APIs. The ClickUp personal token goes straight into the header value without any prefix keyword.

### OAuth 2.0 Access Token Header

For OAuth access tokens, use the standard Bearer scheme:

```http
Authorization: Bearer {access_token}
```

Example:
```http
Authorization: Bearer abc123def456ghi789
```

### Full Request Example (Personal Token, curl)

```bash
curl -X GET "https://api.clickup.com/api/v2/team" \
  -H "Authorization: pk_4753994_EXP7MPOJ7XQM5UJDV2M45MPF0YHH5YHO" \
  -H "Content-Type: application/json"
```

### Full Request Example (OAuth Token, curl)

```bash
curl -X GET "https://api.clickup.com/api/v2/team" \
  -H "Authorization: Bearer abc123def456ghi789" \
  -H "Content-Type: application/json"
```

### Full Request Example (Creating a Task, Python)

```python
import requests

CLICKUP_TOKEN = "pk_4753994_EXP7MPOJ7XQM5UJDV2M45MPF0YHH5YHO"
LIST_ID = "123456789"

headers = {
    "Authorization": CLICKUP_TOKEN,
    "Content-Type": "application/json"
}

payload = {
    "name": "New Task from API",
    "description": "Created via Python",
    "priority": 2,
    "status": "in progress"
}

response = requests.post(
    f"https://api.clickup.com/api/v2/list/{LIST_ID}/task",
    headers=headers,
    json=payload
)
print(response.json())
```

### Content-Type Requirement

Always set `Content-Type: application/json` on POST and PUT requests. ClickUp does not fully support form-encoded data and unexpected behavior can result if this header is missing or incorrect.

---

## 4. OAuth Token Details — Expiration, Refresh, Scopes

### Token Expiration

**Personal tokens:** Never expire. They remain valid until the user manually regenerates the token in Settings → Apps.

**OAuth access tokens:** Currently do not expire. Per the official FAQ: *"OAuth access tokens do not expire at this time."* The documentation explicitly notes this behavior is subject to change in the future. There is no refresh token mechanism documented for v2 — when ClickUp introduces expiration, a new authorization flow will likely be required.

**Practical implication:** For current integrations, you do not need to implement token refresh logic. However, tokens can become invalid if:
- The user revokes access to your app
- The workspace authorization is removed
- The ClickUp account is deleted

**Best practice:** Handle `OAUTH_019`, `OAUTH_021`, `OAUTH_025`, and `OAUTH_077` error codes gracefully — these indicate a revoked or invalid token and require re-authorization, not a simple retry.

### OAuth Scopes

ClickUp API v2 does not publish a granular, explicit list of OAuth scopes in the way that Google or GitHub do (where you request `read:user` or `repo` scope individually). Instead, the authorization is workspace-level: the user selects which workspaces to grant access to, and the resulting token has access to all data within those workspaces that the user themselves can access.

This means:
- The token inherits the user's own permission level within the workspace
- There is no way to request "read-only" access at the OAuth level in v2
- The user's role (Owner, Admin, Member, Guest) determines what the token can and cannot do
- Access is bounded by what the authorizing user can see and modify

After token exchange, call `GET /api/v2/team` to retrieve the list of authorized workspaces for the token. This is the correct way to discover which workspaces a user authorized during the OAuth flow.

---

## 5. Core Data Model — The ClickUp Hierarchy

ClickUp organizes all work in a strict hierarchy with six levels. Understanding this hierarchy is essential for navigating the API, since every endpoint is scoped to a level in the tree and requires the parent's ID.

```
Workspace (Team)
  └── Space
        ├── Folder
        │     └── List
        │           └── Task
        │                 └── Subtask (nested subtasks also supported)
        └── List (Folderless — directly under Space)
```

Each level down the tree is contained within the level above it. Tasks always live in a List. Lists always live in either a Folder or directly in a Space (folderless). Folders always live in a Space. Spaces always live in a Workspace.

---

### 5.1 Workspace (Team)

The Workspace is the top-level organizational entity in ClickUp. It represents an entire organization or company account.

**API v2 terminology note:** In the v2 API, Workspaces are called "Teams" and their identifier is `team_id`. This is legacy naming carried over from earlier ClickUp versions. In API v3, this was renamed to "Workspace" and uses `workspace_id`. For all v2 endpoints, always use `team_id` when referring to a workspace.

**What a Workspace contains:**
- All users (members, admins, guests)
- All Spaces
- Global settings (integrations, billing, permissions defaults)
- Member IDs that identify users throughout all API calls

**Practical use:** The `team_id` is required on many endpoints across the entire hierarchy (e.g., searching tasks across the workspace, creating spaces). It is one of the most important IDs to retrieve and cache at the start of any integration.

**Get your Workspace ID:**
```bash
GET https://api.clickup.com/api/v2/team
```
This returns all workspaces authorized for the current token, including their `id` (the `team_id`).

---

### 5.2 Space

Spaces are the first organizational layer inside a Workspace. They typically map to departments, teams, or major business functions (e.g., "Marketing", "Engineering", "Client Work").

**What a Space contains:**
- Folders (and folderless Lists)
- Space-level settings: statuses, features (sprints, time tracking, custom fields, etc.), privacy
- Member visibility controls

**Key Space properties returned by the API:**
```json
{
  "id": "space_id_number",
  "name": "Marketing",
  "private": false,
  "statuses": [...],
  "multiple_assignees": true,
  "features": {
    "due_dates": { "enabled": true },
    "time_tracking": { "enabled": true },
    "tags": { "enabled": true },
    "time_estimates": { "enabled": true },
    "checklists": { "enabled": true },
    "custom_fields": { "enabled": true },
    "remap_dependencies": { "enabled": false },
    "dependency_warning": { "enabled": true },
    "portfolios": { "enabled": false }
  }
}
```

Spaces can be public (visible to all workspace members) or private (only visible to specific members). For private Spaces, the API can only return member info to users who have access to that Space.

---

### 5.3 Folder

Folders live inside Spaces and group related Lists together. They were historically called "Projects" in older ClickUp versions — the FAQ confirms this: *"Projects is the legacy term for what are now called Folders in ClickUp."*

**What a Folder contains:**
- One or more Lists
- Folder-level metadata (name, status, override settings)

**Folderless Lists:** ClickUp supports Lists that exist directly within a Space without being nested inside a Folder. The API handles these with a separate endpoint variant: `GET /api/v2/space/{space_id}/list` (as opposed to `GET /api/v2/folder/{folder_id}/list` for folder-scoped lists).

---

### 5.4 List

Lists are where Tasks actually live. Every task belongs to a "home" List — this is the list where the task was created and where it is primarily managed.

**Key List properties:**
```json
{
  "id": "list_id_number",
  "name": "Sprint 1",
  "orderindex": 0,
  "status": null,
  "priority": null,
  "assignee": null,
  "task_count": 24,
  "due_date": null,
  "start_date": null,
  "folder": { "id": "folder_id", "name": "Q2 Project", "hidden": false },
  "space": { "id": "space_id", "name": "Engineering", "access": true },
  "archived": false,
  "override_statuses": null,
  "statuses": [...],
  "permission_level": "create"
}
```

**Tasks in Multiple Lists (TIML):** ClickUp supports adding tasks to multiple lists. However, a task always has exactly one "home" List. When querying `GET /api/v2/list/{list_id}/task`, only tasks whose home is `list_id` are returned by default. To include tasks from other lists that have been added to this list, use the `include_timl=true` query parameter.

---

### 5.5 Task

Tasks are the atomic unit of work in ClickUp. They live in Lists and contain all the actual work data.

**Core task fields:**
```json
{
  "id": "9hz",
  "custom_id": null,
  "name": "Design new landing page",
  "text_content": "Plain text description",
  "description": "HTML description",
  "status": {
    "status": "in progress",
    "color": "#4194f6",
    "type": "custom",
    "orderindex": 1
  },
  "orderindex": "1.00000000000000000000000000000000",
  "date_created": "1567780450202",
  "date_updated": "1567780450202",
  "creator": {
    "id": 183,
    "username": "John Smith",
    "color": "#827718",
    "profilePicture": null
  },
  "assignees": [],
  "checklists": [],
  "tags": [],
  "parent": null,
  "priority": null,
  "due_date": null,
  "start_date": null,
  "time_estimate": null,
  "time_spent": 0,
  "custom_fields": [],
  "list": { "id": "124", "name": "List", "access": true },
  "folder": { "id": "457", "name": "Folder 3", "hidden": false, "access": true },
  "space": { "id": "789" },
  "url": "https://app.clickup.com/t/9hz"
}
```

**Priority values (numeric, not customizable):**
| Value | Label |
|---|---|
| 1 | Urgent |
| 2 | High |
| 3 | Normal |
| 4 | Low |
| null | No priority |

**Time fields:** `time_estimate` and `time_spent` are both in **milliseconds**.

**Date fields:** `date_created`, `date_updated`, `due_date`, `start_date` are all **Unix timestamps in milliseconds** (not seconds).

---

### 5.6 Subtask

Subtasks are not a separate resource type — they are tasks with a `parent` property set to another task's ID. This design means you interact with subtasks using all the same Task endpoints.

**How to identify a subtask:** Check the `parent` field in the task object.
- `"parent": null` — top-level task
- `"parent": "1234"` — subtask of task `1234`

**Nested subtasks** are fully supported. A subtask can itself have subtasks, creating arbitrarily deep nesting. Each nested subtask's `parent` field points to its immediate parent:

```
Top level task:     id=1234,  parent=null
  └── Subtask:      id=4567,  parent=1234
        └── Subtask: id=9876, parent=4567
```

**Creating a subtask:** Use the standard Create Task endpoint (`POST /api/v2/list/{list_id}/task`) and set the `parent` field in the request body:

```json
{
  "name": "Subtask name",
  "parent": "parent_task_id"
}
```

**Viewing subtasks:** By default, `GET /api/v2/list/{list_id}/task` does not return subtasks. Add `?subtasks=true` to include them. The `GET /api/v2/task/{task_id}` endpoint supports `include_subtasks=true`.

**Updating and deleting subtasks:** Use the same Update Task (`PUT /api/v2/task/{task_id}`) and Delete Task endpoints as regular tasks — the `task_id` is the subtask's own ID.

---

## 6. ID Format Reference

Understanding how ClickUp IDs are formatted is critical for building reliable integrations.

| Entity | ID Field | Type | Format | Example |
|---|---|---|---|---|
| Workspace (Team) | `team_id` | Numeric (double) | Integer | `9012345` |
| Space | `space_id` | Numeric (double) | Integer | `789456` |
| Folder | `folder_id` | Numeric (double) | Integer | `123456` |
| List | `list_id` | Numeric (double) | Integer | `987654321` |
| Task | `task_id` | String | Short alphanumeric | `"9hz"`, `"c0j"`, `"8xdfdjbgd"` |
| User | `user_id` | Integer | Integer | `183`, `395492` |
| Group (User Group) | `group_id` | String/UUID | UUID | `"7689a169-a000-4985-..."` |

**Key observations:**

1. **team_id, space_id, folder_id, list_id are all numeric.** Despite the API spec defining them as `type: number, contentEncoding: double`, they are effectively large integers. In Python, treat them as `int`. In JavaScript, be aware that extremely large integers may lose precision — use string representations if needed.

2. **task_id is a short alphanumeric string**, not a number. Examples from the official docs: `"9hz"`, `"c0j"`, `"9hx"`, `"8xdfdjbgd"`. These are compact, URL-safe identifiers. Always treat `task_id` as a string, never a number.

3. **Custom Task IDs:** ClickUp Business Plan and above supports user-defined custom task IDs (e.g., `CLK-1`, `ENG-42`). These are separate from the system `task_id`. To use a custom task ID in API calls, you must pass `?custom_task_ids=true&team_id={team_id}` as query parameters. Without these parameters, the API will look up the provided ID as a system `task_id`, not a custom one.

4. **`team_id` vs `group_id` ambiguity:** In v2, `team_id` = Workspace ID. The `group_id` refers to a User Group (a named collection of users within a workspace). This is a common source of confusion. The FAQ is explicit: *"`team_id` refers to the id of a Workspace, and `group_id` refers to the id of a Team (a group of users)."*

---

## 7. Key Endpoints per Hierarchy Level

Base URL for all endpoints: `https://api.clickup.com/api/v2`

### 7.1 Workspace (Team) Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/team` | Get all authorized workspaces for the current token |
| GET | `/team/{team_id}` | Get a specific workspace by ID |

**Get Authorized Teams response example:**
```json
{
  "teams": [
    {
      "id": "9012345",
      "name": "My Company",
      "color": "#536cfe",
      "avatar": null,
      "members": [
        {
          "user": {
            "id": 183,
            "username": "John Smith",
            "email": "john@example.com",
            "color": "#827718",
            "role": 3
          }
        }
      ]
    }
  ]
}
```

---

### 7.2 Space Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/team/{team_id}/space` | Get all spaces in a workspace |
| POST | `/team/{team_id}/space` | Create a new space |
| GET | `/space/{space_id}` | Get a specific space |
| PUT | `/space/{space_id}` | Update a space |
| DELETE | `/space/{space_id}` | Delete a space |

**Get Spaces query parameters:**
- `archived` (boolean): include archived spaces (default: false)

**Create Space request body:**
```json
{
  "name": "New Space",
  "multiple_assignees": true,
  "features": {
    "due_dates": { "enabled": true, "start_date": false, "remap_due_dates": true, "remap_closed_due_date": false },
    "time_tracking": { "enabled": false },
    "tags": { "enabled": true },
    "time_estimates": { "enabled": true },
    "checklists": { "enabled": true },
    "custom_fields": { "enabled": true },
    "remap_dependencies": { "enabled": false },
    "dependency_warning": { "enabled": true },
    "portfolios": { "enabled": false }
  }
}
```

---

### 7.3 Folder Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/space/{space_id}/folder` | Get all folders in a space |
| POST | `/space/{space_id}/folder` | Create a folder in a space |
| GET | `/folder/{folder_id}` | Get a specific folder |
| PUT | `/folder/{folder_id}` | Update a folder |
| DELETE | `/folder/{folder_id}` | Delete a folder |

**Create Folder request body (minimum required):**
```json
{
  "name": "New Folder"
}
```

---

### 7.4 List Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/folder/{folder_id}/list` | Get lists in a folder |
| POST | `/folder/{folder_id}/list` | Create a list in a folder |
| GET | `/space/{space_id}/list` | Get folderless lists in a space |
| POST | `/space/{space_id}/list` | Create a folderless list in a space |
| GET | `/list/{list_id}` | Get a specific list |
| PUT | `/list/{list_id}` | Update a list |
| DELETE | `/list/{list_id}` | Delete a list |
| GET | `/list/{list_id}/member` | Get members with access to a list |

**Get Lists query parameters:**
- `archived` (boolean): include archived lists (default: false)

**Create List request body (folder-scoped):**
```json
{
  "name": "Sprint 1",
  "content": "Sprint 1 description",
  "due_date": 1567780450202,
  "due_date_time": false,
  "priority": 1,
  "assignee": 183,
  "status": "red"
}
```

---

### 7.5 Task Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/list/{list_id}/task` | Get tasks in a list (max 100 per page) |
| POST | `/list/{list_id}/task` | Create a task in a list |
| GET | `/task/{task_id}` | Get a specific task |
| PUT | `/task/{task_id}` | Update a task |
| DELETE | `/task/{task_id}` | Delete a task |
| GET | `/team/{team_id}/task` | Get filtered tasks across the entire workspace |
| GET | `/task/{task_id}/member` | Get members with access to a task |

**Get Tasks query parameters (selected):**
- `archived` (boolean)
- `include_markdown_description` (boolean)
- `page` (integer) — pagination, 0-indexed, 100 tasks per page
- `order_by` (string) — sort field
- `reverse` (boolean) — reverse sort
- `subtasks` (boolean) — include subtasks
- `statuses[]` (array) — filter by status
- `assignees[]` (array) — filter by assignee user IDs
- `due_date_gt` / `due_date_lt` (integer) — date range filters (Unix ms)
- `date_created_gt` / `date_created_lt` (integer)
- `date_updated_gt` / `date_updated_lt` (integer)
- `custom_fields` — filter by custom field values
- `include_timl` (boolean) — include tasks added to this list from other lists

**Get Filtered Team Tasks (`GET /team/{team_id}/task`)** is the power endpoint for cross-list, cross-folder task queries. It supports all the same filter parameters above, plus additional cross-hierarchy filtering.

**Create Task request body:**
```json
{
  "name": "New Task Name",
  "description": "New Task Description",
  "assignees": [183],
  "tags": ["tag1", "tag2"],
  "status": "in progress",
  "priority": 1,
  "due_date": 1508369194377,
  "due_date_time": false,
  "time_estimate": 8640000,
  "start_date": 1567780450202,
  "start_date_time": false,
  "notify_all": true,
  "parent": null,
  "links_to": null,
  "check_required_custom_fields": true,
  "custom_fields": [
    {
      "id": "0a52c486-5f05-403b-b4fd-c512ff05131c",
      "value": 23
    }
  ]
}
```

**Create Subtask:** Same endpoint, but set `"parent": "parent_task_id"` in the body.

**Pagination:** Task list responses are capped at 100 tasks. Use `page=0`, `page=1`, etc. to paginate. Continue incrementing until fewer than 100 tasks are returned, which signals the last page.

---

### 7.6 User/Member Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/team/{team_id}/user/{user_id}` | Get a workspace member's details |
| PUT | `/team/{team_id}/user/{user_id}` | Edit a workspace member (role, etc.) |
| DELETE | `/team/{team_id}/user/{user_id}` | Remove a member from workspace |

---

### 7.7 Authorization Endpoints

| Method | Path | Description |
|---|---|---|
| POST | `/oauth/token` | Exchange authorization code for access token |
| GET | `/team` | Get authorized workspaces for current token |
| GET | `/user` | Get the currently authenticated user |

---

## 8. Permissions Model — Roles, Access Levels, Guests

ClickUp uses a layered permissions system. A user's effective access to any resource is determined by three factors combining together:

1. Their Workspace role
2. The sharing and permission settings on the specific item (Space/Folder/List/Task)
3. Whether they are a member or guest

### 8.1 Workspace Roles

Roles are represented numerically in the API via the `"role"` field in user objects:

| Role Number | Label | Description |
|---|---|---|
| 1 | Workspace Owner | Full control — billing, all settings, promote/demote all users including admins |
| 2 | Admin | Most management capabilities minus full billing control |
| 3 | Member | Regular user — can create/edit tasks where they have access |
| 4 | Guest | Limited access — can only see what has been explicitly shared with them |

**Owner capabilities:**
- Access and update all public Spaces, Folders, and Lists
- Change security and sharing defaults workspace-wide
- Promote or demote any user including admins
- Manage billing and workspace settings

**Admin capabilities:**
- View and adjust most public items
- Configure default Space settings
- Control most permission-related settings
- Manage users and guests (cannot manage owners unless delegated)

**Member capabilities:**
- Create and edit tasks in locations where they have access
- Collaborate via comments, attachments, time tracking
- Create views, docs, dashboards based on sharing settings
- Access determined by Space/Folder/List sharing configuration

**Guest capabilities:**
- Can only see items explicitly shared with them
- Cannot access any part of the workspace not specifically granted

### 8.2 Guest Billing Considerations

A critical operational note from the API docs:

> Adding a guest with view-only permissions to a Team automatically converts them to a paid guest. If no paid guest seats are available, an additional member seat will be added, increasing the number of paid guest seats. This change incurs a prorated charge based on the billing cycle.

This means automating guest additions via the API can trigger unexpected billing charges. Always verify seat availability before programmatically adding guests.

### 8.3 Access at Item Level

Even with the correct workspace role, access can be further restricted by item-level settings:

- **Spaces** can be made private — only explicitly added members can see them
- **Folders** can have their own sharing restrictions within a Space
- **Lists** can have permission levels: view, comment, edit, create
- **Tasks** inherit from their parent List unless overridden

The `permission_level` field in List responses indicates the current token's access level to that specific list: values include `read`, `comment`, `create`, `edit`, `manage`.

### 8.4 User Groups

ClickUp supports User Groups — named collections of users that can be assigned to tasks or given access to locations. In the API:
- Create: `POST /api/v2/team/{team_id}/group`
- The `group_id` identifies a User Group (not to be confused with `team_id` which identifies a Workspace)
- Tasks can have `group_assignees` in addition to individual `assignees`

---

## 9. Rate Limits

Rate limits apply per token (both personal and OAuth tokens) and are determined by the Workspace plan.

| Plan | Rate Limit |
|---|---|
| Free Forever | 100 requests/minute/token |
| Unlimited | 100 requests/minute/token |
| Business | 100 requests/minute/token |
| Business Plus | 1,000 requests/minute/token |
| Enterprise | 10,000 requests/minute/token |

### Rate Limit Response Headers

Every API response includes headers for monitoring rate limit status:

| Header | Description |
|---|---|
| `X-RateLimit-Limit` | Maximum requests allowed in current window |
| `X-RateLimit-Remaining` | Requests remaining before throttling |
| `X-RateLimit-Reset` | Unix timestamp when the window resets |

### Handling 429 Errors

When the rate limit is exceeded, the API returns:
- HTTP status code: `429 Too Many Requests`
- Check `X-RateLimit-Reset` to determine when to retry

**Recommended pattern:**
```python
import time
import requests

def clickup_request_with_retry(url, headers, max_retries=3):
    for attempt in range(max_retries):
        response = requests.get(url, headers=headers)

        if response.status_code == 200:
            return response.json()
        elif response.status_code == 429:
            reset_time = int(response.headers.get('X-RateLimit-Reset', 0))
            wait_seconds = max(reset_time - int(time.time()), 1)
            print(f"Rate limited. Waiting {wait_seconds}s before retry...")
            time.sleep(wait_seconds)
        else:
            response.raise_for_status()

    raise Exception("Max retries exceeded")
```

---

## 10. Common Auth Errors & How to Handle Them

### HTTP Status Code Reference

| Code | Meaning | Common Cause |
|---|---|---|
| 200 | Success | Request processed normally |
| 400 | Bad Request | Invalid JSON, wrong field types, missing required params |
| 401 | Unauthorized | Missing or invalid Authorization header |
| 403 | Forbidden | Token is valid but lacks permission for the requested resource |
| 404 | Not Found | Resource ID does not exist or token cannot see it |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Server Error | ClickUp internal error — retry after a delay |

### ClickUp-Specific OAuth Error Codes

| Error Code | Meaning | Resolution |
|---|---|---|
| `OAUTH_007` | Redirect URI does not match registered URIs | Update the redirect URI in your app settings |
| `OAUTH_010` | Client application not found | Verify `client_id` is correct; recreate the app if needed |
| `OAUTH_017` | Authorization header missing OR redirect URI missing in OAuth flow | Add the `Authorization` header; ensure redirect URI is present |
| `OAUTH_019` | Token not found (access revoked) | Re-initiate OAuth flow with the user |
| `OAUTH_021` | Token not found | Re-initiate OAuth flow |
| `OAUTH_023` | Team not authorized for this token | Redirect user to authorize the workspace |
| `OAUTH_025` | Token not found | Re-initiate OAuth flow |
| `OAUTH_026` | Team not authorized | Redirect user to authorize the workspace |
| `OAUTH_027` | Team not authorized | Redirect user to authorize the workspace |
| `OAUTH_029`–`OAUTH_045` | Various team authorization errors | Redirect user to re-authorize the workspace |
| `OAUTH_077` | Token not found | Re-initiate OAuth flow |
| `OAUTH_171` | Webhook configuration already exists | Use the existing webhook or delete it before creating a new one |

### Error Response Format

All error responses include a JSON body:
```json
{
  "err": "Authorization header required",
  "ECODE": "OAUTH_017"
}
```

Some errors include a `details` array with field-level validation information:
```json
{
  "err": "Bad Request",
  "ECODE": "INPUT_003",
  "details": [
    {
      "field": "due_date",
      "message": "due_date must be a number"
    }
  ]
}
```

### CORS Error

If making ClickUp API requests directly from a browser (frontend JavaScript), you will encounter:
```
XMLHttpRequest from origin has been blocked by CORS policy
```

ClickUp's API does not support browser-based direct calls. Solution: implement a server-side proxy. Route all ClickUp API calls through your backend — your frontend calls your server, your server calls ClickUp. This keeps tokens server-side and avoids CORS issues.

---

## 11. Security Best Practices

### Token Storage

**Personal tokens:**
- Store in environment variables (`CLICKUP_API_TOKEN`), never hard-coded
- Use a secrets manager (AWS Secrets Manager, HashiCorp Vault, 1Password Secrets Automation) in production
- Never commit tokens to version control — use `.gitignore` and `.env` files

**OAuth client credentials:**
- `client_id` is semi-public (it's in the authorization URL) but keep it out of version control
- `client_secret` is private — treat it like a password. Never expose in client-side code
- OAuth access tokens should be stored encrypted at rest in your database

**Code pattern:**
```python
import os

# Correct: from environment
token = os.getenv("CLICKUP_API_TOKEN")

# Never do this:
token = "pk_4753994_EXP7MPOJ7XQM5UJDV2M45MPF0YHH5YHO"
```

### HTTPS Requirement

All ClickUp API communication must use HTTPS. Never send tokens over plain HTTP.

### State Parameter in OAuth

Always include the `state` parameter when initiating the OAuth flow and verify it matches when the user returns. This prevents CSRF attacks that could result in unauthorized workspace access.

```python
import secrets

def start_oauth_flow():
    state = secrets.token_urlsafe(32)
    session['oauth_state'] = state  # store server-side
    auth_url = f"https://app.clickup.com/api?client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}&state={state}"
    return redirect(auth_url)

def oauth_callback(code, state):
    if state != session.get('oauth_state'):
        raise SecurityError("State mismatch — possible CSRF attack")
    # proceed with token exchange
```

### Token Revocation Handling

Build in graceful handling for revoked tokens:
- Catch `OAUTH_019`, `OAUTH_021`, `OAUTH_025`, `OAUTH_077` error codes
- On these errors, mark the token as invalid in your database
- Prompt the user to re-authorize rather than retrying endlessly

### Minimum Required Access

When creating OAuth apps or service accounts, only request access to the workspaces and permissions your integration actually needs. In ClickUp's workspace-level authorization model, this means encouraging users to authorize only the specific workspace your tool needs.

### No Client-Side Calls

Never call the ClickUp API from frontend JavaScript, mobile apps, or any client-side code:
- Your token is exposed in the browser's network tab
- CORS will block the request anyway
- Always proxy through a server

### Audit Logging

For enterprise integrations, log all API operations server-side with:
- Timestamp
- Which token/user made the request
- What endpoint was called
- What workspace/resource was modified

This enables incident response if a token is compromised.

---

## 12. Webhook Signatures

ClickUp webhooks are signed using HMAC-SHA256, providing a way to verify that incoming webhook requests are genuinely from ClickUp and have not been tampered with.

**Mechanism:**
1. When you create a webhook, the response includes a `webhook.secret`
2. ClickUp signs every outgoing webhook payload using this secret
3. The signature is included in the `X-Signature` header as a hex digest

**Webhook request structure:**
```
POST /your-webhook-endpoint
Content-Type: application/json
X-Signature: f7bc83f430538424b13298e6aa6fb983

{"webhook_id": "7689a169-a000-4985-8676-6902b96d6627", "event": "taskCreated", "task_id": "c0j"}
```

**Verification (Node.js):**
```javascript
const crypto = require('crypto');

function verifyClickUpWebhook(rawBody, secret, receivedSignature) {
  const computed = crypto
    .createHmac('sha256', secret)
    .update(rawBody)  // rawBody must be the raw string, not a parsed object
    .digest('hex');

  // Use constant-time comparison to prevent timing attacks
  return crypto.timingSafeEqual(
    Buffer.from(computed),
    Buffer.from(receivedSignature)
  );
}
```

**Verification (Python):**
```python
import hmac
import hashlib

def verify_clickup_webhook(raw_body: str, secret: str, received_signature: str) -> bool:
    computed = hmac.new(
        secret.encode('utf-8'),
        raw_body.encode('utf-8'),
        hashlib.sha256
    ).hexdigest()

    return hmac.compare_digest(computed, received_signature)
```

**Critical:** Use the raw, unparsed request body string for HMAC computation. Do not parse the JSON first and then re-serialize — any whitespace or key ordering differences will produce a different hash.

---

## 13. Practical Code Examples

### Complete OAuth Flow (Python / Flask)

```python
import os
import secrets
import requests
from flask import Flask, redirect, request, session

app = Flask(__name__)
app.secret_key = os.getenv("FLASK_SECRET_KEY")

CLIENT_ID = os.getenv("CLICKUP_CLIENT_ID")
CLIENT_SECRET = os.getenv("CLICKUP_CLIENT_SECRET")
REDIRECT_URI = "https://yourapp.com/oauth/callback"
BASE_URL = "https://api.clickup.com/api/v2"

@app.route('/connect')
def connect():
    state = secrets.token_urlsafe(32)
    session['oauth_state'] = state
    auth_url = (
        f"https://app.clickup.com/api"
        f"?client_id={CLIENT_ID}"
        f"&redirect_uri={REDIRECT_URI}"
        f"&state={state}"
    )
    return redirect(auth_url)

@app.route('/oauth/callback')
def oauth_callback():
    # Verify state to prevent CSRF
    if request.args.get('state') != session.get('oauth_state'):
        return "Invalid state", 400

    code = request.args.get('code')
    if not code:
        return "No authorization code", 400

    # Exchange code for token
    response = requests.post(
        f"{BASE_URL}/oauth/token",
        json={
            "client_id": CLIENT_ID,
            "client_secret": CLIENT_SECRET,
            "code": code
        }
    )

    token_data = response.json()
    access_token = token_data.get('access_token')

    # Store access_token securely (here: in session, use DB in production)
    session['clickup_token'] = access_token

    # Get authorized workspaces
    teams_response = requests.get(
        f"{BASE_URL}/team",
        headers={"Authorization": f"Bearer {access_token}"}
    )
    teams = teams_response.json().get('teams', [])

    return f"Connected! Authorized workspaces: {[t['name'] for t in teams]}"
```

### Walking the Full Hierarchy (Python)

```python
import requests

TOKEN = os.getenv("CLICKUP_API_TOKEN")
HEADERS = {
    "Authorization": TOKEN,
    "Content-Type": "application/json"
}
BASE = "https://api.clickup.com/api/v2"

def get_full_hierarchy():
    # 1. Get all workspaces
    teams = requests.get(f"{BASE}/team", headers=HEADERS).json()["teams"]

    for team in teams:
        team_id = team["id"]
        print(f"\nWorkspace: {team['name']} (ID: {team_id})")

        # 2. Get all spaces in workspace
        spaces = requests.get(f"{BASE}/team/{team_id}/space", headers=HEADERS).json()["spaces"]

        for space in spaces:
            space_id = space["id"]
            print(f"  Space: {space['name']} (ID: {space_id})")

            # 3. Get folders in space
            folders = requests.get(f"{BASE}/space/{space_id}/folder", headers=HEADERS).json()["folders"]

            for folder in folders:
                folder_id = folder["id"]
                print(f"    Folder: {folder['name']} (ID: {folder_id})")

                # 4. Get lists in folder
                lists = requests.get(f"{BASE}/folder/{folder_id}/list", headers=HEADERS).json()["lists"]

                for lst in lists:
                    list_id = lst["id"]
                    print(f"      List: {lst['name']} (ID: {list_id}, Tasks: {lst['task_count']})")

            # Don't forget folderless lists
            folderless = requests.get(f"{BASE}/space/{space_id}/list", headers=HEADERS).json()["lists"]
            for lst in folderless:
                print(f"    [No Folder] List: {lst['name']} (ID: {lst['id']})")
```

---

## 14. Terminology Gotchas — v2 vs v3 Naming

This is one of the most common sources of confusion when working with ClickUp's API documentation, since both v2 and v3 docs are present on the developer portal simultaneously.

| Concept | v2 API Term | v3 API Term | Notes |
|---|---|---|---|
| Top-level organization | Team (`team_id`) | Workspace (`workspace_id`) | Same thing, different names |
| User group | Group (`group_id`) | Group | Named collection of users |
| Folder | Folder | Folder | No change (was "Project" in ClickUp 1.x) |
| Task | Task | Task | No change |

**Rule:** If you are working with `/api/v2/` endpoints, always use `team_id` to refer to a workspace. If you mix v2 and v3 terminology, you may pass the wrong ID to the wrong endpoint parameter.

**Additional legacy naming:**
- "Projects" in old ClickUp UI = Folders in the API
- "Teams" in old ClickUp UI = Workspaces
- The legacy term "team" in `/api/v2/team/` routes = Workspace, not a user group

---

## 15. Sources

| Source | URL | Notes |
|---|---|---|
| ClickUp Authentication Docs | https://developer.clickup.com/docs/authentication | Official auth guide |
| Get Access Token Reference | https://developer.clickup.com/reference/getaccesstoken | OAuth token endpoint OpenAPI spec |
| ClickUp API FAQ | https://developer.clickup.com/docs/faq | Token expiry, subtasks, role numbers, team vs workspace |
| Rate Limits | https://developer.clickup.com/docs/rate-limits | Per-plan limits, headers |
| Common Errors | https://developer.clickup.com/docs/common_errors | OAUTH error codes |
| Tasks Docs | https://developer.clickup.com/docs/tasks | Task fields, priorities, subtasks |
| Webhook Signatures | https://developer.clickup.com/docs/webhooksignature | HMAC-SHA256 verification |
| v2 vs v3 Terminology | https://developer.clickup.com/docs/general-v2-v3-api | team_id vs workspace_id |
| Get Tasks Reference | https://developer.clickup.com/reference/gettasks | Task listing endpoint |
| Get Task Reference | https://developer.clickup.com/reference/gettask | Single task endpoint |
| Create Task Reference | https://developer.clickup.com/reference/createtask | Task creation endpoint |
| Update Task Reference | https://developer.clickup.com/reference/updatetask | Task update endpoint |
| Get Spaces Reference | https://developer.clickup.com/reference/getspaces | Space listing endpoint |
| Get Lists Reference | https://developer.clickup.com/reference/getlists | List listing endpoint |
| Create OAuth App (Help) | https://help.clickup.com/hc/en-us/articles/6303422883095 | Step-by-step OAuth app setup |
| Custom Task IDs (Help) | https://help.clickup.com/hc/en-us/articles/6304361756951 | Business plan custom IDs |
| Permissions Guide | https://consultevo.com/clickup-permissions-how-to-guide-2/ | Roles and access levels |
