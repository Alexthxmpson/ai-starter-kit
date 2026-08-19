# My AI Workspace

This file is read by Claude Code at the start of every session. It explains how this workspace is organized and the rules to work by.

## Layout

| Folder | What lives here |
|--------|-----------------|
| `.claude/commands/` | Skills (slash commands). Each file is a reusable playbook. |
| `projects/` | One folder per project or build. |
| `context/handoffs/` | Session notes. Read the latest relevant one at the start of a session, write one at the end. |
| `docs/apis/` | Saved API documentation, one folder per tool. Only code against docs saved here. |

## Rules

1. **Session start:** check `context/handoffs/` for a recent note about the current topic and read it before doing anything.
2. **Session end:** when meaningful work was done, write a handoff via the `/handoff` skill.
3. **Integrations:** never guess API endpoints or parameters. If the docs for a tool are not in `docs/apis/`, fetch and save them first (the `/api-docs` skill does this).
4. **Secrets:** API keys live in `.env` files, never in code, never in this file, never committed to git.
5. **Scope:** one build at a time. Finish or park before starting the next thing.

## About me

<!-- Fill this in: what your business is, who you serve, what you are building right now. Your AI reads this every session, so keep it current. -->
