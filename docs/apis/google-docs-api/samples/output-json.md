---
source: https://developers.google.com/workspace/docs/api/samples/output-json
scraped: 2026-03-01
api: google-docs-api
---

# Sample: Output Document Contents as JSON

## Purpose

"Outputs a JSON dump of the complete contents of a document"

Useful for: Understanding document structure or troubleshooting issues.

## Java Implementation

```java
import com.google.api.services.docs.v1.Docs;
import com.google.api.services.docs.v1.model.Document;
import com.google.gson.Gson;

public class OutputJSON {
  private static final String DOCUMENT_ID = "<YOUR_DOCUMENT_ID>";
  private static final List<String> SCOPES =
      Collections.singletonList(DocsScopes.DOCUMENTS_READONLY);

  public static void main(String... args) throws IOException {
    Docs docsService = new Docs.Builder(HTTP_TRANSPORT, JSON_FACTORY,
        getCredentials(HTTP_TRANSPORT))
        .setApplicationName("Google Docs API Document Contents")
        .build();

    Document response = docsService.documents().get(DOCUMENT_ID)
        .setIncludeTabsContent(true).execute();
    Gson gson = new GsonBuilder().setPrettyPrinting().create();
    System.out.println(gson.toJson(response));
  }
}
```

## Python Implementation

```python
import json
from apiclient import discovery
from oauth2client import client, file, tools

DOCUMENT_ID = "YOUR_DOC_ID"
SCOPES = "https://www.googleapis.com/auth/documents.readonly"

service = discovery.build("docs", "v1", http=creds.authorize(Http()))
result = service.documents().get(
    documentId=DOCUMENT_ID,
    includeTabsContent=True
).execute()
print(json.dumps(result, indent=4, sort_keys=True))
```

## JavaScript (Browser) Implementation

```javascript
function printDocBody() {
    gapi.client.docs.documents.get({
        documentId: 'DOCUMENT_ID',
        includeTabsContent: true
    }).then(function(response) {
        var doc = response.result;
        appendPre(JSON.stringify(doc.body, null, 4));
    });
}
```

## Key API Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| `documentId` | string | From URL: `https://docs.google.com/document/d/YOUR_DOC_ID/edit` |
| `includeTabsContent` | true | Include all tab content in response |

## Authentication Scope

`https://www.googleapis.com/auth/documents.readonly` — read-only access sufficient.

## Output Format

The JSON output follows the full Document resource structure:
- `documentId`, `title`, `revisionId`
- `tabs[].documentTab.body.content[]` — nested structural elements
- `tabs[].documentTab.namedRanges`, `lists`, `inlineObjects`, etc.
