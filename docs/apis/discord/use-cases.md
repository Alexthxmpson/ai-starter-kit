# Discord REST API — Use Cases & Practical Guide

**Date:** 2026-02-27

---

## What You Can Do

### Sending Messages (Bots)
- Post text messages to any channel your bot has access to
- Send rich embeds with titles, descriptions, fields, images, colors, and timestamps
- Reply to specific messages with `message_reference`
- Edit your bot's own messages after sending
- Delete messages (your own without extra perms, others' with `MANAGE_MESSAGES`)
- Bulk delete up to 100 messages at once (must be under 14 days old)
- Send messages with file attachments (multipart form data)

### Sending Messages (Webhooks — No Bot)
- Post to any channel that has a webhook set up, using just the webhook URL
- Customize the display name and avatar per-message (override bot identity)
- Send embeds, text, and components
- Edit and delete your own webhook messages after sending
- Post into threads via `?thread_id=` parameter

### Channel Management
- List all channels in a guild
- Create text, voice, category, forum, stage, and thread channels
- Modify channel settings: name, topic, slowmode, NSFW flag, position, category
- Delete channels
- Set per-channel permission overwrites for specific users or roles

### Guild (Server) Management
- Get server info including name, icon, boost level, member count
- List all guild members (requires `GUILD_MEMBERS` privileged intent)
- Modify members: set nickname, assign/remove roles, mute/deafen in voice
- Kick and ban members

### Role Management
- List all roles in a guild
- Create new roles with custom name, color, permissions, and hoisting
- Modify existing roles
- Delete roles
- Assign or remove roles from specific members

### Slash Commands / Interactions
- Register global slash commands (available in all servers, ~1 hour propagation)
- Register guild-specific slash commands (instant, good for testing)
- Handle interaction payloads at your HTTP endpoint
- Respond to interactions with messages (ephemeral or visible)
- Defer responses and follow up within 15 minutes for slow operations
- Create user context menu and message context menu commands

### Notifications & Automation
- Send formatted notifications to Discord channels from any external service
- Build CI/CD pipelines that report build/deploy status
- Monitor external APIs and alert channels on events
- Automate moderation actions (role assignment, message deletion)

---

## Practical Automation & Project Ideas

| Idea | What to Build | Auth Method | Key Endpoints |
|------|---------------|-------------|---------------|
| **CI/CD build notifier** | Send embed to #deployments when GitHub Actions passes or fails | Webhook URL | `POST /webhooks/{id}/{token}` |
| **Error alerting** | Pipe application exceptions to a #errors channel with stack trace in embed | Webhook URL | `POST /webhooks/{id}/{token}` |
| **Uptime monitor** | Check your services every 5 min and post to #status when down/recovered | Webhook URL | `POST /webhooks/{id}/{token}` |
| **Daily digest bot** | Post a morning summary embed of analytics/metrics to a channel | Bot Token | `POST /channels/{id}/messages` |
| **Welcome bot** | DM new members a welcome message and assign a "New Member" role | Bot Token + Gateway | `PATCH /guilds/{id}/members/{user.id}`, `POST /channels/{dm.id}/messages` |
| **Role assignment bot** | Users click a button to self-assign roles (e.g., game preferences) | Bot Token | `PUT /guilds/{id}/members/{user.id}/roles/{role.id}` |
| **Slash command deploy trigger** | `/deploy production` in Discord triggers a Vercel API deployment | Bot Token | `PUT /applications/{id}/commands`, then call Vercel API |
| **Channel archiver** | Slash command to create a read-only archive of a channel's messages | Bot Token | `GET /channels/{id}/messages`, `POST /guilds/{id}/channels` |
| **Announcement cross-poster** | Mirror posts from one server's #announcements to another server via webhook | Bot Token | `GET /channels/{id}/messages`, `POST /webhooks/{id}/{token}` |
| **Ticket system** | `/ticket` creates a private thread, assigns support role, notifies team | Bot Token | `POST /guilds/{id}/channels` (thread), `PUT /guilds/{id}/members/{user.id}/roles/{role.id}` |
| **Poll system** | `/poll "Question" "A" "B"` creates an embed with reaction-based voting | Bot Token | `POST /channels/{id}/messages`, add reactions |
| **Log channel** | Mirror moderation actions (kicks, bans, edits) to a private #audit-log | Bot Token + Gateway | `POST /channels/{id}/messages` |
| **Scheduled announcements** | Cron job that posts weekly announcements at a set time | Webhook URL | `POST /webhooks/{id}/{token}` |
| **Form submission notifier** | Website contact form posts submission details to a Discord channel | Webhook URL | `POST /webhooks/{id}/{token}` |

---

## Choosing Your Auth Method

| Scenario | Use |
|----------|-----|
| Just need to send messages to one channel from an external service | **Webhook URL** — simplest, no bot setup needed |
| Need to read messages, manage members, or react to events | **Bot Token** |
| Need to act on behalf of a specific user | **OAuth2 Bearer Token** |
| Need slash commands with UI components | **Bot Token** + interactions endpoint |

---

## Key Limits & Gotchas

### Messages
- `content` max: **2000 characters** — split long messages or use embeds
- Max **10 embeds** per message
- Each embed: title max 256 chars, description max 4096 chars, field value max 1024 chars, total embed limit 6000 chars
- File attachments: **10 MiB default** per file (higher for Nitro/boosted servers)
- Bulk delete only works on messages **less than 14 days old** — older messages must be deleted one at a time
- Bots can only edit **their own messages** — cannot edit other users' messages
- To delete someone else's message, the bot needs `MANAGE_MESSAGES` permission

### Webhooks
- Webhook messages **cannot mention @everyone** or @roles by default — must set `allowed_mentions` explicitly
- Webhook `username` override does **not** bypass Discord's display name sanitization
- Webhook `avatar_url` must be a direct image URL (not redirects)
- `wait=true` query param is required if you need the message ID back (for later editing/deleting)
- Webhooks have their own rate limits separate from bot rate limits

### Rate Limits
- Global limit: **50 requests/second** per token
- Per-route limits vary — check `X-RateLimit-Remaining` on every response
- When you hit 429, **stop immediately** and wait `retry_after` seconds from the response body
- Sending 10,000+ invalid requests from one IP within 10 minutes = **temporary IP ban**
- Sending messages to the same channel rapidly will hit tighter per-channel rate limits
- Webhooks have a limit of approximately **30 messages per minute per webhook**

### Permissions & Intents
- Bots must be in the server and have the required permissions for each action
- `GUILD_MEMBERS` is a **privileged intent** — must be enabled in Developer Portal AND in your code to read member lists
- `MESSAGE_CONTENT` is a **privileged intent** since 2022 — bots cannot read message content without it enabled
- Permission integers are **bitfields** — combine with bitwise OR, check with bitwise AND
- When a bot joins a server, it only gets permissions granted to it during the OAuth2 install flow

### Slash Commands
- Global command registration can take **up to 1 hour** to propagate — use guild commands while developing
- You must respond to an interaction within **3 seconds** or Discord marks it as failed
- If you use deferred response (type 5), you have **15 minutes** to follow up
- Overwrites global commands with PUT — always send the **complete** list of desired commands
- Commands are tied to the `application.id`, not the bot token directly
- You need the `applications.commands` OAuth2 scope to register commands in other guilds

### Channels & Guilds
- `GET /guilds/{id}/channels` does **not** include threads — use separate thread endpoints
- Creating a channel requires `MANAGE_CHANNELS` permission
- When setting `permission_overwrites`, bots can only allow/deny permissions they themselves hold
- `rate_limit_per_user` (slowmode) range: 0–21600 seconds (6 hours max)
- Deleting a category does **not** delete its child channels — they become uncategorized

### Roles
- Permissions are stored as a **string representation of a bitfield integer** — parse as BigInt in JavaScript
- Bots can only manage roles **below their highest role** in the hierarchy
- The `@everyone` role ID is always equal to the guild ID
- `managed: true` roles (from integrations/bots) cannot be manually assigned or modified

### IDs (Snowflakes)
- All Discord IDs are **64-bit integers** encoded as strings in JSON
- In JavaScript, use `BigInt` or a library — regular `Number` will lose precision on large IDs
- Snowflakes contain a timestamp: `(BigInt(id) >> 22n) + 1420070400000n` gives creation timestamp in ms

---

## Minimal Working Examples

### Webhook — Send a formatted deploy notification (no bot needed)

```javascript
const WEBHOOK_URL = process.env.DISCORD_WEBHOOK_URL;

await fetch(WEBHOOK_URL, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    username: 'Deploy Bot',
    embeds: [{
      title: 'Deployment Complete',
      description: 'Production updated successfully.',
      color: 5763719, // green
      fields: [
        { name: 'Environment', value: 'Production', inline: true },
        { name: 'Commit', value: '`a1b2c3d`', inline: true },
      ],
      timestamp: new Date().toISOString(),
    }],
  }),
});
```

### Bot — Send a message to a channel

```javascript
const BOT_TOKEN = process.env.DISCORD_BOT_TOKEN;
const CHANNEL_ID = '123456789012345678';

await fetch(`https://discord.com/api/v10/channels/${CHANNEL_ID}/messages`, {
  method: 'POST',
  headers: {
    Authorization: `Bot ${BOT_TOKEN}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    content: 'Alert: database CPU exceeded 90%',
    allowed_mentions: { parse: [] }, // suppress all @mentions
  }),
});
```

### Bot — Assign a role to a user

```javascript
await fetch(`https://discord.com/api/v10/guilds/${GUILD_ID}/members/${USER_ID}/roles/${ROLE_ID}`, {
  method: 'PUT',
  headers: { Authorization: `Bot ${BOT_TOKEN}` },
});
```

### Slash command — Register then respond

```javascript
// 1. Register command (run once)
await fetch(`https://discord.com/api/v10/applications/${APP_ID}/guilds/${GUILD_ID}/commands`, {
  method: 'PUT',
  headers: {
    Authorization: `Bot ${BOT_TOKEN}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify([{
    name: 'ping',
    description: 'Replies with Pong!',
    type: 1,
  }]),
});

// 2. Handle interaction at your HTTP endpoint (must respond within 3 seconds)
app.post('/interactions', (req, res) => {
  const interaction = req.body;
  if (interaction.type === 1) return res.json({ type: 1 }); // PING verification
  if (interaction.data.name === 'ping') {
    return res.json({
      type: 4, // CHANNEL_MESSAGE_WITH_SOURCE
      data: { content: 'Pong!', flags: 64 }, // flags: 64 = ephemeral
    });
  }
});
```
