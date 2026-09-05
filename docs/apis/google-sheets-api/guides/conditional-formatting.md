---
source: https://developers.google.com/sheets/api/guides/conditional-format
scraped: 2026-03-01
api: google-sheets-api
---

# Conditional Formatting — Google Sheets API

## Overview

Conditional formatting dynamically changes cell appearance based on their values or values in other cells.

Common applications:
- Highlighting cells exceeding thresholds (e.g., bold text for transactions over $2,000)
- Color-coding cells based on value intensity (escalating red backgrounds)
- Formatting based on other cell content (highlight addresses with market time > 90 days)

## Formatting Rules Structure

Conditional formatting uses formatting rules stored in a spreadsheet list, applied in order. Each rule contains:
- **Target range**: Single cell, range, or multiple ranges
- **Rule type**: Boolean or Gradient
- **Conditions**: Criteria for triggering the rule
- **Formatting**: Appearance changes to apply

## Boolean Rules

A `BooleanRule` applies formatting when a `BooleanCondition` evaluates true:

```json
{
  "booleanRule": {
    "condition": {
      "type": "NUMBER_GREATER",
      "values": [
        { "userEnteredValue": "2000" }
      ]
    },
    "format": {
      "textFormat": {
        "bold": true
      }
    }
  }
}
```

### Built-in Condition Types

| Type | Description |
|---|---|
| `NUMBER_GREATER` | Cell value > condition value |
| `NUMBER_GREATER_THAN_EQ` | Cell value >= condition value |
| `NUMBER_LESS` | Cell value < condition value |
| `NUMBER_LESS_THAN_EQ` | Cell value <= condition value |
| `NUMBER_EQ` | Cell value = condition value |
| `NUMBER_NOT_EQ` | Cell value != condition value |
| `NUMBER_BETWEEN` | Cell value between two values |
| `NUMBER_NOT_BETWEEN` | Cell value not between two values |
| `TEXT_CONTAINS` | Cell text contains value |
| `TEXT_NOT_CONTAINS` | Cell text does not contain value |
| `TEXT_STARTS_WITH` | Cell text starts with value |
| `TEXT_ENDS_WITH` | Cell text ends with value |
| `TEXT_EQ` | Cell text equals value |
| `TEXT_IS_EMAIL` | Cell text is a valid email |
| `TEXT_IS_URL` | Cell text is a valid URL |
| `DATE_EQ` | Cell date equals value |
| `DATE_BEFORE` | Cell date before value |
| `DATE_AFTER` | Cell date after value |
| `DATE_ON_OR_BEFORE` | Cell date on or before value |
| `DATE_ON_OR_AFTER` | Cell date on or after value |
| `DATE_BETWEEN` | Cell date between two dates |
| `DATE_NOT_BETWEEN` | Cell date not between two dates |
| `DATE_IS_VALID` | Cell contains valid date |
| `ONE_OF_RANGE` | Cell value is in a range |
| `ONE_OF_LIST` | Cell value is in list |
| `BLANK` | Cell is blank |
| `NOT_BLANK` | Cell is not blank |
| `CUSTOM_FORMULA` | Custom formula evaluates to true |

### Custom Formulas

Allow arbitrary expressions that can evaluate any cells (not just the target). The formula must return true.

```json
{
  "booleanRule": {
    "condition": {
      "type": "CUSTOM_FORMULA",
      "values": [
        { "userEnteredValue": "=A1>MEDIAN($A$1:$A$100)" }
      ]
    },
    "format": {
      "backgroundColor": { "red": 1.0, "green": 0.0, "blue": 0.0 }
    }
  }
}
```

### Supported CellFormat Subset for Boolean Rules

- Bold, italic, strikethrough text
- Text color (`foregroundColor`)
- Background color (`backgroundColor`)

**Limitation:** Attempting to use unsupported properties like underlining, alignment, or borders results in a `400 invalid request` error.

## Gradient Rules

A `GradientRule` maps color ranges to value ranges using three `InterpolationPoint` objects:

```json
{
  "gradientRule": {
    "minpoint": {
      "color": { "green": 1.0 },
      "type": "MIN"
    },
    "midpoint": {
      "color": { "red": 1.0, "green": 1.0 },
      "type": "PERCENTILE",
      "value": "50"
    },
    "maxpoint": {
      "color": { "red": 1.0 },
      "type": "MAX"
    }
  }
}
```

### InterpolationPoint Types

| Type | Description |
|---|---|
| `MIN` | Minimum value in range |
| `MAX` | Maximum value in range |
| `NUMBER` | Specific number |
| `PERCENT` | Percentage of range |
| `PERCENTILE` | Percentile of range |

## Managing Rules

All via `spreadsheets.batchUpdate`:

| Request | Description |
|---|---|
| `AddConditionalFormatRuleRequest` | Insert rules at specified index |
| `UpdateConditionalFormatRuleRequest` | Replace or reorder rules |
| `DeleteConditionalFormatRuleRequest` | Remove rules by index |

### Add Rule Example

```json
{
  "addConditionalFormatRule": {
    "rule": {
      "ranges": [
        {
          "sheetId": 0,
          "startRowIndex": 1,
          "endRowIndex": 11,
          "startColumnIndex": 4,
          "endColumnIndex": 5
        }
      ],
      "booleanRule": {
        "condition": {
          "type": "CUSTOM_FORMULA",
          "values": [
            { "userEnteredValue": "=GT($E2,median($E$2:$E$11))" }
          ]
        },
        "format": {
          "textFormat": { "bold": true },
          "backgroundColor": { "red": 1, "green": 0, "blue": 0 }
        }
      }
    },
    "index": 0
  }
}
```
