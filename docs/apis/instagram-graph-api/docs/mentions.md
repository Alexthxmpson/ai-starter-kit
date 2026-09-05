# IG User Mentions - Instagram Platform
**Source:** https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/mentions
**Date:** 2026-03-01
**Note:** Original URL https://developers.facebook.com/docs/instagram-api/guides/mentions redirects here.

---

## IG User Mentions

This edge allows you to create an IG Comment on an IG Comment or captioned IG Media object that an IG User has been @mentioned in by another Instagram user.

---

## Creating

### Replying to a Captioned IG Media Object

**`POST /{ig-user-id}/mentions?media_id={media_id}&message={message}`**

Creates an IG Comment on an IG Media object in which an IG User has been @mentioned in a caption.

#### Limitations

- Mentions on Stories are not supported
- Commenting on photos in which you were tagged is not supported
- Webhooks will not be sent if the Media upon which the comment or @mention appears was created by an account that is set to private

#### Query String Parameters

- `{media_id}` (required) — the media ID contained in the Webhook notification payload
- `{message}` (required) — text to include in the comment

#### Permissions

A Facebook User access token with the following permissions:
- `instagram_basic`
- `instagram_manage_comments`
- `pages_read_engagement`

If the token is from a User whose Page role was granted via the Business Manager, one of the following is also required:
- `ads_management`
- `ads_read`

#### Sample Request

```bash
curl -i -X POST \
  -d "media_id=17920112008063024" \
  -d "message=Thanks%20for%20the%20dinosaur!" \
  -d "access_token=a-valid-access-token-goes-here" \
  "https://graph.facebook.com/17841405309211844/mentions"
```

#### Sample Response

```json
{ "id": "17846319838228163" }
```

---

### Replying to a Comment

**`POST /{ig-user-id}/mentions?media_id={media_id}&comment_id={comment_id}&message={message}`**

Creates an IG Comment on an IG Comment in which an IG User has been @mentioned.

#### Limitations

- Mentions on Stories are not supported
- Commenting on photos in which you were tagged is not supported
- Webhooks will not be sent if the Media upon which the comment or @mention appears was created by an account that is set to private

#### Query String Parameters

- `{comment_id}` (required) — the comment ID contained in the Webhook notification payload
- `{media_id}` (required) — the media ID contained in the Webhook notification payload
- `{message}` (required) — text to include in the comment

#### Permissions

A Facebook User access token with the following permissions:
- `instagram_basic`
- `instagram_manage_comments`
- `pages_read_engagement`
- `pages_show_list`

If the token is from a User whose Page role was granted via the Business Manager, one of the following is also required:
- `ads_management`
- `ads_read`

#### Sample Request

```bash
curl -i -X POST \
  -d "media_id=17920112008063024" \
  -d "comment_id=17918718562020960" \
  -d "message=Hope%20you%20enjoy%20your%20new%20T-Rex!" \
  -d "access_token=a-valid-access-token-goes-here" \
  "https://graph.facebook.com/17841405309211844/mentions"
```

#### Sample Response

```json
{ "id": "17846319838254687" }
```

---

## Reading

This operation is not supported.

## Updating

This operation is not supported.

## Deleting

This operation is not supported.
