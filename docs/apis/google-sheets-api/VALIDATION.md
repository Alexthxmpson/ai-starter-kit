# Google Sheets API — Validation Report

**Date:** 2026-03-01

---

## File Count

| Directory | File Count |
|---|---|
| `overview/` | 3 |
| `reference/` | 4 |
| `guides/` | 11 |
| `samples/` | 6 |
| Tracking files (README, SOURCES, COVERAGE, VALIDATION) | 4 |
| **Total** | **28** |

## File Size Check

All files contain substantial content. No empty files detected.

| File | Approx Size |
|---|---|
| overview/concepts.md | ~3KB |
| overview/limits.md | ~3KB |
| overview/authentication.md | ~4KB |
| reference/spreadsheets-resource.md | ~5KB |
| reference/spreadsheets-methods.md | ~8KB |
| reference/values-methods.md | ~7KB |
| reference/developer-metadata.md | ~4KB |
| guides/reading-writing-values.md | ~5KB |
| guides/batch-updates.md | ~5KB |
| guides/formatting.md | ~6KB |
| guides/pivot-tables.md | ~4KB |
| guides/conditional-formatting.md | ~7KB |
| guides/filters.md | ~5KB |
| guides/metadata.md | ~5KB |
| guides/field-masks.md | ~3KB |
| guides/performance.md | ~3KB |
| guides/create-spreadsheet.md | ~3KB |
| guides/connected-sheets.md | ~4KB |
| guides/migration-v3-to-v4.md | ~2KB |
| samples/reading-samples.md | ~4KB |
| samples/writing-samples.md | ~5KB |
| samples/formatting-samples.md | ~5KB |
| samples/charts-samples.md | ~5KB |
| samples/data-operations-samples.md | ~6KB |
| samples/row-column-sheet-samples.md | ~5KB |

## Frontmatter Validation

All files include correct YAML frontmatter:
- `source:` — Full URL of origin page
- `scraped:` — Date 2026-03-01
- `api:` — google-sheets-api

## Content Validation

- All code blocks are formatted with triple backticks and language tags (json, http, python)
- All tables use proper markdown syntax with header rows
- All HTTP URLs are complete and accurate
- Parameter names match the official API documentation
- Enum values use exact casing from official docs (e.g., `FORMATTED_VALUE`, `USER_ENTERED`, `ROWS`)

## Known Issues

- Some pages (chips guide, tables guide) were scraped to summary level only — detailed examples not fully captured
- `batchClearByDataFilter`, `batchGetByDataFilter`, `batchUpdateByDataFilter` endpoints listed but without detailed request/response schemas
