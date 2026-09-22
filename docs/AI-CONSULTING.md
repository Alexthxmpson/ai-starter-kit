# Working with Alexander from your terminal

If you are one of Alexander's consulting clients, your command center can talk to his client portal. One command pulls everything from your engagement into this repo, and your AI turns each call into working pieces here instead of a list you forget.

## What it does

```
/ai-consulting          pull latest call, action items, roadmap, onboarding answers, approved builds
/ai-consulting apply    propose changes to this repo from the last call (skills, context, SOPs, projects), you approve, it applies and ticks the items off in the portal
/ai-consulting paste    same thing from a transcript you paste, no token needed
/ai-consulting done     tick an item off
/ai-consulting log      send Alexander a note (it lands in his inbox before the next call)
```

Everything lands in `context/ai-consulting/`. Those files are read by your AI at the start of a session like the rest of `context/`, so every session starts knowing what was agreed on the last call.

## Setup (once)

1. Alexander sends you a portal token: 40 letters and digits. It is yours only; treat it like a password.
2. In your command center: `claude "/ai-consulting"`. It asks for the token and saves it to `.env` (git-ignored, never committed).
3. That is it. Run `/ai-consulting` after every call, or whenever you want the current picture.

Lost or leaked the token? Tell Alexander; he revokes it and sends a new one. The old one stops working the moment he does.

## What the portal shares with your terminal

Your calls (summary, takeaways, action items, builds discussed, recording link; never the raw transcript), your action items, your roadmap, your onboarding answers with any passwords or keys blanked out, approved build specs, delivered builds, and Alexander's resource links. Nothing about other clients.

## What your terminal sends back

Only two things, and only when you run them: "item done" for an action item, and a short note. No files, no transcripts, no code.

## The loop this creates

```
call with Alexander  ->  /ai-consulting  ->  /ai-consulting apply  ->  files in this repo  ->  items ticked  ->  Alexander sees it before the next call
```
