# Close CRM API Documentation — Topics Reference

> **Source**: https://developer.close.com
> **Date scraped**: 2026-03-30
> **Coverage**: Introduction + all 11 topic pages from the Getting Started section

---

## Introduction

Welcome to the Close REST API specification. Close empowers our customers to scale their Close instance by providing helpful documentation around our API. You can use this information to build robust integrations and get even more value out of Close.

Close uses industry-standard REST conventions to build our APIs. The benefits of this are many standard HTTP features, predictable URL structures, and standardized response codes.

Our Support Team can assist Close customers with any questions you may have about our API. Email: support@close.com

Implementing something cool, want to share your feedback or just want to chat about where our API is going? Joe Kemp, VP of Engineering, would love to hear your thoughts. Use the Calendly link on the docs site to schedule a chat with him.

Want a behind the scenes look at how we build Close? Check out the "Making of Close" blog.

### API Base URL

```
https://api.close.com/api/v1
```

### Getting Started Topics

1. Authentication with API keys
2. Authentication with OAuth
3. Specifying Filter Parameters
4. Timezone Offsets
5. Fields
6. Updating Specific Fields
7. Pagination
8. Webhooks
9. Rate Limits
10. HTTP Response Codes
11. API Clients

### Available Resources (Endpoints)

- Leads
- Contacts
- Activities (Email, Call, SMS, Meeting, Note, Lead Status Change, Opportunity Status Change, Task Completed, Created, Custom Activity, and more)
- Opportunities
- Tasks
- Users
- Organizations
- Custom Fields
- Custom Objects
- Webhook Subscriptions
- Event Log
- Export API
- Advanced Filtering API
- And many more administrative resources

---

## Authentication with API Keys

**URL**: https://developer.close.com/topics/authentication/

API keys are best used for scripts and simple integrations that are internal to your organization. If you need to register and authenticate a public application, see Authentication with OAuth instead.

### Perform API calls with API key

API keys use HTTP Basic client side authentication. Basic authentication is a simple authentication scheme built into the HTTP protocol. To use it, send your HTTP requests with an `Authorization` header that contains the word `Basic` followed by a space and a base64-encoded string composed of an API key followed by a colon. The API key acts as the username and the password is always empty. API keys are per-organization and can be generated and deleted in the Settings page. See the API Keys FAQ for more information.

### Example cURL request with an API key

```bash
curl https://api.close.com/api/v1/me/ -u yourapikey:
```

Notice the `:` at the end of the API key. This is used because the key is sent as the username with a blank password.

### Raw HTTP request

```text
GET /api/v1/me/ HTTP/1.1
Authorization: Basic eW91cmFwaWtleTo=
Host: api.close.com
```

This results in the header `Authorization: Basic eW91cmFwaWtleTo=` sent with the request as base64-encoded string `yourapikey:` is `eW91cmFwaWtleTo=`.

### API Base URL

```
https://api.close.com/api/v1
```

### Key Management

API keys are per-organization and can be generated and deleted in the Settings page. See the API Keys FAQ for more information.

---

## Authentication with OAuth

**URL**: https://developer.close.com/topics/authentication-oauth2/

To start integrating with Close using OAuth 2.0, a developer must have a Close account and acquire its own credentials, a `client_id` and `client_secret`. Those can be obtained by accessing the Settings page, navigating to **Developer -> OAuth Apps**, clicking the **Create App** button and filling in the form. You should also implement a redirect URI where the user is redirected after the authorization. In the examples below we use `https://example.com/callback/close`.

### Authorization

First you need to have your application redirect the user to Close's authorization page with the `client_id` and `redirect_uri`.

```text
https://app.close.com/oauth2/authorize/?client_id=CLIENT_ID&response_type=code
```

The user will be presented with a Consent Screen and be able to select an organization and grant or decline access. If the user chooses to grant access, their browser is redirected to that OAuth App's `redirect_uri`, the Authorization Code is passed inside the `code` query parameter.

```text
https://example.com/callback/close?code=CODE
```

If the user chooses to decline access instead, their browser is redirected to the same `redirect_uri` with error information in query parameters.

```text
https://example.com/callback/close?error=access_denied
```

### Obtain Access Token

The Authorization Code can be exchanged for an Access Token by performing a POST request with form-encoded parameters to `https://api.close.com/oauth2/token/`

