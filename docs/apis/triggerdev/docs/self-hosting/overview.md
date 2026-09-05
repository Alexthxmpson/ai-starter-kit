---
source: https://trigger.dev/docs/self-hosting/overview
scraped: 2026-02-28
---

# Trigger.dev Self-Hosting Overview

Trigger.dev offers a self-hosted option for users with specific infrastructure requirements. Self-hosting Trigger.dev means you run and manage the platform on your own infrastructure, giving you full control over your environment.

However, the managed Cloud version is recommended for most users due to its scalability and support benefits.

## Architecture

The self-hosted deployment consists of two independently scalable components:

- **Webapp**: Contains the dashboard, Redis, and Postgres
- **Worker**: Houses the supervisor and task execution runners

## Feature Limitations

Self-hosted installations lack several Cloud-exclusive features:
- Warm starts for faster consecutive executions
- Automatic scaling capabilities
- Checkpoint functionality for non-blocking waits
- Dedicated support access

Both versions support community assistance and ARM deployments.

## Configuration Flexibility

Most system limits are configurable through environment variables on the webapp container, including concurrency, rate limits, task payloads, and machine specifications. However, some parameters remain hardcoded, such as the 128KB I/O packet length limit.

## Getting Started

The documentation provides guides for two primary deployment methods: Docker Compose and Kubernetes, with community support available through Discord.
