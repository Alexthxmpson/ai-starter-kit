---
source: https://developers.google.com/sheets/api/guides/values
scraped: 2026-03-01
api: google-sheets-api
---

# Reading & Writing Cell Values — Google Sheets API

## Available Methods Overview

| Range Access | Reading | Writing |
|---|---|---|
| Single range | `spreadsheets.values.get` | `spreadsheets.values.update` |
| Multiple ranges | `spreadsheets.values.batchGet` | `spreadsheets.values.batchUpdate` |
| Appending | — | `spreadsheets.values.append` |

**Best practice:** Combine multiple operations using batch methods for improved efficiency.

## Reading Data

### Key Parameters

| Parameter | Default | Description |
|---|---|---|
| `majorDimension` | ROWS | Specifies row or column orientation |
| `valueRenderOption` | FORMATTED_VALUE | Controls output format |
| `dateTimeRenderOption` | SERIAL_NUMBER | Date/time representation (only when valueRenderOption is not FORMATTED_VALUE) |

### Single Range Read

```http
GET https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/values/Sheet1!A1:D5
```

Response:
```json
{
  "range": "Sheet1!A1:D5",
  "majorDimension": "ROWS",
  "values": [
    ["Item", "Cost", "Stocked", "Ship Date"],
    ["Wheel", "$20.50", "4", "3/1/2016"]
  ]
}
```

### Column-Grouped Format

```http
GET https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/values/Sheet1!A1:D3?majorDimension=COLUMNS
```

### With Rendering Options (return formulas and serial dates)

```http
GET https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/values/Sheet1!A1:D5?valueRenderOption=FORMULA&dateTimeRenderOption=SERIAL_NUMBER
```

### Multiple Ranges Read

```http
GET https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/values:batchGet?ranges=Sheet1!B:B&ranges=Sheet1!D:D&valueRenderOption=UNFORMATTED_VALUE
```

### Cross-Sheet Ranges

```http
GET https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/values:batchGet?ranges=Sheet1!A1:D5&ranges=Products!D1:D100&ranges=Sales!E4:F6
```

## Writing Data

### ValueInputOption Parameter (required for all writes)

| Value | Description |
|---|---|
| `RAW` | Input treated as literal strings; formulas like "=1+2" remain as text |
| `USER_ENTERED` | Input parsed as if entered via Sheets UI; "Mar 1 2016" becomes a date, "$100.15" gains currency formatting |

### Write Single Range

```http
PUT https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/values/Sheet1!A1:D5?valueInputOption=USER_ENTERED
```

Request body:
```json
{
  "range": "Sheet1!A1:D5",
  "majorDimension": "ROWS",
  "values": [
    ["Item", "Cost", "Stocked", "Ship Date"],
    ["Wheel", "$20.50", "4", "3/1/2016"],
    ["Door", "$15", "2", "3/15/2016"],
    ["Engine", "$100", "1", "3/20/2016"],
    ["Totals", "=SUM(B2:B4)", "=SUM(C2:C4)", "=MAX(D2:D4)"]
  ]
}
```

Response:
```json
{
  "spreadsheetId": "SPREADSHEET_ID",
  "updatedRange": "Sheet1!A1:D5",
  "updatedRows": 5,
  "updatedColumns": 4,
  "updatedCells": 20
}
```

### Selective Writing (skip cells with null, clear with "")

```json
{
  "range": "Sheet1!B1",
  "majorDimension": "COLUMNS",
  "values": [
    [null, "$1", "$2", ""],
    [],
    [null, "4/1/2016", "4/15/2016", ""]
  ]
}
```

### Batch Write Multiple Ranges

```http
POST https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/values:batchUpdate
```

Request body:
```json
{
  "valueInputOption": "USER_ENTERED",
  "data": [
    {
      "range": "Sheet1!A1:A4",
      "majorDimension": "COLUMNS",
      "values": [["Item", "Wheel", "Door", "Engine"]]
    },
    {
      "range": "Sheet1!B1:D2",
      "majorDimension": "ROWS",
      "values": [
        ["Cost", "Stocked", "Ship Date"],
        ["$20.50", "4", "3/1/2016"]
      ]
    }
  ]
}
```

### Append Values

```http
POST https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/values/Sheet1!A1:E1:append?valueInputOption=USER_ENTERED
```

Request body:
```json
{
  "range": "Sheet1!A1:E1",
  "majorDimension": "ROWS",
  "values": [
    ["Door", "$15", "2", "3/15/2016"],
    ["Engine", "$100", "1", "3/20/2016"]
  ]
}
```

## Important Notes

- Empty trailing rows/columns are omitted from responses
- To clear data, use empty strings (`""`)
- Use `null` in values array to skip cells
- For insertion/deletion of rows or formatting changes, use `spreadsheets.batchUpdate()` instead
