---
source: https://trigger.dev/docs/context
scraped: 2026-02-28
---

# Context Documentation

The `ctx` object provides information about a task run in Trigger.dev.

## Overview

Context (`ctx`) allows you to access information about a run. **Important note:** "The context object does not change whilst your code is executing. This means values like `ctx.run.durationMs` will be fixed at the moment the `run()` function is called."

## Context Properties

### task
- **exportName** (string): The exported function name of the task
- **id** (string): The ID of the task
- **filePath** (string): The file path of the task

### attempt
- **id** (string): The ID of the execution attempt
- **number** (number): The attempt number
- **startedAt** (date): The start time of the attempt
- **backgroundWorkerId** (string): The ID of the background worker
- **backgroundWorkerTaskId** (string): The ID of the background worker task
- **status** (string): The current status of the attempt

### run
- **id** (string): The ID of the task run
- **context** (any, optional): The context of the task run
- **tags** (array): Tags associated with the task run
- **isTest** (boolean): Whether this is a test run
- **createdAt** (date): The creation time of the task run
- **startedAt** (date): The start time of the task run
- **idempotencyKey** (string, optional): An optional idempotency key
- **maxAttempts** (number, optional): Maximum number of attempts allowed
- **durationMs** (number): The duration in milliseconds when the `run()` function is called
- **costInCents** (number): The cost in cents when the `run()` function is called
- **baseCostInCents** (number): The base cost in cents when the `run()` function is called
- **version** (string, optional): The version of the task run
- **maxDuration** (number, optional): The maximum allowed duration for the task run

### queue
- **id** (string): The ID of the queue
- **name** (string): The name of the queue

### environment
- **id** (string): The ID of the environment
- **slug** (string): The slug of the environment
- **type** (string): The type (PRODUCTION, STAGING, DEVELOPMENT, or PREVIEW)
- **branchName** (string, optional): The branch name if environment is PREVIEW
- **git** (object, optional): Git-related information including commit details, repository info, and pull request data

### organization
- **id** (string): The ID of the organization
- **slug** (string): The slug of the organization
- **name** (string): The name of the organization

### project
- **id** (string): The ID of the project
- **ref** (string): The reference of the project
- **slug** (string): The slug of the project
- **name** (string): The name of the project

### batch (optional)
- **id** (string): The ID of the batch

### machine (optional)
- **name** (string): The name of the machine preset
- **cpu** (number): The CPU allocation
- **memory** (number): The memory allocation
- **centsPerMs** (number): The cost per millisecond for this preset

## Example Usage

```typescript
import { task } from "@trigger.dev/sdk";

export const parentTask = task({
  id: "parent-task",
  run: async (payload: { message: string }, { ctx }) => {
    if (ctx.environment.type === "DEVELOPMENT") {
      return;
    }
  },
});
```
