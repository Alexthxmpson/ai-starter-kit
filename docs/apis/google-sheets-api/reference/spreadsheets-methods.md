---
source: https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets
scraped: 2026-03-01
api: google-sheets-api
---

# spreadsheets Methods — Google Sheets API v4

## spreadsheets.create

**POST** `https://sheets.googleapis.com/v4/spreadsheets`

Create a new spreadsheet.

**Request Body:** Spreadsheet resource

**Response:** Newly created Spreadsheet resource (includes `spreadsheetId`, `properties`, `sheets[]`, `spreadsheetUrl`)

**Required Scopes (one of):**
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`
- `https://www.googleapis.com/auth/spreadsheets`

---

## spreadsheets.get

**GET** `https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}`

Retrieve a spreadsheet by ID.

**Path Parameters:**
- `spreadsheetId` (string, required)

**Query Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `ranges[]` | string | Specific cell ranges using A1 notation |
| `includeGridData` | boolean | Returns grid data when true; ignored if field mask is set |
| `excludeTablesInBandedRanges` | boolean | Excludes tables from banded ranges when true |

**Request Body:** Must be empty

**Response:** Spreadsheet object

**Note:** By default, data within grids is not returned. For large spreadsheets, use `values.get()` instead for better performance.

**Required Scopes (one of):**
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.readonly`
- `https://www.googleapis.com/auth/drive.file`
- `https://www.googleapis.com/auth/spreadsheets`
- `https://www.googleapis.com/auth/spreadsheets.readonly`

---

## spreadsheets.batchUpdate

**POST** `https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}:batchUpdate`

Apply one or more updates to a spreadsheet atomically. If any request is invalid, the entire batch fails.

**Path Parameters:**
- `spreadsheetId` (string, required)

**Request Body:**

```json
{
  "requests": [ { Request } ],
  "includeSpreadsheetInResponse": boolean,
  "responseRanges": [ string ],
  "responseIncludeGridData": boolean
}
```

| Field | Type | Description |
|---|---|---|
| `requests[]` | Request objects (required) | Updates to apply in specified order |
| `includeSpreadsheetInResponse` | boolean | Whether response includes full spreadsheet resource |
| `responseRanges[]` | string array | Limits ranges in response (only if includeSpreadsheetInResponse is true) |
| `responseIncludeGridData` | boolean | Whether grid data is returned in response |

**Response Body:**

```json
{
  "spreadsheetId": string,
  "replies": [ { Response } ],
  "updatedSpreadsheet": { Spreadsheet }
}
```

| Field | Description |
|---|---|
| `spreadsheetId` | Target spreadsheet ID |
| `replies[]` | Maps 1:1 with requests; some may be empty |
| `updatedSpreadsheet` | Returned only if `include_spreadsheet_in_response` is true |

**Required Scopes (one of):**
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`
- `https://www.googleapis.com/auth/spreadsheets`

### Supported Request Types in batchUpdate

**Add/Duplicate:**
- `addSheet` — Add a new sheet
- `duplicateSheet` — Duplicate a sheet
- `addNamedRange` — Add a named range
- `addProtectedRange` — Add a protected range
- `addConditionalFormatRule` — Add conditional format rule
- `addFilterView` — Add a filter view
- `addChart` — Add a chart
- `addBanding` — Add banded colors
- `addDimensionGroup` — Group rows/columns
- `addDataSource` — Add external data source
- `addTable` — Add a table

**Update/Set:**
- `updateSpreadsheetProperties` — Update spreadsheet-level properties
- `updateSheetProperties` — Update sheet properties
- `updateDimensionProperties` — Update row/column properties (size, visibility)
- `updateNamedRange` — Update named range
- `updateProtectedRange` — Update protected range
- `updateCells` — Update cell values/formats
- `repeatCell` — Apply formatting to a range
- `updateBorders` — Update cell borders
- `updateConditionalFormatRule` — Modify conditional format rule
- `updateFilterView` — Modify filter view
- `updateChartSpec` — Modify chart
- `updateEmbeddedObjectPosition` — Move/resize embedded objects
- `updateBanding` — Update banded colors
- `setBasicFilter` — Set the basic filter
- `setDataValidation` — Set data validation
- `updateDeveloperMetadata` — Update metadata

**Delete:**
- `deleteSheet` — Delete a sheet
- `deleteNamedRange` — Delete a named range
- `deleteProtectedRange` — Delete a protected range
- `deleteConditionalFormatRule` — Delete a conditional format rule
- `deleteFilterView` — Delete a filter view
- `deleteEmbeddedObject` — Delete a chart
- `deleteBanding` — Delete banded colors
- `clearBasicFilter` — Clear the basic filter
- `deleteDimensionGroup` — Ungroup rows/columns
- `deleteDataSource` — Remove data source
- `deleteTable` — Remove a table

**Data Manipulation:**
- `insertDimension` — Insert rows or columns
- `deleteDimension` — Delete rows or columns
- `moveDimension` — Move rows or columns
- `autoResizeDimensions` — Auto-resize rows/columns
- `appendDimension` — Append rows or columns
- `sortRange` — Sort a range
- `autoFill` — Auto-fill data
- `cutPaste` — Cut and paste
- `copyPaste` — Copy and paste
- `findReplace` — Find and replace
- `mergeCells` — Merge cells
- `unmergeCells` — Unmerge cells
- `insertRange` — Insert cells/rows/columns
- `deleteRange` — Delete cells/rows/columns
- `appendCells` — Append cells to sheet

---

## spreadsheets.getByDataFilter

**POST** `https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}:getByDataFilter`

Retrieve a spreadsheet using data filter parameters to return selective data.

**Path Parameters:**
- `spreadsheetId` (string, required)

**Request Body:**

```json
{
  "dataFilters": [ { DataFilter } ],
  "includeGridData": boolean,
  "excludeTablesInBandedRanges": boolean
}
```

**Response:** Spreadsheet object matching filtered criteria

**Required Scopes (one of):**
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`
- `https://www.googleapis.com/auth/spreadsheets`

---

## spreadsheets.sheets.copyTo

**POST** `https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/sheets/{sheetId}:copyTo`

Copy a single sheet to another spreadsheet.

**Path Parameters:**
- `spreadsheetId` (string) — Source spreadsheet
- `sheetId` (integer) — Sheet to copy

**Request Body:**

```json
{
  "destinationSpreadsheetId": string
}
```

**Response:** SheetProperties of the newly created sheet

**Required Scopes (one of):**
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`
- `https://www.googleapis.com/auth/spreadsheets`
