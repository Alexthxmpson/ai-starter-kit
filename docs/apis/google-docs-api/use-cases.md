# Google Docs API — Use Cases & Practical Guide

**Date:** 2026-03-01
**Source:** https://developers.google.com/workspace/docs/api/reference/rest

---

## What You Can Do

### Free / No Auth Required
- Nothing. All Docs API operations require OAuth 2.0. There is no public read-only API key access.

### Free + OAuth Required (No Payment)
- Read any Google Doc you have access to
- Create new Google Docs documents
- Insert, delete, and format text programmatically
- Insert images from public URLs
- Create tables, headers, footers, footnotes
- Use named ranges for template injection
- Mail merge: copy templates + replace placeholders
- Extract all text content from a document
- List and manage document tabs
- Apply paragraph styles (headings, bullets, borders)
- Get document as full JSON structure

### Paid / Requires Additional Setup
- No paid tiers — the Google Docs API is entirely free
- Rate limit increases may require requesting a quota upgrade via Google Cloud console
- For large-scale usage: set up a Google Cloud project with service accounts (free)

### What the API Cannot Do
- Cannot upload local images directly (images must be publicly accessible URLs)
- Cannot access comments (use Google Drive API for comments)
- Cannot export documents as PDF/DOCX (use Google Drive API `files.export`)
- Cannot move or copy documents (use Google Drive API `files.copy`)
- Cannot manage document permissions (use Google Drive API)
- Cannot directly adjust bullet nesting levels on existing bullets (workaround: delete + re-add)
- Cannot do real-time collaborative editing via API (use WebSockets/Drive API for change detection)
- Cannot access document version history
- Cannot create or manage Google Workspace users

---

## Automation Ideas

| Use Case | Complexity | What You Do | Key Endpoint / Request |
|----------|------------|-------------|------------------------|
| Generate invoices from template | Medium | Copy template, ReplaceAllText for each field | `files.copy` + `batchUpdate` + `ReplaceAllTextRequest` |
| Mail merge from Google Sheets | Medium | Read sheet rows, copy template, inject values | `batchUpdate` + `ReplaceAllTextRequest` |
| Extract text for AI processing | Easy | Get doc, recursively extract textRun.content | `documents.get` + `includeTabsContent=true` |
| Auto-generate weekly reports | Medium | Create doc, insert dynamic content, share | `documents.create` + `batchUpdate` |
| Export doc structure as JSON | Easy | Get doc with includeTabsContent | `documents.get` |
| Build a CMS / headless doc system | Complex | Use named ranges as content slots, update programmatically | `CreateNamedRangeRequest` + `ReplaceNamedRangeContentRequest` |
| Contract generator | Medium | Template with named ranges, inject client data | Named ranges + `batchUpdate` |
| Sync Notion/Airtable data to Docs | Complex | Read source data, update doc placeholders | `ReplaceAllTextRequest` batch |
| Style enforcement tool | Medium | Read doc, detect non-conforming paragraphs, apply UpdateParagraphStyle | `documents.get` + `UpdateParagraphStyleRequest` |
| Add auto-formatted tables from data | Medium | Build InsertTableRequest, fill cells with InsertText | `InsertTableRequest` + `InsertTextRequest` |
| Insert images from cloud storage | Easy | Build InsertInlineImageRequest with public CDN URL | `InsertInlineImageRequest` |
| Track document changes via revision | Medium | Store revisionId, compare after changes | `documents.get` + `revisionId` field |
| Create numbered report sections | Easy | Create doc, insert text, apply CreateParagraphBullets | `CreateParagraphBulletsRequest` |
| Multi-tab document builder | Complex | AddDocumentTab, insert content per tab with tabId | `AddDocumentTabRequest` + per-tab requests |
| Document health checker | Medium | Scan for placeholder text not yet replaced | `documents.get` + text search in response |

---

## Key Limits and Gotchas

| Limit / Gotcha | Details |
|----------------|---------|
| Read quota | 3,000 requests/minute per project, 300 per user |
| Write quota | 600 requests/minute per project, 60 per user |
| Quota error | HTTP 429 — implement exponential backoff |
| Image URLs | Must be publicly accessible. No local file upload. |
| Index encoding | All indexes are UTF-16 code units, not characters (affects emoji, CJK) |
| Backward editing | Always insert from highest index to lowest within a batch — prevents index shift errors |
| Tab content | Must pass `includeTabsContent=true` to get content from tabs (not returned by default) |
| Suggestions mode | Use `SUGGESTIONS_INLINE` to get correct indexes when suggestions exist |
| WriteControl | Use `requiredRevisionId` to prevent overwriting concurrent edits |
| batchUpdate atomicity | All requests in a batch are validated first — if one fails, none apply |
| ReplaceAllText scope | Applies to ALL tabs by default; use `tabsCriteria` to restrict |
| Bullet nesting | Cannot directly promote/demote list levels on existing bullets |
| Comments | Not in Docs API — use `drive.comments` resource via Drive API |
| Export (PDF/DOCX) | Use `drive.files.export` with the appropriate MIME type |
| No free tier | Everything requires OAuth 2.0 (no API key read-only access) |
| revisionId | Only valid for 24 hours — don't store and reuse later |
| Service accounts | All calls count toward one account's quota |

---

## OAuth Scope Selection Guide

| Need | Use This Scope |
|------|---------------|
| Read documents you have access to | `documents.readonly` or `drive.file` |
| Create and edit documents | `documents` or `drive.file` |
| Access all user's Drive files | `drive` (restricted — requires extra verification) |
| App-specific files only | `drive.file` (recommended — non-sensitive) |

Always start with `drive.file` — it only allows access to files created or opened by your app, which is the least invasive and fastest to verify.

---

## Available Code Examples and Tools

All code examples in this documentation folder:
- **Python** quickstart, text extraction, mail merge, JSON dump
- **Java** text insertion, formatting, images, tables
- **JavaScript** (browser) OAuth + document get
- **Go** OAuth2 + document get
- **PHP** inline image insertion

GitHub sample repository: https://github.com/googleworkspace/python-samples/tree/main/docs

---

## Quick Start (Python — 5 minutes)

```bash
python3 -m pip install google-api-python-client google-auth-httplib2 google-auth-oauthlib
```

```python
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
import os

SCOPES = ["https://www.googleapis.com/auth/documents"]

flow = InstalledAppFlow.from_client_secrets_file("credentials.json", SCOPES)
creds = flow.run_local_server(port=0)
service = build("docs", "v1", credentials=creds)

# Create a doc
doc = service.documents().create(body={'title': 'My First Doc'}).execute()
doc_id = doc['documentId']

# Insert text
service.documents().batchUpdate(documentId=doc_id, body={'requests': [
    {'insertText': {'location': {'index': 1}, 'text': 'Hello from the API!'}}
]}).execute()

print(f"https://docs.google.com/document/d/{doc_id}/edit")
```
