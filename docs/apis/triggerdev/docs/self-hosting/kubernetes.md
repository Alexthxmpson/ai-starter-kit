---
source: https://trigger.dev/docs/self-hosting/kubernetes
scraped: 2026-02-28
---

# Kubernetes Deployment Guide for Trigger.dev

## Overview

Trigger.dev offers self-hosting capabilities through an official Helm chart. However, the documentation emphasizes that "This guide alone is unlikely to result in a production-ready deployment," as security, scaling, and reliability concerns require custom configuration.

## Minimum Requirements

**Cluster specifications:**
- Kubernetes 1.19+
- Helm 3.8+
- 6+ vCPU and 12+ GB RAM total
- Persistent volume support

**Component resource allocations:**

| Component | vCPU | RAM |
|-----------|------|-----|
| Webapp | 1 | 2GB |
| Supervisor | 1 | 1GB |
| PostgreSQL | 1 | 2GB |
| Redis | 0.5 | 1GB |
| ClickHouse | 1 | 2GB |

## Quick Installation

The fastest deployment uses default values (testing only):

```bash
helm upgrade -n trigger --install trigger \
  oci://ghcr.io/triggerdotdev/charts/trigger \
  --version "~4.0.0" \
  --create-namespace
```

Access the dashboard via port-forward at `http://localhost:3040`.

## Configuration Strategy

Helm values follow camelCase naming, mapping to UPPER_SNAKE_CASE environment variables. The documentation recommends using Kubernetes secrets rather than plaintext values for production deployments, especially for sensitive configurations like database credentials and authentication tokens.

## External Services Support

The Helm chart supports integrating external services:
- PostgreSQL with SSL/CA certificate support
- Redis with TLS capabilities
- ClickHouse databases
- S3-compatible object storage

Each service offers both direct configuration and secret-based approaches for credential management.

## Authentication Options

Supported methods include GitHub OAuth and email authentication via Resend, with optional email whitelisting for access restriction.
