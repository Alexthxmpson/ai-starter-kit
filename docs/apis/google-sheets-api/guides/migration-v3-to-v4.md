---
source: https://developers.google.com/sheets/api/guides/migration
scraped: 2026-03-01
api: google-sheets-api
---

# Migration Guide: Google Sheets API v3 to v4

## Status

**Google Sheets API v3 was turned down on August 2, 2021.** All developers must use v4.

## Major Differences

**Data Format**: v3 used XML; v4 uses JSON — they are not backward-compatible.

**Authorization Scopes**:
- v3: Single scope (`https://spreadsheets.google.com/feeds`)
- v4: Multiple granular scopes (`spreadsheets.readonly`, `spreadsheets`, Drive scopes)

**Visibility Model**: v3 explicitly declared visibility (public/private) in endpoints; v4 relies on permission checks instead.

**Projection**: v3 offered fixed data subsets (`basic`/`full`); v4 uses flexible field masks.

## Core API Changes

| Operation | v3 Approach | v4 Approach |
|---|---|---|
| Create spreadsheets | Drive API only | Dedicated `spreadsheets.create` method |
| Sheet metadata | XML worksheet feed | `spreadsheets.get` with JSON response |
| Add sheets | POST to worksheet feed | `AddSheet` in `batchUpdate` |
| Retrieve rows | List feed with column headers | `values.get` with A1 notation ranges |
| Edit cells | Individual PUT requests | `values.update` or `values.batchUpdate` |
| Delete rows | DELETE on row edit URL | `DeleteDimension` in `batchUpdate` |

## Notable v4 Advantages

- Access to formulas, formatting, hyperlinks, and data validation
- Support for disjoint cell ranges in single requests
- More comprehensive sheet property control
- Better performance through batch operations
- Named ranges, protected ranges, conditional formatting, charts, pivot tables — all accessible via API
- Developer metadata for attaching custom data to cells/rows/columns
