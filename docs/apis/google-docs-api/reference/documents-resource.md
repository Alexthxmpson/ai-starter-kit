---
source: https://developers.google.com/workspace/docs/api/reference/rest/v1/documents
scraped: 2026-03-01
api: google-docs-api
---

# Google Docs REST API — Documents Resource Reference

## Service Information

- **Base URL:** `https://docs.googleapis.com`
- **Discovery Document:** `https://docs.googleapis.com/$discovery/rest?version=v1`

## Core Resource Structures

### Document

The primary resource representing a Google Docs document:

| Field | Type | Description |
|-------|------|-------------|
| `documentId` | string (output only) | Unique identifier |
| `title` | string | Document name |
| `tabs` | Tab[] | Tab objects containing document content |
| `revisionId` | string (output only) | Current revision identifier (valid 24 hours) |
| `suggestionsViewMode` | enum | Suggestions display mode |
| `body` | Body | Main document content (legacy field) |
| `headers` | map | Header objects keyed by ID |
| `footers` | map | Footer objects keyed by ID |
| `footnotes` | map | Footnote objects keyed by ID |
| `documentStyle` | DocumentStyle | Document-level styling |
| `namedStyles` | NamedStyles | Named style definitions |
| `lists` | map | List objects by ID |
| `namedRanges` | map | Named ranges by name |
| `inlineObjects` | map | Inline objects keyed by ID |
| `positionedObjects` | map | Positioned objects keyed by ID |

### Tab

Represents a document tab:

| Field | Type | Description |
|-------|------|-------------|
| `tabProperties` | TabProperties | ID, title, parent reference |
| `childTabs` | Tab[] | Nested tab objects |
| `documentTab` | DocumentTab | Content container |

Tab hierarchy example: `document.tabs[2].childTabs[0].childTabs[1].documentTab.body`

### DocumentTab

Contains tab-specific content mirroring Document structure: body, headers, footers, footnotes, styles, lists, objects.

### Body

Contains `content` array of StructuralElement objects representing document structure.

### StructuralElement

Union type with `startIndex` and `endIndex` (UTF-16 offsets):

| Type | Description |
|------|-------------|
| `paragraph` | Paragraph element |
| `sectionBreak` | Section break |
| `table` | Table element |
| `tableOfContents` | Table of contents |

### Paragraph

Document text unit:

| Field | Type | Description |
|-------|------|-------------|
| `elements` | ParagraphElement[] | Array of paragraph elements |
| `paragraphStyle` | ParagraphStyle | Formatting |
| `bullet` | Bullet | List information |
| `positionedObjectIds` | string[] | Tethered objects |

### ParagraphElement

Union type with `startIndex`, `endIndex`:

| Type | Description |
|------|-------------|
| `textRun` | Text run with uniform styling |
| `autoText` | Auto-generated text (page numbers, etc.) |
| `pageBreak` | Page break |
| `columnBreak` | Column break |
| `footnoteReference` | Footnote reference |
| `horizontalRule` | Horizontal rule |
| `equation` | Equation |
| `inlineObjectElement` | Inline object (image, etc.) |
| `person` | Person reference |
| `richLink` | Rich link |

## Text Styling

### TextStyle

Inherited styling object:

| Field | Type | Description |
|-------|------|-------------|
| `bold` | boolean | Bold formatting |
| `italic` | boolean | Italic formatting |
| `underline` | boolean | Underline formatting |
| `strikethrough` | boolean | Strikethrough formatting |
| `smallCaps` | boolean | Small caps formatting |
| `backgroundColor` | OptionalColor | Background color |
| `foregroundColor` | OptionalColor | Text color |
| `fontSize` | Dimension | Font size |
| `weightedFontFamily` | WeightedFontFamily | Font family and weight |
| `baselineOffset` | enum | NONE, SUPERSCRIPT, SUBSCRIPT |
| `link` | Link | Hyperlink |

### TextRun

Represents uniformly styled text:

| Field | Type | Description |
|-------|------|-------------|
| `content` | string | Text content (non-text elements replaced with U+E907) |
| `suggestedInsertionIds` | string[] | Suggestion IDs for insertions |
| `suggestedDeletionIds` | string[] | Suggestion IDs for deletions |
| `textStyle` | TextStyle | Applied text style |
| `suggestedTextStyleChanges` | map | Suggested style changes |

