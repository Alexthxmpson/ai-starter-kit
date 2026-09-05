---
source: https://developers.google.com/sheets/api/guides/batchupdate
scraped: 2026-03-01
api: google-sheets-api
---

# Batch Updates — Google Sheets API

## Overview

The `spreadsheets.batchUpdate` method enables updates to spreadsheet data beyond cell values, including dimensions, formatting, named ranges, and conditional rules. Changes are grouped in a batch — if one request is unsuccessful, none of the others are applied (atomic operations).

## Operation Categories

| Category | Purpose |
|---|---|
| Add/Duplicate | Create new objects or copy existing ones |
| Update/Set | Modify object properties while preserving others |
| Delete | Remove objects |

## Supported Objects and Operations

The API supports operations on:
- Spreadsheet Properties
- Sheets (add, update, delete)
- Dimensions (rows/columns)
- Cells (values, formats, validation)
- Named Ranges
- Borders
- Filters and Filter Views
- Data Validation
- Conditional Formatting Rules
- Protected Ranges
- Embedded Objects (charts)
- Merges
- Data manipulation (AutoFill, Cut/Paste, Copy/Paste, Find/Replace, Sort)

## Field Masks

Update requests require field masks — comma-delimited lists specifying which fields to modify.

- `fields: "title"` — update only the title
- `fields: "userEnteredFormat.backgroundColor"` — update only background color
- `fields: "*"` — wildcard updates all fields (use with caution in production)

## Request Format

```http
POST https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID:batchUpdate
```

```json
{
  "requests": [
    {
      "updateSpreadsheetProperties": {
        "properties": {
          "title": "My Updated Title"
        },
        "fields": "title"
      }
    },
    {
      "findReplace": {
        "find": "Total",
        "replacement": "Sum",
        "allSheets": true
      }
    }
  ]
}
```

## Response Format

```json
{
  "spreadsheetId": string,
  "replies": [
    {},
    { "findReplace": { "occurrencesChanged": 5 } }
  ]
}
```

The `replies` array maps 1:1 with the `requests` array. Some requests produce empty responses (`{}`).

## "Add" Requests Return Metadata

Most "add" requests return response objects containing metadata like assigned IDs:

```json
{
  "replies": [
    {
      "addSheet": {
        "properties": {
          "sheetId": 12345,
          "title": "New Sheet",
          "index": 1
        }
      }
    }
  ]
}
```

## Building an Entire Spreadsheet in One Request

You can combine `AddSheetRequest`, `UpdateCellsRequest`, and `AddNamedRange` in a single batch to build entire spreadsheets in one API call.

## Key Rules

1. **Atomicity**: If any request fails validation, the entire batch fails and nothing is applied
2. **Order matters**: Subrequests are processed in the order they appear
3. **Single auth**: One authentication token applies to all subrequests
4. **Counts as one**: The entire batch counts as a single API request toward usage limits

## Common Use Cases

- Updating metadata or formatting across multiple objects simultaneously
- Initial data uploads to a new API implementation
- Deleting numerous objects at once
- Building entire spreadsheet structures in one round trip
