# HeyGen API — Technical Documentation

**Source:** https://docs.heygen.com/
**Date documented:** 2026-02-28
**Product:** HeyGen — AI avatar video generation platform

---

## 1. Overview

HeyGen enables programmatic creation of AI avatar videos — generate talking-head videos from text scripts, clone voices, use templates for personalized video at scale, and run interactive real-time streaming avatars. Core use cases: video generation, avatar management, template personalization, voice synthesis, and live streaming sessions.

**Env variable name:** `HEYGEN_API_KEY`

---

## 2. Base URLs

| Service | Base URL |
|---------|----------|
| Main API | `https://api.heygen.com` |
| OAuth tokens | `https://api2.heygen.com/v1/oauth/token` |
| OAuth refresh | `https://api2.heygen.com/v1/oauth/refresh_token` |

Endpoints use a mix of `/v1`, `/v2`, and `/v3` versions — check each endpoint individually.

---

## 3. Authentication

### Method 1: API Key (Recommended)

Include your API key in every request header:

```http
X-API-Key: YOUR_API_KEY
```

**Example:**
```bash
curl -X POST "https://api.heygen.com/v1/video_agent/generate" \
  -H "X-API-Key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Introduce our product in 30 seconds"}'
```

### Method 2: OAuth 2.0

For multi-user applications. Supports Authorization Code Flow with PKCE.

1. Redirect user to HeyGen's authorization page (include `client_id`, `redirect_uri`, `state`, `code_challenge`)
2. Exchange code for tokens:

```http
POST https://api2.heygen.com/v1/oauth/token
Content-Type: application/json

{
  "code": "AUTHORIZATION_CODE",
  "client_id": "YOUR_CLIENT_ID",
  "client_secret": "YOUR_CLIENT_SECRET",
  "redirect_uri": "YOUR_REDIRECT_URI",
  "grant_type": "authorization_code"
}
```

3. Use access token as `Authorization: Bearer YOUR_ACCESS_TOKEN`
4. Refresh using `refresh_token` when access token expires

---

## 4. Key Endpoints

### 4.1 Video Generation

#### Generate Avatar Video (Agent — simple prompt)
```
POST /v1/video_agent/generate
```
```json
{
  "prompt": "Introduce our product in 30 seconds",
  "model": "model_name",
  "voice_id": "voice_id"
}
```

#### Generate Avatar Video from Script
```
POST /v1/video_generate
```
Full control over avatar, voice, background, and script segments.

**Video response fields:**
```json
{
  "video_id": "unique_id",
  "video_url": "https://...",
  "status": "processing",
  "created_at": "2026-02-28T00:00:00Z"
}
```

Videos are created **asynchronously** — they return `"status": "processing"` initially. Poll or use webhooks to detect completion.

---

### 4.2 Avatar Management

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/v2/avatars` | List all available avatars |
| GET | `/v2/avatar/{avatar_id}/details` | Get avatar details |
| GET | `/v2/avatar_group/{group_id}/avatars` | List avatars in a group |
| GET | `/v1/streaming/avatar.list` | List streaming/interactive avatars |

---

### 4.3 Voice Management

#### List Voices (V2)
```
GET /v1/audio/voices
```

Returns 300+ voices across 175+ languages.

**TTS models:**

| Model | Description |
|-------|-------------|
| Multilingual v2 | Default — multi-language support |
| Turbo v2 | English-specific, faster |
| Multilingual Turbo | Faster multi-language |

**Third-party integrations available:** ElevenLabs (1K+ voices), OpenAI, Resemble AI

#### Text-to-Speech
```
POST /v1/audio/text_to_speech
```
```json
{
  "text": "Hello, welcome to our platform.",
  "voice_id": "VOICE_ID"
}
```

---

### 4.4 Template Personalization

#### Generate from Template (V3)
```
POST /v1/template_video_create
```

Templates use `{{variable_name}}` placeholders. Variable types: text, images, videos, voices, avatars, audio.

**Example:**
```json
{
  "template_id": "TEMPLATE_ID",
  "variables": {
    "name": { "type": "text", "value": "Alexander" },
    "company": { "type": "text", "value": "Acme Corp" }
  }
}
```

#### List Templates
```
GET /v1/template_list
```

#### Get Template Details
```
GET /v1/template/{template_id}
```

---

### 4.5 Streaming / Interactive Avatars

Real-time avatar sessions over WebSocket/WebRTC. Used for live AI agents, customer service bots, virtual presenters.

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/v1/streaming.new` | Create session |
| POST | `/v1/streaming.start` | Start streaming |
| POST | `/v1/streaming.task` | Send command to avatar |

