# Discord REST API — Technical Documentation

**Source:** https://discord.com/developers/docs/reference
**Message Resource:** https://discord.com/developers/docs/resources/message
**Channel Resource:** https://discord.com/developers/docs/resources/channel
**Date:** 2026-02-27

---

## Table of Contents

1. [Overview](#overview)
2. [API Versioning](#api-versioning)
3. [Authentication](#authentication)
4. [Rate Limits](#rate-limits)
5. [Error Handling](#error-handling)
6. [Messages](#messages)
7. [Channels](#channels)
8. [Guilds (Servers)](#guilds-servers)
9. [Roles](#roles)
10. [Webhooks](#webhooks)
11. [Interactions & Slash Commands](#interactions--slash-commands)
12. [OAuth2](#oauth2)

---

## Overview

The Discord REST API provides programmatic access to Discord resources: guilds (servers), channels, messages, users, roles, and more. It pairs with the Gateway (WebSocket) API for real-time events.

- **Base URL:** `https://discord.com/api/v10`
- **Format:** All request/response bodies are JSON
- **Current stable version:** v10

---

## API Versioning

| Version | Status     | Notes                            |
|---------|------------|----------------------------------|
| v10     | Current    | Recommended — use this           |
| v9      | Available  | Still functional                 |
| v8      | Deprecated | Avoid for new integrations       |
| v6      | Deprecated | Legacy only                      |

Always include the version in the URL:

```
https://discord.com/api/v10/channels/{channel.id}/messages
```

---

## Authentication

Discord supports three authentication methods depending on use case.

### Method 1: Bot Token

Used for bots registered in the Discord Developer Portal. Provides full API access within servers the bot is installed in.

**Header format:**

```http
Authorization: Bot YOUR_BOT_TOKEN
```

**Getting a Bot Token:**
1. Go to [discord.com/developers/applications](https://discord.com/developers/applications)
2. Create a new Application
3. Navigate to **Bot** section
4. Click **Reset Token** to generate a token
5. Copy the token — shown only once

**Example curl:**

```bash
curl "https://discord.com/api/v10/channels/123456789/messages" \
  -H "Authorization: Bot YOUR_BOT_TOKEN"
```

**Example fetch (Node.js):**

```javascript
const response = await fetch('https://discord.com/api/v10/channels/123456789/messages', {
  headers: {
    Authorization: 'Bot ' + process.env.DISCORD_BOT_TOKEN,
  },
});
const messages = await response.json();
```

---

### Method 2: Webhook URL (No Bot Required)

Webhooks let you send messages to a specific channel without any bot infrastructure. The URL itself contains the authentication.

**Webhook URL format:**

```
https://discord.com/api/webhooks/{webhook.id}/{webhook.token}
```

Create a webhook in Discord: **Channel Settings → Integrations → Webhooks → New Webhook**

**Send a message:**

```bash
curl -X POST "https://discord.com/api/webhooks/WEBHOOK_ID/WEBHOOK_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "Hello from a webhook!"}'
```

---

### Method 3: OAuth2 Bearer Token

Used when acting on behalf of a Discord user (not a bot). Required for user-authorized apps.

**Header format:**

```http
Authorization: Bearer USER_BEARER_TOKEN
```

OAuth2 flow is detailed in the [OAuth2 section](#oauth2) below.

---

## Rate Limits

Discord applies rate limits both **globally** and **per-route**.

### Global Limit
- **50 requests per second** per bot/user token
- Exceeding the global limit returns `429 Too Many Requests`

### Per-Route Limits
Each API route has its own rate limit bucket. Limits vary by endpoint.

### Rate Limit Response Headers

| Header                       | Description                                             |
|------------------------------|---------------------------------------------------------|
| `X-RateLimit-Limit`          | Max requests in this bucket                             |
| `X-RateLimit-Remaining`      | Requests remaining before rate limited                  |
| `X-RateLimit-Reset`          | Unix epoch (seconds) when the bucket resets             |
| `X-RateLimit-Reset-After`    | Seconds until the bucket resets                         |
| `X-RateLimit-Bucket`         | Unique identifier for the rate limit bucket             |
| `X-RateLimit-Global`         | `true` if the rate limit is global                      |
| `Retry-After`                | Seconds to wait before retrying (on 429 response)       |

### 429 Response Body

```json
{
  "message": "You are being rate limited.",
  "retry_after": 1.337,
  "global": false
}
```

### Invalid Request Limit
- IP addresses that make 10,000+ invalid requests (401, 403, 429) within a 10-minute window are temporarily blocked
- Avoid retrying on 403 errors without fixing the underlying issue

---

## Error Handling

### HTTP Status Codes

| Code | Meaning                                              |
|------|------------------------------------------------------|
| 200  | OK                                                   |
| 201  | Created                                              |
| 204  | No Content — success, no body                        |
| 400  | Bad Request — invalid parameters                     |
| 401  | Unauthorized — missing or invalid token              |
| 403  | Forbidden — missing permissions                      |
| 404  | Not Found — resource does not exist                  |
| 405  | Method Not Allowed                                   |
| 429  | Too Many Requests — rate limited                     |
| 502  | Gateway Unavailable — Discord outage                 |

### JSON Error Object

```json
{
  "code": 50013,
  "message": "Missing Permissions",
  "errors": {
    "content": {
      "_errors": [
        {
          "code": "BASE_TYPE_REQUIRED",
          "message": "This field is required"
        }
      ]
    }
  }
}
```

### Common Discord Error Codes

| Code  | Meaning                                                    |
|-------|------------------------------------------------------------|
| 0     | General error                                              |
| 10003 | Unknown Channel                                            |
| 10004 | Unknown Guild                                              |
| 10008 | Unknown Message                                            |
| 10011 | Unknown Role                                               |
| 10015 | Unknown Webhook                                            |
| 50001 | Missing Access                                             |
| 50013 | Missing Permissions                                        |
| 50035 | Invalid Form Body (validation error on request body)       |
| 50006 | Cannot send an empty message                               |
| 50007 | Cannot send messages to this user (DMs closed)             |
| 50016 | Timed out waiting for acknowledgment                       |
| 60003 | Two factor is required for this operation                  |
| 130000 | API resource is currently overloaded                      |

---

## Messages

### Send a Message

```
POST /channels/{channel.id}/messages
```

**Required Permission:** `SEND_MESSAGES`
**Required:** At least one of `content`, `embeds`, `components`, `files`, or `sticker_ids`

**Request Body Parameters:**

| Field             | Type     | Required | Description                                               |
|-------------------|----------|----------|-----------------------------------------------------------|
| `content`         | string   | No*      | Message text (max 2000 characters)                        |
| `tts`             | boolean  | No       | Text-to-speech (requires `SEND_TTS_MESSAGES` permission)  |
| `embeds`          | array    | No*      | Array of embed objects (max 10 embeds)                    |
| `allowed_mentions`| object   | No       | Controls who gets pinged                                  |
| `message_reference`| object  | No       | Reply to a specific message                               |
| `components`      | array    | No*      | Action rows with buttons/select menus                     |
| `sticker_ids`     | array    | No*      | Up to 3 sticker IDs                                       |
| `flags`           | integer  | No       | Message flags (e.g., `64` = ephemeral, bots only)        |
| `files`           | files    | No*      | File attachments (multipart form)                         |

*At least one required.

**Example: Simple text message**

```bash
curl -X POST "https://discord.com/api/v10/channels/CHANNEL_ID/messages" \
  -H "Authorization: Bot BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "Hello, world!"}'
```

**Example: Message with embed**

```bash
curl -X POST "https://discord.com/api/v10/channels/CHANNEL_ID/messages" \
  -H "Authorization: Bot BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Check out this embed:",
    "embeds": [
      {
        "title": "Build Successful",
        "description": "Deployment to production completed.",
        "color": 3066993,
        "fields": [
          {"name": "Environment", "value": "Production", "inline": true},
          {"name": "Duration", "value": "1m 23s", "inline": true}
        ],
        "timestamp": "2026-02-27T12:00:00.000Z",
        "footer": {"text": "Deploy Bot"}
      }
    ]
  }'
```

**Example: Reply to a message**

```json
{
  "content": "I agree!",
  "message_reference": {
    "message_id": "ORIGINAL_MESSAGE_ID",
    "channel_id": "CHANNEL_ID",
    "guild_id": "GUILD_ID"
  }
}
```

**Allowed Mentions Object:**

```json
{
  "allowed_mentions": {
    "parse": ["roles", "users", "everyone"],
    "roles": ["ROLE_ID_1"],
    "users": ["USER_ID_1"],
    "replied_user": false
  }
}
```

| `parse` value | Pings              |
|---------------|--------------------|
| `"everyone"`  | @everyone / @here  |
| `"roles"`     | All @role mentions |
| `"users"`     | All @user mentions |

**Embed Object Structure:**

```json
{
  "title": "Embed Title",
  "description": "Embed description text",
  "url": "https://example.com",
  "color": 5814783,
  "timestamp": "2026-02-27T12:00:00.000Z",
  "footer": {
    "text": "Footer text",
    "icon_url": "https://example.com/icon.png"
  },
  "image": {"url": "https://example.com/image.png"},
  "thumbnail": {"url": "https://example.com/thumb.png"},
  "author": {
    "name": "Author Name",
    "url": "https://example.com",
    "icon_url": "https://example.com/avatar.png"
  },
  "fields": [
    {"name": "Field Name", "value": "Field Value", "inline": true}
  ]
}
```

**Response:** Message object

```json
{
  "id": "987654321",
  "channel_id": "123456789",
  "author": {"id": "BOT_USER_ID", "username": "MyBot", "bot": true},
  "content": "Hello, world!",
  "timestamp": "2026-02-27T12:00:00.000+00:00",
  "edited_timestamp": null,
  "tts": false,
  "mention_everyone": false,
  "embeds": [],
  "attachments": []
}
```

---

### Get a Message

```
GET /channels/{channel.id}/messages/{message.id}
```

**Required Permission:** `READ_MESSAGE_HISTORY`

**Example Request:**

```bash
curl "https://discord.com/api/v10/channels/CHANNEL_ID/messages/MESSAGE_ID" \
  -H "Authorization: Bot BOT_TOKEN"
```

---

### Get Channel Messages (List)

```
GET /channels/{channel.id}/messages
```

**Query Parameters:**

| Parameter | Type    | Description                                              |
|-----------|---------|----------------------------------------------------------|
| `around`  | snowflake | Get messages around this message ID                    |
| `before`  | snowflake | Get messages before this message ID                    |
| `after`   | snowflake | Get messages after this message ID                     |
| `limit`   | integer | Number of messages to return (1–100, default 50)         |

**Example: Get last 20 messages**

```bash
curl "https://discord.com/api/v10/channels/CHANNEL_ID/messages?limit=20" \
  -H "Authorization: Bot BOT_TOKEN"
```

---

### Edit a Message

```
PATCH /channels/{channel.id}/messages/{message.id}
```

**Note:** Bots can only edit their own messages.

**Request Body (only include fields to change):**

```json
{
  "content": "Updated message content",
  "embeds": [...],
  "components": [...]
}
```

**Example Request:**

```bash
curl -X PATCH "https://discord.com/api/v10/channels/CHANNEL_ID/messages/MESSAGE_ID" \
  -H "Authorization: Bot BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "Edited message"}'
```

---

### Delete a Message

```
DELETE /channels/{channel.id}/messages/{message.id}
```

**Required Permission:** `MANAGE_MESSAGES` (to delete others' messages)
Bots can delete their own messages without this permission.

**Example Request:**

```bash
curl -X DELETE "https://discord.com/api/v10/channels/CHANNEL_ID/messages/MESSAGE_ID" \
  -H "Authorization: Bot BOT_TOKEN"
```

**Response:** `204 No Content`

---

### Bulk Delete Messages

```
POST /channels/{channel.id}/messages/bulk-delete
```

**Required Permission:** `MANAGE_MESSAGES`

**Request Body:**

```json
{
  "messages": ["MESSAGE_ID_1", "MESSAGE_ID_2", "MESSAGE_ID_3"]
}
```

**Constraints:**
- 2–100 messages per request
- Messages must be **less than 14 days old** (older messages cannot be bulk deleted)
- Duplicate IDs are silently ignored

---

## Channels

### Get a Channel

```
GET /channels/{channel.id}
```

**Example Request:**

```bash
curl "https://discord.com/api/v10/channels/CHANNEL_ID" \
  -H "Authorization: Bot BOT_TOKEN"
```

**Channel Object Key Fields:**

| Field                  | Type    | Description                                              |
|------------------------|---------|----------------------------------------------------------|
| `id`                   | snowflake | Channel ID                                             |
| `type`                 | integer | Channel type (see below)                                 |
| `guild_id`             | snowflake | Guild this channel belongs to                          |
| `name`                 | string  | Channel name                                             |
| `topic`                | string  | Channel topic (text channels)                            |
| `nsfw`                 | boolean | Whether channel is age-restricted                        |
| `position`             | integer | Sorting position                                         |
| `rate_limit_per_user`  | integer | Slowmode duration in seconds                             |
| `parent_id`            | snowflake | Parent category channel ID                             |
| `permission_overwrites`| array   | Per-user/role permission overrides                       |
| `last_message_id`      | snowflake | Last message sent in channel                           |

**Channel Types:**

| Value | Name                  |
|-------|-----------------------|
| 0     | GUILD_TEXT            |
| 1     | DM                    |
| 2     | GUILD_VOICE           |
| 4     | GUILD_CATEGORY        |
| 5     | GUILD_ANNOUNCEMENT    |
| 10    | ANNOUNCEMENT_THREAD   |
| 11    | PUBLIC_THREAD         |
| 12    | PRIVATE_THREAD        |
| 13    | GUILD_STAGE_VOICE     |
| 15    | GUILD_FORUM           |

---

### List Guild Channels

```
GET /guilds/{guild.id}/channels
```

Returns all channels in a guild. **Does not include threads.**

**Example Request:**

```bash
curl "https://discord.com/api/v10/guilds/GUILD_ID/channels" \
  -H "Authorization: Bot BOT_TOKEN"
```

---

### Create a Guild Channel

```
POST /guilds/{guild.id}/channels
```

**Required Permission:** `MANAGE_CHANNELS`

**Request Body:**

```json
{
  "name": "general-chat",
  "type": 0,
  "topic": "General discussion",
  "position": 1,
  "rate_limit_per_user": 5,
  "nsfw": false,
  "parent_id": "CATEGORY_CHANNEL_ID",
  "permission_overwrites": [
    {
      "id": "ROLE_ID",
      "type": 0,
      "allow": "2048",
      "deny": "0"
    }
  ]
}
```

**Key Body Parameters:**

| Field                  | Type    | Required | Description                                          |
|------------------------|---------|----------|------------------------------------------------------|
| `name`                 | string  | Yes      | Channel name (2–100 characters)                      |
| `type`                 | integer | No       | Channel type (default: 0 = text)                     |
| `topic`                | string  | No       | Channel topic (max 1024 characters for text)         |
| `position`             | integer | No       | Position in channel list                             |
| `rate_limit_per_user`  | integer | No       | Slowmode (0–21600 seconds)                           |
| `nsfw`                 | boolean | No       | Age-restrict the channel                             |
| `parent_id`            | snowflake| No      | Put inside a category                                |
| `permission_overwrites`| array   | No       | Permission overrides for specific users/roles        |
| `bitrate`              | integer | No       | Voice channels only (8000–96000)                     |
| `user_limit`           | integer | No       | Voice channel user cap (0 = unlimited)               |

---

### Modify a Channel

```
PATCH /channels/{channel.id}
```

**Required Permission:** `MANAGE_CHANNELS`
Include only fields you want to change.

**Example:** Change name and topic

```bash
curl -X PATCH "https://discord.com/api/v10/channels/CHANNEL_ID" \
  -H "Authorization: Bot BOT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "new-channel-name", "topic": "Updated topic"}'
```

---

### Delete a Channel

```
DELETE /channels/{channel.id}
```

**Required Permission:** `MANAGE_CHANNELS`

For guilds, deletes the channel. For DMs, closes the DM.

**Response:** Returns the deleted channel object.

---

## Guilds (Servers)

### Get a Guild

```
GET /guilds/{guild.id}
```

**Optional Query Parameter:**

| Parameter    | Type    | Description                                     |
|--------------|---------|-------------------------------------------------|
| `with_counts`| boolean | Include approximate member/presence counts      |

**Example Request:**

```bash
curl "https://discord.com/api/v10/guilds/GUILD_ID?with_counts=true" \
  -H "Authorization: Bot BOT_TOKEN"
```

**Key Response Fields:**

| Field                  | Description                              |
|------------------------|------------------------------------------|
| `id`                   | Guild snowflake ID                       |
| `name`                 | Guild name                               |
| `icon`                 | Icon hash                                |
| `owner_id`             | Owner user ID                            |
| `roles`                | Array of role objects                    |
| `channels`             | Array of channel objects (partial)       |
| `member_count`         | Approximate member count (with_counts)   |
| `verification_level`   | Verification level (0–4)                 |
| `premium_tier`         | Boost level (0–3)                        |

---

### List Guild Members

```
GET /guilds/{guild.id}/members
```

**Required Permission/Intent:** `GUILD_MEMBERS` privileged intent must be enabled in Developer Portal.

**Query Parameters:**

| Parameter | Type    | Description                            |
|-----------|---------|----------------------------------------|
| `limit`   | integer | Max members (1–1000, default 1)        |
| `after`   | snowflake | Fetch members after this user ID      |

---

### Get Guild Member

```
GET /guilds/{guild.id}/members/{user.id}
```

---

### Modify Guild Member

```
PATCH /guilds/{guild.id}/members/{user.id}
```

**Request Body:**

```json
{
  "nick": "New Nickname",
  "roles": ["ROLE_ID_1", "ROLE_ID_2"],
  "mute": false,
  "deaf": false
}
```

---

### Remove Guild Member (Kick)

```
DELETE /guilds/{guild.id}/members/{user.id}
```

**Required Permission:** `KICK_MEMBERS`

---

## Roles

### Get Guild Roles

```
GET /guilds/{guild.id}/roles
```

Returns an array of all role objects in the guild.

**Example Request:**

```bash
curl "https://discord.com/api/v10/guilds/GUILD_ID/roles" \
  -H "Authorization: Bot BOT_TOKEN"
```

**Role Object:**

```json
{
  "id": "ROLE_ID",
  "name": "Admin",
  "color": 16711680,
  "hoist": true,
  "position": 5,
  "permissions": "8",
  "managed": false,
  "mentionable": true
}
```

| Field         | Description                                              |
|---------------|----------------------------------------------------------|
| `id`          | Role snowflake ID                                        |
| `name`        | Role name                                                |
| `color`       | Integer color (decimal RGB)                              |
| `hoist`       | Whether role is displayed separately in sidebar          |
| `position`    | Role hierarchy position (higher = more powerful)         |
| `permissions` | Bitfield string of permissions                           |
| `managed`     | Whether managed by an integration (cannot be changed)    |
| `mentionable` | Whether users can @mention this role                     |

---

### Create a Guild Role

```
POST /guilds/{guild.id}/roles
```

**Required Permission:** `MANAGE_ROLES`

**Request Body:**

```json
{
  "name": "Moderator",
  "permissions": "8",
  "color": 3447003,
  "hoist": true,
  "mentionable": false
}
```

**Permissions Bitfield — Common Values:**

| Permission        | Bit Value  |
|-------------------|------------|
| `ADMINISTRATOR`   | `8`        |
| `MANAGE_GUILD`    | `32`       |
| `MANAGE_CHANNELS` | `16`       |
| `MANAGE_ROLES`    | `268435456`|
| `MANAGE_MESSAGES` | `8192`     |
| `KICK_MEMBERS`    | `2`        |
| `BAN_MEMBERS`     | `4`        |
| `SEND_MESSAGES`   | `2048`     |
| `READ_MESSAGE_HISTORY` | `65536` |
| `VIEW_CHANNEL`    | `1024`     |

Combine permissions with bitwise OR: e.g., `KICK_MEMBERS | BAN_MEMBERS = 6`

---

### Modify a Guild Role

```
PATCH /guilds/{guild.id}/roles/{role.id}
```

**Required Permission:** `MANAGE_ROLES`

```json
{
  "name": "Senior Moderator",
  "color": 16776960,
  "permissions": "10"
}
```

---

### Delete a Guild Role

```
DELETE /guilds/{guild.id}/roles/{role.id}
```

**Required Permission:** `MANAGE_ROLES`

**Response:** `204 No Content`

---

### Add Role to Member

```
PUT /guilds/{guild.id}/members/{user.id}/roles/{role.id}
```

**Required Permission:** `MANAGE_ROLES`

**Response:** `204 No Content`

---

### Remove Role from Member

```
DELETE /guilds/{guild.id}/members/{user.id}/roles/{role.id}
```

**Required Permission:** `MANAGE_ROLES`

**Response:** `204 No Content`

---

## Webhooks

Webhooks allow sending messages to a channel without a bot. They only require the webhook URL.

### Create a Webhook

```
POST /channels/{channel.id}/webhooks
```

**Required Permission:** `MANAGE_WEBHOOKS`

**Request Body:**

```json
{
  "name": "Build Notifier",
  "avatar": null
}
```

**Response:** Webhook object including `id`, `token`, and `url`.

---

### Get Channel Webhooks

```
GET /channels/{channel.id}/webhooks
```

---

### Execute (Send Message via) Webhook

```
POST /webhooks/{webhook.id}/{webhook.token}
```

No authentication header required — the URL token authenticates the request.

**Query Parameters:**

| Parameter | Type    | Description                                                          |
|-----------|---------|----------------------------------------------------------------------|
| `wait`    | boolean | `true` to receive the created message object in response             |
| `thread_id`| snowflake | Post into a thread instead of the main channel                   |

**Request Body Parameters:**

| Field      | Type   | Required | Description                                              |
|------------|--------|----------|----------------------------------------------------------|
| `content`  | string | No*      | Message text (max 2000 characters)                       |
| `username` | string | No       | Override the webhook's display name                      |
| `avatar_url`| string| No       | Override the webhook's avatar with an image URL          |
| `tts`      | boolean| No       | Text-to-speech                                           |
| `embeds`   | array  | No*      | Array of embed objects (max 10)                          |
| `allowed_mentions` | object | No | Control mentions                                   |
| `components`| array | No*      | Message components (buttons, selects)                    |

*At least one of `content`, `embeds`, `components`, or `files` is required.

**Example: Simple webhook message**

```bash
curl -X POST "https://discord.com/api/webhooks/WEBHOOK_ID/WEBHOOK_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "Deployment complete!"}'
```

**Example: Rich embed notification**

```bash
curl -X POST "https://discord.com/api/webhooks/WEBHOOK_ID/WEBHOOK_TOKEN?wait=true" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "CI Bot",
    "avatar_url": "https://example.com/bot-avatar.png",
    "embeds": [
      {
        "title": "Build #42 Succeeded",
        "description": "Branch `main` deployed to production.",
        "color": 5763719,
        "fields": [
          {"name": "Commit", "value": "`a1b2c3d`", "inline": true},
          {"name": "Author", "value": "Alexander", "inline": true},
          {"name": "Duration", "value": "1m 45s", "inline": true}
        ],
        "timestamp": "2026-02-27T12:00:00.000Z"
      }
    ]
  }'
```

---

### Edit a Webhook Message

```
PATCH /webhooks/{webhook.id}/{webhook.token}/messages/{message.id}
```

```json
{
  "content": "Updated content",
  "embeds": [...]
}
```

---

### Delete a Webhook Message

```
DELETE /webhooks/{webhook.id}/{webhook.token}/messages/{message.id}
```

**Response:** `204 No Content`

---

## Interactions & Slash Commands

### Overview

Slash commands are registered globally or per-guild. When a user invokes one, Discord sends an **Interaction** payload to your configured **Interactions Endpoint URL** (set in Developer Portal) or via Gateway.

### Register Global Application Commands

```
PUT /applications/{application.id}/commands
```

**Note:** Overwrites the entire global command list. Global commands take up to 1 hour to propagate.

**Request Body (array of command objects):**

```json
[
  {
    "name": "ping",
    "description": "Replies with Pong!",
    "type": 1
  },
  {
    "name": "deploy",
    "description": "Trigger a deployment",
    "type": 1,
    "options": [
      {
        "name": "environment",
        "description": "Target environment",
        "type": 3,
        "required": true,
        "choices": [
          {"name": "Production", "value": "production"},
          {"name": "Staging", "value": "staging"}
        ]
      }
    ]
  }
]
```

**Command Types:**

| Value | Name         | Description                          |
|-------|--------------|--------------------------------------|
| 1     | CHAT_INPUT   | Slash command                        |
| 2     | USER         | Right-click user context menu        |
| 3     | MESSAGE      | Right-click message context menu     |

**Option Types:**

| Value | Name          |
|-------|---------------|
| 1     | SUB_COMMAND   |
| 2     | SUB_COMMAND_GROUP |
| 3     | STRING        |
| 4     | INTEGER       |
| 5     | BOOLEAN       |
| 6     | USER          |
| 7     | CHANNEL       |
| 8     | ROLE          |
| 9     | MENTIONABLE   |
| 10    | NUMBER        |

---

### Register Guild-Specific Commands

```
PUT /applications/{application.id}/guilds/{guild.id}/commands
```

Guild commands are **instant** — no propagation delay. Best for testing and server-specific commands.

---

### Get All Global Commands

```
GET /applications/{application.id}/commands
```

---

### Delete a Global Command

```
DELETE /applications/{application.id}/commands/{command.id}
```

**Response:** `204 No Content`

---

### Responding to an Interaction

When Discord sends an interaction to your endpoint, you must respond within **3 seconds** or the interaction will fail.

**POST your-endpoint (Discord sends this):**

```json
{
  "id": "INTERACTION_ID",
  "token": "INTERACTION_TOKEN",
  "type": 2,
  "data": {
    "name": "ping",
    "options": []
  },
  "guild_id": "GUILD_ID",
  "channel_id": "CHANNEL_ID",
  "member": {...}
}
```

**You respond with:**

```json
{
  "type": 4,
  "data": {
    "content": "Pong!",
    "flags": 64
  }
}
```

**Interaction Response Types:**

| Value | Name                              | Description                                      |
|-------|-----------------------------------|--------------------------------------------------|
| 1     | PONG                              | ACK a Ping (for endpoint verification)           |
| 4     | CHANNEL_MESSAGE_WITH_SOURCE       | Respond with a message                           |
| 5     | DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE | Show "thinking..." indicator, respond later   |
| 6     | DEFERRED_UPDATE_MESSAGE           | ACK component interaction, update message later  |
| 7     | UPDATE_MESSAGE                    | Update the existing message (components)         |

**`flags: 64`** makes the response ephemeral (only visible to the user who invoked the command).

---

### Follow-Up Messages (after defer)

If you use response type `5` (deferred), you have **15 minutes** to send the actual response:

```
POST /webhooks/{application.id}/{interaction.token}
```

```json
{
  "content": "Here's your result after processing!"
}
```

---

## OAuth2

### Authorization URL

```
https://discord.com/oauth2/authorize
  ?client_id=YOUR_CLIENT_ID
  &redirect_uri=YOUR_REDIRECT_URI
  &response_type=code
  &scope=identify+guilds+bot
  &permissions=2048
```

### Exchange Code for Token

```
POST https://discord.com/api/v10/oauth2/token
```

```
Content-Type: application/x-www-form-urlencoded

client_id=YOUR_CLIENT_ID
&client_secret=YOUR_CLIENT_SECRET
&grant_type=authorization_code
&code=AUTH_CODE_FROM_REDIRECT
&redirect_uri=YOUR_REDIRECT_URI
```

**Response:**

```json
{
  "access_token": "USER_BEARER_TOKEN",
  "token_type": "Bearer",
  "expires_in": 604800,
  "refresh_token": "REFRESH_TOKEN",
  "scope": "identify guilds"
}
```

### Common OAuth2 Scopes

| Scope               | Description                                             |
|---------------------|---------------------------------------------------------|
| `identify`          | Read basic user info (id, username, avatar)             |
| `email`             | Read user's email address                               |
| `guilds`            | List user's guilds                                      |
| `guilds.join`       | Add user to a guild                                     |
| `bot`               | Add a bot to a guild (requires `permissions` param)     |
| `applications.commands` | Create slash commands on behalf of the app          |
| `webhook.incoming`  | Create webhooks in guilds                               |
| `messages.read`     | Read user's direct messages                             |

---

## Quick Reference: Endpoint Cheat Sheet

| Action                          | Method | Path                                                              |
|---------------------------------|--------|-------------------------------------------------------------------|
| Send message                    | POST   | `/channels/{channel.id}/messages`                                 |
| Get message                     | GET    | `/channels/{channel.id}/messages/{message.id}`                    |
| List messages                   | GET    | `/channels/{channel.id}/messages`                                 |
| Edit message                    | PATCH  | `/channels/{channel.id}/messages/{message.id}`                    |
| Delete message                  | DELETE | `/channels/{channel.id}/messages/{message.id}`                    |
| Bulk delete messages             | POST   | `/channels/{channel.id}/messages/bulk-delete`                     |
| Get channel                     | GET    | `/channels/{channel.id}`                                          |
| Modify channel                  | PATCH  | `/channels/{channel.id}`                                          |
| Delete channel                  | DELETE | `/channels/{channel.id}`                                          |
| List guild channels             | GET    | `/guilds/{guild.id}/channels`                                     |
| Create guild channel            | POST   | `/guilds/{guild.id}/channels`                                     |
| Get guild                       | GET    | `/guilds/{guild.id}`                                              |
| List guild members              | GET    | `/guilds/{guild.id}/members`                                      |
| Modify guild member             | PATCH  | `/guilds/{guild.id}/members/{user.id}`                            |
| Get guild roles                 | GET    | `/guilds/{guild.id}/roles`                                        |
| Create guild role               | POST   | `/guilds/{guild.id}/roles`                                        |
| Modify guild role               | PATCH  | `/guilds/{guild.id}/roles/{role.id}`                              |
| Delete guild role               | DELETE | `/guilds/{guild.id}/roles/{role.id}`                              |
| Add role to member              | PUT    | `/guilds/{guild.id}/members/{user.id}/roles/{role.id}`            |
| Remove role from member         | DELETE | `/guilds/{guild.id}/members/{user.id}/roles/{role.id}`            |
| Create webhook                  | POST   | `/channels/{channel.id}/webhooks`                                 |
| Execute webhook                 | POST   | `/webhooks/{webhook.id}/{webhook.token}`                          |
| Edit webhook message            | PATCH  | `/webhooks/{webhook.id}/{webhook.token}/messages/{message.id}`    |
| Delete webhook message          | DELETE | `/webhooks/{webhook.id}/{webhook.token}/messages/{message.id}`    |
| Register global commands        | PUT    | `/applications/{app.id}/commands`                                 |
| Register guild commands         | PUT    | `/applications/{app.id}/guilds/{guild.id}/commands`               |
| Get global commands             | GET    | `/applications/{app.id}/commands`                                 |
| Delete global command           | DELETE | `/applications/{app.id}/commands/{command.id}`                    |
