# Google Sheets API — Full Technical Documentation

**Source:** https://developers.google.com/sheets/api/reference/rest
**Date Saved:** 2026-03-01
**API Version:** v4
**Service Endpoint:** https://sheets.googleapis.com
**Discovery Document:** https://sheets.googleapis.com/$discovery/rest?version=v4

---

## Overview

The Google Sheets API is a REST interface that lets you read and write Google Sheets programmatically. It replaces the deprecated Sheets API v3 (shut down August 2, 2021).

---

## Authentication

**Method:** OAuth 2.0 only. API keys are NOT supported.

### OAuth Scopes

| Scope | Access | Classification |
|---|---|---|
| `https://www.googleapis.com/auth/spreadsheets` | See, edit, create, delete all Sheets | Sensitive |
| `https://www.googleapis.com/auth/spreadsheets.readonly` | See all Sheets (read only) | Sensitive |
| `https://www.googleapis.com/auth/drive.file` | Only files this app created or opened | Non-sensitive (recommended) |
| `https://www.googleapis.com/auth/drive` | All Drive files | Restricted |
| `https://www.googleapis.com/auth/drive.readonly` | See and download all Drive files | Restricted |

**Key Rule:** Scopes apply to spreadsheet files as a whole, not individual sheets within a spreadsheet.

---

## Resources

### v4.spreadsheets

| Method | HTTP | Endpoint | Description |
|---|---|---|---|
| `create` | POST | `/v4/spreadsheets` | Create a new spreadsheet |
| `get` | GET | `/v4/spreadsheets/{spreadsheetId}` | Get spreadsheet by ID |
| `batchUpdate` | POST | `/v4/spreadsheets/{spreadsheetId}:batchUpdate` | Apply one or more updates atomically |
| `getByDataFilter` | POST | `/v4/spreadsheets/{spreadsheetId}:getByDataFilter` | Get spreadsheet matching data filters |

### v4.spreadsheets.values

| Method | HTTP | Endpoint | Description |
|---|---|---|---|
| `get` | GET | `/v4/spreadsheets/{id}/values/{range}` | Read single range |
| `batchGet` | GET | `/v4/spreadsheets/{id}/values:batchGet` | Read multiple ranges |
| `update` | PUT | `/v4/spreadsheets/{id}/values/{range}` | Write single range |
| `batchUpdate` | POST | `/v4/spreadsheets/{id}/values:batchUpdate` | Write multiple ranges |
| `append` | POST | `/v4/spreadsheets/{id}/values/{range}:append` | Append after last row of table |
| `clear` | POST | `/v4/spreadsheets/{id}/values/{range}:clear` | Clear values (keep formatting) |
| `batchClear` | POST | `/v4/spreadsheets/{id}/values:batchClear` | Clear multiple ranges |
| `batchGetByDataFilter` | POST | `/v4/spreadsheets/{id}/values:batchGetByDataFilter` | Read by metadata filter |
| `batchUpdateByDataFilter` | POST | `/v4/spreadsheets/{id}/values:batchUpdateByDataFilter` | Write by metadata filter |
| `batchClearByDataFilter` | POST | `/v4/spreadsheets/{id}/values:batchClearByDataFilter` | Clear by metadata filter |

### v4.spreadsheets.developerMetadata

| Method | HTTP | Endpoint | Description |
|---|---|---|---|
| `get` | GET | `/v4/spreadsheets/{id}/developerMetadata/{metadataId}` | Get metadata by ID |
| `search` | POST | `/v4/spreadsheets/{id}/developerMetadata:search` | Search metadata by filter |

### v4.spreadsheets.sheets

| Method | HTTP | Endpoint | Description |
|---|---|---|---|
| `copyTo` | POST | `/v4/spreadsheets/{id}/sheets/{sheetId}:copyTo` | Copy sheet to another spreadsheet |

---

## Key Enums

### ValueInputOption
Controls how written values are interpreted.

| Value | Description |
|---|---|
| `RAW` | Literal strings; formulas stay as text |
| `USER_ENTERED` | Parsed like UI input; dates/currencies/formulas evaluated |

### ValueRenderOption
Controls how values appear in read responses.

| Value | Description |
|---|---|
| `FORMATTED_VALUE` (default) | Displayed value with number format applied |
| `UNFORMATTED_VALUE` | Raw stored value (dates as serial numbers) |
| `FORMULA` | Returns formula text instead of calculated result |

### DateTimeRenderOption
Only applies when `valueRenderOption` is NOT `FORMATTED_VALUE`.

| Value | Description |
|---|---|
| `SERIAL_NUMBER` (default) | Days since Dec 30, 1899; time as fraction of day |
| `FORMATTED_STRING` | Human-readable date string per spreadsheet locale |

### InsertDataOption (append only)

