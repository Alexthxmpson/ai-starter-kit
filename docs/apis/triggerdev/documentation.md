# Trigger.dev — Technical Reference

**Sources:**
- https://trigger.dev/docs
- https://trigger.dev/docs/management/overview
- https://trigger.dev/docs/management/runs/list
- https://trigger.dev/docs/management/runs/retrieve
- https://trigger.dev/docs/management/runs/cancel
- https://trigger.dev/docs/management/tasks/trigger
- https://trigger.dev/docs/management/schedules/list
- https://trigger.dev/docs/management/authentication

**Date documented:** 2026-02-27

---

## Overview

Trigger.dev (v3) is a **code-first background jobs and workflow automation platform** for developers. It lets you write long-running async tasks in TypeScript that live inside your codebase, run without timeout limits, retry on failure, schedule on cron expressions, and coordinate with each other using parent/child patterns. It is designed as an alternative to bolt-on solutions like Vercel Cron or AWS Lambda for tasks that require durability, observability, and long execution windows.

**Key characteristics:**
- Tasks defined entirely in TypeScript — no separate dashboard-only configuration
- No timeout limits (uses checkpoint/restore via CRIU to pause and resume tasks)
- Full OpenTelemetry tracing and observability built in
- Cloud-hosted or self-hosted
- SDK + REST Management API for triggering and managing runs programmatically

---

## Core Concepts

### Tasks

A **task** is the fundamental unit of work. You define it in TypeScript using the `task()` function from `@trigger.dev/sdk`, export it from a file in your project, and deploy it using the Trigger.dev CLI. Each task has:

- A unique **id** string
- A **run** function that receives a typed payload
- Optional **retry**, **queue**, **machine**, and **schedule** configuration
- Optional lifecycle hooks (`onStart`, `onSuccess`, `onFailure`, `onComplete`)

### Runs

A **run** is a single execution of a task. When you trigger a task, Trigger.dev creates a run with a unique `run_` prefixed ID. Runs have statuses:

| Status | Meaning |
|---|---|
| `PENDING_VERSION` | Waiting for a matching deployed version |
| `DELAYED` | Execution intentionally deferred |
| `QUEUED` | Waiting in queue for a worker |
| `EXECUTING` | Currently running |
| `REATTEMPTING` | Retrying after failure |
| `FROZEN` | Checkpointed and paused (waiting for subtask, delay, or token) |
| `COMPLETED` | Finished successfully |
| `CANCELED` | Manually canceled |
| `FAILED` | Exhausted all retry attempts |
| `CRASHED` | Unrecoverable infrastructure error |
| `INTERRUPTED` | Interrupted mid-execution |
| `SYSTEM_FAILURE` | Platform-side failure |

### Schedules

A schedule attaches a cron expression to a task so it runs automatically on a time-based cadence. Schedules can be **declarative** (defined in code) or **imperative** (created via the SDK/REST API at runtime, e.g., per-user schedules).

### Queues

Queues control concurrency — how many instances of a task (or group of tasks) can execute simultaneously. You can set a `concurrencyLimit` on a queue to prevent overloading downstream services.

---

## Installation and Setup

```bash
npm install @trigger.dev/sdk@latest
```

Initialize a project (interactive CLI):

```bash
npx trigger.dev@latest init
```

This creates a `trigger.config.ts` file and a `src/trigger/` directory for your task definitions.

**Environment variables required:**

```bash
TRIGGER_SECRET_KEY=tr_dev_xxxxxxxxxxxx   # From your project dashboard
```

---

## Defining Tasks (SDK)

### Basic Task

```typescript
import { task } from "@trigger.dev/sdk";

export const helloWorld = task({
  id: "hello-world",
  run: async (payload: { message: string }) => {
    console.log(payload.message);
    return { success: true };
  },
});
```

### Task with Retry Configuration

