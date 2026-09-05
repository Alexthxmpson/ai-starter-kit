---
source: https://developers.google.com/sheets/api/samples/data
scraped: 2026-03-01
api: google-sheets-api
---

# Data Operations Samples — Google Sheets API

## Data Validation

Apply a validation rule where cell value must be > 5:

```json
{
  "requests": [
    {
      "setDataValidation": {
        "range": {
          "sheetId": 0,
          "startRowIndex": 0,
          "endRowIndex": 10,
          "startColumnIndex": 0,
          "endColumnIndex": 4
        },
        "rule": {
          "condition": {
            "type": "NUMBER_GREATER",
            "values": [
              { "userEnteredValue": "5" }
            ]
          },
          "inputMessage": "Value must be greater than 5",
          "strict": true
        }
      }
    }
  ]
}
```

## Copy Formatting Only (No Values)

```json
{
  "copyPaste": {
    "source": {
      "sheetId": 0,
      "startRowIndex": 0,
      "endRowIndex": 10,
      "startColumnIndex": 0,
      "endColumnIndex": 4
    },
    "destination": {
      "sheetId": 0,
      "startRowIndex": 0,
      "endRowIndex": 10,
      "startColumnIndex": 5,
      "endColumnIndex": 9
    },
    "pasteType": "PASTE_FORMAT"
  }
}
```

PasteType options: `PASTE_NORMAL`, `PASTE_VALUES`, `PASTE_FORMAT`, `PASTE_NO_BORDERS`, `PASTE_FORMULA`, `PASTE_DATA_VALIDATION`, `PASTE_CONDITIONAL_FORMATTING`

## Cut and Paste (Move Data)

```json
{
  "cutPaste": {
    "source": {
      "sheetId": 0,
      "startRowIndex": 0,
      "endRowIndex": 10,
      "startColumnIndex": 0,
      "endColumnIndex": 4
    },
    "destination": {
      "sheetId": 0,
      "rowIndex": 0,
      "columnIndex": 5
    },
    "pasteType": "PASTE_NORMAL"
  }
}
```

## Replicate Formula Across Range

`RepeatCellRequest` adjusts cell references automatically:

```json
{
  "repeatCell": {
    "range": {
      "sheetId": 0,
      "startRowIndex": 0,
      "endRowIndex": 10,
      "startColumnIndex": 1,
      "endColumnIndex": 4
    },
    "cell": {
      "userEnteredValue": {
        "formulaValue": "=FLOOR(A1*PI())"
      }
    },
    "fields": "userEnteredValue"
  }
}
```

Formula at B1 = `=FLOOR(A1*PI())`; formula at D6 auto-becomes `=FLOOR(C6*PI())`

## Multi-Criteria Sorting

Sort range A1:D10 by column B ascending, then C descending, then D descending:

```json
{
  "sortRange": {
    "range": {
      "sheetId": 0,
      "startRowIndex": 0,
      "endRowIndex": 10,
      "startColumnIndex": 0,
      "endColumnIndex": 4
    },
    "sortSpecs": [
      { "dimensionIndex": 1, "sortOrder": "ASCENDING" },
      { "dimensionIndex": 2, "sortOrder": "DESCENDING" },
      { "dimensionIndex": 3, "sortOrder": "DESCENDING" }
    ]
  }
}
```

## Find and Replace

```json
{
  "findReplace": {
    "find": "Total",
    "replacement": "Sum",
    "allSheets": true,
    "matchCase": false,
    "matchEntireCell": false
  }
}
```

## Named and Protected Ranges

### Add Named Range

```json
{
  "addNamedRange": {
    "namedRange": {
      "name": "Counts",
      "range": {
        "sheetId": 0,
        "startRowIndex": 0,
        "endRowIndex": 3,
        "startColumnIndex": 0,
        "endColumnIndex": 5
      }
    }
  }
}
```

### Add Protected Range (Warning Only)

```json
{
  "addProtectedRange": {
    "protectedRange": {
      "range": {
        "sheetId": 0,
        "startRowIndex": 3,
        "endRowIndex": 4,
        "startColumnIndex": 0,
        "endColumnIndex": 5
      },
      "description": "Protecting total row",
      "warningOnly": true
    }
  }
}
```

### Add Protected Range (Specific Users Only)

```json
{
  "updateProtectedRange": {
    "protectedRange": {
      "protectedRangeId": 123,
      "namedRangeId": "NAMED_RANGE_ID",
      "warningOnly": false,
      "editors": {
        "users": ["charlie@example.com", "sasha@example.com"]
      }
    },
    "fields": "namedRangeId,warningOnly,editors"
  }
}
```

### Delete Named Range

```json
{
  "deleteNamedRange": {
    "namedRangeId": "NAMED_RANGE_ID"
  }
}
```
