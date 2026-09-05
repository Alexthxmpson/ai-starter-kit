---
source: https://trigger.dev/docs/how-to-reduce-your-spend
scraped: 2026-02-28
---

# How to Reduce Your Spend on Trigger.dev

This guide provides practical strategies for lowering costs on the Trigger.dev platform through monitoring, configuration, and optimization techniques.

## Key Cost-Reduction Strategies

**Monitor Usage Patterns**
The platform offers a usage dashboard accessible via the Organization menu, allowing you to track expensive tasks, total duration metrics, run counts, and daily usage spikes. Regular monitoring helps identify anomalies early.

**Set Up Billing Alerts**
Two alert types are available: standard notifications at 75%, 90%, 100%, 200%, and 500% of monthly budget, plus spike alerts at multiples like 1000% to catch runaway processes. The documentation recommends keeping spike alerts enabled as a safety mechanism.

**Optimize Machine Configurations**
Start with the smallest machine size (small-1x: 0.5 vCPU, 0.5 GB RAM) and scale up only when necessary. Larger machines incur higher per-second costs, so right-sizing prevents unnecessary expenses.

**Leverage Idempotency Keys**
These prevent duplicate work by caching results within a specified TTL (time-to-live), particularly valuable during retries. The feature works across wait functions and child task triggers.

**Consolidate Parallel Work**
Executing multiple async operations (like API calls) within a single task is often more efficient than splitting across many tasks, since most time involves waiting rather than computing.

**Minimize Unnecessary Retries**
Configure lower `maxAttempts` values for non-critical tasks and use `AbortTaskRunError` to prevent retries on permanent failures that would waste compute resources.

**Use Checkpointing for Waits**
Waits longer than 5 seconds automatically checkpoint tasks, meaning you don't incur compute costs during idle periods. This makes waitpoint-based patterns preferable to polling loops.

**Apply Debouncing**
Consolidate multiple rapid triggers into single runs using the debounce feature, ideal for scenarios like document indexing or webhook aggregation.
