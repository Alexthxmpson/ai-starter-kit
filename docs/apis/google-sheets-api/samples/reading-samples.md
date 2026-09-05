---
source: https://developers.google.com/sheets/api/samples/reading
scraped: 2026-03-01
api: google-sheets-api
---

# Reading Data Samples — Google Sheets API

## Single Range (Rows format)

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
    ["Wheel", "$20.50", "4", "3/1/2016"],
    ["Door", "$15", "2", "3/15/2016"],
    ["Engine", "$100", "1", "3/20/2016"],
    ["Totals", "$135.5", "7", "3/20/2016"]
  ]
}
```

## Single Range (Columns format)

```http
GET https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/values/Sheet1!A1:D3?majorDimension=COLUMNS
```

Response:
```json
{
  "range": "Sheet1!A1:D3",
  "majorDimension": "COLUMNS",
  "values": [
    ["Item", "Wheel", "Door"],
    ["Cost", "$20.50", "$15"],
    ["Stocked", "4", "2"],
    ["Ship Date", "3/1/2016", "3/15/2016"]
  ]
}
```

## With Rendering Options (return formulas + serial dates)

```http
GET https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/values/Sheet1!A1:D5?valueRenderOption=FORMULA&dateTimeRenderOption=SERIAL_NUMBER
```

Returns formulas like `=SUM(B2:B4)` instead of calculated `$135.5`, and dates as serial numbers like `42460` instead of `"3/1/2016"`.

## Multiple Ranges — Batch Get

```http
GET https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/values:batchGet?ranges=Sheet1!B:B&ranges=Sheet1!D:D&valueRenderOption=UNFORMATTED_VALUE
```

Response:
```json
{
  "spreadsheetId": "SPREADSHEET_ID",
  "valueRanges": [
    {
      "range": "Sheet1!B1:B1000",
      "majorDimension": "ROWS",
      "values": [["Cost"], [20.5], [15], [100], [135.5]]
    },
    {
      "range": "Sheet1!D1:D1000",
      "majorDimension": "ROWS",
      "values": [["Ship Date"], [42461], [42475], [42480]]
    }
  ]
}
```

## Cross-Sheet Multiple Ranges

```http
GET https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID/values:batchGet?ranges=Sheet1!A1:D5&ranges=Products!D1:D100&ranges=Sales!E4:F6
```

## Python Example

```python
from googleapiclient.discovery import build

service = build("sheets", "v4", credentials=creds)
spreadsheet_id = "SPREADSHEET_ID"
range_name = "Sheet1!A1:D5"

result = service.spreadsheets().values().get(
    spreadsheetId=spreadsheet_id,
    range=range_name
).execute()

rows = result.get("values", [])
for row in rows:
    print(row)
```

## Python Batch Get Example

```python
result = service.spreadsheets().values().batchGet(
    spreadsheetId=spreadsheet_id,
    ranges=["Sheet1!A1:D5", "Sheet2!A1:B10"],
    valueRenderOption="UNFORMATTED_VALUE",
    dateTimeRenderOption="SERIAL_NUMBER"
).execute()

for value_range in result.get("valueRanges", []):
    print(f"Range: {value_range['range']}")
    for row in value_range.get("values", []):
        print(row)
```
