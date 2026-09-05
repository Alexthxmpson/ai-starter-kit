---
source: https://trigger.dev/docs/wait-until
scraped: 2026-02-28
---

# Wait Until

> "Wait until a date, then continue execution."

## Overview

This feature enables sending scheduled reminders by pausing task execution until a specified datetime, then resuming to complete the operation.

## Basic Example

```ts
export const sendReminderEmail = task({
  id: "send-reminder-email",
  run: async (payload: { to: string; name: string; date: string }) => {
    await wait.until({ date: new Date(payload.date) });

    const { data, error } = await resend.emails.send({
      from: "hello@trigger.dev",
      to: payload.to,
      subject: "Don't forget…",
      html: `<p>Hello ${payload.name},</p><p>...</p>`,
    });
  },
});
```

This approach simplifies implementation by handling scheduling complexity automatically without manual cron job management.

## Performance & Checkpointing

When waiting exceeds a few seconds in Trigger.dev Cloud, task execution automatically pauses. For waits longer than 5 seconds using `wait.for` or `wait.until`, the system checkpoints progress and excludes the wait period from compute usage calculations.

## Optional Error Handling

Throw an error if the target date has already passed:

```ts
await wait.until({ date: new Date(date), throwIfInThePast: true });
```

## Idempotency

Prevent redundant waits when retrying tasks using idempotency keys:

```ts
await wait.until({
  date: futureDate,
  idempotencyKey: "my-idempotency-key",
  idempotencyKeyTTL: "1h",
});
```
