---
source: https://developers.google.com/sheets/api/guides/metadata
scraped: 2026-03-01
api: google-sheets-api
---

# Developer Metadata — Google Sheets API

## Overview

The developer metadata feature enables associating custom data with spreadsheet entities (rows, columns, sheets, or entire spreadsheets) and querying this information to locate related objects.

## Use Cases

- Tagging rows as "headerRow" without needing values
- Storing `formResponseId = resp123` linked to a specific row
- Linking spreadsheet rows to records in external databases
- Attaching version tags or processing status to ranges

## Key Concepts

### Metadata as Tags
Simple key-location associations like `"headerRow"` marking specific rows without values.

### Metadata as Key-Value Pairs
Structured properties such as `"formResponseId = resp123"` attached to locations.

### Visibility Settings

| Value | Description |
|---|---|
| `project` | Only visible to the Google Cloud project that created it |
| `document` | Accessible from any authorized project |

### Uniqueness

While metadata keys need not be unique, each `metadataId` must be distinct. The API auto-assigns IDs if unspecified.

## Storage Limits

- **30,000 characters per scope**
  - Spreadsheet level: 30,000 total
  - Per sheet: 30,000 each
- Character counts include `metadataKey` and `metadataValue` fields combined

## Creating Metadata

Use `batchUpdate` with `CreateDeveloperMetadataRequest`:

```json
{
  "createDeveloperMetadata": {
    "developerMetadata": {
      "metadataKey": "formResponseId",
      "metadataValue": "resp123",
      "location": {
        "dimensionRange": {
          "sheetId": 0,
          "dimension": "ROWS",
          "startIndex": 1,
          "endIndex": 2
        }
      },
      "visibility": "DOCUMENT"
    }
  }
}
```

### Location Types

```json
// Spreadsheet-level
"location": { "spreadsheet": true }

// Sheet-level
"location": { "sheetId": 0 }

// Row-level
"location": {
  "dimensionRange": {
    "sheetId": 0,
    "dimension": "ROWS",
    "startIndex": 1,
    "endIndex": 2
  }
}

// Column-level
"location": {
  "dimensionRange": {
    "sheetId": 0,
    "dimension": "COLUMNS",
    "startIndex": 0,
    "endIndex": 1
  }
}
```

## Reading Metadata

### Single item

```http
GET https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/developerMetadata/{metadataId}
```

### Multiple items via search

```json
{
  "dataFilters": [
    {
      "developerMetadataLookup": {
        "metadataKey": "formResponseId",
        "metadataValue": "resp123"
      }
    }
  ]
}
```

## Updating Metadata

Use `UpdateDeveloperMetadataRequest` via `batchUpdate`:

```json
{
  "updateDeveloperMetadata": {
    "dataFilters": [
      {
        "developerMetadataLookup": {
          "metadataId": 12345
        }
      }
    ],
    "developerMetadata": {
      "metadataValue": "newValue"
    },
    "fields": "metadataValue"
  }
}
```

## Deleting Metadata

Use `DeleteDeveloperMetadataRequest`:

```json
{
  "deleteDeveloperMetadata": {
    "dataFilter": {
      "developerMetadataLookup": {
        "metadataId": 12345
      }
    }
  }
}
```

## Working with Values by Metadata Reference

| Method | Description |
|---|---|
| `spreadsheets.values.batchGetByDataFilter` | Fetch cells matching metadata |
| `spreadsheets.values.batchUpdateByDataFilter` | Update cells via metadata |
| `spreadsheets.values.batchClearByDataFilter` | Clear cells by metadata reference |
| `spreadsheets.getByDataFilter` | Return spreadsheet subsets matching metadata |

### Example: Fetch Cells by Metadata

```json
POST https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/values:batchGetByDataFilter

{
  "dataFilters": [
    {
      "developerMetadataLookup": {
        "metadataKey": "formResponseId"
      }
    }
  ]
}
```
