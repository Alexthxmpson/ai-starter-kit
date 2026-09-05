---
source: https://developers.google.com/sheets/api/samples/writing
scraped: 2026-03-01
api: google-sheets-api
---

# Writing Data Samples — Google Sheets API

## Write Single Range (USER_ENTERED)

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

## Write Single Range (RAW — no formula parsing)

```http
PUT https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/values/Sheet1!A1:E1?valueInputOption=RAW
```

Request body:
```json
{
  "range": "Sheet1!A1:E1",
  "majorDimension": "ROWS",
  "values": [["Data", 123.45, true, "=MAX(D2:D4)", "10"]]
}
```

Formula `"=MAX(D2:D4)"` appears as literal text.

## Selective Writing (skip cells with null, clear with "")

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

- `null` — skips cell (no change)
- `""` — clears cell value

## Batch Write Multiple Ranges

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

Response:
```json
{
  "spreadsheetId": "SPREADSHEET_ID",
  "totalUpdatedRows": 4,
  "totalUpdatedColumns": 4,
  "totalUpdatedCells": 8,
  "totalUpdatedSheets": 1,
  "responses": [
    { "updatedRange": "Sheet1!A1:A4", "updatedRows": 4, ... },
    { "updatedRange": "Sheet1!B1:D2", "updatedRows": 2, ... }
  ]
}
```

## Append Values

```http
POST https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/values/Sheet1!A1:E1:append?valueInputOption=USER_ENTERED&insertDataOption=INSERT_ROWS
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

Response:
```json
{
  "spreadsheetId": "SPREADSHEET_ID",
  "tableRange": "Sheet1!A1:D5",
  "updates": {
    "spreadsheetId": "SPREADSHEET_ID",
    "updatedRange": "Sheet1!A6:D7",
    "updatedRows": 2,
    "updatedColumns": 4,
    "updatedCells": 8
  }
}
```

## Python: Write Values

```python
from googleapiclient.discovery import build

service = build("sheets", "v4", credentials=creds)
spreadsheet_id = "SPREADSHEET_ID"
range_name = "Sheet1!A1:D5"
values = [
    ["Item", "Cost", "Stocked", "Ship Date"],
    ["Wheel", "$20.50", "4", "3/1/2016"],
]

body = {
    "values": values
}
result = service.spreadsheets().values().update(
    spreadsheetId=spreadsheet_id,
    range=range_name,
    valueInputOption="USER_ENTERED",
    body=body
).execute()
print(f"Updated {result.get('updatedCells')} cells.")
```

## Python: Append Values

```python
values = [
    ["New Item", "$50", "3", "4/1/2016"],
]
body = { "values": values }
result = service.spreadsheets().values().append(
    spreadsheetId=spreadsheet_id,
    range="Sheet1!A1",
    valueInputOption="USER_ENTERED",
    insertDataOption="INSERT_ROWS",
    body=body
).execute()
```
