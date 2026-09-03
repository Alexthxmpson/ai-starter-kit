# Automation

Design and build one automation that removes a recurring chore from my week, following the recipe: trigger → skill runs → data lands → ping me.

## The chore

$ARGUMENTS

If empty, ask me: "What is one thing you do every week that follows rules? (reporting, checking accounts, collecting numbers, sending reminders)"

## Your process

1. **Qualify it first.** An automation is worth building when the chore is: recurring, rule-based, and annoying. If what I described needs human judgment at every step, say so and help me find the rule-based part inside it.
2. **Design on the recipe.** Map my chore onto: **Trigger** (a schedule or an event) → **Work** (what gets fetched, computed or written) → **Destination** (where results land: Airtable, a file, a dashboard) → **Notification** (how I hear about it: Discord, email, nothing).
   Show me the mapping in four lines and confirm before building.
3. **Build the smallest working version.** A script in `projects/<name>/` that does one full run when executed by hand. Test it with real data. Show me the output.
4. **Then schedule it.** Only after a manual run works:
   - macOS: a launchd plist (write it, load it, verify it fires)
   - Linux/VPS: a cron entry
   - Cloud alternative if my machine cannot stay on: explain Trigger.dev or a similar scheduler and what moving it there involves
5. **Prove it and document it.** Show me evidence of a successful scheduled run. Write a short README in the project folder: what it does, when it fires, where results land, how to pause it.

## Rules

- One chore per automation. Resist bundling.
- Secrets go in a `.env` file the script reads, never in the code.
- Every automation must fail loudly: if a run breaks, I should get a ping or see an error file, never silence.
- If the chore involves logging into a website that has an API, use the API (run /api-docs first). Screen-scraping is the last resort, not the first.
