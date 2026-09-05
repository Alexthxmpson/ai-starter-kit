# Webhooks & Comments — Briefing

**Coverage: 92-94% | Status: COMPLETE**

## Webhook Quick Reference

| Operation | Method | Endpoint |
|-----------|--------|----------|
| List webhooks | GET | `/team/{team_id}/webhook` |
| Create webhook | POST | `/team/{team_id}/webhook` |
| Update webhook | PUT | `/webhook/{webhook_id}` |
| Delete webhook | DELETE | `/webhook/{webhook_id}` |

## Create Webhook

```json
POST /team/{team_id}/webhook
{
  "endpoint": "https://your-server.com/clickup-webhook",
  "events": ["taskCreated", "taskStatusUpdated"],
  "space_id": 12345678
}
```

- Use `"events": "*"` for all events
- `space_id`, `list_id`, `task_id` to scope webhook to specific resources
- Response includes `webhook.secret` — **store it immediately, shown only once**

## All 27 Event Types

**Task:** taskCreated, taskUpdated, taskDeleted, taskStatusUpdated, taskPriorityUpdated, taskAssigneeUpdated, taskDueDateUpdated, taskTagUpdated, taskMoved, taskCommentPosted, taskCommentUpdated, taskTimeTracked

**List:** listCreated, listUpdated, listDeleted

**Folder:** folderCreated, folderUpdated, folderDeleted

**Space:** spaceCreated, spaceUpdated, spaceDeleted

**Goal/KR:** goalCreated, goalUpdated, goalDeleted, goalKeyResultCreated, goalKeyResultUpdated, goalKeyResultDeleted

## Payload Structure

```json
{
  "webhook_id": "7fa3ec74-...",
  "event": "taskStatusUpdated",
  "task_id": "9hx",
  "history_items": [
    {
      "field": "status",
      "before": {"status": "in progress", "color": "#d3d3d3"},
      "after": {"status": "Open", "color": "#d3d3d3"},
      "user": {"id": 183, "username": "John"},
      "date": "1566400646923"
    }
  ]
}
```

## HMAC Signature Verification

```python
import hashlib, hmac

def verify_clickup_webhook(raw_body: bytes, signature: str, secret: str) -> bool:
    expected = hmac.new(
        secret.encode("utf-8"),
        raw_body,
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(expected, signature)
```

**Critical rules:**
- Compute HMAC on **raw bytes** before JSON parsing
- Result is **hex-encoded** (`.hexdigest()`), never base64
- Use constant-time comparison (`hmac.compare_digest`)
- Header is `X-Signature`

## Reliability Rules

| Rule | Detail |
|------|--------|
| Response timeout | 7 seconds — respond immediately, process async |
| Retries | 5 per event, then dropped (no replay) |
| Suspension trigger | fail_count ≥ 100, or your server returns 401/410 |
| Reactivation | PUT with `{"status": "active"}` |
| Duplicate webhook | OAUTH_171 error — already registered for URL + location |

## Production Webhook Handler Pattern

```python
@app.post("/clickup-webhook")
async def handle_webhook(request: Request, background_tasks: BackgroundTasks):
    body = await request.body()
    sig = request.headers.get("x-signature", "")
    if not verify_clickup_webhook(body, sig, WEBHOOK_SECRET):
        raise HTTPException(401)
    event = json.loads(body)
    background_tasks.add_task(process_event, event)  # respond first
    return JSONResponse({"received": True})
```

## Comments API

| Operation | Method | Endpoint |
|-----------|--------|----------|
| Create task comment | POST | `/task/{task_id}/comment` |
| Get task comments | GET | `/task/{task_id}/comment` |
| Get threaded comments | GET | `/task/{task_id}/comment/threaded` |
| Update comment | PUT | `/comment/{comment_id}` |
| Delete comment | DELETE | `/comment/{comment_id}` |
| Create list comment | POST | `/list/{list_id}/comment` |
| Create chat comment | POST | `/view/{view_id}/comment` |

**Comment pagination is cursor-based** (not page number):
```python
# First call: no params
resp = client.get(f"/task/{task_id}/comment")
# Next call: use last item's id + date
params = {"start_id": last["id"], "start": last["date"]}
```
25 comments per page. Stop when response is empty.

## Sources

- https://developer.clickup.com/docs/webhooksignature
- https://developer.clickup.com/docs/webhookhealth
- https://developer.clickup.com/reference/createwebhook
- https://developer.clickup.com/reference/createtaskcomment
