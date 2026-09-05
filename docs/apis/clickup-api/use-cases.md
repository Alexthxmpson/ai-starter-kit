# ClickUp API v2/v3 -- Use Cases & Practical Guide

**Date:** 2026-03-18 | **Last Updated:** 2026-03-29

---

## Raw Growth AI -- ClickUp Setup

### Workspace Details
- **Workspace:** Rawgrowth (team_id / workspace_id: `90131458500`)
- **Space:** Rawgrowth Team (ID: `901313716577`)
- **Lists:** "List" (`901326628062`), "Founders Kanban" (`901326628160`)
- **Views:** Overview + Conversation
- **Team:** Chris West (owner), Alexander Alberts (admin), Dilan Patel (admin)
- **Plan:** Check via `GET /v2/team` -- rate limits depend on plan

### Raw Growth Use Cases (Priority Order)

| Use Case | How | Endpoint(s) | Complexity |
|----------|-----|-------------|-----------|
| **CRM pipeline tracking** | Use "Founders Kanban" list with status columns as pipeline stages. Update task status = move through pipeline | `PUT /v2/task/{id}` with `{"status": "Stage Name"}` | Easy |
| **Team task management** | Create tasks from Slack/Discord/AI. Assign to Chris/Alexander/Dilan | `POST /v2/list/{list_id}/task` | Easy |
| **Daily standup digest** | Fetch all tasks updated in last 24h, group by assignee, post to Slack | `GET /v2/list/{list_id}/task?date_updated_gt={ts}` | Easy |
| **Webhook -> Slack/Discord** | Notify team on task status change, new comments, overdue tasks | `POST /v2/team/{id}/webhook` + your handler | Easy |
| **Chat/comments as CRM notes** | Post comments on lead tasks with call notes, meeting outcomes | `POST /v2/task/{id}/comment` | Easy |
| **Time tracking for billing** | Track billable hours per client/project, export for invoicing | `POST /v2/team/{id}/time_entries` | Medium |
| **Lead intake automation** | Webhook from website/form -> create task in Founders Kanban with custom fields | `POST /v2/list/901326628160/task` | Medium |
| **Pipeline analytics** | Count tasks per status, calculate conversion rates, avg time per stage | `GET /v2/list/{id}/task` + aggregate | Medium |
| **AI task triage** | Read new tasks -> AI classifies priority/assignee -> auto-update | `GET` + `PUT /v2/task/{id}` | Medium |
| **Custom Task Types** | Use Milestones for key deal stages, custom types for different lead categories | `POST` with `custom_item_id` | Easy |

### Quick Start for Raw Growth

```python
import requests

CLICKUP_TOKEN = "pk_YOUR_TOKEN"
TEAM_ID = "90131458500"
SPACE_ID = "901313716577"
LIST_ID = "901326628062"  # Main list
KANBAN_LIST_ID = "901326628160"  # Founders Kanban

headers = {
    "Authorization": CLICKUP_TOKEN,
    "Content-Type": "application/json"
}

# Create a CRM lead task
lead = requests.post(
    f"https://api.clickup.com/api/v2/list/{KANBAN_LIST_ID}/task",
    headers=headers,
    json={
        "name": "Acme Corp - $15K Setup",
        "description": "Hot lead from Instagram DMs. CEO interested in AI automation.",
        "status": "New Lead",
        "priority": 2,  # High
        "assignees": [CHRIS_USER_ID],
        "tags": ["hot-lead", "instagram"],
        "custom_fields": [
            {"id": "DEAL_VALUE_FIELD_UUID", "value": 15000}
        ]
    }
).json()

# Add a note after a sales call
requests.post(
    f"https://api.clickup.com/api/v2/task/{lead['id']}/comment",
    headers=headers,
    json={
        "comment_text": "Discovery call completed. Pain points: manual data entry, no CRM. Next: send proposal by Friday."
    }
)

# Move lead through pipeline
requests.put(
    f"https://api.clickup.com/api/v2/task/{lead['id']}",
    headers=headers,
    json={"status": "Proposal Sent"}
)

# Set up webhook for team notifications
webhook = requests.post(
    f"https://api.clickup.com/api/v2/team/{TEAM_ID}/webhook",
    headers=headers,
    json={
        "endpoint": "https://your-server.com/clickup-webhook",
        "events": [
            "taskCreated",
            "taskStatusUpdated",
            "taskCommentPosted",
            "taskAssigneeUpdated"
        ],
        "list_id": int(KANBAN_LIST_ID)
    }
).json()
print(f"Webhook secret (SAVE THIS): {webhook['webhook']['secret']}")
```

---

## What You Can Do

### Free (Personal Token, No Billing Required)
- Read all workspace data (tasks, spaces, lists, members, time entries)
- Create and update tasks programmatically
- Post comments on tasks
- Set up webhooks for real-time event monitoring
- Create subtasks, checklists, dependencies
- Filter and search tasks across the workspace
- Paginate through full task lists
- Use Custom Task Types (Milestones, custom types)
- Search Docs (v3)

### Paid Features (Business+ Required for Scale)
- **Custom field writes at scale**: Free plan = 60 lifetime writes. Business+ = unlimited
- **Rate limit headroom**: 1,000 req/min on Business Plus vs 100 on lower plans
- **Sprints**: Sprint features require ClickUp's Agile add-on
- **Guests API**: Adding guests via API (Enterprise only)
- **Time Tracking 2.0**: Available on paid plans
- **Audit Logs**: Enterprise only (v3 API)
- **Custom Roles**: Enterprise only

