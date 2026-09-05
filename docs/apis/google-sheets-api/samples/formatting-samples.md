---
source: https://developers.google.com/sheets/api/samples/formatting
scraped: 2026-03-01
api: google-sheets-api
---

# Formatting Samples — Google Sheets API

All formatting uses:
```http
POST https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID:batchUpdate
```

## Edit Cell Borders (Blue Dashed)

```json
{
  "requests": [
    {
      "updateBorders": {
        "range": {
          "sheetId": 0,
          "startRowIndex": 0,
          "endRowIndex": 10,
          "startColumnIndex": 0,
          "endColumnIndex": 6
        },
        "top": {
          "style": "DASHED",
          "width": 1,
          "color": { "blue": 1.0 }
        },
        "bottom": {
          "style": "DASHED",
          "width": 1,
          "color": { "blue": 1.0 }
        },
        "innerHorizontal": {
          "style": "DASHED",
          "width": 1,
          "color": { "blue": 1.0 }
        }
      }
    }
  ]
}
```

## Format Header Row (Black bg, White text, Centered, Bold)

```json
{
  "requests": [
    {
      "repeatCell": {
        "range": {
          "sheetId": 0,
          "startRowIndex": 0,
          "endRowIndex": 1
        },
        "cell": {
          "userEnteredFormat": {
            "backgroundColor": {
              "red": 0.0,
              "green": 0.0,
              "blue": 0.0
            },
            "horizontalAlignment": "CENTER",
            "textFormat": {
              "foregroundColor": {
                "red": 1.0,
                "green": 1.0,
                "blue": 1.0
              },
              "fontSize": 12,
              "bold": true
            }
          }
        },
        "fields": "userEnteredFormat(backgroundColor,textFormat,horizontalAlignment)"
      }
    }
  ]
}
```

## Merge Cells

```json
{
  "requests": [
    {
      "mergeCells": {
        "range": {
          "sheetId": 0,
          "startRowIndex": 0,
          "endRowIndex": 2,
          "startColumnIndex": 0,
          "endColumnIndex": 5
        },
        "mergeType": "MERGE_ALL"
      }
    }
  ]
}
```

## Custom DateTime Format

```json
{
  "requests": [
    {
      "repeatCell": {
        "range": {
          "sheetId": 0,
          "startRowIndex": 1,
          "endRowIndex": 2,
          "startColumnIndex": 4,
          "endColumnIndex": 5
        },
        "cell": {
          "userEnteredFormat": {
            "numberFormat": {
              "type": "DATE_TIME",
              "pattern": "hh:mm:ss am/pm, ddd mmm dd yyyy"
            }
          }
        },
        "fields": "userEnteredFormat.numberFormat"
      }
    }
  ]
}
```

Result: "02:05:07 PM, Sun Apr 03 2016"

## Custom Number Format

```json
{
  "requests": [
    {
      "repeatCell": {
        "range": {
          "sheetId": 0,
          "startRowIndex": 1,
          "endRowIndex": 2,
          "startColumnIndex": 5,
          "endColumnIndex": 6
        },
        "cell": {
          "userEnteredFormat": {
            "numberFormat": {
              "type": "NUMBER",
              "pattern": "#,##0.0000"
            }
          }
        },
        "fields": "userEnteredFormat.numberFormat"
      }
    }
  ]
}
```

Result: 12345.1234567 → "12,345.1235"

## Freeze Rows/Columns

```json
{
  "requests": [
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
  ]
}
```

## Auto-Resize Columns

```json
{
  "requests": [
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
  ]
}
```

## Set Column Width

```json
{
  "requests": [
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
  ]
}
```
