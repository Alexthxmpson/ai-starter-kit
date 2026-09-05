# Linear API — Technical Reference

**Source:** https://developers.linear.app/docs/graphql/working-with-the-graphql-api
**Source:** https://developers.linear.app/docs/sdk/getting-started
**Date:** 2026-02-27

---

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
   - [Personal API Keys](#personal-api-keys)
   - [OAuth 2.0](#oauth-20)
3. [GraphQL Endpoint](#graphql-endpoint)
4. [Making Requests](#making-requests)
5. [Queries](#queries)
   - [Issues](#issues)
   - [Teams](#teams)
   - [Projects](#projects)
   - [Cycles](#cycles)
   - [Labels](#labels)
   - [Users](#users)
6. [Mutations](#mutations)
   - [createIssue (issueCreate)](#createissue-issuecreate)
   - [updateIssue (issueUpdate)](#updateissue-issueupdate)
   - [createComment (commentCreate)](#createcomment-commentcreate)
7. [Filtering](#filtering)
8. [Pagination](#pagination)
9. [Webhooks](#webhooks)
10. [Linear SDK (JavaScript / TypeScript)](#linear-sdk-javascript--typescript)
11. [Rate Limits](#rate-limits)

---

## Overview

Linear's public API is a GraphQL API — the same API Linear uses internally for its own applications. It gives full read and write access to all Linear entities: issues, teams, projects, cycles, labels, users, comments, and more.

The API is schema-driven. You can explore the full schema at:
https://studio.apollographql.com/public/Linear-API/schema/reference?variant=current

---

## Authentication

Linear supports two authentication methods: **personal API keys** and **OAuth 2.0**.

### Personal API Keys

Best for personal scripts, internal tooling, and automation where a single user's access is sufficient.

**Generate a key:**
Linear Settings → API → Personal API Keys → Create Key

**Usage:**

```http
POST https://api.linear.app/graphql
Authorization: Bearer lin_api_xxxxxxxxxxxxxxxxxxxx
Content-Type: application/json
```

- All requests with the same key share the same rate-limit quota.
- API keys are scoped to the user who created them.

---

### OAuth 2.0

Recommended for applications that act on behalf of other users. As of October 1, 2025, all newly created OAuth apps issue refresh tokens by default. Apps created before that date have until April 1, 2026 to migrate.

**Step 1 — Register your app**

Go to Linear Settings → API → OAuth Applications → Create new application. You will receive a `client_id` and `client_secret`.

**Step 2 — Redirect user to authorization**

```
GET https://linear.app/oauth/authorize
  ?client_id=YOUR_CLIENT_ID
  &redirect_uri=YOUR_REDIRECT_URI
  &response_type=code
  &scope=read,write
  &state=RANDOM_STATE_VALUE
```

**Available scopes:**

| Scope | Description |
|---|---|
| `read` | Read access to all resources |
| `write` | Write access to all resources |
| `initiative:read` | Read access to initiatives |
| `initiative:write` | Write access to initiatives |
| `customer:read` | Read access to customers |
| `customer:write` | Write access to customers |

Linear also supports the **PKCE flow** for public clients and the **client_credentials grant** for server-to-server communication.

**Step 3 — Exchange authorization code for tokens**

```http
POST https://api.linear.app/oauth/token
Content-Type: application/x-www-form-urlencoded

code=AUTHORIZATION_CODE
&client_id=YOUR_CLIENT_ID
&client_secret=YOUR_CLIENT_SECRET
&redirect_uri=YOUR_REDIRECT_URI
&grant_type=authorization_code
```

**Response:**

```json
{
  "access_token": "lat_xxxxxxxxxxxx",
  "refresh_token": "lrt_xxxxxxxxxxxx",
  "token_type": "Bearer",
  "expires_in": 86400,
  "scope": "read,write"
}
```

- Access tokens expire in 24 hours.
- Use the refresh token to obtain a new access token without requiring the user to re-authorize.

**Step 4 — Refresh the access token**

```http
POST https://api.linear.app/oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token
&refresh_token=lrt_xxxxxxxxxxxx
&client_id=YOUR_CLIENT_ID
&client_secret=YOUR_CLIENT_SECRET
```

**Revoke a token:**

```http
POST https://api.linear.app/oauth/revoke
Content-Type: application/x-www-form-urlencoded

access_token=lat_xxxxxxxxxxxx
```

---

## GraphQL Endpoint

All GraphQL operations (queries and mutations) go to a single endpoint:

```
https://api.linear.app/graphql
```

**Required headers:**

| Header | Value |
|---|---|
| `Authorization` | `Bearer <token>` |
| `Content-Type` | `application/json` |

---

## Making Requests

All requests are HTTP POST with a JSON body containing a `query` string and optional `variables` object.

**Raw HTTP example:**

```http
POST https://api.linear.app/graphql
Authorization: Bearer lin_api_xxxxxxxxxxxx
Content-Type: application/json

{
  "query": "query { viewer { id name email } }",
  "variables": {}
}
```

**curl example:**

```bash
curl -X POST https://api.linear.app/graphql \
  -H "Authorization: Bearer lin_api_xxxxxxxxxxxx" \
  -H "Content-Type: application/json" \
  -d '{"query":"query { viewer { id name email } }"}'
```

**Response envelope:**

```json
{
  "data": {
    "viewer": {
      "id": "user_abc123",
      "name": "Alexander Thompson",
      "email": "alexander@example.com"
    }
  }
}
```

---

## Queries

### Issues

**Fetch all issues (first 50):**

```graphql
query GetIssues {
  issues(first: 50) {
    nodes {
      id
      identifier
      title
      description
      priority
      state {
        id
        name
        type
      }
      assignee {
        id
        name
        email
      }
      team {
        id
        name
        key
      }
      labels {
        nodes {
          id
          name
          color
        }
      }
      createdAt
      updatedAt
      archivedAt
      dueDate
      estimate
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

**Fetch a single issue by ID:**

```graphql
query GetIssue($id: String!) {
  issue(id: $id) {
    id
    identifier
    title
    description
    priority
    url
    state {
      name
      type
    }
    assignee {
      name
    }
    comments {
      nodes {
        id
        body
        user {
          name
        }
        createdAt
      }
    }
  }
}
```

Variables:

```json
{ "id": "ISS-123" }
```

**Fetch issues assigned to the current user:**

```graphql
query MyIssues {
  viewer {
    assignedIssues(first: 25) {
      nodes {
        id
        identifier
        title
        state {
          name
        }
        priority
        dueDate
      }
    }
  }
}
```

---

### Teams

**List all teams:**

```graphql
query GetTeams {
  teams {
    nodes {
      id
      name
      key
      description
      color
      icon
      states {
        nodes {
          id
          name
          type
          position
        }
      }
      labels {
        nodes {
          id
          name
          color
        }
      }
      members {
        nodes {
          id
          name
          email
        }
      }
    }
  }
}
```

**Fetch a single team:**

```graphql
query GetTeam($id: String!) {
  team(id: $id) {
    id
    name
    key
    issueCount
    triageEnabled
    defaultIssueState {
      id
      name
    }
  }
}
```

---

### Projects

**List all projects:**

```graphql
query GetProjects {
  projects(first: 50) {
    nodes {
      id
      name
      description
      state
      progress
      startDate
      targetDate
      lead {
        id
        name
      }
      teams {
        nodes {
          id
          name
        }
      }
      members {
        nodes {
          id
          name
        }
      }
      issues {
        nodes {
          id
          title
          state {
            name
          }
        }
      }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

---

### Cycles

**List cycles for a team:**

```graphql
query GetCycles($teamId: String!) {
  team(id: $teamId) {
    cycles(first: 10) {
      nodes {
        id
        number
        name
        startsAt
        endsAt
        completedAt
        progress
        issues {
          nodes {
            id
            title
            state {
              name
            }
          }
        }
      }
    }
  }
}
```

**Get the active cycle for a team:**

```graphql
query GetActiveCycle($teamId: String!) {
  team(id: $teamId) {
    activeCycle {
      id
      number
      name
      startsAt
      endsAt
      progress
      completedIssueCount
      issueCount
    }
  }
}
```

---

### Labels

**List all labels for a workspace:**

```graphql
query GetLabels {
  issueLabels {
    nodes {
      id
      name
      color
      description
      team {
        id
        name
      }
    }
  }
}
```

---

### Users

**List all workspace members:**

```graphql
query GetUsers {
  users {
    nodes {
      id
      name
      displayName
      email
      avatarUrl
      active
      admin
      createdAt
    }
  }
}
```

**Get the currently authenticated user:**

```graphql
query GetViewer {
  viewer {
    id
    name
    email
    displayName
    organization {
      id
      name
      urlKey
    }
  }
}
```

---

## Mutations

### createIssue (issueCreate)

Creates a new issue. The only required fields are `title` and `teamId`.

```graphql
mutation CreateIssue($input: IssueCreateInput!) {
  issueCreate(input: $input) {
    success
    issue {
      id
      identifier
      title
      url
    }
  }
}
```

**Variables — full example:**

```json
{
  "input": {
    "title": "Fix login page redirect bug",
    "description": "After OAuth login the user is redirected to `/` instead of the original destination. Reproduce by visiting `/dashboard` while logged out.",
    "teamId": "team_abc123",
    "stateId": "state_xyz789",
    "assigneeId": "user_def456",
    "priority": 2,
    "labelIds": ["label_aaa111", "label_bbb222"],
    "projectId": "project_ggg333",
    "estimate": 3,
    "dueDate": "2026-03-15"
  }
}
```

**Priority values:**

| Value | Meaning |
|---|---|
| `0` | No priority |
| `1` | Urgent |
| `2` | High |
| `3` | Medium |
| `4` | Low |

If `stateId` is omitted, the issue is placed in the team's first Backlog state (or Triage if enabled).

---

### updateIssue (issueUpdate)

Updates an existing issue by ID. Only pass the fields you want to change.

```graphql
mutation UpdateIssue($id: String!, $input: IssueUpdateInput!) {
  issueUpdate(id: $id, input: $input) {
    success
    issue {
      id
      identifier
      title
      state {
        name
      }
      assignee {
        name
      }
    }
  }
}
```

**Variables:**

```json
{
  "id": "issue_abc123",
  "input": {
    "title": "Fix login page redirect bug (updated)",
    "stateId": "state_in_progress",
    "assigneeId": "user_new456",
    "priority": 1,
    "dueDate": "2026-03-10",
    "estimate": 5
  }
}
```

**Archive an issue:**

```json
{
  "id": "issue_abc123",
  "input": {
    "archived": true
  }
}
```

---

### createComment (commentCreate)

Adds a comment to an issue.

```graphql
mutation CreateComment($input: CommentCreateInput!) {
  commentCreate(input: $input) {
    success
    comment {
      id
      body
      createdAt
      user {
        id
        name
      }
    }
  }
}
```

**Variables:**

```json
{
  "input": {
    "issueId": "issue_abc123",
    "body": "Investigated the redirect issue. The problem is in `AuthCallback.tsx` line 42 — `returnTo` param is not being passed through the OAuth state. PR incoming."
  }
}
```

---

## Filtering

Most paginated list queries accept a `filter` argument. Filters support field comparisons, relational filters, and `and`/`or` logical operators.

**Filter issues by assignee and state:**

```graphql
query FilteredIssues {
  issues(
    filter: {
      assignee: { email: { eq: "alexander@example.com" } }
      state: { type: { eq: "started" } }
    }
    first: 25
  ) {
    nodes {
      id
      identifier
      title
      priority
    }
  }
}
```

**Filter by priority:**

```graphql
query HighPriorityIssues {
  issues(
    filter: {
      priority: { lte: 2 }
      state: { type: { nin: ["completed", "cancelled"] } }
    }
    first: 50
  ) {
    nodes {
      id
      title
      priority
    }
  }
}
```

**Filter by label:**

```graphql
query BugIssues {
  issues(
    filter: {
      labels: { name: { eq: "Bug" } }
    }
    first: 50
  ) {
    nodes {
      id
      title
    }
  }
}
```

**Filter by date (relative ISO 8601 duration):**

```graphql
query RecentIssues {
  issues(
    filter: {
      createdAt: { gt: "-P7D" }
    }
    orderBy: createdAt
    first: 50
  ) {
    nodes {
      id
      title
      createdAt
    }
  }
}
```

`-P7D` means "7 days ago". All date fields support relative ISO 8601 durations.

**Supported comparison operators:**

| Operator | Meaning |
|---|---|
| `eq` | Equal |
| `neq` | Not equal |
| `in` | In list |
| `nin` | Not in list |
| `lt` | Less than |
| `lte` | Less than or equal |
| `gt` | Greater than |
| `gte` | Greater than or equal |
| `contains` | String contains |
| `startsWith` | String starts with |
| `endsWith` | String ends with |

**Logical operators:**

```graphql
filter: {
  and: [
    { state: { type: { eq: "started" } } },
    { priority: { lte: 2 } }
  ]
}
```

---

## Pagination

Linear uses **Relay-style cursor-based pagination**. Paginated queries accept `first`/`after` (forward) or `last`/`before` (backward) arguments.

**Forward pagination pattern:**

```graphql
query PaginatedIssues($cursor: String) {
  issues(first: 50, after: $cursor) {
    nodes {
      id
      title
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

**Iteration logic (TypeScript):**

```typescript
let cursor: string | undefined = undefined;
let hasNextPage = true;
const allIssues: Issue[] = [];

while (hasNextPage) {
  const result = await client.issues({
    first: 50,
    after: cursor,
    filter: { state: { type: { eq: "started" } } }
  });

  allIssues.push(...result.nodes);
  hasNextPage = result.pageInfo.hasNextPage;
  cursor = result.pageInfo.endCursor ?? undefined;
}
```

**Ordering:**

- Default: `createdAt` descending
- Pass `orderBy: updatedAt` to sort by last updated

**Archived resources** are hidden from paginated responses by default. Pass `includeArchived: true` to include them.

---

## Webhooks

Webhooks deliver real-time push notifications when Linear data changes. Linear recommends webhooks over polling.

**Supported event types:**

- `Issue`
- `Comment`
- `IssueAttachment`
- `Document`
- `Reaction`
- `Project`
- `ProjectUpdate`
- `Cycle`
- `IssueLabel`
- `User`
- `IssueSLA`

### Create a Webhook

```graphql
mutation CreateWebhook($input: WebhookCreateInput!) {
  webhookCreate(input: $input) {
    success
    webhook {
      id
      url
      enabled
      resourceTypes
    }
  }
}
```

**Variables:**

```json
{
  "input": {
    "url": "https://yourapp.com/webhooks/linear",
    "teamId": "team_abc123",
    "resourceTypes": ["Issue", "Comment", "Project"],
    "enabled": true,
    "secret": "your_signing_secret"
  }
}
```

After creation, Linear shows the Webhook Secret **once**. Store it immediately in an environment variable.

### Webhook Payload Structure

```json
{
  "action": "create",
  "type": "Issue",
  "organizationId": "org_abc123",
  "teamId": "team_abc123",
  "webhookTimestamp": 1709030400000,
  "data": {
    "id": "issue_xyz789",
    "createdAt": "2026-02-27T12:00:00.000Z",
    "updatedAt": "2026-02-27T12:00:00.000Z",
    "title": "Fix login bug",
    "priority": 2,
    "state": {
      "id": "state_aaa",
      "name": "In Progress",
      "type": "started"
    },
    "assignee": {
      "id": "user_bbb",
      "name": "Alexander Thompson"
    },
    "team": {
      "id": "team_abc123",
      "name": "Engineering",
      "key": "ENG"
    }
  },
  "webhookId": "webhook_ccc"
}
```

**Action values:** `create`, `update`, `remove`

### Signature Verification

Every webhook request includes a `Linear-Signature` header containing an HMAC-SHA256 signature of the raw request body, signed with your webhook secret.

```typescript
import { createHmac, timingSafeEqual } from "crypto";

function verifyLinearWebhook(
  rawBody: string,
  signature: string,
  secret: string
): boolean {
  const expected = createHmac("sha256", secret)
    .update(rawBody)
    .digest("hex");

  return timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(expected)
  );
}

// Express handler example
app.post("/webhooks/linear", (req, res) => {
  const signature = req.headers["linear-signature"] as string;
  const rawBody = req.rawBody; // must use raw body, not parsed JSON

  if (!verifyLinearWebhook(rawBody, signature, process.env.LINEAR_WEBHOOK_SECRET!)) {
    return res.status(401).json({ error: "Invalid signature" });
  }

  const payload = JSON.parse(rawBody);

  // Guard against replay attacks — reject if timestamp is older than 60 seconds
  const ageMs = Date.now() - payload.webhookTimestamp;
  if (ageMs > 60_000) {
    return res.status(400).json({ error: "Webhook too old" });
  }

  // Process payload...
  console.log(`${payload.action} ${payload.type}:`, payload.data.id);
  res.json({ received: true });
});
```

Use `timingSafeEqual` — standard string comparison is vulnerable to timing attacks.

---

## Linear SDK (JavaScript / TypeScript)

The official SDK wraps the GraphQL API with fully typed models and auto-generated methods for every query and mutation.

**Installation:**

```bash
npm install @linear/sdk
# or
pnpm add @linear/sdk
# or
yarn add @linear/sdk
```

Requires Node.js v18+. The SDK is written in TypeScript but works in any JavaScript environment.

**Initialize with an API key:**

```typescript
import { LinearClient } from "@linear/sdk";

const client = new LinearClient({
  apiKey: process.env.LINEAR_API_KEY,
});
```

**Initialize with an OAuth access token:**

```typescript
const client = new LinearClient({
  accessToken: process.env.LINEAR_ACCESS_TOKEN,
});
```

### SDK Query Examples

```typescript
// Get the authenticated user
const me = await client.viewer;
console.log(me.name, me.email);

// Get all teams
const teamsResult = await client.teams();
for (const team of teamsResult.nodes) {
  console.log(team.name, team.key);
}

// Get issues for a team with filtering
const issuesResult = await client.issues({
  filter: {
    team: { key: { eq: "ENG" } },
    state: { type: { eq: "started" } },
    priority: { lte: 2 },
  },
  first: 50,
});

for (const issue of issuesResult.nodes) {
  console.log(`[${issue.identifier}] ${issue.title}`);
}

// Get a single issue with related data
const issue = await client.issue("issue_abc123");
const state = await issue.state;
const assignee = await issue.assignee;
const labels = await issue.labels();
console.log(state?.name, assignee?.name);
```

### SDK Mutation Examples

```typescript
// Create an issue
const createResult = await client.createIssue({
  title: "Investigate memory leak in worker process",
  description: "Worker process memory climbs over 6 hours without release.",
  teamId: "team_abc123",
  priority: 2,
  assigneeId: "user_def456",
  labelIds: ["label_bug"],
});

if (createResult.success) {
  const newIssue = await createResult.issue;
  console.log(`Created: ${newIssue?.identifier} — ${newIssue?.url}`);
}

// Update an issue
const updateResult = await client.updateIssue("issue_abc123", {
  stateId: "state_done",
  priority: 0,
});
console.log("Updated:", updateResult.success);

// Create a comment
const commentResult = await client.createComment({
  issueId: "issue_abc123",
  body: "Fixed in PR #412. Deployed to staging.",
});
console.log("Comment created:", commentResult.success);
```

### Running Raw GraphQL via the SDK

```typescript
const result = await client.client.rawRequest<{ issues: any }>(
  `query {
    issues(first: 10, filter: { priority: { eq: 1 } }) {
      nodes { id identifier title }
    }
  }`
);
console.log(result.data.issues.nodes);
```

---

## Rate Limits

| Auth Method | Limit |
|---|---|
| Authenticated (API key or OAuth) | 5,000 requests per hour |
| Unauthenticated | 60 requests per hour |

- Authenticated limits are **per user** — all API keys and tokens belonging to the same user share one quota.
- Unauthenticated limits are **per IP address**.
- When the limit is exceeded, Linear returns HTTP `429 Too Many Requests`.
- Check the `X-RateLimit-Remaining` and `X-RateLimit-Reset` response headers to track quota usage.

**Best practices:**
- Use filtering in your GraphQL queries rather than fetching everything and filtering in code.
- Batch multiple fields into a single query instead of making multiple round trips.
- Use webhooks for real-time updates instead of polling.
- Implement exponential backoff when you receive a 429 response.
