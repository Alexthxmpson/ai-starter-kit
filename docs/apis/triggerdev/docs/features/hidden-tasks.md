---
source: https://trigger.dev/docs/hidden-tasks
scraped: 2026-02-28
---

# Hidden Tasks

## Overview

Hidden tasks are task definitions that remain internal to their module rather than being exported for external access. They can still be executed by other tasks within the same file or package.

## Key Characteristics

According to the documentation, hidden tasks are "tasks that are not exported from your trigger files but can still be executed. These tasks are only accessible to other tasks within the same file or module where they're defined."

## Use Cases

Hidden tasks serve several purposes:

1. **Internal Workflows** - Create task chains that should only be triggered by sibling tasks within the same file
2. **Encapsulation** - Keep implementation details private while exposing only necessary public task interfaces
3. **Reusable Packages** - Import and use task utilities from external packages without re-exporting them

## Example Implementation

A hidden task for internal data processing:

```ts
const processData = task({
  id: "process-data",
  run: async (payload: { data: string }, { ctx }) => {
    return { processed: payload.data.toUpperCase() };
  },
});
```

This task can be invoked by a publicly exported task within the same module using the `.trigger()` method to create a composed workflow.

## Benefits

This pattern enables cleaner APIs by distinguishing between public task interfaces and internal implementation details, supporting modular workflow architecture.