### OptionalColor / Color / RgbColor

Color representation:
- `OptionalColor` contains optional `Color`
- `Color` contains `RgbColor`
- `RgbColor`: `red`, `green`, `blue` (numbers 0.0-1.0)

### Dimension

Magnitude with unit:

| Field | Type | Description |
|-------|------|-------------|
| `magnitude` | number | Numeric value |
| `unit` | enum | Measurement unit: `PT` for points |

### WeightedFontFamily

| Field | Type | Description |
|-------|------|-------------|
| `fontFamily` | string | Font name |
| `weight` | integer | 100-900 (multiples of 100) |

## Paragraph Formatting

### ParagraphStyle

| Field | Type | Description |
|-------|------|-------------|
| `headingId` | string (read-only) | Heading ID |
| `namedStyleType` | NamedStyleType enum | Named style type |
| `alignment` | Alignment enum | START, CENTER, END, JUSTIFIED |
| `lineSpacing` | number | Line spacing percentage |
| `direction` | ContentDirection | LEFT_TO_RIGHT, RIGHT_TO_LEFT |
| `spacingMode` | SpacingMode | NEVER_COLLAPSE, COLLAPSE_LISTS |
| `spaceAbove` | Dimension | Space above paragraph |
| `spaceBelow` | Dimension | Space below paragraph |
| `borderBetween` | ParagraphBorder | Border between paragraphs |
| `borderTop` | ParagraphBorder | Top border |
| `borderBottom` | ParagraphBorder | Bottom border |
| `borderLeft` | ParagraphBorder | Left border |
| `borderRight` | ParagraphBorder | Right border |
| `indentFirstLine` | Dimension | First line indent |
| `indentStart` | Dimension | Start indent |
| `indentEnd` | Dimension | End indent |
| `tabStops` | TabStop[] | Tab stop positions |
| `keepLinesTogether` | boolean | Keep paragraph lines together |
| `keepWithNext` | boolean | Keep with next paragraph |
| `avoidWidowAndOrphan` | boolean | Avoid widow/orphan lines |
| `shading` | Shading | Paragraph shading |
| `pageBreakBefore` | boolean | Page break before paragraph |

### ParagraphBorder

| Field | Type | Description |
|-------|------|-------------|
| `color` | OptionalColor | Border color |
| `width` | Dimension | Border width |
| `padding` | Dimension | Border padding |
| `dashStyle` | DashStyle enum | SOLID, DOT, DASH |

### TabStop

| Field | Type | Description |
|-------|------|-------------|
| `offset` | Dimension | Tab stop position |
| `alignment` | TabStopAlignment | START, CENTER, END |

## Named Styles

### NamedStyles
Container for `styles` array of NamedStyle objects.

### NamedStyle

| Field | Type | Description |
|-------|------|-------------|
| `type` | NamedStyleType | Style type |
| `textStyle` | TextStyle | Text formatting |
| `paragraphStyle` | ParagraphStyle | Paragraph formatting |

### NamedStyleType Enum
NORMAL_TEXT, TITLE, SUBTITLE, HEADING_1, HEADING_2, HEADING_3, HEADING_4, HEADING_5, HEADING_6

## Lists

### List
- `listProperties` (ListProperties)

### ListProperties
- `nestingLevels` (NestingLevel[])

### NestingLevel

| Field | Type | Description |
|-------|------|-------------|
| `bulletAlignment` | BulletAlignment | Bullet alignment |
| `glyphType` | GlyphType | Bullet marker type |
| `glyphSymbol` | string | Custom bullet symbol |
| `glyphFormat` | string | Glyph format string |
| `startNumber` | integer | Starting number |
| `textStyle` | TextStyle | Bullet text style |

### Bullet

| Field | Type | Description |
|-------|------|-------------|
| `listId` | string | List identifier |
| `nestingLevel` | integer | Nesting level |

## Tables

### Table

| Field | Type | Description |
|-------|------|-------------|
| `rows` | TableRow[] | Table rows |
| `tableStyle` | TableStyle | Table styling |
| `columnProperties` | TableColumnProperties[] | Column properties |
| `suggestedTableStyleChanges` | map | Suggested style changes |

