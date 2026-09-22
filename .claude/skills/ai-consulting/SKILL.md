---
name: ai-consulting
description: Sync a client's repo with Alexander Alberts' consulting portal. Pulls the latest call, action items, roadmap, onboarding answers and approved builds into context/ai-consulting/, turns call outcomes into skills, context and SOPs in the repo (apply), works from a pasted transcript when there is no token yet, and writes item completions and notes back to the portal.
---

# /ai-consulting playbook

You are working inside a client's own command center (a repo built from Alexander's starter kit, or any repo). Alexander is their AI consultant; the portal at `https://alexander-clients.vercel.app` holds everything about the engagement. This skill keeps the repo and the portal in step.

Helper: `python3 .claude/skills/ai-consulting/scripts/aic_portal.py` (urllib only, nothing to install). API contract: `references/api-contract.md`. Generated file layout: `references/file-formats.md`. How to turn a call into repo changes: `references/apply-playbook.md`.

## 0. Preconditions (every run)

- Working directory is the repo root (where `.env` and `.claude/` live). If not, `cd` there first.
- `python3 --version` is 3.8 or newer.
- Token: `.env` has `AIC_PORTAL_TOKEN` (40 chars, `[A-Za-z0-9]`). Missing: run the first-run flow from `.claude/commands/ai-consulting.md`. The token is a secret. It goes to `.env` through `aic_portal.py setup`, nowhere else.
- Optional `AIC_PORTAL_URL` in `.env` overrides the portal host (Alexander uses this for previews).

## 1. `pull` (default mode)

```
python3 .claude/skills/ai-consulting/scripts/aic_portal.py pull
```

Writes into `context/ai-consulting/`:

| File | Holds |
|---|---|
| `latest-call.md` | Most recent call: summary, takeaways, my action items, Alexander's action items, builds discussed, recording link, plus one-liners for the 7 calls before it |
| `action-items.md` | Open items first, then the last 25 done, each with its portal `id` |
| `roadmap.md` | Week-by-week plan with the current week marked |
| `onboarding.md` | My onboarding answers by section (credentials redacted server-side) |
| `builds.md` | Approved build specs, delivered builds, client resources, last 3 weekly recaps |
| `context.json`, `.state.json` | Raw payload and last-pull time (used by `--refresh`) |

`pull --refresh` asks only for calls and items changed since the last pull (minus a 5-minute margin) and merges them into the cached payload. Use plain `pull` when in doubt; the full payload is small.

After a pull, give the user this briefing and nothing longer:

1. Who and where: name, phase, week N of M, days left.
2. Latest call: title, date, one-sentence summary.
3. My open items: count, and the top 3 by due date with their ids.
4. Alexander's open items: count, top 2.
5. Anything new since the last pull (compare `.state.json` lastPull with item `created` and call `date`). First pull: say so.
6. Suggested next step: usually `/ai-consulting apply` when there are open client items, else the current roadmap focus.

## 2. `apply`

Goal: the call's outcomes exist in the repo as working things, not as a to-do list. Read `references/apply-playbook.md`, then:

1. If `context/ai-consulting/.state.json` is missing or `lastPull` is older than 24 hours, `pull` first.
2. Read `latest-call.md`, `action-items.md`, `builds.md` (approved specs), and the repo's `CLAUDE.md` plus `context/` so proposals fit how this repo is organised.
3. Classify every **open, Client-owned** action item and every entry in "Builds discussed" into one of: `skill` (a new or edited `.claude/commands/*.md`), `context` (a fact about the business into `context/business/*` or `CLAUDE.md`), `sop` (a process into `docs/sops/<slug>.md`), `project` (a build folder under `projects/<slug>/` with a spec.md), `human` (needs the user to act outside the repo), `alexander` (waiting on Alexander).
4. Present ONE plan table and stop:

   | # | item (id) | change | file(s) | closes item? |

   Show the intended content in a sentence per row. Ask: "Apply all, or tell me the numbers to skip?"
5. On approval: create or edit the files. Keep the repo's conventions (skill files follow the shape of the existing ones in `.claude/commands/`; SOPs are numbered steps with an owner and a trigger). No em dashes. Do not invent facts: anything the call did not say goes in as a `TODO(confirm)` line for the user.
6. Mark done ONLY items whose closing change is now in the repo: `aic_portal.py done <id> <id>`. `human` and `alexander` items stay open; list them.
7. `aic_portal.py log "<one line: what changed, which items closed>"`. Alexander reads these before the next call.
8. Offer `/handoff` if the repo has it.

Paste mode (no token) runs the same steps from the local files, skipping 6 and 7, and ends with: "When you have a token, run `/ai-consulting` once and I will sync these items."

## 3. `paste`

For a transcript the portal does not have yet (or before a token exists).

1. Ask for the transcript. Accept pasted text or a file path. Save it: `aic_portal.py paste <path>` or pipe the text to `aic_portal.py paste -`.
2. Read `context/ai-consulting/latest-call.md`. Replace the `_pending_` block under "Extracted" with: **Summary** (5 lines max), **Takeaways** (bullets), **My action items** (bullets, each with an owner and a due date if the call gave one), **Alexander's action items**, **Builds discussed**.
3. Append the extracted client items to `action-items.md` under "Open" with `id` = `(pasted)`.
4. Say what you extracted and offer `apply`.

## 4. `done`, `log`, `status`

- `done <id> [...]`: the helper refuses non-`rec…` ids and reports `404` for items that are not the user's.
- `log "<text>"`: one note per run; keep it under 500 characters; it is a message to a person.
- `status`: prints the client name, phase and open-item count, or the exact error.

## Failure handling

| Symptom | Do |
|---|---|
| `No valid AIC_PORTAL_TOKEN` | First-run flow (ask for the token, `setup`). |
| `401` | Token revoked, rotated or mistyped. Ask the user to get a fresh one from Alexander; never retry more than twice. |
| `429` | Locked for 15 minutes after 30 failures from this token or IP. Stop, tell the user the time, do not loop. |
| `Cannot reach the portal` | Network or a wrong `AIC_PORTAL_URL`. Check `.env`, retry once. |
| Files exist but look stale | `pull` (full). |

## Never

- Commit `.env` or paste the token into any file, message, or handoff.
- Edit generated files by hand.
- Mark an item done that the user still has to do in the real world.
- Send transcripts anywhere; they stay local.
