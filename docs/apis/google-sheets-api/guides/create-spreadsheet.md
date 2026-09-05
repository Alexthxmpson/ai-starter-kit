---
source: https://developers.google.com/sheets/api/guides/create
scraped: 2026-03-01
api: google-sheets-api
---

# Creating and Managing Spreadsheets — Google Sheets API

## Creating a Spreadsheet

Use the `spreadsheets.create()` method. No required parameters.

### HTTP Request

```http
POST https://sheets.googleapis.com/v4/spreadsheets
```

### Request Body

```json
{
  "properties": {
    "title": "My Spreadsheet"
  }
}
```

### Response

```json
{
  "spreadsheetId": "1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms",
  "properties": { ... },
  "sheets": [ ... ],
  "spreadsheetUrl": "https://docs.google.com/spreadsheets/d/1BxiMVs0..."
}
```

### Python Example

```python
from googleapiclient.discovery import build

service = build("sheets", "v4", credentials=creds)
spreadsheet = {
    "properties": {
        "title": "My Spreadsheet"
    }
}
spreadsheet = service.spreadsheets().create(body=spreadsheet, fields="spreadsheetId").execute()
print(f"Spreadsheet ID: {spreadsheet.get('spreadsheetId')}")
```

## File Organization

By default, created spreadsheets save to the user's root Drive folder. Two options to organize:

### Option 1: Move After Creation

```python
from googleapiclient.discovery import build

drive_service = build("drive", "v3", credentials=creds)
file = drive_service.files().update(
    fileId=spreadsheet_id,
    addParents=folder_id,
    removeParents="root",
    fields="id, parents"
).execute()
```

### Option 2: Create Directly in Folder

```python
file_metadata = {
    "name": "My Spreadsheet",
    "mimeType": "application/vnd.google-apps.spreadsheet",
    "parents": [folder_id]
}
file = drive_service.files().create(body=file_metadata, fields="id").execute()
```

Both approaches require Drive API scopes for authorization.

## Retrieving Spreadsheet Data

```http
GET https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}
```

By default, excludes cell data. To include data:
- Set `includeGridData=true` parameter
- Use field masks to specify particular fields needed

**Best practice for large spreadsheets:** Use `values.get()` instead — returns only cell values without formatting metadata.

## Adding Sheets to a Spreadsheet

```json
{
  "requests": [
    {
      "addSheet": {
        "properties": {
          "title": "New Sheet",
          "gridProperties": {
            "rowCount": 1000,
            "columnCount": 26
          },
          "tabColor": {
            "red": 1.0,
            "green": 0.3,
            "blue": 0.4
          }
        }
      }
    }
  ]
}
```

## Required OAuth Scopes

| Operation | Required Scope |
|---|---|
| Create spreadsheet | `drive`, `drive.file`, or `spreadsheets` |
| Create in folder | `drive` or `drive.file` |
| Move to folder | `drive` or `drive.file` |
