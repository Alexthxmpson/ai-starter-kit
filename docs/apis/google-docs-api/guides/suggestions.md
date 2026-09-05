---
source: https://developers.google.com/workspace/docs/api/how-tos/suggestions
scraped: 2026-03-01
api: google-docs-api
---

# Guide: Work with Suggestions

## Overview

Google Docs enables collaborators to make suggestions, which function as "deferred edits waiting for approval." The `documents.get` method retrieves document content that may include unresolved suggestions.

## SuggestionsViewMode Parameter

The optional `SuggestionsViewMode` parameter controls how suggestions appear in API responses:

| Mode | Description |
|------|-------------|
| `SUGGESTIONS_INLINE` | Text pending deletion or insertion displays in the document |
| `PREVIEW_WITH_SUGGESTIONS_ACCEPTED` | Content preview with all suggestions accepted |
| `PREVIEW_WITHOUT_SUGGESTIONS` | Content preview with all suggestions rejected |
| `DEFAULT_FOR_CURRENT_ACCESS` | Default applied when parameter omitted |

## Critical Index Behavior

"To obtain indexes that you can use in a subsequent `documents.batchUpdate` call, get the version using **SUGGESTIONS_INLINE**. Only this mode provides the correct indexes."

When suggestions exist, indexes differ from rejection scenarios. The paragraph containing suggested text shifts based on view mode — with `SUGGESTIONS_INLINE`, indexes account for all suggested insertions.

## Java Example

```java
final String SUGGEST_MODE = "PREVIEW_WITHOUT_SUGGESTIONS";
Document doc = service.documents().get(DOCUMENT_ID)
    .setIncludeTabsContent(true)
    .setSuggestionsViewMode(SUGGEST_MODE)
    .execute();
```

## Python Example

```python
SUGGEST_MODE = "PREVIEW_WITHOUT_SUGGESTIONS"
result = (service.documents().get(
    documentId=DOCUMENT_ID,
    includeTabsContent=True,
    suggestionsViewMode=SUGGEST_MODE,
).execute())
```

## Style Suggestions

Style suggestions involve formatting/presentation changes rather than content modifications. They employ `SuggestedTextStyle` annotations containing:

- **textStyle**: Describes post-change formatting
- **textStyleSuggestionState**: Indicates which fields changed; "Only the style features set to `true` in the `textStyleSuggestionState` are part of the suggestion."

Style suggestions don't offset indexes but may fragment `TextRun` objects into smaller chunks.

## Suggestion Data Structures

### TextRun with Suggestions

```json
{
  "textRun": {
    "content": "suggested text",
    "suggestedInsertionIds": ["suggestion-id-1"],
    "suggestedDeletionIds": ["suggestion-id-2"],
    "textStyle": { ... },
    "suggestedTextStyleChanges": {
      "suggestion-id-1": {
        "textStyle": { "bold": true },
        "textStyleSuggestionState": {
          "boldSuggested": true
        }
      }
    }
  }
}
```

## Working with Suggestions Programmatically

To safely use indexes when suggestions exist:
1. Always request `SUGGESTIONS_INLINE` mode when you plan to do batchUpdate operations
2. Filter out suggestion IDs as needed for your use case
3. Be aware that suggested deletions still appear in `SUGGESTIONS_INLINE` mode
