---
source: https://developers.google.com/workspace/docs/api/how-tos/tabs
scraped: 2026-03-01
api: google-docs-api
---

# Guide: Work with Tabs

## Overview

"Google Docs features an organizational layer called tabs." Each tab has its own title and ID, and can contain child tabs nested beneath it.

## Structural Changes (Legacy vs. New)

The Document resource previously contained all text content directly. With tabs, content is organized in a new structure.

### Old Structure (direct fields on Document):
- `document.body`
- `document.headers`
- `document.footers`
- `document.footnotes`
- `document.documentStyle`
- `document.lists`
- `document.namedRanges`
- `document.inlineObjects`
- `document.positionedObjects`

### New Structure (within tabs):
Text content is now accessed via `document.tabs[]`, where each `Tab` object contains a `documentTab` field with the same content fields.

## Key API Changes

### documents.get()

| Parameter | Behavior |
|-----------|----------|
| `includeTabsContent=true` | Returns all tab contents in `document.tabs`; legacy fields left empty |
| omitted / `false` | Returns only first tab content in legacy fields; `document.tabs` is empty |

### documents.create()
Returns Document with content populated in both legacy fields and `document.tabs`.

### documents.batchUpdate()
Each Request can specify a target tab. Default behavior:
- Most requests apply to first tab if not specified
- `ReplaceAllTextRequest`, `DeleteNamedRangeRequest`, `ReplaceNamedRangeContentRequest` apply to all tabs by default

## Tab Access Pattern

```python
# Get document with all tabs
document = service.documents().get(
    documentId=DOCUMENT_ID,
    includeTabsContent=True
).execute()

# Access tabs
tabs = document.get('tabs', [])
for tab in tabs:
    tab_props = tab.get('tabProperties', {})
    tab_id = tab_props.get('tabId')
    tab_title = tab_props.get('title')

    # Access content
    doc_tab = tab.get('documentTab', {})
    body = doc_tab.get('body', {})

    # Access nested child tabs
    child_tabs = tab.get('childTabs', [])

    print(f"Tab: {tab_title} (ID: {tab_id})")

# Deep nested access example:
deep_body = document['tabs'][2]['childTabs'][0]['childTabs'][1]['documentTab']['body']
```

## Tab Properties

```json
{
  "tabProperties": {
    "tabId": "abc123",
    "title": "My Tab",
    "parentTabId": "parent-tab-id",
    "index": 0
  }
}
```

## Add a New Tab

```json
{
  "addDocumentTab": {
    "tab": {
      "tabProperties": {
        "title": "New Tab"
      }
    },
    "insertionIndex": 1
  }
}
```

## Delete a Tab

```json
{
  "deleteTab": {
    "tabId": "tab-id-to-delete"
  }
}
```

## Update Tab Properties

```json
{
  "updateDocumentTabProperties": {
    "tabId": "tab-id",
    "tabProperties": {
      "title": "Updated Title"
    },
    "fields": "title"
  }
}
```

## Internal Links with Tabs

- Updated fields: `link.bookmark` and `link.heading` (instead of legacy `bookmarkId`/`headingId`)
- New field: `link.tabId` for tab-specific links
- Behavior depends on `includeTabsContent` parameter in get requests

```json
{
  "link": {
    "tabId": "abc123",
    "heading": {
      "id": "heading-id",
      "tabId": "abc123"
    }
  }
}
```

## Specifying Tab in batchUpdate Requests

Most requests accept a `tabId` in their location or range:

```json
{
  "insertText": {
    "location": {
      "index": 1,
      "tabId": "specific-tab-id"
    },
    "text": "Hello"
  }
}
```

```json
{
  "updateTextStyle": {
    "range": {
      "startIndex": 1,
      "endIndex": 5,
      "tabId": "specific-tab-id"
    },
    "textStyle": { "bold": true },
    "fields": "bold"
  }
}
```

## Migration Notes

For backwards compatibility:
- Applications not using `includeTabsContent=true` continue to work with legacy fields
- Only first tab content appears in legacy fields
- New apps should use `includeTabsContent=true` and access content through `document.tabs`
