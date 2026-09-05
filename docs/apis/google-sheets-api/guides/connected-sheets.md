---
source: https://developers.google.com/sheets/api/guides/connected-sheets
scraped: 2026-03-01
api: google-sheets-api
---

# Connected Sheets (BigQuery & Looker) — Google Sheets API

## Overview

Connected Sheets enables analysis of massive datasets directly within Google Sheets by linking to BigQuery or Looker data warehouses. Users leverage familiar Sheets functionality like pivot tables, charts, and formulas for data exploration.

## BigQuery Integration

### Setup Requirements

- OAuth 2.0 token with `bigquery.readonly` scope
- Valid Google Cloud project ID

### Data Source Objects Supported

- Data source tables (extracts up to 1,000 rows)
- Pivot tables with aggregation functions
- Charts (various types including column charts)
- Formulas referencing connected data

### Adding a BigQuery Data Source

```json
{
  "addDataSource": {
    "dataSource": {
      "spec": {
        "bigQuery": {
          "projectId": "my-gcp-project",
          "querySpec": {
            "rawQuery": "SELECT region, SUM(sales) FROM `dataset.sales` GROUP BY region"
          }
        }
      }
    }
  }
}
```

Alternative — table spec:

```json
{
  "bigQuery": {
    "projectId": "my-gcp-project",
    "tableSpec": {
      "tableProjectId": "data-project",
      "datasetId": "my_dataset",
      "tableId": "my_table"
    }
  }
}
```

### Key Process

1. Add data source via `AddDataSourceRequest`
2. Response contains `dataSourceId` for referencing the connection
3. A `DATA_SOURCE` sheet provides a preview of up to 500 rows
4. Data import occurs asynchronously

### Asynchronous Operations

Poll `spreadsheets.get()` repeatedly until `DataExecutionStatus` returns `SUCCEEDED` or `FAILED`. Execution typically completes within 10 minutes.

```python
import time

while True:
    result = service.spreadsheets().get(
        spreadsheetId=spreadsheet_id,
        fields="sheets.data.rowData"
    ).execute()

    # Check execution status
    status = get_data_execution_status(result)
    if status in ["SUCCEEDED", "FAILED"]:
        break
    time.sleep(5)
```

## Looker Integration

### Setup Requirements

- Instance URI
- Model name
- Explore name
- Reuses existing Google Account Link with Looker

### Limitations

"It is not possible to create DataSource formulas, extracts, and charts from Looker data sources." Only pivot tables are supported for Looker connections.

```json
{
  "addDataSource": {
    "dataSource": {
      "spec": {
        "looker": {
          "instanceUri": "https://mycompany.looker.com",
          "model": "sales",
          "explore": "orders"
        }
      }
    }
  }
}
```

## Data Source API Methods

| Method | Description |
|---|---|
| `AddDataSourceRequest` | Connect a new external data source |
| `UpdateDataSourceRequest` | Modify data source connection |
| `DeleteDataSourceRequest` | Remove data source |
| `RefreshDataSourceRequest` | Refresh connected data |

## DataSourceParameter

Connect cell values to query parameters:

```json
{
  "parameters": [
    {
      "name": "start_date",
      "namedRangeId": "MY_NAMED_RANGE_ID"
    }
  ]
}
```
