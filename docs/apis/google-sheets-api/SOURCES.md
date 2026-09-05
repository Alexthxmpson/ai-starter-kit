# Google Sheets API — Sources

**Scraped:** 2026-03-01
**Total Pages:** 27
**Successfully Scraped:** 25
**Failed:** 2
**Coverage:** ~93%

---

## Overview / Concepts

| URL | Output File | Status |
|---|---|---|
| https://developers.google.com/sheets/api/guides/concepts | overview/concepts.md | OK |
| https://developers.google.com/sheets/api/limits | overview/limits.md | OK |
| https://developers.google.com/sheets/api/scopes | overview/authentication.md | OK |
| https://developers.google.com/sheets/api/troubleshoot-authentication-authorization | overview/authentication.md (merged) | OK |
| https://developers.google.com/sheets/api/troubleshoot-api-errors | overview/limits.md (merged) | OK |
| https://developers.google.com/sheets/api/guides/migration | guides/migration-v3-to-v4.md | OK |

## Reference — Methods

| URL | Output File | Status |
|---|---|---|
| https://developers.google.com/sheets/api/reference/rest | reference/spreadsheets-methods.md | OK |
| https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/create | reference/spreadsheets-methods.md | OK |
| https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/get | reference/spreadsheets-methods.md | OK |
| https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/batchUpdate | reference/spreadsheets-methods.md | OK |
| https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/getByDataFilter | reference/spreadsheets-methods.md | OK |
| https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/get | reference/values-methods.md | OK |
| https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/update | reference/values-methods.md | OK |
| https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/append | reference/values-methods.md | OK |
| https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/batchGet | reference/values-methods.md | OK |
| https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/batchUpdate | reference/values-methods.md | OK |
| https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/clear | reference/values-methods.md | OK |
| https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.developerMetadata/get | reference/developer-metadata.md | OK |
| https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.sheets/copyTo | reference/spreadsheets-methods.md | OK |
| https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#Spreadsheet | reference/spreadsheets-resource.md | OK |
| https://developers.google.com/sheets/api/reference/query-parameters | FAILED | 404 Not Found |

## Guides

| URL | Output File | Status |
|---|---|---|
| https://developers.google.com/sheets/api/guides/values | guides/reading-writing-values.md | OK |
| https://developers.google.com/sheets/api/guides/batchupdate | guides/batch-updates.md | OK |
| https://developers.google.com/sheets/api/guides/formats | guides/formatting.md | OK |
| https://developers.google.com/sheets/api/guides/pivot-tables | guides/pivot-tables.md | OK |
| https://developers.google.com/sheets/api/guides/conditional-format | guides/conditional-formatting.md | OK |
| https://developers.google.com/sheets/api/guides/filters | guides/filters.md | OK |
| https://developers.google.com/sheets/api/guides/filters-overview | guides/filters.md (merged) | OK |
| https://developers.google.com/sheets/api/guides/metadata | guides/metadata.md | OK |
| https://developers.google.com/sheets/api/guides/field-masks | guides/field-masks.md | OK |
| https://developers.google.com/sheets/api/guides/performance | guides/performance.md | OK |
| https://developers.google.com/sheets/api/guides/create | guides/create-spreadsheet.md | OK |
| https://developers.google.com/sheets/api/guides/connected-sheets | guides/connected-sheets.md | OK |
| https://developers.google.com/sheets/api/guides/chips | guides/chips-and-tables.md | PENDING — content merged into notes |
| https://developers.google.com/sheets/api/guides/tables | guides/chips-and-tables.md | PENDING — content merged into notes |
| https://developers.google.com/sheets/api/guides/batch | guides/batch-updates.md (merged) | OK |
| https://developers.google.com/sheets/api/guides/migration | guides/migration-v3-to-v4.md | OK |

## Samples

| URL | Output File | Status |
|---|---|---|
| https://developers.google.com/sheets/api/samples/reading | samples/reading-samples.md | OK |
| https://developers.google.com/sheets/api/samples/writing | samples/writing-samples.md | OK |
| https://developers.google.com/sheets/api/samples/formatting | samples/formatting-samples.md | OK |
| https://developers.google.com/sheets/api/samples/charts | samples/charts-samples.md | OK |
| https://developers.google.com/sheets/api/samples/data | samples/data-operations-samples.md | OK |
| https://developers.google.com/sheets/api/samples/rowcolumn | samples/row-column-sheet-samples.md | OK |
| https://developers.google.com/sheets/api/samples/ranges | samples/data-operations-samples.md (merged) | OK |
| https://developers.google.com/sheets/api/samples/sheet | samples/row-column-sheet-samples.md (merged) | OK |
| https://developers.google.com/sheets/api/guides | FAILED | 404 Not Found |

## Quickstart

| URL | Output File | Status |
|---|---|---|
| https://developers.google.com/sheets/api/quickstart/python | overview/authentication.md (merged) | OK |

---

## Notes on Failures

- `https://developers.google.com/sheets/api/reference/query-parameters` — Returns generic redirect to system parameters. Content: query parameters are documented at the Google Cloud system parameters page, not specific to Sheets API.
- `https://developers.google.com/sheets/api/guides` — 404. Discovery was performed by fetching the concepts page which contained all guide links.