```text
POST /oauth2/token/ HTTP/1.1
Content-Type: application/x-www-form-urlencoded
Host: api.close.com

client_id=CLIENT_ID&client_secret=CLIENT_SECRET&grant_type=authorization_code&code=CODE
```

You will get the following JSON response:

```json
{
  "token_type": "Bearer",
  "access_token": "ACCESS_TOKEN",
  "expires_in": 3600,
  "refresh_token": "REFRESH_TOKEN",
  "scope": "all.full_access offline_access",
  "organization_id": "ORGANIZATION_ID",
  "user_id": "USER_ID"
}
```

Notice that the Access Token has a limited lifetime and expires in `expires_in` seconds from the moment it was issued. If your application has `offline_access` scope, the `refresh_token` property will be present in the response and you can refresh the Access Token (see below).

### OAuth2 Endpoints Summary

| Endpoint | URL | Method |
|----------|-----|--------|
| Authorization | `https://app.close.com/oauth2/authorize/` | GET (redirect) |
| Token Exchange | `https://api.close.com/oauth2/token/` | POST |
| Token Refresh | `https://api.close.com/oauth2/token/` | POST |
| Token Revocation | `https://api.close.com/oauth2/revoke/` | POST |

### Authorization Endpoint Parameters

| Parameter | Required | Value |
|-----------|----------|-------|
| `client_id` | Yes | Your OAuth app client ID |
| `response_type` | Yes | `code` |
| `redirect_uri` | Yes | Configured in OAuth app settings |

### Token Exchange Parameters

| Parameter | Required | Value |
|-----------|----------|-------|
| `client_id` | Yes | Your OAuth app client ID |
| `client_secret` | Yes | Your OAuth app client secret |
| `grant_type` | Yes | `authorization_code` |
| `code` | Yes | Authorization code from redirect |

### Token Response Fields

| Field | Description |
|-------|-------------|
| `token_type` | Always `"Bearer"` |
| `access_token` | The access token to use for API calls |
| `expires_in` | Token lifetime in seconds (3600 = 1 hour) |
| `refresh_token` | Token for refreshing access (requires `offline_access` scope) |
| `scope` | Granted scopes, e.g. `"all.full_access offline_access"` |
| `organization_id` | The organization the user granted access to |
| `user_id` | The user who granted access |

### Perform API calls with Access Token

Send your HTTP requests with an `Authorization` header that contains the word `Bearer` followed by a space and the Access Token.

Example using cURL:

```bash
curl https://api.close.com/api/v1/me/ -H "Authorization: Bearer ACCESS_TOKEN"
```

Which results in the following request:

```text
GET /api/v1/me/ HTTP/1.1
Authorization: Bearer ACCESS_TOKEN
Host: api.close.com
```

### Refresh Access Token

If your application has an `offline_access` scope you can refresh the Access Token using the Refresh Token obtained before by performing a POST request with form-encoded parameters to `https://api.close.com/oauth2/token/`

```text
POST /oauth2/token/ HTTP/1.1
Content-Type: application/x-www-form-urlencoded
Host: api.close.com

client_id=CLIENT_ID&client_secret=CLIENT_SECRET&grant_type=refresh_token&refresh_token=REFRESH_TOKEN
```

You will get the following JSON response:

```json
{
  "token_type": "Bearer",
  "access_token": "ACCESS_TOKEN",
  "expires_in": 3600,
  "refresh_token": "REFRESH_TOKEN",
  "scope": "all.full_access offline_access",
  "organization_id": "ORGANIZATION_ID",
  "user_id": "USER_ID"
}
```

**Important**: The authorization server issues a new Refresh Token and the client must discard the old Refresh Token and replace it with the new one. The authorization server revokes the old Refresh Token after issuing a new one.

### Token Refresh Parameters

| Parameter | Required | Value |
|-----------|----------|-------|
| `client_id` | Yes | Your OAuth app client ID |
| `client_secret` | Yes | Your OAuth app client secret |
| `grant_type` | Yes | `refresh_token` |
| `refresh_token` | Yes | The current refresh token |

### Revoke Application Access

It's a good security practice to revoke Access and Refresh Tokens immediately if the user chooses to disable the integration with Close. You can accomplish this by performing a POST request with form-encoded parameters to `https://api.close.com/oauth2/revoke/`.