### TableRow

| Field | Type | Description |
|-------|------|-------------|
| `content` | TableCell[] | Row cells |
| `tableRowStyle` | TableRowStyle | Row styling |
| `suggestedTableRowStyleChanges` | map | Suggested changes |

### TableCell

| Field | Type | Description |
|-------|------|-------------|
| `content` | StructuralElement[] | Cell content |
| `tableCellStyle` | TableCellStyle | Cell styling |
| `suggestedTableCellStyleChanges` | map | Suggested changes |

### TableCellStyle

| Field | Type | Description |
|-------|------|-------------|
| `rowSpan` | integer | Rows spanned |
| `columnSpan` | integer | Columns spanned |
| `backgroundColor` | OptionalColor | Cell background |
| `borders` | four TableCellBorder | Cell borders |
| `paddingTop/Bottom/Left/Right` | Dimension | Cell padding |
| `contentAlignment` | ContentAlignment enum | Vertical alignment |
| `inheritedCellStyle` | TableCellStyle | Inherited style |

### TableColumnProperties

| Field | Type | Description |
|-------|------|-------------|
| `widthType` | WidthType | EVENLY_DISTRIBUTED, FIXED_WIDTH |
| `width` | Dimension | Column width |

### TableStyle

| Field | Type | Description |
|-------|------|-------------|
| `tableHeadingStyle` | TextStyle | Heading row style |
| `firstRowHeaderId` | string | First header row ID |
| `firstColumnHeaderId` | string | First header column ID |

## Headers, Footers, Footnotes

### Header / Footer

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Header/footer identifier |
| `content` | StructuralElement[] | Content elements |

### Footnote

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Footnote identifier |
| `content` | StructuralElement[] | Footnote content |

### FootnoteReference

| Field | Type | Description |
|-------|------|-------------|
| `footnoteId` | string | Referenced footnote ID |
| `footnoteNumber` | string | Display number |

## Inline and Positioned Objects

### InlineObject

| Field | Type | Description |
|-------|------|-------------|
| `objectId` | string | Object identifier |
| `inlineObjectProperties` | InlineObjectProperties | Object properties |

### InlineObjectProperties
- `embeddedObject` (EmbeddedObject)

### EmbeddedObject

| Field | Type | Description |
|-------|------|-------------|
| `mimeType` | string | MIME type |
| `description` | string | Alt text description |
| `title` | string | Object title |
| `linkedContentReference` | LinkedContentReference | Linked content |
| `imageProperties` | ImageProperties | Image properties |
| `embeddedDrawingProperties` | EmbeddedDrawingProperties | Drawing properties |

### ImageProperties

| Field | Type | Description |
|-------|------|-------------|
| `contentUri` | string | Image content URI |
| `width` | Dimension | Image width |
| `height` | Dimension | Image height |
| `cropProperties` | CropProperties | Crop settings |
| `brightness` | number | Brightness adjustment |
| `contrast` | number | Contrast adjustment |
| `transparency` | number | Transparency level |
| `angle` | number | Rotation angle |

### CropProperties

| Field | Type | Description |
|-------|------|-------------|
| `offsetLeft` | Dimension | Left crop offset |
| `offsetTop` | Dimension | Top crop offset |
| `offsetBottom` | Dimension | Bottom crop offset |
| `offsetRight` | Dimension | Right crop offset |

### PositionedObject

| Field | Type | Description |
|-------|------|-------------|
| `objectId` | string | Object identifier |
| `positionedObjectProperties` | PositionedObjectProperties | Object properties |

### PositionedObjectPositioning

| Field | Type | Description |
|-------|------|-------------|
| `layout` | PositionedObjectLayout enum | Layout mode |
| `leftOffset` | Dimension | Left position offset |
| `topOffset` | Dimension | Top position offset |

## Named Ranges

### NamedRanges

| Field | Type | Description |
|-------|------|-------------|
| `namedRanges` | NamedRange[] | Named range objects |

### NamedRange

| Field | Type | Description |
|-------|------|-------------|
| `namedRangeId` | string | Unique range identifier |
| `name` | string | Range name |
| `ranges` | Range[] | Range positions |

### Range

