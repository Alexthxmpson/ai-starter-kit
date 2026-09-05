---
source: https://developers.google.com/workspace/docs/api/how-tos/format-text
scraped: 2026-03-01
api: google-docs-api
---

# Guide: Format Text

## Overview

The Google Docs API enables two distinct formatting approaches:
- **Character formatting**: Font, color, underlining applied to individual text characters
- **Paragraph formatting**: Indentation, line spacing, alignment applied to text blocks

## Character Formatting

### Implementation Method
Use `batchUpdate` with `UpdateTextStyleRequest`, requiring:
- A `Range` object specifying `segmentId`, `startIndex`, `endIndex`, and `tabId`

### Supported Properties

| Property | Type | Description |
|----------|------|-------------|
| `bold` | boolean | Bold text |
| `italic` | boolean | Italic text |
| `underline` | boolean | Underlined text |
| `strikethrough` | boolean | Strikethrough text |
| `smallCaps` | boolean | Small caps |
| `weightedFontFamily` | WeightedFontFamily | Font family and weight |
| `fontSize` | Dimension | Font size in PT |
| `foregroundColor` | OptionalColor | Text color (RGB 0.0-1.0) |
| `backgroundColor` | OptionalColor | Background highlight color |
| `link` | Link | Hyperlink URL |
| `baselineOffset` | enum | SUPERSCRIPT or SUBSCRIPT |

### Java Example

```java
requests.add(new Request().setUpdateTextStyle(new UpdateTextStyleRequest()
    .setTextStyle(new TextStyle()
        .setBold(true)
        .setItalic(true))
    .setRange(new Range()
        .setStartIndex(1)
        .setEndIndex(5)
        .setTabId(TAB_ID))
    .setFields("bold")));
```

### Python Example

```python
{
    'updateTextStyle': {
        'range': {
            'startIndex': 1,
            'endIndex': 5,
            'tabId': 'TAB_ID'
        },
        'textStyle': {
            'bold': True,
            'italic': True,
            'foregroundColor': {
                'color': {
                    'rgbColor': {
                        'red': 1.0,
                        'green': 0.0,
                        'blue': 0.0
                    }
                }
            },
            'fontSize': {
                'magnitude': 14,
                'unit': 'PT'
            }
        },
        'fields': 'bold,italic,foregroundColor,fontSize'
    }
}
```

## Paragraph Formatting

### Implementation Method
Use `UpdateParagraphStyleRequest` with range specifications matching character formatting structure.

### Supported Properties

| Property | Type | Description |
|----------|------|-------------|
| `namedStyleType` | enum | "HEADING_1", "HEADING_2", ... "NORMAL_TEXT", "TITLE" |
| `spaceAbove` | Dimension | Space above paragraph |
| `spaceBelow` | Dimension | Space below paragraph |
| `lineSpacing` | number | Line spacing percentage |
| `alignment` | enum | START, CENTER, END, JUSTIFIED |
| `indentFirstLine` | Dimension | First line indent |
| `indentStart` | Dimension | Left indent |
| `indentEnd` | Dimension | Right indent |
| `borderLeft` | ParagraphBorder | Left border |
| `borderRight` | ParagraphBorder | Right border |
| `borderTop` | ParagraphBorder | Top border |
| `borderBottom` | ParagraphBorder | Bottom border |
| `keepLinesTogether` | boolean | Keep paragraph on one page |
| `keepWithNext` | boolean | Keep with following paragraph |

### Border Configuration

```java
.setBorderLeft(new ParagraphBorder()
    .setColor(new OptionalColor()...)
    .setDashStyle("DASH")
    .setPadding(new Dimension()...)
    .setWidth(new Dimension()...))
```

## Key Concepts

**Style Inheritance**: Applied formatting overrides defaults from paragraph `TextStyle`. Unset properties inherit from underlying styles.

**Batch Operations**: Combine multiple formatting requests in single `batchUpdate` call for efficiency.

**Field Specification**: Always include the `fields` parameter listing modified properties (e.g., `"bold,italic"`, `"borderLeft"`). This prevents unintended clearing of other properties.

**Wildcard Warning**: Using `*` as the field mask selects all fields but is discouraged for production because:
- It may cause errors with read-only fields
- Newly added fields in future API updates may break your implementation
