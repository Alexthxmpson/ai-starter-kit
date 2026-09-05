---
source: https://developers.google.com/workspace/docs/api/concepts/document
scraped: 2026-03-01
api: google-docs-api
---

# Google Docs API — Core Concepts

## Primary API Methods

The Docs API provides three core operations through the `documents` resource:

- **`documents.create`**: Establishes a new document
- **`documents.get`**: Retrieve the contents of a specified document
- **`documents.batchUpdate`**: Atomically perform a set of updates on a specified document

## Document Identification

The `documentId` is a unique, stable identifier extracted from a document's URL structure:

```
https://docs.google.com/document/d/DOCUMENT_ID/edit
```

Extraction pattern: `/document/d/([a-zA-Z0-9-_]+)`

This ID remains constant even if the document name changes. In Drive API equivalency, `documentId` maps to the `id` field in the `files` resource.

## MIME Type Specification

Docs files use the MIME type: `application/vnd.google-apps.document`

Query filter for Drive API retrieval: `q: mimeType = 'application/vnd.google-apps.document'`

## Document Structure

**Document ID**: Unique identifier derived from document URLs; remains stable despite name changes

**Element**: Structural components including Body, DocumentStyle, and List objects

**Index**: startIndex and endIndex properties indicating element positions within segments (measured in UTF-16 code units)

**Named Range**: A contiguous range of text with user-defined labels for programmatic access. Multiple ranges can share names; all have unique IDs.

**Segment**: Body, Header, Footer, or Footnote containers with relative indexing

**Suggestion**: Document modifications that don't alter original text until approved

## Request/Response Flow

**Document Creation Workflow:**
1. Call `documents.create`
2. Receive HTTP response with created document instance
3. Optionally call `documents.batchUpdate` to populate content
4. Response varies: some methods return applied request details; others return empty

**Document Update Workflow:**
1. Call `documents.get` with `documentId`
2. Parse returned JSON containing content, formatting, and structure
3. Determine required modifications
4. Call `documents.batchUpdate` with edit requests
5. Receive HTTP response

## Integration with Google Drive API

New documents default to user's root folder. Related Drive methods:
- `files.copy`: Duplicate documents
- `files.list`: Locate document IDs
- `files.export`: Export document content with appropriate MIME type

## Key Capabilities

The API supports:
- Automating processes and bulk documentation creation
- Document formatting and styling
- Invoice and contract generation
- Retrieving object attributes programmatically
- Text insertion, deletion, and movement
- Image insertion
- List and table management
- Named range operations
- Suggestion handling
- Tab management
- Field mask implementation
