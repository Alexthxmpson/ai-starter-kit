---
source: https://developers.google.com/workspace/docs/api/how-tos/named-ranges
scraped: 2026-03-01
api: google-docs-api
---

# Guide: Work with Named Ranges

## Core Concept

Named ranges allow developers to identify and reference specific document sections that automatically update their indexes as content is added or removed, eliminating the need to manually track editing changes.

**Key benefit:** "The indexes of the named range are automatically updated as content is added to and removed from the document."

## Use Cases

- Replace specific content by name without searching the document
- Template systems with named placeholders
- Programmatic content injection at known locations
- Multi-location simultaneous updates

## Implementation Pattern

1. **Fetch the document** with `includeTabsContent=true`
2. **Retrieve named ranges** from the first tab's DocumentTab
3. **Sort ranges by startIndex** in descending order (to avoid index shifting)
4. **Execute batch operations:**
   - Delete existing range content via `DeleteContentRangeRequest`
   - Insert replacement text using `InsertTextRequest` with Location (segmentId, index, tabId)
   - Recreate the named range with `CreateNamedRangeRequest` covering the new text
5. **Apply changes** via `batchUpdate` with `WriteControl.requiredRevisionId`

## Create a Named Range

```json
{
  "createNamedRange": {
    "name": "customer-name",
    "range": {
      "startIndex": 10,
      "endIndex": 25,
      "tabId": "TAB_ID"
    }
  }
}
```

The response includes the `namedRangeId` for future reference.

## Read Named Ranges

```python
document = service.documents().get(
    documentId=DOCUMENT_ID,
    includeTabsContent=True
).execute()

# Access named ranges from the first tab
first_tab = document.get('tabs', [{}])[0]
doc_tab = first_tab.get('documentTab', {})
named_ranges = doc_tab.get('namedRanges', {})

# named_ranges is a dict keyed by name, each containing a list of ranges
for name, named_range_obj in named_ranges.items():
    for named_range in named_range_obj.get('namedRanges', []):
        range_id = named_range['namedRangeId']
        for range_item in named_range.get('ranges', []):
            start = range_item['startIndex']
            end = range_item['endIndex']
            print(f"Range '{name}': {start}-{end}")
```

## Update Content in Named Range

```python
def replace_named_range(service, doc_id, range_name, new_text):
    # Get current document state
    document = service.documents().get(
        documentId=doc_id,
        includeTabsContent=True
    ).execute()
    revision_id = document['revisionId']

    # Find all instances of the named range
    named_ranges = (document.get('tabs', [{}])[0]
                   .get('documentTab', {})
                   .get('namedRanges', {}))

    target_ranges = named_ranges.get(range_name, {}).get('namedRanges', [])

    requests = []
    # Process in reverse order to avoid index shifting
    all_ranges = []
    for nr in target_ranges:
        range_id = nr['namedRangeId']
        tab_id = document['tabs'][0]['tabProperties']['tabId']
        for r in nr.get('ranges', []):
            all_ranges.append((r['startIndex'], r['endIndex'], range_id, tab_id))

    all_ranges.sort(key=lambda x: x[0], reverse=True)

    for start, end, range_id, tab_id in all_ranges:
        # Delete existing content
        requests.append({
            'deleteContentRange': {
                'range': {
                    'startIndex': start,
                    'endIndex': end,
                    'tabId': tab_id
                }
            }
        })
        # Insert new content
        requests.append({
            'insertText': {
                'location': {
                    'index': start,
                    'tabId': tab_id
                },
                'text': new_text
            }
        })
        # Recreate named range
        requests.append({
            'createNamedRange': {
                'name': range_name,
                'range': {
                    'startIndex': start,
                    'endIndex': start + len(new_text),
                    'tabId': tab_id
                }
            }
        })

    service.documents().batchUpdate(
        documentId=doc_id,
        body={
            'requests': requests,
            'writeControl': {'requiredRevisionId': revision_id}
        }
    ).execute()
```

## Delete a Named Range

```json
{
  "deleteNamedRange": {
    "namedRangeId": "range-id-here"
  }
}
```

Or delete by name (removes all ranges with that name):

```json
{
  "deleteNamedRange": {
    "name": "customer-name"
  }
}
```

## Replace Named Range Content

Use `ReplaceNamedRangeContentRequest` for a simpler approach when you just need to replace text:

```json
{
  "replaceNamedRangeContent": {
    "namedRangeName": "customer-name",
    "text": "New Customer Name"
  }
}
```

## Important Constraints

- **Visibility**: Named ranges are not private; all API users can access range definitions
- **Scope**: Ranges specify content location but don't become part of duplicated content if copy-pasted elsewhere
- **UTF-16 Encoding**: Text length calculations must account for UTF-16 code units
- **Multiple ranges**: Multiple ranges can share the same name; each has a unique `namedRangeId`
- **Write control**: Use `requiredRevisionId` to prevent overwriting concurrent changes
