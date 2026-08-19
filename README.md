# AI Starter Kit

The exact workspace structure and starter skills from Alexander Alberts' AI event in Bali. One command gets you from zero to a working Claude Code setup with the folder structure and first skills I use myself.

## What you get

- **Claude Code installed** (the AI engine that reads files, writes code and runs commands for you)
- **A clean workspace** with the folder structure from the talk: skills, projects, handoffs, docs
- **5 starter skills** (slash commands you run inside Claude Code):

| Skill | What it does |
|-------|-------------|
| `/brain-dump` | My full prompting workflow: dump your messy idea, get interviewed in rounds of questions until nothing is assumed, then get a build spec |
| `/first-principles` | Strips an idea or problem down to what is actually true, then rebuilds it without the assumptions |
| `/api-docs` | Before any integration: finds the official API docs, saves them locally, and only codes from the real docs. Never let AI guess an API |
| `/dashboard` | Turns any data you have (CSV, Airtable export, spreadsheet) into a live dashboard on a real URL |
| `/handoff` | Ends a work session with a note to the next session, so your AI stops having amnesia |

## Quick start

**Option 1: one command**

```bash
curl -fsSL https://raw.githubusercontent.com/Alexthxmpson/ai-starter-kit/main/install.sh | bash
```

**Option 2: clone first**

```bash
git clone https://github.com/Alexthxmpson/ai-starter-kit.git
cd ai-starter-kit
./install.sh
```

The installer checks your machine, installs Claude Code if it is missing, and creates your workspace at `~/ai-workspace` (it asks first, and never overwrites files you already have).

## After installing

```bash
cd ~/ai-workspace
claude
```

Sign in when it asks (a Claude Pro or Max subscription, or an API key, both work). Then try your first command:

```
/brain-dump I want to build a dashboard that shows my weekly sales
```

## The rules that make this work

1. **One workspace.** Everything lives in `ai-workspace`. Your AI can see all of it, so every project benefits from every other project.
2. **End every session with `/handoff`.** The note it writes is what makes tomorrow's session smart about today.
3. **Never let AI guess an API.** Run `/api-docs <tool name>` before integrating anything.
4. **Finished beats impressive.** One business, one bottleneck, one build at a time.

## Requirements

- macOS or Linux
- [Node.js 18+](https://nodejs.org) (the installer will tell you if it is missing)

## Questions

This kit comes from the event. Message me on WhatsApp with questions, or find me on Instagram.