```text
POST /oauth2/revoke/ HTTP/1.1
Content-Type: application/x-www-form-urlencoded
Host: api.close.com

client_id=CLIENT_ID&client_secret=CLIENT_SECRET&token=REFRESH_TOKEN
```

### Revocation Parameters

| Parameter | Required | Value |
|-----------|----------|-------|
| `client_id` | Yes | Your OAuth app client ID |
| `client_secret` | Yes | Your OAuth app client secret |
| `token` | Yes | The refresh token to revoke |

---

## Specifying Filter Parameters

**URL**: https://developer.close.com/topics/specifying-filter-parameters/

Many resources accept filters and other parameters which can be simply passed in the GET query string. However, in certain cases, like filtering by a long list of IDs, URLs can potentially exceed the recommended maximum URL length (2000 characters). To prevent problems with long URLs, parameters can also be specified in a JSON-encoded dictionary in the request body under the `_params` key. Since GET requests with a request body are against the specification, we support the `x-http-method-override` HTTP header that lets you override the request method.

For example, the following two requests are equivalent:

### Method 1: POST with method override header

```bash
curl -X POST
     -u apikey:
     -H 'content-type: application/json'
     -H 'x-http-method-override: GET'
     -d '{"_params": { "lead_id": "THE_LEAD_ID" }}'
     https://api.close.com/api/v1/activity/
```

### Method 2: Standard GET with query string

```bash
curl -u apikey: https://api.close.com/api/v1/activity/?lead_id=THE_LEAD_ID
```

### Notes

- The `x-http-method-override` header can also be used for clients that have issues with request methods other than GET and POST.
- Parameters are passed as a JSON object under the `_params` key in the request body.
- The `Content-Type` header must be set to `application/json` when using the body method.

---

## Timezone Offsets

**URL**: https://developer.close.com/topics/timezone-offsets/

For requests that include date filters like `date_created` or `date_start`, you can use the `x-tz-offset` HTTP header to pass your timezone's UTC offset as part of your request. Including this header in your request lets you retrieve search results, run reports, and schedule emails and SMS relative to your timezone. This can be especially important when requesting an activity report that you want to match to what you see in Close or when running a query via the Advanced Filtering API where your query has a relative date (i.e. Leads Created Today).

### Standard Offset Example

For EDT (UTC-4:00), include the following header in your request:

```bash
-H 'x-tz-offset: -4'
```

### Half-Hour Offset Example

For timezones like NDT (UTC-2:30) that have half-hour offsets, include a `.5` in the header:

```bash
-H 'x-tz-offset: -2.5'
```

### When to Use

- Activity reports that should match what you see in Close
- Queries via the Advanced Filtering API with relative dates (e.g., "Leads Created Today")
- Scheduling emails and SMS relative to your timezone
- Any request with date filters like `date_created` or `date_start`

---

## Fields

**URL**: https://developer.close.com/topics/fields/

Most endpoints support a `_fields` parameter that lets you specify which fields you require in the response. For example, if you only need `id` and `display_name` when listing Leads, add `?_fields=id,display_name` to the URL. This will improve performance of your API calls.

### Usage Example

```
GET /api/v1/lead/?_fields=id,display_name
```

This returns only the `id` and `display_name` fields for each lead, rather than the full object.

### Syntax

- Pass field names as a comma-separated list: `?_fields=field1,field2,field3`
- Append to the URL as a query parameter

### Important Warning

In some cases, an API response can include fields that are not listed in the sample response for that endpoint below. **Non-custom fields that are not included in the sample response for an endpoint should not be used in integrations, as they may change without warning.**

---

## Updating Specific Fields

**URL**: https://developer.close.com/topics/updating-specific-fields/

In the Close API, every `PUT` request behaves as a patch. What it means is that you don't need to send all the fields with every request. For example, if only the `title` field changed for a specific Contact, there's no need to include the `name` field in the request.

### Key Points

- `PUT` requests are patch-like: only send the fields you want to update
- You do NOT need to include unchanged fields in the request body
- Only the fields you include in the `PUT` body will be updated; all other fields remain unchanged

---

## Pagination

**URL**: https://developer.close.com/topics/pagination/

Close API uses two different pagination methods depending on the endpoint. Most list endpoints use offset-based pagination, while some specialized endpoints use cursor-based pagination.

### Offset-Based Pagination

Most list endpoints (e.g., `/api/v1/lead/`, `/api/v1/contact/`) use `_limit` and `_skip` parameters to paginate through results. For example, the first three pages for the lead resource (100 records per page) are:

