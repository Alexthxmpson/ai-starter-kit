---
source: https://developers.google.com/sheets/api/samples/rowcolumn
scraped: 2026-03-01
api: google-sheets-api
---

# Row, Column, and Sheet Operation Samples — Google Sheets API

## Row/Column Operations

### Set Column Width

```json
{
  "updateDimensionProperties": {
    "range": {
      "sheetId": 0,
      "dimension": "COLUMNS",
      "startIndex": 0,
      "endIndex": 1
    },
    "properties": {
      "pixelSize": 200
    },
    "fields": "pixelSize"
  }
}
```

### Set Row Height

```json
{
  "updateDimensionProperties": {
    "range": {
      "sheetId": 0,
      "dimension": "ROWS",
      "startIndex": 0,
      "endIndex": 5
    },
    "properties": {
      "pixelSize": 40
    },
    "fields": "pixelSize"
  }
}
```

### Append Empty Rows

```json
{
  "appendDimension": {
    "sheetId": 0,
    "dimension": "ROWS",
    "length": 10
  }
}
```

### Auto-Resize Columns

```json
{
  "autoResizeDimensions": {
    "dimensions": {
      "sheetId": 0,
      "dimension": "COLUMNS",
      "startIndex": 0,
      "endIndex": 5
    }
  }
}
```

### Insert Rows

```json
{
  "insertDimension": {
    "range": {
      "sheetId": 0,
      "dimension": "ROWS",
      "startIndex": 3,
      "endIndex": 5
    },
    "inheritFromBefore": false
  }
}
```

`inheritFromBefore: false` means new rows inherit formatting from rows after; `true` = inherit from before.

### Delete Rows

```json
{
  "deleteDimension": {
    "range": {
      "sheetId": 0,
      "dimension": "ROWS",
      "startIndex": 3,
      "endIndex": 5
    }
  }
}
```

### Move Rows/Columns

```json
{
  "moveDimension": {
    "source": {
      "sheetId": 0,
      "dimension": "COLUMNS",
      "startIndex": 0,
      "endIndex": 1
    },
    "destinationIndex": 5
  }
}
```

## Sheet Operations

### Add a Sheet

```json
{
  "addSheet": {
    "properties": {
      "title": "Deposits",
      "gridProperties": {
        "rowCount": 20,
        "columnCount": 12
      },
      "tabColor": {
        "red": 1.0,
        "green": 0.3,
        "blue": 0.4
      }
    }
  }
}
```

Response contains `addSheet.properties.sheetId` — save this for future requests.

### Delete a Sheet

```json
{
  "deleteSheet": {
    "sheetId": 12345
  }
}
```

### Clear Sheet Values (Keep Formatting)

```json
{
  "updateCells": {
    "range": {
      "sheetId": 0
    },
    "fields": "userEnteredValue"
  }
}
```

### Copy a Sheet to Another Spreadsheet

```http
POST https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/sheets/SHEET_ID:copyTo
```

Request body:
```json
{
  "destinationSpreadsheetId": "TARGET_SPREADSHEET_ID"
}
```

The copy retains all values, formatting, formulas, and properties. Title becomes "Copy of [original]".

### Read Sheet Metadata

```http
GET https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID?fields=sheets.properties
```

Returns sheet IDs, titles, types, grid properties (rowCount, columnCount, frozenRowCount, etc.).

### Hide/Show a Sheet

```json
{
  "updateSheetProperties": {
    "properties": {
      "sheetId": 0,
      "hidden": true
    },
    "fields": "hidden"
  }
}
```

### Freeze Rows and Columns

```json
{
  "updateSheetProperties": {
    "properties": {
      "sheetId": 0,
      "gridProperties": {
        "frozenRowCount": 1,
        "frozenColumnCount": 1
      }
    },
    "fields": "gridProperties.frozenRowCount,gridProperties.frozenColumnCount"
  }
}
```
