---
source: https://developers.google.com/workspace/docs/api/samples/extract-text
scraped: 2026-03-01
api: google-docs-api
---

# Sample: Extract Text from a Document

## Purpose

"Extracts only the text from a document"

Useful for: Passing document text to another service (NLP, LLM, search index, etc.).

## Overview

Text extraction requires traversing the document structure. Text appears within three structural element types:
1. **Paragraph** elements
2. **Table of Contents** elements
3. **Table** elements (which can nest recursively)

## Python Implementation

```python
import os.path
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

SCOPES = ["https://www.googleapis.com/auth/documents.readonly"]
DOCUMENT_ID = "YOUR_DOCUMENT_ID"

def read_paragraph_element(element):
    """Returns the text in the given ParagraphElement."""
    text_run = element.get('textRun')
    if not text_run:
        return ''
    return text_run.get('content', '')

def read_structural_elements(elements):
    """Recurses through a list of Structural Elements to read a document's text."""
    text = ''
    for value in elements:
        if 'paragraph' in value:
            paragraph = value.get('paragraph')
            for elem in paragraph.get('elements'):
                text += read_paragraph_element(elem)
        elif 'table' in value:
            # The text in table cells are in nested Structural Elements
            table = value.get('table')
            for row in table.get('tableRows'):
                cells = row.get('tableCells')
                for cell in cells:
                    text += read_structural_elements(cell.get('content'))
        elif 'tableOfContents' in value:
            # The text in the TOC is also in Structural Elements
            toc = value.get('tableOfContents')
            text += read_structural_elements(toc.get('content'))
    return text

def main():
    creds = None
    if os.path.exists("token.json"):
        creds = Credentials.from_authorized_user_file("token.json", SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file("credentials.json", SCOPES)
            creds = flow.run_local_server(port=0)
        with open("token.json", "w") as token:
            token.write(creds.to_json())

    try:
        service = build("docs", "v1", credentials=creds)
        document = service.documents().get(
            documentId=DOCUMENT_ID,
            includeTabsContent=True
        ).execute()

        # Process all tabs
        all_text = ''
        for tab in document.get('tabs', []):
            doc_tab = tab.get('documentTab', {})
            body = doc_tab.get('body', {})
            all_text += read_structural_elements(body.get('content', []))

        print(all_text)

    except HttpError as err:
        print(err)

if __name__ == "__main__":
    main()
```

## Java Implementation Pattern

```java
public static String getText(Document document) {
    StringBuilder sb = new StringBuilder();
    List<Tab> tabs = document.getTabs();
    if (tabs == null) return "";

    for (Tab tab : tabs) {
        DocumentTab docTab = tab.getDocumentTab();
        if (docTab == null) continue;
        Body body = docTab.getBody();
        if (body == null) continue;
        readStructuralElements(body.getContent(), sb);
    }
    return sb.toString();
}

private static void readStructuralElements(
        List<StructuralElement> elements, StringBuilder sb) {
    if (elements == null) return;
    for (StructuralElement element : elements) {
        if (element.getParagraph() != null) {
            for (ParagraphElement pe : element.getParagraph().getElements()) {
                if (pe.getTextRun() != null) {
                    sb.append(pe.getTextRun().getContent());
                }
            }
        } else if (element.getTable() != null) {
            for (TableRow row : element.getTable().getTableRows()) {
                for (TableCell cell : row.getTableCells()) {
                    readStructuralElements(cell.getContent(), sb);
                }
            }
        } else if (element.getTableOfContents() != null) {
            readStructuralElements(
                element.getTableOfContents().getContent(), sb);
        }
    }
}
```

## Key Notes

- Always use `includeTabsContent=True` to get content from all tabs
- Non-text elements (images, equations) appear as U+E907 in `textRun.content`
- Tables can be nested — the recursive approach handles this correctly
- Headers, footers, and footnotes are in separate segments and require separate extraction
