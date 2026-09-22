# Generated files in `context/ai-consulting/`

All five markdown files start with an HTML comment naming the portal URL and the `generatedAt` time. Re-running `pull` overwrites them. Never hand-edit; the next pull would erase the edit.

## latest-call.md
```
# Latest call
**<title>** on YYYY-MM-DD (<n> min)
Recording: <url>
Portal id: `rec…`
## Summary / ## Takeaways / ## My action items (the client) / ## Alexander's action items / ## Builds discussed / ## My notes
## Previous calls
- YYYY-MM-DD **<title>**: <first 220 chars of summary>
```
In paste mode the file is instead: a "Filed" line, an "## Extracted" block (filled by the skill) and "## Transcript" with the raw text.

## action-items.md
Two tables, `## Open (n)` then `## Done (n)` (last 25), columns `id | item | owner | due | source`. Owner is `Client` (the user) or `Alexander`. `id` is the portal record id used by `done`. Items extracted from a pasted transcript carry `(pasted)` as id.

## roadmap.md
Program line (term, start, end, phase) then a table `week | starts | theme | status | focus`; the current week's status is `**Current**`.

## onboarding.md
One `## <section>` per onboarding section, then `**question**` / answer pairs. Credentials are already `[REDACTED]` by the server.

## builds.md
`## Approved build specs` (title, priority, status, full body), `## Delivered` (name, type, status, url), `## Resources` (client-facing links from Alexander), `## Weekly recaps` (last 3).

## context.json and .state.json
`context.json` is the raw API payload (see `api-contract.md`). `.state.json` holds `lastPull`, `client`, `portal`; `pull --refresh` uses `lastPull` minus 5 minutes as the `since` cutoff.
