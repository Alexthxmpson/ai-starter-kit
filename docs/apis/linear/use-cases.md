# Linear API — Use Cases & Practical Summary

**Source:** https://developers.linear.app/docs/graphql/working-with-the-graphql-api
**Source:** https://developers.linear.app/docs/sdk/getting-started
**Date:** 2026-02-27

---

## What the Linear API Can Do

The Linear GraphQL API gives you full programmatic access to your Linear workspace. With it you can:

- Read and write issues (create, update, archive, prioritize, assign)
- Manage teams, projects, and cycles
- Add comments and reactions
- Manage labels and workflow states
- Query users and organization members
- Receive real-time event notifications via webhooks
- Build integrations that keep Linear in sync with external systems

---

## Project Ideas

| Project | What It Does | Key API Operations |
|---|---|---|
| **GitHub PR to Linear Issue Sync** | When a PR is merged, automatically close the linked Linear issue and post a comment with the PR URL | `issueUpdate` (stateId), `commentCreate` |
| **Slack Daily Standup Bot** | Posts each team member's assigned in-progress issues every morning at 9am | `viewer.assignedIssues`, filter by state type `started` |
| **Automated Sprint Loader** | At the start of each cycle, pulls backlog issues tagged with a sprint label and moves them to the active cycle | `issues` query + filter, `issueUpdate` (cycleId) |
| **Issue Triage Webhook Handler** | Listens for new issues created without assignees and routes them to the correct team member based on label rules | Webhooks (`Issue` create events), `issueUpdate` |
| **Bug Priority Escalator** | Scans open bug issues daily; if a bug is older than 3 days with no activity, bumps priority to Urgent | `issues` filter by label + `updatedAt`, `issueUpdate` (priority: 1) |
| **Project Progress Dashboard** | Builds a read-only dashboard showing cycle completion %, burndown, and open vs closed ratios | `cycles`, `projects` queries |
| **Linear → Notion Export** | Exports all completed issues from the past sprint to a Notion database for retrospectives | `issues` filter by state + cycle, Notion API |
| **Customer Feedback to Issue** | Takes Typeform/Stripe webhook events, creates Linear issues automatically with structured descriptions | `issueCreate` with description template |
| **Cross-Workspace Issue Mirror** | Keeps issues in sync between two Linear workspaces (e.g., internal + client-facing) | Webhooks + `issueCreate`/`issueUpdate` in both workspaces |
| **Slack Slash Command: /linear** | `/linear create [title]` creates a Linear issue from Slack; `/linear me` shows your open issues | Slack slash commands + `issueCreate`, `viewer.assignedIssues` |
| **SLA Breach Alerter** | Monitors issues with due dates; sends alerts when an issue is at risk of breaching SLA | Webhooks (`IssueSLA`), `issues` filter by `dueDate` |
| **Label-Based Auto-Assignment** | When a label like "backend" is added to an issue, automatically assign it to the on-call backend engineer | Webhooks (`Issue` update events), `issueUpdate` (assigneeId) |

---

## Key Limits and Quotas

| Limit | Value |
|---|---|
| Authenticated rate limit | 5,000 requests / hour |
| Unauthenticated rate limit | 60 requests / hour |
| Rate limit scope (API key) | Per user — all keys for the same user share one quota |
| Rate limit scope (unauthenticated) | Per IP address |
| Error code when exceeded | HTTP 429 Too Many Requests |
| OAuth access token lifetime | 24 hours |
| Pagination max per request | Varies; `first` max is typically 250 |
| Archived resources in results | Hidden by default — use `includeArchived: true` |
| Webhook timestamp tolerance (recommended) | Reject payloads older than 60 seconds |

---

## Gotchas and Things to Know

**Mutations use different naming than expected.**
The GraphQL mutation names are `issueCreate`, `issueUpdate`, and `commentCreate` — not `createIssue`, `updateIssue`, or `createComment`. The SDK methods (`client.createIssue()`) do use the intuitive names, but raw GraphQL queries must use the API names.

**Teams are required for issue creation.**
You cannot create an issue without a `teamId`. You must first query your teams to get the correct ID before creating issues. Hard-coding team names can break if names change — always use IDs.

**State IDs are team-specific.**
Workflow states (Backlog, In Progress, Done, etc.) belong to individual teams. A `stateId` valid for Team A will not work for Team B. Query the team's states before setting `stateId`.

**Priority is a number, not a string.**
Priority is `0` (none), `1` (urgent), `2` (high), `3` (medium), `4` (low). Many integrations make the mistake of passing strings like `"high"`.

**OAuth tokens expire after 24 hours.**
If your app uses OAuth and you do not implement token refresh, users will be silently de-authorized the next day. Store the refresh token and call the refresh endpoint before expiry.

**Webhook secrets are shown only once.**
After creating a webhook via the API or UI, the signing secret is displayed exactly once. If you miss it, you must delete and recreate the webhook.

**Verify webhook signatures with timingSafeEqual.**
Standard string comparison (`===`) is vulnerable to timing attacks. Use Node's `crypto.timingSafeEqual` or an equivalent constant-time comparison function.

**Raw body is required for webhook verification.**
Express and similar frameworks parse the request body into an object before your handler runs, which breaks HMAC verification. You must capture the raw bytes before parsing. Use `express.raw({ type: 'application/json' })` for webhook routes or a custom middleware.

**Polling is discouraged.**
Linear explicitly recommends against polling the API for updates. Use webhooks instead for event-driven architectures.

**Archived issues are excluded by default.**
Paginated queries do not return archived issues unless you pass `includeArchived: true`. If your integration tracks all historical issues, add this flag.

**Filter in GraphQL, not in code.**
Fetching all issues and filtering them in your application wastes your rate-limit quota. Use the `filter` argument in your queries so Linear does the filtering server-side.

**Cursor-based pagination — store endCursor, not page numbers.**
Linear uses cursor-based pagination, not offset-based. There is no concept of "page 2." You must pass the `endCursor` from `pageInfo` as the `after` argument in the next request.

**SDK lazy-loads related entities.**
When using the SDK, related entities (e.g., `issue.assignee`, `issue.state`) are not fetched automatically — they return a Promise that resolves lazily. Call `await issue.assignee` to get the actual object. For bulk operations, prefer a raw GraphQL query that fetches everything in one round trip.

**Rate limit is per user, not per key.**
If you have multiple API keys for the same Linear user, they all share the same 5,000 request/hour quota. For high-throughput integrations, you may need separate Linear users (e.g., a dedicated bot/service account).

---

## Quick Reference: Common Patterns

**Get team ID by key:**

```typescript
const teams = await client.teams();
const engineering = teams.nodes.find(t => t.key === "ENG");
const teamId = engineering!.id;
```

**Get state ID by name:**

```typescript
const team = await client.team(teamId);
const states = await team.states();
const inProgressState = states.nodes.find(s => s.name === "In Progress");
const stateId = inProgressState!.id;
```

**Create an issue and get its URL:**

```typescript
const result = await client.createIssue({
  title: "Fix auth redirect",
  teamId,
  stateId,
  priority: 2,
});
const issue = await result.issue;
console.log(issue?.url); // https://linear.app/yourorg/issue/ENG-42
```

**Iterate all pages of results:**

```typescript
let cursor: string | undefined;
let hasNextPage = true;

while (hasNextPage) {
  const page = await client.issues({ first: 50, after: cursor });
  // process page.nodes...
  hasNextPage = page.pageInfo.hasNextPage;
  cursor = page.pageInfo.endCursor ?? undefined;
}
```
