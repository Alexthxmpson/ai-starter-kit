# Trigger.dev API — Use Cases & Practical Guide

**Date:** 2026-02-28

---

## What You Can Do

### Free Tier (10 concurrent runs, 10 scheduled tasks)

- Define background tasks as plain TypeScript/JavaScript code
- Trigger tasks from your backend via SDK or REST API
- Run scheduled (cron) tasks on any frequency
- Retry failed tasks automatically with configurable backoff
- Monitor all runs in real-time via the dashboard
- Delay execution (seconds, hours, or days into the future)
- Debounce triggers — consolidate repeated calls into one run
- Batch trigger up to 500 tasks in a single SDK call
- Use idempotency keys to prevent duplicate executions
- Stream real-time run status to your frontend via React hooks
- Human-in-the-loop flows: pause a run and wait for a token
- Chain tasks: trigger subtasks and wait for their results
- Run Python scripts inside tasks via the Python extension
- Deploy to Trigger.dev Cloud with zero infrastructure management

### Paid (Hobby/Pro — higher concurrency, longer log retention, preview branches)

- Up to 100+ concurrent runs (Pro)
- Up to 1,000 scheduled tasks per project (Pro)
- 30-day log retention (Pro, vs 1 day free)
- Preview branches for staging environments (Hobby: 5, Pro: 20+)
- 500+ concurrent realtime connections (Pro)
- Higher API rate limits on request
- Self-hosting on your own infrastructure (Docker or Kubernetes)

### What the API Cannot Do

- Run browser-native code (tasks run in Node.js/server environments only)
- Guarantee sub-second latency — tasks are background jobs, not real-time handlers
- Share state between runs without external storage (use your own DB)
- Trigger tasks from purely frontend code without a backend endpoint
- Exceed 10MB for task output payloads
- Exceed 3MB for individual trigger payloads (auto-uploaded to S3 above 512KB)
- Persist queue data beyond 14 days (Cloud TTL limit)

---

## Automation Ideas

| Use Case | Complexity | What You Do | Key SDK / Endpoint |
|---|---|---|---|
| Send welcome email sequence (Day 0, 3, 7) | Easy | Trigger email task with delay options for each step | `tasks.trigger()` + `delay` option |
| Daily report generation | Easy | Cron task queries your DB, builds report, emails it | `schedules.create()` + `tasks.trigger()` |
| Process uploaded file in background | Easy | Webhook triggers a task with file URL in payload | `tasks.trigger()` from webhook handler |
| Sync data between two APIs hourly | Easy | Scheduled task calls both APIs and writes results | `schedules.create()` |
| Notify Slack on new user signup | Easy | Task triggered on signup event, calls Slack API | `tasks.trigger()` |
| Monitor endpoint and alert on failure | Easy | Cron task pings URL, triggers Slack/email if down | `schedules.create()` |
| Retry failed Stripe payments | Medium | Event trigger on payment failure, retry with backoff | `tasks.trigger()` + `retry` config |
| Batch AI processing (100+ items) | Medium | `batchTrigger()` spawns one task per item in parallel | `tasks.batchTrigger()` |
| Long-running web scraping job | Medium | Task loops pages with waits to avoid bans | `wait.for()` inside task loop |
| AI content generation pipeline | Medium | Sequential tasks: research → draft → review → publish | `triggerAndWait()` chaining |
| Human-in-the-loop approval workflow | Medium | Task pauses, sends approval link, resumes on token | `wait.forToken()` + `waitpoints.complete` |
| Real-time CSV import with progress | Medium | Task streams progress back to frontend during import | Realtime API + `runs.subscribe()` |
| Bulk data migration | Medium | Background task paginates source, writes to target | `tasks.trigger()` + checkpoint state |
| Run AI analysis on new Notion pages | Medium | Webhook → task fetches page, calls Claude API, writes result | `tasks.trigger()` from Notion webhook |
| Cancel and replay stale runs | Medium | Management API lists old runs, cancels, replays with new payload | `runs.list()` + `runs.cancel()` + `runs.replay()` |
| Dynamic per-user concurrency queues | Hard | Use `concurrencyKey` per user to isolate their job queue | `trigger()` with `queue.concurrencyKey` |
| Multi-step AI agent with tool calls | Hard | Task loop calls LLM, executes tool, loops until done | `triggerAndWait()` with subtask tools |
| Scheduled DB cleanup with audit log | Hard | Cron task deletes rows, writes structured metadata per run | `schedules.create()` + `runs.update-metadata` |
| Preview branch CI pipeline | Hard | Deploy to preview env, run integration tasks, promote on pass | Deployment API + `deployments.promote` |

---

## Key Limits and Gotchas

### Concurrency

- Free: **10 concurrent runs** across all tasks
- If your task bursts above the limit, excess runs are queued — not dropped
- Use `queue.concurrencyLimit` to cap per-task concurrency
- Use `concurrencyKey` to create per-entity queues (e.g. per user, per tenant)

### Rate Limits

- **1,500 API requests per minute** across all tiers
- Paid users can request increases
- Use `batchTrigger()` instead of looping `trigger()` to stay within limits
- Batch size: up to **1,000 items per call** (SDK 4.3.1+), 500 in older versions

### Payload Limits

- Single trigger payload: **max 3MB** (auto-uploaded to S3 above 512KB)
- Batch item payload: **max 3MB per item**
- Task output: **max 10MB**
- For larger data: upload to your own storage and pass a presigned URL in payload

### Retries

- Default retry config: up to 3 attempts with exponential backoff
- Set `retry: { maxAttempts: 10, factor: 2, minTimeoutInMs: 1000 }` per task
- Each attempt is billed as a separate run unit
- `wait.for()` and `triggerAndWait()` do not count retries for inner tasks

### Authentication

- `tr_dev_*` keys are scoped to the **dev environment** only
- `tr_prod_*` keys are scoped to **production**
- Personal access tokens (`tr_pat_*`) work cross-environment but require `projectRef`
- Never use secret keys in frontend code — always call from a backend

### Scheduling

- Cron tasks use standard cron syntax; timezone-aware via IANA timezone strings
- Free tier: **10 scheduled tasks** max per project
- Deactivating a schedule does not delete it — it stays in the registry
- Use `schedules.timezones` endpoint to get the full list of valid timezone strings

### Waits and Long-Running Tasks

- `wait.for()` pauses a run without consuming compute — safe for multi-hour delays
- `wait.forToken()` pauses until you call the callback URL or `waitpoints.complete` API — use for human approval flows
- Tasks with no `maxDuration` set can run indefinitely (Cloud) — set it explicitly for safety
- If a run is waiting and the worker crashes, it resumes automatically on the next worker

### Queues

- Default queue name is the task's export name
- Runs enqueued beyond the queue limit (`10,000` on Free prod, `1,000,000` on Pro) are rejected — not queued further
- Pausing a queue holds all runs in it; unpausing resumes from where they left off

### Logging

- Free tier: **1 day** log retention
- Logs are structured and searchable in the dashboard
- Use `logger.info()` / `logger.error()` inside tasks — plain `console.log` also works but has less structure

### Deployments

- `trigger deploy` packages and deploys your tasks as a versioned deployment
- Promote a deployment to production via dashboard or `deployments.promote` API
- Preview branches let you test task changes before merging (Hobby/Pro)
- Atomic deployments: new runs use the new version; in-flight runs complete on the old version