| Page | URL |
|------|-----|
| Page 1 | `/api/v1/lead/?_skip=0&_limit=100` |
| Page 2 | `/api/v1/lead/?_skip=100&_limit=100` |
| Page 3 | `/api/v1/lead/?_skip=200&_limit=100` |

#### Parameters

| Parameter | Description |
|-----------|-------------|
| `_skip` | Number of records to skip (offset). Starts at 0. |
| `_limit` | Number of records to return per page. |

#### Response Format

The response contains two fields:

| Field | Type | Description |
|-------|------|-------------|
| `data` | array | The list of objects for the current page |
| `has_more` | boolean | Indicates if there are more pages after this one |

Additionally, there is a maximum limit that can vary per resource. You will get a 400 response with an appropriate message if you exceed it.

### Deep Pagination

If you're planning to iterate through a long list of results (for example, all leads, contacts, or activities within your organization), doing so using `_skip` and `_limit` is going to be inefficient at best or outright impossible at worst. Close API has a maximum `_skip` limit which varies per resource.

If you need to paginate for more than a few pages, update your query to return smaller batches of objects. A popular method to do this is to use the `date_created` field as a range, and make multiple requests while incrementing or decrementing the date.

Another option for extracting a larger portion of your data out of Close efficiently is to request its export via the **Export API**.

### Cursor-Based Pagination

Some endpoints use cursor-based pagination instead of offset-based. With cursors, you pass a cursor token from the previous response to fetch the next page of results. This avoids issues with data changing between requests.

The following endpoints use cursor-based pagination:

| Endpoint | Cursor Parameter | Limit Parameter |
|----------|-----------------|-----------------|
| Advanced Filtering API | `cursor` (in request body) | `_limit` (in request body) |
| Events API | `_cursor` (query parameter) | `_limit` (query parameter) |

See each endpoint's documentation for specific pagination details.

---

## Webhooks

**URL**: https://developer.close.com/topics/webhooks/

Webhooks allow a subscription URL to be configured that we will POST event data to as it is added to the Event Log. Each subscription is configured to trigger when an event matches a set of object types and actions.

### Example Webhook Payload

Here is an example of the Webhook data for an opportunity that was won. This would be sent to the URL you provide using a `POST` request:

```json
{
  "event": {
    "date_created": "2019-01-15T12:48:23.395000",
    "meta": {
      "request_method": "PUT",
      "request_path": "/api/v1/opportunity/oppo_7H4sjNso7FyBFaeR3RXi5PMJbilfo0c6UPCxsJtEhCO/"
    },
    "id": "ev_2sYKRjcrA79yKxi3S4Crd7",
    "action": "updated",
    "date_updated": "2019-01-15T12:48:23.395000",
    "changed_fields": [
      "confidence",
      "date_updated",
      "status_id",
      "status_label",
      "status_type"
    ],
    "previous_data": {
      "status_type": "active",
      "confidence": 70,
      "date_updated": "2019-01-15T12:47:39.873000+00:00",
      "status_id": "stat_3FD9DnGUCJzccBKTh8LiiKoyVPpMJsOkJdcGoA5AYKH",
      "status_label": "Active"
    },
    "organization_id": "orga_XbVPx5fFbKlYTz9PW5Ih1XDhViV10YihIaEgMEb6fVW",
    "data": {
      "contact_name": "Mr. Jones",
      "user_name": "Joe Kemp",
      "value_period": "one_time",
      "updated_by_name": "Joe Kemp",
      "date_created": "2019-01-15T12:41:24.496000+00:00",
      "user_id": "user_N6KhMpzHRCYQHdn4gRNIFNN5JExnsrprKA6ekxM63XA",
      "updated_by": "user_N6KhMpzHRCYQHdn4gRNIFNN5JExnsrprKA6ekxM63XA",
      "value_currency": "USD",
      "organization_id": "orga_XbVPx5fFbKlYTz9PW5Ih1XDhViV10YihIaEgMEb6fVW",
      "status_label": "Won",
      "contact_id": "cont_BwlwYQkIP6AooiXP1CMvc6Zbb5gGh2gPu4dqIDlDrII",
      "status_type": "won",
      "created_by_name": "Joe Kemp",
      "id": "oppo_8H4sjNso7FyBFaeR3RXi5PMJbilfo0c6UPCxsJtEhCO",
      "lead_name": "KLine",
      "date_lost": null,
      "note": "",
      "date_updated": "2019-01-15T12:48:23.392000+00:00",
      "status_id": "stat_wMS9M6HC2O3CSEOzF5g2vEGt6RM5R3RfhIQixdnmjf2",
      "value": 100000,
      "created_by": "user_N6KhMpzHRCYQHdn4gRNIFNN5JExnsrprKA6ekxM63XA",
      "value_formatted": "$1,000",
      "date_won": "2019-01-15",
      "lead_id": "lead_zwqYhEFwzPyfCErS8uQ77is2wFLvr9BgVi6cTfbFM68",
      "confidence": 100
    },
    "request_id": "req_4S2L8JTBAA1OUS74SVmfbN",
    "object_id": "oppo_7H4sjNso7FyBFaeR3RXi5PMJbilfo0c6UPCxsJtEhCO",
    "user_id": "user_N6KhMpzHRCYQHdn4gRNIFNN5JExnsrprKA6ekxM63XA",
    "object_type": "opportunity",
    "lead_id": "lead_zwqYhEFwzPyfCErS8uQ77is2wFLvr9BgVi6cTfbFM68"
  },
  "subscription_id": "whsub_8AmjKCZYT3zI8eZoi4HhFC"
}
```

