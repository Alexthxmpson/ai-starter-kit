---
source: https://trigger.dev/docs/self-hosting/env/webapp
scraped: 2026-02-28
---

# Webapp Environment Variables

This page documents the configuration variables for the Trigger.dev webapp container, organized by functional category.

## Required Secrets

Three encryption secrets must be generated using `openssl rand -hex 16`:

- **SESSION_SECRET**: Session encryption
- **MAGIC_LINK_SECRET**: Magic link encryption
- **ENCRYPTION_KEY**: Secret store encryption

## Domain Configuration

The webapp requires several origin URLs to be specified:

- `APP_ORIGIN` and `LOGIN_ORIGIN` (typically identical)
- `API_ORIGIN` and `STREAM_ORIGIN` (defaults to `APP_ORIGIN`)
- `ELECTRIC_ORIGIN` (defaults to `http://localhost:3060`)
- `REMIX_APP_PORT` (defaults to 3030)

## Database & Caching

PostgreSQL configuration requires a primary connection string and a separate direct URL for migrations. Optional read-replica support and connection pooling parameters are available. Redis configuration includes host, port, optional credentials, and separate reader endpoints.

## Authentication & Email

GitHub OAuth is supported via client credentials. Email delivery can use Resend, SMTP, or AWS SES. Alert-specific email configuration can override general settings.

## Performance & Concurrency

"The default org execution concurrency limit needs to be 3x the env concurrency." Worker concurrency defaults to 10, with configurable polling intervals. Development runs are limited to 25 concurrent executions by default.

## Rate Limiting & Quotas

API and run engine rate limiting uses a refill-interval model. Batch operations support up to 500 items (v2) or 1000 items (v3). Task payloads exceeding 512KB are offloaded to S3, with a maximum size of 3MB.

## Deployment & Storage

Deploy registry credentials and platform specifications configure container image management. S3-compatible object storage handles large payloads. Optional bootstrap configuration enables worker group setup.

## Observability

OpenTelemetry limits configure span attributes, log attributes, and event counts. Optional event loop monitoring and telemetry collection can be toggled.
