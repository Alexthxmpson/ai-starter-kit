---
source: https://developers.google.com/workspace/docs/api/auth
scraped: 2026-03-01
api: google-docs-api
---

# Google Docs API — Authentication & OAuth 2.0 Scopes

## OAuth 2.0 Scopes

| Scope | Access Level | Sensitivity |
|-------|--------------|-------------|
| `https://www.googleapis.com/auth/documents` | Full read/write/create/delete access to all Google Docs | Sensitive |
| `https://www.googleapis.com/auth/documents.readonly` | See all your Google Docs documents (read-only) | Sensitive |
| `https://www.googleapis.com/auth/drive.file` | See, edit, create, and delete only specific Google Drive files | Non-sensitive (Recommended) |
| `https://www.googleapis.com/auth/drive` | Complete access to all Drive files | Restricted |
| `https://www.googleapis.com/auth/drive.readonly` | Read-only access to all Drive files | Restricted |

## Scope Classification

**Non-sensitive scopes** provide per-file access and require basic app verification. Recommended to use `drive.file` when possible as it limits access to only files created/opened by the app.

**Sensitive scopes** require additional verification and access specific user data authorized per-application.

**Restricted scopes** demand full verification and security assessment if storing data on external servers, per the Google API Services User Data Policy.

## Configuration Requirements

Apps must configure the OAuth consent screen and declare scopes before deployment. Users validate requested scopes during installation. Public applications accessing user data require verification to remove the "unverified app" warning.

## Scope Selection Best Practice

"You should choose the most narrowly focused scope possible" to improve user trust and simplify the verification process.

## Method-Specific Scope Requirements

### documents.get()
Requires one of:
- `https://www.googleapis.com/auth/documents`
- `https://www.googleapis.com/auth/documents.readonly`
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.readonly`
- `https://www.googleapis.com/auth/drive.file`

### documents.create()
Requires one of:
- `https://www.googleapis.com/auth/documents`
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`

### documents.batchUpdate()
Requires one of:
- `https://www.googleapis.com/auth/documents`
- `https://www.googleapis.com/auth/drive`
- `https://www.googleapis.com/auth/drive.file`