| Value | Description |
|---|---|
| `OVERWRITE` | Overwrite existing data |
| `INSERT_ROWS` | Insert new rows for the data |

### Dimension

| Value | Description |
|---|---|
| `ROWS` (default) | Data organized as rows |
| `COLUMNS` | Data organized as columns |

---

## spreadsheets.values.get — Full Reference

```
GET https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{range}
```

**Path Parameters:**
- `spreadsheetId` (string, required) — The spreadsheet ID
- `range` (string, required) — A1 or R1C1 notation

**Query Parameters:**
- `majorDimension` (Dimension, optional) — Default: ROWS
- `valueRenderOption` (ValueRenderOption, optional) — Default: FORMATTED_VALUE
- `dateTimeRenderOption` (DateTimeRenderOption, optional) — Default: SERIAL_NUMBER (ignored if valueRenderOption is FORMATTED_VALUE)

**Response — ValueRange:**
```json
{
  "range": "Sheet1!A1:D5",
  "majorDimension": "ROWS",
  "values": [
    ["header1", "header2"],
    ["value1", "value2"]
  ]
}
```

---

## spreadsheets.values.update — Full Reference

```
PUT https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{range}
```

**Path Parameters:**
- `spreadsheetId` (string, required)
- `range` (string, required) — A1 notation

**Query Parameters:**
- `valueInputOption` (ValueInputOption, **required**)
- `includeValuesInResponse` (boolean, optional)
- `responseValueRenderOption` (ValueRenderOption, optional) — Default: FORMATTED_VALUE
- `responseDateTimeRenderOption` (DateTimeRenderOption, optional) — Default: SERIAL_NUMBER

**Request Body — ValueRange:**
```json
{
  "range": "Sheet1!A1:D5",
  "majorDimension": "ROWS",
  "values": [["a", "b"], ["c", "d"]]
}
```

**Response — UpdateValuesResponse:**
```json
{
  "spreadsheetId": "...",
  "updatedRange": "Sheet1!A1:D5",
  "updatedRows": 2,
  "updatedColumns": 2,
  "updatedCells": 4
}
```

---

## spreadsheets.values.append — Full Reference

```
POST https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{range}:append
```

**Query Parameters:**
- `valueInputOption` (required)
- `insertDataOption` (InsertDataOption) — Default: OVERWRITE
- `includeValuesInResponse` (boolean) — Default: false
- `responseValueRenderOption` — Default: FORMATTED_VALUE
- `responseDateTimeRenderOption` — Default: SERIAL_NUMBER

**Response:**
```json
{
  "spreadsheetId": "...",
  "tableRange": "Sheet1!A1:D5",
  "updates": { "updatedRange": "Sheet1!A6:D7", "updatedRows": 2 }
}
```

---

## spreadsheets.values.batchUpdate — Full Reference

```
POST https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values:batchUpdate
```

**Request Body:**
```json
{
  "valueInputOption": "USER_ENTERED",
  "data": [
    {
      "range": "Sheet1!A1:B2",
      "majorDimension": "ROWS",
      "values": [["a", "b"], ["c", "d"]]
    }
  ],
  "includeValuesInResponse": false,
  "responseValueRenderOption": "FORMATTED_VALUE"
}
```

**Response:**
```json
{
  "spreadsheetId": "...",
  "totalUpdatedRows": 2,
  "totalUpdatedColumns": 2,
  "totalUpdatedCells": 4,
  "totalUpdatedSheets": 1,
  "responses": [{ "updatedRange": "Sheet1!A1:B2", ... }]
}
```

---

## spreadsheets.batchUpdate — Full Reference

```
POST https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}:batchUpdate
```

**Request Body:**
```json
{
  "requests": [ { Request } ],
  "includeSpreadsheetInResponse": false,
  "responseRanges": [],
  "responseIncludeGridData": false
}
```

**Response:**
```json
{
  "spreadsheetId": "...",
  "replies": [ { Response } ],
  "updatedSpreadsheet": { Spreadsheet }
}
```

All requests are applied atomically. If any fails, none are applied.

### Complete List of Request Types

**Sheet/Structure:**
`addSheet`, `duplicateSheet`, `deleteSheet`, `updateSheetProperties`

**Dimensions:**
`insertDimension`, `deleteDimension`, `moveDimension`, `appendDimension`, `autoResizeDimensions`, `updateDimensionProperties`

**Cells:**
`updateCells`, `repeatCell`, `appendCells`, `mergeCells`, `unmergeCells`, `copyPaste`, `cutPaste`, `autoFill`, `findReplace`, `sortRange`, `insertRange`, `deleteRange`

**Borders:** `updateBorders`

**Named/Protected Ranges:**
`addNamedRange`, `updateNamedRange`, `deleteNamedRange`, `addProtectedRange`, `updateProtectedRange`, `deleteProtectedRange`