```typescript
export const resilientTask = task({
  id: "resilient-task",
  retry: {
    maxAttempts: 10,
    factor: 1.8,
    minTimeoutInMs: 500,
    maxTimeoutInMs: 30_000,
    randomize: true,
  },
  run: async (payload: { userId: string }) => {
    // If this throws, it retries with exponential backoff
    const result = await fetchUserData(payload.userId);
    return result;
  },
});
```

**Retry options:**

| Option | Type | Default | Description |
|---|---|---|---|
| `maxAttempts` | number | 3 | Total number of attempts before failing |
| `factor` | number | 2 | Exponential backoff multiplier |
| `minTimeoutInMs` | number | 1000 | Minimum wait between retries |
| `maxTimeoutInMs` | number | 60000 | Maximum wait between retries |
| `randomize` | boolean | false | Add jitter to backoff timing |

### Task with Queue and Concurrency

```typescript
import { task, queue } from "@trigger.dev/sdk";

export const emailSender = task({
  id: "email-sender",
  queue: {
    name: "email-queue",
    concurrencyLimit: 5,   // Max 5 emails sending simultaneously
  },
  run: async (payload: { to: string; subject: string; body: string }) => {
    await sendEmail(payload);
  },
});
```

### Task with Machine Spec

```typescript
export const heavyComputeTask = task({
  id: "heavy-compute",
  machine: {
    preset: "large-2x",   // More CPU and RAM
  },
  maxDuration: 3600,      // 1 hour max execution time in seconds
  run: async (payload: { datasetUrl: string }) => {
    // Long-running ML inference or data processing
  },
});
```

**Available machine presets:**

| Preset | CPU | RAM |
|---|---|---|
| `micro` | 0.25 vCPU | 0.25 GB |
| `small-1x` | 0.5 vCPU | 0.5 GB |
| `small-2x` | 1 vCPU | 1 GB |
| `medium-1x` | 1 vCPU | 2 GB |
| `medium-2x` | 2 vCPU | 4 GB |
| `large-1x` | 4 vCPU | 8 GB |
| `large-2x` | 8 vCPU | 16 GB |

### Lifecycle Hooks

```typescript
export const trackedTask = task({
  id: "tracked-task",
  onStart: async (payload, { ctx }) => {
    console.log(`Starting run ${ctx.run.id}`);
  },
  onSuccess: async (payload, output, { ctx }) => {
    await notifySlack(`Task ${ctx.task.id} completed successfully`);
  },
  onFailure: async (payload, error, { ctx }) => {
    await alertPagerDuty(error);
  },
  run: async (payload) => {
    return { processed: true };
  },
});
```

---

## Triggering Tasks (SDK)

### trigger() — Fire and Forget

```typescript
import { tasks } from "@trigger.dev/sdk";

// Trigger from your Next.js API route, Express handler, etc.
const handle = await tasks.trigger("hello-world", {
  message: "Hello from my app!",
});

console.log(`Run started: ${handle.id}`);
```

**With options:**

```typescript
const handle = await tasks.trigger("hello-world", { message: "test" }, {
  delay: "5m",             // Execute after 5 minutes
  idempotencyKey: "unique-key-123",  // Prevent duplicate runs
  tags: ["user:123", "env:prod"],    // Filter runs in dashboard
  ttl: "24h",              // Expire the run if not started within 24 hours
  queue: {
    name: "my-queue",
    concurrencyLimit: 10
  }
});
```

**Delay formats:** `"30s"`, `"5m"`, `"2h"`, `"7d"` or seconds as integer

### triggerAndWait() — Await Result from Parent Task

Use this inside another task to spawn a child task and wait for its result before continuing:

```typescript
export const parentTask = task({
  id: "parent-task",
  run: async (payload: { userId: string }) => {
    // Spawn child task and wait for result
    const result = await childTask.triggerAndWait({ userId: payload.userId });

    if (result.ok) {
      return { processed: result.output };
    } else {
      throw new Error(`Child task failed: ${result.error}`);
    }
  },
});

export const childTask = task({
  id: "child-task",
  run: async (payload: { userId: string }) => {
    const data = await fetchUserProfile(payload.userId);
    return data;
  },
});
```

