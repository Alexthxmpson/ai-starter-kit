---
source: https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values
scraped: 2026-03-01
api: google-sheets-api
---

# spreadsheets.values Methods — Google Sheets API v4

The `spreadsheets.values` resource provides read/write access to cell values.

## Enums Reference

### ValueInputOption
How input data is interpreted when writing.

| Value | Description |
|---|---|
| `RAW` | Input treated as literal strings; formulas like "=1+2" remain as text |
| `USER_ENTERED` | Input parsed as if entered via Sheets UI; "Mar 1 2016" becomes a date, "$100.15" gains currency formatting |
| `INPUT_VALUE_OPTION_UNSPECIFIED` | Default, invalid for most operations |

### ValueRenderOption
How values are rendered in output.

| Value | Description |
|---|---|
| `FORMATTED_VALUE` (default) | Values as displayed in the UI, respecting number formatting |
| `UNFORMATTED_VALUE` | Values as stored, without number formatting |
| `FORMULA` | Returns formulas rather than calculated values |

### DateTimeRenderOption
How dates/times are rendered (only applies when `valueRenderOption` is NOT `FORMATTED_VALUE`).

| Value | Description |
|---|---|
| `SERIAL_NUMBER` (default) | Days since December 30, 1899; time as fraction of a day |
| `FORMATTED_STRING` | Date/time as formatted string using the spreadsheet's locale |

### InsertDataOption (for append)

| Value | Description |
|---|---|
| `OVERWRITE` | New data overwrites existing data (rows/columns still insert at sheet end) |
| `INSERT_ROWS` | New rows inserted for the data |

### Dimension

| Value | Description |
|---|---|
| `ROWS` (default) | Organize data as rows |
| `COLUMNS` | Organize data as columns |

---

## spreadsheets.values.get

**GET** `https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{range}`

Read values from a single range.

**Path Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `spreadsheetId` | string | The ID of the spreadsheet to retrieve data from |
| `range` | string | The A1 or R1C1 notation of the range to retrieve values from |

**Query Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `majorDimension` | Dimension enum | ROWS or COLUMNS format (default: ROWS) |
| `valueRenderOption` | ValueRenderOption enum | How values should be represented (default: FORMATTED_VALUE) |
| `dateTimeRenderOption` | DateTimeRenderOption enum | How dates/times render; ignored if valueRenderOption is FORMATTED_VALUE (default: SERIAL_NUMBER) |

**Request Body:** Must be empty

**Response:** `ValueRange` object

```json
{
  "range": string,
  "majorDimension": enum(Dimension),
  "values": [ [ value ] ]
}
```

**Required Scopes (one of):**
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.readonly`
- `https://www.googleapis.com/auth/drive.file`
- `https://www.googleapis.com/auth/spreadsheets`
- `https://www.googleapis.com/auth/spreadsheets.readonly`

---

## spreadsheets.values.batchGet

**GET** `https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values:batchGet`

Read multiple ranges at once.

**Path Parameters:**
- `spreadsheetId` (string, required)

**Query Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `ranges[]` | string | Cell range in A1 or R1C1 notation (repeat for multiple ranges) |
| `majorDimension` | Dimension enum | ROWS or COLUMNS (default: ROWS) |
| `valueRenderOption` | ValueRenderOption enum | Default: FORMATTED_VALUE |
| `dateTimeRenderOption` | DateTimeRenderOption enum | Default: SERIAL_NUMBER |

**Request Body:** Must be empty

**Response:** `BatchGetValuesResponse`

```json
{
  "spreadsheetId": string,
  "valueRanges": [ { ValueRange } ]
}
```

**Required Scopes:** Same as values.get

---

## spreadsheets.values.update

**PUT** `https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{range}`

Write values to a single range.

**Path Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `spreadsheetId` | string | The ID of the spreadsheet to update |
| `range` | string | The A1 notation of the values to update |

**Query Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `valueInputOption` | enum (required) | How input data should be interpreted (RAW or USER_ENTERED) |
| `includeValuesInResponse` | boolean | Whether response includes updated cell values |
| `responseValueRenderOption` | enum | How values in response should render (default: FORMATTED_VALUE) |
| `responseDateTimeRenderOption` | enum | How dates/times render in response (default: SERIAL_NUMBER) |

