# Fathom Video API — Use Cases & Practical Guide

**Date:** 2026-02-27
**Product:** Fathom Video (fathom.video) — AI meeting notes, transcripts, summaries
**API docs:** https://developers.fathom.ai

---

## Important: This is Fathom VIDEO — Not Fathom Analytics

Alexander's API key is for **fathom.video** (meeting notetaker), not usefathom.com (website analytics). They are completely separate products with separate APIs and API keys.

---

## What You Can Do

### Group 1: Retrieve Meeting Data

- Pull a list of all your recorded meetings, paginated
- Filter meetings by date range, recorder email, or team
- Retrieve full verbatim transcripts with speaker attribution and timestamps
- Get AI-generated meeting summaries (formatted markdown)
- Extract action items from any meeting
- Access CRM match data linked to meetings

### Group 2: Real-Time Webhooks

- Receive an HTTP POST the moment a meeting finishes processing
- Configure what data is included in the webhook payload (transcript, summary, action items)
- Filter which meeting types trigger webhooks (your recordings, team recordings, shared recordings)
- Verify payload authenticity using HMAC signatures

### Group 3: Team Management

- List all teams in your Fathom workspace
- List all members of a specific team
- Filter meeting queries by team name

### Group 4: Build Integrations

- Push meeting summaries into a CRM (HubSpot, Salesforce, Pipedrive)
- Sync transcripts to a knowledge base (Notion, Confluence)
- Auto-create follow-up tasks from action items
- Feed meeting content to an LLM for further analysis
- Build custom dashboards of meeting activity

---

## Practical Automation & Project Ideas

| Project | What It Does | Complexity | Key API Used |
|---|---|---|---|
| CRM auto-update | Webhook → parse action items → create HubSpot tasks | Medium | Webhook + action items |
| Notion meeting log | After every call, create a Notion page with summary + transcript | Low | Webhook + summary |
| Weekly meeting digest | Every Monday, email all meetings from last 7 days with summaries | Low | List meetings + created_after filter |
| Action item tracker | Extract all action items this week → push to Asana/Linear/Notion database | Medium | List meetings + include_action_items |
| Slack post-call summary | Webhook fires → post summary to relevant Slack channel based on team | Medium | Webhook + summary + Slack API |
| Transcript search tool | Pull all transcripts, index in Elasticsearch/Pinecone, search semantically | High | List meetings + include_transcript |
| RAG knowledge base | Feed all meeting transcripts to a vector DB → query with LLM | High | List meetings + include_transcript |
| Sales call analysis | Fetch all Sales team meetings → run LLM analysis on transcripts for coaching | High | List meetings + teams[] filter + transcript |
| Deal-specific timeline | Filter by participant email (external contact) → build call history per deal | Medium | List meetings + recorded_by filter |
| Meeting analytics dashboard | Count meetings per week/person/team, average duration, build charts | Low-Medium | List meetings + pagination |
| Auto-transcription backup | Archive all transcripts to S3/Google Drive as markdown files | Low | List meetings + include_transcript |
| Follow-up email drafter | Webhook → GPT-4 prompt with transcript → draft follow-up email in Gmail | Medium | Webhook + transcript + OpenAI + Gmail |
| Interview notes compiler | After each interview, add transcript to a candidates Notion database | Low | Webhook + summary + action items |
| Meeting cost calculator | Meeting duration × attendee count × avg salary → cost per meeting report | Low | List meetings (duration + invitees) |

---

## Key API Patterns

### Pattern 1: Polling (Scheduled Sync)

Use this when you want to sync meetings on a schedule (e.g., daily or hourly).

```python
import requests
from datetime import datetime, timedelta

API_KEY = "YOUR_FATHOM_API_KEY"
BASE_URL = "https://api.fathom.ai/external/v1"

yesterday = (datetime.utcnow() - timedelta(days=1)).isoformat() + "Z"

response = requests.get(
    f"{BASE_URL}/meetings",
    headers={"X-Api-Key": API_KEY},
    params={
        "created_after": yesterday,
        "include_summary": "true",
        "include_action_items": "true"
    }
)

meetings = response.json().get("items", [])
for meeting in meetings:
    print(f"{meeting['title']} — {meeting['created_at']}")
```

### Pattern 2: Webhook (Real-Time)

Use this when you need to react immediately when a meeting ends. Lower latency than polling, and does not count against your rate limit.

```python
# Flask webhook receiver example
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/fathom-webhook", methods=["POST"])
def fathom_webhook():
    data = request.json
    recording_id = data.get("recording_id")
    summary = data.get("summary", {}).get("markdown_formatted", "")
    action_items = data.get("action_items", [])

    # Your logic here: post to Slack, update CRM, etc.
    print(f"New meeting ready: {recording_id}")
    print(f"Summary: {summary[:200]}...")

    for item in action_items:
        print(f"Action: {item['text']} → {item.get('assignee', 'Unassigned')}")

    return jsonify({"status": "ok"}), 200

if __name__ == "__main__":
    app.run(port=3000)
```

---

## Key Limits & Gotchas

