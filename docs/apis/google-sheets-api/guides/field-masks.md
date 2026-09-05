---
source: https://developers.google.com/sheets/api/guides/field-masks
scraped: 2026-03-01
api: google-sheets-api
---

# Field Masks — Google Sheets API

## Overview

Field masks enable API callers to specify which fields should be returned or updated, improving performance by avoiding unnecessary data retrieval and preventing accidental overwrites.

## Reading with Field Masks

**Purpose:** Limit response data from spreadsheet read requests.

### Syntax Rules

| Syntax | Description |
|---|---|
| `field1,field2` | Multiple fields, comma-separated |
| `sheets.properties` | Nested fields using dot notation |
| `sheets(sheetId,title)` | Multiple subfields from same type using parentheses |
| Field names accept camelCase or snake_case | |

### Example: Get only sheet metadata

```http
GET https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID?fields=sheets.properties(sheetId,title,sheetType,gridProperties)
```

Returns only: sheet ID, title, sheet type, and grid properties for all sheets.

### Common Read Field Mask Examples

```
fields=spreadsheetId,properties.title
fields=sheets(sheetId,title)
fields=sheets.basicFilter
fields=sheets.filterViews
fields=sheets(charts)
fields=sheets.data.rowData.values(chipRuns)
```

## Updating with Field Masks

**Purpose:** Update specific fields while preserving others unchanged.

### Key Behaviors

- Used within `spreadsheets.batchUpdate` operations
- Unspecified fields retain their current values
- To unset a field: omit the field from the update message but include it in the mask

### Example: Update only sheet title

```json
{
  "updateSheetProperties": {
    "properties": {
      "sheetId": 0,
      "title": "New Title"
    },
    "fields": "title"
  }
}
```

### Example: Update background color only

```json
{
  "repeatCell": {
    "range": { "sheetId": 0, "startRowIndex": 0, "endRowIndex": 1 },
    "cell": {
      "userEnteredFormat": {
        "backgroundColor": { "red": 1.0, "green": 0.0, "blue": 0.0 }
      }
    },
    "fields": "userEnteredFormat.backgroundColor"
  }
}
```

## Wildcard Caution

A `*` wildcard specifies all fields. Use with caution:
- Risks errors from read-only fields being included
- New fields added in future API versions may cause unexpected behavior
- **Production code should explicitly list fields instead**

```json
"fields": "*"  // Use only for testing, never in production
```

## Common Field Paths

| Operation | Field Mask |
|---|---|
| Spreadsheet title | `title` |
| Sheet title only | `title` |
| Cell background color | `userEnteredFormat.backgroundColor` |
| Cell text format | `userEnteredFormat.textFormat` |
| Cell number format | `userEnteredFormat.numberFormat` |
| Cell value | `userEnteredValue` |
| Named range name | `name` |
| Pivot table | `pivotTable` |
| Protected range editors | `namedRangeId,warningOnly,editors` |
