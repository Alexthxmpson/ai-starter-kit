---
source: https://trigger.dev/docs/tasks/schemaTask
scraped: 2026-02-28
---

# schemaTask Documentation

## Overview

The `schemaTask` function enables you to define tasks with runtime payload validation using a schema parser. As stated in the documentation, it "Define[s] tasks with a runtime payload schema and validate[s] the payload before running the task."

## Key Features

**Payload Validation**: The schema validates payloads both when triggering tasks directly and before execution. Invalid payloads prevent task runs and generate schema-specific errors.

**Type Inference**: Libraries like Zod support distinct input/output types, allowing you to define schemas with defaults or type coercion. For example, a string can be coerced to a date, or a field can have a default value.

**AI Integration**: The `ai.tool()` function converts `schemaTask` instances into tools compatible with the Vercel AI SDK, enabling LLM integration.

## Basic Usage

```ts
import { schemaTask } from "@trigger.dev/sdk";
import { z } from "zod";

const myTask = schemaTask({
  id: "my-task",
  schema: z.object({
    name: z.string(),
    age: z.number(),
  }),
  run: async (payload) => {
    console.log(payload.name, payload.age);
  },
});
```

## Supported Schema Libraries

The documentation covers implementations for:
- Zod
- Yup
- Superstruct
- ArkType
- @effect/schema
- runtypes
- valibot
- typebox
- Custom parser functions

Each schema library's parser validates data according to its validation rules before task execution.
