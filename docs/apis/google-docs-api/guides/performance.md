---
source: https://developers.google.com/workspace/docs/api/how-tos/performance
scraped: 2026-03-01
api: google-docs-api
---

# Guide: Performance Optimization

## Key Performance Techniques

### 1. Gzip Compression

Enable bandwidth reduction through gzip encoding by setting HTTP headers:
- `Accept-Encoding: gzip`
- `User-Agent: my program (gzip)`

"Although this requires additional CPU time to uncompress the results, the trade-off with network costs usually makes it very worthwhile."

Most client libraries handle this automatically.

### 2. Partial Resources via Fields Parameter

Use the `fields` query parameter to request only needed data fields, reducing network, CPU, and memory usage.

**Basic syntax examples:**

| Pattern | Selects |
|---------|---------|
| `fields=kind,items` | Returns specific top-level fields |
| `fields=items/title` | Returns nested fields only |
| `fields=items(title,author/uri)` | Uses sub-selection for specific sub-fields |
| `fields=context/facets/label` | Accesses deeply nested fields |
| `fields=items/pagemap/*/title` | Wildcard selection across objects |

**Example request with fields:**
```
GET https://docs.googleapis.com/v1/documents/DOC_ID?fields=title,tabs(documentTab(body.content(paragraph))),revisionId
```

### 3. Response Handling

- Success returns HTTP `200 OK` with selected fields only
- Invalid `fields` parameter returns HTTP `400 Bad Request` with error message
- Response includes only selected fields and their enclosing parent objects

### 4. Syntax Rules

- Comma-separated lists select multiple fields
- `a/b` notation navigates nested structures
- Parentheses `()` enable sub-field selection
- Wildcards `*` select all child objects
- Exception: Omit "data" wrapper in `data: {...}` responses

### 5. Combine with Pagination

For operations involving lists or large datasets, combine partial responses with pagination parameters (`maxResults`, `nextPageToken`) for optimal performance gains.

## Practical Examples

### Minimal read (title only):
```
GET /v1/documents/DOC_ID?fields=title
```

### Read revision ID for write control:
```
GET /v1/documents/DOC_ID?fields=title,revisionId
```

### Read all tab body content:
```
GET /v1/documents/DOC_ID?fields=tabs(documentTab(body.content))&includeTabsContent=true
```

### Read named ranges only:
```
GET /v1/documents/DOC_ID?fields=tabs(documentTab(namedRanges))&includeTabsContent=true
```

### Read document for text extraction:
```
GET /v1/documents/DOC_ID?fields=tabs(documentTab(body.content(paragraph(elements(textRun(content))))))&includeTabsContent=true
```

## Batching Strategy

Combine as many operations as possible into a single `batchUpdate` call:

- Reduces HTTP overhead
- Operations execute atomically
- Better performance than sequential single-operation calls
- Quota usage is per request, not per operation within a batch

## Client Library Defaults

The official Google API client libraries:
- Enable gzip by default
- Handle token refresh automatically
- Provide built-in retry logic for transient errors
