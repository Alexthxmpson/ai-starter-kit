# Sharing to Stories - Instagram Platform
**Source:** https://developers.facebook.com/docs/instagram-platform/sharing-to-stories
**Date:** 2026-03-01
**Note:** Original URL https://developers.facebook.com/docs/instagram-api/guides/content-publishing/stories redirected here. This page covers the mobile SDK (Android/iOS) approach to sharing content to Instagram Stories. For API-based story publishing via the Graph API, see content-publishing.md (media_type=STORIES).

---

## Sharing to Stories

You can integrate sharing into your Android and iOS apps so that users can share your content as an Instagram story.

**Important (January 2023):** You must provide a Facebook AppID to share content to Instagram Stories. Without it, users see: "The app you shared from doesn't currently support sharing to Stories."

## Overview

By using Android **Implicit Intents** and iOS **Custom URL Schemes**, your app can send photos, videos, and stickers to the Instagram app. The Instagram app receives this content and loads it in the story composer so the User can publish it to their Instagram Stories.

The Instagram app's story composer is comprised of two layers:

**Background Layer** — Fills the screen. Can be customized with a photo, video, solid color, or color gradient.

**Sticker Layer** — Contains an image that can be further customized by the User within the story composer.

## Publishing Stories via Graph API

To publish a story programmatically via the API:
- Set `media_type=STORIES` when creating a media container
- The container can contain an image or video
- After publishing, `media_type` field returns `IMAGE/VIDEO` — check `media_product_type` field to confirm it's a story

## Android Developers

Android implementations use implicit intents to launch the Instagram app and pass it content.

**Sharing flow:**
1. Instantiate an implicit intent with the content you want to pass to the Instagram app
2. Start an activity and check that it can resolve the implicit intent
3. Resolve the activity if it is able to

### Android Data Parameters

| Content | Type | Description |
|---|---|---|
| Facebook App ID | String | Your Facebook App ID |
| Background asset | Uri | Uri to an image asset (JPG, PNG) or video asset (H.264, H.265, WebM). Min dimensions 720x1280. Recommended ratios 9:16 or 9:18. Videos: 1080p, up to 20 seconds. **Must be a content Uri to a local file on device.** Must send background asset, sticker asset, or both. |
| Sticker asset | Uri | Uri to an image asset (JPG, PNG). Recommended dimensions: 640x480. Appears as sticker over background. **Must be a content Uri to a local file on device.** Must send background asset, sticker asset, or both. |
| Background layer top color | String | Hex string color value (e.g., `#33FF33`). If same as bottom, solid color. If different, generates gradient. Ignored if background asset is specified. |
| Background layer bottom color | String | Hex string color value (e.g., `#FF00FF`). If same as top, solid color. If different, generates gradient. Ignored if background asset is specified. |

### Android: Sharing a Background Asset

```java
// Instantiate an intent
Intent intent = new Intent("com.instagram.share.ADD_TO_STORY");

// Attach your App ID to the intent
String sourceApplication = "1234567"; // This is your application's FB ID
intent.putExtra("source_application", sourceApplication);

// Attach your image to the intent from a URI
Uri backgroundAssetUri = Uri.parse("your-image-asset-uri-goes-here");
intent.setDataAndType(backgroundAssetUri, MEDIA_TYPE_JPEG);

// Grant URI permissions for the image
intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

// Instantiate an activity
Activity activity = getActivity();

// Verify that the activity resolves the intent and start it
if (activity.getPackageManager().resolveActivity(intent, 0) != null) {
    activity.startActivityForResult(intent, 0);
}
```

### Android: Sharing a Sticker Asset

```java
// Instantiate an intent
Intent intent = new Intent("com.instagram.share.ADD_TO_STORY");

// Attach your App ID to the intent
String sourceApplication = "1234567"; // This is your application's FB ID
intent.putExtra("source_application", sourceApplication);

// Attach your sticker to the intent from a URI, and set background colors
Uri stickerAssetUri = Uri.parse("your-image-asset-uri-goes-here");
intent.setType(MEDIA_TYPE_JPEG);
intent.putExtra("interactive_asset_uri", stickerAssetUri);
intent.putExtra("top_background_color", "#33FF33");
intent.putExtra("bottom_background_color", "#FF00FF");

// Instantiate an activity
Activity activity = getActivity();

// Grant URI permissions for the sticker
activity.grantUriPermission(
    "com.instagram.android",
    stickerAssetUri,
    Intent.FLAG_GRANT_READ_URI_PERMISSION);

// Verify that the activity resolves the intent and start it
if (activity.getPackageManager().resolveActivity(intent, 0) != null) {
    activity.startActivityForResult(intent, 0);
}
```

### Android: Sharing Background Asset and Sticker Asset

