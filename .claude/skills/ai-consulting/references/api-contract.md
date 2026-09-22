# Client Context API (contract v1)

Base URL: `https://alexander-clients.vercel.app` (production) or any preview URL of the `alexander-clients` Vercel project.
Endpoint: `/api/context`. Auth: `Authorization: Bearer <token>`. Every response is JSON with `Cache-Control: no-store`.

This is the contract that C6 (client builds) and P3 (the `/ai-consulting` client skill) build against. Add fields freely; never rename or remove one without bumping this file.

## Token

- 40 characters, `[A-Za-z0-9]`, stored in 👤 Clients `API Token`, issue time in `API Token Created`.
- Issued or rotated by an admin: `POST /api/auth {"op":"token-issue","clientId":"rec…"}` with the admin session cookie. The token is returned once in the response and never again. Issuing again rotates: the old token stops working immediately.
- Revoked by `POST /api/auth {"op":"token-revoke","clientId":"rec…"}`. Both fields are cleared.
- A token only works while the client's `Portal Access Enabled` box is ticked. Unticking it returns `401 {"error":"Access disabled"}` without touching the token.
- Lookup is a `filterByFormula` equality on `API Token` followed by a constant-time byte comparison (`crypto.timingSafeEqual`) of the returned value. Malformed tokens (wrong length or alphabet) are rejected before any lookup.

## Rate limit and lockout

State lives in 🔐 Auth Log rows with `Role = api`. Only failures are logged: `Result = FAIL` for a bad, revoked, malformed or disabled token, `Result = LOCKED` for a request refused by the lock. `Username` is `api:<12 hex chars of sha256(token)>` so the log never holds token material. Successful requests are not logged.

Lock rule: 30 `FAIL` rows in 15 minutes, counted per token handle **or** per client IP, refuses every request from that handle or IP with `429` until the window passes. Every failed or locked request is also delayed by 300 ms. Verified 2026-09-22: 31 attempts with one bad token from one IP gave 27 x 401 then 429 (three earlier failures from the same IP counted toward the IP cap).

## GET /api/context

Query parameters (both optional):

| Param | Meaning |
|---|---|
| `since=<ISO date>` | `calls` and `actionItems` are filtered to records whose Airtable `LAST_MODIFIED_TIME()` is after the date. Every other section is unaffected. Invalid dates return `400`. |
| `section=<a,b,c>` | Return only these sections: `calls`, `items`, `onboarding`, `roadmap`, `prds`, `deliverables`, `resources`, `recaps`. Comma separated. Unknown names return `400` with the list. |

`client`, `generatedAt`, `since` and `sections` are always present.

```json
{
  "client": {
    "id": "rec…", "name": "David Junghanns", "company": "Leon Media", "status": "Active",
    "phase": "Install", "term": 3, "startDate": "2026-09-14", "endDate": "2026-12-14",
    "goals": "…", "tokenCreated": "2026-09-22T12:56:51.374Z", "onboardingSubmittedAt": "2026-09-14T…"
  },
  "calls": [{
    "id": "rec…", "date": "2026-09-19T10:00:00.000Z", "title": "Kickoff", "era": "AI Consulting",
    "durationMin": 58, "summary": "…", "takeaways": "…", "clientActionItems": "…",
    "myActionItems": "…", "buildsDiscussed": "…", "clientNotes": null,
    "recordingUrl": "https://fathom.video/calls/…"
  }],
  "actionItems": [{
    "id": "rec…", "item": "Send the Notion export", "status": "Open", "owner": "Client",
    "due": "2026-09-26", "source": "Call", "notes": null, "created": "2026-09-19T…", "callId": "rec…"
  }],
  "roadmap": [{ "id": "rec…", "week": 1, "theme": "Install", "focus": "…", "status": "Current", "weekStart": "2026-09-15" }],
  "prds": [{ "id": "rec…", "title": "…", "status": "Approved", "priority": "P1", "body": "…", "decided": "2026-09-20" }],
  "deliverables": [{ "id": "rec…", "name": "…", "type": "Build", "status": "Delivered", "description": "…", "url": "https://…", "delivered": "2026-09-21" }],
  "onboarding": {
    "Your business & team": { "Company / brand name": "Leon Media", "…": "…" },
    "Tools, access & documents": { "Accounts we will likely need access to": "GHL login: [REDACTED] password: [REDACTED]" }
  },
  "resources": [{ "id": "rec…", "name": "…", "type": "Guide", "url": "https://…", "description": "…" }],
  "weeklyRecaps": [{ "id": "rec…", "title": "Week of 2026-09-21", "weekOf": "2026-09-21", "body": "…" }],
  "generatedAt": "2026-09-22T13:00:00.000Z",
  "since": null,
  "sections": ["calls", "items", "onboarding", "roadmap", "prds", "deliverables", "resources", "recaps"]
}
```

