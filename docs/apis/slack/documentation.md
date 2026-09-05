# Slack API — Technical Documentation

## Overview

The Slack API allows developers to build bots, automate workflows, and integrate external services
into Slack workspaces. It supports sending and receiving messages, managing channels, handling
interactive user actions, and subscribing to real-time workspace events.

Core use patterns:
- **Bots**: Automated users that respond to messages or slash commands.
- **Incoming Webhooks**: One-way URL endpoints for posting messages without a full app.
- **Events API**: Receive real-time notifications when things happen in Slack.
- **Block Kit**: Rich, structured message formatting with interactive components.
- **Slash Commands**: Custom `/commands` that users trigger to invoke actions.
- **Modals**: Pop-up forms and views within Slack for collecting user input.

---

## Authentication

### Bot Token (xoxb-)
The most common auth method. Obtained after installing a Slack App to a workspace.

```
Authorization: Bearer xoxb-xxxxxxxxxxxx-xxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx
```

Scopes are granted when the app is installed. Each API method requires specific scopes.

### User Token (xoxp-)
Acts on behalf of a specific user rather than the bot. Less common; used when user-level
permissions are needed (e.g., reading DMs the bot hasn't been invited to).

### Incoming Webhook URL
A fixed URL tied to a specific channel. Send a POST request with a JSON body to post a message.
No token required — the URL itself is the credential. Keep it secret.

```
https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

### App-Level Token (xapp-)
Used for Socket Mode connections. Allows your app to receive events without exposing a public
HTTP endpoint.

---

## Base URL

```
https://slack.com/api/
```

All Web API methods are called via HTTPS POST requests to:
```
https://slack.com/api/{method.name}
```

Responses are always JSON with a top-level `ok` boolean field.

```json
{ "ok": true, ... }
{ "ok": false, "error": "channel_not_found" }
```

---

## Key API Methods

### Messaging

#### chat.postMessage
Send a message to a channel or DM.

```http
POST https://slack.com/api/chat.postMessage
Authorization: Bearer xoxb-...
Content-Type: application/json

{
  "channel": "C0123456789",
  "text": "Hello from the API!",
  "blocks": [...],
  "thread_ts": "1234567890.123456",
  "unfurl_links": false
}
```

| Parameter   | Type    | Description                                            |
|-------------|---------|--------------------------------------------------------|
| channel     | String  | Channel ID, user ID (for DMs), or channel name.       |
| text        | String  | Plain text fallback (required if no blocks).          |
| blocks      | Array   | Block Kit layout for rich formatting.                 |
| thread_ts   | String  | Reply to a specific message thread.                   |
| mrkdwn      | Boolean | Enable Slack markdown formatting. Default: true.      |

Required scope: `chat:write`

---

#### chat.update
Update the content of an existing message.

```json
{
  "channel": "C0123456789",
  "ts": "1234567890.123456",
  "text": "Updated message text"
}
```

Required scope: `chat:write`

---

#### chat.delete
Delete a message.

```json
{
  "channel": "C0123456789",
  "ts": "1234567890.123456"
}
```

Required scope: `chat:write`

---

### Channels / Conversations

#### conversations.list
List all channels the bot has access to.

```json
{
  "types": "public_channel,private_channel",
  "limit": 100,
  "exclude_archived": true
}
```

Required scope: `channels:read`, `groups:read`

---

#### conversations.history
Retrieve message history from a channel.

```json
{
  "channel": "C0123456789",
  "limit": 50,
  "oldest": "1234567890.000000",
  "latest": "1234599999.000000"
}
```

Required scope: `channels:history`

---

#### conversations.info
Get details about a specific channel.

```json
{
  "channel": "C0123456789"
}
```

Returns: name, topic, purpose, member count, creation date.

---

### Users

#### users.list
List all members of the workspace.

```json
{
  "limit": 200,
  "cursor": "PAGINATION_CURSOR"
}
```

Required scope: `users:read`

---

#### users.info
Get details for a single user.

```json
{
  "user": "U0123456789"
}
```

Returns: name, email, display name, timezone, profile image, status.

---

#### users.lookupByEmail
Find a user by their email address.

```json
{
  "email": "user@example.com"
}
```

Required scope: `users:read.email`

---

### Files

#### files.upload
Upload a file to a channel.

```http
POST https://slack.com/api/files.upload
Content-Type: multipart/form-data

{
  "channels": "C0123456789",
  "filename": "report.csv",
  "filetype": "csv",
  "initial_comment": "Here is this week's report.",
  "content": "col1,col2\nval1,val2"
}
```

Required scope: `files:write`

---

### Reactions

#### reactions.add
Add an emoji reaction to a message.

```json
{
  "channel": "C0123456789",
  "timestamp": "1234567890.123456",
  "name": "white_check_mark"
}
```

Required scope: `reactions:write`

---

#### reactions.remove
Remove an emoji reaction.

```json
{
  "channel": "C0123456789",
  "timestamp": "1234567890.123456",
  "name": "white_check_mark"
}
```

---

### Pins and Bookmarks

#### pins.add
Pin a message in a channel.

```json
{
  "channel": "C0123456789",
  "timestamp": "1234567890.123456"
}
```

Required scope: `pins:write`

---

#### bookmarks.add
Add a bookmark link to a channel's bookmarks bar.

```json
{
  "channel_id": "C0123456789",
  "title": "Runbook",
  "type": "link",
  "link": "https://docs.example.com/runbook"
}
```

---

## Block Kit

Block Kit is Slack's UI framework for building structured, interactive messages and modals.

### Block Types

| Block Type  | Description                                        |
|-------------|----------------------------------------------------|
| section     | Text with optional accessory (button, image, etc.)|
| divider     | A horizontal line separator.                       |
| header      | Large bold heading text.                           |
| image       | An image with alt text and optional title.        |
| actions     | A row of interactive elements (buttons, selects). |
| context     | Small secondary text or images.                   |
| input       | A form field (text input, select, datepicker).    |

### Example Block Kit Message

```json
{
  "blocks": [
    {
      "type": "header",
      "text": { "type": "plain_text", "text": "Deployment Alert" }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Service*: api-gateway\n*Status*: :red_circle: Failed\n*Triggered by*: <@U0123456789>"
      }
    },
    {
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": { "type": "plain_text", "text": "View Logs" },
          "url": "https://logs.example.com",
          "style": "danger"
        }
      ]
    }
  ]
}
```

---

## Incoming Webhooks

The simplest way to post messages. Useful for one-directional notifications.

```bash
curl -X POST https://hooks.slack.com/services/T.../B.../xxx \
  -H "Content-Type: application/json" \
  -d '{"text": "Build passed! Ready to deploy."}'