### Webhook Event Fields

| Field | Description |
|-------|-------------|
| `event.id` | Unique event ID (e.g., `ev_2sYKRjcrA79yKxi3S4Crd7`) |
| `event.date_created` | Timestamp of the event |
| `event.date_updated` | Timestamp of the event update |
| `event.action` | The action that triggered the event (e.g., `created`, `updated`, `deleted`) |
| `event.object_type` | Type of object (e.g., `opportunity`, `lead`, `contact`) |
| `event.object_id` | ID of the affected object |
| `event.changed_fields` | Array of field names that changed (for `updated` actions) |
| `event.previous_data` | Object containing previous values of changed fields |
| `event.data` | Object containing the current state of the resource |
| `event.organization_id` | Organization ID |
| `event.user_id` | User who triggered the event |
| `event.lead_id` | Associated lead ID (if applicable) |
| `event.request_id` | Request ID that caused the event |
| `event.meta.request_method` | HTTP method of the originating request |
| `event.meta.request_path` | URL path of the originating request |
| `subscription_id` | The webhook subscription that matched this event |

### Webhook Delivery

#### Retry Logic

Failed deliveries are retried with a retry interval that exponentially backs off up to every 20 minutes. They will be retried up to 72 hours before being dropped.

#### Event Ordering

Event ordering is not guaranteed due to event consolidation, parallelism, and retries.

#### Automatic Pausing

A subscription will automatically be paused and its queue cleared when one of the following happens:

- **Event queue reaches 100,000 backlogged events.** Warning emails will be sent to admins when there are more than 80,000 backlogged events.
- **All event delivery fails for 3 days.** Warning emails will be sent to admins before the subscription is paused.

Paused subscriptions require manual reactivation via the API.

#### Consolidation

For `updated` or `deleted` actions, webhooks fire after a consolidation delay. Event updates are written immediately to the event log during the consolidation period so if you query the event log directly you may see events that you haven't received a webhook notification for yet.

#### Recommendations

- Process webhooks asynchronously by queuing locally first
- Access historical events via the Event Log API (up to 30 days)

### Data Management

- Users with the Admin role can manage subscriptions for all users in the organization. Non-admin users can only modify subscriptions created by them.
- All data is delivered in the Webhook event even for non-admin users since they would have access to the same data via the application at delivery time.
- We recommend using HTTPS to protect your data during delivery. SSL certificate validation is enabled by default but can be disabled via the `verify_ssl` field.

### Webhook Signatures

The subscription API's POST response includes a `signature_key` value that will be used to sign Webhooks for the subscription. The signature and signing timestamp is available in the following two headers of each POST request to your endpoint.

#### Signature Headers

```
close-sig-hash: aa4fea8d4b74a0790e6b0dc2214db9d4d7651cb3e23f53caea499defd71ee431
close-sig-timestamp: 1544271440
```

The signature in the `close-sig-hash` header is the sha256 HMAC of the `close-sig-timestamp` and payload concatenated.

#### Python 3 Signature Verification Example

