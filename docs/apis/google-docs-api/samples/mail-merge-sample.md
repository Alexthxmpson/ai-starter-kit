---
source: https://developers.google.com/workspace/docs/api/samples/mail-merge
scraped: 2026-03-01
api: google-docs-api
---

# Sample: Mail Merge

## Purpose

Merge documents from templates using data sources (Google Sheets or plain text).

## Overview

"A mail merge takes values from rows of a spreadsheet or another data source and inserts them into a template document."

## Data Structure

Data organized with one record per row, columns as fields:

| Name | Address | Zone |
|------|---------|------|
| UrbanPq | 123 1st St. | West |
| Pawxana | 456 2nd St. | South |

## Template Variables

The sample uses double-brace syntax: `{{VALUE}}` for placeholders unlikely to appear naturally in content.

## Implementation Steps

1. Create a Docs file and note its document ID
2. Set `DOCS_FILE_ID` variable to the ID
3. Replace contact information with template placeholders
4. Choose data source via `SOURCE` variable ('text' or 'sheets')
5. Configure `SHEETS_FILE_ID` if using Sheets data

## Key APIs Required

- Google Docs API
- Google Sheets API (for spreadsheet data source)
- Google Drive API (for file copying)

## Required OAuth Scopes

```python
SCOPES = [
    'https://www.googleapis.com/auth/drive',
    'https://www.googleapis.com/auth/documents',
    'https://www.googleapis.com/auth/spreadsheets.readonly'
]
```

## Core Logic

```python
# Configuration
DOCS_FILE_ID = 'your-template-doc-id'
SHEETS_FILE_ID = 'your-sheets-data-id'
SOURCE = 'sheets'  # or 'text'

# Sample text data (alternative to Sheets)
TEXT_SOURCE_DATA = (
    ('name', 'address', 'zone'),
    ('Alice Smith', '123 Oak St', 'North'),
    ('Bob Jones', '456 Pine Ave', 'South'),
)

def merge_template(service_drive, service_docs, service_sheets=None):
    # Get data rows
    if SOURCE == 'sheets':
        data = get_sheets_data(service_sheets, SHEETS_FILE_ID)
    else:
        data = TEXT_SOURCE_DATA

    headers = data[0]
    rows = data[1:]

    merge_docs = []
    for row in rows:
        # Copy the template
        copy_result = service_drive.files().copy(
            fileId=DOCS_FILE_ID,
            body={'name': f'Merged - {row[0]}'}
        ).execute()
        doc_id = copy_result['id']

        # Build replacement requests
        requests = [
            {
                'replaceAllText': {
                    'containsText': {'text': f'{{{{{header}}}}}', 'matchCase': True},
                    'replaceText': value
                }
            }
            for header, value in zip(headers, row)
        ]

        # Execute replacements
        service_docs.documents().batchUpdate(
            documentId=doc_id,
            body={'requests': requests}
        ).execute()

        merge_docs.append(f"https://docs.google.com/document/d/{doc_id}/edit")
        print(f"Created: {merge_docs[-1]}")

    return merge_docs


def get_sheets_data(service, spreadsheet_id):
    result = service.spreadsheets().values().get(
        spreadsheetId=spreadsheet_id,
        range='Sheet1'
    ).execute()
    return tuple(map(tuple, result.get('values', ())))
```

## Important Note

"For documents with multiple tabs, `ReplaceAllTextRequest` by default applies to all tabs."

To restrict to specific tabs:
```python
{
    'replaceAllText': {
        'containsText': {'text': '{{placeholder}}', 'matchCase': True},
        'replaceText': 'value',
        'tabsCriteria': {'tabIds': ['tab-id-here']}
    }
}
```

## GitHub Repository

Full samples available at: https://github.com/googleworkspace/python-samples/tree/main/docs