> When a parent task is waiting on a child via `triggerAndWait()`, it enters the `FROZEN` state and releases compute resources. The Checkpoint/Restore system resumes it automatically when the child finishes.

### batchTrigger() — Trigger Many Runs at Once

```typescript
const batchHandle = await tasks.batchTrigger("hello-world", [
  { payload: { message: "Hello user 1" } },
  { payload: { message: "Hello user 2" } },
  { payload: { message: "Hello user 3" } },
]);
```

### batchTriggerAndWait() — Trigger Many and Await All

```typescript
export const fanOutTask = task({
  id: "fan-out",
  run: async (payload: { userIds: string[] }) => {
    const results = await childTask.batchTriggerAndWait(
      payload.userIds.map(id => ({ payload: { userId: id } }))
    );

    const succeeded = results.filter(r => r.ok);
    return { processed: succeeded.length };
  },
});
```

---

## Scheduled Tasks

### Declarative Schedule (Defined in Code)

```typescript
import { schedules } from "@trigger.dev/sdk";

export const dailyReport = schedules.task({
  id: "daily-report",
  cron: "0 9 * * 1-5",   // 9 AM every weekday
  run: async (payload) => {
    // payload.timestamp = when this run was scheduled
    // payload.lastTimestamp = when the previous run fired
    await generateAndEmailReport(payload.timestamp);
  },
});
```

The `cron` property is synced automatically when you run `npx trigger.dev dev` or deploy.

### Imperative Schedules (Dynamic, Per-User)

```typescript
import { schedules } from "@trigger.dev/sdk";

// Create a schedule at runtime (e.g., when user signs up)
const schedule = await schedules.create({
  task: "send-reminder",
  cron: "0 10 * * MON",  // Every Monday at 10 AM
  timezone: "America/New_York",
  externalId: `user-${userId}`,   // Link to your user ID for management
});

// Deactivate a user's schedule
await schedules.deactivate(schedule.id);

// Reactivate
await schedules.activate(schedule.id);

// Delete permanently
await schedules.del(schedule.id);
```

**schedules.create() parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `task` | string | Yes | Task ID to run on schedule |
| `cron` | string | Yes | Cron expression |
| `timezone` | string | No | IANA timezone string (default UTC) |
| `externalId` | string | No | Your own identifier for this schedule |
| `deduplicationKey` | string | No | Prevent duplicate schedule creation |

---

## Delays and Waiting

### wait.for() — Pause Task Execution

```typescript
import { wait } from "@trigger.dev/sdk";

export const delayedTask = task({
  id: "delayed-task",
  run: async (payload) => {
    await doFirstStep(payload);

    // Pause for 2 hours — releases compute resources during wait
    await wait.for({ hours: 2 });

    await doSecondStep(payload);
  },
});
```

**wait.for() options:** `seconds`, `minutes`, `hours`, `days`, `weeks`

### wait.until() — Pause Until a Specific Time

```typescript
await wait.until({ date: new Date("2026-03-01T09:00:00Z") });
```

### Human-in-the-Loop: wait.forToken()

```typescript
import { wait, auth } from "@trigger.dev/sdk";

export const approvalWorkflow = task({
  id: "approval-workflow",
  run: async (payload: { documentId: string }) => {
    const token = await wait.createToken({ timeout: "24h" });

    await sendApprovalEmail({
      documentId: payload.documentId,
      approveUrl: `https://your-app.com/approve?token=${token.id}`,
    });

    // Task freezes here until someone hits the approve URL
    const result = await wait.forToken(token);

    if (result.ok) {
      await processApproval(payload.documentId);
    } else {
      await handleRejection(payload.documentId);
    }
  },
});
```

---

## Authentication

### Authentication Methods

Trigger.dev uses two types of credentials:

**1. Secret Key (Environment-scoped)**

- Format: `tr_dev_xxxx` (development), `tr_prod_xxxx` (production), `tr_stg_xxxx` (staging)
- Scoped to a specific project environment
- Used for: triggering tasks, managing runs, schedules, env vars in that environment
- Most common for backend server usage

**2. Personal Access Token (PAT)**

- Format: `tr_pat_xxxx`
- User-scoped — grants access across all organizations, projects, and environments the user can access
- Must provide `projectRef` since it is not environment-scoped
- Used for: CI/CD pipelines, multi-environment management scripts

### SDK Configuration

```typescript
import { configure } from "@trigger.dev/sdk";

