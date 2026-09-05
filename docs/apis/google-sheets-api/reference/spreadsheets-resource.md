---
source: https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#Spreadsheet
scraped: 2026-03-01
api: google-sheets-api
---

# Spreadsheet Resource — Google Sheets API v4

## Core Resource Structure

```json
{
  "spreadsheetId": string,
  "properties": { SpreadsheetProperties },
  "sheets": [ { Sheet } ],
  "namedRanges": [ { NamedRange } ],
  "spreadsheetUrl": string,
  "developerMetadata": [ { DeveloperMetadata } ],
  "dataSources": [ { DataSource } ],
  "dataSourceSchedules": [ { DataSourceRefreshSchedule } ]
}
```

| Field | Type | Description |
|---|---|---|
| `spreadsheetId` | string (read-only) | Unique identifier |
| `properties` | SpreadsheetProperties | Overall spreadsheet settings |
| `sheets[]` | Sheet objects | Individual sheet tabs |
| `namedRanges[]` | NamedRange objects | Named cell ranges |
| `spreadsheetUrl` | string (read-only) | Access URL |
| `developerMetadata[]` | DeveloperMetadata | Custom metadata |
| `dataSources[]` | DataSource | External data connections |
| `dataSourceSchedules[]` | DataSourceRefreshSchedule (read-only) | Refresh schedules |

## SpreadsheetProperties

| Field | Type | Description |
|---|---|---|
| `title` | string | Spreadsheet name |
| `locale` | string | Language/region (ISO 639-1 or combined format) |
| `autoRecalc` | RecalculationInterval enum | Volatile function recalculation timing |
| `timeZone` | string | CLDR format timezone |
| `defaultFormat` | CellFormat (read-only) | Base cell formatting applied sheet-wide |
| `iterativeCalculationSettings` | object | Circular reference resolution |
| `spreadsheetTheme` | object | Applied theme with colors and fonts |
| `importFunctionsExternalUrlAccessAllowed` | boolean | External URL access control |

## RecalculationInterval Enum

| Value | Description |
|---|---|
| `ON_CHANGE` | Updates on every modification |
| `MINUTE` | Updates on change plus every minute |
| `HOUR` | Updates on change plus hourly |

## IterativeCalculationSettings

| Field | Type | Description |
|---|---|---|
| `maxIterations` | integer | Maximum calculation rounds |
| `convergenceThreshold` | number | Stops when successive results differ below this value |

## SpreadsheetTheme

| Field | Type | Description |
|---|---|---|
| `primaryFontFamily` | string | Default font name |
| `themeColors[]` | ThemeColorPair objects | Color mappings |

## NamedRange

| Field | Type | Description |
|---|---|---|
| `namedRangeId` | string | Unique ID |
| `name` | string | User-defined name |
| `range` | GridRange | Actual cell coordinates |

## DataSource (External Data Connections)

| Field | Type | Description |
|---|---|---|
| `dataSourceId` | string | Spreadsheet-scoped unique ID |
| `spec` | DataSourceSpec | Connection details |
| `calculatedColumns[]` | array | Derived columns |
| `sheetId` | integer | Associated sheet |

## DataSourceSpec

Supports two connection types:
- `bigQuery` (BigQueryDataSourceSpec) — BigQuery connection
- `looker` (LookerDataSourceSpec) — Looker instance connection
- `parameters[]` (DataSourceParameter) — Query variables

## BigQueryDataSourceSpec

| Field | Type | Description |
|---|---|---|
| `projectId` | string | Billing-enabled GCP project |
| `querySpec` or `tableSpec` | object | Query or table reference |

## DataSourceParameter

| Field | Type | Description |
|---|---|---|
| `name` | string | Parameter identifier |
| `namedRangeId` or `range` | string/GridRange | Value source |

## DataSourceRefreshSchedule

| Field | Type | Description |
|---|---|---|
| `enabled` | boolean | Active status |
| `refreshScope` | enum | `ALL_DATA_SOURCES` |
| `nextRun` | Interval (read-only) | Next execution window |
| `dailySchedule`, `weeklySchedule`, or `monthlySchedule` | object | Schedule type |

### Schedule Types

**Daily**: `startTime` (TimeOfDay) — only hours used

**Weekly**: `startTime` + `daysOfWeek[]` (Monday-Sunday enum)

**Monthly**: `startTime` + `daysOfMonth[]` (1-28 only)

### TimeOfDay

| Field | Range |
|---|---|
| `hours` | 0-23 |
| `minutes` | 0-59 |
| `seconds` | 0-59 |
| `nanos` | 0-999,999,999 |

## Available Methods

| Method | HTTP | Description |
|---|---|---|
| `create` | POST | Create new spreadsheet |
| `get` | GET | Retrieve spreadsheet by ID |
| `batchUpdate` | POST | Apply multiple updates |
| `getByDataFilter` | POST | Retrieve using data filter criteria |
