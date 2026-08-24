# Loops, Schedules, and the 24/7 Question

## The automation recipe

Every good automation follows the same four-beat recipe:

```
A schedule fires → a skill runs → data lands somewhere structured → a ping tells you it happened
```

Worked example from the talk: a Skool community gets scraped daily by screenshots, the numbers land in Airtable, and a summary posts to Discord every morning. Any recurring, rule-based chore in your business fits this recipe. The `/automation` skill in this kit designs and builds one with you.

## The catch

Something has to be switched on to run it. Your three options, in order:

### Level 1: Your laptop (start here)

Free, already yours, fine while you experiment. Dies when you close the lid, so nothing critical lives here. On macOS, scheduled jobs use `launchd`; the `/automation` skill sets this up for you.

### Level 2: Mac mini

A real Mac in a drawer at home, running your full setup 24/7. Everything works exactly like your laptop: Mac apps, a real browser, screen-based scraping. One-time cost. The choice when your automations use Mac-only tools or need a real browser.

### Level 3: VPS (rented cloud server)

A few euros a month, always on, reachable from anywhere. Best for pure code: scripts, scrapers, APIs. No Mac apps, and you manage it through the terminal. Providers: Hetzner, DigitalOcean, and similar.

### The cloud-scheduler shortcut

If the automation is pure code, services like **Trigger.dev** run it on a clock in the cloud and remove the question entirely. No hardware, no server management.

## The decision in ten seconds

```
Do you have an automation worth running 24/7 yet?
├── No  → your laptop. Stay here until something earns the upgrade.
└── Yes → does it need Mac apps or a real browser?
    ├── Yes → Mac mini
    └── No  → VPS or a cloud scheduler
```

**The rule: never buy hardware for automations you have not built yet.**
