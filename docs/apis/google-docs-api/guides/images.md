---
source: https://developers.google.com/workspace/docs/api/how-tos/images
scraped: 2026-03-01
api: google-docs-api
---

# Guide: Insert Inline Images

## Overview

The Google Docs API enables image insertion into documents via the `InsertInlineImageRequest` method.

**Key constraint:** "The image must be publicly accessible through the URL that you provide in this method."

## Method: InsertInlineImageRequest

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `uri` | string | Yes | Publicly accessible image URL |
| `location` | Location | Yes | Insertion point with `index` and `tabId` fields |
| `objectSize` | Size (optional) | No | Image dimensions |

### Size Format

Each dimension requires:
- `magnitude`: Numeric value
- `unit`: Measurement unit (e.g., "PT" for points)

## Code Examples

### Java

```java
List<Request> requests = new ArrayList<>();
requests.add(new Request().setInsertInlineImage(
    new InsertInlineImageRequest()
        .setUri(imageUri)
        .setLocation(new Location()
            .setIndex(insertionIndex)
            .setTabId(TAB_ID))
        .setObjectSize(new Size()
            .setHeight(new Dimension().setMagnitude(50.0).setUnit("PT"))
            .setWidth(new Dimension().setMagnitude(50.0).setUnit("PT")))));

BatchUpdateDocumentRequest body = new BatchUpdateDocumentRequest()
    .setRequests(requests);
BatchUpdateDocumentResponse response = docsService.documents()
    .batchUpdate(DOCUMENT_ID, body).execute();

// Get the inserted image object ID
String objectId = response.getReplies().get(0)
    .getInsertInlineImage().getObjectId();
```

### PHP

```php
$requests = array(
    new Google_Service_Docs_Request(array(
        'insertInlineImage' => array(
            'uri' => $imageUri,
            'location' => array(
                'index' => $insertionIndex,
                'tabId' => $TAB_ID
            ),
            'objectSize' => array(
                'height' => array('magnitude' => 50.0, 'unit' => 'PT'),
                'width' => array('magnitude' => 50.0, 'unit' => 'PT')
            )
        )
    ))
);
```

### Python

```python
requests = [
    {
        'insertInlineImage': {
            'uri': image_uri,
            'location': {
                'index': insertion_index,
                'tabId': TAB_ID
            },
            'objectSize': {
                'height': {'magnitude': 50.0, 'unit': 'PT'},
                'width': {'magnitude': 50.0, 'unit': 'PT'}
            }
        }
    }
]

response = service.documents().batchUpdate(
    documentId=DOCUMENT_ID,
    body={'requests': requests}
).execute()

# Get the inserted image's object ID
object_id = response['replies'][0]['insertInlineImage']['objectId']
```

## Response Structure

"The method inserts the image as a new `ParagraphElement` with an `InlineObjectElement` of length 1, where the `startIndex` is the request's location."

The response includes the inserted image's `objectId` for future reference (e.g., for `ReplaceImageRequest`).

## Replace an Image

Use `ReplaceImageRequest` to swap one image for another:

```json
{
  "replaceImage": {
    "imageObjectId": "existing-object-id",
    "uri": "https://example.com/new-image.png",
    "imageReplaceMethod": "CENTER_CROP"
  }
}
```

**imageReplaceMethod options:**
- `CENTER_CROP`: Crops to fill the original dimensions
- `DEFAULT`: Stretches to fit

## Limitations

- Images must be publicly accessible via URL (no authentication)
- Cannot insert images from local files directly
- Image dimensions cannot exceed document page dimensions
