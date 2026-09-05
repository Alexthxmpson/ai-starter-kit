# Vercel REST API — Technical Documentation

**Source:** https://vercel.com/docs/rest-api
**Endpoints Reference:** https://vercel.com/docs/rest-api/endpoints
**Date:** 2026-02-27

---

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Base URL & Versioning](#base-url--versioning)
4. [Pagination](#pagination)
5. [Rate Limits](#rate-limits)
6. [Error Handling](#error-handling)
7. [Teams & Scoping](#teams--scoping)
8. [Deployments](#deployments)
9. [Projects](#projects)
10. [Environment Variables](#environment-variables)
11. [Domains & Aliases](#domains--aliases)
12. [Logs](#logs)

---

## Overview

The Vercel REST API allows you to programmatically manage deployments, projects, domains, environment variables, and team resources. All endpoints live under `https://api.vercel.com` and follow REST conventions. Responses are JSON.

---

## Authentication

All requests require a **Vercel Access Token** sent as a Bearer token in the `Authorization` header.

### Getting a Token

1. Go to [vercel.com/account/tokens](https://vercel.com/account/tokens)
2. Click **Create Token**
3. Give it a name and scope (full account or specific team)
4. Copy the token — it is only shown once

### Using the Token

```http
Authorization: Bearer <YOUR_TOKEN>
```

**Example with curl:**

```bash
curl https://api.vercel.com/v9/projects \
  -H "Authorization: Bearer xxxxxxxxxxxxxxxxxxxxxxxx"
```

**Example with fetch (Node.js):**

```javascript
const response = await fetch('https://api.vercel.com/v9/projects', {
  headers: {
    Authorization: 'Bearer ' + process.env.VERCEL_TOKEN,
  },
});
const data = await response.json();
```

> **Note:** Tokens are sensitive. Never commit them to source control. Use environment variables or a secrets manager.

---

## Base URL & Versioning

- **Base URL:** `https://api.vercel.com`
- Endpoints are versioned per-resource (e.g., `/v9/projects`, `/v13/deployments`)
- Always check the specific endpoint version in the official docs, as versions differ by resource

```
https://api.vercel.com/v9/projects
https://api.vercel.com/v13/deployments
https://api.vercel.com/v6/deployments/{id}/aliases
```

---

## Pagination

Most list endpoints return paginated results.

| Parameter | Type   | Default | Maximum | Description                        |
|-----------|--------|---------|---------|-----------------------------------|
| `limit`   | number | 20      | 100     | Number of results per page         |
| `from`    | number | —       | —       | Timestamp (ms) to paginate from    |
| `until`   | number | —       | —       | Timestamp (ms) to paginate until   |

**Paginated response shape:**

```json
{
  "deployments": [...],
  "pagination": {
    "count": 20,
    "next": 1614124471,
    "prev": null
  }
}
```

Pass `pagination.next` as the `from` query parameter to get the next page.

---

## Rate Limits

Rate limit information is returned in response headers on every request.

| Header                  | Description                                      |
|-------------------------|--------------------------------------------------|
| `X-RateLimit-Limit`     | Maximum requests allowed in the window           |
| `X-RateLimit-Remaining` | Requests remaining in the current window         |
| `X-RateLimit-Reset`     | Unix timestamp (seconds) when the window resets  |

When a rate limit is exceeded, the API returns **429 Too Many Requests**. Back off and retry after the `X-RateLimit-Reset` time.

---

## Error Handling

All error responses follow a consistent JSON structure:

```json
{
  "error": {
    "code": "forbidden",
    "message": "Not authorized"
  }
}
```

Some endpoints extend the error object with additional fields (e.g., `missingToken`, `invalidToken`).

### Common HTTP Status Codes

| Code | Meaning                                                        |
|------|----------------------------------------------------------------|
| 200  | OK — request succeeded                                         |
| 201  | Created — resource created successfully                        |
| 204  | No Content — success with no response body                     |
| 400  | Bad Request — invalid parameters or body                       |
| 401  | Unauthorized — missing or invalid token                        |
| 403  | Forbidden — valid token but insufficient permissions           |
| 404  | Not Found — resource does not exist                            |
| 409  | Conflict — resource already exists (e.g., duplicate domain)    |
| 422  | Unprocessable Entity — validation error                        |
| 429  | Too Many Requests — rate limit exceeded                        |
| 500  | Internal Server Error — Vercel-side error                      |

### Common Error Codes

| `error.code`          | Meaning                                       |
|-----------------------|-----------------------------------------------|
| `forbidden`           | Token lacks required permission               |
| `not_found`           | Resource not found                            |
| `invalid_token`       | Token is malformed or expired                 |
| `missing_token`       | No Authorization header provided              |
| `too_many_requests`   | Rate limit exceeded                           |
| `domain_conflict`     | Domain already in use by another project      |

---

## Teams & Scoping

By default, requests operate on your **personal account**. To operate on a **team**, append `teamId` or `slug` as a query parameter.

| Query Param | Description                       | Example                          |
|-------------|-----------------------------------|----------------------------------|
| `teamId`    | The team's unique identifier      | `?teamId=team_abc123`            |
| `slug`      | The team's URL slug               | `?slug=my-company`               |

Find your team ID via:

```bash
curl https://api.vercel.com/v2/teams \
  -H "Authorization: Bearer <TOKEN>"
```

**Always include `teamId` or `slug` when managing team resources**, otherwise the API operates on your personal account and may return 403 errors for team-owned resources.

---

## Deployments

### List Deployments

```
GET /v6/deployments
```

**Query Parameters:**

| Parameter   | Type   | Description                                   |
|-------------|--------|-----------------------------------------------|
| `app`       | string | Filter by project/app name                    |
| `projectId` | string | Filter by project ID                          |
| `state`     | string | Filter by state: `BUILDING`, `READY`, `ERROR` |
| `target`    | string | `production` or `preview`                     |
| `limit`     | number | Results per page (max 100, default 20)        |
| `teamId`    | string | Scope to a team                               |
| `slug`      | string | Team slug alternative to teamId               |

**Example Request:**

```bash
curl "https://api.vercel.com/v6/deployments?projectId=prj_abc123&limit=10&teamId=team_xyz" \
  -H "Authorization: Bearer <TOKEN>"
```

**Example Response:**

```json
{
  "deployments": [
    {
      "uid": "dpl_bE4gijzGaTAV4VsF5KfvMVXTsTNA",
      "name": "my-next-app",
      "url": "my-next-app-abc123.vercel.app",
      "created": 1614124471000,
      "state": "READY",
      "target": "production",
      "projectId": "prj_abc123",
      "creator": {
        "uid": "usr_xyz",
        "email": "user@example.com",
        "username": "username"
      },
      "meta": {
        "githubCommitSha": "a1b2c3d4",
        "githubCommitMessage": "Fix: update homepage"
      }
    }
  ],
  "pagination": {
    "count": 1,
    "next": null
  }
}
```

---

### Get a Deployment by ID or URL

```
GET /v13/deployments/{idOrUrl}
```

**Path Parameters:**

| Parameter | Type   | Description                          |
|-----------|--------|--------------------------------------|
| `idOrUrl` | string | Deployment ID (`dpl_...`) or URL     |

**Example Request:**

```bash
curl "https://api.vercel.com/v13/deployments/dpl_bE4gijzGaTAV4VsF5KfvMVXTsTNA" \
  -H "Authorization: Bearer <TOKEN>"
```

**Key Response Fields:**

| Field       | Type   | Description                                                        |
|-------------|--------|--------------------------------------------------------------------|
| `uid`       | string | Unique deployment ID                                               |
| `url`       | string | Deployment URL (null if upload is incomplete)                      |
| `name`      | string | Project name                                                       |
| `state`     | string | `QUEUED`, `BUILDING`, `READY`, `ERROR`, `CANCELED`                |
| `target`    | string | `production` or `preview`                                          |
| `created`   | number | Unix timestamp in milliseconds                                     |
| `projectId` | string | Associated project ID                                              |
| `meta`      | object | Git metadata (commit SHA, message, author, branch)                 |

---

### Create a New Deployment

```
POST /v13/deployments
```

**Query Parameters:**

| Parameter | Type   | Description                            |
|-----------|--------|----------------------------------------|
| `teamId`  | string | Deploy under a team                    |
| `slug`    | string | Team slug                              |
| `forceNew`| number | `1` to force a new build even if unchanged |

**Request Body (from Git):**

```json
{
  "name": "my-next-app",
  "project": "prj_abc123",
  "gitSource": {
    "type": "github",
    "ref": "main",
    "sha": "a1b2c3d4e5f6",
    "projectId": "prj_abc123"
  },
  "target": "production"
}
```

**Request Body (prebuilt / file upload):**

```json
{
  "name": "my-static-site",
  "files": [
    {
      "file": "index.html",
      "data": "<!DOCTYPE html><html><body>Hello</body></html>",
      "encoding": "utf-8"
    }
  ],
  "projectSettings": {
    "framework": null
  }
}
```

**Key Body Parameters:**

| Field       | Type   | Required | Description                                            |
|-------------|--------|----------|--------------------------------------------------------|
| `name`      | string | Yes      | Project name                                           |
| `project`   | string | No       | Project ID or name to associate                        |
| `gitSource` | object | No       | Git source info (type, ref, sha)                       |
| `files`     | array  | No       | Array of file objects for direct upload                |
| `target`    | string | No       | `production` or `preview`                              |
| `meta`      | object | No       | Custom metadata key/value pairs                        |
| `env`       | object | No       | Deployment-level environment variable overrides        |

**Example Response:**

```json
{
  "uid": "dpl_newDeploymentId",
  "url": "my-next-app-newid.vercel.app",
  "name": "my-next-app",
  "state": "BUILDING",
  "target": "production",
  "projectId": "prj_abc123",
  "created": 1614124999000
}
```

---

### Delete a Deployment

```
DELETE /v13/deployments/{id}
```

**Path Parameters:**

| Parameter | Type   | Description         |
|-----------|--------|---------------------|
| `id`      | string | Deployment ID       |

**Query Parameters:**

| Parameter | Type   | Description         |
|-----------|--------|---------------------|
| `teamId`  | string | Team identifier     |
| `slug`    | string | Team slug           |

**Example Request:**

```bash
curl -X DELETE "https://api.vercel.com/v13/deployments/dpl_abc123?teamId=team_xyz" \
  -H "Authorization: Bearer <TOKEN>"
```

**Response:**

```json
{
  "uid": "dpl_abc123",
  "state": "DELETED"
}
```

---

### Promote a Deployment to Production

Points all production domains for a project to a given deployment. This does **not** rebuild the deployment — it only redirects traffic.

```
POST /v10/projects/{projectId}/promote/{deploymentId}
```

**Path Parameters:**

| Parameter      | Type   | Description                              |
|----------------|--------|------------------------------------------|
| `projectId`    | string | Project ID or name                       |
| `deploymentId` | string | Deployment ID to promote to production   |

**Query Parameters:**

| Parameter | Type   | Description |
|-----------|--------|-------------|
| `teamId`  | string | Team ID     |
| `slug`    | string | Team slug   |

**Example Request:**

```bash
curl -X POST "https://api.vercel.com/v10/projects/prj_abc123/promote/dpl_xyz789?teamId=team_xyz" \
  -H "Authorization: Bearer <TOKEN>"
```

**Response:** `200 OK` with updated project/deployment info.

> **Important:** If you need to rebuild before promoting, use the Create Deployment endpoint first, then promote once the deployment state is `READY`.

---

### Get Deployment Events (Logs)

```
GET /v1/deployments/{id}/events
```

Returns build log events for a deployment in real-time or historical form.

**Query Parameters:**

| Parameter  | Type   | Description                                       |
|------------|--------|---------------------------------------------------|
| `follow`   | number | `1` to stream events as they happen (SSE)         |
| `direction`| string | `forward` or `backward`                           |
| `limit`    | number | Max events to return                              |
| `teamId`   | string | Team identifier                                   |

**Example Request:**

```bash
curl "https://api.vercel.com/v1/deployments/dpl_abc123/events?teamId=team_xyz" \
  -H "Authorization: Bearer <TOKEN>"
```

**Response (array of event objects):**

```json
[
  {
    "type": "stdout",
    "created": 1614124500000,
    "payload": {
      "text": "Installing dependencies...",
      "date": 1614124500000
    }
  }
]
```

---

## Projects

### List Projects

```
GET /v9/projects
```

**Query Parameters:**

| Parameter  | Type   | Description                                    |
|------------|--------|------------------------------------------------|
| `limit`    | number | Results per page (max 100, default 20)         |
| `from`     | number | Timestamp for pagination                       |
| `search`   | string | Filter by project name                         |
| `teamId`   | string | Team identifier                                |
| `slug`     | string | Team slug                                      |

**Example Request:**

```bash
curl "https://api.vercel.com/v9/projects?teamId=team_xyz&limit=50" \
  -H "Authorization: Bearer <TOKEN>"
```

**Example Response:**

```json
{
  "projects": [
    {
      "id": "prj_abc123",
      "name": "my-next-app",
      "framework": "nextjs",
      "createdAt": 1614000000000,
      "updatedAt": 1614124471000,
      "latestDeployments": [...],
      "targets": {
        "production": {
          "url": "my-next-app.vercel.app"
        }
      }
    }
  ],
  "pagination": {
    "count": 1,
    "next": null
  }
}
```

---

### Get a Project

```
GET /v9/projects/{idOrName}
```

**Path Parameters:**

| Parameter  | Type   | Description            |
|------------|--------|------------------------|
| `idOrName` | string | Project ID or name     |

**Example Request:**

```bash
curl "https://api.vercel.com/v9/projects/my-next-app?teamId=team_xyz" \
  -H "Authorization: Bearer <TOKEN>"
```

---

### Create a Project

```
POST /v9/projects
```

**Request Body:**

```json
{
  "name": "my-new-project",
  "framework": "nextjs",
  "gitRepository": {
    "type": "github",
    "repo": "myorg/my-repo"
  },
  "buildCommand": "npm run build",
  "outputDirectory": ".next",
  "rootDirectory": null
}
```

**Key Body Parameters:**

| Field             | Type   | Required | Description                                           |
|-------------------|--------|----------|-------------------------------------------------------|
| `name`            | string | Yes      | Project name (must be unique per team/account)        |
| `framework`       | string | No       | Framework preset: `nextjs`, `create-react-app`, etc.  |
| `gitRepository`   | object | No       | Link to a Git repo (`type`, `repo`)                   |
| `buildCommand`    | string | No       | Override build command                                |
| `outputDirectory` | string | No       | Override output directory                             |
| `rootDirectory`   | string | No       | Monorepo: subdirectory to use as project root         |
| `publicSource`    | boolean| No       | Whether to make source publicly accessible            |

**Example Response:**

```json
{
  "id": "prj_newId",
  "name": "my-new-project",
  "framework": "nextjs",
  "createdAt": 1614124999000
}
```

---

### Update a Project

```
PATCH /v9/projects/{idOrName}
```

**Request Body:** Same fields as Create — include only the fields you want to update.

```json
{
  "name": "renamed-project",
  "buildCommand": "npm run build:prod",
  "framework": "nextjs"
}
```

**Example Request:**

```bash
curl -X PATCH "https://api.vercel.com/v9/projects/old-name?teamId=team_xyz" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name": "new-name"}'
```

---

### Delete a Project

```
DELETE /v9/projects/{idOrName}
```

**Example Request:**

```bash
curl -X DELETE "https://api.vercel.com/v9/projects/prj_abc123?teamId=team_xyz" \
  -H "Authorization: Bearer <TOKEN>"
```

**Response:** `204 No Content`

> **Warning:** This permanently deletes the project and all its deployments. There is no undo.

---

## Environment Variables

### List Environment Variables

```
GET /v9/projects/{idOrName}/env
```

**Query Parameters:**

| Parameter | Type   | Description                              |
|-----------|--------|------------------------------------------|
| `decrypt` | boolean| `true` to return decrypted values        |
| `teamId`  | string | Team identifier                          |
| `slug`    | string | Team slug                                |

**Example Request:**

```bash
curl "https://api.vercel.com/v9/projects/my-next-app/env?teamId=team_xyz&decrypt=true" \
  -H "Authorization: Bearer <TOKEN>"
```

**Example Response:**

```json
{
  "envs": [
    {
      "id": "env_abc123",
      "key": "DATABASE_URL",
      "value": "postgres://...",
      "type": "encrypted",
      "target": ["production", "preview"],
      "gitBranch": null,
      "configurationId": null,
      "updatedAt": 1614124471000,
      "createdAt": 1614000000000
    }
  ]
}
```

---

### Create Environment Variable(s)

```
POST /v10/projects/{idOrName}/env
```

**Query Parameters:**

| Parameter | Type    | Description                                                          |
|-----------|---------|----------------------------------------------------------------------|
| `upsert`  | boolean | `true` to update existing variable instead of creating a duplicate   |
| `teamId`  | string  | Team identifier                                                      |

**Request Body (single variable):**

```json
{
  "key": "API_SECRET",
  "value": "my-secret-value",
  "type": "encrypted",
  "target": ["production", "preview", "development"],
  "comment": "Third-party API secret key"
}
```

**Request Body (multiple variables):**

```json
[
  {
    "key": "API_KEY",
    "value": "key123",
    "type": "plain",
    "target": ["production"]
  },
  {
    "key": "DEBUG",
    "value": "false",
    "type": "plain",
    "target": ["preview", "development"]
  }
]
```

**Key Body Parameters:**

| Field               | Type     | Required | Description                                                         |
|---------------------|----------|----------|---------------------------------------------------------------------|
| `key`               | string   | Yes      | Variable name (e.g., `DATABASE_URL`)                               |
| `value`             | string   | Yes      | Variable value                                                      |
| `type`              | string   | Yes      | `plain`, `secret`, or `encrypted`                                  |
| `target`            | string[] | Yes      | One or more of: `production`, `preview`, `development`             |
| `gitBranch`         | string   | No       | Scope to a specific git branch (preview only)                      |
| `comment`           | string   | No       | Description/comment for the variable                               |
| `customEnvironmentIds` | string[] | No  | Scope to custom environments                                       |

**Variable Types:**

| Type        | Description                                          |
|-------------|------------------------------------------------------|
| `plain`     | Stored in plaintext, visible in UI                   |
| `secret`    | Encrypted, not returned in list (deprecated approach)|
| `encrypted` | Encrypted at rest, decryptable via API with token    |

---

### Edit an Environment Variable

```
PATCH /v9/projects/{idOrName}/env/{id}
```

**Path Parameters:**

| Parameter | Type   | Description               |
|-----------|--------|---------------------------|
| `idOrName`| string | Project ID or name        |
| `id`      | string | Environment variable ID   |

**Request Body:** Same fields as create — include only fields to change.

```json
{
  "value": "new-secret-value",
  "target": ["production"]
}
```

---

### Delete an Environment Variable

```
DELETE /v9/projects/{idOrName}/env/{id}
```

**Example Request:**

```bash
curl -X DELETE "https://api.vercel.com/v9/projects/my-next-app/env/env_abc123?teamId=team_xyz" \
  -H "Authorization: Bearer <TOKEN>"
```

**Response:** `200 OK` with the deleted variable object.

---

## Domains & Aliases

### List Aliases for a Deployment

```
GET /v6/deployments/{id}/aliases
```

**Example Request:**

```bash
curl "https://api.vercel.com/v6/deployments/dpl_abc123/aliases?teamId=team_xyz" \
  -H "Authorization: Bearer <TOKEN>"
```

**Example Response:**

```json
{
  "aliases": [
    {
      "uid": "alias_xyz",
      "alias": "my-app.vercel.app",
      "created": 1614000000000,
      "deployment": {
        "id": "dpl_abc123",
        "url": "my-app-abc123.vercel.app"
      }
    }
  ]
}
```

---

### Assign a Domain to a Project

```
POST /v9/projects/{idOrName}/domains
```

**Request Body:**

```json
{
  "name": "www.myapp.com"
}
```

**Example Request:**

```bash
curl -X POST "https://api.vercel.com/v9/projects/my-next-app/domains?teamId=team_xyz" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name": "www.myapp.com"}'
```

---

### Remove a Domain from a Project

```
DELETE /v9/projects/{idOrName}/domains/{domain}
```

**Example Request:**

```bash
curl -X DELETE "https://api.vercel.com/v9/projects/my-next-app/domains/www.myapp.com?teamId=team_xyz" \
  -H "Authorization: Bearer <TOKEN>"
```

---

### Assign an Alias to a Deployment

Creates an alias pointing to a specific deployment.

```
POST /v2/deployments/{id}/aliases
```

**Request Body:**

```json
{
  "alias": "staging.myapp.com"
}
```

---

### Check Domain Configuration

```
GET /v6/domains/{domain}/config
```

Returns DNS configuration status and any conflicts for a domain.

---

## Logs

### Get Deployment Build Logs (Events)

```
GET /v1/deployments/{id}/events
```

Covered in the Deployments section above. Returns build log output (stdout/stderr) for a deployment.

### Get Runtime Logs

Runtime logs are available through Vercel's Log Drains feature for production. The API for querying runtime logs uses:

```
GET /v1/projects/{projectId}/deployments/{deploymentId}/runtime-logs
```

**Query Parameters:**

| Parameter | Type   | Description                        |
|-----------|--------|------------------------------------|
| `teamId`  | string | Team identifier                    |
| `slug`    | string | Team slug                          |
| `limit`   | number | Number of log lines to return      |
| `since`   | number | Unix timestamp to start from       |

**Example Request:**

```bash
curl "https://api.vercel.com/v1/projects/prj_abc/deployments/dpl_xyz/runtime-logs?teamId=team_xyz" \
  -H "Authorization: Bearer <TOKEN>"
```

> **Note:** Runtime logs may be empty for static deployments (SSG) since there is no server runtime. Serverless function logs are captured for API routes.

---

## Teams

### List Teams

```
GET /v2/teams
```

**Example Request:**

```bash
curl "https://api.vercel.com/v2/teams" \
  -H "Authorization: Bearer <TOKEN>"
```

**Example Response:**

```json
{
  "teams": [
    {
      "id": "team_abc123",
      "slug": "my-company",
      "name": "My Company",
      "createdAt": 1614000000000
    }
  ]
}
```

---

### Get a Team

```
GET /v2/teams/{idOrSlug}
```

**Example Request:**

```bash
curl "https://api.vercel.com/v2/teams/my-company" \
  -H "Authorization: Bearer <TOKEN>"
```

---

## Quick Reference: Endpoint Cheat Sheet

| Action                          | Method | Path                                              |
|---------------------------------|--------|---------------------------------------------------|
| List deployments                | GET    | `/v6/deployments`                                 |
| Get deployment                  | GET    | `/v13/deployments/{idOrUrl}`                      |
| Create deployment               | POST   | `/v13/deployments`                                |
| Delete deployment               | DELETE | `/v13/deployments/{id}`                           |
| Promote deployment              | POST   | `/v10/projects/{projectId}/promote/{deploymentId}`|
| Get deployment events/logs      | GET    | `/v1/deployments/{id}/events`                     |
| List projects                   | GET    | `/v9/projects`                                    |
| Get project                     | GET    | `/v9/projects/{idOrName}`                         |
| Create project                  | POST   | `/v9/projects`                                    |
| Update project                  | PATCH  | `/v9/projects/{idOrName}`                         |
| Delete project                  | DELETE | `/v9/projects/{idOrName}`                         |
| List env vars                   | GET    | `/v9/projects/{idOrName}/env`                     |
| Create env var(s)               | POST   | `/v10/projects/{idOrName}/env`                    |
| Edit env var                    | PATCH  | `/v9/projects/{idOrName}/env/{id}`                |
| Delete env var                  | DELETE | `/v9/projects/{idOrName}/env/{id}`                |
| List deployment aliases         | GET    | `/v6/deployments/{id}/aliases`                    |
| Assign domain to project        | POST   | `/v9/projects/{idOrName}/domains`                 |
| Remove domain from project      | DELETE | `/v9/projects/{idOrName}/domains/{domain}`        |
| List teams                      | GET    | `/v2/teams`                                       |
