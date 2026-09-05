---
source: https://developers.google.com/workspace/docs/api/how-tos/tables
scraped: 2026-03-01
api: google-docs-api
---

# Guide: Work with Tables

## Core Operations

The Google Docs API enables:
- Insert/delete rows, columns, or entire tables
- Insert and read content from table cells
- Modify column properties and row styling

## Data Structure

Tables are represented as `StructuralElement` objects containing:
- `table` with `columns` and `rows` properties
- `tableRows` array (each containing `tableCells`)
- Each cell has a `content` array of structural elements

## Insert Table

**Request:** `InsertTableRequest`

Specify dimensions and location (index or end-of-segment).

```json
{
  "insertTable": {
    "rows": 3,
    "columns": 4,
    "location": {
      "index": 1,
      "tabId": "TAB_ID"
    }
  }
}
```

## Table Row Operations

**InsertTableRowRequest**: Add rows above/below specified cells using `TableCellLocation`

```json
{
  "insertTableRow": {
    "tableCellLocation": {
      "tableStartLocation": { "index": 2, "tabId": "TAB_ID" },
      "rowIndex": 1,
      "columnIndex": 0
    },
    "insertBelow": true
  }
}
```

**InsertTableColumnRequest**: Insert columns left/right of target cells

**DeleteTableRowRequest**: Remove a table row

**DeleteTableColumnRequest**: Remove columns by cell reference

## Column Properties

**UpdateTableColumnPropertiesRequest**: Modify column widths and types

```json
{
  "updateTableColumnProperties": {
    "tableStartLocation": { "index": 2, "tabId": "TAB_ID" },
    "columnIndices": [0],
    "tableColumnProperties": {
      "widthType": "FIXED_WIDTH",
      "width": { "magnitude": 100.0, "unit": "PT" }
    },
    "fields": "widthType,width"
  }
}
```

**Width types:**
- `EVENLY_DISTRIBUTED`: Column shares available space
- `FIXED_WIDTH`: Column has specific width in points

## Row Styling

**UpdateTableRowStyleRequest**: Adjust row properties like minimum height

```json
{
  "updateTableRowStyle": {
    "tableStartLocation": { "index": 2, "tabId": "TAB_ID" },
    "rowIndices": [0],
    "tableRowStyle": {
      "minRowHeight": { "magnitude": 20.0, "unit": "PT" }
    },
    "fields": "minRowHeight"
  }
}
```

## Cell Style

**UpdateTableCellStyleRequest**: Format individual cells

Supports:
- `backgroundColor`: Cell background color
- `borderLeft/Right/Top/Bottom`: Cell borders (with color, width, dashStyle)
- `paddingLeft/Right/Top/Bottom`: Cell padding
- `contentAlignment`: TOP, MIDDLE, BOTTOM
- `rowSpan`, `columnSpan`: Cell spanning

## Cell Content Operations

**Reading:** Recursively inspect structural elements within cells

**Writing:** Use `InsertTextRequest` with the specific cell index

**Deleting:** Apply `DeleteContentRangeRequest` with start/end indexes

## Merge/Unmerge Cells

**MergeTableCellsRequest**: Combine adjacent cells

```json
{
  "mergeTableCells": {
    "tableRange": {
      "tableCellLocation": {
        "tableStartLocation": { "index": 2 },
        "rowIndex": 0,
        "columnIndex": 0
      },
      "rowSpan": 1,
      "columnSpan": 2
    }
  }
}
```

**UnmergeTableCellsRequest**: Split previously merged cells

## Pin Header Rows

**PinTableHeaderRowsRequest**: Lock header rows during scrolling

```json
{
  "pinTableHeaderRows": {
    "tableStartLocation": { "index": 2 },
    "pinnedHeaderRowsCount": 1
  }
}
```

## Implementation Pattern

Requests batch together in `BatchUpdateDocumentRequest`, requiring document ID and tab ID specifications for location targeting.

## Reading Table Content

To read content from a specific cell, access via the document structure:

```python
# Python pseudo-code for reading table cell content
document = service.documents().get(documentId=DOC_ID, includeTabsContent=True).execute()
tabs = document.get('tabs', [])
for tab in tabs:
    body = tab.get('documentTab', {}).get('body', {})
    for element in body.get('content', []):
        if 'table' in element:
            table = element['table']
            for row in table.get('tableRows', []):
                for cell in row.get('tableCells', []):
                    # Process cell content
                    for cell_element in cell.get('content', []):
                        if 'paragraph' in cell_element:
                            for para_element in cell_element['paragraph'].get('elements', []):
                                if 'textRun' in para_element:
                                    print(para_element['textRun']['content'])
```
