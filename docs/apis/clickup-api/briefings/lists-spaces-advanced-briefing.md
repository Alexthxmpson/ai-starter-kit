# Lists, Spaces & Advanced Features — Briefing

**Coverage: 87-93% | Status: SUBSTANTIAL**

## Spaces API

```
GET /team/{team_id}/space            List all spaces
POST /team/{team_id}/space           Create space
PUT /space/{space_id}                Update space
DELETE /space/{space_id}             Delete space
```

Space `features` object controls capabilities (due_dates, time_tracking, tags, sprints, checklists, custom_fields, native_automations, etc.)

## Folders API

```
GET /space/{space_id}/folder         List folders
POST /space/{space_id}/folder        Create folder
PUT /folder/{folder_id}              Update folder
DELETE /folder/{folder_id}           Delete folder
```

## Lists API

```
GET /folder/{folder_id}/list         Lists in folder
GET /space/{space_id}/list           Folderless lists (different endpoint!)
POST /folder/{folder_id}/list        Create list in folder
POST /space/{space_id}/list          Create folderless list
PUT /list/{list_id}                  Update list
DELETE /list/{list_id}               Delete list
```

**Folderless lists use space endpoint, NOT folder endpoint** — common source of bugs.

## Time Tracking (v2.0)

```
GET /team/{team_id}/time_entries     Get entries (filter: dates, user, task)
POST /team/{team_id}/time_entries    Create entry (body: tid, start, duration)
PATCH /team/{team_id}/time_entries/{id}  Update
DELETE /team/{team_id}/time_entries/{id} Delete
```

- `start` and `duration` are in **milliseconds**
- Negative `duration` = timer currently running
- Only one location filter at a time (space_id OR folder_id OR list_id OR task_id)

## Tags API

```
GET /space/{space_id}/tag            Get space tags
POST /space/{space_id}/tag           Create tag
PUT /tag/{tag_name}                  Update tag color/name
DELETE /space/{space_id}/tag/{tag_name}  Delete tag
POST /task/{task_id}/tag/{tag_name}  Add to task
DELETE /task/{task_id}/tag/{tag_name}  Remove from task
```

## Goals API

```
GET /team/{team_id}/goal             List goals
POST /team/{team_id}/goal            Create goal (name, due_date, owners, color)
PUT /goal/{goal_id}                  Update goal
DELETE /goal/{goal_id}               Delete goal
POST /goal/{goal_id}/key_result      Add key result
PUT /key_result/{key_result_id}      Update key result
DELETE /key_result/{key_result_id}   Delete key result
```

Key result types: `number`, `currency`, `boolean`, `percentage`, `automatic`

## Views API

```
GET /team/{team_id}/view             Workspace-level views
GET /space/{space_id}/view           Space views
GET /folder/{folder_id}/view         Folder views
GET /list/{list_id}/view             List views
GET /view/{view_id}/task             Get tasks in a view
POST /{level}/{id}/view              Create view
```

View types: list, board, calendar, table, gantt, activity, map, conversation, workload
**Docs and Whiteboard views not accessible via v2 Views API.**

## Checklists API

```
POST /task/{task_id}/checklist                       Create checklist
PUT /checklist/{id}                                  Update (rename)
DELETE /checklist/{id}                               Delete
POST /checklist/{id}/checklist_item                  Add item
PUT /checklist/{id}/checklist_item/{item_id}         Update item (name, resolved, assignee)
DELETE /checklist/{id}/checklist_item/{item_id}      Delete item
```

## Dependencies API

```
POST /task/{task_id}/dependency      Add dependency
DELETE /task/{task_id}/dependency    Remove dependency
```

Body fields:
- `depends_on`: This task WAITS for the specified task
- `dependency_of`: The specified task WAITS for this task

## Attachments API

```
POST /task/{task_id}/attachment      Upload file
```

**Must use `multipart/form-data`** — not JSON. Do NOT set Content-Type header manually (let HTTP client set it with boundary). Storage full error: `GBUSED_005`.

## Members API

```
GET /team/{team_id}/member           Workspace members
GET /list/{list_id}/member           List members
GET /task/{task_id}/member           Task members
POST /task/{task_id}/member          Add member to task
DELETE /task/{task_id}/member/{uid}  Remove member
```

**Adding guests:** May trigger billing. Enterprise plan only.

## Status Rules

- Each list/space must have at least 1 `"type": "open"` + 1 `"type": "closed"` status
- Status names are **case-sensitive** in all task queries
- Status colors use hex format: `"#d3d3d3"`

## Sources

- https://developer.clickup.com/docs/views
- https://developer.clickup.com/reference/getfolders
- https://developer.clickup.com/reference/createtaskattachment
- https://developer.clickup.com/reference/createatimeentry
- https://developer.clickup.com/reference/creategoal
