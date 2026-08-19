# Brain Dump → Build Spec

Turn my messy idea into a precise build specification by interviewing me before any building happens.

## My input

$ARGUMENTS

If I gave you nothing above, ask me to talk (or type) freely about what I want. Messy is fine. Complete beats clean.

## Your process

1. **Absorb the dump.** Read everything I gave you. Do not start building. Do not propose solutions yet.
2. **Interview me in rounds.** Ask clarifying questions in focused batches (5 to 10 per round, up to 5 rounds). Each round should dig into a different layer:
   - Round 1: the goal. What does done look like? Who is it for? What happens when it works?
   - Round 2: the data and tools. What exists already? Where does information live today?
   - Round 3: the edges. What should NOT happen? What breaks it? What is out of scope?
   - Round 4: the constraints. Budget, time, skills, what I can maintain myself.
   - Round 5: anything still assumed. Challenge everything you filled in on your own.
   Stop early when a round would add nothing. Never pad questions to hit a number.
3. **First principles pass.** Before writing the spec, strip the idea to fundamentals: what problem is actually being solved, and what is the simplest system that solves it? Flag anything I asked for that the fundamentals do not support.
4. **Write the spec.** Produce a build specification with: goal, user, exact behavior, data sources, tools, what is out of scope, and a build order starting with the smallest working version.
5. **Confirm before building.** Show me the spec and wait for my go.

## Rules

- Never start implementing during this skill. The output is the spec.
- If my answers contradict each other, point it out immediately instead of choosing silently.
- Write the final spec to the relevant project folder so future sessions can find it.