**Filters:**
`setBasicFilter`, `clearBasicFilter`, `addFilterView`, `updateFilterView`, `duplicateFilterView`, `deleteFilterView`

**Conditional Formatting:**
`addConditionalFormatRule`, `updateConditionalFormatRule`, `deleteConditionalFormatRule`

**Data Validation:** `setDataValidation`

**Charts:**
`addChart`, `updateChartSpec`, `updateEmbeddedObjectPosition`, `deleteEmbeddedObject`

**Banded Ranges:** `addBanding`, `updateBanding`, `deleteBanding`

**Dimension Groups:** `addDimensionGroup`, `deleteDimensionGroup`

**Developer Metadata:**
`createDeveloperMetadata`, `updateDeveloperMetadata`, `deleteDeveloperMetadata`

**Spreadsheet Properties:** `updateSpreadsheetProperties`

**Connected Sheets/Data Sources:**
`addDataSource`, `updateDataSource`, `deleteDataSource`, `refreshDataSource`

**Tables:** `addTable`, `updateTable`, `deleteTable`

---

## Cell Reference Notation

### A1 Notation
- `Sheet1!A1:B2` — rows 1-2, columns A-B on Sheet1
- `Sheet1!A:A` — entire column A
- `Sheet1!1:2` — entire rows 1 and 2
- `A1:B2` — same sheet as context
- `'My Sheet'!A1:B2` — sheet name with spaces requires single quotes

### R1C1 Notation
- `Sheet1!R1C1:R2C2` — row 1 col 1 to row 2 col 2
- `Sheet1!R[3]C[1]` — 3 rows down, 1 column right (relative)

---

## Spreadsheet Resource Schema (Abbreviated)

```json
{
  "spreadsheetId": string,
  "properties": {
    "title": string,
    "locale": string,
    "autoRecalc": "ON_CHANGE" | "MINUTE" | "HOUR",
    "timeZone": string
  },
  "sheets": [
    {
      "properties": {
        "sheetId": integer,
        "title": string,
        "index": integer,
        "sheetType": "GRID" | "OBJECT" | "DATA_SOURCE",
        "gridProperties": {
          "rowCount": integer,
          "columnCount": integer,
          "frozenRowCount": integer,
          "frozenColumnCount": integer,
          "hideGridlines": boolean
        },
        "hidden": boolean,
        "tabColor": { "red": float, "green": float, "blue": float }
      }
    }
  ],
  "namedRanges": [
    {
      "namedRangeId": string,
      "name": string,
      "range": {
        "sheetId": integer,
        "startRowIndex": integer,
        "endRowIndex": integer,
        "startColumnIndex": integer,
        "endColumnIndex": integer
      }
    }
  ]
}
```

---

## Error Codes

| Code | Status | Cause | Fix |
|---|---|---|---|
| 400 | Bad Request | Malformed request, invalid fields | Check API reference; fix request body |
| 401 | Unauthorized | Missing or invalid OAuth token | Re-authenticate |
| 403 | Forbidden | Insufficient scope or no access to spreadsheet | Add required scope; share spreadsheet |
| 404 | Not Found | Spreadsheet or range not found | Verify spreadsheet ID and range |
| 429 | Too Many Requests | Quota exceeded | Exponential backoff |
| 500 | Internal Server Error | API bug | Report on issue tracker |
| 503 | Service Unavailable | Service down or spreadsheet too complex | Reduce complexity; use field masks; retry |

### Exponential Backoff Formula

```python
import time
import random

def make_request_with_backoff(func, max_retries=5):
    for n in range(max_retries):
        try:
            return func()
        except HttpError as e:
            if e.status_code == 429:
                wait = min((2**n) + random.random(), 64)
                time.sleep(wait)
            else:
                raise
    raise Exception("Max retries exceeded")
```

---

## Usage Limits

| Limit | Value |
|---|---|
| Read requests/minute/project | 300 |
| Write requests/minute/project | 300 |
| Read requests/minute/user/project | 60 |
| Write requests/minute/user/project | 60 |
| Recommended max payload | 2 MB |
| Max processing time per request | 180 seconds |
| Developer metadata per spreadsheet | 30,000 characters |
| Developer metadata per sheet | 30,000 characters |
| Pricing | Free |

---

## Python Client Setup

```python
# Install
# python3 -m pip install google-api-python-client google-auth-httplib2 google-auth-oauthlib

from googleapiclient.discovery import build
from google.oauth2 import service_account

# Service Account (recommended for automation)
SCOPES = ['https://www.googleapis.com/auth/spreadsheets']
creds = service_account.Credentials.from_service_account_file(
    'service_account.json', scopes=SCOPES
)
service = build('sheets', 'v4', credentials=creds)

# Now use service.spreadsheets().values().get(...) etc.
```

See `/overview/authentication.md` for OAuth2 setup (user-authorized apps).
See `/samples/` for complete code examples.
