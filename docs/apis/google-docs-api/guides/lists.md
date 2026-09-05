---
source: https://developers.google.com/workspace/docs/api/how-tos/lists
scraped: 2026-03-01
api: google-docs-api
---

# Guide: Work with Lists

## Overview

The Google Docs API enables programmatic list creation and manipulation through batch request operations. Three primary operations are supported:
1. Creating numbered lists
2. Converting paragraphs to lists
3. Removing list formatting

## Creating Numbered Lists

**Process:**
1. Use `documents.create` to initialize a document
2. Use `documents.batchUpdate` with `InsertTextRequest` to add content (items separated by `\n`)
3. Include `CreateParagraphBulletsRequest` with a `Range` and `BulletGlyphPreset`

### Key Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `startIndex` | integer | Beginning of text range |
| `endIndex` | integer | End of text range |
| `tabId` | string | Tab identifier (optional; defaults to first tab) |
| `bulletPreset` | string | Formatting pattern specification |

### BulletGlyphPreset Options

| Preset | Description |
|--------|-------------|
| `NUMBERED_DECIMAL_ALPHA_ROMAN` | decimal → lowercase letter → lowercase Roman numeral |
| `NUMBERED_DECIMAL_ALPHA_ROMAN_PARENS` | decimal) → letter) → roman) |
| `NUMBERED_DECIMAL_NESTED` | Nested decimal like 1, 1.1, 1.1.1 |
| `BULLET_DISC_CIRCLE_SQUARE` | Disc → circle → square |
| `BULLET_DIAMONDX_ARROW3D_SQUARE` | Diamond → 3D arrow → square |
| `BULLET_CHECKBOX` | Checkbox bullets |
| `BULLET_ARROW_DIAMOND_DISC` | Arrow → diamond → disc |
| `BULLET_STAR_CIRCLE_SQUARE` | Star → circle → square |
| `BULLET_ARROW3D_CIRCLE_SQUARE` | 3D arrow → circle → square |
| `BULLET_LEFTTRIANGLE_DIAMOND_DISC` | Left triangle → diamond → disc |
| `BULLET_DIAMONDX_HOLLOWDIAMOND_SQUARE` | Diamond-X → hollow diamond → square |

### Python Example

```python
# Create a document and insert list items
create_result = service.documents().create(body={'title': 'My List Doc'}).execute()
document_id = create_result['documentId']

# Insert text items
requests = [
    {
        'insertText': {
            'location': {'index': 1},
            'text': 'Item 1\nItem 2\nItem 3\n'
        }
    }
]
service.documents().batchUpdate(
    documentId=document_id,
    body={'requests': requests}
).execute()

# Apply numbered list formatting
requests = [
    {
        'createParagraphBullets': {
            'range': {
                'startIndex': 1,
                'endIndex': 21  # End of all list items
            },
            'bulletPreset': 'NUMBERED_DECIMAL_ALPHA_ROMAN'
        }
    }
]
service.documents().batchUpdate(
    documentId=document_id,
    body={'requests': requests}
).execute()
```

## Converting Paragraphs to Lists

Use `CreateParagraphBulletsRequest` to transform existing text into bulleted lists.

"All paragraphs that overlap with the given range are bulleted."

**Important Limitation:** Nesting levels cannot be adjusted on existing bullets.

**Workaround for changing nesting:**
1. Delete bullet formatting (`DeleteParagraphBulletsRequest`)
2. Add leading tabs to desired items (`InsertTextRequest`)
3. Recreate bullet formatting (`CreateParagraphBulletsRequest`)

## Removing List Formatting

Use `DeleteParagraphBulletsRequest` with a `Range` specification.

The API "deletes all bullets that overlap with the given range, regardless of nesting level" and adds indentation to preserve visual nesting.

```json
{
  "deleteParagraphBullets": {
    "range": {
      "startIndex": 1,
      "endIndex": 25,
      "tabId": "TAB_ID"
    }
  }
}
```

## Java Example

```java
// Insert text
List<Request> requests = new ArrayList<>();
requests.add(new Request().setInsertText(new InsertTextRequest()
    .setLocation(new Location().setIndex(1))
    .setText("Item 1\nItem 2\nItem 3\n")));

// Apply bullets
requests.add(new Request().setCreateParagraphBullets(
    new CreateParagraphBulletsRequest()
        .setRange(new Range().setStartIndex(1).setEndIndex(21))
        .setBulletPreset("BULLET_ARROW_DIAMOND_DISC")));

docsService.documents().batchUpdate(DOCUMENT_ID,
    new BatchUpdateDocumentRequest().setRequests(requests)).execute();
```

## Key Notes

- List formatting applies to entire paragraphs, not partial text
- Nested list levels are determined by leading tabs or indentation
- The API does not directly support promoting/demoting list levels — use the tab workaround