// Using secret key (most common)
configure({
  secretKey: process.env.TRIGGER_SECRET_KEY,   // tr_dev_xxx or tr_prod_xxx
});

// Using PAT with project reference
configure({
  secretKey: process.env.TRIGGER_PAT,          // tr_pat_xxx
  projectRef: "proj_your_project_id",
});
```

If `TRIGGER_SECRET_KEY` is set as an environment variable, the SDK uses it automatically without needing an explicit `configure()` call.

### REST API Authentication

Pass the secret key as a Bearer token:

```bash
Authorization: Bearer tr_dev_xxxxxxxxxxxx
```

### Preview Branch Targeting

To target a preview environment branch:

```typescript
configure({
  secretKey: process.env.TRIGGER_SECRET_KEY,
  previewBranch: "feature/my-branch",
});
```

Or via HTTP header on direct REST calls:

```
x-trigger-branch: feature/my-branch
```

---

## Management API — Runs

All Management API endpoints are available through both the `@trigger.dev/sdk` package and direct REST calls.

**Base URL:** `https://api.trigger.dev`

---

### Trigger a Task Run

**REST:** `POST /api/v1/tasks/{taskIdentifier}/trigger`

**SDK:**
```typescript
import { tasks } from "@trigger.dev/sdk";
const handle = await tasks.trigger("my-task-id", { key: "value" });
```

**Request Body:**

| Field | Type | Required | Description |
|---|---|---|---|
| `payload` | any JSON | No | Input data passed to the task's run function |
| `context` | any JSON | No | Metadata about the run (accessible but not the task payload) |
| `options.queue.name` | string | No | Queue name |
| `options.queue.concurrencyLimit` | integer (0-1000) | No | Concurrency limit for this queue |
| `options.concurrencyKey` | string | No | Scope concurrency limit to a specific key |
| `options.idempotencyKey` | string | No | Prevent duplicate runs — returns existing run ID if key matches |
| `options.ttl` | string or integer | No | Expire run if not started in time (e.g., "1h42m" or seconds) |
| `options.delay` | string | No | Delay execution (e.g., "1h", "30d", "15m") |
| `options.tags` | string[] | No | Up to 10 tags (max 128 chars each) for filtering |
| `options.machine` | string | No | Machine preset override (micro, small-1x, ..., large-2x) |

**Response (200):**

```json
{
  "id": "run_abc123"
}
```

**cURL Example:**

```bash
curl -X POST https://api.trigger.dev/api/v1/tasks/my-task-id/trigger \
  -H "Authorization: Bearer tr_prod_xxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{
    "payload": { "userId": "user_456", "action": "send_welcome_email" },
    "options": {
      "idempotencyKey": "welcome-user_456",
      "tags": ["user:456", "type:welcome"],
      "delay": "5m"
    }
  }'
```

---

### List Runs

**REST:** `GET /api/v1/runs`

**SDK:**
```typescript
import { runs } from "@trigger.dev/sdk";

// Basic list
const page = await runs.list({ limit: 20 });

// With filters
const filteredPage = await runs.list({
  status: ["EXECUTING", "QUEUED"],
  taskIdentifier: ["my-task-id"],
  filter: {
    createdAt: { from: "2026-01-01", to: "2026-02-27" }
  }
});

// Auto-paginate through all results
for await (const run of runs.list({ limit: 50 })) {
  console.log(run.id, run.status);
}
```