**JS SDK:** `@heygen/streaming-avatar` (npm)
```bash
npm install @heygen/streaming-avatar
```

LiveKit integration supported for custom streaming infrastructure.

---

### 4.6 Video Translation

```
POST /v1/video_translate/translate
```

Translates existing videos into another language.

---

### 4.7 Webhooks

#### Register webhook
```
POST /v1/webhook/add
```
```json
{
  "url": "https://your-app.com/heygen-webhook",
  "events": ["avatar_video.success", "avatar_video.fail"]
}
```

#### List available events
```
GET /v1/webhook/events
```

#### Webhook events

| Event | Trigger |
|-------|---------|
| `avatar_video.success` | Video generation completed |
| `avatar_video.fail` | Video generation failed |
| `video_agent.success` | Video agent generation done |
| `video_agent.fail` | Video agent generation failed |
| `video_translate.success` | Translation completed |
| `video_translate.fail` | Translation failed |
| `personalized_video` | Personalized video event |

Verify webhook requests using the secret key provided at registration.

---

## 5. Input Limits

| Item | Limit |
|------|-------|
| Script text | Max 1,500 characters per input |
| API text | Recommended < 5,000 characters |
| Encoding | UTF-8 |

---

## 6. Output Specs

| Feature | Detail |
|---------|--------|
| Format | WebM |
| Free plan resolution | 720p max |
| Paid plans | 1080p |
| 4K | Enterprise/Team only |
| Processing | Asynchronous |

---

## 7. Rate Limits & Pricing

| Plan | Cost | Credits/Month |
|------|------|---------------|
| Free | Free | 10 credits |
| Pro | $99/mo | 100 credits |
| Scale | Custom | 660 credits |
| Enterprise | Custom | Custom |

- Credits expire 30 days after issuance
- No free credits available as of February 2026
- Pay-as-you-go available outside subscription

**Rate limit error codes:**

| Code | Meaning |
|------|---------|
| `400140` | Daily rate limit exceeded |
| `10007` | Concurrent limit reached — upgrade plan |

Returns `HTTP 429` when limits are exceeded.

---

## 8. Error Codes

| Status | Meaning | Action |
|--------|---------|--------|
| `200` | Success | — |
| `400` | Bad request | Check request body and error code |
| `401` | Unauthorized | Verify API key |
| `429` | Rate limited | Back off and retry |
| `500` | Server error | Retry |

**Error response format:**
```json
{
  "code": "error_code",
  "message": "Human-readable description"
}
```

---

## 9. SDKs

| Language | Package |
|----------|---------|
| JavaScript (streaming) | `@heygen/streaming-avatar` (npm) |
| Python | No official SDK — use direct HTTP |
| TypeScript (community) | `heygen-typescript-sdk` (teamduality) |

---

## 10. Key Limitations

1. **Async video generation** — all videos are created asynchronously; must poll or use webhooks.
2. **Concurrency cap** — limited simultaneous video jobs per plan; `"Pending"` status means you've hit the limit.
3. **Text length** — 1,500 character max per script segment.
4. **No batch operations** — videos submit individually.
5. **No free credits** — as of February 2026, free plan limited to 10 credits/month only.
6. **OAuth token expiry** — access tokens expire; implement refresh token flow.
7. **4K is enterprise-only** — standard plans cap at 1080p.
8. **Security safeguards** — HeyGen may temporarily block activity that resembles abuse.

---

## 11. Sources

- [HeyGen API Documentation](https://docs.heygen.com/)
- [Authentication](https://docs.heygen.com/reference/authentication)
- [Create Avatar Video V2](https://docs.heygen.com/reference/create-an-avatar-video-v2)
- [Generate Video from Template V3](https://docs.heygen.com/docs/generate-video-from-template-v3)
- [Webhook Events](https://docs.heygen.com/docs/using-heygens-webhook-events)
- [API Limits](https://docs.heygen.com/reference/limits)
- [Error Responses](https://docs.heygen.com/reference/errors)
- [Streaming Avatar SDK](https://docs.heygen.com/docs/streaming-avatar-sdk)
- [OAuth 2.0 Guide](https://docs.heygen.com/docs/connecting-your-app-to-heygen-with-oauth-20)
- [API Pricing](https://www.heygen.com/api-pricing)
