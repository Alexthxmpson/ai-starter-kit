# AI Consulting: sync with Alexander's portal

Pull my consulting context (latest call, action items, roadmap, onboarding answers, approved builds) from Alexander's client portal into this repo, turn call outcomes into concrete changes here, and report back. Full playbook: `.claude/skills/ai-consulting/SKILL.md`. Read it before acting.

Helper (standard library only): `python3 .claude/skills/ai-consulting/scripts/aic_portal.py <command>`

## Modes

| I type | You do |
|---|---|
| `/ai-consulting` | Make sure the token is set (first run: ask me for it, see below), then `pull`, then give me the 6-line briefing from the playbook. |
| `/ai-consulting apply` | Pull if the files are older than a day, read `context/ai-consulting/latest-call.md` + `action-items.md`, propose a diff plan (item -> change -> file), wait for my approval, apply it, mark the finished items done with `done <id>`, `log` a one-line summary to Alexander. |
| `/ai-consulting paste` | No token yet, or an unsynced call: I paste the transcript (or give a file path). File it with `paste`, extract summary, takeaways and action items into the local files, then offer `apply`. Write-back is off in this mode; say so. |
| `/ai-consulting done <id> [<id>]` | Mark those action items done in the portal. |
| `/ai-consulting log <text>` | Send Alexander a note. It lands in his inbox with my name on it. |
| `/ai-consulting status` | Check the token and connection. |

## First run: the token

1. Check `.env` for `AIC_PORTAL_TOKEN`. If it is there, skip this.
2. If not: "Alexander gave you a portal token (40 letters and digits, sent on WhatsApp or Discord). Paste it here." Wait.
3. Run `python3 .claude/skills/ai-consulting/scripts/aic_portal.py setup <token>`. That writes it to `.env` and makes sure `.env` is git-ignored.
4. Never write the token into this file, `SKILL.md`, `CLAUDE.md`, a handoff, or any committed file. Never echo more than its last 4 characters.
5. If the portal answers 401, the token was revoked or mistyped: ask me to get a fresh one from Alexander. If 429, wait 15 minutes; do not retry in a loop.

## Rules

- The files in `context/ai-consulting/` are generated. Never hand-edit them; re-run the pull.
- `apply` changes this repo only after I approve the plan. It never touches `.env`.
- Mark an item done only when the change that closes it is in the repo. Items that need me to do something outside the terminal (send a file, book a call, decide something) stay open; list them for me instead.
- Plain language, no jargon without an explanation, one question at a time.
