---
source: https://trigger.dev/docs/self-hosting/env/supervisor
scraped: 2026-02-28
---

# Supervisor Environment Variables

## Required Settings

| Variable | Purpose |
|----------|---------|
| `TRIGGER_API_URL` | Points to the webapp hosting the Trigger.dev API |
| `TRIGGER_WORKER_TOKEN` | Authentication token for workers (supports file:// paths) |
| `MANAGED_WORKER_SECRET` | Must match the webapp configuration value |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OpenTelemetry export endpoint at `<webapp-url>/otel` |

## Worker Configuration

Control how worker instances operate:
- **`TRIGGER_WORKER_INSTANCE_NAME`** (default: random UUID) — Set to `spec.nodeName` in Kubernetes
- **`TRIGGER_WORKER_HEARTBEAT_INTERVAL_SECONDS`** (default: 30) — Heartbeat frequency

## Workload API Settings

Enable and configure the API used by runs to perform actions:
- **`TRIGGER_WORKLOAD_API_ENABLED`** (default: true)
- **`TRIGGER_WORKLOAD_API_PROTOCOL`** (default: http)
- **`TRIGGER_WORKLOAD_API_DOMAIN`** — Leave empty for auto-detection
- **`TRIGGER_WORKLOAD_API_HOST_INTERNAL`** (default: 0.0.0.0)
- **`TRIGGER_WORKLOAD_API_PORT_INTERNAL`** (default: 8020)
- **`TRIGGER_WORKLOAD_API_PORT_EXTERNAL`** (default: 8020)

## Runner & Dequeue Settings

Manage run execution and queue processing with options for heartbeat intervals, snapshot polling, logging, and dequeue behavior (intervals, batch sizes, consumer limits).

## Docker & Container Management

Configure Docker API version, image handling, resource enforcement, auto-cleanup, networking, and registry authentication credentials.

## Kubernetes Integration

Deploy on Kubernetes with namespace selection, node labeling (`v4-worker` default), image pull secrets, and ephemeral storage limits (10Gi default).

## Observability & Cleanup

Enable metrics collection, pod cleanup routines, and failed pod handlers with configurable intervals.

## Debug Mode

Toggle debug logging and run telemetry transmission to the platform.
