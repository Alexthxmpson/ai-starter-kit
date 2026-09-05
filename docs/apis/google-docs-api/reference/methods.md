---
source: https://developers.google.com/workspace/docs/api/reference/rest/v1/documents
scraped: 2026-03-01
api: google-docs-api
---

# Google Docs API — Methods Reference

## documents.get

**Endpoint:** `GET https://docs.googleapis.com/v1/documents/{documentId}`

Uses gRPC Transcoding syntax.

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `documentId` | string | Yes | The ID of the document to retrieve |

### Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `suggestionsViewMode` | enum (SuggestionsViewMode) | Controls how suggestions appear. Options: SUGGESTIONS_INLINE, PREVIEW_WITH_SUGGESTIONS_ACCEPTED, PREVIEW_WITHOUT_SUGGESTIONS, DEFAULT_FOR_CURRENT_ACCESS |
| `includeTabsContent` | boolean | If true, populates Document.tabs; if false, populates legacy body/documentStyle fields |

### Request Body
Must be empty.

### Response
Returns a `Document` object containing the latest version.

### Authorization Scopes (any one of):
- `https://www.googleapis.com/auth/documents`
- `https://www.googleapis.com/auth/documents.readonly`
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.readonly`
- `https://www.googleapis.com/auth/drive.file`

---

## documents.create

**Endpoint:** `POST https://docs.googleapis.com/v1/documents`

### Request Body

A Document object. Only `title` is used; other fields are ignored:

| Field | Type | Description |
|-------|------|-------------|
| `documentId` | string (output only) | Unique identifier |
| `title` | string | Document display name (used for creation) |
| `tabs[]` | Tab[] | Output only |
| `revisionId` | string (output only) | Opaque revision identifier |
| `suggestionsViewMode` | enum (output only) | Suggestion rendering mode |
| `body` | Body (output only) | Main document body |
| `headers` | map (output only) | Header objects |
| `footers` | map (output only) | Footer objects |
| `footnotes` | map (output only) | Footnote objects |
| `documentStyle` | DocumentStyle (output only) | Document styling |
| `namedStyles` | NamedStyles (output only) | Named styles |
| `lists` | map (output only) | List definitions |
| `namedRanges` | map (output only) | Named ranges |
| `inlineObjects` | map (output only) | Inline objects |
| `positionedObjects` | map (output only) | Positioned objects |

**Note:** "Other fields in the request, including any provided content, are ignored" during creation.

### Response
Returns a newly created `Document` object.

### Authorization Scopes (any one of):
- `https://www.googleapis.com/auth/documents`
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`

---

## documents.batchUpdate

**Endpoint:** `POST https://docs.googleapis.com/v1/documents/{documentId}:batchUpdate`

Applies one or more updates to the document atomically. All requests are validated before any are applied.

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `documentId` | string | Yes | The identifier of the document |

### Request Body Structure

```json
{
  "requests": [
    {
      object (Request)
    }
  ],
  "writeControl": {
    object (WriteControl)
  }
}
```

### Response Body

```json
{
  "documentId": string,
  "replies": [
    {
      object (Response)
    }
  ],
  "writeControl": {
    object (WriteControl)
  }
}
```

**Response Fields:**
- `documentId`: Identifier of the updated document
- `replies[]`: Response array corresponding 1:1 with requests; some may be empty
- `writeControl`: Updated write control post-execution

### WriteControl Configuration

```json
{
  "requiredRevisionId": string,
  "targetRevisionId": string
}
```

| Field | Purpose |
|-------|---------|
| `requiredRevisionId` | Enforces update against specific revision; fails if not current |
| `targetRevisionId` | Applies changes against specified revision, merging collaborator edits |

