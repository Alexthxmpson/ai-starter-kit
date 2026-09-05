# Create a token

**Source:** https://developers.notion.com/reference/create-a-token
**Date:** 2026-03-01

---

Creates an access token that a third-party service can use to authenticate with Notion.

For step-by-step instructions on how to use this endpoint to create a public integration, check out the Authorization guide. To walkthrough how to create tokens for Link Previews, refer to the Link Previews guide.

## Endpoint

```
POST /v1/oauth/token
```

## Authentication

**Authorization** (header, required): Basic authentication of the form `Basic <encoded-value>`, where `<encoded-value>` is the base64-encoded string `username:password`.

For OAuth token creation, the `username` is your OAuth `client_id` and the `password` is your `client_secret`.

## Headers

| Header | Type | Required | Description |
|--------|------|----------|-------------|
| `Notion-Version` | `enum<string>` | required | The API version. Latest: `2025-09-03` |

## Request body (application/json)

### Option 1: Authorization code grant

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `grant_type` | `string` | required | Must be `"authorization_code"` |
| `code` | `string` | required | The authorization code received from the OAuth flow |
| `redirect_uri` | `string` | | The redirect URI used during authorization (see requirements below) |
| `external_account` | `object` | | External account information |

### Option 2: Other grant types

The endpoint also supports other grant type options.

### redirect_uri requirements for public integrations

The `redirect_uri` is **required** if:
- The `redirect_uri` query parameter was set in the Authorization URL provided to users, OR
- There are more than one `redirect_uri`s included in the integration's settings under **OAuth Domain & URIs**.

The `redirect_uri` field is **NOT allowed** if:
- There is one `redirect_uri` included in the integration's settings under OAuth Domain & URIs, AND the `redirect_uri` query parameter was NOT included in the Authorization URL.

## Code sample

```javascript
import { Client } from "@notionhq/client"
const notion = new Client()
const response = await notion.oauth.token({
  client_id: process.env.OAUTH_CLIENT_ID,
  client_secret: process.env.OAUTH_CLIENT_SECRET,
  grant_type: "authorization_code",
  code: "abc123-authorization-code",
  redirect_uri: "https://example.com/callback"
})
```

## Response (200)

```json
{
  "access_token": "<string>",
  "token_type": "bearer",
  "refresh_token": "<string>",
  "bot_id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
  "workspace_icon": "<string>",
  "workspace_name": "<string>",
  "workspace_id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
  "owner": {
    "type": "<string>",
    "user": {
      "type": "<string>",
      "person": {
        "email": "<string>"
      },
      "name": "<string>",
      "avatar_url": "<string>",
      "id": "<string>",
      "object": "<string>"
    }
  },
  "duplicated_template_id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
  "request_id": "3c90c3cc-0d44-4b50-8888-8dd25736052a"
}
```

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `access_token` | `string` | The access token to use for API requests |
| `token_type` | `string` | Always `"bearer"` |
| `refresh_token` | `string \| null` | The refresh token (if applicable) |
| `bot_id` | `string<uuid>` | The bot user ID associated with this token |
| `workspace_icon` | `string \| null` | Icon URL for the workspace |
| `workspace_name` | `string \| null` | Name of the workspace |
| `workspace_id` | `string<uuid>` | ID of the workspace |
| `owner` | `User object` | The user or workspace that authorized the integration |
| `duplicated_template_id` | `string<uuid> \| null` | If a template was duplicated during authorization |
| `request_id` | `string<uuid>` | The ID of the request |

## Errors

Each Public API endpoint can return several possible error codes. See the Error codes section of the Status codes documentation for more information.
