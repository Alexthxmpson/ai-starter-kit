# YouTube Data API v3 — Use Cases & Practical Guide

**Date:** 2026-03-01

---

## What You Can Do

### Free / No Auth Required
- Read public video metadata, channel info, playlists, search results (API key only, no OAuth)
- List public videos by channel, search by keyword, get video statistics

### Paid / Requires Setup
- Enable YouTube Data API v3 in Google Cloud Console — default **10,000 units/day** free quota
- API key for public data reads; OAuth 2.0 required for any write operations or private data
- Upload videos to YouTube (public, unlisted, private, or scheduled)
- Update video metadata: title, description, tags, category, privacy status, thumbnails
- Create, update, and delete playlists; add/remove videos from playlists
- Set custom thumbnails on videos
- Insert, update, and delete closed captions/subtitles
- List channel details, subscriber count, uploaded videos playlist
- Search across YouTube for videos, channels, and playlists
- Manage video comments (list, insert, moderate, delete)
- Manage subscriptions (list, add, remove)
- Upload via resumable upload protocol for large files

### What the API Cannot Do
- Access YouTube Analytics data (use YouTube Analytics API instead)
- Retrieve real-time live stream analytics
- Access monetization or revenue data
- Manage YouTube Studio settings beyond basic metadata
- Bypass copyright Content ID systems
- Return more data than the quota allows — **10,000 units/day default** (search = 100 units/call)
- Access private videos belonging to other users
- Upload videos longer than 15 minutes without a verified account (YouTube account limit, not API limit)

---

## Automation Ideas

| Use Case | Complexity | What You Do | Key Endpoint / Cost |
|---|---|---|---|
| Upload a video to YouTube | Easy | POST `videos.insert` with multipart or resumable upload | `videos.insert` — 100 units |
| Update video title, description, tags | Easy | PUT `videos.update` with `snippet` part | `videos.update` — 50 units |
| Set a custom thumbnail | Easy | POST `thumbnails.set` with image file | `thumbnails.set` — 50 units |
| Get video stats (views, likes, comments) | Easy | GET `videos.list` with `statistics` part | `videos.list` — 1 unit |
| List all videos in a channel | Easy | GET `playlistItems.list` from uploads playlist ID | `playlistItems.list` — 1 unit |
| Create a playlist | Easy | POST `playlists.insert` with title and privacy | `playlists.insert` — 50 units |
| Add a video to a playlist | Easy | POST `playlistItems.insert` with `videoId` + `playlistId` | `playlistItems.insert` — 50 units |
| Search YouTube for videos by keyword | Easy | GET `search.list` with `q` param and `type=video` | `search.list` — 100 units |
| Get channel details and subscriber count | Easy | GET `channels.list` with `statistics` part | `channels.list` — 1 unit |
| Upload subtitles/captions file | Medium | POST `captions.insert` with track name, language, and `.srt`/`.vtt` file | `captions.insert` — 400 units |
| Set video privacy to scheduled (premiere) | Medium | `videos.update` with `status.publishAt` timestamp (must be `private` first) | `videos.update` — 50 units |
| Auto-tag videos by category on upload | Medium | `videos.insert` with `snippet.tags[]` and `snippet.categoryId` | `videos.insert` — 100 units |
| Bulk update descriptions across a channel | Medium | `playlistItems.list` → loop video IDs → `videos.update` each | `playlistItems.list` (1) + `videos.update` × N (50 each) |
| Delete a video | Medium | DELETE `videos.delete` with `id` param | `videos.delete` — 50 units |
| Sync uploaded videos to a Notion database | Hard | `playlistItems.list` uploads playlist → `videos.list` per batch → upsert Notion rows | `playlistItems.list` + `videos.list` + Notion API |
| Multi-language caption workflow | Hard | Upload base video → `captions.insert` per language → update status | `captions.insert` × N — 400 units each |

---

## Key Limits and Gotchas

### Quota System — 10,000 Units/Day Default
- Every request costs units — **invalid requests still cost at least 1 unit**
- Quota resets at **midnight Pacific Time**
- Request a quota increase via the Quota extension form in Google Cloud Console

### Quota Cost Quick Reference
| Operation | Cost |
|-----------|------|
| `videos.list`, `channels.list`, `playlists.list`, `playlistItems.list` | **1 unit** |
| `videos.insert` (upload) | **100 units** |
| `search.list` | **100 units** |
| `videos.update`, `playlists.insert/update/delete`, `playlistItems.insert` | **50 units** |
| `thumbnails.set` | **50 units** |
| `captions.insert` | **400 units** |
| `captions.update` | **450 units** |

**Key implication:** With 10,000 units/day you can do roughly: 100 `search.list` calls, OR 100 video uploads, OR 10,000 metadata reads — not all at once.

### The `part` Parameter is Mandatory
- Every request requires a `part` parameter specifying which resource parts to return (e.g., `snippet`, `statistics`, `status`, `contentDetails`)
- Only request the parts you actually need — unrequested parts are not returned and don't count toward bandwidth
- `fields` parameter further filters within parts to reduce response size

### Search Is Expensive — Avoid Where Possible
- `search.list` costs **100 units per call** — same as a video upload
- To list a channel's videos cheaply: use `playlistItems.list` on the channel's uploads playlist (1 unit) instead of `search.list` filtered by `channelId`
- Prefer `videos.list`, `channels.list`, `playlists.list` (1 unit each) over search whenever the resource ID is known

### Auth
- **API key**: sufficient for read-only public data (`videos.list`, `search.list`, etc.)
- **OAuth 2.0**: required for all write operations (`videos.insert/update/delete`, `playlists.insert`, `captions.insert`, etc.) and for accessing private/unlisted content
- Scope for uploads and management: `https://www.googleapis.com/auth/youtube`
- Read-only scope: `https://www.googleapis.com/auth/youtube.readonly`

### Resumable Uploads
- Required for files > ~5 MB; strongly recommended for all video uploads
- Upload URL is valid for **1 week** from creation
- Supports interruption and resume — track byte offset
- Use `videos.insert` with `uploadType=resumable` to initiate

### Pagination
- List methods return paginated results with `nextPageToken` and `prevPageToken`
- Pass `pageToken` to retrieve next page — each page counts as a separate quota unit for `search.list` (100 units/page)
- Default max results per page: 50 (`maxResults` parameter, max 50)

### Privacy and Upload Status
- Videos start processing after upload — `processingDetails.processingStatus` transitions from `processing` → `succeeded`
- To schedule a video premiere: set `status.privacyStatus=private` + `status.publishAt` (ISO 8601 datetime)
- Private videos are only accessible to the account owner; unlisted videos accessible to anyone with the link

### ETags for Caching
- All API responses include ETags — use `If-None-Match` header to avoid re-fetching unchanged resources (returns HTTP 304)
- Reduces quota usage for polling patterns
