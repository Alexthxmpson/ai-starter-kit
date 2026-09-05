---
source: https://trigger.dev/docs/open-source-self-hosting
scraped: 2026-02-28
---

# Docker (Legacy) Self-Hosting Guide for Trigger.dev

## Overview

This documentation covers self-hosting Trigger.dev v3 using Docker on your own infrastructure. The guide explicitly warns that "Security, scaling, and reliability concerns are not fully addressed here" and is intended for evaluation rather than production use.

## Key Requirements

The setup demands:
- 4 CPU cores
- 8 GB RAM
- Debian or derivative operating system
- Docker and Docker Compose installed
- Ngrok (or alternative reverse proxy) to expose the webapp

## Two Deployment Options

**Single Server Setup**: Everything runs on one machine—the simplest approach for spare capacity scenarios.

**Split Services Setup**: The webapp runs separately from worker components, enabling independent scaling of workload capacity.

## Critical Warnings

The documentation highlights several security and operational concerns:

- "The docker-provider does not currently enforce any resource limits" allowing tasks to consume all available CPU and RAM
- Worker components have "direct access to the Docker socket" and can execute any Docker command
- Task containers use "host networking," eliminating network isolation between containers and the host
- The docker checkpoint feature is experimental and may cause data loss
- ARM support is unavailable for v3 worker components

## Configuration Highlights

**Registry Setup**: Deploy v3 projects by pushing images to Docker Hub (or compatible registries) so workers can pull them when needed.

**Email Authentication**: The system defaults to magic link authentication. Supported providers include Resend, SMTP, and AWS SES.

**Large Payloads**: Payloads exceeding 512KB offload to S3-compatible storage like Cloudflare R2.

**Checkpointing**: Advanced feature allowing container state persistence, requiring CRIU installation and experimental Docker features.

## Maintenance

Updates involve pulling new Docker images and restarting services via `./update.sh` and restart scripts. The documentation recommends checking `.env.example` for new configuration variables during updates.