```python
import hmac
import hashlib

key = '058bfb6a3d8cfdc4da7c3be5901b16ae11da982b46a25fb2cd7016e97a140a1c'
data = headers['close-sig-timestamp'] + payload
signature = hmac.new(bytearray.fromhex(key), data.encode('utf-8'), hashlib.sha256).hexdigest()
valid = hmac.compare_digest(headers['close-sig-hash'], signature)  # Will be True if sigs match
```

**Note**: The `key` value is the `signature_key` returned when you create a webhook subscription via the Subscription API.

### Subscription Management

See the [Subscription API](https://developer.close.com/resources/webhook-subscriptions/) documentation for the details of managing Webhook subscriptions.

### Limits

The maximum number of webhook subscriptions per organization is **40**.

However, a higher limit of webhook subscriptions (up to a total of **500 subscriptions**) is allowed for specific automation platforms:

- Zapier
- Backendless
- Integrately
- Customer.io Journeys Track API

---

## Rate Limits

**URL**: https://developer.close.com/topics/rate-limits/

We enforce API call rate limits to protect our infrastructure from excessive request rates, to keep Close fast and stable for everyone. These limits are high enough that typical API workflows aren't affected. However, please do code your integration to follow the rule below:

**If you receive a response status code of 429 (Too Many Requests), please sleep/pause for the number of seconds specified by the `rate_reset` value before making additional requests to that endpoint.** See below for the specific response format.

### Rate Limit Enforcement

Rate limits are enforced per **endpoint group**. Endpoint groups are used to provide more granular control by grouping endpoint URL paths and methods (e.g. GET, PUT, etc.) together. For instance, GETs to `/api/v1/lead/` and POSTs/PUTs to `/api/v1/activity/` may be counted as two different API groups. This allows us to offer a higher limit on lightweight requests than we would be able to on more resource intensive request types.

### Organization vs. API Key Limits

API requests are limited at a per Organization level across all users' API keys. We also enforce a lower rate limit per API key, which helps ensure that an individual heavy integration doesn't cause other lightweight integrations (on separate API keys) to get rate limited unnecessarily.

The per Organization limit is currently **3 times higher** than individual API key rate limits, meaning that:

| Level | Example Limit |
|-------|---------------|
| Per API Key | 20 RPS (requests per second) |
| Per Organization | 60 RPS (3x the per-key limit) |

This allows you to use 3 API keys at their maximum RPS and not hit the Organization rate limit until you add a 4th key making additional requests. The 429 response provides details to identify which limit and endpoint group was hit.

### RateLimit Response Header

Most API responses will have the `RateLimit` header to provide rate limiting statistics about the limit it's closest to hitting. Per the RFC spec, this header will contain three values:

| Value | Description |
|-------|-------------|
| `limit` | Request limit enforced for this endpoint; some endpoints may allow bursting over this limit |
| `remaining` | Requests left in the enforcement window |
| `reset` | Seconds remaining before this enforcement window ends (as a decimal) |

#### Example Header

```text
RateLimit: limit=100, remaining=50, reset=5
```

### 429 Response Handling

Each `429` response is guaranteed to have the `RateLimit` header set as well as the `retry-after` header as per RFC 7231 (equivalent to `x-rate-limit-reset` rounded up to the next integer).

**Note**: Previously data was provided in the response body, however that information should be gathered from the `RateLimit` header instead.

**Recommendation**: Use the `rate_reset` value instead of the `retry-after` header for a more accurate wait time.

### Special / Stricter Rate Limits

Some API endpoints may have stricter (unpredictable) rate limits and may trigger a 429 even if the user agent places requests within the enforcement window. In these scenarios only the `rate_reset` values and `retry-after` header may be set.

### Deprecated Headers

Previously the following rate limit headers were included, however they have been replaced by the single `RateLimit` header:

| Deprecated Header | Replaced By |
|-------------------|-------------|
| `x-rate-limit-limit` | `RateLimit: limit=...` |
| `x-rate-limit-remaining` | `RateLimit: remaining=...` |
| `x-rate-limit-reset` | `RateLimit: reset=...` |

---

## HTTP Response Codes

**URL**: https://developer.close.com/topics/http-response-codes/

The following HTTP codes are used in the responses:

| Code | Description |
|------|-------------|
| `200` | When the request was successful. |
| `400` | When there was an issue with the request. |
| `401` | When the request needs to be authenticated. |
| `402` | When the request could not be completed, because a limit of your current plan was reached. |
| `403` | When an operation was not allowed. |
| `404` | When the URL was not found. |
| `405` | When the HTTP method was not supported. |
| `415` | When the request used an unsupported format. |

**Note**: The `429` (Too Many Requests) status code is documented separately in the Rate Limits topic. Server error codes (5xx) are not explicitly listed in the documentation.

---

## API Clients

**URL**: https://developer.close.com/topics/api-clients/

The Close REST API is usable in any programming language that can send HTTP requests and handle HTTP responses. To make development using our API easier, some awesome contributors have helped us develop numerous API Clients for multiple programming languages. Check them out below:

### Python

| Library | Link | Maintainer |
|---------|------|------------|
| Close's Python Wrapper | https://github.com/closeio/closeio-api | Close (Official) |

### Ruby

| Library | Link |
|---------|------|
| Simple Example using REST Client | https://gist.github.com/philfreo/9359930 |
| Taylor Brooks' Close Ruby Wrapper | https://github.com/taylorbrooks/closeio |

### PHP

| Library | Link |
|---------|------|
| Simple Example using Ryan McCue's Requests Library | https://gist.github.com/philfreo/5406540 |
| Loopline Systems' Close API Wrapper | https://github.com/loopline-systems/closeio-api-wrapper |
| Geoff Wagstaff's Close API SDK | https://github.com/TheDeveloper/closeio-php-sdk |
| Benjamin Gyuro's Close API Client for Laravel | https://github.com/gyurobenjamin/closeio-laravel-api |

### Node.js

| Library | Link | Maintainer |
|---------|------|------------|
| Close's Node.js Wrapper | https://github.com/closeio/closeio-node | Close (Official) |

### C#

| Library | Link |
|---------|------|
| More Than Rewards' Close .NET Library | https://github.com/MoreThanRewards/CloseIoDotNet |

### Elixir

| Library | Link |
|---------|------|
| Nested's Closex Library | https://github.com/nested-tech/closex |
| Taylor Brooks' ExClose Library | https://github.com/taylorbrooks/ex_closeio |

### Go

| Library | Link |
|---------|------|
| Recare's Close Golang Client | https://github.com/veyo-care/closeio-golang-client |
| Analytical Flavor Systems' Close API Wrapper | https://github.com/AnalyticalFlavorSystems/closeio-go |

### Contributing

If you've developed a Close API Client and want to be included on this list, please reach out to **support@close.com**.

---

## Quick Reference

### Authentication Methods

| Method | Use Case | Header Format |
|--------|----------|---------------|
| API Key (Basic Auth) | Internal scripts & simple integrations | `Authorization: Basic base64(apikey:)` |
| OAuth 2.0 (Bearer Token) | Public applications | `Authorization: Bearer ACCESS_TOKEN` |

### Important Headers

| Header | Purpose |
|--------|---------|
| `Authorization` | Authentication (Basic or Bearer) |
| `Content-Type` | Request body format (usually `application/json`) |
| `x-http-method-override` | Override HTTP method (e.g., make POST act as GET) |
| `x-tz-offset` | Timezone UTC offset for date filters |
| `RateLimit` | Rate limit statistics in responses |
| `retry-after` | Seconds to wait after a 429 response |
| `close-sig-hash` | Webhook signature (SHA256 HMAC) |
| `close-sig-timestamp` | Webhook signature timestamp |

### Key URLs

| Resource | URL |
|----------|-----|
| API Base | `https://api.close.com/api/v1` |
| OAuth Authorization | `https://app.close.com/oauth2/authorize/` |
| OAuth Token | `https://api.close.com/oauth2/token/` |
| OAuth Revoke | `https://api.close.com/oauth2/revoke/` |
| Support | support@close.com |

### Pagination Parameters

| Method | Parameters | Used By |
|--------|-----------|---------|
| Offset-based | `_skip`, `_limit` | Most list endpoints |
| Cursor-based (body) | `cursor`, `_limit` | Advanced Filtering API |
| Cursor-based (query) | `_cursor`, `_limit` | Events API |

### Rate Limit Tiers

| Scope | Relative Limit |
|-------|---------------|
| Per API Key | 1x (e.g., 20 RPS) |
| Per Organization | 3x (e.g., 60 RPS) |