### Authorization Scopes (any one of):
- `https://www.googleapis.com/auth/documents`
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`

---

## All Request Types for batchUpdate

The `requests` array in `batchUpdate` accepts these 37 request types:

| # | Request Type | Description |
|---|-------------|-------------|
| 1 | `ReplaceAllTextRequest` | Replace all instances of text matching criteria |
| 2 | `InsertTextRequest` | Insert text at a specified location |
| 3 | `UpdateTextStyleRequest` | Modify formatting of existing text |
| 4 | `CreateParagraphBulletsRequest` | Add bullet formatting to paragraphs |
| 5 | `DeleteParagraphBulletsRequest` | Remove bullet formatting |
| 6 | `CreateNamedRangeRequest` | Define a named range in the document |
| 7 | `DeleteNamedRangeRequest` | Remove a named range |
| 8 | `UpdateParagraphStyleRequest` | Modify paragraph-level formatting |
| 9 | `DeleteContentRangeRequest` | Remove content between specified positions |
| 10 | `InsertInlineImageRequest` | Add an image inline with text |
| 11 | `InsertTableRequest` | Create a new table |
| 12 | `InsertTableRowRequest` | Add rows to existing tables |
| 13 | `InsertTableColumnRequest` | Add columns to existing tables |
| 14 | `DeleteTableRowRequest` | Remove table rows |
| 15 | `DeleteTableColumnRequest` | Remove table columns |
| 16 | `InsertPageBreakRequest` | Create a page break |
| 17 | `DeletePositionedObjectRequest` | Remove floating objects |
| 18 | `UpdateTableColumnPropertiesRequest` | Modify column formatting |
| 19 | `UpdateTableCellStyleRequest` | Format individual cells |
| 20 | `UpdateTableRowStyleRequest` | Format entire rows |
| 21 | `ReplaceImageRequest` | Swap one image for another |
| 22 | `UpdateDocumentStyleRequest` | Modify document-wide properties |
| 23 | `MergeTableCellsRequest` | Combine adjacent cells |
| 24 | `UnmergeTableCellsRequest` | Split merged cells |
| 25 | `CreateHeaderRequest` | Add header sections |
| 26 | `CreateFooterRequest` | Add footer sections |
| 27 | `CreateFootnoteRequest` | Insert footnotes |
| 28 | `ReplaceNamedRangeContentRequest` | Update content within named ranges |
| 29 | `UpdateSectionStyleRequest` | Modify section formatting |
| 30 | `InsertSectionBreakRequest` | Create section divisions |
| 31 | `DeleteHeaderRequest` | Remove headers |
| 32 | `DeleteFooterRequest` | Remove footers |
| 33 | `PinTableHeaderRowsRequest` | Lock header rows during scrolling |
| 34 | `AddDocumentTabRequest` | Create new document tabs |
| 35 | `DeleteTabRequest` | Remove document tabs |
| 36 | `UpdateDocumentTabPropertiesRequest` | Modify tab settings |
| 37 | `InsertPersonRequest` | Add person references |

---

## InsertTextRequest

```json
{
  "insertText": {
    "location": {
      "index": integer,
      "tabId": string
    },
    "text": string
  }
}
```

**Important:** Indexes are measured in UTF-16 code units. Each insertion shifts all higher-numbered indexes by the inserted text's character count.

**Best Practice:** Order insertions to "write backwards" — insert at the highest-numbered index first.

---

## DeleteContentRangeRequest

```json
{
  "deleteContentRange": {
    "range": {
      "startIndex": integer,
      "endIndex": integer,
      "tabId": string
    }
  }
}
```

---

## UpdateTextStyleRequest

```json
{
  "updateTextStyle": {
    "range": {
      "startIndex": integer,
      "endIndex": integer,
      "tabId": string
    },
    "textStyle": {
      "bold": boolean,
      "italic": boolean,
      "underline": boolean,
      "foregroundColor": { "color": { "rgbColor": { "red": 0.0, "green": 0.0, "blue": 0.0 } } },
      "fontSize": { "magnitude": 12, "unit": "PT" },
      "weightedFontFamily": { "fontFamily": "Arial", "weight": 400 },
      "link": { "url": "https://example.com" }
    },
    "fields": "bold,italic"
  }
}
```

**Note:** Include `fields` parameter listing modified properties.

---

## UpdateParagraphStyleRequest

```json
{
  "updateParagraphStyle": {
    "range": {
      "startIndex": integer,
      "endIndex": integer,
      "tabId": string
    },
    "paragraphStyle": {
      "namedStyleType": "HEADING_1",
      "spaceAbove": { "magnitude": 10.0, "unit": "PT" },
      "alignment": "CENTER"
    },
    "fields": "namedStyleType,alignment"
  }
}
```

---

## InsertInlineImageRequest

```json
{
  "insertInlineImage": {
    "uri": "https://example.com/image.png",
    "location": {
      "index": integer,
      "tabId": string
    },
    "objectSize": {
      "height": { "magnitude": 50.0, "unit": "PT" },
      "width": { "magnitude": 50.0, "unit": "PT" }
    }
  }
}
```

**Response:** Includes `insertedInlineImage.objectId` for the newly created image.

---

## ReplaceAllTextRequest

```json
{
  "replaceAllText": {
    "containsText": {
      "text": "{{placeholder}}",
      "matchCase": true
    },
    "replaceText": "replacement value",
    "tabsCriteria": {
      "tabIds": ["tab-id-1"]
    }
  }
}
```

**Note:** If `tabsCriteria` is omitted, applies to all tabs.

---

## CreateParagraphBulletsRequest

```json
{
  "createParagraphBullets": {
    "range": {
      "startIndex": integer,
      "endIndex": integer,
      "tabId": string
    },
    "bulletPreset": "NUMBERED_DECIMAL_ALPHA_ROMAN"
  }
}
```

**Bullet Presets:**
- `NUMBERED_DECIMAL_ALPHA_ROMAN`: decimal → lowercase letter → lowercase Roman
- `BULLET_ARROW_DIAMOND_DISC`: arrow → diamond → disc

**Limitation:** Nesting levels cannot be adjusted on existing bullets. Workaround: delete bullet → add leading tabs → recreate bullet.

---

## InsertTableRequest

```json
{
  "insertTable": {
    "rows": integer,
    "columns": integer,
    "location": {
      "index": integer,
      "tabId": string
    }
  }
}
```

---

## CreateNamedRangeRequest

```json
{
  "createNamedRange": {
    "name": "my-range-name",
    "range": {
      "startIndex": integer,
      "endIndex": integer,
      "tabId": string
    }
  }
}
```

---

## Field Masks

### Read Operations
Use `fields` query parameter to request only needed data:

```
GET https://docs.googleapis.com/v1/documents/documentId?fields=title,tabs(documentTab(body.content(paragraph))),revisionId
```

### Syntax Rules
- Comma-separated lists select multiple fields
- `a/b` notation navigates nested structures
- Parentheses `()` enable sub-field selection
- Wildcards `*` select all child objects (discouraged for production)

### Update Operations
Include `fields` parameter in update requests to indicate changed fields. Unspecified fields retain current values. Fields can be cleared by adding them to the mask without including them in the message.
