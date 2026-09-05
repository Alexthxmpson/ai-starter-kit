---
source: https://trigger.dev/docs/self-hosting/docker
scraped: 2026-02-28
---

# Docker Compose Setup for Trigger.dev

## Overview

This guide covers self-hosting Trigger.dev using Docker Compose. The documentation emphasizes that this setup alone is unlikely to be production-ready without addressing security, scaling, and reliability separately.

## Key Changes in v4

The latest version introduced significant improvements:

- **Simplified architecture**: The provider and coordinator merged into a single supervisor, eliminating startup scripts
- **Horizontal scaling**: Support for multiple worker machines enables scaling as needed
- **Enhanced security**: Docker Socket Proxy included by default; all containers use network isolation
- **Built-in services**: Registry and object storage eliminate third-party dependencies
- **Automatic cleanup**: Supervisor manages container lifecycle automatically

## System Requirements

### Webapp Machine
- 3+ vCPU
- 6+ GB RAM
- Hosts: webapp, PostgreSQL, Redis, related services

### Worker Machine
- 4+ vCPU
- 8+ GB RAM
- Hosts: supervisor and task runs

Resource needs scale with concurrency. For example, "100 concurrency x `small-1x` (0.5 vCPU, 0.5 GB RAM) = 50 vCPU and 50 GB RAM".

## Setup Instructions

### Webapp Configuration

1. Clone the repository and navigate to the docker directory
2. Create `.env` file from `.env.example`
3. Launch with `docker compose up -d`
4. Configure environment variables and reapply
5. Access at `http://localhost:8030`
6. Check container logs for magic link credentials

### Worker Configuration

1. Clone repository and navigate to docker directory
2. Create `.env` file
3. Start worker with `docker compose up -d`
4. Configure supervisor environment variables including worker token
5. Apply changes and repeat for additional workers

### Combined Setup

Run both components on one machine using:

```bash
docker compose -f webapp/docker-compose.yml -f worker/docker-compose.yml up -d
```

## Worker Token Management

For separate deployments, manually configure the worker token generated during initial webapp startup. The webapp displays the token once—save it immediately. Set `TRIGGER_WORKER_TOKEN` in `.env` and restart the worker container.

Additional worker groups require admin API access via curl to create new groups beyond the bootstrap group.

## Registry and Storage Configuration

**Registry defaults** (change before production):
- URL: `localhost:5000`
- Username: `registry-user`
- Password: `very-secure-indeed`

**Object storage defaults** (change before production):
- Endpoint: `http://localhost:9000`
- Username: `admin`
- Password: `very-safe-password`

The `packets` bucket is created automatically for large payloads and outputs.

## Authentication Options

**Magic links** (default): Logs to container if email not configured

**Email transports**:
- Resend
- SMTP (note: `SMTP_SECURE=false` uses STARTTLS, not insecure transmission)
- AWS SES

**GitHub OAuth**: Requires OAuth app with callback URL `https://<domain>/auth/github/callback`

**Access restriction**: Use `WHITELISTED_EMAILS` regex pattern to limit signups across all authentication methods.

## CLI Usage Tips

- Use `-a` flag to specify self-hosted instance URL to avoid cloud redirect
- Create multiple profiles for managing different instances
- Use `switch` command to change between profiles
- In CI environments, set `TRIGGER_API_URL` and `TRIGGER_ACCESS_TOKEN` variables

## Troubleshooting Common Issues

- **Deployment failures**: Ensure registry access from deploy machine
- **Email issues**: Check container logs and configure email transport
- **Schema errors**: May indicate PostgreSQL SSL certificate problems; mount certificate and set `NODE_EXTRA_CA_CERTS`
- **Migration sync issues**: Reset goose tracker (with data backup first)

## Version Locking

Specify Docker image versions via `TRIGGER_IMAGE_TAG` environment variable to maintain backwards compatibility with CLI versions and ensure consistent feature support across deployments.