| Limit / Gotcha | Detail |
|---|---|
| 60 requests per minute | Hard limit — no higher tier available. For bulk historical syncs, add `time.sleep(1)` between requests or batch with `limit=100` |
| API key scope is user-level | Your key only sees meetings you recorded OR meetings shared to your team. Cannot access other users' private meetings |
| No upload API | You cannot push external audio/video files into Fathom for processing — meetings must be recorded by Fathom's bot |
| Transcript availability | Transcripts are only available after Fathom fully processes the meeting. Webhook is the reliable way to know when it's ready |
| `triggered_for` scope on webhooks | If you don't set `triggered_for`, you may get more events than expected. Configure this carefully |
| At least one `include_*` must be true | When creating a webhook, at least one of `include_transcript`, `include_summary`, `include_action_items`, `include_crm_matches` must be `true` |
| Fathom only joins scheduled meetings | Fathom's bot joins via calendar invite or manual bot invite — it cannot retroactively record past meetings |
| No write endpoints for summaries | You cannot edit or regenerate summaries via API — read-only for meeting content |
| Pagination is cursor-based | Do NOT use offset pagination — use the `next_cursor` value from each response |
| Summary quality varies by template | The summary template is set in Fathom's UI per call type. The API returns whatever template was applied |
| `recorded_by[]` filter takes email | Must use the exact email address of the recorder — not a display name |
| Share URL vs. meeting URL | `share_url` is a public-shareable link; `url` is the Fathom internal link. Use `share_url` when embedding or linking externally |

---

## Data Available per Meeting

| Data Point | API Field | Notes |
|---|---|---|
| Meeting title | `title` / `meeting_title` | Calendar event title |
| Recording date/time | `created_at`, `started_at`, `ended_at` | ISO 8601 timestamps |
| Duration | `ended_at - started_at` | Calculate from timestamps |
| Meeting platform | `meeting_type` | `zoom`, `google_meet`, `microsoft_teams`, `webex` |
| Who recorded | `recorded_by.name`, `.email`, `.team` | The Fathom user who hosted the bot |
| All attendees | `calendar_invitees[]` | Name, email, internal/external flag |
| Full transcript | `transcript[]` | Speaker + text + timestamp per turn |
| AI summary | `default_summary.markdown_formatted` | Markdown-formatted, template-based |
| Action items | `action_items[]` | Text + assignee |
| Share link | `share_url` | Public-shareable URL |

---

## When to Use Webhook vs. Polling

| Use Case | Recommended Approach |
|---|---|
| Post-call Slack notification | Webhook — needs to fire immediately |
| CRM update after every call | Webhook — real-time, reliable |
| Daily digest email | Polling — scheduled job with `created_after` |
| Bulk historical sync (first setup) | Polling — paginate through all meetings once |
| Real-time transcript analysis | Webhook — lowest latency |
| Weekly report generation | Polling — simple cron job |
| Building a search index | Polling — one-time full sync, then webhooks for new |

---

## Rate Limit Strategies

With 60 req/min, here is how to stay within limits for common scenarios:

| Scenario | Approach |
|---|---|
| Sync 1,000 meetings | Use `limit=100`, 10 pages needed, spread over 2 minutes |
| Check for new meetings every 5 min | 1 request every 5 minutes — well within limits |
| Fetch meeting + transcript separately | Combine with `include_transcript=true` on list — 1 request instead of 2 |
| Multi-user org sync | Each user has separate API key with its own 60 req/min — no shared limit |

---

## Integration Targets (No Native Connectors — Build Yourself)

Fathom has no official Zapier app or Make.com module as of 2026-02-27. Build webhook receivers that call target APIs directly:

| Target | How to Integrate |
|---|---|
| HubSpot | POST to HubSpot Engagements API after webhook |
| Notion | Use Notion API to create pages from meeting data |
| Slack | Use Slack Incoming Webhooks or Block Kit |
| Linear | Create issues from action items via Linear API |
| Google Sheets | Append rows via Google Sheets API |
| Airtable | POST records via Airtable API |
| Pipedream / n8n | Use HTTP trigger node to receive Fathom webhooks |

---

## Getting Started in 5 Minutes

1. Log in at https://app.fathom.video
2. Go to Settings → API → Create API Key
3. Test immediately:

```bash
curl -s \
  -H "X-Api-Key: YOUR_API_KEY" \
  "https://api.fathom.ai/external/v1/meetings?limit=3&include_summary=true" \
  | jq '.items[0].default_summary.markdown_formatted'
```

4. If you see a summary printed — you're set. If you get `401`, double-check your key.

---

## Sources

- [Fathom Video Public API Help Article](https://help.fathom.video/en/articles/8368641)
- [Fathom API Developer Docs](https://developers.fathom.ai)
- [Fathom API Quickstart](https://developers.fathom.ai/quickstart)
- [Fathom Webhooks Reference](https://developers.fathom.ai/webhooks)
- [Fathom List Meetings Endpoint](https://developers.fathom.ai/api-reference/meetings/list-meetings)
- [Webhook Testing Guide](https://help.fathom.video/en/articles/10625473)
- [GitHub — Dot-Fun/fathom-mcp](https://github.com/Dot-Fun/fathom-mcp)
- [GitHub — matthewbergvinson/fathom-mcp](https://github.com/matthewbergvinson/fathom-mcp)
