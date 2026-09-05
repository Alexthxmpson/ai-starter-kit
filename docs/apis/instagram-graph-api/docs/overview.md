# Overview - Instagram Platform
**Source:** https://developers.facebook.com/docs/instagram-platform/overview
**Date:** 2026-03-01
**Note:** Original URL https://developers.facebook.com/docs/instagram-api/overview redirected to https://developers.facebook.com/docs/instagram-platform/overview

---

## Overview

The Instagram Platform is a collection of APIs that allows your app to access data for Instagram professional accounts including both businesses and creators. You can build an app that only serves your Instagram professional account, or you can build an app that serves other Instagram professional accounts that you do not own or manage.

There are two Instagram API configurations you can use in your app:

| Instagram API with Facebook Login for Business | Instagram API with Business Login for Instagram |
|---|---|
| Your app serves Instagram professional accounts that are linked to a Facebook Page | Your app serves Instagram professional accounts with a presence on Instagram only |
| Your app users use their Facebook credentials to log in to your app | Your app users use their Instagram credentials to log in to your app |

Depending on the configuration you choose, your app users will be able to have conversations with their customers or people interested in their Instagram professional account, moderate comments on their media, send private replies, publish content, publish ads, and get insights.

## Which API is right for my app?

| Component | Instagram API setup with Instagram Login | Instagram API setup with Facebook Login |
|---|---|---|
| Access token type | Instagram User | Facebook User or Page |
| Authorization type | Business Login for Instagram | Facebook Login for Business |
| Comment moderation | Yes | Yes |
| Content publishing | Yes | Yes |
| Facebook Page | Not required | Required |
| Hashtag search | No | Yes |
| Insights | Yes | Yes |
| Mentions | Yes | Yes |
| Messaging | Yes | via Messenger Platform |
| Product tagging | No | Yes |
| Partnership Ads | No | Yes |

Base URLs:
- Instagram Login apps: `graph.instagram.com`
- Facebook Login apps: `graph.facebook.com`

## Access Levels

There are two access levels available to your app: Standard Access and Advanced Access.

**Standard Access** — Default access level for all apps. Limits the data your app can get. Intended for apps that will only be used by people who have roles on them, during app development, or for testing. If your app only serves your Instagram professional account or an account you manage, Standard Access is sufficient.

**Advanced Access** — Required if your app serves Instagram professional accounts that you don't own or manage and can be used by app users who do not have a role on your app or a role on a business portfolio that has claimed your app. Requires App Review and Business Verification.

**Note:** Some features might not work properly until your app has been granted Advanced Access. This might limit the functionality of any test apps you use.

## App Review

Meta App Review enables Meta to verify that your app uses their products and APIs in an approved manner. Your app must complete Meta App Review to be granted Advanced Access.

### Private Apps

If reviewers are unable to test your app because it is behind a private intranet, has no user interface, or has not implemented Facebook Login for Business, you can request approval only for:
- `instagram_basic`
- `instagram_manage_comments`

## App Users

To use the APIs, your app users must have an Instagram professional account. An Instagram professional account can be for a business or creator.

Your app will also interact with Instagram users who interact with your app users' Instagram professional accounts. These interactions can happen through comments and reactions on your app users' Instagram comments, posts, reels, and stories, ads, and Instagram Direct.

## Authentication and Authorization

Endpoint authorization is handled through permissions and features. Before your app can use an endpoint to access an app user's Instagram professional account data, you must first request all permissions required by those endpoints from the app user.

**Login flow:**
1. App user clicks your embed URL → Meta opens authorization window → user grants permissions → Meta redirects to your redirect URI and sends an Authorization Code (valid 1 hour)
2. Exchange the authorization code for a short-lived access token (valid 1 hour)
3. Exchange short-lived token for a long-lived access token (valid 60 days, refreshable)

### Features and Permissions

| Instagram Login | Facebook Login |
|---|---|
| `instagram_business_basic` | `instagram_basic` |
| `instagram_business_content_publish` | `instagram_content_publish` |
| `instagram_business_manage_comments` | `instagram_manage_comments` |
| `instagram_business_manage_messages` | `instagram_manage_insights` |
| Human Agent | `instagram_manage_messages` |
| | `pages_show_list` |
| | `pages_read_engagement` |
| | Human Agent |
| | Instagram Public Content Access |

**Human Agent feature:** Allows a human agent to respond to user messages using the `human_agent` tag within 7 days of a user's message.

**Instagram Public Content Access feature:** Allows access to Instagram Graph API's Hashtag Search endpoints.

## Base URLs

- Apps using Business Login for Instagram (Instagram credentials): `graph.instagram.com`
- Apps using Facebook Login for Business (Facebook credentials): `graph.facebook.com`

## Business Verification

Required if your app requires Advanced Access — if your app will be used by app users who do not have a Role on the app itself, or a Role in a Business that has claimed the app.

## Comment Moderation

The API can:
- Get comments
- Reply to comments
- Delete comments
- Hide/unhide comments
- Disable/enable comments on media
- Identify media where the account has been @mentioned

