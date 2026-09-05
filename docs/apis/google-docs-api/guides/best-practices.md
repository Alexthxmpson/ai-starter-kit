---
source: https://developers.google.com/workspace/docs/api/how-tos/best-practices
scraped: 2026-03-01
api: google-docs-api
---

# Guide: Best Practices

## Core Principles

### 1. Edit Backwards for Efficiency

Order requests in descending index order within a single `documents.batchUpdate` call to "eliminate the need to compute the index changes due to insertions and deletions."

When you have multiple insertions in the same batch, inserting at higher indexes first means earlier insertions don't shift the positions of later ones.

```python
# Correct: insert from end to beginning
requests = [
    {'insertText': {'location': {'index': 100}, 'text': 'Last item'}},
    {'insertText': {'location': {'index': 50}, 'text': 'Middle item'}},
    {'insertText': {'location': {'index': 10}, 'text': 'First item'}},
]
```

### 2. Plan for Collaboration

Document state changes between API calls due to concurrent editing. The API client must manage state consistency defensively, even without anticipated collaboration.

Never assume the document state remains unchanged between your `get` and `batchUpdate` calls.

### 3. WriteControl for State Consistency

Use the `WriteControl` field in `batchUpdate` with two options:

| Option | Behavior |
|--------|----------|
| `requiredRevisionId` | Prevents writes if document was modified since read; returns error |
| `targetRevisionId` | Applies writes against collaborator changes; server merges content into new revision |

Retrieve `revisionId` from `documents.get` response before composing updates.

```python
# Get document and capture revision ID
doc = service.documents().get(
    documentId=DOC_ID,
    includeTabsContent=True
).execute()
revision_id = doc['revisionId']

# Use it in batchUpdate
service.documents().batchUpdate(
    documentId=DOC_ID,
    body={
        'requests': requests,
        'writeControl': {
            'requiredRevisionId': revision_id
            # Or use 'targetRevisionId' for merge behavior
        }
    }
).execute()
```

### 4. Tab Handling Requirements

- Set `includeTabsContent` parameter to `true` in `documents.get` to retrieve all tab content (not returned by default)
- Specify tab ID(s) for each `Request` in `batchUpdate`
- Requests without tab specification apply to first tab by default

### 5. Use Field Masks

Always use field masks to request only the data you need:

```
GET https://docs.googleapis.com/v1/documents/DOC_ID?fields=title,revisionId
```

For update requests, always include the `fields` parameter:
```json
{
  "updateTextStyle": {
    "textStyle": { "bold": true },
    "fields": "bold"
  }
}
```

### 6. Batch Requests Together

Minimize API calls by combining multiple operations into a single `batchUpdate`:

```python
# Good: One API call for multiple operations
requests = [
    {'insertText': {...}},
    {'updateTextStyle': {...}},
    {'createParagraphBullets': {...}}
]
service.documents().batchUpdate(documentId=DOC_ID, body={'requests': requests}).execute()

# Avoid: Multiple separate API calls
service.documents().batchUpdate(documentId=DOC_ID, body={'requests': [insert_req]}).execute()
service.documents().batchUpdate(documentId=DOC_ID, body={'requests': [style_req]}).execute()
```

### 7. Handle Quota Errors with Exponential Backoff

```python
import time
import random

def batchUpdate_with_retry(service, doc_id, requests, max_retries=5):
    for attempt in range(max_retries):
        try:
            return service.documents().batchUpdate(
                documentId=doc_id,
                body={'requests': requests}
            ).execute()
        except HttpError as e:
            if e.resp.status == 429:
                wait = min((2 ** attempt) + random.random(), 64)
                time.sleep(wait)
            else:
                raise
    raise Exception("Max retries exceeded")
```

### 8. Use Gzip Compression

Enable bandwidth reduction through gzip encoding:

```python
# Python: gzip is enabled by default in google-api-python-client
# For manual HTTP requests:
headers = {
    'Accept-Encoding': 'gzip',
    'User-Agent': 'my-app (gzip)'
}
```

## Performance Optimization

### Partial Responses

Request only needed fields to reduce network, CPU, and memory usage:

```
# Get only title and body content
GET /v1/documents/DOC_ID?fields=title,tabs(documentTab(body.content))

# Get title, revision, and paragraph content
GET /v1/documents/DOC_ID?fields=title,revisionId,tabs(documentTab(body.content(paragraph)))
```

### Field Mask Syntax

| Pattern | Selects |
|---------|---------|
| `fields=kind,items` | Specific top-level fields |
| `fields=items/title` | Nested fields only |
| `fields=items(title,author/uri)` | Specific sub-fields |
| `fields=context/facets/label` | Deeply nested fields |
| `fields=items/pagemap/*/title` | Wildcard across objects |

## Error Codes

| HTTP Status | Meaning | Action |
|-------------|---------|--------|
| 400 | Bad Request | Check request structure and field masks |
| 401 | Unauthorized | Refresh OAuth token |
| 403 | Forbidden | Check OAuth scopes |
| 404 | Not Found | Verify document ID |
| 429 | Too Many Requests | Implement exponential backoff |
| 500 | Internal Server Error | Retry with backoff |
