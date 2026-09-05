# Instagram Graph API Documentation — Sources
**Date scraped:** 2026-03-01
**Output directory:** `C:/Users/Aleki/api-docs/instagram-graph-api/`

---

## Notes on URL Structure

Meta has reorganized all Instagram developer documentation. The old `instagram-api` URL namespace has largely been replaced by `instagram-platform`. Most old URLs redirect automatically to new ones, but some returned 404 or the new page content differs structurally from the original.

**Old base:** `https://developers.facebook.com/docs/instagram-api/`
**New base:** `https://developers.facebook.com/docs/instagram-platform/`

---

## Source Pages

| File | Original URL (requested) | Actual URL scraped | Status | Notes |
|---|---|---|---|---|
| `overview.md` | https://developers.facebook.com/docs/instagram-api/overview | https://developers.facebook.com/docs/instagram-platform/overview | Redirected | Full platform overview |
| `getting-started.md` | https://developers.facebook.com/docs/instagram-api/getting-started | N/A | 404 | Page not found. File contains redirect guidance to current entry points. |
| `content-publishing.md` | https://developers.facebook.com/docs/instagram-api/guides/content-publishing | https://developers.facebook.com/docs/instagram-platform/content-publishing | Redirected | Comprehensive guide; covers photo, video, reels, stories, carousels |
| `publish-photo.md` | https://developers.facebook.com/docs/instagram-api/guides/content-publishing/photo | N/A | No separate page | Consolidated into main content-publishing guide. File contains extracted photo-specific info. |
| `publish-video.md` | https://developers.facebook.com/docs/instagram-api/guides/content-publishing/video | N/A | No separate page | Consolidated into main content-publishing guide. File contains extracted video-specific info. |
| `publish-reels.md` | https://developers.facebook.com/docs/instagram-api/guides/content-publishing/reels | N/A | No separate page | Consolidated into main content-publishing guide. File contains extracted reels-specific info including Trial Reels. |
| `publish-stories.md` | https://developers.facebook.com/docs/instagram-api/guides/content-publishing/stories | https://developers.facebook.com/docs/instagram-platform/sharing-to-stories | Redirected (different content) | New page covers mobile SDK approach (Android/iOS). Graph API story publishing via `media_type=STORIES` is covered in content-publishing.md. |
| `publish-carousel.md` | https://developers.facebook.com/docs/instagram-api/guides/content-publishing/carousel | N/A | No separate page | Consolidated into main content-publishing guide. File contains extracted carousel-specific info. |
| `ig-media-reference.md` | https://developers.facebook.com/docs/instagram-api/reference/ig-media | https://developers.facebook.com/docs/instagram-platform/reference/instagram-media | Redirected | Full IG Media fields, edges, CRUD operations |
| `ig-user-media-edge.md` | https://developers.facebook.com/docs/instagram-api/reference/ig-user/media | https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/media | Redirected | POST and GET on IG User media edge; all container parameters |
| `ig-user-media-publish.md` | https://developers.facebook.com/docs/instagram-api/reference/ig-user/media_publish | https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/media_publish | Redirected | Publish endpoint reference |
| `mentions.md` | https://developers.facebook.com/docs/instagram-api/guides/mentions | https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/mentions | Redirected | IG User Mentions edge reference |
| `hashtag-search.md` | https://developers.facebook.com/docs/instagram-api/guides/hashtag-search | https://developers.facebook.com/docs/instagram-platform/instagram-api-with-facebook-login/hashtag-search | Redirected | Hashtag search guide; Facebook Login only |
| `insights.md` | https://developers.facebook.com/docs/instagram-api/guides/insights | https://developers.facebook.com/docs/instagram-platform/insights | Redirected | Insights guide with examples |
| `ig-user-reference.md` | https://developers.facebook.com/docs/instagram-api/reference/ig-user | https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user | Redirected | Full IG User reference; all fields and edges |
| `ig-user-insights.md` | https://developers.facebook.com/docs/instagram-api/reference/ig-user/insights | https://developers.facebook.com/docs/instagram-platform/api-reference/instagram-user/insights | Redirected | Full account insights reference; all metrics with period/breakdown/metric_type |

---

## Raw Snapshot Files (Intermediate — can be deleted)

These files were created as intermediate working files during scraping. They contain the raw Playwright accessibility tree YAML and are not needed for reference.

- `raw_overview.md`
- `raw_content-publishing.md`
- `raw_ig-user-media.md`
- `raw_ig-media.md`
- `raw_ig-user-reference.md`
- `raw_ig-user-insights.md`

---

## Key Findings

1. **Meta restructured their docs.** All old `instagram-api` guide URLs now redirect to `instagram-platform` equivalents. The sub-guides for photo, video, reels, and carousel no longer exist as separate pages — all content is consolidated in the main `/content-publishing` page.

2. **Two API configurations.** The Instagram Platform now has two distinct API paths:
   - Instagram API with Instagram Login (`graph.instagram.com`, `instagram_business_*` permissions)
   - Instagram API with Facebook Login (`graph.facebook.com`, `instagram_basic`/`instagram_manage_*` permissions)

3. **Hashtag Search is Facebook Login only.** The Hashtag Search feature is not available for Instagram API with Instagram Login.

4. **`impressions` metric deprecated.** The `impressions` metric for account insights is deprecated as of v22.0 and will be fully removed April 21, 2025. The replacement is the `views` metric.

5. **Stories via mobile SDK vs. Graph API.** The `/sharing-to-stories` page covers the mobile SDK approach. Stories published via the Graph API use `media_type=STORIES` in the `/media` endpoint, which is documented in `content-publishing.md`.
