---
source: https://trigger.dev/docs/troubleshooting-alerts
scraped: 2026-02-28
---

# Alerts

Get notified when runs or deployments fail, or when deployments succeed.

## Supported Alert Events

The system supports alerts for three event types:

- Run fails
- Deployment fails
- Deployment succeeds

## Setup Instructions

### Creating an Alert

Navigate to the Alerts section in the left menu and select "New alert" to open the configuration modal.

### Choosing Alert Method

Select your preferred notification channel:

- **Email** notifications
- **Slack** notifications
- **Webhook** notifications

Each method triggers for run failures, deployment failures, and deployment successes.

### Managing Alerts

Use the triple-dot menu on the right side of any alert row to disable or delete it.

## Webhook Integration

### Processing Webhooks

The SDK provides utilities to parse webhook payloads. Here's a Remix example:

```ts
import { ActionFunctionArgs, json } from "@remix-run/server-runtime";
import { webhooks, WebhookError } from "@trigger.dev/sdk";

export async function action({ request }: ActionFunctionArgs) {
  if (request.method !== "POST") {
    return json({ error: "Method not allowed" }, { status: 405 });
  }

  try {
    const event = await webhooks.constructEvent(request, process.env.ALERT_WEBHOOK_SECRET!);

    switch (event.type) {
      case "alert.run.failed": {
        console.log("[Webhook Internal Test] Run failed alert webhook received", { event });
        break;
      }
      case "alert.deployment.success": {
        console.log("[Webhook Internal Test] Deployment success alert webhook received", { event });
        break;
      }
      case "alert.deployment.failed": {
        console.log("[Webhook Internal Test] Deployment failed alert webhook received", { event });
        break;
      }
      default: {
        console.log("[Webhook Internal Test] Unhandled webhook type", { event });
      }
    }

    return json({ received: true }, { status: 200 });
  } catch (err) {
    if (err instanceof WebhookError) {
      console.error("Webhook error:", { message: err.message });
      return json({ error: err.message }, { status: 400 });
    }

    if (err instanceof Error) {
      console.error("Error processing webhook:", { message: err.message });
      return json({ error: err.message }, { status: 400 });
    }

    console.error("Error processing webhook:", { err });
    return json({ error: "Internal server error" }, { status: 500 });
  }
}
```

### Webhook Payload Properties

All webhooks include common properties:

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Unique identifier for the webhook event |
| `created` | datetime | Timestamp of webhook event creation |
| `webhookVersion` | string | Webhook payload format version |
| `type` | string | One of: `alert.run.failed`, `alert.deployment.success`, or `alert.deployment.failed` |

### Run Failed Alert Payload

The `object` property contains:

**Task Information:**
- `object.task.id` - Task identifier
- `object.task.filePath` - Task definition file path
- `object.task.exportName` - Exported function name
- `object.task.version` - Task version
- `object.task.sdkVersion` - SDK version
- `object.task.cliVersion` - CLI version

**Run Information:**
- `object.run.id` - Run identifier
- `object.run.number` - Run sequence number
- `object.run.status` - Current run status
- `object.run.createdAt` - Run creation timestamp
- `object.run.startedAt` - Execution start timestamp
- `object.run.completedAt` - Execution completion timestamp
- `object.run.isTest` - Test run indicator
- `object.run.idempotencyKey` - Idempotency key
- `object.run.tags` - Associated tags array
- `object.run.error` - Error details object
- `object.run.isOutOfMemoryError` - OOM error indicator
- `object.run.machine` - Machine preset used
- `object.run.dashboardUrl` - Dashboard viewing URL

**Organization/Project/Environment:**
- `object.environment.id`, `type`, `slug`
- `object.organization.id`, `slug`, `name`
- `object.project.id`, `ref`, `slug`, `name`

### Deployment Success Alert Payload

The `object` property contains:

**Deployment Information:**
- `object.deployment.id` - Deployment identifier
- `object.deployment.status` - Deployment status
- `object.deployment.version` - Deployment version
- `object.deployment.shortCode` - Short identifier
- `object.deployment.deployedAt` - Completion timestamp
- `object.tasks` - Array of deployed tasks with id, filePath, exportName, and triggerSource

**Organization/Project/Environment:**
- `object.environment.id`, `type`, `slug`
- `object.organization.id`, `slug`, `name`
- `object.project.id`, `ref`, `slug`, `name`

### Deployment Failed Alert Payload

The `object` property contains:

**Deployment Information:**
- `object.deployment.id` - Deployment identifier
- `object.deployment.status` - Deployment status
- `object.deployment.version` - Deployment version
- `object.deployment.shortCode` - Short identifier
- `object.deployment.failedAt` - Failure timestamp

**Error Information:**
- `object.error.name` - Error name
- `object.error.message` - Error message
- `object.error.stack` - Stack trace (optional)
- `object.error.stderr` - Standard error output (optional)

**Organization/Project/Environment:**
- `object.environment.id`, `type`, `slug`
- `object.organization.id`, `slug`, `name`
- `object.project.id`, `ref`, `slug`, `name`