---

## Automation Ideas Table

| Use Case | Complexity | Rate Limit Impact | Plan Required |
|----------|-----------|------------------|---------------|
| Create tasks from Slack/Discord/email | Easy | Low | Any |
| Webhook -> Notify on status change | Easy | None (webhooks free) | Any |
| CRM pipeline with Kanban statuses | Easy | Low | Any |
| Chat view as team messaging | Easy | Low | Any |
| Daily task digest / standup bot | Easy | Low | Any |
| Natural language task creation (AI) | Medium | Low | Any |
| Auto-assign tasks based on content | Medium | Medium | Any |
| Webhook -> trigger n8n/Make/Zapier workflow | Easy | None | Any |
| AI triage: read task -> classify -> update | Medium | Medium | Business+ |
| Sync tasks to/from external system (CRM) | Medium | High | Business+ |
| AI reads new task -> writes summary to field | Medium | Medium | Business+ |
| Bulk update 500+ tasks | Complex | Very High | Business Plus |
| Time tracking automation | Medium | Low | Business |
| Sprint analytics -> AI report | Medium | Medium | Business |
| Custom field as AI memory store | Medium | High (if many tasks) | Business+ |
| Hierarchical project creation | Easy | Low | Any |
| Goal progress tracking automation | Medium | Low | Business |
| Move tasks between lists with field mapping | Medium | Low | Any (v3) |
| Audit log monitoring (security) | Medium | Low | Enterprise |

---

## Key Limits & Gotchas

| Limit | Detail |
|-------|--------|
| Rate limit Free/Business | 100 req/min per token |
| Rate limit Business Plus | 1,000 req/min per token |
| No bulk endpoint | Each task/field = 1 API call |
| Custom field writes (Free) | 60 lifetime per workspace |
| Webhook response window | 7 seconds (process async!) |
| Webhook retry | 5 attempts, then dropped |
| Webhook fail_count >= 100 | Webhook suspended |
| Custom field creation | Must be done in UI (not API) |
| Dates | Always Unix milliseconds (not seconds!) |
| Assignees | Create: array. Update: {add, rem} object |
| Status names | Case-sensitive |
| Task IDs | Short alphanumeric strings (e.g., "9hz") |
| OAuth scopes | None -- full workspace access or nothing |
| Webhook IPs | No dedicated IP -- use HMAC verification |
| v3 availability | Only select endpoints (Docs, Audit Logs, Move Task) |
| Time entries default | Last 30 days, auth user only |
| Tasks in Multiple Lists | Excluded by default -- use `include_timl=true` |

---

## Available Scripts / Tools

### Round 1 Research Documents (in `round-1/`)
- `auth-and-data-model.md` -- Authentication, OAuth flow, hierarchy walker
- `tasks-and-custom-fields.md` -- Full task CRUD + custom field client class
- `lists-spaces-advanced.md` -- Complete Python client for all resources
- `comments-and-webhooks.md` -- Webhook handler + HMAC verification
- `rate-limits-and-integration-patterns.md` -- ClickUpClient with backoff + AI patterns

### Reusable Python Patterns (in research docs)
- `ClickUpClient` -- rate-limiting + exponential backoff client class
- `get_all_tasks()` -- pagination loop for any list
- `get_tasks_updated_since()` -- incremental sync
- `get_all_comments()` -- cursor-based comment pagination
- `verify_clickup_webhook()` -- HMAC signature verification
- `batch_update_tasks_async()` -- async bulk update with aiohttp
- OAuth 2.0 Flask example
- Full hierarchy walker (workspace -> space -> folder -> list)

### ClickUp MCP Server
ClickUp provides an official MCP Server for AI integration. Community MCP server also available: https://github.com/TaazKareem/clickup-mcp-server

### Claude Code Skill
`/clickup` skill available for Rawgrowth ClickUp operations.

---

## Recommended Architecture for Raw Growth AI

```
ClickUp Workspace (Rawgrowth)
      |
      +-- Founders Kanban (CRM Pipeline)
      |     Statuses: New Lead -> Qualified -> Demo Scheduled -> Proposal Sent -> Negotiation -> Won/Lost
      |
      +-- Team List (Task Management)
            Statuses: Open -> In Progress -> Review -> Done

Webhook Events -> Your Server (FastAPI)
      |
      +-- Verify HMAC + respond 200 immediately
      +-- Background Queue
            |
            +-- taskStatusUpdated -> Slack #deals notification
            +-- taskCommentPosted -> Slack thread update
            +-- taskCreated -> AI triage + auto-assign
            |
            +-- ClickUp API (write results back, rate limited)
```

**Key principle:** Webhooks for triggers (free, real-time). API writes for updates (rate-limited). Never block webhook response on API calls.

---

## Integration with n8n / Make / Zapier

ClickUp has official integrations with all major automation platforms:
- **n8n:** Native ClickUp node -- create/update/delete tasks, search, comments
- **Make (Integromat):** Full ClickUp module suite
- **Zapier:** ClickUp Zapier app -- triggers on new/changed tasks

For custom AI workflows, **webhooks + your own endpoint** are more powerful than these platforms.
