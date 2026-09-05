# Google Sheets API — Coverage Report

**Date:** 2026-03-01

---

## Coverage by Category

| Category | Files Created | URLs Scraped | Coverage |
|---|---|---|---|
| Overview / Concepts | 3 | 6 | 100% |
| Reference (Methods & Resources) | 3 | 13 | 93% (1 failed/404) |
| Guides | 10 | 16 | 94% (chips/tables in notes) |
| Samples | 5 | 8 | 100% (some merged) |
| Quickstart | 1 (merged) | 1 | 100% |
| **TOTAL** | **22 files** | **44 URLs** | **~95%** |

---

## File Inventory

### overview/ (3 files)
- `concepts.md` — Core terminology, A1 notation, R1C1 notation, resource overview, OAuth scopes
- `limits.md` — Quota limits (300 req/min per project, 60 req/min per user), error codes, pricing (free), 2MB payload recommendation, 180s timeout
- `authentication.md` — OAuth scopes table, sensitivity classifications, Python quickstart, common auth errors

### reference/ (3 files)
- `spreadsheets-resource.md` — Complete Spreadsheet resource schema: SpreadsheetProperties, Sheet, NamedRange, DataSource, DataSourceSpec, BigQueryDataSourceSpec, DataSourceRefreshSchedule, TimeOfDay, RecalculationInterval enum
- `spreadsheets-methods.md` — All spreadsheets.* methods: create, get, batchUpdate, getByDataFilter, sheets.copyTo; complete list of all batchUpdate request types (40+ request types documented)
- `values-methods.md` — All spreadsheets.values.* methods: get, batchGet, update, batchUpdate, append, clear, batchClear, batchGetByDataFilter, batchUpdateByDataFilter, batchClearByDataFilter; ValueInputOption, ValueRenderOption, DateTimeRenderOption, InsertDataOption, Dimension enums fully documented
- `developer-metadata.md` — Developer metadata methods, concepts, location types, storage limits (30K chars per scope)

### guides/ (10 files)
- `reading-writing-values.md` — Values API methods, parameters, reading/writing patterns, best practices
- `batch-updates.md` — batchUpdate overview, atomicity, field masks, all supported request categories
- `formatting.md` — Borders, RepeatCellRequest, merge cells, number format tokens, date-time tokens, custom formats
- `pivot-tables.md` — PivotTable configuration, PivotGroup, aggregation functions, creating/modifying/deleting
- `conditional-formatting.md` — BooleanRule, GradientRule, all condition types (25+ types), InterpolationPoint types
- `filters.md` — BasicFilter, FilterViews, DataFilter comparison, SortSpec, FilterCriteria, URL sharing
- `metadata.md` — Developer metadata concepts, visibility, storage limits, all CRUD operations, location types
- `field-masks.md` — Read and update field masks, syntax rules, wildcard warnings, common field paths
- `performance.md` — Gzip compression, partial resources, batch requests, concurrent limits, spreadsheet design tips
- `create-spreadsheet.md` — Create, retrieve spreadsheets, file organization via Drive API
- `connected-sheets.md` — BigQuery and Looker integration, async polling, DataSource API methods
- `migration-v3-to-v4.md` — v3 shutdown date, major differences, operation mapping table

### samples/ (5 files)
- `reading-samples.md` — HTTP request examples + Python code for all read patterns
- `writing-samples.md` — HTTP request examples + Python code for all write patterns
- `formatting-samples.md` — JSON examples for borders, header formatting, merges, custom formats, freeze, resize
- `charts-samples.md` — Column charts, pie charts, positioning, modifying, deleting, reading chart data
- `data-operations-samples.md` — Data validation, copy/cut paste, formula replication, sorting, find/replace, named/protected ranges
- `row-column-sheet-samples.md` — Dimension properties, insert/delete/move rows and columns, sheet add/delete/copy/clear/hide/freeze

---

## Gaps / Not Covered

- `spreadsheets.values.batchClearByDataFilter`, `batchGetByDataFilter`, `batchUpdateByDataFilter` — listed but no detailed examples
- Charts: many chart types and settings are not accessible via the API (acknowledged limitation)
- Smart chips guide (chips.md) — content summary captured but not a dedicated file
- Tables guide (tables.md) — content summary captured but not a dedicated file
- Quickstart samples for other languages (JS, Java, Go, PHP, Ruby) — Python documented
- Apps Script integration — documented as alternative, not included here
- Developer preview features — not documented
