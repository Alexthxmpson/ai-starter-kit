---
source: https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.developerMetadata
scraped: 2026-03-01
api: google-sheets-api
---

# spreadsheets.developerMetadata Methods — Google Sheets API v4

Developer metadata enables associating custom data with spreadsheet entities and querying to locate related objects.

## Concepts

**Metadata as Tags**: Simple key-location associations like `"headerRow"` marking specific rows without values.

**Metadata as Key-Value Pairs**: Structured properties such as `"formResponseId = resp123"` attached to locations.

**Visibility Settings:**
- `project` — Only visible to the Google Cloud project that created it
- `document` — Accessible from any authorized project

**Uniqueness:** While metadata keys need not be unique, each `metadataId` must be distinct. The API auto-assigns IDs if unspecified.

## Storage Limits

- **30,000 characters per scope**
  - Spreadsheet level: 30,000 total
  - Per sheet: 30,000 each
- Character counts include `metadataKey` and `metadataValue` fields combined

---

## spreadsheets.developerMetadata.get

**GET** `https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/developerMetadata/{metadataId}`

Retrieve developer metadata by ID.

**Path Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `spreadsheetId` | string | The spreadsheet to retrieve metadata from |
| `metadataId` | integer | The unique identifier of the developer metadata |

**Request Body:** Must be empty

**Response:** `DeveloperMetadata` object

**Required Scopes (one of):**
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`
- `https://www.googleapis.com/auth/spreadsheets`

---

## spreadsheets.developerMetadata.search

Search for developer metadata matching specified filters.

**Required Scopes (one of):**
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`
- `https://www.googleapis.com/auth/spreadsheets`

---

## Creating Metadata

Use `batchUpdate` with `CreateDeveloperMetadataRequest`, specifying key, location, visibility, and optional value/ID.

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

## Updating Metadata

Use `UpdateDeveloperMetadataRequest` via `batchUpdate`, including `DataFilter`, new values, and field mask.

## Deleting Metadata

Use `DeleteDeveloperMetadataRequest` with `DataFilter` targeting specific metadata.

## Working with Associated Values

Retrieve or modify cell values by metadata reference:

| Method | Description |
|---|---|
| `spreadsheets.values.batchGetByDataFilter` | Fetch cells matching metadata |
| `spreadsheets.values.batchUpdateByDataFilter` | Update cells via metadata |
| `spreadsheets.values.batchClearByDataFilter` | Clear cells by metadata reference |
| `spreadsheets.getByDataFilter` | Return spreadsheet subsets matching metadata |
