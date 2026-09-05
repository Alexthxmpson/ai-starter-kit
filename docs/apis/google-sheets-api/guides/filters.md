---
source: https://developers.google.com/sheets/api/guides/filters
scraped: 2026-03-01
api: google-sheets-api
---

# Filters — Google Sheets API

## Three Filter Types

| Type | Visibility | Persistence | Purpose |
|---|---|---|---|
| Basic Filter | Global (all viewers) | Until cleared | Quick analysis, single default per sheet |
| Filter Views | Individual | Saved as named views | Shared reports, multiple per sheet |
| Data Filter | API-only, non-persistent | Per-request | API queries without modifying spreadsheet |

## Basic Filter

A single default filter per sheet that applies to all viewers.

### Set Basic Filter

```json
{
  "setBasicFilter": {
    "filter": {
      "range": {
        "sheetId": 0,
        "startRowIndex": 0,
        "endRowIndex": 20,
        "startColumnIndex": 0,
        "endColumnIndex": 6
      },
      "sortSpecs": [
        {
          "dimensionIndex": 3,
          "sortOrder": "ASCENDING"
        }
      ],
      "filterCriteria": {
        "0": {
          "hiddenValues": ["Panel"]
        },
        "6": {
          "condition": {
            "type": "DATE_BEFORE",
            "values": {
              "userEnteredValue": "4/30/2016"
            }
          }
        }
      }
    }
  }
}
```

### Clear Basic Filter

```json
{
  "clearBasicFilter": {
    "sheetId": 0
  }
}
```

### Retrieve Basic Filter

```http
GET https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID?fields=sheets/basicFilter
```

## Filter Views

Named, reusable filters that can be toggled. Multiple filter views per sheet.

### Create Filter View

```json
{
  "addFilterView": {
    "filter": {
      "title": "Q1 2016",
      "range": {
        "sheetId": 0,
        "startRowIndex": 0,
        "endRowIndex": 20,
        "startColumnIndex": 0,
        "endColumnIndex": 6
      },
      "sortSpecs": [
        {
          "dimensionIndex": 3,
          "sortOrder": "ASCENDING"
        },
        {
          "dimensionIndex": 6,
          "sortOrder": "ASCENDING"
        }
      ],
      "filterCriteria": {
        "0": { "hiddenValues": ["Panel"] }
      }
    }
  }
}
```

### Duplicate Filter View

```json
{
  "duplicateFilterView": {
    "filterId": FILTER_VIEW_ID
  }
}
```

### Update Filter View

```json
{
  "updateFilterView": {
    "filter": {
      "filterViewId": FILTER_VIEW_ID,
      "filterCriteria": {
        "0": { "hiddenValues": ["Panel", "Patio"] }
      }
    },
    "fields": "filterCriteria"
  }
}
```

### Delete Filter View

```json
{
  "deleteFilterView": {
    "filterId": FILTER_VIEW_ID
  }
}
```

### List Filter Views

```http
GET https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID?fields=sheets/filterViews
```

### Filter View URL Sharing

```
https://docs.google.com/spreadsheets/d/SPREADSHEET_ID/edit#gid=0&fvid=FILTER_VIEW_ID
```

## Sort Specifications

```json
{
  "sortSpecs": [
    {
      "dimensionIndex": 3,
      "sortOrder": "ASCENDING"
    },
    {
      "dimensionIndex": 6,
      "sortOrder": "ASCENDING"
    }
  ]
}
```

## FilterCriteria Object

```json
{
  "filterCriteria": {
    "0": {
      "hiddenValues": ["Panel", "Patio"]
    },
    "3": {
      "condition": {
        "type": "DATE_AFTER",
        "values": [{ "userEnteredValue": "1/1/2016" }]
      }
    }
  }
}
```

Key: Column index (zero-based string)
Value: FilterCriteria with `hiddenValues` and/or `condition`
