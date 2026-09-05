# Rate Limits & AI Integration Patterns — Briefing

**Coverage: 96% | Status: COMPLETE**

## Rate Limits by Plan

| Plan | Req/Min Per Token |
|------|-----------------|
| Free Forever | 100 |
| Unlimited | 100 |
| Business | 100 |
| Business Plus | 1,000 |
| Enterprise | 10,000 |

**Per token, not per IP.** Multiple tokens from same workspace each get their own limit.

**Recommended minimum for AI automation: Business Plus (1,000 req/min)**

## Rate Limit Headers (on every response)

| Header | Description |
|--------|-------------|
| `X-RateLimit-Limit` | Total limit |
| `X-RateLimit-Remaining` | Remaining in window |
| `X-RateLimit-Reset` | Unix timestamp (seconds) when window resets |

**No `Retry-After` header.** Compute wait time: `reset_timestamp - time.time() + 2`

## 429 Handling

```python
if response.status_code == 429:
    reset_at = response.headers.get("X-RateLimit-Reset")
    wait = max(1, int(reset_at) - int(time.time())) + 2 if reset_at else 60
    time.sleep(wait)
```

## No Bulk Endpoints

ClickUp v2 has **NO bulk task update endpoint** (confirmed "not on roadmap"). Each task + each custom field = separate API call. Design accordingly.

- At 100 req/min: can update ~50 tasks/min (1 read + 1 write per task)
- At 1,000 req/min: ~400 tasks/min sustained with headroom

## Pagination Summary

**Tasks:** Page-based (0-indexed), 100/page, `last_page: boolean` signal
**Comments:** Cursor-based, 25/page, `start_id` + `start` params

## AI Integration Patterns

### 1. ClickUp as Task Queue
```python
# Poll tasks in "AI Review" status → process → update to "Reviewed"
tasks = client.get("/list/{id}/task", params={"statuses[]": ["AI Review"]})
for task in tasks["tasks"]:
    result = ai.analyze(task["description"])
    client.post(f"/task/{task['id']}/comment", data={"comment_text": result})
    client.put(f"/task/{task['id']}", data={"status": "Reviewed"})
```

### 2. Natural Language → Structured Task
```python
extracted = claude.extract_fields(user_input)  # {name, priority, due_date}
client.post(f"/list/{list_id}/task", data=extracted)
```

### 3. Webhook → AI Trigger (real-time, no rate limit cost)
```python
if "@ai" in comment_text.lower():
    await ai_respond(task_id, comment_text)
```

### 4. Incremental Sync (efficient polling)
```python
# Only get tasks updated since last run
tasks = client.get("/list/{id}/task", params={
    "date_updated_gt": last_run_timestamp_ms,
    "order_by": "updated"
})
```

### 5. Store AI Outputs in Custom Fields
```python
field_ids = get_custom_field_ids(list_id)  # fetch + cache
client.post(f"/task/{id}/field/{field_ids['AI Score']}", data={"value": 8.5})
client.post(f"/task/{id}/field/{field_ids['AI Category']}", data={"value": option_uuid})
```

## Python SDK Recommendation

Build a custom `ClickUpClient` class (see MASTER-SYNTHESIS.md Section 8.3). Community SDKs may lag behind API changes. The custom class gives you:
- Rate limit header tracking on every response
- Proactive throttle before hitting limit
- Exponential backoff with jitter
- Proper 429 handling using X-RateLimit-Reset

## Common Gotchas

| Gotcha | Fix |
|--------|-----|
| Rate window uses X-RateLimit-Reset, not Retry-After | Compute wait manually |
| status names are case-sensitive | Fetch from `GET /list/{id}`, use exact string |
| Free plan: 60 custom field writes lifetime | Upgrade to Business+ |
| Webhook duplicates: OAUTH_171 | Check existing before creating |
| CORS blocks browser-side calls | Always proxy through backend |

## Sources

- https://developer.clickup.com/docs/rate-limits
- https://developer.clickup.com/docs/faq
- https://consultevo.com/clickup-ai-agents-workflow-integration/
- https://feedback.clickup.com/public-api/p/update-multiple-task-fields-in-a-single-api-call
