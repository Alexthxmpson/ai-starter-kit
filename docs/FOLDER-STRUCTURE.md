# The Workspace, Folder by Folder

```
ai-workspace/
├── CLAUDE.md
├── .claude/
│   └── commands/
│       ├── brain-dump.md
│       ├── skill-creator.md
│       ├── automation.md
│       ├── dashboard.md
│       ├── api-docs.md
│       ├── first-principles.md
│       └── handoff.md
├── projects/
├── context/
│   └── handoffs/
└── docs/
    └── apis/
```

## CLAUDE.md

Read by your AI at the start of every session. It holds the rules of the workspace and, crucially, the "About me" section: your business, your customers, what you are building. Keep it current; it is the difference between advice for "a business" and advice for YOUR business.

## .claude/commands/ (skills)

One file per playbook. Run them inside Claude Code by typing `/` plus the filename. Add your own with `/skill-creator`. This folder is the compounding asset: it should grow every week you work.

## projects/

One folder per build. Each project gets its own folder with its code, its spec (from `/brain-dump`), and a short README. Never let builds float around loose; a year from now you will want to find them.

## context/handoffs/

Your AI's memory between sessions. Every session that did meaningful work ends with `/handoff`, which writes a dated note: what was done, what works, what is next, what was decided. Every session starts by reading the latest relevant note. This is the highest-leverage habit in the whole kit.

## docs/apis/

Saved API documentation, one folder per tool, written by `/api-docs`. The rule it enforces: never let AI code against an API from memory. Fetch the real docs, save them here, code only from what is saved.

## Growing it

- New repeating process → `/skill-creator`
- New build → new folder in `projects/`, starting with `/brain-dump`
- New tool integration → `/api-docs <tool>` first
- End of any real session → `/handoff`
