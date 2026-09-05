# Slack — Capabilities & Use Cases

**API:** Slack Web API + Events API + Block Kit
**Access:** Bot token (xoxb-...) or Incoming Webhook URL
**Last updated:** 2026-02-28

---

## What You Can Do

### Messaging (Easy)
- Send messages to any channel or DM
- Format messages with Block Kit (buttons, images, dropdowns)
- Update or delete existing messages
- Add emoji reactions to messages
- Post threaded replies

### Reading & Searching
- List all channels in workspace
- Get message history from any channel
- Search messages across workspace
- Look up users by email or name

### Files & Media
- Upload files and images to channels
- Share file links

### Interactivity
- Handle slash commands
- Button click callbacks
- Modal forms (multi-step flows)
- Select menus and date pickers

### Events & Automation
- Subscribe to events (new message, mention, join)
- Real-time event delivery via webhook
- App mention handler

---

## Use Cases

| Use Case | Method/Feature | Difficulty |
|----------|---------------|------------|
| Send notification to #alerts channel | `chat.postMessage` | Easy |
| Daily standup prompt to team | `chat.postMessage` scheduled | Easy |
| Post report with charts/tables | Block Kit message | Medium |
| Notify when deployment succeeds | `chat.postMessage` from CI | Easy |
| Build Slack bot that answers questions | Events API + slash command | Medium |
| Send DM to specific user by email | `users.lookupByEmail` + DM | Easy |
| Approval workflow with buttons | Block Kit interactive | Medium |
| Forward email to Slack channel | Webhook + postMessage | Easy |
| React to a message with checkmark | `reactions.add` | Easy |
| Get all unread mentions | `search.messages` | Medium |
| Auto-archive channels programmatically | `conversations.archive` | Easy |
| Build onboarding bot for new members | `member_joined_channel` event | Hard |

---

## Quick Reference

```python
# Python — send message
from slack_sdk import WebClient
client = WebClient(token="xoxb-...")
client.chat_postMessage(channel="#general", text="Hello!")

# Incoming Webhook (simplest, no token needed)
import requests
requests.post(WEBHOOK_URL, json={"text": "Hello from automation!"})
```

---

## Key Notes
- Incoming Webhooks = simplest way to post messages (just a POST to a URL)
- Bot token = full API access (requires Slack app with correct scopes)
- Block Kit builder: https://app.slack.com/block-kit-builder
- Rate limits: ~1 message/second per channel
- Scopes needed: `chat:write`, `channels:read`, `users:read`, `files:write`