| Field | Type | Description |
|-------|------|-------------|
| `startIndex` | integer | Start position (UTF-16) |
| `endIndex` | integer | End position (UTF-16) |
| `tabId` | string | Tab identifier |

## Document Style

### DocumentStyle

| Field | Type | Description |
|-------|------|-------------|
| `defaultHeaderId` | string | Default header ID |
| `defaultFooterId` | string | Default footer ID |
| `evenPageHeaderId` | string | Even page header ID |
| `evenPageFooterId` | string | Even page footer ID |
| `firstPageHeaderId` | string | First page header ID |
| `firstPageFooterId` | string | First page footer ID |
| `marginTop/Bottom/Left/Right` | Dimension | Page margins |
| `pageSize` | Size | Page dimensions |
| `pageNumberStart` | integer | Starting page number |
| `background` | Background | Page background |
| `documentFormat` | DocumentFormat | Document format |

### Size

| Field | Type | Description |
|-------|------|-------------|
| `width` | Dimension | Page width |
| `height` | Dimension | Page height |

## Links

### Link (Union type)

| Field | Type | Description |
|-------|------|-------------|
| `url` | string | External URL |
| `tabId` | string | Tab reference |
| `bookmark` | BookmarkLink | Bookmark reference |
| `heading` | HeadingLink | Heading reference |
| `bookmarkId` | string (legacy) | Legacy bookmark ID |
| `headingId` | string (legacy) | Legacy heading ID |

### BookmarkLink

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Bookmark identifier |
| `tabId` | string | Containing tab ID |

## AutoText and Breaks

### AutoText

| Field | Type | Description |
|-------|------|-------------|
| `type` | Type enum | PAGE_NUMBER, PAGE_COUNT |
| `textStyle` | TextStyle | Text styling |

## Enumerations

| Enum | Values |
|------|--------|
| BaselineOffset | BASELINE_OFFSET_UNSPECIFIED, NONE, SUPERSCRIPT, SUBSCRIPT |
| Alignment | ALIGNMENT_UNSPECIFIED, START, CENTER, END, JUSTIFIED |
| ContentDirection | CONTENT_DIRECTION_UNSPECIFIED, LEFT_TO_RIGHT, RIGHT_TO_LEFT |
| SpacingMode | SPACING_MODE_UNSPECIFIED, NEVER_COLLAPSE, COLLAPSE_LISTS |
| DashStyle | DASH_STYLE_UNSPECIFIED, SOLID, DOT, DASH |
| TabStopAlignment | TAB_STOP_ALIGNMENT_UNSPECIFIED, START, CENTER, END |
| WidthType | EVENLY_DISTRIBUTED, FIXED_WIDTH |
| ColumnSeparatorStyle | NONE, BETWEEN_EACH_COLUMN |
| SuggestionsViewMode | SUGGESTIONS_INLINE, PREVIEW_WITH_SUGGESTIONS_ACCEPTED, PREVIEW_WITHOUT_SUGGESTIONS, DEFAULT_FOR_CURRENT_ACCESS |

## SectionBreak

### SectionStyle

| Field | Type | Description |
|-------|------|-------------|
| `columnProperties` | SectionColumnProperties | Column layout |
| `defaultHeaderId` | string | Default header ID |
| `defaultFooterId` | string | Default footer ID |
| `evenPageHeaderId` | string | Even page header ID |
| `firstPageHeaderId` | string | First page header ID |

### SectionColumnProperties

| Field | Type | Description |
|-------|------|-------------|
| `columnSeparatorStyle` | ColumnSeparatorStyle | NONE, BETWEEN_EACH_COLUMN |
| `numColumns` | integer | Number of columns |

## Suggestion Tracking

### TextStyleSuggestionState
Boolean mask indicating changed fields: boldSuggested, italicSuggested, underlineSuggested, strikethroughSuggested, smallCapsSuggested, backgroundColorSuggested, foregroundColorSuggested, fontSizeSuggested, weightedFontFamilySuggested, baselineOffsetSuggested, linkSuggested

### SuggestedTextStyle
- `textStyle` (TextStyle)
- `textStyleSuggestionState` (TextStyleSuggestionState)

### SuggestedParagraphStyle
- `paragraphStyle` (ParagraphStyle)
- `paragraphStyleSuggestionState` (ParagraphStyleSuggestionState)