**Query Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `page[size]` | integer (10-100, default 25) | Runs per page |
| `page[after]` | string | Run ID — start page after this ID (forward pagination) |
| `page[before]` | string | Run ID — start page before this ID (backward pagination) |
| `filter[status]` | string[] | Filter by status values |
| `filter[taskIdentifier]` | string[] | Filter by task ID(s) |
| `filter[version]` | string[] | Filter by worker version |
| `filter[tag]` | string[] | Filter by tags (up to 10) |
| `filter[isTest]` | boolean | Filter test runs only |
| `filter[schedule]` | string | Filter by schedule ID |
| `filter[bulkAction]` | string | Filter by bulk action ID |
| `filter[createdAt][from]` | string | Start date filter |
| `filter[createdAt][to]` | string | End date filter |
| `filter[createdAt][period]` | string | Relative period (e.g., "1d", "7d") |

**Run Object Fields in Response:**

| Field | Type | Description |
|---|---|---|
| `id` | string | Run identifier (run_xxx) |
| `status` | string | Current run status |
| `taskIdentifier` | string | Task ID |
| `env.id` | string | Environment identifier |
| `env.name` | string | Environment name |
| `createdAt` | datetime | When run was created |
| `updatedAt` | datetime | Last status update |
| `startedAt` | datetime | When execution began |
| `finishedAt` | datetime | When execution completed |
| `durationMs` | integer | Compute duration in milliseconds |
| `costInCents` | integer | Total compute cost |
| `baseCostInCents` | integer | Base cost before overages |
| `idempotencyKey` | string | Idempotency key if provided |
| `isTest` | boolean | Whether this is a test run |
| `version` | string | Worker version |
| `tags` | string[] | Applied tags |
| `delayedUntil` | datetime | When delayed run will execute |
| `ttl` | string | Time-to-live setting |
| `expiredAt` | datetime | When run expired |

---

### Retrieve a Run

**REST:** `GET /api/v3/runs/{runId}`

**SDK:**
```typescript
import { runs } from "@trigger.dev/sdk";

const run = await runs.retrieve("run_abc123");

console.log(run.status);       // COMPLETED
console.log(run.output);       // Task return value (secret key only)
console.log(run.payload);      // Input payload (secret key only)

for (const attempt of run.attempts) {
  if (attempt.status === "FAILED") {
    console.log("Error:", attempt.error);
  }
}
```

**Response fields (in addition to List fields):**

| Field | Type | Description |
|---|---|---|
| `payload` | any JSON | Task input (secret key only; omitted with PAT public key) |
| `output` | any JSON | Task return value (secret key only) |
| `payloadPresignedUrl` | string | 5-minute download URL for large payloads |
| `outputPresignedUrl` | string | 5-minute download URL for large outputs |
| `attempts` | array | Attempt history with id, status, error, timestamps |
| `relatedRuns` | object | Parent/child run references |
| `schedule` | object | Schedule details if run was schedule-triggered |

**cURL Example:**

```bash
curl https://api.trigger.dev/api/v3/runs/run_abc123 \
  -H "Authorization: Bearer tr_prod_xxxxxxxxxxxx"
```

---

### Cancel a Run

**REST:** `POST /api/v1/runs/{runId}/cancel`

**SDK:**
```typescript
await runs.cancel("run_abc123");
```

- Only affects in-progress runs (QUEUED, EXECUTING, FROZEN states)
- If the run is already COMPLETED or FAILED, this has no effect
- Returns immediately; the run may take a moment to fully cancel

**cURL Example:**

```bash
curl -X POST https://api.trigger.dev/api/v1/runs/run_abc123/cancel \
  -H "Authorization: Bearer tr_prod_xxxxxxxxxxxx"
```

---

### Replay a Run

Creates a new run with the identical payload and options as an existing run.

