---
source: https://developers.google.com/workspace/docs/api/how-tos/move-text
scraped: 2026-03-01
api: google-docs-api
---

# Guide: Insert, Delete, and Move Text

## Overview

The Google Docs API enables programmatic text manipulation through the `documents.batchUpdate` method, supporting insertion, deletion, and repositioning of content across document segments.

## Insert Text

**Method:** `documents.batchUpdate` with `InsertTextRequest`

**Key Parameters:**
- `text`: The string to insert
- `location`: Specifies insertion point via index and optional tabId

**Important Note:** "Indexes are measured in UTF-16 code units."

**Index Adjustment Behavior:**
Each insertion shifts all higher-numbered indexes by the inserted text's character count. The documentation recommends a workaround: "order your insertions to 'write backwards': do the insertion at the highest-numbered index first."

### Java Example

```java
requests.add(new Request().setInsertText(new InsertTextRequest()
        .setText(text1)
        .setLocation(new Location().setIndex(25).setTabId(TAB_ID))));
```

### Python Example

```python
requests = [{
    'insertText': {
        'location': {'index': 25, 'tabId': TAB_ID},
        'text': text1
    }
}]
result = service.documents().batchUpdate(
    documentId=DOCUMENT_ID, body={'requests': requests}).execute()
```

### PHP Example

```php
$requests[] = new Google_Service_Docs_Request(array(
    'insertText' => array(
        'text' => $text1,
        'location' => array('index' => 25, 'tabId' => TAB_ID)
    )
));
```

## Delete Text

**Method:** `documents.batchUpdate` with `DeleteContentRangeRequest`

**Required Structure:**
- `Range` object specifying `startIndex` and `endIndex`
- Optional `tabId` for specific document tab

### Java Example

```java
requests.add(new Request().setDeleteContentRange(
        new DeleteContentRangeRequest()
                .setRange(new Range()
                        .setStartIndex(10)
                        .setEndIndex(24)
                        .setTabId(TAB_ID))));
```

### Python Example

```python
requests = [{
    'deleteContentRange': {
        'range': {
            'startIndex': 10,
            'endIndex': 24,
            'tabId': TAB_ID
        }
    }
}]
```

## Move Text

Moving text requires a two-step process:
1. Retrieve content via `get` request
2. Delete from source and insert at destination

**Note:** Clipboard functionality is unavailable through the API. You must read the content first, then perform delete + insert.

## Key Rules

- All indexes are UTF-16 code unit positions
- When batching multiple insertions, order from highest index to lowest to avoid index shifting issues
- The `\n` character counts as 1 UTF-16 code unit
- Non-BMP characters (emoji, some CJK) count as 2 UTF-16 code units
