---
source: https://developers.google.com/sheets/api/guides/concepts
scraped: 2026-03-01
api: google-sheets-api
---

# Google Sheets API Overview & Concepts

The Google Sheets API is a REST interface enabling programmatic spreadsheet manipulation via `https://sheets.googleapis.com`.

## Core Terminology

**Spreadsheet**: The primary object containing multiple sheets with structured data in cells, represented by the `spreadsheets` resource with a unique `spreadsheetId`.

**Sheet**: A tab within a spreadsheet, represented by the `Sheets` resource containing a numeric `sheetId` and `title` within `SheetProperties`.

**Cell**: Individual data fields arranged in rows and columns, identified by row/column coordinates rather than unique IDs.

**Spreadsheet ID**: A stable string identifier derived from the spreadsheet URL that persists even if the name changes.

**Sheet ID**: A stable numeric identifier for a specific sheet, extractable from the spreadsheet URL.

## Cell Reference Notation

### A1 Notation (most common)
- `Sheet1!A1:B2` - cells in first two rows/columns
- `Sheet1!A:A` - entire first column
- `'Jon's_Data'!A1:D5` - named ranges with special characters require quotes

### R1C1 Notation (less common)
- `Sheet1!R1C1:R2C2` - first two cells in top rows
- `Sheet1!R[3]C[1]` - relative positioning (three rows down, one column right)

## Additional Concepts

**Named Range**: Custom-named cell or range simplifying references.

**Protected Range**: Cells that cannot be modified, represented by the `ProtectedRange` resource.

## REST Resources

| Resource | Description |
|---|---|
| `v4.spreadsheets` | Main spreadsheet operations |
| `v4.spreadsheets.developerMetadata` | Custom metadata on spreadsheet objects |
| `v4.spreadsheets.sheets` | Sheet-level operations |
| `v4.spreadsheets.values` | Read/write cell values |

## Resource Methods

**v4.spreadsheets:** `batchUpdate`, `create`, `get`, `getByDataFilter`

**v4.spreadsheets.developerMetadata:** `get`, `search`

**v4.spreadsheets.sheets:** `copyTo`

**v4.spreadsheets.values:** `append`, `batchClear`, `batchClearByDataFilter`, `batchGet`, `batchGetByDataFilter`, `batchUpdate`, `batchUpdateByDataFilter`, `clear`, `get`, `update`

## OAuth Scopes

| Scope | Access | Classification |
|---|---|---|
| `https://www.googleapis.com/auth/spreadsheets` | See, edit, create, delete all Sheets | Sensitive |
| `https://www.googleapis.com/auth/spreadsheets.readonly` | See all Sheets | Sensitive |
| `https://www.googleapis.com/auth/drive.file` | Only specific Drive files used by this app | Non-sensitive (recommended) |
| `https://www.googleapis.com/auth/drive` | All Drive files | Restricted |
| `https://www.googleapis.com/auth/drive.readonly` | See and download all Drive files | Restricted |

**Note:** Scopes apply to spreadsheet files as a whole, not individual sheets.