```

Supports `text`, `blocks`, `username`, `icon_emoji`, `icon_url`, and `channel` overrides (if enabled).

---

## Slash Commands

Register a `/command` in your Slack App settings. When a user types it, Slack sends a POST
request to your configured URL.

### Incoming Payload

```
token=xxx
team_id=T0123456789
channel_id=C0123456789
user_id=U0123456789
command=/deploy
text=production
response_url=https://hooks.slack.com/commands/...
```

Respond within 3 seconds with a JSON message body, or use `response_url` for delayed responses.

---

## Events API

Subscribe to workspace events via HTTP POST callbacks.

### Setup
1. Enable Events API in your Slack App settings.
2. Set a Request URL that handles incoming events.
3. Subscribe to event types at the bot or workspace level.

### Common Event Types

| Event Type             | Description                                        |
|------------------------|----------------------------------------------------|
| message                | A message was posted to a channel.                |
| app_mention            | The bot was @-mentioned.                          |
| member_joined_channel  | A user joined a channel.                          |
| member_left_channel    | A user left a channel.                            |
| reaction_added         | A reaction was added to a message.                |
| file_shared            | A file was shared in a channel.                   |
| channel_created        | A new channel was created.                        |
| app_home_opened        | A user opened the bot's App Home tab.             |

### Event Payload Example

```json
{
  "type": "event_callback",
  "team_id": "T0123456789",
  "event": {
    "type": "app_mention",
    "user": "U0123456789",
    "text": "<@UBOT123> summarize this channel",
    "channel": "C0123456789",
    "ts": "1234567890.123456"
  }
}
```

Your endpoint must respond with HTTP 200 and the `challenge` value during URL verification.

---

## Socket Mode vs HTTP Mode

| Feature          | HTTP Mode                        | Socket Mode                        |
|------------------|----------------------------------|------------------------------------|
| Endpoint needed  | Yes — public HTTPS URL           | No — outbound WebSocket connection |
| Best for         | Production apps                  | Development, internal tools        |
| Token type       | Bot token (xoxb-)                | App-level token (xapp-)            |
| Latency          | Depends on network/infra         | Lower, persistent connection       |

---

## Key Permission Scopes

| Scope                | Required For                              |
|----------------------|-------------------------------------------|
| chat:write           | Sending messages as the bot.             |
| channels:read        | Listing public channels.                 |
| channels:history     | Reading message history.                 |
| users:read           | Listing users and getting user info.     |
| users:read.email     | Looking up users by email.               |
| files:write          | Uploading files.                         |
| reactions:write      | Adding/removing emoji reactions.         |
| pins:write           | Pinning messages.                        |
| commands             | Registering slash commands.              |
| app_mentions:read    | Receiving @-mention events.              |
| im:write             | Opening DM conversations.                |

---

## SDKs

### Python — slack_sdk

```bash
pip install slack_sdk
```

```python
from slack_sdk import WebClient

client = WebClient(token="xoxb-...")

response = client.chat_postMessage(
    channel="#general",
    text="Hello from Python!"
)

print(response["ts"])
```

### Node.js — @slack/web-api

```bash
npm install @slack/web-api
```

```javascript
const { WebClient } = require("@slack/web-api");

const client = new WebClient("xoxb-...");

const result = await client.chat.postMessage({
  channel: "#general",
  text: "Hello from Node.js!",
});

console.log(result.ts);
```

---

## Rate Limits

Slack enforces per-method, per-workspace rate limits (Tier 1–4):

| Tier   | Limit              | Example Methods                     |
|--------|--------------------|--------------------------------------|
| Tier 1 | 1 req/min          | files.upload                        |
| Tier 2 | 20 req/min         | conversations.list, users.list      |
| Tier 3 | 50 req/min         | chat.postMessage                    |
| Tier 4 | 100+ req/min       | conversations.history               |

Exceeded requests return HTTP 429 with a `Retry-After` header.

---

## Useful Links

- API Reference: https://api.slack.com/methods
- Block Kit Builder: https://app.slack.com/block-kit-builder
- Events API: https://api.slack.com/events
- Slash Commands: https://api.slack.com/interactivity/slash-commands
- OAuth Scopes: https://api.slack.com/scopes
- Python SDK Docs: https://slack.dev/python-slack-sdk/
- Node.js SDK Docs: https://slack.dev/node-slack-sdk/
