---
source: https://developers.google.com/sheets/api/guides/pivot-tables
scraped: 2026-03-01
api: google-sheets-api
---

# Pivot Tables — Google Sheets API

## Overview

Pivot tables automatically summarize spreadsheet data through aggregation, sorting, counting, or averaging. They function as queries against source datasets, presenting processed views in new tables.

## Key Characteristics

- Pivot table definitions are associated with a single cell coordinate — the top-left corner of the displayed table
- The rendered output spans multiple rows and columns automatically
- There are no dedicated modification or deletion requests — update the cell with different content or clear it

## Creating a Pivot Table

Use `batchUpdate` with an `updateCells` request, supplying a `PivotTable` definition in a cell:

```json
{
  "updateCells": {
    "rows": {
      "values": [
        {
          "pivotTable": {
            "source": {
              "sheetId": SOURCE_SHEET_ID,
              "startRowIndex": 0,
              "startColumnIndex": 0,
              "endRowIndex": 20,
              "endColumnIndex": 7
            },
            "rows": [
              {
                "sourceColumnOffset": 1,
                "showTotals": true,
                "sortOrder": "ASCENDING"
              }
            ],
            "columns": [
              {
                "sourceColumnOffset": 4,
                "sortOrder": "ASCENDING",
                "showTotals": true
              }
            ],
            "values": [
              {
                "summarizeFunction": "COUNTA",
                "sourceColumnOffset": 4
              }
            ],
            "valueLayout": "HORIZONTAL"
          }
        }
      ]
    },
    "start": {
      "sheetId": DEST_SHEET_ID,
      "rowIndex": 0,
      "columnIndex": 0
    },
    "fields": "pivotTable"
  }
}
```

## PivotTable Configuration Options

| Field | Description |
|---|---|
| `source` | Source data range (GridRange) |
| `rows[]` | PivotGroup objects for row fields |
| `columns[]` | PivotGroup objects for column fields |
| `values[]` | PivotValue objects for data aggregation |
| `criteria` | PivotFilterCriteria for filtering |
| `valueLayout` | HORIZONTAL or VERTICAL |

### PivotGroup Fields

| Field | Description |
|---|---|
| `sourceColumnOffset` | Column index in source data |
| `showTotals` | Whether to show totals |
| `sortOrder` | ASCENDING or DESCENDING |
| `valueBucket` | For grouping by value |
| `groupRule` | Grouping rule (date groups, histogram, etc.) |

### Aggregation Functions (summarizeFunction)

`SUM`, `COUNT`, `AVERAGE`, `MAX`, `MIN`, `MEDIAN`, `PRODUCT`, `STDEV`, `STDEVP`, `VAR`, `VARP`, `COUNTA`, `COUNTUNIQUE`, `CUSTOM`

## Modifying and Deleting

- **Modify**: Use `updateCells` with new `PivotTable` definition and `fields: "pivotTable"`
- **Delete**: Use `updateCells` with empty value and `fields: "pivotTable"`

## Common Use Cases

- Total sales by region and quarter
- Average salary by title and location
- Count of incidents by product and time period
- Account-specific aggregated data analysis
- Recent period exploration (e.g., 24-hour incident data)

## Connected Sheets Pivot Tables (BigQuery)

Pivot tables can also connect to BigQuery data sources via Connected Sheets. Setup requires:
- OAuth 2.0 token with `bigquery.readonly` scope
- Valid Google Cloud project ID

```json
{
  "addDataSource": {
    "dataSource": {
      "spec": {
        "bigQuery": {
          "projectId": "my-project",
          "querySpec": {
            "rawQuery": "SELECT * FROM `dataset.table`"
          }
        }
      }
    }
  }
}
```
