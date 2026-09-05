# Vercel REST API — Use Cases & Practical Guide

**Date:** 2026-02-27

---

## What You Can Do

### Deployment Management
- Trigger new deployments programmatically (from CI/CD, scripts, or other services)
- List and inspect deployments — filter by state, project, or target (production/preview)
- Delete old or failed deployments to keep the dashboard clean
- Promote any previous deployment to production instantly (without rebuilding)
- Fetch build logs and events for a deployment to diagnose failures

### Project Management
- List all projects under your account or team
- Create new projects and link them to a Git repository via API
- Update project settings (name, build command, output directory, framework)
- Delete projects programmatically

### Environment Variables
- List, create, update, and delete environment variables per project
- Scope env vars to specific environments: production, preview, development
- Scope env vars to specific git branches (useful for feature branches)
- Bulk-create env vars by passing an array in one request
- Use `upsert=true` to safely create-or-update without duplicates

### Domains & Aliases
- Assign and remove custom domains from projects
- Assign specific aliases (e.g., staging.myapp.com) to a specific deployment
- Check domain DNS configuration status

### Team & Account Operations
- List all teams your token has access to
- Retrieve team IDs and slugs for use in other requests

---

## Practical Automation & Project Ideas

| Idea | What to Build | Endpoints Used |
|------|---------------|----------------|
| **CI/CD deploy trigger** | After tests pass in GitHub Actions, call Vercel API to create a production deployment | `POST /v13/deployments` |
| **Preview deploy manager** | Auto-delete preview deployments older than 7 days to stay under deployment limits | `GET /v6/deployments`, `DELETE /v13/deployments/{id}` |
| **One-click rollback** | Script that lists the last 10 production deployments and lets you pick one to promote | `GET /v6/deployments`, `POST /v10/projects/{id}/promote/{deploymentId}` |
| **Deployment health dashboard** | Poll deployment state every 30s and alert when a deployment hits `ERROR` state | `GET /v13/deployments/{id}` |
| **Build log streamer** | Pipe Vercel build logs into Slack or a monitoring tool during deploys | `GET /v1/deployments/{id}/events?follow=1` |
| **Env var sync tool** | Sync environment variables across multiple projects or environments from a central config file | `GET /v9/projects/{id}/env`, `POST /v10/projects/{id}/env` |
| **Multi-project env rotator** | Rotate API keys/secrets across all projects when credentials change | `PATCH /v9/projects/{id}/env/{envId}` |
| **Staging environment setup** | Automate full project creation with env vars, domains, and git linking for new features | `POST /v9/projects`, `POST /v10/projects/{id}/env`, `POST /v9/projects/{id}/domains` |
| **Deploy notification bot** | Webhook-style: poll for new deployments and post to Slack/Discord when state changes to `READY` | `GET /v6/deployments` |
| **Traffic promotion after QA** | Automatically promote a preview deployment to production once a QA checklist is marked done | `POST /v10/projects/{id}/promote/{deploymentId}` |
| **Branch env var injection** | Inject branch-specific env vars when a PR is opened (scope by `gitBranch`) | `POST /v10/projects/{id}/env` |
| **Project audit tool** | List all projects + their env vars (without values) to audit for missing required keys | `GET /v9/projects`, `GET /v9/projects/{id}/env` |

---

## Key Limits & Gotchas

### Authentication
- Tokens are shown **once** at creation — store them immediately in a secrets manager
- Tokens scope to personal or specific teams; a personal token cannot access team resources unless explicitly scoped
- Always use `?teamId=` or `?slug=` when targeting team-owned resources — missing this returns 403 silently

### Deployments
- `POST /v13/deployments` triggers a **full rebuild**; `POST /v10/projects/{id}/promote/{deploymentId}` just **switches traffic** without rebuilding
- If a deployment upload is still in progress, the `url` field in the response will be `null`
- Deployment states: `QUEUED` → `BUILDING` → `READY` (or `ERROR` / `CANCELED`)
- You cannot delete a deployment that is currently live as the production deployment — promote a different one first

### Environment Variables
- `type: "encrypted"` variables are not returned as plaintext unless you pass `?decrypt=true` and your token has permission
- `type: "secret"` is deprecated — use `"encrypted"` for new variables
- `gitBranch` scoping only works for the `preview` target, not `production`
- Use `?upsert=true` in POST requests to avoid creating duplicates if the key already exists
- Changing an env var does **not** automatically trigger a redeploy — you must create a new deployment to pick up the change

### Pagination
- Default page size is 20; maximum is 100
- To page through results, pass `pagination.next` from the response as the `from` query parameter
- Large projects with many deployments require multiple requests to retrieve all results

### Rate Limits
- Rate limit headers (`X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`) are on every response — check them
- When you hit 429, back off until `X-RateLimit-Reset` — do not retry immediately
- Automation scripts that loop over many deployments or projects should add delays or respect the rate limit headers

### Domains
- A domain can only belong to one project at a time — assigning it to a second project returns 409 conflict
- DNS propagation after adding a domain can take time — the API can confirm configuration validity but not DNS propagation completion
- Custom domains must be verified (DNS records pointing to Vercel) before they go live

### Versioning
- Different resources use different API version prefixes (`/v6`, `/v9`, `/v10`, `/v13`) — there is no single global version
- Always check the official docs for the correct version prefix; using the wrong version returns 404
- Vercel does not always announce version deprecations in advance — pin to tested versions in production scripts

### Promote vs. Redeploy
- Promoting is **instant** and does not run build steps — good for fast rollbacks
- If you need to re-run the build (e.g., env var changes), create a new deployment instead of promoting
- Promoting a deployment that was built on an old commit does not update the Git metadata in the dashboard

---

## Minimal Working Example

```bash
# 1. List your projects
curl "https://api.vercel.com/v9/projects?limit=5" \
  -H "Authorization: Bearer $VERCEL_TOKEN"

# 2. Trigger a production deployment from Git
curl -X POST "https://api.vercel.com/v13/deployments?teamId=$TEAM_ID" \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "my-app",
    "project": "prj_abc123",
    "target": "production",
    "gitSource": {
      "type": "github",
      "ref": "main",
      "sha": "a1b2c3d4"
    }
  }'

# 3. Promote an existing deployment (no rebuild)
curl -X POST "https://api.vercel.com/v10/projects/prj_abc123/promote/dpl_xyz789?teamId=$TEAM_ID" \
  -H "Authorization: Bearer $VERCEL_TOKEN"

# 4. Set an environment variable
curl -X POST "https://api.vercel.com/v10/projects/my-app/env?teamId=$TEAM_ID&upsert=true" \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "STRIPE_SECRET_KEY",
    "value": "sk_live_...",
    "type": "encrypted",
    "target": ["production"]
  }'
```
