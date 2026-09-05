---
source: https://trigger.dev/docs/github-integration
scraped: 2026-02-28
---

# GitHub Integration for Trigger.dev

## Overview

The GitHub integration enables automatic deployments whenever code is pushed to tracked branches. This eliminates the need for manual `trigger.dev deploy` commands or custom CI/CD setup.

## Setup Process

The integration requires four steps:

1. **Install the GitHub app** via your project's settings page to authorize Trigger.dev for your organization
2. **Select a repository** to connect to your project
3. **Configure branch tracking** by designating which branches trigger deployments to production, staging, or preview environments
4. **Customize build settings** (optional), including the config file path, install command, and pre-build commands

## How Branch Tracking Works

The system monitors specified branches and automatically deploys code when changes are pushed:

- **Production and Staging branches**: Each push triggers a deployment. Consecutive pushes queue subsequent deployments until the previous one finishes.
- **Pull Request previews**: PRs deploy to preview environments by default (requires preview environment enablement). Preview branches are automatically archived when PRs are merged or closed.

## Build Environment Configuration

### Environment Variables

Variables prefixed with `TRIGGER_BUILD_` are exposed during the build process with the prefix removed. For instance, `TRIGGER_BUILD_MY_TOKEN` is exposed as `MY_TOKEN`.

### Private npm Registry Support

Projects using private npm packages can authenticate by setting `TRIGGER_BUILD_NPM_RC` with a base64-encoded `.npmrc` file containing credentials. The build server automatically creates the appropriate `.npmrc` file for authentication.

## Repository Management

Users can disconnect repositories anytime or modify GitHub app access through account settings (Settings → Applications → Installed GitHub Apps).
