# YouTube Data API v3 — Documentation Sources
**Date scraped:** 2026-03-01
**Scraping method:** Playwright browser automation (navigate + snapshot) + WebFetch fallback

---

## Files

| File | Title | Source URL | Status |
|------|-------|------------|--------|
| `getting-started.md` | YouTube Data API — Getting Started | https://developers.google.com/youtube/v3/getting-started | OK |
| `auth-client-side.md` | OAuth 2.0 for Client-Side Web Apps | https://developers.google.com/youtube/v3/guides/auth/client-side-web-apps | OK |
| `uploading-video.md` | Uploading a Video | https://developers.google.com/youtube/v3/guides/uploading_a_video | OK |
| `resumable-uploads.md` | Using the Resumable Upload Protocol | https://developers.google.com/youtube/v3/guides/using_resumable_upload_protocol | OK (see note) |
| `videos-insert.md` | Videos: insert | https://developers.google.com/youtube/v3/docs/videos/insert | OK |
| `videos-list.md` | Videos: list | https://developers.google.com/youtube/v3/docs/videos/list | OK |
| `videos-update.md` | Videos: update | https://developers.google.com/youtube/v3/docs/videos/update | OK |
| `videos-delete.md` | Videos: delete | https://developers.google.com/youtube/v3/docs/videos/delete | OK |
| `playlists-insert.md` | Playlists: insert | https://developers.google.com/youtube/v3/docs/playlists/insert | OK |
| `playlists-list.md` | Playlists: list | https://developers.google.com/youtube/v3/docs/playlists/list | OK |
| `playlist-items-insert.md` | PlaylistItems: insert | https://developers.google.com/youtube/v3/docs/playlistItems/insert | OK |
| `search-list.md` | Search: list | https://developers.google.com/youtube/v3/docs/search/list | OK |
| `channels-list.md` | Channels: list | https://developers.google.com/youtube/v3/docs/channels/list | OK |
| `captions-insert.md` | Captions: insert | https://developers.google.com/youtube/v3/docs/captions/insert | OK |
| `thumbnails-set.md` | Thumbnails: set | https://developers.google.com/youtube/v3/docs/thumbnails/set | OK |
| `quota-usage.md` | Quota Costs for API Requests | https://developers.google.com/youtube/v3/determine_quota_cost | OK (see note) |

---

## Notes

### resumable-uploads.md
The originally requested URL `https://developers.google.com/youtube/v3/guides/resumable_uploads` returned **404**. The correct URL is `https://developers.google.com/youtube/v3/guides/using_resumable_upload_protocol`. Content was scraped from the correct URL and saved to `resumable-uploads.md`. The 404 URL is noted in the file header.

### quota-usage.md
The originally requested URL `https://developers.google.com/youtube/v3/determine_quota_usage` returned **404**. The correct URL is `https://developers.google.com/youtube/v3/determine_quota_cost`. Content was fetched via WebFetch (Playwright browser was unavailable at the time) from the correct URL and saved to `quota-usage.md`. The 404 URL and correct URL are both noted in the file header.

---

## Snap files (intermediary)

The following snapshot files were created during scraping and can be deleted:
- `snap-getting-started.md`
- `snap-auth-client-side.md`
- `snap-resumable-uploads.md`
- `snap-channels-list.md`
