# Google Docs API — Local Documentation

**Scraped:** 2026-03-01
**Source:** https://developers.google.com/workspace/docs/api/reference/rest
**Coverage:** ~91% (25 files across 4 categories)

---

## Quick Reference

| Item | Value |
|------|-------|
| Base URL | `https://docs.googleapis.com` |
| Version | v1 |
| Auth | OAuth 2.0 |
| Pricing | Free (no cost) |
| Read quota | 3,000 req/min/project, 300 req/min/user |
| Write quota | 600 req/min/project, 60 req/min/user |
| Error on limit | HTTP 429 |

## Three Methods

| Method | HTTP | Endpoint |
|--------|------|----------|
| `documents.get` | GET | `/v1/documents/{documentId}` |
| `documents.create` | POST | `/v1/documents` |
| `documents.batchUpdate` | POST | `/v1/documents/{documentId}:batchUpdate` |

## Contents

### overview/
- **concepts.md** — Core terminology, document structure, request patterns
- **overview.md** — Service info, 3 primary methods, client libraries
- **limits.md** — Quota table, exponential backoff, pricing
- **auth-scopes.md** — All 5 OAuth scopes with sensitivity levels

### reference/
- **documents-resource.md** — Full Document schema (all 50+ fields and sub-fields, all enums)
- **methods.md** — All 3 methods + all 37 batchUpdate request types with JSON examples

### guides/
- **best-practices.md** — WriteControl, backward editing, batching, error handling
- **format-text.md** — UpdateTextStyleRequest, UpdateParagraphStyleRequest
- **images.md** — InsertInlineImageRequest, ReplaceImageRequest
- **insert-delete-move-text.md** — InsertTextRequest, DeleteContentRangeRequest
- **lists.md** — CreateParagraphBulletsRequest, BulletGlyphPresets
- **mail-merge.md** — Template + ReplaceAllTextRequest pattern
- **named-ranges.md** — Create, read, update, delete named ranges
- **performance.md** — Field masks, gzip compression, partial responses
- **suggestions.md** — SuggestionsViewMode, index behavior
- **tables.md** — All table operations (insert, delete, style, merge)
- **tabs.md** — Document tabs, legacy vs. new structure

### samples/
- **extract-text.md** — Recursive text extraction (Python + Java)
- **mail-merge-sample.md** — Full mail merge with Google Sheets
- **output-json.md** — Dump document as JSON
- **quickstart-python.md** — Python OAuth2 quickstart
- **quickstart-js.md** — JavaScript browser quickstart
- **quickstart-go.md** — Go OAuth2 quickstart

## Key Concepts to Know

1. **Indexes are UTF-16 code units** — not bytes, not characters
2. **Edit backwards** — insert at highest index first to avoid shift issues
3. **Use `includeTabsContent=true`** — required to get content from all tabs
4. **WriteControl** — use `requiredRevisionId` for safe concurrent edits
5. **Field masks** — always specify `fields` in update requests
6. **Images must be public URLs** — no local file upload via Docs API
7. **Comments not in Docs API** — use Drive API for comments
8. **batchUpdate is atomic** — all-or-nothing, validated before applied
