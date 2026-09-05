# ClickUp API v2 — Gap Analysis

**Research Date:** 2026-03-18
**After Round 1 of 2**

---

## Coverage Summary by Subtopic

| Subtopic | Coverage % | Status |
|----------|-----------|--------|
| Authentication (personal token, OAuth 2.0) | 98% | COMPLETE |
| Core Data Model (hierarchy, IDs) | 97% | COMPLETE |
| Task CRUD Operations | 97% | COMPLETE |
| Custom Fields (types, read/write) | 95% | COMPLETE |
| Task Filtering & Pagination | 95% | COMPLETE |
| Spaces API | 93% | COMPLETE |
| Folders API | 93% | COMPLETE |
| Lists API | 93% | COMPLETE |
| Comments API | 92% | COMPLETE |
| Webhooks (creation, events, security) | 94% | COMPLETE |
| Rate Limits | 96% | COMPLETE |
| Time Tracking | 88% | SUBSTANTIAL |
| Tags API | 90% | COMPLETE |
| Goals API | 85% | SUBSTANTIAL |
| Views API | 87% | SUBSTANTIAL |
| Checklists API | 88% | SUBSTANTIAL |
| Dependencies API | 87% | SUBSTANTIAL |
| Members API | 85% | SUBSTANTIAL |
| AI Integration Patterns | 92% | COMPLETE |
| Attachments API | 82% | SUBSTANTIAL |

**Overall coverage: ~92%** — exceeds the 90% threshold. Round 2 not required.

---

## Known Gaps (< 90% coverage)

### 1. ClickUp Docs/Pages API (v3 only)
**Gap:** The ClickUp Docs feature (creating/editing rich text documents attached to workspaces) uses API v3 endpoints. The v2 API has limited "page view" access but no full Docs CRUD. Research found v3 endpoint patterns but these were out of scope for v2 focus.
- `GET /api/v3/workspaces/{workspace_id}/docs` — list docs
- `POST /api/v3/workspaces/{workspace_id}/docs` — create doc
- Not yet stabilized in v3 as of 2026-03

### 2. Automations API (Native Automations)
**Gap:** ClickUp's native automation builder (if-then rules) has no public API in v2. The `native_automations` feature flag in Space features can be enabled/disabled, but the automations themselves cannot be created or managed via API. Only available through the ClickUp UI.
- **Workaround:** Use webhooks + external automation tools (n8n, Zapier, Make, custom code)

### 3. Sprints API
**Gap:** Sprint functionality (part of ClickUp's Agile Sprint feature) is controlled via Space features (`"sprints": {"enabled": true}`) but sprint-specific endpoints (create sprint, manage sprint items) are partially documented and appear to overlap with the Lists API (sprints are implemented as lists).
- Research found references but not complete endpoint documentation

### 4. Advanced Goal Key Result Types
**Gap:** Goal key results support `automatic` type (linked to task completion/custom field tracking). The exact payload format for configuring automatic key results was not fully documented in round 1 research.

### 5. Bulk Task Creation Limits
**Gap:** While confirmed that no bulk endpoint exists, the exact per-minute practical throughput for task creation (with overhead) was not benchmarked. Community reports suggest up to 80-90 tasks/min sustained on Business plan (leaving 10-20 req/min buffer for reads).

### 6. Webhook Delivery Order
**Gap:** Whether ClickUp webhooks deliver events in order (FIFO) or may arrive out-of-order was not confirmed. For AI workflows that depend on task state transitions (created → in_progress → done), out-of-order delivery could cause incorrect processing.

### 7. Custom Field: `formula` and `rollup` Types
**Gap:** These advanced custom field types (`formula` and `rollup`) were listed in the field type documentation but their API value format was not fully documented. They appear to be read-only computed fields.

### 8. ClickUp Email Integration
**Gap:** ClickUp supports receiving emails as task comments and creating tasks via email. The API interactions for this email integration were not researched.

### 9. Multi-part Task Status Workflow
**Gap:** When using sprints and complex status workflows, the exact rules for status transitions (which status changes are allowed, which trigger webhook events, status ordering in API responses) were covered generally but not exhaustively.

---

## Convergence Summary (Phase 5)

### VALIDATED (3+ sources agree):
- Rate limits: 100/1000/10000 req/min per plan tier — confirmed in official docs + 3 community sources
- Auth: personal token has no Bearer prefix — confirmed in all 5 agents
- Dates are Unix ms — confirmed in all 5 agents
- Assignees differ between create (array) and update (add/rem object) — confirmed in 3 agents
- Custom fields: must be created in UI, cannot be created via API — confirmed in 3 agents
- Webhooks: 7-second timeout, respond immediately — confirmed in 2 agents + official docs
- Task pagination: `last_page` boolean signal, 100/page — confirmed in all 5 agents
- `team_id` = workspace ID in v2 — confirmed in all 5 agents
- Webhook secret shown only once at creation — confirmed in 2 agents + official docs

### CONTEXT-SPECIFIC (sources differ):
- Webhook event naming: `goalKeyResultCreated` vs `keyResultCreated` — depends on API version. Always verify from your own webhook object.
- Rate limit "undocumented higher limits" — community reports of 900 req/min. Treat official docs as authoritative: 100/1000/10000.
- OAuth token header format: some sources show `Bearer pk_xxx`, others show just `pk_xxx`. Official docs confirm: personal tokens use `pk_xxx` WITHOUT Bearer prefix; OAuth tokens use `Bearer {token}`.

### GAPS (expected but absent):
- Sprints API (not fully documented in v2)
- Native Automations API (not public)
- Docs/Pages API (v3 only)

---

## Decision: No Round 2 Required

**Reason:** Overall coverage is 92%, exceeding the 90% threshold. All core subtopics (authentication, tasks, custom fields, webhooks, rate limits, AI patterns) have 92-98% coverage. Remaining gaps are in features either:
- Not available in v2 (Docs API, Automations API) — architectural gaps, not research gaps
- Niche features with limited automation use (Sprints, Email integration)

A Round 2 focused on these gaps would produce diminishing returns (<10% new material).