```java
// Instantiate an intent
Intent intent = new Intent("com.instagram.share.ADD_TO_STORY");

// Attach your App ID to the intent
String sourceApplication = "1234567"; // This is your application's FB ID
intent.putExtra("source_application", sourceApplication);

// Attach your image to the intent from a URI
Uri backgroundAssetUri = Uri.parse("your-background-image-asset-uri-goes-here");
intent.setDataAndType(backgroundAssetUri, MEDIA_TYPE_JPEG);

// Attach your sticker to the intent from a URI
Uri stickerAssetUri = Uri.parse("your-sticker-image-asset-uri-goes-here");
intent.putExtra("interactive_asset_uri", stickerAssetUri);

// Grant URI permissions for the image
intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

// Instantiate an activity
Activity activity = getActivity();

// Grant URI permissions for the sticker
activity.grantUriPermission(
    "com.instagram.android",
    stickerAssetUri,
    Intent.FLAG_GRANT_READ_URI_PERMISSION);

// Verify that the activity resolves the intent and start it
if (activity.getPackageManager().resolveActivity(intent, 0) != null) {
    activity.startActivityForResult(intent, 0);
}
```

## iOS Developers

iOS implementations use a **custom URL scheme** to launch the Instagram app and pass it content.

**Sharing flow:**
1. Check that your app can resolve Instagram's custom URL scheme
2. Assign the content that you want to share to the pasteboard
3. Resolve the custom URL scheme if your app is able to

### iOS Data Parameters

| Content | Type | Description |
|---|---|---|
| Facebook App ID | NSString * | Your Facebook App ID |
| Background image asset | NSData * | Data for image asset (JPG, PNG). Min dimensions 720x1280. Recommended ratios 9:16 or 9:18. Must pass background asset (image or video), sticker asset, or both. |
| Background video asset | NSData * | Data for video asset (H.264, H.265, WebM). Videos: 1080p, up to 20 seconds. Under 50 MB recommended. Must pass background asset (image or video), sticker asset, or both. |
| Sticker asset | NSData * | Data for image asset (JPG, PNG). Recommended dimensions: 640x480. Appears as sticker over background. Must pass background asset (image or video), sticker asset, or both. |
| Background layer top color | NSString * | Hex string color value. If same as bottom, solid color. If different, generates gradient. |
| Background layer bottom color | NSString * | Hex string color value. If same as top, solid color. If different, generates gradient. |

### Register Instagram's Custom URL Scheme

Add `instagram-stories` to the `LSApplicationQueriesSchemes` key in your app's `Info.plist`.

### iOS: Sharing a Background Asset

```objective-c
- (void)shareBackgroundImage {
    // Identify your App ID
    NSString *const appIDString = @"1234567890";
    // Call method to share image
    [self backgroundImage:UIImagePNGRepresentation([UIImage imageNamed:@"backgroundImage"])
                    appID:appIDString];
}

// Method to share image
- (void)backgroundImage:(NSData *)backgroundImage appID:(NSString *)appID {
    NSURL *urlScheme = [NSURL URLWithString:[NSString stringWithFormat:@"instagram-stories://share?source_application=%@", appID]];
    if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
        // Attach the pasteboard items
        NSArray *pasteboardItems = @[@{@"com.instagram.sharedSticker.backgroundImage" : backgroundImage}];
        // Set pasteboard options
        NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
        [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
        [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
    } else {
        // Handle error cases
    }
}
```

### iOS: Sharing a Sticker Asset

Default background color is `#222222` if no background colors specified.

```objective-c
- (void)shareStickerImage {
    NSString *const appIDString = @"1234567890";
    [self stickerImage:UIImagePNGRepresentation([UIImage imageNamed:@"stickerImage"])
    backgroundTopColor:@"#444444"
 backgroundBottomColor:@"#333333"
                 appID:appIDString];
}

- (void)stickerImage:(NSData *)stickerImage
  backgroundTopColor:(NSString *)backgroundTopColor
backgroundBottomColor:(NSString *)backgroundBottomColor
               appID:(NSString *)appID {
    NSURL *urlScheme = [NSURL URLWithString:[NSString stringWithFormat:@"instagram-stories://share?source_application=%@", appID]];
    if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
        NSArray *pasteboardItems = @[@{
            @"com.instagram.sharedSticker.stickerImage" : stickerImage,
            @"com.instagram.sharedSticker.backgroundTopColor" : backgroundTopColor,
            @"com.instagram.sharedSticker.backgroundBottomColor" : backgroundBottomColor
        }];
        NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
        [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
        [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
    } else {
        // Handle error cases
    }
}
```

### iOS: Sharing Background Asset and Sticker Asset

```objective-c
- (void)shareBackgroundAndStickerImage {
    NSString *const appIDString = @"1234567890";
    [self backgroundImage:UIImagePNGRepresentation([UIImage imageNamed:@"backgroundImage"])
             stickerImage:UIImagePNGRepresentation([UIImage imageNamed:@"stickerImage"])
                    appID:appIDString];
}

- (void)backgroundImage:(NSData *)backgroundImage stickerImage:(NSData *)stickerImage appID:(NSString *)appID {
    NSURL *urlScheme = [NSURL URLWithString:[NSString stringWithFormat:@"instagram-stories://share?source_application=%@", appID]];
    if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
        NSArray *pasteboardItems = @[@{
            @"com.instagram.sharedSticker.backgroundImage" : backgroundImage,
            @"com.instagram.sharedSticker.stickerImage" : stickerImage
        }];
        NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
        [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
        [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:nil];
    } else {
        // Handle error cases
    }
}
```

## Sharing to Facebook Stories

You can also allow your app's Users to share your content as a Facebook story. Refer to the Facebook Sharing to Stories documentation: https://developers.facebook.com/docs/sharing/sharing-to-stories
