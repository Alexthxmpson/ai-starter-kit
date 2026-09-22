# Turning a call into repo changes

The point of a consulting call is a change in how the business runs. In a command-center repo that change is a file: a skill, a context fact, an SOP, a project. `apply` makes those files.

## Mapping rules

| The call says | Class | Where it goes | Example |
|---|---|---|---|
| "Every week you should…", "whenever X happens, do Y", any repeatable process the user runs with AI | `skill` | `.claude/commands/<verb-noun>.md` | "Draft the Monday client update from last week's numbers" -> `/weekly-client-update` |
| A fact about the business, an offer, a customer, a number, a decision | `context` | `context/business/overview.md` or `goals.md`, or the matching `CLAUDE.md` section | "We are dropping the €500 tier" |
| A human process with steps, handoffs and owners (often involves people other than the user) | `sop` | `docs/sops/<slug>.md` | "Onboarding a new ecom client: contract, access, kickoff" |
| Something to build (a dashboard, a bot, an automation), or an approved spec in `builds.md` | `project` | `projects/<slug>/spec.md` (+ README) with the spec text, done-when, and the first three steps | "Intake bot on the website" |
| The user must do something outside the repo | `human` | Listed back to the user, item stays open | "Send Alexander the Notion export" |
| Alexander owes something | `alexander` | Ignored here, item stays open | "Alexander drafts the PRD" |

## Writing a skill from a call

1. Name it after the outcome the user gets, not the tool.
2. Open with two sentences: what it produces, when to run it.
3. Inputs: what the user pastes or which file/URL it reads.
4. Steps: numbered, each with the exact file it reads or writes.
5. Output: what "done" looks like (a file path, a message, a draft).
6. Match the tone and length of the existing skills in `.claude/commands/` (one screen, plain language).
7. Add one line to the skills table in `README.md` if the repo has one.

## Writing an SOP

`docs/sops/<slug>.md`: Trigger, Owner, Steps (numbered, each with who and which tool), Done-when, Common failures. Under a page.

## Writing a project spec

`projects/<slug>/spec.md`: Why (from the call, quoted where possible), Outcome, Scope, Out of scope, Done when, First three steps. If `builds.md` has an approved spec with the same topic, paste its body under "Alexander's spec" and do not rewrite it.

## Deciding "closes item?"

Yes only when a person could look at the repo and agree the item is finished. "Set up a skill for X" is closed by the skill file. "Use the skill for two weeks" is not closed by anything in the repo. When unsure, leave it open and say why.

## After applying

- `aic_portal.py done <ids>` for the closed ones.
- `aic_portal.py log "Applied call of <date>: added /<skill>, docs/sops/<x>.md, projects/<y>/spec.md; closed 3 items, 2 still need me (send export, book call)."`
- Suggest `/handoff`.
