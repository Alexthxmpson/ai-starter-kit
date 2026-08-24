# AI Starter Kit

**From zero to a working AI setup in one command.** The exact workspace structure, starter skills and written guides from Alexander Alberts' AI event in Bali.

This is not a course. It is the actual setup from the talk: a terminal-first AI workspace where Claude Code does the doing, skills capture your processes, and handoff notes give your AI memory between sessions.

## Quick start

**One command (macOS / Linux):**

```bash
curl -fsSL https://raw.githubusercontent.com/Alexthxmpson/ai-starter-kit/main/install.sh | bash
```

**Or clone first and read everything (good instinct):**

```bash
git clone https://github.com/Alexthxmpson/ai-starter-kit.git
cd ai-starter-kit
./install.sh
```

The installer checks your machine, installs Claude Code if it is missing, and creates a workspace at `~/ai-workspace`. It never overwrites files you already have. Windows: install WSL first, then run the same command inside it.

**Got the kit already?** Pull new skills and guides any time, without touching your files:

```bash
curl -fsSL https://raw.githubusercontent.com/Alexthxmpson/ai-starter-kit/main/install.sh | bash -s -- --update
```

## What you get

### Seven starter skills

| Skill | What it does |
|-------|-------------|
| `/brain-dump` | The full prompting workflow from the talk: dump your messy idea, get interviewed in rounds until nothing is assumed, receive a build spec |
| `/skill-creator` | The compounding move: interviews you about a process you know, writes it as a new skill your AI runs forever |
| `/automation` | Designs and builds one automation on the recipe from the talk: trigger → skill → data lands → ping |
| `/dashboard` | Turns data you already have into a live dashboard on a real URL |
| `/api-docs` | Fetches real, current API docs and saves them locally before any integration. Never let AI guess an API |
| `/first-principles` | Strips an idea to what is actually true, then rebuilds it without the assumptions |
| `/handoff` | Ends a session with a note to the next one, so your AI stops having amnesia |

### The workspace

```
ai-workspace/
├── CLAUDE.md              ← rules + "About me", read every session
├── .claude/commands/      ← your skills (grows every week)
├── projects/              ← one folder per build
├── context/handoffs/      ← session notes: your AI's memory
└── docs/                  ← guides + saved API documentation
```

### Five written guides

Installed into `~/ai-workspace/docs/guides/`, also readable right here:

- **[SETUP.md](docs/SETUP.md)**: the four pieces of the setup and how they fit
- **[PROMPTING.md](docs/PROMPTING.md)**: the brain dump → interview → first principles workflow, with a worked example
- **[TOOLS.md](docs/TOOLS.md)**: GitHub, Vercel, Airtable, Supabase, GHL, Close, Zapier, Make, n8n, Trigger.dev, in plain language
- **[ALWAYS-ON.md](docs/ALWAYS-ON.md)**: loops, schedules, and the laptop → Mac mini → VPS decision
- **[FOLDER-STRUCTURE.md](docs/FOLDER-STRUCTURE.md)**: every folder explained, and how to grow the workspace

## Your first week

1. **Tonight:** run the installer, `cd ~/ai-workspace`, run `claude`, sign in. Fill in the "About me" section of `CLAUDE.md`.
2. **Day 1:** `/dashboard` on data you already have (ad account export, CRM, a spreadsheet). Fastest visible win, zero risk.
3. **Day 2:** pick one home for your data (Airtable first). Everything gets easier once your data has an address.
4. **Day 3:** `/automation` on one weekly chore that follows rules: the client report, the account check, the numbers roundup.
5. **Every session after:** end with `/handoff`. This habit compounds harder than any tool.

## The rules that make it work

1. **One workspace.** Everything lives in `ai-workspace`, so every project benefits from every other project.
2. **Never let AI guess an API.** `/api-docs <tool>` before integrating anything.
3. **One build at a time.** Finished beats impressive.
4. **Secrets in `.env` files.** Never in code, never in git.
5. **Did it remove work from your week?** The Friday question that separates systems from dopamine.

## Requirements

- macOS or Linux (Windows via WSL)
- [Node.js 18+](https://nodejs.org)
- A Claude subscription (Pro or Max) or an API key, for signing into Claude Code

## Questions

This kit comes from the event. Message me on WhatsApp with questions, or find me on Instagram.

## License

MIT. Take it, use it, build your own version of it.
