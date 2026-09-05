---
source: https://developers.google.com/workspace/docs/api/how-tos/merge
scraped: 2026-03-01
api: google-docs-api
---

# Guide: Merge Text into a Document (Mail Merge)

## Overview

The Google Docs API enables merging data from external sources into template documents. This approach separates content from presentation design.

## Basic Recipe

1. Create a document with placeholder content for design/formatting
2. Replace placeholders with tags (e.g., `{{account-holder-name}}`)
3. Copy the template using Google Drive API
4. Use `batchUpdate()` with `ReplaceAllTextRequest` to replace values

## Key API Methods

| Method | Purpose |
|--------|---------|
| `documents.batchUpdate()` | Performs text replacements across document tabs |
| `ReplaceAllTextRequest` | Request object containing replacement instructions |
| `SubstringMatchCriteria` | Defines text to find with `setText()` and `setMatchCase()` |
| `TabsCriteria` | Optionally specifies target tabs via `addTabIds()` |

## Request Structure

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

**Note:** If `tabsCriteria` is omitted, `ReplaceAllTextRequest` applies to all tabs.

## Python Implementation

```python
from googleapiclient.discovery import build
from google.oauth2.credentials import Credentials
import copy

SCOPES = [
    'https://www.googleapis.com/auth/documents',
    'https://www.googleapis.com/auth/drive',
    'https://www.googleapis.com/auth/spreadsheets.readonly'
]

TEMPLATE_DOC_ID = 'your-template-doc-id'

def create_merged_document(creds, recipient_data):
    """
    recipient_data = {
        '{{name}}': 'John Smith',
        '{{email}}': 'john@example.com',
        '{{date}}': '2026-03-01'
    }
    """
    drive_service = build('drive', 'v3', credentials=creds)
    docs_service = build('docs', 'v1', credentials=creds)

    # Copy the template
    copy_result = drive_service.files().copy(
        fileId=TEMPLATE_DOC_ID,
        body={'name': f"Letter for {recipient_data.get('{{name}}', 'Unknown')}"}
    ).execute()
    new_doc_id = copy_result['id']

    # Build replacement requests
    requests = []
    for placeholder, value in recipient_data.items():
        requests.append({
            'replaceAllText': {
                'containsText': {
                    'text': placeholder,
                    'matchCase': True
                },
                'replaceText': value
            }
        })

    # Execute replacements
    docs_service.documents().batchUpdate(
        documentId=new_doc_id,
        body={'requests': requests}
    ).execute()

    return new_doc_id

# Example usage
data = {
    '{{name}}': 'Jane Doe',
    '{{address}}': '123 Main St',
    '{{zone}}': 'West'
}
doc_id = create_merged_document(creds, data)
print(f"Created: https://docs.google.com/document/d/{doc_id}/edit")
```

## Template Management

### Service Account (Template Creation)

```python
# Create template document
create_result = docs_service.documents().create(
    body={'title': 'Template - Customer Letter'}
).execute()
template_id = create_result['documentId']

# Share template (make it accessible)
drive_service.permissions().create(
    fileId=template_id,
    body={'type': 'anyone', 'role': 'reader'}
).execute()
```

### User Credentials (Instance Creation)

```python
# Duplicate template
copy_result = drive_service.files().copy(
    fileId=TEMPLATE_DOC_ID,
    body={'name': 'Merged Document - Customer Name'}
).execute()
```

## Data Source: Google Sheets

```python
def get_data_from_sheets(creds, spreadsheet_id, range_name):
    sheets_service = build('sheets', 'v4', credentials=creds)
    result = sheets_service.spreadsheets().values().get(
        spreadsheetId=spreadsheet_id,
        range=range_name
    ).execute()

    values = result.get('values', [])
    if not values:
        return []

    headers = values[0]  # First row as headers
    records = []
    for row in values[1:]:
        record = {}
        for i, header in enumerate(headers):
            record[f'{{{{{header}}}}}'] = row[i] if i < len(row) else ''
        records.append(record)

    return records

# Usage
records = get_data_from_sheets(creds, SHEETS_ID, 'Sheet1!A:Z')
for record in records:
    doc_id = create_merged_document(creds, record)
    print(f"Created document: {doc_id}")
```

## Required OAuth Scopes

```python
SCOPES = [
    'https://www.googleapis.com/auth/drive',          # Copy files
    'https://www.googleapis.com/auth/documents',       # Edit docs
    'https://www.googleapis.com/auth/spreadsheets.readonly'  # Read sheet data
]
```

## Placeholder Design Tips

- Use double braces: `{{field-name}}` — unlikely to appear in normal content
- Keep names lowercase with hyphens
- Common patterns: `{{first-name}}`, `{{company}}`, `{{date}}`, `{{amount}}`
- Avoid spaces in placeholder names