Rules baked into the shaping:

- **Calls never include the transcript.** Summary, takeaways, the two action-item blocks, builds discussed, client notes and the recording URL only. Sorted newest first. `consultant` is reserved (not populated yet: 📞 Calls has no consultant field).
- **actionItems** sorted Open first, then newest. Includes both owners (`Client` and `Alexander`).
- **prds** are only `Approved` or `Built`, the same rule as the portal. Drafts and items awaiting approval stay internal.
- **onboarding** is the latest 📥 Onboarding Submission for the client, shaped as `{ sectionLabel: { question: answer } }` from `Raw JSON` (fallback: the section text fields split on blank lines). Every answer passes the same two regexes as `scripts/export_client_briefs.py redact()`: `password|passwd|pwd|pass|api key|secret|token|login` followed by `is`, `:` or `=` gets `[REDACTED]`; key-shaped strings (`sk-…`, `pat….`, `eyJ…`, `ghp_…`, `xox…`, `pit-…`) get `[REDACTED-KEY]`. Airtable keeps the originals. Applied to all sections, not just Platform Access & Keys and Stack & Documents.
- **resources** are rows with `Audience = Client-facing` or linked to the client via `Related Clients`.
- **roadmap** sorted by week, **weeklyRecaps** newest first.

## POST /api/context

Same bearer. Body is JSON, max 16 KB.

| Body | Effect | Response |
|---|---|---|
| `{"op":"item-done","id":"rec…"}` | Sets the client's own ✅ Action Item to `Done`. Items of other clients (or unknown ids) return `404 Item not found`. Idempotent. | `{"ok":true,"id":"rec…","status":"Done"}` |
| `{"op":"log","text":"…"}` | Appends a 📨 Requests row: `Source = API`, `Status = New`, `Request` = first 90 chars, `Raw Message` = full text (10 k cap), linked to the client. Pings the ops Discord webhook when configured. | `{"ok":true,"id":"rec…"}` |

Anything else: `400 {"error":"unknown op"}`.

## Errors

| Code | When |
|---|---|
| 400 | bad `since`, unknown `section`, missing `id`/`text`, unknown op |
| 401 | no `Authorization` header, malformed/unknown/revoked token, `Portal Access Enabled` off |
| 404 | `item-done` on an item that is not the client's |
| 405 | method other than GET/POST |
| 413 | POST body over 16 KB |
| 429 | lockout (see above) |
| 500 | Airtable unreachable (`Auth temporarily unavailable`) or an unexpected error |

## Deployment note

The Vercel Hobby plan caps a deployment at 12 serverless functions and `api/` already had 12. The handler therefore lives in `api/_context.js` (underscore files are not deployed as functions) and `vercel.json` rewrites `/api/context` to `/api/auth?_route=context`; `api/auth.js` dispatches to it before its admin check. The public path is `/api/context` and nothing else should depend on the rewrite. Any further endpoint needs the same treatment or a plan upgrade.

## Curl cheat sheet

```bash
T=…40 chars…
curl -s https://alexander-clients.vercel.app/api/context -H "Authorization: Bearer $T"
curl -s "https://alexander-clients.vercel.app/api/context?section=items,calls&since=2026-09-01" -H "Authorization: Bearer $T"
curl -s -X POST https://alexander-clients.vercel.app/api/context -H "Authorization: Bearer $T" \
  -H 'Content-Type: application/json' -d '{"op":"item-done","id":"rec…"}'
curl -s -X POST https://alexander-clients.vercel.app/api/context -H "Authorization: Bearer $T" \
  -H 'Content-Type: application/json' -d '{"op":"log","text":"Shipped the intake bot, want a review Friday"}'
```
