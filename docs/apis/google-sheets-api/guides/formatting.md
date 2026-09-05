---
source: https://developers.google.com/sheets/api/guides/formats
scraped: 2026-03-01
api: google-sheets-api
---

# Formatting — Google Sheets API

## Implementation

All formatting uses `spreadsheets.batchUpdate` with:
- `UpdateCellsRequest` — for specific cells
- `RepeatCellRequest` — for applying same format across a range

```http
POST https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID:batchUpdate
```

---

## Cell Borders

Use `UpdateBordersRequest`:

```json
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
```

Border styles: `DOTTED`, `DASHED`, `SOLID`, `SOLID_MEDIUM`, `SOLID_THICK`, `DOUBLE`, `NONE`

---

## Format Header Rows

`RepeatCellRequest` formats entire rows with text color, background color, font size, alignment, and bold:

```json
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
```

Color values are 0.0-1.0 (float), not 0-255.

---

## Merge Cells

```json
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
```

Merge types:
- `MERGE_ALL` — Merges entire range into one cell
- `MERGE_COLUMNS` — Merges within each column, maintains row separation
- `MERGE_ROWS` — Merges within each row

---

## Number Formats

### Structure

Patterns use up to four semicolon-separated sections:
`[POSITIVE];[NEGATIVE];[ZERO];[TEXT]`

### Core Number Tokens

| Token | Purpose |
|---|---|
| `0` | Digit with leading zeros |
| `#` | Digit without insignificant zeros |
| `?` | Digit rendered as space if insignificant |
| `.` | Decimal point |
| `%` | Percentage (multiplies by 100) |
| `,` | Thousands separator or scaling |
| `E+` / `E-` | Scientific notation |
| `/` | Fractional format |
| `\` | Literal character escape |

### Meta Instructions

- `[condition]` — Applies format based on value comparison (e.g., `[<100]"Low";[>1000]"High"`)
- `[Color]` or `[Color#]` — Text color using names (Black, Blue, Red, etc.) or numbers 1-56

### Example Formats

```json
{
  "repeatCell": {
    "range": { "sheetId": 0, "startRowIndex": 1, "endRowIndex": 2 },
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
```

---

## Date-Time Formats

Google Sheets uses an epoch date system:
- Whole number = days since December 30, 1899
- Fractional part = time as fraction of one day (noon = 0.5)

### Date-Time Tokens

| Token | Function |
|---|---|
| `h` / `hh+` | Hour (12/24-hour based on AM/PM presence) |
| `m` / `mm` | Minutes or month (context-dependent) |
| `M` / `MM` | Month (explicit, with/without leading zero) |
| `mmm` / `mmmm` | Month abbreviation or full name |
| `s` / `ss` | Seconds without/with leading zero |
| `d` / `dd` | Day without/with leading zero |
| `ddd` / `dddd+` | Day abbreviation or full name |
| `y` / `yy` / `yyyy+` | 2-digit or 4-digit year |
| `a/p` or `am/pm` | AM/PM indicator |
| `[h+]` / `[m+]` / `[s+]` | Elapsed time duration |

### Example DateTime Format

```json
{
  "numberFormat": {
    "type": "DATE_TIME",
    "pattern": "hh:mm:ss am/pm, ddd mmm dd yyyy"
  }
}
```

Result: "02:05:07 PM, Sun Apr 03 2016"

**Note:** Rendering depends on the spreadsheet's locale setting (default: `en_US`)
