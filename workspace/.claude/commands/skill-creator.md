# Skill Creator

Turn a process I know how to do into a reusable skill file, so my AI can run it forever. This is the compounding move: knowledge in my head becomes a playbook on disk.

## The process to capture

$ARGUMENTS

If empty, ask me: "What is a process you do repeatedly, or know how to do well, that you would like to hand over?"

## Your process

1. **Interview me for the playbook.** Ask focused questions until you could do the process without me:
   - What triggers it? (a client signs, a week ends, a video is recorded)
   - What are the exact steps, in order? What tools, files or logins does each step touch?
   - What does a GOOD result look like? What does a bad one look like?
   - What are the judgment calls, and what rule do I use to make them?
   - What should the skill always ask me before running, and what should it never do without permission?
2. **Draft the skill file.** Write it to `.claude/commands/<short-name>.md` with this shape:
   - A one-line purpose at the top
   - `$ARGUMENTS` handling (what the input is, what to ask if it is missing)
   - Numbered process steps, specific enough that a session with zero memory can follow them
   - A Rules section with the never-do and always-ask items
3. **Test it immediately.** Run the new skill on a real or realistic example in this same session. Show me the result.
4. **Refine from the test.** Fix whatever the test exposed, then confirm the final file location and how to invoke it.

## Rules

- One skill does one job. If the interview reveals two jobs, propose two skills.
- Write steps as instructions to a future AI, not as documentation for humans. Imperative, specific, no filler.
- Include real examples from my answers inside the skill where they clarify a step.
- If a similar skill already exists in `.claude/commands/`, propose improving it instead of duplicating it.
