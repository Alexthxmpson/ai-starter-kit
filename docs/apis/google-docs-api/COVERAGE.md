# Google Docs API — Documentation Coverage

**Date:** 2026-03-01

---

## Coverage by Category

| Category | Scraped | Total | Coverage |
|----------|---------|-------|----------|
| Overview / Concepts | 5 | 5 | 100% |
| Reference (REST methods) | 5 | 5 | 100% |
| Guides / How-tos | 11 | 14 | 79% |
| Samples / Quickstarts | 7 | 7 | 100% |
| Support | 1 | 1 | 100% |
| **Total** | **29** | **32** | **~91%** |

---

## What Is Covered

### Overview (100%)
- Core concepts (Document ID, segments, named ranges, suggestions, tabs)
- Service endpoint and discovery document
- Usage limits and quota details
- OAuth 2.0 scopes (all 5 scopes documented)
- Request/response patterns

### Reference (100%)
- All 3 HTTP methods: `documents.get`, `documents.create`, `documents.batchUpdate`
- All 37 request types for `batchUpdate`
- Full `Document` resource schema (all fields and sub-fields)
- All enum values
- `WriteControl` structure
- Full `TextStyle`, `ParagraphStyle`, `TableCellStyle`, `ImageProperties` schemas

### Guides (79%)
- Insert/Delete/Move Text
- Format Text (character and paragraph)
- Insert Inline Images
- Work with Lists (create, convert, delete)
- Work with Tables (all operations)
- Work with Named Ranges
- Work with Tabs (legacy vs. new structure)
- Work with Suggestions
- Best Practices (WriteControl, batching, backward editing)
- Mail Merge (templates, Sheets integration)
- Performance Optimization (field masks, gzip, partial responses)

### Missing Guides (21%)
- Create and Manage Documents (page returned 404; content distributed across other pages)
- Comments (not directly available via Docs API — use Drive API)
- Edit Rules (404; content merged into best practices)

### Samples (100%)
- Output document as JSON (Java, Python, JavaScript)
- Extract text (Python, Java)
- Mail merge (Python with Sheets)
- Quickstart: Python
- Quickstart: JavaScript (Browser)
- Quickstart: Go

---

## Data Quality Notes

- All request types have JSON structure documented
- Code examples available in Python, Java, PHP, JavaScript, and Go
- All quota numbers captured (3000 read/min/project, 60 write/min/user, etc.)
- All OAuth scopes with sensitivity levels documented
- Exponential backoff formula documented
- Field mask syntax fully documented
- Tab structure changes (legacy vs. new) fully documented