**SDK:**
```typescript
const newHandle = await runs.replay("run_abc123");
console.log(`Replayed as: ${newHandle.id}`);
```

---

## Management API — Schedules

### List Schedules

**REST:** `GET /api/v1/schedules`

**SDK:**
```typescript
import { schedules } from "@trigger.dev/sdk";

const allSchedules = await schedules.list();

// With pagination
const page = await schedules.list({ page: 1, perPage: 20 });
```

**Response includes per schedule:**
- `id` — schedule identifier
- `task` — associated task ID
- `type` — `DECLARATIVE` or `IMPERATIVE`
- `active` — whether schedule is enabled
- `cron` — cron expression
- `timezone` — IANA timezone
- `nextRun` — next scheduled execution time
- `externalId` — your custom identifier if set

### Create Schedule

```typescript
const schedule = await schedules.create({
  task: "send-weekly-report",
  cron: "0 8 * * MON",
  timezone: "Europe/Amsterdam",
  externalId: "user-123-weekly-report",
});
```

### Retrieve, Activate, Deactivate, Delete

```typescript
const schedule = await schedules.retrieve("sched_abc123");

await schedules.deactivate("sched_abc123");
await schedules.activate("sched_abc123");
await schedules.del("sched_abc123");
```

---

## Development and Deployment

### Local Development

```bash
npx trigger.dev@latest dev
```

Starts a local dev server that connects to Trigger.dev Cloud, runs your tasks locally, and provides real-time logs. Supports hot reload.

### Deployment

```bash
npx trigger.dev@latest deploy
```

Bundles tasks with esbuild (ESM output, tree-shaken), deploys to Trigger.dev Cloud infrastructure.

### CLI Commands

| Command | Description |
|---|---|
| `trigger.dev login` | Authenticate CLI with your Trigger.dev account |
| `trigger.dev init` | Initialize Trigger.dev in a project |
| `trigger.dev dev` | Run dev mode with local execution |
| `trigger.dev deploy` | Deploy tasks to production |
| `trigger.dev whoami` | Show current authenticated user |

---

## Observability

- Full **OpenTelemetry** tracing — every run generates spans
- Auto-instrumentation for Prisma, AWS SDK, and other popular libraries
- Real-time logs in the Trigger.dev dashboard
- **Realtime API** for streaming run status to frontends using React hooks

---

## Environments

| Environment | Key Prefix | Purpose |
|---|---|---|
| Development | `tr_dev_` | Local development and testing |
| Staging | `tr_stg_` | Pre-production validation |
| Production | `tr_prod_` | Live traffic |
| Preview | (branch-based) | Branch-specific preview deployments |

---

## Pricing Tiers

| Plan | Price | Included Usage | Concurrency | Schedules | Log Retention | Team Members |
|---|---|---|---|---|---|---|
| Free | $0/month | $5/month compute | 10 concurrent runs | Limited | Short retention | Limited |
| Hobby | $10/month | $10/month compute | 25 concurrent runs | 100 schedules | 7 days | 5 members |
| Pro | Custom | Scales with usage | Higher limits | More schedules | Longer retention | More members |
| Enterprise | Custom | Custom | Custom | Custom | Custom | Unlimited |

**Compute billing:** You pay for the CPU/memory/time consumed by your task runs. Machine presets (micro through large-2x) have different per-second rates. Unused included compute does not roll over.

**Additional concurrency:** Available as a self-serve add-on on Hobby and Pro plans. AWS region deployments may include doubled concurrency as a bonus.

For current pricing: https://trigger.dev/pricing

---

## Self-Hosting

Trigger.dev is open source (MIT license) and can be self-hosted on your own infrastructure. The self-hosted option provides:

- Full data control (no data leaves your environment)
- Custom log retention
- Suitable for GDPR, HIPAA, SOC2 compliance requirements

Deployment uses Docker/Docker Compose. See the GitHub repository at https://github.com/triggerdotdev/trigger.dev for self-hosting instructions.
