# Prompting: The First Prompt Is Never a Prompt

The workflow from the talk. The quality of a build is decided before the first line of code.

```
Voice brain dump → 5 rounds × 20 questions → first principles pass → then build
```

## Step 1: The brain dump

Talk for ten minutes about exactly what you want. Alexander uses **superwhisper** (voice to text on Mac); typing works too, voice is just faster than your inner editor.

Messy is fine. Complete beats clean. Include the why, the who, the "it would be cool if", the fears, all of it.

## Step 2: The interview

Do not let the AI start building. Make it interview YOU, in rounds, until nothing important is assumed:

- Round 1: the goal. What does done look like? Who is it for?
- Round 2: the data and tools. What exists already? Where does information live today?
- Round 3: the edges. What should NOT happen? What is out of scope?
- Round 4: constraints. Budget, time, what you can maintain yourself.
- Round 5: whatever is still assumed. Challenge everything.

Every wrong assumption killed here saves an hour of building the wrong thing.

## Step 3: First principles

Strip the idea to what is actually true, then rebuild from fundamentals. Half the features usually do not survive. Good. The `/first-principles` skill in this kit runs this pass.

## Step 4: Build

Only now. In this kit, steps 1 to 3 are one command: `/brain-dump`.

## A worked example

**The dump sounds like:** "I want a client dashboard, it pulls from GoHighLevel, shows ad spend, needs to work on mobile, clients get a login, maybe a weekly email..."

**The interview asks back:** "Which numbers actually drive decisions? Who looks at it, you or the client? What already stores this data? What must NOT be visible to clients?"

**What changes:** half the features die. The real build shrinks to one screen with four numbers. It ships in a day instead of a month.

## Notes

- This workflow is model-agnostic. Run the thinking phase on any AI you like; the workflow is the asset, not the model.
- Save the resulting spec in the project folder, so future sessions build against it instead of re-deciding.
