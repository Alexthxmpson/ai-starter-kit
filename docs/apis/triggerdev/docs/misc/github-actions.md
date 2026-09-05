---
source: https://trigger.dev/docs/github-actions
scraped: 2026-02-28
---

# CI / GitHub Actions

## Overview

Trigger.dev tasks can be deployed through GitHub Actions and other CI systems. The documentation provides templates for automatic deployments when code changes are pushed to specific branches.

## Key Deployment Scenarios

**Production Deployments**: A workflow triggers automatically when changes are pushed to the `main` branch, specifically when the `trigger` directory is modified.

**Staging Deployments**: Manual workflow dispatch allows deployments to staging environments from any branch or commit.

**Preview Branches**: Pull requests can deploy to preview environments with automatic archival when PRs are merged or closed. The workflow requires all four pull request event types: `opened`, `synchronize`, `reopened`, and `closed`.

## Setup Requirements

1. **Access Token**: Create a personal access token from your Trigger.dev profile's "Personal Access Tokens" tab
2. **GitHub Secret**: Add `TRIGGER_ACCESS_TOKEN` to your repository's Actions secrets
3. **Node.js**: Workflows use Node.js 20.x with `npm install` for dependencies

## Important Configuration Notes

The deployment command will fail if version mismatches are detected between the CLI and `@trigger.dev/*` packages. To maintain version consistency, add `trigger.dev` to `devDependencies` and create npm scripts for deployment commands defined in `package.json`.

## Self-Hosted Deployments

Self-hosted instances require Docker Buildx setup, registry credentials in GitHub secrets, and the `TRIGGER_API_URL` environment variable pointing to your webapp domain (e.g., `https://trigger.example.com`).
