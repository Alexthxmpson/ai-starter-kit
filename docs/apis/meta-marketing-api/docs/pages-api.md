# Facebook Pages API

**Source:** https://developers.facebook.com/docs/pages-api
**Date:** 2026-03-01

---

## Overview

The Facebook Pages API from Meta allows apps to access and update a Facebook Page's settings and content, create and get Posts, get Comments on Page owned content, get Page insights, update actions that Users are able to perform on a Page, and much more.

---

## Documentation Contents

Recommended reading order:

| Guide | Description |
|-------|-------------|
| [Overview](https://developers.facebook.com/docs/pages/overview) | Learn about the components of the Pages API and how it works. |
| [Getting Started](https://developers.facebook.com/docs/pages/getting-started) | An introductory tutorial showing you how to publish a post to your Facebook Page. |
| [Manage a Page](https://developers.facebook.com/docs/pages/managing) | Get a list of your Pages with tasks you can perform on each and Page access tokens, and update Page settings. |
| [Posts and Comments](https://developers.facebook.com/docs/pages/publishing) | Create, publish, update, and delete Page posts and comments. |
| [Page Insights](https://developers.facebook.com/docs/platforminsights/page) | Get insights into your Page posts. |
| [Pages Search](https://developers.facebook.com/docs/pages/searching) | Search for Pages. |
| [Page Tabs](https://developers.facebook.com/docs/pages/tabs) | Get list of tabs for your Page. |
| [Meta Webhooks](https://developers.facebook.com/docs/pages/webhooks) | Get real-time notifications sent to your server for events that happen on your Page. |
| [Upcoming Changes](https://developers.facebook.com/docs/pages/upcoming-changes) | Get notifications about upcoming changes Meta will be implementing on your Page. |
| [Error Codes](https://developers.facebook.com/docs/pages/error-codes) | View error codes and their description for errors you may encounter. |
| [Changelog](https://developers.facebook.com/docs/pages/changelog) | View the log of changes for the Pages API. |

---

## Sidebar Sections

The Pages API documentation covers:

- Overview
- Create an app
- Webhooks
- Get Started
- Manage a Page
- Upcoming Changes
- Comments and @Mentions
- Posts
- Page Integrity API & Webhook
- Insights
- Pages Search
- Error Codes
- Changelog

---

## Relationship to Marketing API

The Pages API is used alongside the Marketing API when:

- Creating ad creatives that use Page posts (`object_story_id`)
- Managing the Page that backs your ads
- Setting up Instagram-connected Pages for Instagram ads
- Creating organic page posts that are then promoted as ads

To link a Page to ad creative, use the `page_id` field in the `object_story_spec` when creating ad creatives.

---

## Related Resources

- [Marketing API — Ad Creative](https://developers.facebook.com/docs/marketing-api/creative)
- [Marketing API — Overview](https://developers.facebook.com/docs/marketing-api/overview)
- [Graph API — Pages](https://developers.facebook.com/docs/graph-api/reference/page/)
