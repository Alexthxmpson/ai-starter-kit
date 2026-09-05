# Notion API Documentation — Sources

**Date scraped:** 2026-03-01
**API version (latest):** 2025-09-03
**Base URL:** https://api.notion.com/v1

---

## Scraped pages

| File | Title | Source URL | Notes |
|------|-------|-----------|-------|
| `overview.md` | Introduction | https://developers.notion.com/reference/intro | Base URL, pagination, REST conventions |
| `capabilities.md` | Integration capabilities | https://developers.notion.com/reference/capabilities | Content, comment, user capability tiers |
| `rate-limits.md` | Request limits | https://developers.notion.com/reference/request-limits | 3 req/sec, size limits |
| `status-codes.md` | Status codes | https://developers.notion.com/reference/status-codes | Full error code table |
| `block-object.md` | Block object | https://developers.notion.com/reference/block | All 30+ block types with examples |
| `page-object.md` | Page object | https://developers.notion.com/reference/page | Page schema and example JSON |
| `database-object.md` | Database object | https://developers.notion.com/reference/database | New 2025-09-03 schema with data_sources |
| `user-object.md` | User object | https://developers.notion.com/reference/user | Person and bot user schemas |
| `create-page.md` | Create a page | https://developers.notion.com/reference/post-page | POST /v1/pages |
| `get-page.md` | Retrieve a page | https://developers.notion.com/reference/retrieve-a-page | GET /v1/pages/{page_id} |
| `update-page.md` | Update page properties | https://developers.notion.com/reference/patch-page | PATCH /v1/pages/{page_id} |
| `create-database.md` | Create a database | https://developers.notion.com/reference/create-a-database | POST /v1/databases (deprecated as of 2025-09-03) |
| `get-database.md` | Retrieve a database | https://developers.notion.com/reference/retrieve-a-database | GET /v1/databases/{database_id} (deprecated as of 2025-09-03) |
| `update-database.md` | Update a database | https://developers.notion.com/reference/update-a-database | PATCH /v1/databases/{database_id} (deprecated as of 2025-09-03) |
| `query-database.md` | Query a database | https://developers.notion.com/reference/post-database-query | POST /v1/databases/{database_id}/query (deprecated as of 2025-09-03) |
| `get-block-children.md` | Retrieve block children | https://developers.notion.com/reference/get-block-children | GET /v1/blocks/{block_id}/children |
| `append-blocks.md` | Append block children | https://developers.notion.com/reference/patch-block-children | PATCH /v1/blocks/{block_id}/children |
| `delete-block.md` | Delete a block | https://developers.notion.com/reference/delete-a-block | DELETE /v1/blocks/{block_id} |
| `list-users.md` | List all users | https://developers.notion.com/reference/get-users | GET /v1/users |
| `get-self.md` | Retrieve your token's bot user | https://developers.notion.com/reference/get-self | GET /v1/users/me |
| `search.md` | Search by title | https://developers.notion.com/reference/post-search | POST /v1/search |
| `create-token.md` | Create a token | https://developers.notion.com/reference/create-a-token | POST /v1/oauth/token |
| `list-comments.md` | List comments | https://developers.notion.com/reference/list-comments | GET /v1/comments |
| `create-comment.md` | Create comment | https://developers.notion.com/reference/create-a-comment | POST /v1/comments |

---

## Skipped / 404 pages

| Original URL | Status | Reason |
|-------------|--------|--------|
| https://developers.notion.com/reference/query-a-database | 404 | Page not found — use `/reference/post-database-query` instead |
| https://developers.notion.com/reference/retrieve-block-children | 404 | Page not found — use `/reference/get-block-children` instead |

---

## Key API notes

- **Latest version:** `2025-09-03` — must be sent as `Notion-Version` header on all requests
- **Auth:** Bearer token in `Authorization` header
- **Rate limit:** 3 requests/second average; returns 429 with `Retry-After` header when exceeded
- **Pagination:** Cursor-based (`start_cursor` / `next_cursor` / `has_more`)
- **Breaking change in 2025-09-03:** Database and data source concepts were split. Old database CRUD endpoints (`/v1/databases` POST/GET/PATCH, query) are deprecated. Use new `/reference/database-*` and `/reference/data-source-*` endpoints instead.
- **Comment capabilities:** Read and insert comment capabilities are OFF by default in integrations — must be explicitly enabled in integration settings.
