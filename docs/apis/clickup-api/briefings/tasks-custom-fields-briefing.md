# Tasks & Custom Fields — Briefing

**Coverage: 97% | Status: COMPLETE**

## Task CRUD Quick Reference

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Create | POST | `/list/{list_id}/task` |
| Read | GET | `/task/{task_id}` |
| Update | PUT | `/task/{task_id}` |
| Delete | DELETE | `/task/{task_id}` |
| List tasks | GET | `/list/{list_id}/task?page=0` |
| Workspace tasks | GET | `/team/{team_id}/task` |

## Critical: Assignees Differ Between Create and Update

```python
# CREATE (flat array)
{"assignees": [183, 224]}

# UPDATE (add/remove object)
{"assignees": {"add": [182], "rem": [183]}}
```

## Date Fields

All dates are **Unix timestamps in milliseconds** (not seconds!):
```python
now_ms = int(time.time() * 1000)  # correct
now_s = int(time.time())          # WRONG — will set dates to 1970
```

## Priority Values

| API Value | Label |
|-----------|-------|
| 1 | Urgent |
| 2 | High |
| 3 | Normal |
| 4 | Low |
| null | None |

## Subtasks

Create subtask = regular task + `parent` field set to parent task_id. Parent must be in same list.

## Pagination

100 tasks per page. Use `last_page: boolean` as stop signal (NOT item count):
```python
page = 0
while True:
    resp = client.get(f"/list/{list_id}/task", params={"page": page})
    tasks.extend(resp["tasks"])
    if resp.get("last_page") or not resp["tasks"]:
        break
    page += 1
```

## Custom Fields

**Cannot be created via API.** Create in UI first. Then:
1. `GET /list/{list_id}/field` → get UUIDs + type_config
2. `POST /task/{task_id}/field/{field_id}` → set value
3. `DELETE /task/{task_id}/field/{field_id}` → remove value
4. Task response includes `custom_fields` array with current values

**17 field types and their value formats:**

| Type | Value Format |
|------|-------------|
| text, short_text | string |
| number, currency | number |
| checkbox | boolean |
| drop_down | option UUID string |
| labels | string[] of option UUIDs |
| date | Unix ms integer |
| url, email, phone | string |
| emoji (rating) | integer 0..count |
| manual_progress | {"current": number} |
| automatic_progress | READ ONLY |
| users (people) | {"add": [uid], "rem": [uid]} |
| tasks (relationship) | {"add": [tid], "rem": [tid]} |
| location | {location: {lat, lng}, formatted_address} |

**Gotchas:**
- Custom field IDs are UUIDs — always pre-fetch, never guess
- Free plan: 60 lifetime custom field writes (workspace total, never resets)
- Custom fields NOT updatable via `PUT /task/{id}` — separate endpoint required

## Filtering

Key params for `GET /list/{list_id}/task`:
- `statuses[]` — case-sensitive status names
- `assignees[]` — user IDs
- `due_date_gt`, `due_date_lt` — Unix ms timestamps
- `date_updated_gt` — for incremental sync
- `subtasks=true` — include subtasks
- `include_closed=true` — include closed tasks
- `include_timl=true` — include tasks added from other lists

## Sources

- https://developer.clickup.com/docs/tasks
- https://developer.clickup.com/reference/createtask
- https://developer.clickup.com/docs/customfields
- https://developer.clickup.com/reference/setcustomfieldvalue
- https://developer.clickup.com/docs/taskfilters
