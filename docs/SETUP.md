# The Setup, Explained

The four pieces from the talk, and how they fit together.

## Piece 1: The terminal

The terminal is where AI stops being a chatbot and gets hands. A chatbot answers you; an AI in your terminal can touch your files, run programs, and ship things while you watch.

- **warp.dev** is what Alexander uses: a modern terminal built with AI workflows in mind.
- **superset.sh** is what friends at the event use. Same idea, different flavor.
- The built-in Terminal app on your Mac also works on day one.

The terminal is a preference. The engine inside it is what matters.

## Piece 2: The engine (Claude Code)

Claude Code is an AI that works inside your terminal. You describe an outcome in plain language, and it reads your files, writes the code, runs the commands, and checks its own work.

```
You, in plain language → Claude Code → your files, terminal, APIs, browser
```

The installer in this kit sets it up for you. You sign in with a Claude subscription (Pro or Max) or an API key.

## Piece 3: Skills

A skill is a playbook written as a file: how you write proposals, how you research a market, how you build a dashboard. You write the process once, and your AI executes it forever. When you find a better way, you edit the file, and every future run improves.

Skills live in `.claude/commands/`. Inside Claude Code you run one by typing `/` plus its name:

```
/dashboard I want a dashboard for my weekly client numbers
```

The most important skill in this kit is `/skill-creator`: it interviews you about a process you know and writes the skill file for you. This is how you turn years of knowledge into an asset.

## Piece 4: The workspace

```
ai-command-center/
├── CLAUDE.md              ← read by your AI at the start of every session
├── .claude/commands/      ← your skills
├── projects/              ← one folder per build
├── context/handoffs/      ← session notes: your AI's memory
└── docs/apis/             ← saved API documentation
```

The folder most people miss is `context/handoffs/`. Every work session ends with a note to the next one (the `/handoff` skill writes it). That single habit is the difference between an AI with amnesia and an AI that picks up where you left off.

## First session checklist

1. `cd ~/ai-command-center` and run `claude`
2. Open `CLAUDE.md` and fill in the "About me" section: what your business is, who you serve, what you are building
3. Run your first `/brain-dump` on something real
4. End with `/handoff`
