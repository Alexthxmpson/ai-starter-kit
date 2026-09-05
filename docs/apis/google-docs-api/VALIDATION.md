# Google Docs API — Validation Report

**Date:** 2026-03-01

---

## File Count

| Directory | Files | Empty Files |
|-----------|-------|-------------|
| overview/ | 4 | 0 |
| reference/ | 2 | 0 |
| guides/ | 9 | 0 |
| samples/ | 6 | 0 |
| root/ | 4 (README, SOURCES, COVERAGE, VALIDATION) | 0 |
| **Total** | **25** | **0** |

---

## File List

### overview/
- `concepts.md` — Core concepts, document ID, element types, request flow
- `overview.md` — Service info, 3 primary methods, client libraries
- `limits.md` — Quota table, exponential backoff formula, pricing
- `auth-scopes.md` — All 5 OAuth scopes with sensitivity classification

### reference/
- `documents-resource.md` — Full Document schema: all fields, types, enums
- `methods.md` — All 3 methods + all 37 batchUpdate request types with JSON

### guides/
- `best-practices.md` — Backward editing, WriteControl, field masks, batching
- `format-text.md` — Character and paragraph formatting with code examples
- `images.md` — InsertInlineImageRequest, ReplaceImageRequest, code examples
- `insert-delete-move-text.md` — InsertTextRequest, DeleteContentRangeRequest
- `lists.md` — CreateParagraphBulletsRequest, all BulletGlyphPreset values
- `mail-merge.md` — Template + ReplaceAllTextRequest + Drive copy pattern
- `named-ranges.md` — Create, read, update, delete named ranges
- `performance.md` — Field mask syntax, gzip, partial responses
- `suggestions.md` — SuggestionsViewMode, index behavior with suggestions
- `tables.md` — All table operations, read/write cell content
- `tabs.md` — Legacy vs. new structure, AddDocumentTab, tab access patterns

### samples/
- `extract-text.md` — Recursive text extraction, Python + Java
- `mail-merge-sample.md` — Full mail merge with Sheets data
- `output-json.md` — JSON dump, Java + Python + JavaScript
- `quickstart-go.md` — Full Go OAuth2 + document get
- `quickstart-js.md` — Browser OAuth2 + gapi.client setup
- `quickstart-python.md` — Full Python OAuth2 + document get

---

## Status

- All files have valid YAML frontmatter (source, scraped, api)
- No empty files
- All code examples preserved
- All quota numbers preserved
- All enum values documented
- All request type names captured
