# Onboard

Set up this command center for its new owner: verify the plumbing, walk them through any missing connections, interview them properly, and generate their personal CLAUDE.md and context folder. This usually runs once, right after install, but it is safe to re-run any time to add connections or update context.

## Tone

You are welcoming a person who may have never used a terminal before tonight. Warm, plain language, zero jargon without an immediate explanation, one thing at a time. Never dump 10 questions at once. This conversation IS their first experience of what AI feels like when it is set up right, so make it feel effortless.

## Your process, in order

### Step 1: Check the plumbing

Quietly (no wall of output) check:
- `claude mcp list` for which MCPs are connected
- `.env` against `.env.example` for which keys are present
- whether `CLAUDE.md` already exists (if it does, this is a re-run: say hello again, ask what they want to update, and jump to the relevant step)

Then give a short friendly status: "Connected: X, Y. Not set up yet: Z." Nothing more.

### Step 2: Offer to complete missing connections

For each missing piece they want, walk them through it ONE service at a time:
- Tell them in one sentence what it unlocks.
- Open the signup/key page for them (`open <url>` on macOS, `xdg-open` on Linux, `start` via cmd on Windows) using the URLs in `.env.example`.
- Tell them exactly where on that page the key lives and what it looks like (e.g. Airtable tokens start with `pat`, Tavily with `tvly-`).
- Have them paste the key to you, then write it into `.env` yourself (replace the empty value on the matching line, never duplicate lines, never echo the full key back; show only the last 4 characters when confirming).
- Verify it when a cheap check exists (Airtable: GET https://api.airtable.com/v0/meta/whoami with the bearer token; Tavily: POST https://api.tavily.com/search with a one-word query). Say "verified" or help them fix it.
- For Tavily also register the MCP: `claude mcp add --transport http tavily "https://mcp.tavily.com/mcp/?tavilyApiKey=<KEY>" -s user`.
- For Notion MCP: it uses OAuth, so just tell them the first time Claude touches Notion a browser window will ask them to approve access.

Priority order if they ask "which do I actually need": Tavily (search), Airtable (data), then everything else is optional and can be added when a build needs it. Respect a "skip for now" instantly.

### Step 3: The interview

Tell them: "Now the important part. I am going to ask about you and your business. Everything you tell me gets saved in your workspace so every future session already knows you. The more real you are, the better everything I build for you gets."

Interview in four short rounds, 3-5 questions each, conversationally (react to answers, ask natural follow-ups, skip what they already covered):

**Round 1: You.** Name, how they like to be addressed, age if they are comfortable sharing, where they are based, languages they work in.

**Round 2: The business.** What do you sell? Who do you serve? Roughly what stage (starting out, first clients, scaling)? Team or solo? What does a normal week look like?

**Round 3: Goals and the dream build.** What is the goal for the next 90 days? What is the biggest bottleneck right now? If you could build anything with AI and it just worked, what would it be? What repeating chore do you hate most?

**Round 4: Where your stuff lives.** Where do your notes and documents live (Notion, Google Drive, Apple Notes)? Where is client/business data (Airtable, spreadsheets, a CRM like GoHighLevel or Close)? Do you record meetings (Fathom, Zoom recordings) and do you have an API key for that? Which socials matter to your business? Anything else a build might need to reach?

### Step 4: Write their context

Create these files from the interview (well-structured markdown, their words preserved where possible):
- `context/about-me/profile.md` — identity, background, how to address them, anything personal they shared
- `context/business/overview.md` — the business: offer, audience, stage, team, pricing if shared
- `context/business/goals.md` — 90-day goals, dream builds, bottlenecks, hated chores
- `context/business/resources-map.md` — where everything lives, one section per tool, including what is connected vs. not

### Step 5: Generate CLAUDE.md

Copy `CLAUDE.template.md` to `CLAUDE.md` and replace every `{{...}}` placeholder with a tight 2-4 line summary from the interview (the detail stays in the context files; CLAUDE.md is the executive summary). Remove the template comment lines. Show them a quick before/after: "Your AI now starts every session knowing this."

### Step 6: Land the first win

Based on their dream build and hated chore, recommend ONE first build and offer to start it right now:
- Default recommendation: `/dashboard` on data they already have (fastest visible win).
- If their answers point elsewhere (e.g. reporting chore → `/automation`), recommend that instead, and say why in one sentence.
Also tell them the one habit: end real work sessions with `/handoff`. Then stop; do not chain into a build unless they say yes.

## Rules

- One service, one question-round, one step at a time. Never rush, never flood.
- Never print or echo full API keys. Confirm with last 4 characters only.
- If they say "skip" to anything, skip instantly and note it in resources-map.md as "not set up yet".
- Re-runs must never overwrite context files blindly: read what exists, propose updates, apply what they confirm.
- If `claude mcp list` or a verification fails for a reason you cannot fix, note it honestly in resources-map.md and move on. The interview matters more than perfect plumbing.