**Request Body:** `ValueRange` object

**Response:** `UpdateValuesResponse`

```json
{
  "spreadsheetId": string,
  "updatedRange": string,
  "updatedRows": integer,
  "updatedColumns": integer,
  "updatedCells": integer,
  "updatedData": { ValueRange }
}
```

**Required Scopes (one of):**
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`
- `https://www.googleapis.com/auth/spreadsheets`

---

## spreadsheets.values.batchUpdate

**POST** `https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values:batchUpdate`

Write values to multiple ranges simultaneously.

**Path Parameters:**
- `spreadsheetId` (string, required)

**Request Body:**

```json
{
  "valueInputOption": enum (required),
  "data": [ { ValueRange } ],
  "includeValuesInResponse": boolean,
  "responseValueRenderOption": enum,
  "responseDateTimeRenderOption": enum
}
```

**Response:** `BatchUpdateValuesResponse`

```json
{
  "spreadsheetId": string,
  "totalUpdatedRows": integer,
  "totalUpdatedColumns": integer,
  "totalUpdatedCells": integer,
  "totalUpdatedSheets": integer,
  "responses": [ { UpdateValuesResponse } ]
}
```

**Required Scopes (one of):**
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`
- `https://www.googleapis.com/auth/spreadsheets`

---

## spreadsheets.values.append

**POST** `https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{range}:append`

Append values after a detected data table.

**Path Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `spreadsheetId` | string | The spreadsheet ID to update |
| `range` | string | A1 notation range for table detection; values append after the last row |

**Query Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `valueInputOption` | enum (required) | How input data should be interpreted |
| `insertDataOption` | InsertDataOption enum | OVERWRITE or INSERT_ROWS |
| `includeValuesInResponse` | boolean | Whether to include appended values in response (default: false) |
| `responseValueRenderOption` | ValueRenderOption enum | Default: FORMATTED_VALUE |
| `responseDateTimeRenderOption` | DateTimeRenderOption enum | Default: SERIAL_NUMBER |

**Request Body:** `ValueRange` object

**Response:**

```json
{
  "spreadsheetId": string,
  "tableRange": string,
  "updates": { UpdateValuesResponse }
}
```

| Field | Description |
|---|---|
| `tableRange` | A1 notation of table before appending (empty if no table found) |
| `updates` | Information about applied updates |

**Required Scopes (one of):**
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`
- `https://www.googleapis.com/auth/spreadsheets`

---

## spreadsheets.values.clear

**POST** `https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{range}:clear`

Clear values from a range (preserves formatting, data validation, and other properties).

**Path Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `spreadsheetId` | string | The ID of the spreadsheet to update |
| `range` | string | The A1 or R1C1 notation of the values to clear |

**Request Body:** Must be empty

**Response:**

```json
{
  "spreadsheetId": string,
  "clearedRange": string
}
```

**Required Scopes (one of):**
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`
- `https://www.googleapis.com/auth/spreadsheets`

---

## spreadsheets.values.batchClear

**POST** `https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values:batchClear`

Clear values from multiple ranges.

**Request Body:**

```json
{
  "ranges": [ string ]
}
```

**Required Scopes:** Same as values.clear

---

## spreadsheets.values.batchGetByDataFilter

**POST** `https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values:batchGetByDataFilter`

Read values matching developer metadata filters.

**Required Scopes (one of):**
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`
- `https://www.googleapis.com/auth/spreadsheets`

---

## spreadsheets.values.batchUpdateByDataFilter

**POST** `https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values:batchUpdateByDataFilter`

Update values matching developer metadata filters.

**Required Scopes (one of):**
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`
- `https://www.googleapis.com/auth/spreadsheets`

---

## spreadsheets.values.batchClearByDataFilter

**POST** `https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values:batchClearByDataFilter`

Clear values matching developer metadata filters.

**Required Scopes (one of):**
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`
- `https://www.googleapis.com/auth/spreadsheets`

---

## Important Notes

- Empty trailing rows/columns are omitted from responses
- To clear data, use empty strings (`""`)
- Use `null` in values array to skip cells without clearing them
- For insertion/deletion of rows or formatting changes, use `spreadsheets.batchUpdate()` instead
