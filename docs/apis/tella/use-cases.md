# Tella API — Use Cases & Practical Guide

**Date:** 2026-02-27
**Product:** Tella (tella.tv) — AI screen recorder and video hosting

---

## Reality Check First

Tella's API is **enterprise-only and private**. Before planning any API-based automation:

- Standard plans (Pro at $16/mo, Premium at $42/mo) do NOT include API access
- API documentation is not publicly published — you get it after signing an enterprise contract
- The API exists and is operational (status page confirms), but access requires contacting Tella sales

**What IS freely available (no API key needed):**
- oEmbed endpoint for generating embed codes from any Tella video URL
- Public video share links
- iFrame embeds

---

## What You Can Do

### Group 1: Video Library Management (Enterprise API)

- List all videos in your workspace programmatically
- Retrieve metadata for specific videos by ID
- Delete videos in bulk
- Filter videos by date range
- Poll for new recordings automatically

### Group 2: Embedding & Sharing (Free — No API Key)

- Generate embed codes for any public Tella video using oEmbed
- Embed Tella videos in websites, wikis, Notion, Confluence
- Control embed dimensions and behavior (autoplay, loop, start time)
- Use the oEmbed API to dynamically render previews in custom apps

### Group 3: Webhooks & Event-Driven Automation (Enterprise API)

- Receive a POST request the moment a recording is ready
- Trigger downstream workflows when a video finishes processing
- Notify team members via Slack/email automatically when recordings complete
- Sync new recordings to a database or CRM
- Kick off video processing pipelines (transcription, summarization)

### Group 4: Content Tracking & Analytics (Enterprise API — limited)

- Track which videos exist in a workspace
- Monitor recording output volume over time
- Build internal dashboards of video content

---

## Practical Automation & Project Ideas

| Project | What It Does | Tools Needed | API Key Required |
|---|---|---|---|
| Video completion notifier | Webhook fires when recording is ready → Slack DM to creator | Tella webhook + Slack API | Yes (enterprise) |
| Auto-transcription pipeline | On `recording.completed` webhook, send video URL to Whisper/Deepgram for transcription | Tella webhook + transcription API | Yes (enterprise) |
| CRM video log | After each recording, log video ID + URL to HubSpot/Notion as a note | Tella webhook + CRM API | Yes (enterprise) |
| Embed code generator | Enter any Tella video URL → get iframe embed code | oEmbed endpoint | No |
| Video library sync | Daily job: pull all videos via API, store metadata in Airtable/database | Tella list API + Airtable | Yes (enterprise) |
| Notion video gallery | Embed Tella videos dynamically in Notion using oEmbed URLs | Notion + Tella URLs | No |
| New video email digest | Weekly email with all recordings from the past 7 days | Tella API + email provider | Yes (enterprise) |
| Auto-delete old recordings | Cron job to delete videos older than 90 days to manage storage | Tella delete API | Yes (enterprise) |
| Video-to-blog pipeline | Webhook → transcribe → GPT summary → publish as blog draft | Tella + Whisper + OpenAI + CMS | Yes (enterprise) |
| Demo video tracker | List all videos, filter by title keyword, log to spreadsheet | Tella list API | Yes (enterprise) |

---

## oEmbed Quick Reference (Free, No Sign-up)

The oEmbed endpoint works for any public Tella video right now:

```http
GET https://www.tella.tv/oembed?url=YOUR_TELLA_VIDEO_URL&maxwidth=800
```

Returns JSON with the iframe HTML ready to paste. This is the one thing you can use without enterprise access.

**Use it to:**
- Auto-generate embeds in a custom CMS
- Preview Tella videos in a link unfurler
- Fetch video thumbnails and titles programmatically

---

## Key Limits & Gotchas

| Limitation | Detail |
|---|---|
| API is enterprise-only | Must contact Tella sales — no self-serve API access |
| No public API docs | You only get documentation after enterprise onboarding |
| No official SDKs | Must write raw HTTP calls — no Python/JS/Ruby libraries |
| No upload API confirmed | Cannot push video files into Tella via API; recording happens in desktop app |
| No Zapier/Make native integration | No official automation platform connectors — must build custom webhook handlers |
| Rate limits unknown | Not published publicly — ask Tella during onboarding |
| oEmbed only works on public videos | Password-protected or private videos will not return embed data |
| Video processing time varies | Mux-backed infrastructure — processing can take 30 seconds to several minutes |
| Status monitoring | Check https://status.tella.tv/public-api before assuming API is down |

---

## When To Use vs. Skip

**Use Tella API when:**
- You are already on or negotiating an enterprise Tella plan
- You need to automate post-recording workflows at scale (many recordings per day)
- You want recording lifecycle webhooks to trigger other systems

**Skip Tella API when:**
- You are on a standard plan — use the UI + share links instead
- You only need a few embeds — use oEmbed or just copy the iframe from Tella's share dialog
- You want a full video API platform — consider Mux, api.video, or Cloudflare Stream which have open, fully documented APIs

---

## Getting API Access

1. Go to https://www.tella.tv
2. Contact sales or support and request enterprise API access
3. They will provide: API key, endpoint documentation, rate limit details
4. Generate your key in Settings → API once enterprise is activated

---

## Sources

- [Tella API Tracker](https://apitracker.io/a/tella-tv)
- [Tella Pricing](https://www.tella.com/pricing)
- [Tella Status — Public API](https://status.tella.tv/public-api)
- [Tella oEmbed via Embedly](https://embed.ly/provider/tella)
- [Tella Help — Embed](https://www.tella.com/help/embed)