## Content Publishing

Your app can publish:
- Single images
- Videos
- Reels (single media posts)
- Carousel posts (multiple images and videos)

### Content Delivery Network URLs

Instagram Platform uses CDN URLs to retrieve rich media content. CDN URLs are privacy-aware and will not return media when content has been deleted or has expired.

### Collaborators

*Facebook Login for Business only.*

Instagram Collaborator Tags allow Instagram users to co-author content and publish media with other accounts (collaborators). With few exceptions, data on co-authored media can only be accessed through the API by the user who published the media.

## Develop with Meta

Before integrating a Meta Technologies API, you must register as a Meta developer and create an app in the Meta App Dashboard.

Products to add depending on login type:

| | Business Login for Instagram | Facebook Login for Business |
|---|---|---|
| Products Required | Instagram > Instagram API setup with Instagram login | Facebook Login for Business + Messenger (Instagram settings) + Instagram > Instagram API setup with Facebook login |

### App IDs

- Apps using Facebook Login for Business: use the Meta app ID displayed at the top of the Meta App Dashboard
- Apps using Business Login for Instagram: use the Instagram app ID displayed on the **Instagram > API setup with Instagram login** section

## Facebook Pages

If your app implements Facebook Login for Business, your app users' Instagram professional accounts must be connected to a Facebook Page.

### Task → Permission Mapping

| Task name in UIs | Task name in API | Grantable Permissions |
|---|---|---|
| Ads | `PROFILE_PLUS_ADVERTISE` | `instagram_basic` |
| Content | `PROFILE_PLUS_CREATE_CONTENT` | `instagram_basic`, `instagram_content_publish` |
| Full control | `PROFILE_PLUS_FULL_CONTROL` | `instagram_basic`, `instagram_content_publish` |
| Insights | `PROFILE_PLUS_ANALYZE` | `instagram_basic`, `instagram_manage_insights` |
| Messages | `PROFILE_PLUS_MESSAGING` | `instagram_basic`, `instagram_manage_messages` |
| Community Activity | `PROFILE_PLUS_MODERATE` | `instagram_basic`, `instagram_manage_comments` |

## Scoped User IDs

**Instagram-scoped User IDs:** When an Instagram user comments on a post, reel, or story, or sends a message to an Instagram professional account, an Instagram-scoped User ID is created specific to that person and Instagram account interaction.

**Page-scoped User IDs:** When an Instagram user comments on a post, reel, or story, or sends a message to an Instagram professional account linked to a Facebook Page, a Page-scoped User ID is created specific to that person and Instagram account interaction.

## /me Endpoint

The `/me` endpoint translates to the object ID of the account (Facebook Page or Instagram professional account) whose access token is currently being used. It can also represent any ID, comments, conversations, media, posts, reels, and stories owned by the account.

## Messaging

An Instagram user sends a message to your app user's Instagram professional account. The message is delivered to the inbox and a webhook notification is sent to your server. Your app can respond within 24 hours. Use the human agent tag to send a response within 7 days if more time is needed.

### Instagram Inbox

Organized into: **Primary**, **General**, and **Requests** folders.
- New conversations from followers → Primary
- Messages from non-followers → Requests folder (not marked Seen until accepted)
- Replies via third-party app → moved to General folder

### Inbox Limitations

- Third-party app replies move conversation to General folder regardless of settings
- Inbox folders are not supported; messages delivered by Messenger Platform don't include folder info
- Webhooks/API messages not considered "Read" until a reply is sent

### Automated Experiences — Rate Limits

- Single App: custom inbox receives/replies from same messaging app
- Multiple Apps: Handover Protocol passes conversation between apps

## Policies

To gain and retain access to the Meta social graph, adhere to:
- Automated chats on Instagram
- Meta Platform Terms
- Developer Policies
- Community Standards
- Responsible Platform Initiatives

## Rate Limiting

All endpoints subject to Instagram Business Use Case rate limiting, except Business Discovery and Hashtag Search endpoints (subject to Platform Rate Limiting).

```
Calls within 24 hours = 4800 * Number of Impressions
```

Number of Impressions = number of times any content from the Instagram professional account has entered a person's screen within the last 24 hours.

### Messaging Rate Limits

**Conversations API:** 2 calls per second per Instagram professional account

**Private Replies API:**
- 100 calls per second per Instagram professional account (live comments)
- 750 calls per hour per Instagram professional account (posts and reels)

**Send API:**
- 100 calls per second (text, links, reactions, stickers)
- 10 calls per second (audio or video content)

## Webhooks

Strongly recommended to use webhooks to receive notifications about media objects or messages. Reduces API call count and rate limiting risk.

## Next Steps

Set up your webhooks server and subscribe to events.

## See Also

- Meta's Graph API: https://developers.facebook.com/docs/graph-api
- Messenger Platform: https://developers.facebook.com/docs/messenger-platform
- Instagram Platform API Reference: https://developers.facebook.com/docs/instagram-platform/reference
