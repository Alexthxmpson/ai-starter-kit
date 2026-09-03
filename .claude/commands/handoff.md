# Session Handoff

End this work session with a note the next session can pick up from. This is what gives your AI memory between sessions.

## Your process

1. Review what happened this session: what was built, decided, tried, and left unfinished.
2. Write a file to `context/handoffs/` named `YYYY-MM-DD-short-topic.md`:

```markdown
---
date: YYYY-MM-DD
topic: One-line description
status: in-progress | blocked | completed
---

## What was done
Short bullets of completed work.

## Current state
What works right now, what does not, exact file paths that matter.

## Next steps
Numbered, in order. Written so a session with zero memory can execute them.

## Decisions made
Choices and the reason, so they do not get relitigated.

## Open questions
Things that need my input before work can continue.
```

3. Keep it under a page. Precision beats completeness: exact paths, exact commands, exact blockers.
4. Confirm the filename to me when written.

## Rules

- Write it even when the session felt small. "Nothing worked, avoid path X" is a valuable handoff.
- Absolute honesty: if something is untested or broken, the handoff says so.
