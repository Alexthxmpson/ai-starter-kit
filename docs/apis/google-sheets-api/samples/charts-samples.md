---
source: https://developers.google.com/sheets/api/samples/charts
scraped: 2026-03-01
api: google-sheets-api
---

# Charts Samples — Google Sheets API

All chart operations use:
```http
POST https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID:batchUpdate
```

**Note:** The Sheets API doesn't grant full control of charts. Some chart types and certain chart settings can't be accessed or selected with the current API.

## Add a Column Chart

```json
{
  "requests": [
    {
      "addChart": {
        "chart": {
          "spec": {
            "title": "My Chart",
            "basicChart": {
              "chartType": "COLUMN",
              "legendPosition": "BOTTOM_LEGEND",
              "axis": [
                { "position": "BOTTOM_AXIS", "title": "Category" },
                { "position": "LEFT_AXIS", "title": "Value" }
              ],
              "domains": [
                {
                  "domain": {
                    "sourceRange": {
                      "sources": [
                        {
                          "sheetId": 0,
                          "startRowIndex": 0,
                          "endRowIndex": 10,
                          "startColumnIndex": 0,
                          "endColumnIndex": 1
                        }
                      ]
                    }
                  }
                }
              ],
              "series": [
                {
                  "series": {
                    "sourceRange": {
                      "sources": [
                        {
                          "sheetId": 0,
                          "startRowIndex": 0,
                          "endRowIndex": 10,
                          "startColumnIndex": 1,
                          "endColumnIndex": 2
                        }
                      ]
                    }
                  },
                  "targetAxis": "LEFT_AXIS"
                }
              ],
              "headerCount": 1
            }
          },
          "position": {
            "newSheet": true
          }
        }
      }
    }
  ]
}
```

## Add a Pie Chart

```json
{
  "addChart": {
    "chart": {
      "spec": {
        "title": "Sales by Region",
        "pieChart": {
          "legendPosition": "RIGHT_LEGEND",
          "threeDimensional": true,
          "domain": {
            "sourceRange": {
              "sources": [
                {
                  "sheetId": 0,
                  "startRowIndex": 0,
                  "endRowIndex": 5,
                  "startColumnIndex": 0,
                  "endColumnIndex": 1
                }
              ]
            }
          },
          "series": {
            "sourceRange": {
              "sources": [
                {
                  "sheetId": 0,
                  "startRowIndex": 0,
                  "endRowIndex": 5,
                  "startColumnIndex": 1,
                  "endColumnIndex": 2
                }
              ]
            }
          }
        }
      },
      "position": {
        "overlayPosition": {
          "anchorCell": {
            "sheetId": 0,
            "rowIndex": 0,
            "columnIndex": 4
          }
        }
      }
    }
  }
}
```

## Move and Resize a Chart

```json
{
  "updateEmbeddedObjectPosition": {
    "objectId": CHART_ID,
    "newPosition": {
      "overlayPosition": {
        "anchorCell": {
          "sheetId": 0,
          "rowIndex": 1,
          "columnIndex": 4
        },
        "offsetXPixels": 10,
        "offsetYPixels": 10,
        "widthPixels": 700,
        "heightPixels": 400
      }
    },
    "fields": "anchorCell,offsetXPixels,offsetYPixels,widthPixels,heightPixels"
  }
}
```

Default chart size: 600×371 pixels.

## Modify an Existing Chart

```json
{
  "updateChartSpec": {
    "chartId": CHART_ID,
    "spec": {
      "title": "Updated Chart Title",
      "basicChart": {
        "chartType": "BAR",
        "legendPosition": "RIGHT_LEGEND",
        "axis": [
          {
            "position": "BOTTOM_AXIS",
            "title": "Values",
            "format": {
              "fontSize": 14,
              "bold": true,
              "italic": true
            }
          }
        ]
      }
    }
  }
}
```

## Delete a Chart

```json
{
  "deleteEmbeddedObject": {
    "objectId": CHART_ID
  }
}
```

## Read Chart Data

```http
GET https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID?fields=sheets(charts)
```

Returns chart specifications and metadata for all charts in the spreadsheet.
