# Close CRM API — Complete Documentation

> **Source**: https://developer.close.com
> **Date scraped**: 2026-03-30
> **Base URL**: `https://api.close.com/api/v1`
> **Auth**: API Key (Basic Auth) or OAuth 2.0
> **70+ pages scraped, 7,440 lines of documentation**

---

## Table of Contents

1. [Topics (Auth, Rate Limits, Pagination, etc.)](#close-crm-api-documentation--topics-reference)
2. [Core Resources (Leads, Contacts, Opportunities, etc.)](#close-crm-api--core-resources-reference)
3. [Activities (Calls, Emails, SMS, Meetings, etc.)](#close-crm-api--activities-reference)
4. [Features (Templates, Sequences, Dialer, etc.)](#close-crm-api--features-reference)
5. [Advanced (Custom Fields, Custom Objects, Events, Webhooks)](#close-crm-api--advanced-reference)

---

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


---


# Close CRM API — Core Resources Documentation

> **Source:** https://developer.close.com
> **Date scraped:** 2026-03-30
> **Base URL:** `https://api.close.com/api/v1`

---

## Table of Contents

1. [Authentication](#authentication)
2. [Rate Limits](#rate-limits)
3. [Pagination](#pagination)
4. [HTTP Response Codes](#http-response-codes)
5. [Leads](#leads)
6. [Contacts](#contacts)
7. [Opportunities](#opportunities)
8. [Tasks](#tasks)
9. [Outcomes](#outcomes)
10. [Memberships](#memberships)
11. [Users](#users)
12. [Organizations](#organizations)
13. [Roles](#roles)
14. [Lead Statuses](#lead-statuses)
15. [Opportunity Statuses](#opportunity-statuses)
16. [Pipelines](#pipelines)
17. [Groups](#groups)
18. [Advanced Filtering](#advanced-filtering)
19. [Reporting](#reporting)
20. [Meeting Search](#meeting-search)

---

## Authentication

API keys use HTTP Basic authentication. The API key acts as the username and the password is always empty.

```bash
curl https://api.close.com/api/v1/me/ -u yourapikey:
```

Note the `:` at the end of the API key. This is required because the key is sent as the username with a blank password.

```
GET /api/v1/me/ HTTP/1.1
Authorization: Basic eW91cmFwaWtleTo=
Host: api.close.com
```

The base64-encoded string `yourapikey:` becomes `eW91cmFwaWtleTo=`.

API keys are per-organization and can be generated and deleted in the Settings page.

For public applications, use OAuth instead (see `/topics/authentication-oauth2/`).

---

## Rate Limits

Rate limits protect Close infrastructure from excessive request rates.

**If you receive a `429` (Too Many Requests) response**, sleep/pause for the number of seconds specified by the `rate_reset` value before making additional requests.

- Rate limits are enforced **per endpoint group** (URL path + HTTP method).
- Rate limits are enforced at a **per Organization level** across all API keys.
- A lower rate limit is also enforced **per API key**.
- The per-Organization limit is currently **3x higher** than individual API key rate limits.
  - Example: if per-key limit is 20 RPS, org limit is 60 RPS.

**RateLimit header** (included in most API responses):

```
RateLimit: limit=100, remaining=50, reset=5
```

| Field | Description |
|-------|-------------|
| `limit` | Request limit enforced for this endpoint (some endpoints allow bursting) |
| `remaining` | Requests left in the enforcement window |
| `reset` | Seconds remaining before enforcement window ends (decimal) |

Each `429` response includes the `RateLimit` header and a `retry-after` header (RFC 7231). Use the `rate_reset` value for more accurate wait times.

Some endpoints may have stricter, unpredictable rate limits that trigger 429 even within the enforcement window.

---

## Pagination

Close API uses two pagination methods.

### Offset-Based Pagination

Most list endpoints use `_limit` and `_skip` parameters.

```
Page 1: /api/v1/lead/?_skip=0&_limit=100
Page 2: /api/v1/lead/?_skip=100&_limit=100
Page 3: /api/v1/lead/?_skip=200&_limit=100
```

**Response fields:**
- `data` — list of objects
- `has_more` — boolean indicating if more pages exist

There is a maximum `_skip` limit that varies per resource. Exceeding it returns a `400`.

**Deep Pagination:** For iterating through large lists, use `date_created` as a range filter and make multiple requests with incrementing/decrementing dates. Alternatively, use the Export API.

### Cursor-Based Pagination

Used by:
- **Advanced Filtering API** — `cursor` and `_limit` in request body
- **Events API** — `_cursor` and `_limit` query parameters

Pass the cursor token from the previous response to fetch the next page.

---

## HTTP Response Codes

| Code | Description |
|------|-------------|
| `200` | Request was successful |
| `400` | Issue with the request |
| `401` | Request needs to be authenticated |
| `402` | Request could not be completed because a limit of the current plan was reached |
| `403` | Operation was not allowed |
| `404` | URL was not found |
| `405` | HTTP method was not supported |
| `415` | Request used an unsupported format |

---

## Leads

Leads are the most important object in Close. They represent a company or organization and can contain contacts, tasks, opportunities, and activities. These other objects must be children of a Lead. A Lead in Close is like both a "lead" and "account" in other CRM terminology.

When a lead is returned, its basic info as well as related tasks, opportunities, and custom fields are included. **Activities are excluded** and must be fetched separately via the activities endpoint.

**Custom Fields:** Returned as `custom.FIELD_ID`. Using the `custom` field dict is deprecated. When using `_fields`, specify `custom` to show all custom fields, or provide a comma-separated list of `custom.FIELD_ID` identifiers.

**Smart Fields:** Not included by default.
- Fetch a specific Smart Field: `?_fields=smart_field_name,other_lead_field_names`
- Fetch all fields including Smart Fields: `?_fields=_all`

Smart Fields are calculated fields (e.g., number of emails on a lead). Use specific field names rather than `_all` for performance.

**Filtering:** Use the [Advanced Filtering API](#advanced-filtering) to find leads matching specific conditions.

### GET /api/v1/lead/

List leads.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | No | Maximum number of results to return |
| `_skip` | integer | No | Number of results to skip (pagination) |
| `_fields` | string | No | Comma-separated field names. Use `custom` for all custom fields, `_all` for all fields including Smart Fields |

### POST /api/v1/lead/

Create a new lead. Contacts, addresses, and custom fields can all be nested in the lead. Activities, tasks, and opportunities must be posted separately.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `status` | string | No | Status label. Do not use with `status_id`. If neither provided, organization default is used |
| `status_id` | string | No | Status ID (recommended over `status` so users can rename statuses in UI) |
| `custom.FIELD_ID` | mixed | No | Custom field value where FIELD_ID is the custom field identifier |
| `contacts` | array | No | Nested contact objects |
| `addresses` | array | No | Nested address objects |

**Notes:**
- Post either `status` or `status_id`, not both.
- If neither exists, the organization's default (first) status is used.
- For multi-value custom fields (`accepts_multiple_values: true`), the entire value is replaced, not appended. E.g., given value `["A", "B"]`, adding `"C"` means setting to `["A", "B", "C"]`.
- Using `custom` field dict or `custom.FIELD_NAME` syntax is deprecated.

```json
{
    "custom.cf_v6S011I6MqcbVvB2FA5Nk8dr5MkL8sWuCiG8cUleO9c": "value",
    "custom.cf_8wtBWsdRU2Fur7GDnEeXQ7ra2Vu7R4hG1SNYdiEhh0F": "other value"
}
```

### GET /api/v1/lead/{id}/

Retrieve a single lead.

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Lead identifier |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_fields` | string | No | Comma-separated field names to include |

### PUT /api/v1/lead/{id}/

Update an existing lead. Supports non-destructive patches.

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Lead identifier |

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `status` | string | No | Updated status label |
| `status_id` | string | No | Updated status ID |
| `custom.FIELD_ID` | mixed | No | Custom field value |
| `custom.FIELD_ID` | null | No | Unset a field |
| `custom.FIELD_ID.add` | mixed | No | Add single value to multi-value field |
| `custom.FIELD_ID.remove` | mixed | No | Remove single value from multi-value field |

**Unset a custom field:**
```json
{ "custom.cf_v6S011I6MqcbVvB2FA5Nk8dr5MkL8sWuCiG8cUleO9c": null }
```

**Add to multi-value field:**
```json
{ "custom.cf_v6S011I6MqcbVvB2FA5Nk8dr5MkL8sWuCiG8cUleO9c.add": "Wednesday" }
```

### DELETE /api/v1/lead/{id}/

Delete a lead.

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Lead identifier |

### POST /api/v1/lead/merge/

Merge two leads.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `source` | string | Yes | Lead ID to merge from |
| `destination` | string | Yes | Lead ID to merge into |

For definitions of "source" and "destination", see the Merge Leads feature in the Close UI.

---

## Contacts

Contacts represent individual people within a company/organization. Each contact belongs to exactly one Lead and can contain multiple phone numbers, email addresses, URLs, and be associated with Contact Custom Fields.

Use the [Advanced Filtering API](#advanced-filtering) to find contacts matching specific conditions.

### GET /api/v1/contact/

List contacts.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | No | Maximum number of results to return |
| `_skip` | integer | No | Number of results to skip for pagination |

### POST /api/v1/contact/

Create a new contact.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `lead_id` | string | No | Lead ID. If not provided, a new lead is created named after the contact |
| `name` | string | No | Contact name |
| `title` | string | No | Contact title/position |
| `phones` | array | No | Array of phone objects `[{"phone": "+1...", "type": "office"}]` |
| `emails` | array | No | Array of email objects `[{"email": "...", "type": "office"}]` |
| `urls` | array | No | Array of URL objects `[{"url": "...", "type": "url"}]` |
| `custom.FIELD_ID` | mixed | No | Custom field value |

### GET /api/v1/contact/{id}/

Fetch a single contact.

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Contact ID |

### PUT /api/v1/contact/{id}/

Update an existing contact.

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Contact ID |

Supports the same custom field update syntax as leads:

```json
{ "custom.cf_v6S011I6MqcbVvB2FA5Nk8dr5MkL8sWuCiG8cUleO9c.add": "Wednesday" }
```

### DELETE /api/v1/contact/{id}/

Delete a contact.

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Contact ID |

---

## Opportunities

Opportunities represent a potential deal with a given company/lead. They have a customizable status (with `status_type` of `active`, `won`, or `lost`), and optionally a monetary amount. They can be associated with Opportunity Custom Fields or Shared Fields.

### GET /api/v1/opportunity/

List or filter opportunities.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `lead_id` | string | No | Filter by lead ID |
| `user_id` | string | No | Filter by user ID (supports `__in` for multiple) |
| `status_id` | string | No | Filter by status ID (supports `__in` for multiple) |
| `status_label` | string | No | Filter by status label (supports `__in` for multiple) |
| `status_type` | string | No | Filter by type: `active`, `won`, `lost` (supports `__in`) |
| `date_created__lt` | date | No | Date created less than |
| `date_created__gt` | date | No | Date created greater than |
| `date_created__lte` | date | No | Date created less than or equal |
| `date_created__gte` | date | No | Date created greater than or equal |
| `date_updated__lt` | date | No | Date updated less than |
| `date_updated__gt` | date | No | Date updated greater than |
| `date_updated__lte` | date | No | Date updated less than or equal |
| `date_updated__gte` | date | No | Date updated greater than or equal |
| `date_won__lt` | date | No | Date won less than |
| `date_won__gt` | date | No | Date won greater than |
| `date_won__lte` | date | No | Date won less than or equal |
| `date_won__gte` | date | No | Date won greater than or equal |
| `value_period` | string | No | Filter: `one_time`, `monthly`, `annual` (supports `__in`) |
| `query` | string | No | Search query filter (opportunity properties only). E.g., `note:important` or `status_change(old_status:active new_status:won date:yesterday)` |
| `_order_by` | string | No | Order by: `date_won`, `date_updated`, `date_created`, `confidence`, `user_name`, `value`, `annualized_value`, `annualized_expected_value` (prepend `-` for descending) |
| `_group_by` | string | No | Group by: `user_id`, `date_won__week`, `date_won__month`, `date_won__quarter`, `date_won__year` (prepend `-` to reverse group order) |
| `_fields` | string | No | Specify which fields to return |
| `lead_saved_search_id` | string | No | Lead Smart View filter ID |
| `_limit` | integer | No | Limit results |
| `_skip` | integer | No | Skip results |

**Aggregate Response Fields** (included regardless of pagination):

| Field | Type | Description |
|-------|------|-------------|
| `total_results` | integer | Total number of matching objects |
| `count_by_value_period` | object | Count by value period, e.g. `{'one_time': 2, 'annual': 1, 'monthly': 1}` |
| `total_value_one_time` | number | Sum of one-time opportunity values |
| `total_value_monthly` | number | Sum of monthly opportunity values |
| `total_value_annual` | number | Sum of annual opportunity values |
| `total_value_annualized` | number | Sum of all values (monthly x 12) |
| `expected_value_one_time` | number | One-time values x confidence |
| `expected_value_monthly` | number | Monthly values x confidence |
| `expected_value_annual` | number | Annual values x confidence |
| `expected_value_annualized` | number | All values x confidence (monthly x 12) |

**Grouping:**

When using `_group_by`, the `data` array contains groups instead of objects:

| Group Field | Description |
|-------------|-------------|
| `key` | Unique group key |
| `objects` | Array of objects in group |
| `total_results` | Count for the group |
| All aggregate values | Per-group aggregates |
| `year` | When grouping by year/month/quarter/week |
| `month` | When grouping by month (1-12) |
| `quarter` | When grouping by quarter (1-4) |
| `weekyear`, `week` | When grouping by week (ISO standard) |
| `user_id`, `user_name` | When grouping by user |

**Notes:**
- Pagination applies to objects, not groups. The last/first group may be cut off.
- Use `key` to combine groups across pages.
- `_order_by` sorts items within each group.
- When grouping by `user_id`, results are ordered by user's full name.
- `lead_query` parameter is deprecated; use `lead_saved_search_id` instead.

### POST /api/v1/opportunity/

Create an opportunity.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `status_id` | string | No | Status ID. If omitted, organization default (first) status used. Fetch available statuses from Opportunity Status API |
| `lead_id` | string | No | Lead ID. If omitted, new lead created (will appear as "Untitled") |
| `custom.FIELD_ID` | mixed | No | Custom field value |

```json
{
    "custom.cf_v6S011I6MqcbVvB2FA5Nk8dr5MkL8sWuCiG8cUleO9c": "value",
    "custom.cf_8wtBWsdRU2Fur7GDnEeXQ7ra2Vu7R4hG1SNYdiEhh0F": "other value"
}
```

**Notes:**
- For multi-value custom fields (`accepts_multiple_values: true`), the entire value is replaced.
- Using `custom` dict or `custom.FIELD_NAME` is deprecated.

### GET /api/v1/opportunity/{id}/

Retrieve an opportunity.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

### PUT /api/v1/opportunity/{id}/

Update an opportunity.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `status_id` | string | No | Setting to `won` status auto-sets `date_won` if not already set. Reverting from `won` does NOT auto-change `date_won` |
| `date_won` | date | No | Auto-set to today when `status_id` set to `won` (respects `x-tz-offset` header) |
| `custom.FIELD_ID` | mixed | No | Custom field update |
| `custom.FIELD_ID` | null | No | Unset a field |
| `custom.FIELD_ID.add` | mixed | No | Add value to multi-value field |
| `custom.FIELD_ID.remove` | mixed | No | Remove value from multi-value field |

### DELETE /api/v1/opportunity/{id}/

Delete an opportunity.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

---

## Tasks

Tasks are action items with a given date assigned to a sales rep. Incomplete tasks (`is_complete` is false) show in the rep's inbox; complete tasks (`is_complete` is true) are in the archive. Archived tasks of certain types are automatically deleted after a time.

The `date` field represents when the task is actionable. It can be date-only (e.g. `2015-01-05`) or datetime (e.g. `2015-01-10T05:00:00+00:00`). When ordering, date-only tasks are ordered before datetime tasks at the same date, taking timezone (`x-tz-offset`) into account.

**Task Types:**

| Type | object_type | Description |
|------|-------------|-------------|
| `lead` | null | To-do item for a lead. `object_type` and `object_id` are null (lead is in `lead_id`) |
| `incoming_email` | emailthread | One or multiple incoming emails on a thread. `emails` array has email activity IDs. `subject` has the thread subject. Multiple unread emails in one thread are consolidated |
| `email_followup` | emailthread | Follow-up reminder on sent email with no response. `email_id` references the original email. `subject` and `body_preview` contain data about the email |
| `missed_call` | call | Missed call. `phone` has remote party number, `local_phone` has the number that was called |
| `answered_detached_call` | call | Call from unassociated number. `phone` has remote party number |
| `voicemail` | call | Voicemail. Same as `missed_call` plus `voicemail_duration` and `voicemail_url` |
| `opportunity_due` | opportunity | Opportunity scheduled to close on this date |
| `incoming_sms` | sms | Incoming SMS/MMS. `remote_phone` has sender number, `local_phone` has the number texted. MMS has `attachments` field |
| `outgoing_call` | call | Outgoing call task |

**Note:** When not filtering by `_type`, only `lead` type tasks are returned. Use `_type=all` for all types, or `_type__in=missed_call,voicemail` for specific types.

### GET /api/v1/task/

List or filter tasks.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | No | Task ID |
| `id__in` | string | No | Comma-separated task IDs |
| `_type` | string | No | Task type filter. Default returns only `lead` type. Use `all` for all types, or `_type__in=type1,type2` |
| `lead_id` | string | No | Filter by lead ID |
| `is_complete` | boolean | No | Filter by completion status |
| `date__lt` | datetime | No | Date less than |
| `date__gt` | datetime | No | Date greater than |
| `date__lte` | datetime | No | Date less than or equal |
| `date__gte` | datetime | No | Date greater than or equal |
| `date_created__lt` | datetime | No | Creation date less than |
| `date_created__gt` | datetime | No | Creation date greater than |
| `date_created__lte` | datetime | No | Creation date less than or equal |
| `date_created__gte` | datetime | No | Creation date greater than or equal |
| `assigned_to` | string | No | Filter by assigned user |
| `view` | string | No | View type: `inbox`, `future`, `archive` |
| `_order_by` | string | No | Order by `date` or `date_created` (prepend `-` for descending) |
| `_limit` | integer | No | Limit results |
| `_skip` | integer | No | Skip results |

**View parameter values:**
- `inbox` — Incomplete tasks up to end of user's day (timezone-aware)
- `future` — Incomplete tasks from tomorrow onward (timezone-aware)
- `archive` — Complete tasks only

**Note:** `view` of `inbox` or `future` overrides any `date__lt` or `date__gte` parameters.

### POST /api/v1/task/

Create a task.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `_type` | string | Yes | Task type: `lead` or `outgoing_call` (only these two can be created) |
| `lead_id` | string | Yes | Lead to associate the task with |
| `assigned_to` | string | No | User ID to assign the task to |
| `date` | string | No | Date or datetime for the task |
| `text` | string | No | Task text (for `lead` type) |
| `is_complete` | boolean | No | Completion status |

### PUT /api/v1/task/

Bulk-update tasks. Any GET endpoint filters may be used (e.g. `id__in=A,B,C`).

**Updatable Fields (bulk):** Only `assigned_to`, `date`, and `is_complete`.

### GET /api/v1/task/{id}/

Fetch a task's details.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

### PUT /api/v1/task/{id}/

Update a task.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

**Updatable Fields:**

| Field | Task Types | Description |
|-------|-----------|-------------|
| `assigned_to` | All | Reassign the task |
| `date` | All | Date or datetime |
| `is_complete` | All | Mark complete/incomplete |
| `text` | `lead` only | Update task text |

### DELETE /api/v1/task/{id}/

Delete a task.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

---

## Outcomes

Outcomes represent standardized results applicable to activities such as calls and meetings. They help sales teams track and categorize interaction results.

Each outcome includes a name, optional description, and specifies which activity types it applies to. Outcomes can be `custom` (user-defined) or `vm-dropped` (automatically applied during voicemail drops).

### GET /api/v1/outcome/

List or filter outcomes.

### POST /api/v1/outcome/

Create a new outcome.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Displayed wherever outcomes can be selected |
| `applies_to` | array | Yes | Valid values: `calls`, `meetings` |
| `description` | string | No | Explains outcome meaning and usage |
| `type` | string | No | `custom` (default) or `vm-dropped` for voicemail drops |

**Note:** The `applies_to` field will be deprecated in a future update and derived from `type` instead. `custom` outcomes will apply to `["calls", "meetings"]`; `vm-dropped` outcomes will apply to `["calls"]`.

### GET /api/v1/outcome/{id}/

Fetch a single outcome.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

### PUT /api/v1/outcome/{id}/

Update an outcome.

**Request Body (all optional):**

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Update the outcome name |
| `description` | string | Update the description |
| `applies_to` | array | Change applicable activity types (will be ignored in future) |
| `type` | string | Change to `custom` or `vm-dropped` |

### DELETE /api/v1/outcome/{id}/

Delete an outcome.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

**Note:** Associated calls and meetings retain their outcome references, but the outcome cannot be set on new activities.

**Usage:** To apply an outcome to a call or meeting, send a PUT request to the respective activity endpoint with `outcome_id: "outcome_xyz"`.

---

## Memberships

Memberships connect a User with one or more Organizations. A Membership is created when a User is added to an organization, and becomes "inactive" when a User leaves or is removed.

### PUT /api/v1/membership/{id}/

Update a membership.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

**Updatable Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `role_id` | string | One of `'admin'`, `'superuser'`, `'user'`, `'restricteduser'`, or a custom Role ID |
| `auto_record_calls` | string | Call recording setting: `'unset'` (initial), `'disabled'`, or `'enabled'` |

### POST /api/v1/membership/

Create or activate a membership for a given email. Ensures an active membership will be provisioned.

- If the user already exists, they are added to the requestor's organization.
- If the user doesn't exist, a new user is provisioned.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes | Email address for the membership |
| `role_id` | string | No | One of `'admin'`, `'superuser'`, `'user'`, `'restricteduser'`, or custom Role ID |

**Authentication:** OAuth only.
**Permissions Required:** "Manage Organization".

### PUT /api/v1/membership/

Bulk-update memberships. Pass comma-separated IDs into `id__in` in query parameters.

**Updatable Fields:** Same as individual update (`role_id`, `auto_record_calls`).

### GET /api/v1/membership/{id}/pinned_views

Get the ordered list of pinned views for the given membership.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

### PUT /api/v1/membership/{id}/pinned_views

Set pinned views for the membership. Provide an ordered list that overwrites the entire current list.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

**Request Body:** Ordered array of view identifiers.

---

## Users

Users represent Close user accounts — typically co-workers or sales representatives.

### GET /api/v1/me/

Fetch information about yourself. This is a special instance of `/user/{your_user_id}/`. Useful for determining the `id` of the Organization you belong to.

### GET /api/v1/user/{id}/

Fetch a single user.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

### GET /api/v1/user/

List all users who are members of the same organizations as you.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | No | Maximum results |
| `_skip` | integer | No | Skip results |

### GET /api/v1/user/availability/

Fetch availability statuses of all users within an organization.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `organization_id` | string | No | Filter by organization ID |

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `active_calls` | array | Call metadata for calls the user is currently participating in |

---

## Organizations

Organizations are "environments" in Close where teams collaborate. Most users belong to a single Organization. Leads/Contacts/Activities cannot be shared across organizations.

### GET /api/v1/organization/{id}/

Get organization details including current members (users), lead and opportunity statuses, etc.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_expand` | string | No | Expand nested fields. E.g., `memberships__user,inactive_memberships__user` |

**Response Notes:**
- By default, `memberships` and `inactive_memberships` are populated with user data prefixed with `user_`.
- Use `_expand` to get a nested `user` field instead.

### PUT /api/v1/organization/{id}/

Update organization settings.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | No | Organization name |
| `currency` | string | No | Currency code |
| `lead_statuses` | array | No | Reordered lead status list |

---

## Roles

Roles define what users in your organization can or cannot do. Each user has a single role set via the Memberships API. Every role has a set of permissions. Some roles (like "Admin") are system-maintained and cannot be edited.

**Note:** Lead visibility fields should be empty for roles with `view_all_leads` permission, and must be set otherwise.

### GET /api/v1/role/{id}/

Fetch a single role.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `id` | string | Yes |

### GET /api/v1/role/

List all roles defined for your organization.

### POST /api/v1/role/

Create a new custom role.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Role name |
| `permissions` | array | Yes | List of permission strings |
| `visibility_user_lcf_ids` | array | No | Lead Custom Field IDs defining visible leads. Empty if role has `view_all_leads` |
| `visibility_user_lcf_behavior` | string | No | Controls unassigned lead visibility. Empty if role has `view_all_leads`. Values: `require_assignment` (leads without assigned users not visible), `allow_unassigned` (leads without assigned users are visible) |

### PUT /api/v1/role/{role_id}/

Update an existing role.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `role_id` | string | Yes |

### DELETE /api/v1/role/{role_id}/

Delete a role.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `role_id` | string | Yes |

**Warning:** Make sure to move all users off this role first by updating their `role_id` attribute.

---

## Lead Statuses

Lead statuses are a customizable list of stages a Lead can be in.

### GET /api/v1/status/lead/

List all lead statuses for your organization.

### POST /api/v1/status/lead/

Create a new lead status.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `label` | string | Yes | Status name |

### PUT /api/v1/status/lead/{status_id}/

Rename a lead status.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `status_id` | string | Yes |

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `label` | string | Yes | New status name |

**Note:** To update the status of a particular lead, use `PUT /lead/{lead_id}/` instead.

### DELETE /api/v1/status/lead/{status_id}/

Delete a lead status.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `status_id` | string | Yes |

**Warning:** Make sure no leads are assigned this status first.

---

## Opportunity Statuses

Opportunity statuses are a customizable list of stages an Opportunity can be in. Each status always has a `status_type` of `active`, `won`, or `lost`.

### GET /api/v1/status/opportunity/

List all opportunity statuses for your organization.

**Response schema:** List of objects with `id`, `label`, `status_type`, `pipeline_id`.

### POST /api/v1/status/opportunity/

Create an opportunity status.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `label` | string | Yes | Status name |
| `status_type` | string | Yes | One of: `active`, `won`, `lost` |
| `pipeline_id` | string | No | Pipeline ID. If provided, status applies to specific pipeline |

### PUT /api/v1/status/opportunity/{status_id}/

Rename an opportunity status.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `status_id` | string | Yes |

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `label` | string | Yes | New status name |

### DELETE /api/v1/status/opportunity/{status_id}/

Delete an opportunity status.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `status_id` | string | Yes |

**Warning:** Make sure no opportunities are assigned this status first.

---

## Pipelines

Pipelines are named and ordered groups of Opportunity Statuses. They allow grouping statuses into separate categories for different teams and workflows (e.g., a "Sales" Pipeline and a "Professional Services" Pipeline).

### GET /api/v1/pipeline/

List all pipelines for your organization.

### POST /api/v1/pipeline/

Create a new pipeline.

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Pipeline name |
| `statuses` | array | No | Initial statuses for the pipeline |

### PUT /api/v1/pipeline/{pipeline_id}/

Update a pipeline. Supports:
- Renaming
- Reordering opportunity statuses
- Moving a status from another pipeline by including `{"id": "id_of_the_status_from_another_pipeline"}` in the `statuses` list

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `pipeline_id` | string | Yes |

### DELETE /api/v1/pipeline/{pipeline_id}/

Delete a pipeline.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `pipeline_id` | string | Yes |

**Constraint:** Only allowed if the pipeline contains no Opportunity Statuses. Delete all statuses or move them to another pipeline first.

---

## Groups

Groups are named collections of Users. They allow referring to multiple Users as a unit in filtering and reporting. A group typically represents a team. Users can belong to multiple groups.

**Note:** Endpoints require `?_fields=name,members` to return corresponding field data. Specify only needed fields to reduce data.

**Filtering with groups:** Endpoints that support filtering for both groups and users use the `?user_id__in=user_abc,user_xyz` parameter. Include group IDs to filter by group membership. Mix individual users and groups: `?user_id__in=user_abc,group_xyz`.

### GET /api/v1/group/

List all groups in the organization.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_fields` | string | No | Comma-separated fields (e.g., `name,members`) |

**Note:** List endpoint does not support retrieving members for all groups. Use individual group endpoint instead.

### POST /api/v1/group/

Create a new group (created with no users; use member endpoint to add).

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_fields` | string | No | Fields to return |

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Group name |

### GET /api/v1/group/{group_id}/

Fetch an individual group.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `group_id` | string | Yes |

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_fields` | string | No | Fields to return |

### PUT /api/v1/group/{group_id}/

Update (rename) a group. Error returned if name is not unique.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `group_id` | string | Yes |

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | New name |

### DELETE /api/v1/group/{group_id}/

Delete a group. Only allowed if the group is not referenced by saved reports or smart views.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `group_id` | string | Yes |

### POST /api/v1/group/{group_id}/member/

Add a user to a group. If already a member, nothing changes.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `group_id` | string | Yes |

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `user_id` | string | Yes | User ID to add |

### DELETE /api/v1/group/{group_id}/member/{user_id}/

Remove a user from a group. If not a member, nothing changes.

**Path Parameters:**

| Parameter | Type | Required |
|-----------|------|----------|
| `group_id` | string | Yes |
| `user_id` | string | Yes |

---

## Advanced Filtering

The Advanced Filtering API enables searching for Leads or Contacts using arbitrary filter criteria.

### POST /api/v1/data/search/

**Top-Level Request Body Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | object | Yes | The filter query structure |
| `_fields` | object | No | Fields to return for matched objects |
| `_limit` | integer | No | Results per page |
| `cursor` | string | No | Pagination cursor from previous response |
| `results_limit` | integer | No | Maximum total results |
| `include_counts` | boolean | No | Include count information |
| `sort` | array | No | Sort configuration |

### Query Types

#### ID Query
Match a single object by ID:
```json
{
  "type": "id",
  "value": "cont_abcdef"
}
```

#### Object Type Query
Specify object type to return (`contact` or `lead`):
```json
{
  "type": "object_type",
  "object_type": "contact"
}
```

#### Text Query
Filter across text-like fields:
```json
{
  "type": "text",
  "value": "Bruce",
  "mode": "full_words"
}
```

**Modes:**
- `full_words` — searches all specified words anywhere in the text, disregards position
- `phrase` — searches words in specified order next to each other

#### Field Value Condition Query
Match based on specific field values:
```json
{
  "type": "field_condition",
  "field": {
    "type": "regular_field",
    "object_type": "contact",
    "field_name": "title"
  },
  "condition": {
    "type": "text",
    "mode": "full_words",
    "value": "CEO"
  }
}
```

**Field types:**

Regular field:
```json
{
  "type": "regular_field",
  "object_type": "contact",
  "field_name": "name"
}
```

Custom field:
```json
{
  "type": "custom_field",
  "custom_field_id": "cf_abcdef"
}
```

#### Has Related Query
Filter based on related object data (e.g., Contact based on Lead data):
```json
{
  "type": "has_related",
  "this_object_type": "contact",
  "related_object_type": "lead",
  "related_query": {
    "type": "field_condition",
    "field": {
      "type": "custom_field",
      "custom_field_id": "cf_B57sofuEB7OBneH86SJctTr7hfiAiQcgkGRbAQfha0Z"
    },
    "condition": {
      "type": "term",
      "values": ["Software as a service"]
    },
    "negate": false
  }
}
```

#### AND/OR Queries
Combine multiple conditions:
```json
{
  "type": "and",
  "queries": [query1, query2, query3]
}
```
```json
{
  "type": "or",
  "queries": [query1, query2, query3]
}
```

#### Query Negation
All queries support negation. Specify `"negate": true` to invert matching.

### Field Conditions

#### Boolean
```json
{ "type": "boolean", "value": true }
```

#### Current User
Reference the authenticated user (for fields like `created_by`):
```json
{ "type": "current_user" }
```

#### Exists
Match if field is set (not null/missing):
```json
{ "type": "exists" }
```

#### Text
```json
{
  "type": "text",
  "value": "Bruce",
  "mode": "full_words"
}
```

#### Term
Match enumeration or choice values:
```json
{
  "type": "term",
  "values": ["draft", "sent"]
}
```

#### Reference
Match object IDs in reference fields:
```json
{
  "type": "reference",
  "reference_type": "user",
  "object_ids": ["user_abc", "user_def"]
}
```

#### Number Range
```json
{
  "type": "number_range",
  "gt": 1
}
```

### Output Control

**Return specific fields:**
```json
{
  "query": {},
  "_fields": {
    "contact": ["id", "name", "title"]
  }
}
```

**Limit results:**
```json
{
  "query": {},
  "results_limit": 100
}
```

**Include counts:**
```json
{
  "query": {},
  "include_counts": true,
  "results_limit": 0
}
```

Response with counts:
```json
{
  "data": [],
  "count": {
    "limited": 0,
    "total": 3
  }
}
```

### Sorting

```json
{
  "query": {},
  "sort": [
    {
      "direction": "asc",
      "field": {
        "object_type": "contact",
        "type": "regular_field",
        "field_name": "title"
      }
    }
  ]
}
```

**Directions:** `asc` or `desc`

**Constraint:** Only numbers, dates, and text fields belonging directly to an object can be sorted. References/ID fields or fields from other objects cannot.

### Pagination

```json
{
  "query": {},
  "_limit": 10,
  "cursor": "<cursor_from_previous_response>"
}
```

**Notes:**
- Cursors expire after **30 seconds**
- Hard limit of **10,000 objects** per pagination sequence
- Use stable sort fields like `date_created` to avoid missing results
- When cursor is `null`, you've reached the last page

### Example: Find CEOs of SaaS companies with at least one email

```json
{
  "query": {
    "type": "and",
    "queries": [
      {
        "type": "object_type",
        "object_type": "contact"
      },
      {
        "type": "field_condition",
        "field": {
          "type": "regular_field",
          "object_type": "contact",
          "field_name": "emails_count"
        },
        "condition": {
          "type": "number_range",
          "gt": 1
        }
      },
      {
        "type": "field_condition",
        "field": {
          "type": "regular_field",
          "object_type": "contact",
          "field_name": "title"
        },
        "condition": {
          "type": "text",
          "mode": "full_words",
          "value": "CEO"
        }
      },
      {
        "type": "has_related",
        "this_object_type": "contact",
        "related_object_type": "lead",
        "related_query": {
          "type": "field_condition",
          "field": {
            "type": "custom_field",
            "custom_field_id": "cf_B57sofuEB7OBneH86SJctTr7hfiAiQcgkGRbAQfha0Z"
          },
          "condition": {
            "type": "term",
            "values": ["Software as a service"]
          },
          "negate": false
        }
      }
    ]
  }
}
```

### Example Response

```json
{
  "data": [
    {
      "__object_type": "contact",
      "id": "cont_HjTcJFiNli2AKf5fioygQDVSpA9nJILI9SkKv3nBk0A",
      "name": "Bruce Wayne",
      "title": "The Dark Knight"
    },
    {
      "__object_type": "contact",
      "id": "cont_LXQqW8mvD0BbCR6qhRPbzPZF7gCbXQIw6GD8vqKipss",
      "name": "Steli Efti",
      "title": "CEO & Co-Founder"
    }
  ]
}
```

### Commonly Used Fields

**Contact** (`object_type: "contact"`):

| Field | Type |
|-------|------|
| `created_by` | User ID |
| `date_created` | datetime |
| `date_updated` | datetime |
| `updated_by` | User ID |
| `emails_count` | integer |
| `phones_count` | integer |
| `urls_count` | integer |
| `title` | text |
| `lead_id` | Lead ID |

**Lead** (`object_type: "lead"`):

| Field | Type |
|-------|------|
| `addresses_count` | integer |
| `all_urls_count` | integer |
| `created_by` | User ID |
| `date_created` | datetime |
| `date_updated` | datetime |
| `updated_by` | User ID |
| `description` | text |
| `display_name` | text |
| `status_id` | Lead Status ID |
| `url` | url |

**Contact Phones** (`object_type: "contact_phone"`):

| Field | Type |
|-------|------|
| `type` | text |
| `phone` | text |

**Contact Emails** (`object_type: "contact_email"`):

| Field | Type |
|-------|------|
| `type` | text |
| `email` | email address |

**Contact URLs** (`object_type: "contact_url"`):

| Field | Type |
|-------|------|
| `type` | text |
| `url` | url |

**Addresses** (`object_type: "address"`):

| Field | Type |
|-------|------|
| `address_1` | text |
| `address_2` | text |
| `city` | text |
| `country` | text |
| `location` | text |
| `state` | text |
| `zipcode` | text |

**Tip:** Instead of composing JSON by hand, build your query visually on the Leads or Contacts page in Close, then click the triple-dot menu and select "Copy Filters".

---

## Reporting

These endpoints return aggregated and per-user data used by Close's Reporting features. Revenue fields are returned in **cents**. Duration values are returned in **seconds**.

### GET /api/v1/report/activity/metrics/

List predefined metrics available for activity reports.

### POST /api/v1/report/activity/

Get an activity report. Returns metrics per time period (overview) or per user (comparison).

**Request Body Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `datetime_range` | object | Conditional | Time range. Required if `relative_range` not provided |
| `relative_range` | string | Conditional | Relative time range. Required if `datetime_range` not provided. Values: `today`, `this-week`, `this-month`, `this-quarter`, `this-year`, `yesterday`, `last-week`, `last-month`, `last-quarter`, `last-year`, `all-time` |
| `query` | object | No | Filter. Key `type` with type-specific keys. Currently only `saved_search` type with `saved_search_id` |
| `users` | array | No | List of user IDs to limit results |
| `type` | string | Yes | Report type: `overview` or `comparison` |
| `metrics` | array | Yes | List of metrics to fetch |

**Response format:** JSON or CSV (specify via `accept` header).

### GET /api/v1/report/sent_emails/{ORGANIZATION_ID}/

Get sent emails report grouped by template.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `user_id` | string | No | Filter by user |
| `date_start` | string | No | Report period start |
| `date_end` | string | No | Report period end |

### GET /api/v1/report/statuses/lead/{ORGANIZATION_ID}/

Get a lead status change report.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `date_start` | string | No | Report period start |
| `date_end` | string | No | Report period end |
| `query` | string | No | Lead search query filter (cannot use with `smart_view_id`) |
| `smart_view_id` | string | No | Smart view filter (cannot use with `query`) |

**Response Fields:**

`status_overview` (array) — All lead statuses with:

| Field | Type | Description |
|-------|------|-------------|
| `status_id` | string | Status ID |
| `status_label` | string | Status label |
| `status_is_deleted` | boolean | Whether status was deleted |
| `started` | integer | Leads in this status at period start |
| `ended` | integer | Leads in this status at period end |
| `change` | integer | Net change (`ended` - `started`) |
| `change_percent` | number | Net change in percent |
| `gained` | integer | Leads not in status at start but in status at end |
| `lost` | integer | Leads in status at start but not at end |
| `entered` | integer | Leads that entered this status during period |
| `left` | integer | Leads that left this status during period |
| `_queries` | object | Search queries for different states (`started`, `ended`, `gained`, `lost`, `entered`, `left`) |
| `_leads_page_urls` | object | UI page paths for different states |

`status_transitions` (array) — Aggregated transitions:

| Field | Type | Description |
|-------|------|-------------|
| `from_status_id` | string | Starting status ID (null for created leads) |
| `from_status_label` | string | Starting status label (null for created leads) |
| `from_status_is_deleted` | boolean | Whether starting status was deleted |
| `to_status_id` | string | Ending status ID |
| `to_status_label` | string | Ending status label |
| `to_status_is_deleted` | boolean | Whether ending status was deleted |
| `count` | integer | Number of leads that transitioned |
| `_query` | string | Search query for these leads |
| `_leads_page_url` | string | UI page path |

### GET /api/v1/report/statuses/opportunity/{ORGANIZATION_ID}/

Get an opportunity status change report.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `user_id` | string | No | Filter by opportunity user |
| `date_start` | string | No | Report period start |
| `date_end` | string | No | Report period end |
| `smart_view_id` | string | No | Smart view filter |
| `query` | string | No | Search query filter |

**Response:** Similar to lead status report with these differences:
- `status_transitions_summary` — summarized transitions (e.g., A->B->C counted as A->C)
- Numbers refer to opportunities, not leads
- `_queries` wrapped in nested opportunity query `opportunity(...)` for leads endpoint; unwrap for opportunities endpoint
- `_opportunities_page_urls` and `_opportunities_page_url` fields for opportunity UI pages

### GET /api/v1/report/custom/{ORGANIZATION_ID}/

Get a custom report (powers "Explorer" in UI).

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | No | Search query filter. Defaults to `*`. When reporting on activities/opportunities, only properties of the chosen object type may be used (e.g., `direction:incoming` for email) |
| `x` | string | Yes | X-axis field (e.g., `lead.custom.MRR`, `opportunity.date_created`) |
| `y` | string | No | Y-axis metric (default: `lead.count`). Examples: `call.duration`, `opportunity.value`. Only `number` data type can be used |
| `interval` | string | No | Graph interval/precision. For date X: `auto`, `hour`, `day`, `week`, `month`, `quarter`, `year` (default: `auto`). For numeric X: integer for histogram interval |
| `transform_y` | string | No | Y transformation: `sum` (default), `avg`, `min`, `max`. Does not apply for `.count` y values if x is same object type |
| `group_by` | string | No | Field to group by (separate series per group) |
| `start` | string/integer | No | Range start. For dates, defaults to org creation date |
| `end` | string/integer | No | Range end. For dates, defaults to now |

**Note:** Get a full list of available fields via `GET /report/custom/fields/`.

### POST /api/v1/report/funnel/opportunity/totals/

Get a funnel report (totals). Returns pipeline funnel metrics aggregated and per-user.

**Request Body Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pipeline` | string | Yes | Pipeline ID defining funnel statuses |
| `type` | string | Yes | `created-cohort` or `active-stage-cohort` |
| `report_relative_range` | string | Conditional | Report time range (relative). Values: `today`, `this-week`, `this-month`, `this-quarter`, `this-year`, `yesterday`, `last-week`, `last-month`, `last-quarter`, `last-year`, `all-time` |
| `report_datetime_range` | object | Conditional | Report time range (absolute) |
| `cohort_relative_range` | string | Conditional | Cohort range (relative). Required for `created-cohort`. Ignored for `active-stage-cohort` |
| `cohort_datetime_range` | object | Conditional | Cohort range (absolute). Required for `created-cohort`. Ignored for `active-stage-cohort` |
| `compared_relative_range` | string | No | Comparison range (relative). Only with `report_relative_range` (active-stage-cohort) or `cohort_relative_range` (created-cohort) |
| `compared_datetime_range` | string | No | Comparison range. Only with `report_datetime_range` or `cohort_datetime_range`. Values: `same-days-last-week`, `same-days-last-month`, `same-days-last-quarter`, `same-days-last-year` |
| `compared_custom_range` | object | No | Custom comparison range |
| `query` | object | No | Filter with `type` and `saved_search_id` |
| `users` | array | No | User or group IDs (empty = all users) |

**Response format:** JSON (aggregated + per-user) or CSV (per-user only, via `accept` header).

**Note:** When `compared_*` ranges are used, the response is the compared report, not the base one.

### POST /api/v1/report/funnel/opportunity/stages/

Get a funnel report (stages). Same parameters and behavior as funnel totals.

---

## Meeting Search

Meetings can be searched by provider calendar information (the underlying calendar events they were created from).

**Searchable Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `provider_calendar_event_id` | string | Yes | Provider event ID the meeting was synced from. **Always required** |
| `provider_calendar_id` | string | No | Provider calendar ID |
| `provider_calendar_type` | string | No | `"google"` or `"microsoft"` |
| `starts_at` | datetime | No | Meeting start time. Supports exact match and range queries |
| `starts_at__gte` | datetime | No | Greater than or equal |
| `starts_at__lt` | datetime | No | Less than |
| `lead_id` | string | No | Filter to specific lead |

**Warning:** You must always provide at least `provider_calendar_event_id` or you will receive an error.

### Example Queries

Search by event ID:
```
GET /api/v1/activity/meeting/?provider_calendar_event_id=EVENT_ID
```

Search with start time:
```
GET /api/v1/activity/meeting/?provider_calendar_event_id=EVENT_ID&starts_at=2023-09-19T15:00:00
```

Search by event and calendar ID:
```
GET /api/v1/activity/meeting/?provider_calendar_event_id=EVENT_ID&provider_calendar_id=CALENDAR_ID
```

Search with date range:
```
GET /api/v1/activity/meeting/?provider_calendar_event_id=EVENT_ID&provider_calendar_type=google&starts_at__gte=2023-09-20&starts_at__lt=2023-09-21&lead_id=LEAD_ID
```

### Google Calendar Provider Information

- `provider_calendar_event_id` = `id` property on Event resource
- `provider_calendar_id` = `id` property on Calendar resource

**Extract from `htmlLink`:** Base64 decode the `eid` query parameter. Result is space-separated `event_id calendar_id`.

Example:
```
https://www.google.com/calendar/event?eid=ZDYzOWZhMWM3ZWEzNDRjNzk3ZGYxZDBmNTE2MDMxMTMgZXhhbXBsZUBjbG9zZS5jb2
```
Base64 decode `eid` -> `d639fa1c7ea344c797df1d0f51603113 example@close.com`

**Extract from edit link:** Base64 decode the last path component.

Example:
```
https://calendar.google.com/calendar/u/1/r/eventedit/ZDYzOWZhMWM3ZWEzNDRjNzk3ZGYxZDBmNTE2MDMxMTMgZXhhbXBsZUBjbG9zZS5jb20
```
Decodes to `d639fa1c7ea344c797df1d0f51603113 example@close.com`

**Note:** You may need to add `=` padding characters for base64 decoding (Google strips them).

### Microsoft Calendar Provider Information

- `provider_calendar_event_id` = `id` property on Event resource
- `provider_calendar_id` = `id` property on Calendar resource

**Extract from `webLink`:** Use the `itemid` query parameter.

Example:
```
https://outlook.office365.com/owa/?itemid=AAMkADdiYzg5OGRlLTY1MjktNDc2Ni05YmVkLWMxMzFlNTQ0MzU3YQBGAAAAAACi9RQWB%2FSNTZBuALM6KIOsBwBtf4g8yY%2BzTZgZh6x0X%2F50AAAAAAENAABtf4g8yY%2BzTZgZh6x0X%2F50AALLI4%2FVAAA%3D&exvsurl=1&path=/calendar/item
```
URL-decode `itemid` and pass as `provider_calendar_event_id`.

**Extract from details link:** Use the last path component.

Example:
```
https://outlook.office.com/calendar/item/AAMkADdiYzg5OGRlLTY1MjktNDc2Ni05YmVkLWMxMzFlNTQ0MzU3YQBGAAAAAACi9RQWB%2FSNTZBuALM6KIOsBwBtf4g8yY%2BzTZgZh6x0X%2F50AAAAAAENAABtf4g8yY%2BzTZgZh6x0X%2F50AALmRd2BAAA%3D
```
URL-decode and pass the last path component as `provider_calendar_event_id`.


---


# Close CRM API — Activities Documentation

> **Source:** https://developer.close.com/resources/activities/
> **Date scraped:** 2026-03-30
> **API Base URL:** `https://api.close.com/api/v1`

---

## Table of Contents

1. [Authentication](#authentication)
2. [Rate Limits](#rate-limits)
3. [Pagination](#pagination)
4. [Rich Text Fields](#rich-text-fields)
5. [Activities Overview](#activities-overview)
6. [Call](#call)
7. [Created](#created)
8. [Email](#email)
9. [EmailThread](#emailthread)
10. [LeadStatusChange](#leadstatuschange)
11. [Meeting](#meeting)
12. [Note](#note)
13. [OpportunityStatusChange](#opportunitystatuschange)
14. [SMS](#sms)
15. [TaskCompleted](#taskcompleted)
16. [LeadMerge](#leadmerge)
17. [WhatsAppMessage](#whatsappmessage)
18. [FormSubmission](#formsubmission)

---

## Authentication

API keys use **HTTP Basic authentication**. The API key is the username; the password is always empty.

```bash
curl https://api.close.com/api/v1/me/ -u yourapikey:
```

This sends the header:

```
Authorization: Basic eW91cmFwaWtleTo=
```

Where `eW91cmFwaWtleTo=` is the base64-encoded string `yourapikey:`.

- API keys are **per-organization** and can be generated/deleted in Settings.
- For public applications, use **OAuth** instead (see `/topics/oauth/`).

---

## Rate Limits

- Rate limits are enforced **per endpoint group** and **per organization**.
- Per-API-key limit exists; the per-organization limit is **3x** the per-key limit.
- If you receive HTTP **429 (Too Many Requests)**, sleep for the number of seconds in `rate_reset` before retrying.

**Response header** (on most responses):

```
RateLimit: limit=100, remaining=50, reset=5
```

| Header Field | Meaning |
|---|---|
| `limit` | Request limit for this endpoint (some allow bursting) |
| `remaining` | Requests left in the enforcement window |
| `reset` | Seconds remaining before the window ends (decimal) |

On 429 responses, the `retry-after` header is also set (rounded up to next integer).

---

## Pagination

### Offset-Based Pagination (most list endpoints)

Uses `_limit` and `_skip` query parameters.

```
Page 1: /api/v1/lead/?_skip=0&_limit=100
Page 2: /api/v1/lead/?_skip=100&_limit=100
Page 3: /api/v1/lead/?_skip=200&_limit=100
```

**Response format:**

```json
{
  "data": [ ... ],
  "has_more": true
}
```

- `data` — array of objects
- `has_more` — boolean indicating if more pages exist

**Deep Pagination:** There is a maximum `_skip` limit per resource. For large datasets, paginate using `date_created` range filters instead, or use the Export API.

### Cursor-Based Pagination

Used by Advanced Filtering API (`cursor` + `_limit` in request body) and Events API (`_cursor` + `_limit` query params).

---

## Rich Text Fields

Rich text fields (`note_html`, `user_note_html`, etc.) accept a **restricted subset of XHTML**.

### Supported HTML Elements

| Element | Purpose |
|---|---|
| `<body>` | Required wrapper (beginning and end) |
| `<b>`, `<strong>` | Bold text |
| `<i>`, `<em>` | Italic text |
| `<u>` | Underlined text |
| `<s>` | Strikethrough text |
| `<code>` | Inline code |
| `<h1>` through `<h6>` | Heading levels |
| `<p>` | Paragraphs |
| `<ul>` | Unordered lists |
| `<li>` | List items |
| `<hr>` | Horizontal rules |
| `<a href="...">` | Links |
| `<img src="..." alt="...">` | Images |
| `<span>` | Generic inline container |

### Mentions

```html
<span data-type="mention" data-id="..." data-label="..." class="mention">@Name</span>
```

### Supported Attributes

- `href` (on `<a>`)
- `src`, `alt` (on `<img>`)
- `style` (inline styling, e.g. colors)
- `data-type`, `data-id`, `data-label`, `class` (for mentions)

### note_html vs note Parameter Behavior

Applies to Call, Note, and other activity types that have both fields:

- **`note_html`** (preferred) — supports rich text via HTML subset. Setting it populates `note` with a plaintext representation (formatting not guaranteed).
- **`note`** — plaintext only. Setting it populates `note_html` by escaping HTML entities (e.g. `<div>` becomes `&lt;div&gt;`) and replacing `\n` with `<br />`.
- **Setting one overwrites the other.** If both are in the same request, `note_html` takes precedence.

---

## Activities Overview

Activities belong to **Leads** and represent any action performed on a Lead or its Contacts (Calls, Emails, Notes, etc.).

### GET /activity/

List or filter all activity types.

```
GET /activity/{?lead_id, user_id, user_id__in, contact_id, contact_id__in, _type, _type__in, date_created__gt, date_created__lt, activity_at__gt, activity_at__lt, _order_by, _fields, _limit, _skip}
```

#### Query Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead ID |
| `user_id` | string | Optional | Filter by user (single lead only) |
| `user_id__in` | string | Optional | Filter by multiple users (single lead only) |
| `contact_id` | string | Optional | Filter by contact (single lead only) |
| `contact_id__in` | string | Optional | Filter by multiple contacts (single lead only) |
| `_type` | string | Optional | Filter by activity type (single lead only) |
| `_type__in` | string | Optional | Filter by multiple activity types (single lead only) |
| `date_created__gt` | datetime | Optional | Created after this timestamp |
| `date_created__lt` | datetime | Optional | Created before this timestamp |
| `activity_at__gt` | datetime | Optional | Activity occurred after this timestamp |
| `activity_at__lt` | datetime | Optional | Activity occurred before this timestamp |
| `_order_by` | string | Optional | Sort field (e.g. `-activity_at`) |
| `_fields` | string | Optional | Specify which response fields to return |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |
| `thread_emails` | string | Optional | `true` or `only` (see below) |

#### Restrictions

- `user_id`, `user_id__in`, `contact_id`, `contact_id__in`, `_type`, `_type__in` can **only** be used when `lead_id` is specified.
- Sorting by `-activity_at` requires `lead_id` parameter.
- Date-based filters must match the sort field (use `activity_at__lt`/`activity_at__gt` only with `_order_by=-activity_at`).

#### Datetime Fields

| Field | Meaning |
|---|---|
| `date_created` | When the activity was created or synced into Close |
| `activity_at` | When the activity actually occurred (e.g. email sent time, meeting start time) |

#### thread_emails Parameter

| Value | Behavior |
|---|---|
| *(not set)* | Returns individual `Email` objects for each email message |
| `true` | Returns `EmailThread` objects + stripped-down `Email` objects |
| `only` | Returns only `EmailThread` objects; no `Email` objects |

#### Custom Activities

`_type` and `_type__in` accept:
- Custom Activity Type IDs (e.g. `actitype_1h5m6uHM9BZOpwVhyRJb4Y`) for a specific custom type
- `Custom` to list all custom activities regardless of type

---

## Call

A Call represents phone interactions. Calls can be made via direct calling, power dialer, or predictive dialer.

### Call Methods

| Value | Description |
|---|---|
| `regular` | Direct calling or incoming calls |
| `power` | Power dialer calls |
| `predictive` | Predictive dialer calls |

### Call Dispositions

| Value | Description |
|---|---|
| `answered` | Call was answered |
| `no-answer` | Call was not answered |
| `vm-answer` | Voicemail reached, no message left (incoming only) |
| `vm-left` | Voicemail was left (incoming) or dropped (outgoing) |
| `busy` | Destination was busy |
| `blocked` | Close blocked the call (e.g. invalid number) |
| `error` | Unexpected error in Close or carrier |
| `abandoned` | Call abandoned (predictive dialer only — no rep available) |

### Call Fields

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique identifier |
| `_type` | string | Activity type (`Call`) |
| `organization_id` | string | Organization ID |
| `lead_id` | string | Associated lead |
| `user_id` | string | Associated user |
| `user_name` | string | User display name |
| `contact_id` | string | Associated contact |
| `created_by` | string | User ID who created |
| `created_by_name` | string | Creator display name |
| `updated_by` | string | User ID who last updated |
| `updated_by_name` | string | Updater display name |
| `date_created` | datetime | Creation timestamp |
| `date_updated` | datetime | Last update timestamp |
| `activity_at` | datetime | When the call occurred |
| `call_method` | string | `regular`, `power`, or `predictive` |
| `disposition` | string | Call outcome (see table above) |
| `outcome_id` | string | Custom user-defined outcome (optional) |
| `status` | string | Call status (defaults to `completed`) |
| `direction` | string | `outbound` or `inbound` |
| `duration` | integer | Call duration in seconds |
| `cost` | decimal | Call cost in US cents |
| `phone` | string | Phone number |
| `source` | string | Call source |
| `local_phone` | string | Local (Close) phone number |
| `remote_phone` | string | Remote (contact) phone number |
| `local_country_iso` | string | ISO country code of local number |
| `remote_country_iso` | string | ISO country code of remote number |
| `recording_url` | string | HTTPS URL to MP3 recording |
| `voicemail_url` | string | URL to voicemail recording |
| `voicemail_duration` | integer | Voicemail duration in seconds |
| `note_html` | string | Rich-text note (HTML subset) |
| `note` | string | Plaintext note |
| `transferred_from` | string | Transfer source |
| `transferred_to` | string | Transfer destination |
| `dialer_id` | string | Dialer session ID |
| `dialer_saved_search_id` | string | Saved search used by dialer |
| `recording_transcript` | object | Call recording transcript (optional, load via `_fields`) |
| `voicemail_transcript` | object | Voicemail transcript (optional, load via `_fields`) |

### Call Transcripts

Not loaded by default. Use `_fields` parameter with `recording_transcript` or `voicemail_transcript`.

**Transcript structure:**

```json
{
  "recording_transcript": {
    "utterances": [
      {
        "speaker_label": "John Lead",
        "speaker_side": "contact",
        "start": 0.1,
        "end": 1.2,
        "text": "Hey, what's up? How is it going?"
      },
      {
        "speaker_label": "Jane User",
        "speaker_side": "close-user",
        "start": 1.3,
        "end": 2.4,
        "text": "Hey John, I'm doing great. How about you?"
      }
    ],
    "summary_text": "Summary text",
    "summary_html": "<p>Summary text</p>"
  }
}
```

| Transcript Field | Type | Description |
|---|---|---|
| `utterances` | array | Array of utterance objects |
| `utterances[].speaker_label` | string | Speaker name |
| `utterances[].speaker_side` | string | `contact` or `close-user` |
| `utterances[].start` | float | Start time in seconds |
| `utterances[].end` | float | End time in seconds |
| `utterances[].text` | string | Spoken text |
| `summary_text` | string | Plaintext summary |
| `summary_html` | string | HTML-formatted summary |

### GET /activity/call/

List or filter all Call activities.

```
GET /activity/call/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

**Response:** `{ "data": [...], "has_more": bool }`

### POST /activity/call/

Log a Call activity manually (for calls made outside of the Close VoIP system).

```
POST /activity/call/
```

| Field | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Required | Lead to associate the call with |
| `status` | string | Optional | Defaults to `completed` |
| `direction` | string | Optional | `outbound` or `inbound` |
| `recording_url` | string | Optional | HTTPS URL to MP3 recording (must start with `https://`) |
| `note_html` | string | Optional | Rich-text note (preferred) |
| `note` | string | Optional | Plaintext note |
| `duration` | integer | Optional | Call duration in seconds |
| `phone` | string | Optional | Phone number called |
| `disposition` | string | Optional | Call outcome |
| `outcome_id` | string | Optional | Custom outcome ID |
| `contact_id` | string | Optional | Contact ID |
| `user_id` | string | Optional | User who made/received the call |

### GET /activity/call/{id}/

Fetch a single Call activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Call activity ID |

### PUT /activity/call/{id}/

Update a Call activity. Most commonly used to update `note_html` or `outcome_id`.

**Restriction:** Fields such as `status`, `duration`, or `direction` **cannot be updated** for internal calls (calls made through Close's VoIP system).

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Call activity ID |
| `note_html` | string | Optional | Rich-text note |
| `note` | string | Optional | Plaintext note |
| `outcome_id` | string | Optional | Custom outcome |

### DELETE /activity/call/{id}/

Delete a Call activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Call activity ID |

---

## Created

Created activities denote the time and method by which a lead was created.

### GET /activity/created/

List or filter all Created activities.

```
GET /activity/created/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### GET /activity/created/{id}/

Fetch a single Created activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Created activity ID |

---

## Email

Email activities represent individual email messages.

### GET /activity/email/

List or filter all Email activities. Returns one object per email message.

```
GET /activity/email/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### POST /activity/email/

Create an Email activity.

```
POST /activity/email/
```

#### Status Values

| Status | Description |
|---|---|
| `inbox` | Log an already received email |
| `draft` | Create a draft email |
| `scheduled` | Send at a scheduled date/time (requires `date_scheduled`) |
| `outbox` | Send immediately (optional `send_in` in seconds, must be < 60) |
| `sent` | Log an already sent email |

#### Request Body Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Required | Lead to associate the email with |
| `status` | string | Required | One of: `inbox`, `draft`, `scheduled`, `outbox`, `sent` |
| `sender` | string | Conditional | Format: `"\"John Smith\" <email@example.com>"`. Required for `inbox`, `scheduled`, `outbox`, `error`. Optional for `draft` and `sent`. |
| `to` | array | Optional | Array of recipient email addresses |
| `cc` | array | Optional | Array of CC email addresses |
| `bcc` | array | Optional | Array of BCC email addresses |
| `subject` | string | Optional | Email subject line |
| `body_text` | string | Optional | Plaintext email body |
| `body_html` | string | Optional | HTML email body |
| `template_id` | string | Optional | Email Template ID (renders server-side if `body_text`/`body_html` omitted) |
| `date_scheduled` | datetime | Conditional | Required when status is `scheduled` |
| `send_in` | integer | Optional | Delay sending by N seconds (max 60, use with `outbox` status) |
| `followup_date` | datetime | Optional | Creates email followup task if no response received |
| `attachments` | array | Optional | Array of attachment objects (see below) |
| `contact_id` | string | Optional | Contact ID |
| `user_id` | string | Optional | User ID |

#### Attachment Object

Files must be uploaded first via the Files API.

| Field | Type | Required | Description |
|---|---|---|---|
| `url` | string | Required | Must begin with `https://app.close.com/go/file/` |
| `filename` | string | Required | File name |
| `content_type` | string | Required | MIME type |
| `size` | integer | Required | File size in bytes |

#### Behavior Notes

- Only drafts can be modified.
- Draft status can change to `scheduled` or `outbox`.
- Scheduled or unsent outbox emails can be canceled by setting status back to `draft`.
- `sender` is required when changing a draft to `scheduled` or `outbox` if not already set.
- Email Templates render server-side when `template_id` is provided without `body_text`/`body_html`.
- `send_in` delays sending by a few seconds (to allow undo).
- `followup_date` triggers an email followup task if no response is received.

### GET /activity/email/{id}/

Fetch a single Email activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Email activity ID |

### PUT /activity/email/{id}/

Update an Email activity. Can modify a draft or send it.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Email activity ID |

**Allowed status changes:**
- Draft -> `scheduled` or `outbox`
- Scheduled/Outbox -> `draft` (to cancel)

### DELETE /activity/email/{id}/

Delete an Email activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Email activity ID |

---

## EmailThread

Email Threads are a collection of Email activities belonging to the same thread. Conversations are generally grouped by subject.

### GET /activity/emailthread/

List or filter all EmailThread activities. Returns one object per email conversation.

```
GET /activity/emailthread/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### GET /activity/emailthread/{id}/

Fetch a single EmailThread activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | EmailThread activity ID |

### DELETE /activity/emailthread/{id}/

Delete an EmailThread activity. **This will also delete all the email activities belonging to this thread.**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | EmailThread activity ID |

---

## LeadStatusChange

Lead Status Changes are created when you change the status of a Lead object.

### GET /activity/status_change/lead/

List or filter all LeadStatusChange activities.

```
GET /activity/status_change/lead/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### POST /activity/status_change/lead/

Create a new LeadStatusChange activity.

> **WARNING:** Creating a lead status change **does NOT change the status of the Lead**. It only logs the status change event in the Lead's activity feed. It should only be used to **import historical status changes** from another organization or system.

| Field | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Required | Lead ID |
| `old_status_id` | string | Required | Previous status ID |
| `new_status_id` | string | Required | New status ID |
| `old_status_label` | string | Optional | Previous status label |
| `new_status_label` | string | Optional | New status label |

### GET /activity/status_change/lead/{id}/

Fetch a single LeadStatusChange activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | LeadStatusChange activity ID |

### DELETE /activity/status_change/lead/{id}/

Delete a single LeadStatusChange activity.

> **WARNING:** Deleting a LeadStatusChange **does NOT change the status of the Lead**. It only removes the status change event from the activity feed. Use only when the change is irrelevant or causing integration problems.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | LeadStatusChange activity ID |

---

## Meeting

A Meeting activity represents calendar events synced with Close. Meetings track statuses, attendees, transcripts, and custom outcomes.

### Meeting Statuses

| Status | Description |
|---|---|
| `upcoming` | Meeting is in the future |
| `in-progress` | Meeting is currently occurring |
| `completed` | Meeting happened and has ended |
| `canceled` | Deleted from all synced calendars, all lead contacts removed, or moved to all-day event |
| `declined-by-lead` | At least one lead contact declined, no other lead contacts accepted |
| `declined-by-org` | All Close users declined to attend |

### Attendee Statuses

| Status | Description |
|---|---|
| `noreply` | Attendee has not replied to the invite |
| `yes` | Attendee accepted |
| `no` | Attendee declined |
| `maybe` | Attendee replied maybe/tentative |

### Meeting Fields

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique identifier |
| `_type` | string | Activity type (`Meeting`) |
| `organization_id` | string | Organization ID |
| `lead_id` | string | Associated lead |
| `user_id` | string | Associated user |
| `contact_id` | string | Associated contact |
| `date_created` | datetime | When the meeting object was created in Close |
| `date_updated` | datetime | When the meeting was last updated in Close |
| `starts_at` | datetime | When the meeting event starts |
| `ends_at` | datetime | When the meeting event ends |
| `activity_at` | datetime | Timeline position (defaults to `starts_at`) |
| `status` | string | Meeting status (see table above) |
| `attendees` | array | Array of attendee objects with status tracking |
| `is_recurring` | boolean | `true` if recurring on Google Calendar |
| `user_note_html` | string | Rich-text meeting notes |
| `outcome_id` | string | Custom user-defined outcome |
| `provider_calendar_event_id` | string | Provider event ID the meeting was synced from |
| `provider_calendar_ids` | array | Provider calendar IDs the meeting was synced from |
| `provider_calendar_type` | string | `"google"` or `"microsoft"` |
| `transcripts` | array | Array of transcript objects (load via `_fields=transcripts`) |

### Meeting Transcripts

Not loaded by default. Use `_fields` parameter with `transcripts` value.

```json
{
  "transcripts": [
    {
      "utterances": [
        {
          "speaker_label": "John Lead",
          "speaker_side": "contact",
          "start": 0.1,
          "end": 1.2,
          "text": "Hey, what's up? How is it going?"
        },
        {
          "speaker_label": "Jane User",
          "speaker_side": "close-user",
          "start": 1.3,
          "end": 2.4,
          "text": "Hey John, I'm doing great. How about you?"
        }
      ],
      "summary_text": "Summary text",
      "summary_html": "<p>Summary text</p>"
    }
  ]
}
```

The `transcripts` field is an array of objects for each Close Notetaker bot that joined. Typically there will be only one transcript. Ordered by time bots joined.

### GET /activity/meeting/

List or filter all Meeting activities.

```
GET /activity/meeting/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### GET /activity/meeting/{id}/

Fetch a single Meeting activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Meeting activity ID |

### PUT /activity/meeting/{id}/

Update a Meeting activity. Most commonly used to update `user_note_html` or `outcome_id`.

| Field | Type | Required | Description |
|---|---|---|---|
| `user_note_html` | string | Optional | Rich-text meeting notes |
| `outcome_id` | string | Optional | Custom outcome ID |

### DELETE /activity/meeting/{id}/

Delete a Meeting activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Meeting activity ID |

### POST /activity/meeting/{id}/integration/

Create or update a third-party Meeting integration.

> **IMPORTANT:** Only **OAuth apps** can perform this operation. Using an API key will result in an error. See Authentication with OAuth.

Third-party integrations appear as tabs titled with the OAuth app name in the activity feed. First invocation creates a new integration; subsequent calls with the same OAuth app update the existing one. Submitting an empty JSON body does nothing.

---

## Note

Note activities are freeform text notes attached to leads.

### Note Fields

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique identifier |
| `_type` | string | Activity type (`Note`) |
| `lead_id` | string | Associated lead |
| `user_id` | string | Associated user |
| `contact_id` | string | Associated contact |
| `note_html` | string | Rich-text note (HTML subset, preferred) |
| `note` | string | Plaintext note |
| `pinned` | boolean | Whether the note is pinned |
| `attachments` | array | Array of attachment objects |
| `date_created` | datetime | Creation timestamp |
| `date_updated` | datetime | Last update timestamp |
| `activity_at` | datetime | When the note occurred |

### GET /activity/note/

List or filter all Note activities.

```
GET /activity/note/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### POST /activity/note/

Create a Note activity.

```
POST /activity/note/
```

| Field | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Required | Lead to associate the note with |
| `note_html` | string | Optional | Rich-text note (preferred, see Rich Text Fields) |
| `note` | string | Optional | Plaintext note |
| `pinned` | boolean | Optional | Pin the note (`true`/`false`) |
| `contact_id` | string | Optional | Contact ID |
| `user_id` | string | Optional | User ID |
| `attachments` | array | Optional | Array of attachment objects |

#### Attachment Object

Files must be uploaded first via the Files API.

| Field | Type | Required | Description |
|---|---|---|---|
| `url` | string | Required | Must begin with `https://app.close.com/go/file/` |
| `filename` | string | Required | File name |
| `content_type` | string | Required | MIME type |

### GET /activity/note/{id}/

Fetch a single Note activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Note activity ID |

### PUT /activity/note/{id}/

Update a Note activity.

| Field | Type | Required | Description |
|---|---|---|---|
| `note_html` | string | Optional | Rich-text note |
| `note` | string | Optional | Plaintext note |
| `pinned` | boolean | Optional | Pin/unpin the note |

### DELETE /activity/note/{id}/

Delete a Note activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | Note activity ID |

---

## OpportunityStatusChange

Opportunity Status Changes are created when you change the status of an Opportunity object.

### GET /activity/status_change/opportunity/

List or filter all OpportunityStatusChange activities.

```
GET /activity/status_change/opportunity/{?lead_id, opportunity_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `opportunity_id` | string | Optional | Filter by opportunity |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### POST /activity/status_change/opportunity/

Create a new OpportunityStatusChange activity.

> **WARNING:** Creating an opportunity status change **does NOT change the status of the Opportunity**. It only logs the status change event in the Lead's activity feed. It should only be used to **import historical status changes** from another organization or system.

| Field | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Required | Lead ID |
| `opportunity_id` | string | Required | Opportunity ID |
| `old_status_id` | string | Required | Previous status ID |
| `new_status_id` | string | Required | New status ID |
| `old_status_label` | string | Optional | Previous status label |
| `new_status_label` | string | Optional | New status label |

### GET /activity/status_change/opportunity/{id}/

Fetch a single OpportunityStatusChange activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | OpportunityStatusChange activity ID |

### DELETE /activity/status_change/opportunity/{id}/

Delete a single OpportunityStatusChange activity.

> **WARNING:** Deleting an OpportunityStatusChange **does NOT change the status of the Opportunity**. It only removes the status change event from the activity feed. Use only if the status change is irrelevant (such as records for a change that has been reverted) and having it in the activity feed is causing integration problems.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | OpportunityStatusChange activity ID |

---

## SMS

SMS activities represent text messages. MMS messages are treated as SMS messages with attachments.

### MMS Attachments

MMS messages have attachments with these fields (identical to email attachments plus extras):

| Field | Type | Description |
|---|---|---|
| `url` | string | Authenticated S3 URL (requires session) |
| `filename` | string | File name |
| `size` | integer | File size in bytes |
| `content_type` | string | MIME type |
| `media_id` | string | Unique attachment identifier |
| `thumbnail_url` | string | Thumbnail URL (if Close generated one; requires session) |

> **Note:** Accessing `url` or `thumbnail_url` requires an authenticated session and leads to a temporarily signed S3 URL.

### GET /activity/sms/

List or filter all SMS activities.

```
GET /activity/sms/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### POST /activity/sms/

Create an SMS activity.

```
POST /activity/sms/{?send_to_inbox}
```

#### Status Values

| Status | Description |
|---|---|
| `inbox` | Log an already received SMS |
| `draft` | Create a draft SMS |
| `scheduled` | Send at scheduled date/time (requires `date_scheduled`) |
| `outbox` | Send immediately (optional `send_in` in seconds, max 60) |
| `sent` | Log an already sent SMS |

#### Request Body Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Required | Lead to associate the SMS with |
| `status` | string | Required | One of: `inbox`, `draft`, `scheduled`, `outbox`, `sent` |
| `text` | string | Optional | SMS message content |
| `template_id` | string | Optional | SMS Template ID (renders instead of `text`) |
| `local_phone` | string | Required | Must be associated with a Phone Number of type `internal` |
| `remote_phone` | string | Optional | Recipient phone number |
| `direction` | string | Optional | Defaults to `inbound` when status=`inbox`, otherwise `outbound` |
| `date_scheduled` | datetime | Conditional | Required when status is `scheduled` |
| `send_in` | integer | Optional | Delay sending by N seconds (max 60) |
| `contact_id` | string | Optional | Contact ID |
| `user_id` | string | Optional | User ID |

#### Query Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `send_to_inbox` | boolean | Optional | Pass `true` to create Inbox Notification when status is `inbox` |

#### Behavior Notes

- Only drafts can be modified.
- Draft status can change to `scheduled` or `outbox`.
- Scheduled or unsent outbox SMS can be canceled by setting status back to `draft`.
- `local_phone` must be associated with a Phone Number of type `internal` (see Phone Numbers).
- `template_id` can be used instead of `text` to auto-render an SMS Template.
- When `direction` is not provided: defaults to `inbound` for `status="inbox"`, otherwise `outbound`.

### GET /activity/sms/{id}/

Fetch a single SMS activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | SMS activity ID |

### PUT /activity/sms/{id}/

Update an SMS activity. Can modify a draft or send it.

| Field | Type | Required | Description |
|---|---|---|---|
| `status` | string | Optional | Change to `outbox` (send now) or `scheduled` (send later) |
| `text` | string | Optional | Updated SMS text |
| `date_scheduled` | datetime | Conditional | Required when changing to `scheduled` |

### DELETE /activity/sms/{id}/

Delete an SMS activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | SMS activity ID |

---

## TaskCompleted

TaskCompleted activities are created when you complete a task on a lead.

### GET /activity/task_completed/

List or filter all TaskCompleted activities.

```
GET /activity/task_completed/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### GET /activity/task_completed/{id}/

Fetch a single TaskCompleted activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | TaskCompleted activity ID |

### DELETE /activity/task_completed/{id}/

Delete a TaskCompleted activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | TaskCompleted activity ID |

---

## LeadMerge

LeadMerge activities are created when you merge one lead into another.

- **Source lead** — the one being merged (will be deleted after merge completes)
- **Destination lead** — the one that remains after the merge
- The `status` field shows the progress of the lead merge

### GET /activity/lead_merge/

List or filter all LeadMerge activities.

```
GET /activity/lead_merge/{?lead_id, user_id, date_created__gt, date_created__lt, _limit, _skip}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |

### GET /activity/lead_merge/{id}/

Fetch a single LeadMerge activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | LeadMerge activity ID |

> **Note:** LeadMerge activities are read-only. There is no POST, PUT, or DELETE endpoint.

---

## WhatsAppMessage

WhatsAppMessage activities represent messages in an external WhatsApp chat. These can be created by WhatsApp integrations to facilitate viewing ongoing WhatsApp conversations within the CRM.

### WhatsAppMessage Fields

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique identifier (format: `acti_...`) |
| `_type` | string | Activity type (`WhatsAppMessage`) |
| `lead_id` | string | Associated lead |
| `user_id` | string | Associated user |
| `contact_id` | string | Associated contact |
| `external_whatsapp_message_id` | string | WhatsApp native message ID |
| `message_markdown` | string | Message body in WhatsApp Markdown format |
| `message_html` | string | HTML representation (read-only) |
| `direction` | string | `incoming` or `outgoing` |
| `attachments` | array | Array of attachment objects |
| `integration_link` | string | URL linking to external system message |
| `response_to_id` | string | Close activity ID of parent WhatsApp message (threading) |
| `date_created` | datetime | Creation timestamp |
| `date_updated` | datetime | Last update timestamp |

### GET /activity/whatsapp_message/

List or filter all WhatsAppMessage activities.

```
GET /activity/whatsapp_message/{?lead_id, user_id, external_whatsapp_message_id, date_created__gt, date_created__lt}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `user_id` | string | Optional | Filter by user |
| `external_whatsapp_message_id` | string | Optional | Filter by WhatsApp message ID (for sync) |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |

### POST /activity/whatsapp_message/

Create a WhatsAppMessage activity.

```
POST /activity/whatsapp_message/{?send_to_inbox}
```

#### Request Body Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Required | Lead to associate the message with |
| `external_whatsapp_message_id` | string | Required | WhatsApp native message ID |
| `message_markdown` | string | Required | Message body in WhatsApp Markdown format |
| `direction` | string | Required | `incoming` or `outgoing` |
| `contact_id` | string | Optional | Contact ID |
| `user_id` | string | Optional | User ID |
| `attachments` | array | Optional | Array of attachment objects (see below) |
| `integration_link` | string | Optional | URL linking back to external system |
| `response_to_id` | string | Optional | Close activity ID of parent WhatsApp message for threading (must be `acti_...` format) |

#### Attachment Object

Files must be uploaded first via the Files API.

| Field | Type | Required | Description |
|---|---|---|---|
| `url` | string | Required | Must begin with `https://app.close.com/go/file/` |
| `filename` | string | Required | File name |
| `content_type` | string | Required | MIME type |

#### Query Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `send_to_inbox` | boolean | Optional | Pass `true` for incoming messages to create Inbox Notification |

#### Constraints

- Total attachment size per message cannot exceed **25MB**.
- Only WhatsApp Markdown messages and file attachments are supported.
- **No support** for Polls, Events, Locations, etc.
- `response_to_id` creates a thread relationship between messages for tracking conversation flow.
- `message_html` (read-only) is automatically generated from `message_markdown`.

### GET /activity/whatsapp_message/{id}/

Fetch a single WhatsAppMessage activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | WhatsAppMessage activity ID |

### PUT /activity/whatsapp_message/{id}/

Update a WhatsAppMessage activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | WhatsAppMessage activity ID |

### DELETE /activity/whatsapp_message/{id}/

Delete a WhatsAppMessage activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | WhatsAppMessage activity ID |

---

## FormSubmission

A FormSubmission activity is created automatically when someone submits a form through Close forms.

> **IMPORTANT:** FormSubmissions are created by the system when a form is submitted. They **cannot be created or modified** through the API. Only read (GET) and delete (DELETE) operations are available.

### FormSubmission Fields

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique identifier |
| `_type` | string | Activity type (`FormSubmission`) |
| `lead_id` | string | Associated lead |
| `contact_id` | string | Associated contact |
| `organization_id` | string | Organization ID |
| `form_id` | string | ID of the form that was submitted |
| `values` | object | Submitted form data as key-value pairs. Keys are form field IDs (e.g. `formfld_0325NAK2ePwMEBJrZZCk5F`), values are user submissions. |
| `ip_address` | string | IP address of the submitter |
| `origin` | string | Origin header from the submission request |
| `source_url` | string | Full URL where the form was submitted |
| `source_url_normalized` | string | Read-only. Computed domain + path from `source_url` |
| `date_created` | datetime | Creation timestamp |
| `date_updated` | datetime | Last update timestamp |

### GET /activity/form_submission/

List or filter all FormSubmission activities.

```
GET /activity/form_submission/{?lead_id, contact_id, organization_id, form_id, form_id__in, date_created__gt, date_created__lt, _limit, _skip, _fields}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lead_id` | string | Optional | Filter by lead |
| `contact_id` | string | Optional | Filter by contact |
| `organization_id` | string | Optional | Filter by organization |
| `form_id` | string | Optional | Filter by specific form |
| `form_id__in` | string | Optional | Filter by multiple forms |
| `date_created__gt` | datetime | Optional | Created after timestamp |
| `date_created__lt` | datetime | Optional | Created before timestamp |
| `_limit` | integer | Optional | Pagination limit |
| `_skip` | integer | Optional | Pagination offset |
| `_fields` | string | Optional | Specify which fields to return |

### GET /activity/form_submission/{id}/

Fetch a single FormSubmission activity.

```
GET /activity/form_submission/{id}/{?_fields}
```

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | FormSubmission activity ID |
| `_fields` | string (query) | Optional | Specify which fields to return |

### DELETE /activity/form_submission/{id}/

Delete a FormSubmission activity.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | string (path) | Required | FormSubmission activity ID |

---

## Endpoint Summary

| Activity Type | List (GET) | Create (POST) | Fetch (GET) | Update (PUT) | Delete (DELETE) |
|---|---|---|---|---|---|
| All Activities | `/activity/` | -- | -- | -- | -- |
| Call | `/activity/call/` | `/activity/call/` | `/activity/call/{id}/` | `/activity/call/{id}/` | `/activity/call/{id}/` |
| Created | `/activity/created/` | -- | `/activity/created/{id}/` | -- | -- |
| Email | `/activity/email/` | `/activity/email/` | `/activity/email/{id}/` | `/activity/email/{id}/` | `/activity/email/{id}/` |
| EmailThread | `/activity/emailthread/` | -- | `/activity/emailthread/{id}/` | -- | `/activity/emailthread/{id}/` |
| LeadStatusChange | `/activity/status_change/lead/` | `/activity/status_change/lead/` | `/activity/status_change/lead/{id}/` | -- | `/activity/status_change/lead/{id}/` |
| Meeting | `/activity/meeting/` | -- | `/activity/meeting/{id}/` | `/activity/meeting/{id}/` | `/activity/meeting/{id}/` |
| Note | `/activity/note/` | `/activity/note/` | `/activity/note/{id}/` | `/activity/note/{id}/` | `/activity/note/{id}/` |
| OpportunityStatusChange | `/activity/status_change/opportunity/` | `/activity/status_change/opportunity/` | `/activity/status_change/opportunity/{id}/` | -- | `/activity/status_change/opportunity/{id}/` |
| SMS | `/activity/sms/` | `/activity/sms/` | `/activity/sms/{id}/` | `/activity/sms/{id}/` | `/activity/sms/{id}/` |
| TaskCompleted | `/activity/task_completed/` | -- | `/activity/task_completed/{id}/` | -- | `/activity/task_completed/{id}/` |
| LeadMerge | `/activity/lead_merge/` | -- | `/activity/lead_merge/{id}/` | -- | -- |
| WhatsAppMessage | `/activity/whatsapp_message/` | `/activity/whatsapp_message/` | `/activity/whatsapp_message/{id}/` | `/activity/whatsapp_message/{id}/` | `/activity/whatsapp_message/{id}/` |
| FormSubmission | `/activity/form_submission/` | -- | `/activity/form_submission/{id}/` | -- | `/activity/form_submission/{id}/` |
| Meeting Integration | -- | `/activity/meeting/{id}/integration/` | -- | -- | -- |

---

## Common Query Parameters (All List Endpoints)

| Parameter | Type | Description |
|---|---|---|
| `lead_id` | string | Filter by lead ID |
| `user_id` | string | Filter by user ID |
| `date_created__gt` | datetime | Created after this timestamp |
| `date_created__lt` | datetime | Created before this timestamp |
| `_limit` | integer | Number of results per page |
| `_skip` | integer | Number of results to skip (offset) |

## Common Response Format

```json
{
  "has_more": false,
  "data": [
    { ... activity object ... }
  ]
}
```

## Authentication Example

```bash
# All endpoints require Basic Auth with API key
curl "https://api.close.com/api/v1/activity/call/" \
  -u "your_api_key:"
```

The colon after the API key is required (key is username, password is empty).


---


# Close CRM API — Features Documentation

> **Source:** https://developer.close.com
> **Date scraped:** 2026-03-30
> **Base URL:** `https://api.close.com/api/v1`
> **Auth:** Basic Auth with API key as username, empty password
> **Note:** The "Example Request/Response" sections on the Close developer site are rendered via client-side JavaScript and cannot be statically extracted. This document captures ALL endpoint definitions, parameters, field types, behavioral notes, and code examples that are present in the documentation.

---

## Table of Contents

1. [Email Templates](#1-email-templates)
2. [SMS Templates](#2-sms-templates)
3. [Connected Accounts](#3-connected-accounts)
4. [Send As](#4-send-as)
5. [Sequences](#5-sequences)
6. [Dialer](#6-dialer)
7. [Smart Views](#7-smart-views)
8. [Bulk Actions](#8-bulk-actions)
9. [Integration Links](#9-integration-links)
10. [Exports](#10-exports)
11. [Phone Numbers](#11-phone-numbers)
12. [Files](#12-files)
13. [Comments](#13-comments)
14. [Unsubscribe Email Address](#14-unsubscribe-email-address)
15. [Rich Text Fields](#15-rich-text-fields)
16. [Field Enrichment](#16-field-enrichment)

---

## 1. Email Templates

Email Templates are predefined emails that can be used over and over again when sending email. They save time when sending emails one at a time via the Close UI, and they are also used when initiating a single Bulk Email.

### List Email Templates

```
GET /email_template/{?is_archived, _limit, _skip}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `is_archived` | boolean | No | Filter by archived status |
| `_limit` | integer | No | Pagination limit |
| `_skip` | integer | No | Pagination offset |

### Create Email Template

```
POST /email_template/
```

Creates a new email template. Request body should include template name, subject, and body content.

### Fetch Email Template

```
GET /email_template/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Email template ID |

### Update Email Template

```
PUT /email_template/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Email template ID |

### Delete Email Template

```
DELETE /email_template/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Email template ID |

### Render Email Template

Render an email template for the given lead/contact using the current user context.

```
GET /email_template/{id}/render/{?lead_id, contact_id, query, entry, mode}
```

Accepts two forms of usage:

**Single lead/contact:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Email template ID |
| `lead_id` | string | Yes | Lead ID to render for |
| `contact_id` | string | Yes | Contact ID to render for |

**Preview results from a search query:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Email template ID |
| `query` | string | Yes | Search query string |
| `entry` | integer | No | Index (0-99) into search results |
| `mode` | string | No | `lead` (default) or `contact` |

**Mode behavior:**
- `lead` (default): The first contact of the lead with the index given by `entry` will be rendered (excluding leads that have no email addresses).
- `contact`: `entry` refers to the index of the contact (excluding contacts that have no emails). Will return an empty dict if there are no more entries.

---

## 2. SMS Templates

SMS Templates are predefined messages that can be used over and over again when sending SMS. They save time when sending sms one at a time via the Close UI.

### List SMS Templates

```
GET /sms_template/{?_limit, _skip}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | No | Pagination limit |
| `_skip` | integer | No | Pagination offset |

### Create SMS Template

```
POST /sms_template/
```

Creates a new SMS template.

### Fetch SMS Template

```
GET /sms_template/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | SMS template ID |

### Update SMS Template

```
PUT /sms_template/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | SMS template ID |

### Delete SMS Template

```
DELETE /sms_template/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | SMS template ID |

---

## 3. Connected Accounts

This endpoint can be used to pull information about the Email and Zoom accounts you currently have connected under Settings > Connected Accounts in Close and Email accounts you have the ability to send as via the Send As functionality.

### Account Types

Connected Accounts have the following possible values for `_type`:

| `_type` Value | Description |
|---------------|-------------|
| `google` | Gmail account using Google OAuth to connect to Close |
| `custom_email` | Non-Gmail email account (e.g. Mailgun, Sendgrid integrations) |
| `zoom` | Zoom account using the Zoom Integration |
| `microsoft` | Microsoft account using Microsoft OAuth to connect to Close |
| `calendly` | Calendly account using Calendly OAuth to connect to Close |

**Note:** `google` and `microsoft` connected accounts have a `synced_calendars` field that contains which calendars are synced in as part of Meetings Sync.

### List Connected Accounts

```
GET /connected_account/{?user_id}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `user_id` | string | No | Filter to a specific user's connected accounts |

Returns all connected accounts you can use in your organization.

### Fetch Connected Account

```
GET /connected_account/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Connected account ID |

---

## 4. Send As

The Send As feature allows a user to explicitly allow another user to send individual emails, bulk emails, and sequence emails as them. Send As permission must be explicitly granted by the user that's allowing another user to send as them. This permission can be revoked by the allowing user at any time.

### List Send As Associations

```
GET /send_as/{?allowing_user_id, allowed_user_id}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `allowing_user_id` | string | No | User ID of the person allowing others to send as them |
| `allowed_user_id` | string | No | User ID of the person allowed to send as another |

**Behavior:** A user only has access to associations they are involved in. This means `allowing_user_id` or `allowed_user_id` must be equal to your user ID. If neither filter is provided, `allowing_user_id` is assumed by default.

### Create Send As Association

```
POST /send_as/
```

**Constraint:** The `allowing_user_id` must be equal to your user ID.

### Delete Send As Association by Users

```
DELETE /send_as/{?allowing_user_id, allowed_user_id}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `allowing_user_id` | string | Yes | Must equal your user ID |
| `allowed_user_id` | string | Yes | User to revoke permission from |

### Retrieve Single Send As Association

```
GET /send_as/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Association ID |

### Delete Send As Association by ID

```
DELETE /send_as/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Association ID |

### Bulk Edit Send As Associations

```
POST /send_as/bulk/
```

You can allow and disallow many other users to send as you in a single command by supplying the user IDs you want to allow and disallow.

Once completed, this endpoint returns all existing associations where your user is the allowing user.

---

## 5. Sequences

A Sequence is a series of steps to be performed, one by one, in specified time gaps to specific subscribers until they reply. Steps may involve sending an email to or calling a subscriber.

### List Sequences

```
GET /sequence/{?_limit, _skip}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | No | Pagination limit |
| `_skip` | integer | No | Pagination offset |

### Create Sequence

```
POST /sequence/
```

Creates a new sequence with steps, schedule, and configuration.

### Fetch Sequence

```
GET /sequence/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Sequence ID |

### Update Sequence

```
PUT /sequence/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Sequence ID |

**IMPORTANT:** If you include `steps` in the payload and exclude some of the existing steps in your sequence, it will remove those steps from the sequence entirely.

### Delete Sequence

```
DELETE /sequence/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Sequence ID |

### List Sequence Subscriptions

```
GET /sequence_subscription/{?sequence_id, contact_id, lead_id}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `sequence_id` | string | Conditional | Sequence to filter by (at least one filter required) |
| `contact_id` | string | Conditional | Contact to filter by (at least one filter required) |
| `lead_id` | string | Conditional | Lead to filter by (at least one filter required) |

**Note:** At least one of `sequence_id`, `contact_id`, and `lead_id` is required.

### Subscribe Contact to Sequence

```
POST /sequence_subscription/
```

Subscribes a contact to a sequence.

### Fetch Sequence Subscription

```
GET /sequence_subscription/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Subscription ID |

### Update Sequence Subscription

```
PUT /sequence_subscription/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Subscription ID |

---

## 6. Dialer

A dialer is associated with a specific Smart View or Shared Entry and automatically calls each lead or contact in it for you. This allows you to call targets in a Smart View or Shared Entry faster.

Once the dialer for a Smart View or Shared Entry is initiated, it starts making calls to each target that belongs to it and connects you to the call once someone picks up.

### Dialer Types

| Type | Behavior |
|------|----------|
| `power` | Calls one lead in the Smart View at a time |
| `predictive` | Calls multiple leads simultaneously and connects you with the first lead that answers |

### Source Types

| `source_type` | Description |
|----------------|-------------|
| `saved-search` | Smart Views |
| `shared-entry` | Shared Entries |

### List or Filter Dialer Sessions

```
GET /dialer/{?status, status__in, source_value, source_type, user_id, _limit, _skip}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string | No | Filter by status |
| `status__in` | string | No | Filter by multiple statuses (comma-separated) |
| `source_value` | string | No | Filter by source value (Smart View or Shared Entry ID) |
| `source_type` | string | No | `saved-search` or `shared-entry` |
| `user_id` | string | No | Filter by user |
| `_limit` | integer | No | Pagination limit |
| `_skip` | integer | No | Pagination offset |

### Get Single Dialer Session

```
GET /dialer/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Dialer session ID |

**Note:** Once you have a `source_value` for a dialer session and `source_type=saved-search`, you can use the saved_search endpoint (`/saved_search/{id}/`) to find out more information about the Smart View being used.

**Response includes:** the `source_value` and `source_type` used in the dialer session, the type of the dialer sessions, the users included in the session, and more.

---

## 7. Smart Views

Smart Views are "saved search queries" in Close and show up in the sidebar in the UI. They can be private for a user or shared with an entire Organization. Smart Views can filter by leads or contacts.

### List Smart Views

```
GET /saved_search/{?type, type__in}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `type` | string | No | `lead` or `contact` (defaults to `lead`) |
| `type__in` | string | No | Comma-separated multiple types, e.g. `lead,contact` |

### Create Smart View

```
POST /saved_search/
```

Create a Lead or Contact Smart View.

For Lead Smart Views, the `type` field is optional (since `lead` is the default `type`).

**IMPORTANT:** When creating a Smart View, you must specify that you want to get objects of the appropriate type via an `object_type` clause as per the Advanced Filtering section.

### Get Single Smart View

```
GET /saved_search/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Smart View ID |

### Update Smart View

```
PUT /saved_search/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Smart View ID |

### Delete Smart View

```
DELETE /saved_search/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Smart View ID |

---

## 8. Bulk Actions

Bulk actions are used to perform an "action" (send an email, update a lead status, etc.) on a number of leads.

### Lead Filtering

To initiate bulk actions for a subset of leads you need to provide the structured filtering values that you would normally send to the Advanced Filtering API endpoint such as `query`, `results_limit`, and `sort` fields.

The only difference is that Bulk Actions endpoints require you to rename the `query` field to `s_query` (shorthand for structured query).

**Advanced Filtering API payload:**

```json
{
    "query": {
        "queries": [...]
    },
    "results_limit": 100,
    "sort": [
        { ... }
    ]
}
```

**Equivalent Bulk Actions payload (note `query` -> `s_query`):**

```json
{
    "s_query": {
        "queries": [...]
    },
    "results_limit": 100,
    "sort": [
        { ... }
    ]
}
```

### Pausing and Resuming

You can pause an in-progress bulk action by sending `{ "status": "paused" }`. You can also resume it afterwards (`{ "status": "resuming" }`), unless more than 7 days passed since you paused the action.

### Email Confirmation

Use `"send_done_email": false` if you don't want to get a confirmation email after a bulk action is done.

---

### Bulk Emails

#### List Bulk Emails

```
GET /bulk_action/email/
```

#### Initiate New Bulk Email

```
POST /bulk_action/email/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `contact_preference` | string | No | `lead` (only email the primary/first contact email of the lead) or `contact` (email the first contact email of each contact of the lead) |
| `s_query` | object | No | Structured query for lead filtering |
| `results_limit` | integer | No | Max number of leads to process |
| `sort` | array | No | Sort specification |
| `send_done_email` | boolean | No | Set to `false` to skip confirmation email |

#### Fetch Single Bulk Email

```
GET /bulk_action/email/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Bulk email action ID |

---

### Bulk Sequence Subscriptions

#### List Bulk Sequence Subscriptions

```
GET /bulk_action/sequence_subscription/
```

#### Initiate New Bulk Sequence Subscription

```
POST /bulk_action/sequence_subscription/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `action_type` | string | Yes | One of: `subscribe`, `resume`, `resume_finished`, `pause` |
| `sequence_id` | string | Conditional | Required if `action_type` is `subscribe`. Optional for resume/pause (if omitted, applies to all sequences) |
| `sender_account_id` | string | Conditional | Required if `action_type` is `subscribe` |
| `sender_name` | string | Conditional | Required if `action_type` is `subscribe` |
| `sender_email` | string | Conditional | Required if `action_type` is `subscribe` |
| `contact_preference` | string | Conditional | Required if `action_type` is `subscribe`. `lead` (only subscribe primary/first contact) or `contact` (subscribe primary email of each contact) |
| `s_query` | object | No | Structured query for lead filtering |
| `send_done_email` | boolean | No | Set to `false` to skip confirmation email |

**`action_type` values:**
- `subscribe` — create a new sequence subscription for contacts that have never received the given sequence
- `resume` — resume any paused sequence subscriptions for the given sequence or all sequences if `sequence_id` is not provided
- `resume_finished` — resume any finished sequence subscriptions for the given sequence or all sequences if `sequence_id` is not provided
- `pause` — pause any active sequence subscriptions for the given sequence or all sequences if `sequence_id` is not provided

#### Fetch Single Bulk Sequence Subscription

```
GET /bulk_action/sequence_subscription/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Bulk sequence subscription action ID |

---

### Bulk Deletes

#### List Bulk Deletes

```
GET /bulk_action/delete/
```

#### Initiate New Bulk Delete

```
POST /bulk_action/delete/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `s_query` | object | No | Structured query for lead filtering |
| `send_done_email` | boolean | No | Set to `false` to skip confirmation email |

#### Fetch Single Bulk Delete

```
GET /bulk_action/delete/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Bulk delete action ID |

---

### Bulk Edits

#### List Bulk Edits

```
GET /bulk_action/edit/
```

#### Initiate New Bulk Edit

```
POST /bulk_action/edit/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `type` | string | Yes | One of: `set_lead_status`, `clear_custom_field`, `set_custom_field` |
| `s_query` | object | No | Structured query for lead filtering |
| `send_done_email` | boolean | No | Set to `false` to skip confirmation email |

**Additional parameters by `type`:**

**`set_lead_status`** — Sets the Lead Status on all matching leads.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `lead_status_id` | string | Yes | ID of the Lead Status to use |

**`clear_custom_field`** — Clears/removes/unsets a specific custom field from all leads.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string | Conditional | ID of the custom field to remove (use this OR `custom_field_name`) |
| `custom_field_name` | string | Conditional | Exact name of the custom field to remove (use this OR `custom_field_id`) |

**`set_custom_field`** — Sets/updates/adds a specific custom field on all leads.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string | Conditional | ID of the custom field (use this OR `custom_field_name`) |
| `custom_field_name` | string | Conditional | Exact name of the custom field (use this OR `custom_field_id`) |
| `custom_field_value` | any | Yes | New value for the field. Use `custom_field_values` for multiple values |
| `custom_field_values` | array | No | Multiple values for fields that support it |
| `custom_field_operation` | string | No | `replace` (default), `add`, or `remove`. Only applicable for custom fields that accept multiple values |

#### Fetch Single Bulk Edit

```
GET /bulk_action/edit/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Bulk edit action ID |

---

## 9. Integration Links

This endpoint can be used to set up integration links available in Close. Each link has a `name` (displayed as link text), `url` template, and a `type`.

### Link Types

| Type | Description |
|------|-------------|
| `lead` | Link appears on lead pages |
| `contact` | Link appears on contact pages |
| `opportunity` | Link appears on opportunity pages |

**Note:** You can only create/edit/delete integration links if you're an admin.

### List Integration Links

```
GET /integration_link/
```

Returns all integration links for your organization.

### Create Integration Link

```
POST /integration_link/
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Display text for the link |
| `url` | string | Yes | URL template for the link |
| `type` | string | Yes | `lead`, `contact`, or `opportunity` |

### Get Single Integration Link

```
GET /integration_link/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Integration link ID |

### Update Integration Link

```
PUT /integration_link/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Integration link ID |

### Delete Integration Link

```
DELETE /integration_link/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Integration link ID |

---

## 10. Exports

This endpoint can be used to export data out of Close.

### Export Leads, Contacts, or Opportunities (by Lead Query)

```
POST /export/lead/
```

You will receive a link to the generated file via email once the export is done. The exported file is GZIP compressed. The `content-encoding` HTTP header will be set to `gzip` and the `content-type` HTTP header will be set to `text/csv` for CSV exports or `application/json` for JSON exports.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `format` | string | Yes | `csv` or `json` |
| `type` | string | Yes | `leads`, `contacts`, or `lead_opps` |
| `s_query` | object | No | Structured query for lead filtering (Advanced Filtering API format with `query` renamed to `s_query`) |
| `results_limit` | integer | No | Max number of results |
| `sort` | array | No | Sort specification |
| `date_format` | string | No | `original` (default), `iso8601`, or `excel`. Only works with CSV format |
| `fields` | array | No | Specific fields to export |
| `include_activities` | boolean | No | Include activities in export. JSON format only, `leads` type only |
| `include_smart_fields` | boolean | No | Include calculated/smart fields |
| `send_done_email` | boolean | No | Set to `false` to skip confirmation email (default: `true`) |

**`type` values:**
- `leads` — For CSV: one row per lead. For JSON: recommended type, superset of other types.
- `contacts` — For CSV: one row per contact.
- `lead_opps` — For CSV: one row per opportunity.

### Date Format Specifications

**`original` (default):**
- Date: `[YYYY]-[MM]-[DD]`
- Date with time: `[YYYY]-[MM]-[DD] [hh]:[mm]:[ss.sssss]+/-[hh]:[mm]`
- Includes microseconds and timezone information.

**`iso8601` (recommended):**
- Date: `[YYYY]-[MM]-[DD]`
- Date with time: `[YYYY]-[MM]-[DD]T[hh]:[mm]:[ss]+/-[hh]:[mm]`
- ISO 8601 compatible, no microseconds.

**`excel`:**
- Date: `[YYYY]-[MM]-[DD]`
- Date with time: `[YYYY]-[MM]-[DD] [hh]:[mm]:[ss] [AM|PM]`
- Always UTC, no timezone info, no microseconds, 12-hour clock.

### Export Opportunities (by Opportunity Filters)

```
POST /export/opportunity/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `format` | string | Yes | `csv` or `json` |
| `params` | object | No | Filter dictionary for the `/opportunity/` endpoint |
| `date_format` | string | No | `original` (default), `iso8601`, or `excel`. Only works with CSV format |
| `fields` | array | No | Specific fields to export |
| `send_done_email` | boolean | No | Set to `false` to skip confirmation email |

### Get Single Export

```
GET /export/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Export ID |

**Response fields:**

| Field | Type | Description |
|-------|------|-------------|
| `status` | string | One of: `created`, `started`, `in_progress`, `done`, `error` |
| `download_url` | string | Link to the exported file (available when status is `done`) |

### List All Exports

```
GET /export/{?_limit, _skip}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | No | Pagination limit |
| `_skip` | integer | No | Pagination offset |

---

## 11. Phone Numbers

This endpoint shows you all the phone numbers that exist in your organization and lets you rent new numbers. It lets you label them and configure their settings.

### Phone Number Types

| Type | Description |
|------|-------------|
| `internal` | Owned and controlled by Close |
| `external` | Owned by you, can only be used for outbound Close calls as a caller ID (e.g. your company cell phone number) |
| `virtual` | Owned by you, but calls are routed to Close via BYOC |

### Group Numbers

Whether a phone number belongs to an individual user or a group is determined by the `is_group_number` boolean. If a phone number is a group number, it will list all participating users' IDs in `participants` and all participating phone numbers in `phone_numbers`.

### List or Search Phone Numbers

```
GET /phone_number/{?number, user_id, is_group_number, _limit, _skip}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `number` | string | No | Filter by phone number |
| `user_id` | string | No | Filter by user ID |
| `is_group_number` | boolean | No | Filter by group number status |
| `_limit` | integer | No | Pagination limit |
| `_skip` | integer | No | Pagination offset |

### Retrieve Single Phone Number

```
GET /phone_number/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Phone number ID |

### Update Phone Number

```
PUT /phone_number/{id}/
```

**Permission:** You need the "Manage Group Phone Numbers" permission to update a group number. You can only update your own personal numbers.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `label` | string | No | Label for the number |
| `forward_to` | string | No | Call forwarding destination phone number |
| `forward_to_enabled` | boolean | No | Enable/disable call forwarding |
| `voicemail_greeting_url` | string | No | HTTPS URL to an MP3 recording for voicemail greeting |
| `participants` | array[string] | No | User IDs for group numbers |
| `phone_numbers` | array[string] | No | Phone numbers in E.164 format (e.g. `+16503334444`) for group numbers |

### Delete Phone Number

```
DELETE /phone_number/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Phone number ID |

**Permission:** You need the "Manage Group Phone Numbers" permission to delete a group number. You can only delete your own personal numbers.

### Rent Internal Phone Number

```
POST /phone_number/request/internal/
```

**Note:** Renting a phone number incurs a cost. You need the "Manage Group Phone Numbers" permission to rent group numbers.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `country` | string | Yes | Two-letter ISO country code (e.g. `US`) |
| `sharing` | string | Yes | `personal` (belongs to individual user) or `group` (group number) |
| `prefix` | string | No | Phone number prefix or area code, not including country code |
| `with_sms` | boolean | No | Force SMS capability. By default, SMS-capable numbers are rented if Close supports SMS for the country. Set to `false` to rent non-SMS numbers in SMS-supported countries |
| `with_mms` | boolean | No | Force MMS capability. By default, MMS-capable numbers are rented if Close supports MMS for the country. Set to `false` to rent non-MMS numbers |

**Response codes:**
- `201` — Number successfully rented, response contains the new number.
- `4xx` — Number not rented, response contains a `status` field.

**Error status values:**

| Status | Description |
|--------|-------------|
| `has-voice-only` | Country/prefix combination only has non-SMS-capable numbers. Retry with `with_sms: false` |
| `needs-more-info` | More information (e.g. proof of address) needed. Contact Close support |
| `billing-error` | Billing error (e.g. telephony budget reached, insufficient funds) |
| `error` | General error. Human-readable message in the `error` field |

---

## 12. Files

Close users wishing to attach files to outgoing emails or other objects via the Close API must first upload these files using the Files API. Files will be uploaded to a Close-provided Amazon S3 bucket.

### Upload Workflow

1. Make a POST request to `/files/upload/` with the `filename` and `content_type` of the file.
2. Use the response data to construct a `multipart/form-data` POST request to the S3 URL provided in `upload.url`. All fields in `upload.fields` must be included. This request must be made **within 60 seconds**.
3. Once uploaded successfully (201 HTTP status), the file is available for up to **24 hours**. Use the `download.url` value when referencing the file in other API endpoints.

**IMPORTANT:** Attempting to use a file before the S3 upload has been made successfully will result in a failed request to the Close API.

### Generate Signed S3 POST

```
POST /files/upload/
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `filename` | string | Yes | Name of the file being uploaded |
| `content_type` | string | Yes | MIME type of the file (e.g. `image/jpeg`) |

**Response schema:**

```json
{
    "upload": {
        "url": "string (S3 endpoint URL)",
        "fields": { "object (form fields for S3 request)" }
    },
    "download": {
        "url": "string (URL to reference this file in other API endpoints)"
    }
}
```

### Complete Code Example (Python)

```python
from closeio_api import Client
import requests

api = Client("YOUR_API_KEY")
files_upload_response = api.post("files/upload", {
    "filename": "image.jpg",
    "content_type": "image/jpeg"
})

# Use the data in the response to construct a multipart/form-data POST request
s3_upload_response = requests.post(
    files_upload_response["upload"]["url"],
    data=files_upload_response["upload"]["fields"],
    files={
      "file": ("image.jpg", open("path/to/image.jpg", "rb"), "image/jpeg")
    }
)
assert s3_upload_response.status_code == 201

# The file will be available for use in other API endpoints, for example below
# when creating an email activity.
email_create_response = api.post("activity/email", data={
    "attachments": [{
        "url": files_upload_response["download"]["url"],
        "filename": "image.jpg",
        "size": 1108447,
        "content_type": "image/jpeg"
    }],
    "contact_id": "cont_8NNOJnVwmHQEYuVOgJ4B4zU7g9RUxYH4JnPjza5Vr6t",
    "lead_id": "lead_KwD00BYbXCHiPWj68LxFkxaeWuULpZ7awzm6LqeFs0h",
    "user_id": "user_N6KhMpzHRCYQHdn4gRNIFNN5JExnsrprKA6ekxM63XA",
    "direction": "outgoing",
    ...
})
```

### Key Constraints

- S3 upload must be completed within **60 seconds** of the `/files/upload/` request.
- Files remain available for a maximum of **24 hours** after upload.
- The S3 upload must return HTTP status **201** to confirm success.
- File must be uploaded to S3 before referencing it in other API endpoints.

---

## 13. Comments

Comments may be left on a variety of object types in Close.

### Threading Model

The commenting feature is modeled as threads with comments, where:
- Each thread is associated with a specific object and has one or more comments.
- A comment may not exist without a thread.
- A thread may not exist without any comments.
- Threads are maintained automatically when creating or removing individual comments.

Comment bodies are formatted as rich text, and may include basic styling and user/group mentions. The `object_type` of the commented-on object is included in the thread, and should match up with the object types described in the event log docs.

### Fetch Multiple Comment Threads

```
GET /comment_thread/{?object_ids, ids, _limit, _skip}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `object_ids` | string | No | Comma-separated object IDs to filter threads |
| `ids` | string | No | Comma-separated thread IDs |
| `_limit` | integer | No | Pagination limit |
| `_skip` | integer | No | Pagination offset |

### Fetch Individual Comment Thread

```
GET /comment_thread/{thread_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `thread_id` | string | Yes | Comment thread ID |

### Fetch Multiple Comments

```
GET /comment/{?object_id, thread_id}
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `object_id` | string | Conditional | Object ID to filter comments (exactly one of `object_id` or `thread_id` required) |
| `thread_id` | string | Conditional | Thread ID to filter comments (exactly one of `object_id` or `thread_id` required) |

**Note:** Comments may be fetched by `object_id` (the object that was commented on) or by `thread_id`. Exactly one of those filters must be provided.

### Create Comment

```
POST /comment/
```

Create a comment on an object. If a comment thread already exists on that object, a new comment is added to the existing thread. If no thread exists yet, one is created automatically.

### Fetch Individual Comment

```
GET /comment/{comment_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `comment_id` | string | Yes | Comment ID |

### Update Comment

```
PUT /comment/{comment_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `comment_id` | string | Yes | Comment ID |

**Note:** You can use this endpoint to edit a comment body. Users may only update their own comments.

### Remove Comment

```
DELETE /comment/{comment_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `comment_id` | string | Yes | Comment ID |

**Behavior:** Contrary to the HTTP verb, this does not necessarily delete a comment (but it will remove it). Comment bodies are removed, but the comment object still exists until all comments in a thread are removed (at which point the entire thread is deleted).

**Permissions:** Permissions around removing comments inherit from the user's permission to delete their own or other users' activities.

---

## 14. Unsubscribe Email Address

Unsubscribe email addresses from receiving messages from Close.

### List All Unsubscribed Emails

```
GET /unsubscribe/email/
```

Get a list of unsubscribed email addresses.

### Unsubscribe an Email Address

```
POST /unsubscribe/email/
```

This is useful for when you have an email address that has unsubscribed in another context (like a mailing list) and you want to unsubscribe them from messages from Close as well.

### Resubscribe an Email Address

```
DELETE /unsubscribe/email/{email_address}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `email_address` | string | Yes | The email address to resubscribe |

---

## 15. Rich Text Fields

In many places, the application allows users to compose using rich text. In particular, within note activities and notes on calls or meetings.

These rich text fields are exposed as strings, where the content is a restricted subset of XHTML.

### Format Requirements

All fields **must** begin and end with `<body></body>` tags.

### Supported HTML Elements

| Element | Description |
|---------|-------------|
| `<body>` | Required wrapper for all rich text content |
| `<h1>` | Heading level 1 |
| `<p>` | Paragraph |
| `<em>` | Emphasis (italic) |
| `<strong>` | Strong emphasis (bold) |
| `<b>` | Bold text |
| `<i>` | Italic text |
| `<u>` | Underlined text |
| `<s>` | Strikethrough text |
| `<span>` | Inline element with style attributes (e.g. color) |
| `<code>` | Code snippet |
| `<a>` | Hyperlink (with `href` attribute) |
| `<img>` | Image (with `src` and `alt` attributes) |
| `<hr>` | Horizontal rule |
| `<ul>` | Unordered list |
| `<li>` | List item |

### Mentions

Rich text fields support mentioning users or groups using a special `<span>` element:

```html
<span data-type="mention" data-id="group_xxxx" data-label="Engineers" class="mention">
  @Engineers
</span>
```

| Attribute | Description |
|-----------|-------------|
| `data-type` | Must be `"mention"` |
| `data-id` | ID of the user or group being mentioned (e.g. `group_xxxx`, `user_xxxx`) |
| `data-label` | Display label for the mention |
| `class` | Must be `"mention"` |

### Complete Example

```xml
<body>
  <h1>HTML Notes Example</h1>
  <p>
    This is an <em>example</em> note. It includes various elements like
    <strong>strong emphasis</strong>, images, and links.
  </p>
  <p>
    Here's a list of some inline elements you can use:
  </p>
  <ul>
    <li><b>Bold text</b></li>
    <li><i>Italic text</i></li>
    <li><u>Underlined text</u></li>
    <li><s>Strikethrough text</s></li>
    <li><span style="color: red;">Colored text</span></li>
    <li><code>example_function()</code></li>
  </ul>
  <p>
    And don't forget about links! Here's an example:
    <a href="http://www.example.com">Click me!</a>
  </p>
  <p>
    You can also include images:
    <img src="http://www.example.com/image.jpg" alt="Example Image" />
  </p>
  <hr />
  <p>
    Finally, many rich text fields support mentioning users or groups cc
    <span
      data-type="mention"
      data-id="group_xxxx"
      data-label="Engineers"
      class="mention"
    >
      @Engineers
    </span>
  </p>
</body>
```

---

## 16. Field Enrichment

Field Enrichment uses AI to intelligently populate fields on leads and contacts.

The Field Enrichment API waits for the enrichment process to complete before returning a response. Fields with complex guidance or requirements may time out / not complete. If this happens consistently, try to simplify the instructions or reduce the scope of the request.

### Supported Field Types

| Field Type | Examples |
|------------|----------|
| Text Fields | Company descriptions, job titles, notes |
| Choice Fields | Industry categories, lead sources, priorities |
| Number Fields | Employee counts, revenue estimates, scores |
| Date Fields | Founded dates, last contact dates |
| Multi-Choice Fields | Tags, categories, services offered |

**Tip:** For best results, configure guidance for each field within the field settings in the Close app.

### Update Strategy

By default, values are saved but only if the field does not already have a value. Saving values may be disabled by specifying `set_new_value: false`, or enrichment can be set to overwrite any existing values by specifying `overwrite_existing_value: true`.

### Enrich Field

```
POST /enrich_field/
```

This endpoint uses AI to enrich (populate or enhance) a specific field on a lead or contact. The enrichment process analyzes existing data and external sources to provide intelligent field values.

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `organization_id` | string | Yes | - | The organization ID |
| `object_type` | string | Yes | - | `"lead"` or `"contact"` |
| `object_id` | string | Yes | - | The ID of the lead or contact to enrich |
| `field_id` | string | Yes | - | The ID of the custom field to enrich |
| `set_new_value` | boolean | No | `true` | Whether to update the field with the enriched value |
| `overwrite_existing_value` | boolean | No | `false` | Whether to overwrite existing field values |

### Important Notes

- This endpoint waits for enrichment to complete, which may take several seconds.
- Complex field guidance may time out.
- Each enrichment request may consume credits or incur costs.
- Heavy usage may trigger rate limiting.

---

## Endpoint Summary

| # | Feature | Endpoints |
|---|---------|-----------|
| 1 | Email Templates | `GET /email_template/`, `POST /email_template/`, `GET /email_template/{id}/`, `PUT /email_template/{id}/`, `DELETE /email_template/{id}/`, `GET /email_template/{id}/render/` |
| 2 | SMS Templates | `GET /sms_template/`, `POST /sms_template/`, `GET /sms_template/{id}/`, `PUT /sms_template/{id}/`, `DELETE /sms_template/{id}/` |
| 3 | Connected Accounts | `GET /connected_account/`, `GET /connected_account/{id}/` |
| 4 | Send As | `GET /send_as/`, `POST /send_as/`, `DELETE /send_as/`, `GET /send_as/{id}/`, `DELETE /send_as/{id}/`, `POST /send_as/bulk/` |
| 5 | Sequences | `GET /sequence/`, `POST /sequence/`, `GET /sequence/{id}/`, `PUT /sequence/{id}/`, `DELETE /sequence/{id}/`, `GET /sequence_subscription/`, `POST /sequence_subscription/`, `GET /sequence_subscription/{id}/`, `PUT /sequence_subscription/{id}/` |
| 6 | Dialer | `GET /dialer/`, `GET /dialer/{id}/` |
| 7 | Smart Views | `GET /saved_search/`, `POST /saved_search/`, `GET /saved_search/{id}/`, `PUT /saved_search/{id}/`, `DELETE /saved_search/{id}/` |
| 8 | Bulk Actions | `GET /bulk_action/email/`, `POST /bulk_action/email/`, `GET /bulk_action/email/{id}/`, `GET /bulk_action/sequence_subscription/`, `POST /bulk_action/sequence_subscription/`, `GET /bulk_action/sequence_subscription/{id}/`, `GET /bulk_action/delete/`, `POST /bulk_action/delete/`, `GET /bulk_action/delete/{id}/`, `GET /bulk_action/edit/`, `POST /bulk_action/edit/`, `GET /bulk_action/edit/{id}/` |
| 9 | Integration Links | `GET /integration_link/`, `POST /integration_link/`, `GET /integration_link/{id}/`, `PUT /integration_link/{id}/`, `DELETE /integration_link/{id}/` |
| 10 | Exports | `POST /export/lead/`, `POST /export/opportunity/`, `GET /export/{id}/`, `GET /export/` |
| 11 | Phone Numbers | `GET /phone_number/`, `GET /phone_number/{id}/`, `PUT /phone_number/{id}/`, `DELETE /phone_number/{id}/`, `POST /phone_number/request/internal/` |
| 12 | Files | `POST /files/upload/` |
| 13 | Comments | `GET /comment_thread/`, `GET /comment_thread/{thread_id}/`, `GET /comment/`, `POST /comment/`, `GET /comment/{comment_id}/`, `PUT /comment/{comment_id}/`, `DELETE /comment/{comment_id}/` |
| 14 | Unsubscribe Email | `GET /unsubscribe/email/`, `POST /unsubscribe/email/`, `DELETE /unsubscribe/email/{email_address}/` |
| 15 | Rich Text Fields | N/A (format reference, not an endpoint) |
| 16 | Field Enrichment | `POST /enrich_field/` |

**Total unique endpoints: 57**


---


# Close CRM API — Advanced Documentation

> Source: https://developer.close.com
> Scraped: 2026-03-30
> Covers: Event Log, Webhooks, Scheduling Links, Custom Fields, Custom Activities, Custom Objects, Changelog

---

# Table of Contents

1. [Event Log](#1-event-log)
   - [Event Object Structure](#11-event-object-structure)
   - [List of Events](#12-list-of-events)
   - [Retrieve Events](#13-retrieve-events)
2. [Webhook Subscriptions](#2-webhook-subscriptions)
   - [Webhook Endpoints](#21-webhook-endpoints)
   - [Webhook Filters](#22-webhook-filters)
3. [Scheduling Links](#3-scheduling-links)
   - [User Scheduling Links](#31-user-scheduling-links)
   - [Shared Scheduling Links](#32-shared-scheduling-links)
   - [Scheduling Link Associations](#33-scheduling-link-associations)
4. [Custom Fields](#4-custom-fields)
   - [Overview & Field Types](#40-overview--field-types)
   - [Lead Custom Fields](#41-lead-custom-fields)
   - [Contact Custom Fields](#42-contact-custom-fields)
   - [Opportunity Custom Fields](#43-opportunity-custom-fields)
   - [Activity Custom Fields](#44-activity-custom-fields)
   - [Custom Object Custom Fields](#45-custom-object-custom-fields)
   - [Shared Custom Fields](#46-shared-custom-fields)
   - [Custom Field Schemas](#47-custom-field-schemas)
5. [Custom Activities](#5-custom-activities)
   - [Custom Activity Types](#51-custom-activity-types)
   - [Custom Activity Instances](#52-custom-activity-instances)
6. [Custom Objects](#6-custom-objects)
   - [Custom Object Types](#61-custom-object-types)
   - [Custom Object Instances](#62-custom-object-instances)
7. [Changelog](#7-changelog)

---

# 1. Event Log

## 1.1 Event Object Structure

The Event Log API provides access to actions in Close that modify objects. Events are retained for up to **30 days** of historical data. Most actions in Close that change an object are logged in the event log.

### Event Fields

| Field | Type | Description |
|-------|------|-------------|
| `date_created` | Timestamp | When the event was created |
| `date_updated` | Timestamp | When the event was last updated; can change if multiple actions occur on the same object |
| `organization_id` | String | The organization identifier |
| `user_id` | String / Null | User who triggered the event, or null if not user-initiated |
| `request_id` | String | Unique request identifier for associating related events |
| `api_key_id` | String / Null | API key used if triggered via API, otherwise null |
| `object_type` | String | Type of affected object (e.g., `lead`, `activity.email`, `status_change.opportunity`) |
| `object_id` | String | ID of the affected object |
| `lead_id` | String / Null | Associated lead ID, or null if not applicable |
| `action` | String | Event type: `created`, `updated`, `deleted`, `merged`, `completed`, `sent`, etc. |
| `changed_fields` | Array | For updates: fields that changed |
| `data` | Object / Null | Current object payload; null for deletes |
| `previous_data` | Object / Null | Previous values for updates; all attributes for deletes |
| `meta` | Object | Additional context (see below) |

### Meta Object Fields

| Field | Description |
|-------|-------------|
| `bulk_action_id` | ID of the bulk action that triggered this event |
| `merge_source_lead_id` | Source lead ID in a merge operation |
| `merge_destination_lead_id` | Destination lead ID in a merge operation |
| `request_method` | HTTP method of the triggering request |
| `request_path` | HTTP path of the triggering request |

### Privacy Consideration

For privacy reasons, certain fields (`data` and `previous_data`) are only visible to non-admins for one hour after the event.

### Event Consolidation

Multiple update events for the same object may consolidate into a single event. The consolidated event retains the original `date_created` and gets a new `date_updated`. The `previous_data` reflects the original state before all consolidation changes.

---

## 1.2 List of Events

All events available through the Close API Event Log, organized by object type and action.

### Lead (`lead`)

| Action | Trigger |
|--------|---------|
| `created` | A lead is created in your organization (regardless of the method) |
| `updated` | Lead's basic fields change (name, description, url, status), contacts are added/removed, or addresses/custom fields are modified. Note: Activity, opportunity, task changes do NOT trigger this event. |
| `deleted` | A lead is deleted. Deleting a lead will cause additional `deleted` events on child objects. |
| `merged` | Two leads are merged; includes `merge_source_lead_id` and `merge_destination_lead_id` in event metadata |

### Contact (`contact`)

| Action | Trigger |
|--------|---------|
| `created` | A contact is created in your organization |
| `updated` | Changes to basic fields (name, title) or nested fields (email, phone, URL) |
| `deleted` | Contact removal |

### Opportunity (`opportunity`)

| Action | Trigger |
|--------|---------|
| `created` | An opportunity is created |
| `updated` | Changes to status, date_won, value, value_period, or confidence. Note: `value_currency` changes do NOT trigger this event as it's organization-wide. |
| `deleted` | Opportunity removal |

### Tasks (`task.SUBTYPE`)

| Action | Trigger |
|--------|---------|
| `created` | Task creation |
| `updated` | Changes to basic fields like `is_complete`, `date`, `text`, `subject` |
| `deleted` | Task removal |
| `completed` | A task is marked as done |

### Email (`activity.email`)

| Action | Trigger |
|--------|---------|
| `created` | Incoming synced email or outgoing email (scheduled/draft) |
| `updated` | Changes to subject, body, status, opens. **Discouraged** — many updates happen when a user is drafting. |
| `deleted` | Email removal |
| `sent` | An outgoing email is sent through the UI or API. Triggered when the email is actually _sent_. |

### Email Thread (`activity.email_thread`)

| Action | Trigger |
|--------|---------|
| `created` | New thread from synced email or API/UI creation |
| `updated` | Changes to emails, participants, or subject |
| `deleted` | Thread removal |

### Unsubscribed Email (`unsubscribed_email`)

| Action | Trigger |
|--------|---------|
| `created` | User email was unsubscribed from bulk and workflow emails |
| `deleted` | Email resubscription |

### Call (`activity.call`)

| Action | Trigger |
|--------|---------|
| `created` | User-initiated, transferred, inbound, or manually logged calls |
| `updated` | Changes to note, status, duration, recording_url. **Discouraged** — many updates happen when a user is writing. |
| `deleted` | Call removal |
| `answered` | A call is answered. Not triggered for calls made outside of Close. |
| `completed` | Call completion (not triggered for manually logged calls) |

### SMS (`activity.sms`)

| Action | Trigger |
|--------|---------|
| `created` | Inbound or outbound SMS creation |
| `updated` | Changes to status, text, phone numbers. **Discouraged** due to frequent draft updates. |
| `deleted` | SMS removal |
| `sent` | An outbound SMS is sent through the UI or API |

### WhatsApp Message (`activity.whatsapp_message`)

| Action | Trigger |
|--------|---------|
| `created` | WhatsApp message created |
| `updated` | WhatsApp message updated |
| `deleted` | WhatsApp message deleted |

### Note (`activity.note`)

| Action | Trigger |
|--------|---------|
| `created` | Note created |
| `updated` | Periodic during typing |
| `deleted` | Note deleted |

### Meeting (`activity.meeting`)

| Action | Trigger |
|--------|---------|
| `created` | Meeting created |
| `updated` | Meeting updated |
| `deleted` | Meeting deleted |
| `scheduled` | Future meeting created or rescheduled |
| `started` | Status moves to "in-progress" |
| `completed` | Status moves to "completed" |
| `canceled` | Status moves to "canceled" |

### Form Submission (`activity.form_submission`)

| Action | Trigger |
|--------|---------|
| `created` | Form submission created |
| `updated` | Form submission updated |
| `deleted` | Form submission deleted |

### Lead Status Change (`activity.lead_status_change`)

| Action | Trigger |
|--------|---------|
| `created` | Also triggers `lead.updated` event |
| `updated` | Consolidates consecutive status changes within short time |
| `deleted` | Reverted status change |

### Opportunity Status Change (`activity.opportunity_status_change`)

| Action | Trigger |
|--------|---------|
| `created` | Similar behavior to lead status changes |
| `updated` | Consolidates consecutive status changes within short time |
| `deleted` | Reverted status change |

### Task Completed (`activity.task_completed`)

| Action | Trigger |
|--------|---------|
| `created` | Also triggers `completed` and `updated` on task and `updated` on lead |
| `deleted` | Task marked incomplete again |

### Import (`import`)

| Action | Trigger |
|--------|---------|
| `created` | CSV import initiated |
| `updated` | Frequent updates during processing (status, progress metrics) |
| `completed` | Import completed |
| `reverting` | Import being reverted |
| `reverted` | Import reverted |

### Export (`export.lead`, `export.opportunity`)

| Action | Trigger |
|--------|---------|
| `created` | Export initiated |
| `updated` | Frequent during processing |
| `completed` | Export completed |

### Bulk Actions (`bulk_action.delete`, `bulk_action.edit`, `bulk_action.email`, `bulk_action.sequence_subscription`)

| Action | Trigger |
|--------|---------|
| `created` | Bulk action initiated |
| `updated` | Frequent during processing |
| `completed` | Bulk action completed |
| `paused` | Bulk action paused |

### Custom Fields

Object types: `custom_fields.lead`, `custom_fields.contact`, `custom_fields.opportunity`, `custom_fields.activity`, `custom_fields.custom_object`, `custom_fields.shared`

| Action | Trigger |
|--------|---------|
| `created` | Initial creation |
| `updated` | Changes to name, type, or choices |
| `deleted` | Field deleted |

### Custom Activity Type (`custom_activity_type`)

| Action | Trigger |
|--------|---------|
| `created` | Type created |
| `updated` | Field changes, ordering, associations |
| `deleted` | Type deleted |

### Custom Activity (`activity.custom_activity`)

| Action | Trigger |
|--------|---------|
| `created` | Custom activity instance created |
| `updated` | Custom activity instance updated |
| `deleted` | Custom activity instance deleted |

### Custom Object Type (`custom_object_type`)

| Action | Trigger |
|--------|---------|
| `created` | Type created |
| `updated` | Type updated |
| `deleted` | Type deleted |

### Custom Object (`custom_object`)

| Action | Trigger |
|--------|---------|
| `created` | Custom object instance created |
| `updated` | Custom object instance updated |
| `deleted` | Custom object instance deleted |

### Status (`status.lead`, `status.opportunity`)

| Action | Trigger |
|--------|---------|
| `created` | Status created |
| `updated` | Label changes |
| `deleted` | Status deleted |

### Membership (`membership`)

| Action | Trigger |
|--------|---------|
| `activated` | User accepts invitation or is re-added |
| `deactivated` | User removal |

### Group (`group`)

| Action | Trigger |
|--------|---------|
| `created` | Group created |
| `updated` | Including member changes |
| `deleted` | Group deleted |

### Saved Search (`saved_search`)

| Action | Trigger |
|--------|---------|
| `created` | Saved search created |
| `updated` | Name, query, sharing changed (not triggered by result changes) |
| `deleted` | Saved search deleted |

### Phone Number (`phone_number`)

| Action | Trigger |
|--------|---------|
| `created` | Phone number created |
| `updated` | Forwarding, participants, voicemail changed |
| `deleted` | Phone number deleted |

### Email Template (`email_template`)

| Action | Trigger |
|--------|---------|
| `created` | Template created |
| `updated` | Name, subject, body, attachments changed |
| `deleted` | Template deleted |

### SMS Template (`sms_template`)

| Action | Trigger |
|--------|---------|
| `created` | Template created |
| `updated` | Name, text, sharing changed |
| `deleted` | Template deleted |

### Sequence (`sequence`)

| Action | Trigger |
|--------|---------|
| `created` | Sequence created |
| `updated` | Including embedded steps |
| `deleted` | Sequence deleted |

### Sequence Subscription (`sequence_subscription`)

| Action | Trigger |
|--------|---------|
| `created` | Subscription created |
| `updated` | Status changes |
| `deleted` | Triggered by related object deletion |

### Comment (`comment`)

| Action | Trigger |
|--------|---------|
| `created` | Comment created |
| `updated` | Body changes or removal |
| `deleted` | Permanent deletion only |

### Comment Thread (`comment_thread`)

| Action | Trigger |
|--------|---------|
| `created` | First comment added |
| `updated` | Participant or count changes |
| `deleted` | Last comment removed |

### Lead Merge (`lead_merge`)

| Action | Trigger |
|--------|---------|
| `created` | Merge initiated |
| `updated` | Status changes |
| `deleted` | Merge deleted |

---

## 1.3 Retrieve Events

### Retrieve a Single Event by ID

```
GET /event/{id}/
```

Returns a single event by its ID using the standard event format.

### Retrieve a List of Events

```
GET /event/
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `date_updated__lt` | ISO datetime | Optional | Events updated before this time |
| `date_updated__gt` | ISO datetime | Optional | Events updated after this time |
| `date_updated__lte` | ISO datetime | Optional | Events updated at or before this time |
| `date_updated__gte` | ISO datetime | Optional | Events updated at or after this time |
| `object_type` | string | Optional | Filter by object type (e.g., `lead`) |
| `object_id` | string | Optional | Filter by specific object ID |
| `action` | string | Optional | Filter by action type (e.g., `deleted`) |
| `lead_id` | string | Optional | Filter by lead; returns events for the lead and its related objects (contacts, activities, opportunities, tasks) |
| `user_id` | string | Optional | Filter by user |
| `request_id` | string | Optional | Filter by API request ID |
| `_cursor` | string | Optional | Pagination cursor from previous response |
| `_limit` | integer | Optional | Maximum events to return (capped at 50, defaults to 50) |

### Supported Filter Combinations

- `object_type` + `object_id`
- `object_type` + `action`
- `object_id` + `action`
- `lead_id` + `object_type`
- `lead_id` + `object_type` + `action`
- `lead_id` + `user_id` + `object_type`
- `lead_id` + `user_id` + `object_type` + `action`
- `lead_id` + `user_id`
- `user_id` + `object_id`
- `user_id` + `object_id` + `action`
- `user_id` + `object_type`
- `user_id` + `object_type` + `action`
- `lead_id` alone
- `user_id` alone
- `request_id` alone

`date_updated` may optionally accompany any supported combination.

### Response Schema

| Field | Type | Description |
|-------|------|-------------|
| `data` | array | List of event objects using standard event format |
| `cursor_next` | string / null | Cursor for retrieving next page (earlier/older events) or null if unavailable |
| `cursor_previous` | string / null | Cursor for retrieving previous page (later/newer events) or null if unavailable |

### Ordering & Behavior

- Events are ordered by date, latest first (by `date_updated` field)
- Despite millisecond-precision limitations on timestamps, multiple events for the same object maintain guaranteed proper order
- Cursors provide reliable pagination; `date_updated` filtering may require accounting for simultaneous events
- Event consolidation of multiple recent events to the same object may occur
- Recommended practice: scan the latest five minutes of events to avoid missing recent entries when paginating
- The endpoint does **not** support the `_skip` parameter

### Pagination Notes

Cursors are a reliable way to go to the next or previous page of events (unlike filtering by `date_updated`, where you may need to account for and filter out multiple events happening in the same millisecond).

To retrieve the next older batch, use the `cursor_next` value from the previous response.

---

# 2. Webhook Subscriptions

## 2.1 Webhook Endpoints

### List Webhook Subscriptions

```
GET /webhook/
```

Returns all webhook subscriptions configured for your organization.

---

### Create New Webhook Subscription

```
POST /webhook/
```

**Request Body:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `url` | string | Yes | Destination URL for webhook delivery |
| `events` | array | Yes | List of events to subscribe to (each with `object_type` and `action` from the event log) |
| `verify_ssl` | boolean | No | SSL certificate validation (default: `true`) |

**Notes:**
- Set `verify_ssl` to `false` to disable SSL validation (not recommended without HTTPS)
- Use Webhook Filters for conditional event delivery
- Webhook subscriptions are automatically paused after 3 days of all event delivery failures

---

### Retrieve Single Webhook Subscription

```
GET /webhook/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Webhook subscription identifier |

---

### Update Webhook Subscription

```
PUT /webhook/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Webhook subscription identifier |
| `url` | string | No | Destination URL |
| `events` | array | No | Event list (same structure as creation) |
| `status` | string | No | `active` or `paused` |
| `verify_ssl` | boolean | No | SSL validation setting |

---

### Delete Webhook Subscription

```
DELETE /webhook/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Webhook subscription identifier |

---

## 2.2 Webhook Filters

More advanced event filtering can be achieved by specifying event filters when creating/modifying a webhook subscription. These filters use JSON to specify conditions on event fields.

### Filter Operators

| Operator | Syntax | Description |
|----------|--------|-------------|
| **Equals** | `{"type": "equals", "value": "<value>"}` | Matches when the entire value matches the provided value |
| **Not Equals** | `{"type": "not_equals", "value": "<value>"}` | Matches when the value does not match the provided value |
| **Is Null** | `{"type": "is_null"}` | Matches when the field value is null |
| **Non Null** | `{"type": "non_null"}` | Matches when the field value is non-null |
| **Contains** | `{"type": "contains", "value": "<value>"}` | Searches for a value in an array or partial string match |
| **And** | `{"type": "and", "filters": [<filter1>, ...]}` | Matches when ALL provided filters match |
| **Or** | `{"type": "or", "filters": [<filter1>, ...]}` | Matches when ONE OR MORE filters match |
| **Not** | `{"type": "not", "filter": <filter>}` | Matches when the provided filter does NOT match |

### Field Access Methods

| Method | Syntax | Description |
|--------|--------|-------------|
| **Field Accessor** | `{"type": "field_accessor", "field": "<field_name>", "filter": <filter>}` | Access specific fields in JSON documents |
| **Any Array Value** | `{"type": "any_array_value", "filter": <filter>}` | Search for matching values inside arrays/lists |

### Example: Match specific user_id

```json
{
  "type": "field_accessor",
  "field": "user_id",
  "filter": {
    "type": "equals",
    "value": "user_N6KhMpzHRCYQHdn4gRNIFNN5JExnsrprKA6ekxM63XA"
  }
}
```

### Example: Drill into nested data object

```json
{
  "type": "field_accessor",
  "field": "data",
  "filter": {
    "type": "field_accessor",
    "field": "user_id",
    "filter": {
      "type": "equals",
      "value": "user_N6KhMpzHRCYQHdn4gRNIFNN5JExnsrprKA6ekxM63XA"
    }
  }
}
```

### Example: Exclude events from specific user (using `not`)

```json
{
  "type": "field_accessor",
  "field": "data",
  "filter": {
    "type": "field_accessor",
    "field": "user_id",
    "filter": {
      "type": "not",
      "filter": {
        "type": "equals",
        "value": "user_N6KhMpzHRCYQHdn4gRNIFNN5JExnsrprKA6ekxM63XA"
      }
    }
  }
}
```

### Example: Exclude events from specific user (using `not_equals`)

```json
{
  "type": "field_accessor",
  "field": "data",
  "filter": {
    "type": "field_accessor",
    "field": "user_id",
    "filter": {
      "type": "not_equals",
      "value": "user_N6KhMpzHRCYQHdn4gRNIFNN5JExnsrprKA6ekxM63XA"
    }
  }
}
```

### Example: Match non-null user_id

```json
{
  "type": "field_accessor",
  "field": "user_id",
  "filter": {
    "type": "non_null"
  }
}
```

### Example: Match leads with "travel" in name

```json
{
  "type": "field_accessor",
  "field": "data",
  "filter": {
    "type": "field_accessor",
    "field": "name",
    "filter": {
      "type": "contains",
      "value": "travel"
    }
  }
}
```

### Example: Match events where name changed

```json
{
  "type": "field_accessor",
  "field": "changed_fields",
  "filter": {
    "type": "contains",
    "value": "name"
  }
}
```

### Example: Match name OR description changes

```json
{
  "type": "field_accessor",
  "field": "changed_fields",
  "filter": {
    "type": "or",
    "filters": [
      {
        "type": "contains",
        "value": "name"
      },
      {
        "type": "contains",
        "value": "description"
      }
    ]
  }
}
```

### Example: Match multiple custom fields (AND operation)

```json
{
  "type": "and",
  "filters": [
    {
      "type": "field_accessor",
      "field": "data",
      "filter": {
        "type": "field_accessor",
        "field": "custom.cf_rR9HjgjI4SYy1X1IlMOozK2VkxMgU5NnHquTR8DVxoQ",
        "filter": {
          "type": "equals",
          "value": "product_1234"
        }
      }
    },
    {
      "type": "field_accessor",
      "field": "data",
      "filter": {
        "type": "field_accessor",
        "field": "custom.cf_vwqYhEFwzPyfCErS8uQ77is1wFLvr9BgVi6cTfbFM48",
        "filter": {
          "type": "equals",
          "value": "sub_product_5678"
        }
      }
    }
  ]
}
```

### Example: Match addresses in specific state/country

```json
{
  "type": "field_accessor",
  "field": "data",
  "filter": {
    "type": "field_accessor",
    "field": "addresses",
    "filter": {
      "type": "any_array_value",
      "filter": {
        "type": "and",
        "filters": [
          {
            "type": "field_accessor",
            "field": "state",
            "filter": {
              "type": "equals",
              "value": "MD"
            }
          },
          {
            "type": "field_accessor",
            "field": "country",
            "filter": {
              "type": "equals",
              "value": "US"
            }
          }
        ]
      }
    }
  }
}
```

---

# 3. Scheduling Links

## Overview

Scheduling Links let you create arbitrary event links that make it easy to find/insert booking links directly from Close.

- **User Scheduling Links** — All users can create these; OAuth applications can create them on behalf of users
- **Shared Scheduling Links** — Available to users with "Manage Customizations" permission; creates template tags for email templates
- Shared Scheduling Links can be mapped to User Scheduling Links or URLs

---

## 3.1 User Scheduling Links

Close users can embed scheduling links in their communications sent through Close. The API supports three scheduling link types identified by their `source` attribute:

| Source | Description |
|--------|-------------|
| `MANUAL` | Created via Close application or `/scheduling_link/` endpoints |
| `THIRD_PARTY` | Created/managed by OAuth applications via `/scheduling_link/integration/` endpoints |
| `CALENDLY` | Close's first-party Calendly integration |

### Editable Attributes (all types)

| Attribute | Type | Description |
|-----------|------|-------------|
| `name` | string | Display name in Close application |
| `url` | string | External scheduling link URL |
| `description` | string | Description shown in Close application |

### Additional Attributes (THIRD_PARTY only)

| Attribute | Type | Description |
|-----------|------|-------------|
| `source_id` | string | Integrating application's identifier |
| `source_type` | string | Short descriptor for the link type |
| `duration_in_minutes` | integer | Meeting length in minutes |

### List User Scheduling Links

```
GET /scheduling_link/
```

Retrieves all user scheduling links.

### Create a User Scheduling Link

```
POST /scheduling_link/
```

Creates a new scheduling link with specified attributes.

### Fetch a User Scheduling Link

```
GET /scheduling_link/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Scheduling link identifier |

### Update a User Scheduling Link

```
PUT /scheduling_link/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Scheduling link identifier |

### Delete a User Scheduling Link

```
DELETE /scheduling_link/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Scheduling link identifier |

### Create or Update via OAuth Integration

```
POST /scheduling_link/integration/
```

**Authentication:** OAuth only (API key will produce an error).

Uses the integration-provided `source_id` field to identify and merge duplicate resources created by the same OAuth Application. If a scheduling link created by your OAuth application with the specified `source_id` does not exist, a new one will be created. Otherwise, the scheduling link resource will be updated.

### Delete via OAuth Integration

```
DELETE /scheduling_link/integration/{source_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `source_id` | string (path) | Yes | Source identifier from OAuth application |

**Authentication:** OAuth only (API key will produce an error).

Uses the `source_id` field to identify and delete the specified User Scheduling Link created by your OAuth Application.

---

## 3.2 Shared Scheduling Links

### List Shared Scheduling Links

```
GET /shared_scheduling_link/
```

Retrieves a list of all shared scheduling links.

### Create a Shared Scheduling Link

```
POST /shared_scheduling_link/
```

Creates a new shared scheduling link.

### Fetch a Shared Scheduling Link

```
GET /shared_scheduling_link/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Shared scheduling link identifier |

### Update a Shared Scheduling Link

```
PUT /shared_scheduling_link/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Shared scheduling link identifier |

### Delete a Shared Scheduling Link

```
DELETE /shared_scheduling_link/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Shared scheduling link identifier |

---

## 3.3 Scheduling Link Associations

Scheduling Link Associations enable mapping and unmapping of Shared Scheduling Links to either User Scheduling Links or URLs.

### Map a Shared Scheduling Link

```
POST /shared_scheduling_link_association/
```

Associates a Shared Scheduling Link with either a User Scheduling Link or a URL.

### Unmap a Shared Scheduling Link

```
POST /shared_scheduling_link_association/unmap
```

Removes an association between a Shared Scheduling Link and its mapped target.

---

# 4. Custom Fields

## 4.0 Overview & Field Types

Custom Fields enable storage of arbitrary data on Leads, Contacts, Opportunities, and Custom Activities. Organizations can define field names, data types, validation rules, and access permissions.

**Permission requirement:** Only users with the `manage_organization` permission can create, edit, or delete Custom Fields.

### API Endpoint Categories

| Endpoint | Resource | Path |
|----------|----------|------|
| Lead Custom Fields | Leads | `/custom_field/lead/` |
| Contact Custom Fields | Contacts | `/custom_field/contact/` |
| Opportunity Custom Fields | Opportunities | `/custom_field/opportunity/` |
| Activity Custom Fields | Custom Activities | `/custom_field/activity/` |
| Object Custom Fields | Custom Objects | `/custom_field/custom_object_type/` |
| Shared Custom Fields | Multiple objects | `/custom_field/shared/` |
| Schema Endpoint | All fields | `/custom_field_schema/{object_type}/` |

### Core Field Properties

| Attribute | Type | Description |
|-----------|------|-------------|
| `name` | string | User-readable field name |
| `description` | string / null | Context description (max 280 characters) |
| `type` | string | Data type (see types below) |
| `choices` | array | Valid values for `choices` type |
| `accepts_multiple_values` | boolean | Multiple values support |
| `editable_with_roles` | array | Roles permitted to edit |
| `referenced_custom_type_id` | string | Custom Object Type ID (for `custom_object` fields) |
| `back_reference_is_visible` | boolean | Display back-reference in UI |

### Supported Field Types

| Type | Description |
|------|-------------|
| `text` | Any text value |
| `number` | Integer or decimal values |
| `date` | Date only (e.g., `"2014-06-12"`) |
| `datetime` | Date with time (e.g., `"2014-06-27T22:00:00-08:00"`) |
| `choices` | Predefined values only |
| `user` | Active/former User IDs or exact names (returns IDs) |
| `contact` | Contact IDs (limited to Lead's contacts) |
| `custom_object` | Custom Object IDs (single type, limited to Lead's objects) |
| `textarea` | Multi-line text (Custom Activities only) |
| `hidden` | Any value, never displayed in UI |

### Multi-Value Support

Multiple values are only supported for: `user`, `choices`, `contact`, and `custom_object` types.

### Contact Field Restrictions

The `contact` type field accepts IDs limited to the relevant Lead's contacts:
- Lead editing: accepts Lead's contacts
- Contact editing: accepts Lead's contacts
- Opportunity editing: accepts Lead's contacts
- Custom Activity editing: accepts Lead's contacts
- Custom Object editing: accepts Lead's contacts

### Custom Field ID Format

New Custom Fields share common `cf_` prefix instead of type-specific prefixes. Existing Custom Field IDs are unchanged.

### Notes

- Custom Object fields reference only one Custom Object Type via `referenced_custom_type_id`
- The `hidden` type stores data useful primarily to API integrations
- URL for Custom Field API changed from `/custom_fields/*/` to `/custom_field/*/` (old endpoint continues working)

---

## 4.1 Lead Custom Fields

### List All Lead Custom Fields

```
GET /custom_field/lead/
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | Optional | Maximum number of results to return |
| `_skip` | integer | Optional | Number of results to skip for pagination |

### Create a New Lead Custom Field

```
POST /custom_field/lead/
```

### Fetch Lead Custom Field Details

```
GET /custom_field/lead/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The custom field ID |

### Update a Lead Custom Field

```
PUT /custom_field/lead/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The custom field ID to update |

**Updateable Fields:**
- Field name
- Field type
- Multiple values acceptance setting
- Role-based edit restrictions
- Options for "choices" field types

**Notes:**
- The updated name will immediately appear in the Close UI
- Only valid values for the updated `type` will be returned by the Lead API
- Type conversions may trigger a `converting_to_type` response field during processing

### Delete a Lead Custom Field

```
DELETE /custom_field/lead/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The custom field ID to delete |

The field will immediately disappear from any Lead API responses.

---

## 4.2 Contact Custom Fields

### List All Contact Custom Fields

```
GET /custom_field/contact/
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | Optional | Limit number of results |
| `_skip` | integer | Optional | Skip number of results |

### Create a New Contact Custom Field

```
POST /custom_field/contact/
```

### Fetch Contact Custom Field Details

```
GET /custom_field/contact/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The custom field ID |

### Update a Contact Custom Field

```
PUT /custom_field/contact/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The custom field ID |

**Updateable Fields:**
- Field name
- Field type
- Multiple values acceptance setting
- Role-based edit restrictions
- Options for "choices" field types

**Note:** Type conversions may require data transformation. During conversion, the response includes a `converting_to_type` field that disappears upon completion.

### Delete a Contact Custom Field

```
DELETE /custom_field/contact/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The custom field ID |

The field immediately disappears from Contact API responses.

---

## 4.3 Opportunity Custom Fields

### List All Opportunity Custom Fields

```
GET /custom_field/opportunity/
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | Optional | Maximum number of records to return |
| `_skip` | integer | Optional | Number of records to skip for pagination |

### Create a New Opportunity Custom Field

```
POST /custom_field/opportunity/
```

### Fetch Opportunity Custom Field Details

```
GET /custom_field/opportunity/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The custom field identifier |

### Update an Opportunity Custom Field

```
PUT /custom_field/opportunity/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The field identifier to update |

**Updateable Fields:**
- Field name
- Field type
- Multiple value acceptance setting
- Role-based editing restrictions
- Options for choice-type fields

**Note:** Type conversions may require processing indicated by a `converting_to_type` field in the response.

### Delete an Opportunity Custom Field

```
DELETE /custom_field/opportunity/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The field identifier to delete |

The field will immediately disappear from any Opportunity API responses.

---

## 4.4 Activity Custom Fields

Activity Custom Fields belong to Custom Activities and have two additional attributes beyond standard custom fields:
- `custom_activity_type_id` -- identifies the Custom Activity Type this field belongs to
- `required` -- specifies whether the field must be completed before publishing the activity

### List All Activity Custom Fields

```
GET /custom_field/activity/
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `_limit` | integer | No | Maximum number of records to return |
| `_skip` | integer | No | Number of records to skip for pagination |

### Create a New Activity Custom Field

```
POST /custom_field/activity/
```

**Request Body Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `custom_activity_type_id` | string | Yes | ID of the Custom Activity Type this field belongs to |
| `required` | boolean | No | Whether the field is required to publish the activity |
| `name` | string | Yes | Field name |
| `type` | string | Yes | Field data type (e.g., text, number, choices) |

### Fetch Activity Custom Field Details

```
GET /custom_field/activity/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The custom field identifier |

### Update an Activity Custom Field

```
PUT /custom_field/activity/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The custom field identifier |

**Updateable Fields:**
- Field name
- Multiple values acceptance setting
- `required` flag
- Role-based editing restrictions
- Options for "choices" field type

**Constraints:** The `custom_activity_type_id` and `type` values cannot be changed after creation.

### Delete an Activity Custom Field

```
DELETE /custom_field/activity/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The custom field identifier |

The field will immediately disappear from any Custom Activity API responses.

---

## 4.5 Custom Object Custom Fields

Custom Object Custom Fields are fields that belong to Custom Objects. They have additional attributes:
- `custom_object_type_id` -- ID of the Custom Object Type this field belongs to
- `required` -- whether the field is required to save the object

### List All Custom Object Custom Fields

```
GET /custom_field/custom_object_type/
```

### Create a New Custom Object Custom Field

```
POST /custom_field/custom_object_type/
```

**Request Body:**

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_object_type_id` | string | Yes | ID of the Custom Object Type this field belongs to |
| `required` | boolean | No | Whether the field is required to save the object |

### Fetch Custom Object Custom Field Details

```
GET /custom_field/custom_object_type/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The custom field identifier |

### Update a Custom Object Custom Field

```
PUT /custom_field/custom_object_type/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The custom field identifier |

**Updateable Fields:**
- Field name
- Multiple value acceptance setting
- Required flag
- Role-based editing restrictions
- Options for "choices" field type

**Restrictions:** The `custom_object_type_id` and `type` values cannot be changed. Updated names appear immediately in the Close UI.

### Delete a Custom Object Custom Field

```
DELETE /custom_field/custom_object_type/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The custom field identifier |

The field immediately disappears from Custom Object API responses.

---

## 4.6 Shared Custom Fields

Shared Custom Fields differ from regular Custom Fields by including an `associations` field that defines which object types the field can be used on.

### List All Shared Custom Fields

```
GET /custom_field/shared/
```

### Create a New Shared Custom Field

```
POST /custom_field/shared/
```

### Update a Shared Custom Field

```
PUT /custom_field/shared/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The shared custom field identifier |

**Updateable:**
- Field name
- Options for "choices" field types

**Constraints:**
- The `type` value cannot be changed
- Updated names appear immediately in the Close UI
- Only valid values for updated `choices` are returned by APIs

### Delete a Shared Custom Field

```
DELETE /custom_field/shared/{custom_field_id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (path) | Yes | The shared custom field identifier |

The field immediately disappears from all associated objects and related APIs (Lead/Contact/Custom Activity).

### Associate a Shared Custom Field

```
POST /custom_field/shared/{shared_custom_field_id}/association/
```

**Request Body:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `object_type` | string | Yes | One of: `lead`, `contact`, `opportunity`, `custom_activity_type`, `custom_object_type` |
| `custom_activity_type_id` | string | Conditional | Required if `object_type` is `custom_activity_type` |
| `custom_object_type_id` | string | Conditional | Required if `object_type` is `custom_object_type` |
| `editable_with_roles` | array | No | List of Roles that can edit field values (per-association setting) |
| `required` | boolean | No | Whether a value must be provided (only for `custom_activity_type` or `custom_object_type`) |

### Update a Shared Custom Field Association

```
PUT /custom_field/shared/{shared_custom_field_id}/association/{object_type}/
```

**URL Parameters:**

| Parameter | Description |
|-----------|-------------|
| `shared_custom_field_id` | The shared custom field identifier |
| `object_type` | `lead`, `contact`, `opportunity`, `custom_activity_type/<catype_id>`, or `custom_object_type/<cotype_id>` |

**Updateable:** `required` and `editable_with_roles`

### Disassociate a Shared Custom Field

```
DELETE /custom_field/shared/{custom_field_id}/association/{object_type}/
```

**URL Parameters:**

| Parameter | Description |
|-----------|-------------|
| `custom_field_id` | The shared custom field identifier |
| `object_type` | `lead`, `contact`, `opportunity`, `custom_activity_type/<catype_id>`, or `custom_object_type/<cotype_id>` |

The field immediately disappears from the disassociated object type.

---

## 4.7 Custom Field Schemas

A Custom Field Schema presents you with _all_ (regular and shared) Custom Fields that belong on a given object (Lead, Contact, Opportunity, or some specific Custom Activity or Custom Object Type), in the specific order that you've defined.

This endpoint is recommended for answering "What Custom Fields can I set on this object?"

### Fetch a Custom Field Schema

```
GET /custom_field_schema/{object_type}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `object_type` | string (path) | Yes | One of: `lead`, `contact`, `opportunity`, `activity/<cat_id>`, `custom_object/<cotype_id>` |

Returns all custom fields belonging to the specified object type in defined order.

### Reorder Custom Fields within a Schema

```
PUT /custom_field_schema/{object_type}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `object_type` | string (path) | Yes | One of: `lead`, `contact`, `opportunity`, `activity/<cat_id>`, `custom_object/<cotype_id>` |

**Request Body:**

```json
{
  "fields": [
    {"id": "cf_xxx"},
    {"id": "cf_yyy"}
  ]
}
```

**Notes:**
- Supply a `fields` list containing `{"id": ...}` objects for each custom field
- IDs omitted from the list are automatically appended to the end
- To remove fields, delete the custom field or disassociate shared fields from the object

---

# 5. Custom Activities

Custom Activities let you create arbitrary activity types with user-defined fields. Implementation follows a three-step process:

1. Create a Custom Activity Type
2. Add Activity Custom Fields or associate Shared Custom Fields
3. Create and manage Custom Activity instances

---

## 5.1 Custom Activity Types

### List Custom Activity Types

```
GET /custom_activity/
```

Returns all Custom Activity Types for the organization, including Custom Field metadata.

### Create New Custom Activity Type

```
POST /custom_activity/
```

Creates a new Custom Activity Type. The type must exist before custom fields can be associated with it.

### Retrieve a Single Custom Activity Type

```
GET /custom_activity/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The Custom Activity Type ID |

Returns a specific Custom Activity Type with its Custom Field metadata.

### Update Existing Custom Activity Type

```
PUT /custom_activity/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The Custom Activity Type ID |

**Updateable Fields:**
- `name`
- `description`
- `api_create_only`
- `editable_with_roles`
- `is_archived`
- Field order (display property only)

**Note:** Adding, modifying, or removing fields must be done via the Custom Field API. Field order is a display property and does not affect API requests/responses.

### Delete a Custom Activity Type

```
DELETE /custom_activity/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The Custom Activity Type ID |

---

## 5.2 Custom Activity Instances

### List or Filter Custom Activity Instances

```
GET /activity/custom/
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `lead_id` | string | Optional | Filter by lead ID |
| `user_id` | string | Optional | Filter by user ID |
| `date_created__gt` | ISO datetime | Optional | Filter for activities created after a specific date |
| `date_created__lt` | ISO datetime | Optional | Filter for activities created before a specific date |
| `custom_activity_type_id` | string | Optional | Filter by custom activity type ID (**requires `lead_id`**) |
| `custom_activity_type_id__in` | string | Optional | Filter by multiple custom activity type IDs (**requires `lead_id`**) |

**Important Notes:**
- When filtering by `custom_activity_type_id` or `custom_activity_type_id__in`, the `lead_id` parameter is required
- To retrieve all Custom Activity instances of a specific type across all leads, use Advanced Filtering first to identify relevant leads, then query each lead individually
- Custom Fields appear as `custom.{custom_field_id}`

### Create Custom Activity Instance

```
POST /activity/custom/
```

**Behavior:**
- Custom Activity instances are created with "published" status by default
- All required fields are validated in "published" status
- Use "draft" status to create activities without setting all required fields
- A Custom Activity can be pinned via the `pinned` field (set to `true` or `false`)

### Retrieve Single Custom Activity Instance

```
GET /activity/custom/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The unique identifier of the Custom Activity instance |

### Update Custom Activity Instance

```
PUT /activity/custom/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The unique identifier of the Custom Activity instance |

**Updateable Fields:**
- Custom Fields (add, change, or remove)
- Status (toggle between "draft" and "published")
- `pinned` field (set to `true` or `false`)

### Delete Custom Activity Instance

```
DELETE /activity/custom/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The unique identifier of the Custom Activity instance |

---

# 6. Custom Objects

Custom Objects are flexible data structures associated with leads that support custom fields. Implementation follows a three-step process:

1. Create a Custom Object Type
2. Add Custom Object Custom Fields or associate Shared Custom Fields
3. Create and manage Custom Object instances on Leads

---

## 6.1 Custom Object Types

### List Custom Object Types

```
GET /custom_object_type/
```

Retrieves all Custom Object Types for your organization, including custom field metadata. The response includes two field lists:
- `fields` -- fields belonging to the type
- `back_reference_fields` -- objects referencing this type

### Create New Custom Object Type

```
POST /custom_object_type/
```

**Required Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | The name of the Custom Object Type |
| `name_plural` | string | Yes | Pluralized version for UI display |

**Optional Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `description` | string | No | Longer description of the type |
| `api_create_only` | boolean | No | If true, instances can only be created via API (default: false) |
| `editable_with_roles` | array | No | Restricts editing to users with specified roles |

### Retrieve Single Custom Object Type

```
GET /custom_object_type/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The Custom Object Type ID |

Returns a single Custom Object Type with associated custom field metadata.

### Update Custom Object Type

```
PUT /custom_object_type/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The Custom Object Type ID |

**Updatable Fields:**
- `name`
- `name_plural`
- `description`
- `api_create_only`
- `editable_with_roles`
- `is_archived` (for archiving)

**Note:** You cannot add, modify, remove or reorder fields from a Custom Object Type using this resource. Use Custom Object Custom Fields or Custom Field Schema APIs instead.

### Delete Custom Object Type

```
DELETE /custom_object_type/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | The Custom Object Type ID |

---

## 6.2 Custom Object Instances

### List Custom Object Instances

```
GET /custom_object/
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `lead_id` | string | **Yes** | Filter instances by lead ID |
| `custom_object_type_id` | string | Optional | Filter by custom object type |

**Notes:**
- The `lead_id` parameter is required for listing operations without Advanced Filtering
- Custom field values appear as `custom.{custom_field_id}`
- For back references, use Advanced Filtering instead

### Create a New Custom Object Instance

```
POST /custom_object/
```

**Required Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `custom_object_type_id` | string | Yes | Determines available custom fields |
| `lead_id` | string | Yes | Associated lead identifier |
| `name` | string | Yes | Display name for the instance |

Custom fields are set using format `custom.{custom_field_id}`.

### Retrieve a Single Custom Object Instance

```
GET /custom_object/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Unique instance identifier |

### Update a Custom Object Instance

```
PUT /custom_object/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Unique instance identifier |

**Modifiable Fields:**
- Custom field values (add, change, or remove)
- `name` property

### Delete a Custom Object Instance

```
DELETE /custom_object/{id}/
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (path) | Yes | Instance to delete |

---

# 7. Changelog

## March 6th, 2026 - `applies_to` field on Outcomes deprecated for write operations

The `applies_to` field on the Outcome API is now deprecated on write operations (create and update). Future updates will derive this field from the `type` field:
- When `type` is `custom`, `applies_to` will be `["calls", "meetings"]`
- When `type` is `vm-dropped`, `applies_to` will be `["calls"]`

The field continues to be returned in read responses.

## January 14th, 2026 - Form Submissions API

Form Submissions added as a new activity type, created when someone fills out a Close Form. New webhook events: `activity.form_submission.created`, `activity.form_submission.updated`, and `activity.form_submission.deleted`.

## December 17th, 2025 - `sender` field requirements for Email activities

Fixed bug allowing email creation without required `sender`. The `sender` field is now required for emails with status `inbox`, `scheduled`, `outbox`, or `error`. It may be omitted for `draft` status or defaults to user's email for `sent` status.

## August 25th, 2025 - Note titles and pinned_at timestamps

Added ability to set Note `title` field when creating or updating Notes. Added `title` and `pinned_at` fields to Note API responses.

## August 14th, 2025 - Transcription related fields in Meeting API

Added `transcripts` field to Meeting API responses.

## July 29th, 2025 - Outcome API

Introduced new Outcome API for organizing and managing outcomes -- standardized results applicable to activities like calls and meetings.

## July 16th, 2025 - Field Enrichment API

Introduced Field Enrichment API using AI to intelligently populate fields on leads and contacts.

## June 25th, 2025 - WhatsApp Messages API

Added WhatsApp Messages as new activity type for syncing WhatsApp conversations into Close. Supports inbound/outbound messages, file attachments (up to 25MB), integration links, and thread support via `response_to_id` field. New webhook events: `activity.whatsapp_message.created`, `activity.whatsapp_message.updated`, `activity.whatsapp_message.deleted`.

## Feb 14th, 2025 - `lead_id` is now optional when creating a Contact or Opportunity

Ability to create a Contact without specifying `lead_id` -- automatically creates new Lead named after the contact. Similarly, creating an Opportunity without `lead_id` creates untitled Lead and associates the opportunity.

## Jan 6th, 2025 - Updating Webhook Subscriptions

Webhook Subscription PUT endpoint now accepts `url`, new `events` list, and `verify_ssl` parameter to control SSL verification at destination URL.

## Dec 2nd, 2024 - `record_calls` field on memberships deprecated

Boolean `record_calls` field deprecated in favor of `auto_record_calls` enum field with values `'unset'`, `'enabled'`, or `'disabled'`.

## Nov 6th, 2024 - Date format in CSV Exports

Export API updated with new `date_format` parameter to control date object formatting in CSV exports.

## Sep 9th, 2024 - Archiving Custom Object Types

Custom Object Types can now be archived via `is_archived: true` flag during update operations.

## Aug 28th, 2024 - Custom Objects are now public

Custom Objects no longer in beta; available to everyone on corresponding billing plan.

## Jun 26th, 2024 - Delete Lead & Opportunity status change activities

Added ability to delete Lead and Opportunity Status Change activities. Deletion removes event from activity feed without changing Lead or Opportunity status.

## Jun 20th, 2024 - Create Lead & Opportunity status change activities

Added ability to create Lead and Opportunity Status Change activities. Creates log entries without changing status -- useful for importing historical changes.

## Jun 10th, 2024 - Disallow Membership creation via API Keys

Membership API no longer allows creation via API keys; possible only with OAuth.

## Jun 7th, 2024 - Lead API only returns incomplete tasks

Lead API now returns only incomplete tasks in "tasks" field. Completed tasks accessible via Task API filtering by `lead_id` and `view=archive`.

## Apr 24th, 2024 - Rate limit body deprecated

Rate limit information should be in headers (RFC spec compliant) rather than request body.

## Mar 28th, 2024 - Commenting API

New Commenting API added for commenting on objects within Close.

## Mar 27th, 2024 - Pipeline fields in Opportunities

Added `pipeline_id` and `pipeline_name` fields to Opportunity responses without requiring extra request.

## Feb 26th, 2024 - Files API, Email Attachments

New Files API for uploading files to Close for use as email attachments in activities and templates.

## Feb 21st, 2024 - Custom Objects (BETA)

Custom Objects API (BETA) added for managing Custom Object Types, Instances, and Custom Fields. Subject to change without notice.

## Feb 15th, 2024 - Email Unsubscribe

Contact resource now includes `emails[].is_unsubscribed` attribute. New webhook event: `unsubscribed_email.created`.

## Nov 13th, 2023 - Scheduling Link integrations

Two new OAuth endpoints added for integrating OAuth Applications to sync scheduling links into Close.

## Nov 10, 2023 - Returning single custom fields in the Leads API

Leads API now supports returning subset of custom fields when querying leads.

## Oct 26th, 2023 - Transcription related fields in Call API

Added `recording_transcript` and `voicemail_transcript` fields to Call API responses.

## Oct 2nd, 2023 - Change to Sequence Subscription API

Added `lead_id` field to Sequence Subscription API responses.

## Sept 21st, 2023 - Third party Meeting integrations & Meeting search

Ability to create/update third-party Meeting integrations (OAuth apps only). New Meeting search endpoint for filtering by calendar provider information.

## Aug 29th, 2023 - Change to the Sequence API

New `schedule` field added; existing `schedule_id` field removed from Sequence API.

## July 21st, 2023 - Rate limit headers updated

Rate limit headers updated to comply with current RFC specification.

## June 29th, 2023 - Lead visibility related fields in Role

Lead visibility-related fields added to Roles API.

## June 20th, 2023 - OAuth Applications

OAuth support added for authentication and authorization.

## May 1st, 2023 - Scheduling Links

Scheduling Links support added to the API.

## Dec 22nd, 2022 - "Hidden" type Custom Field values visible in Event Log

"Hidden" type Custom Field values now displayed in Event Log (previously hidden).

## Sept 26th, 2022 - SMS Templates

SMS Templates support added.

## Mar 10th, 2022 - Sequences

Support added for calling steps within Sequences.

## Feb 15th, 2022 - MMS support

Added MMS support for phone rentals (Canada/USA only) via `with_mms` parameter. Added `attachments` field to SMS activities and Incoming SMS tasks.

## Feb 14th, 2022 - Advanced Filtering API

New Advanced Filtering API functionality for filtering Lead objects. Lead endpoint `query` parameter now deprecated.

## Nov 16th, 2021 - New Webhook Filters

Four new webhook filters added: `is_null`, `non_null`, `not_equals`, and `not`.

## Nov 9th, 2021 - Undocumented an old endpoint for Activity Reporting

Removed documentation for old/deprecated Activity Reporting endpoint `/report/activity/{organization_id}/`.

## June 11th, 2021 - Custom Fields on Opportunities

Opportunities can now have Custom Fields. New Opportunity Custom Field API endpoint; Shared Custom Fields extended to support Opportunities.

## June 7th, 2021 - Automatically pause failing webhook subscriptions

Webhook subscriptions automatically paused after 3 days of all event delivery failures.

## May 17th, 2021 - Custom Field ID Format

New Custom Fields share common `cf_` prefix instead of type-specific prefixes. Existing Custom Field IDs unchanged.

## Apr 22th, 2021 - Shared Custom Fields

New endpoints for creating Shared Custom Fields, associating them across object types, and reordering Custom Fields.

## Apr 13th, 2021 - Contact Filtering

New endpoint for finding Contacts by arbitrary filter sets.

## Mar 31st, 2021 - Change to the Sequence API

Listing Sequence Subscriptions now requires filtering by `sequence_id`, `lead_id`, or `contact_id`.

## Jan 5th, 2021 - Changes to the Sequence API

Permission errors now return 403 instead of 401. Sequence Step errors simplified to high-level messages.

## Oct 29th, 2020 - Microsoft Connected Accounts

Microsoft Accounts now connectable via OAuth for Office 365 email.

## Oct 9th, 2020 - Send As API

Send As feature available through API using new Send As endpoint.

## Oct 3rd, 2020 - Active Calls on the Users Availability API

Users Availability API now indicates which users are currently on active phone calls.

## Sep 18th, 2020 - New URL for the Custom Field API

Custom Field API recommended URL changed from `/custom_fields/*/` to `/custom_field/*/`. Old endpoint continues working.

## Aug 13th, 2020 - Groups

Groups allow naming collections of Users for filtering and reporting.

## Aug 7th, 2020 - Custom Activities Beta

Limited beta launch of Custom Activities feature for defining arbitrary activity types. API may change before launch.

## Jun 30th, 2020 - Connected Accounts and clarification on field usage in integrations

Connected Accounts endpoint added for retrieving connected account information. Clarification added: non-custom fields not in sample responses shouldn't be used.

## May 19th, 2020 - HTTP/2 and Header Casing

New infrastructure supports HTTP/2. Headers normalized to lowercase in responses; case-insensitive in requests.

## Apr 30th, 2020 - Custom Field Description

Custom Fields now support optional description property for user context.

## Apr 6th, 2020 - Custom Fields on Contacts

Contacts can now have Custom Fields. New Contact Custom Field API endpoint added.

## Dec 10th, 2019 - Introducing Pipelines

Pipelines introduced as named/ordered groups of Opportunity Statuses. Opportunity Statuses field in Organization/Me APIs deprecated; use `pipelines` field instead.

## Nov 13th, 2019 - Deprecate old Activity Report endpoint

New Activity Report endpoint (POST to `/report/activity/`) should replace old version (GET to `/report/activity/{ORGANIZATION_ID}/`).

## Oct 31st, 2019 - Deprecate setting a status on an Opportunity via the `status` field

Use `status_id` field for Opportunity status operations; deprecated status label usage in `status` field.

## Oct 12th, 2019 - Add new endpoint for Meeting activities

New `/activity/meeting/` endpoint added for Google Calendar Meeting activities (beta).

## Aug 20th, 2019 - POST HTTP Status Code

Newer APIs return `201` HTTP status for POST requests with `Location` header. Existing APIs continue returning `200`.

## Jul 2nd, 2019 - Add multiple value support to the bulk edit action

`custom_field_values` and `custom_field_operation` support multiple values for bulk edit actions.

## June 18th, 2019 - Add event filtering to webhook subscriptions

Webhook subscriptions now support `extra_filter` field for filtering events by field/value changes.

## May 10th, 2019 - Add API key ID to events

Event log and webhook events now contain API key ID if changes made via API key.

## May 8th, 2019 - Add new activity report endpoint

New activity report endpoint fetches additional metrics; available metrics exposed in reporting API.

## Apr. 25th, 2019 - Support for Multi-Select Custom Fields

"Choices" and "User" type Custom Fields now accept multiple values via `accepts_multiple_values: true`.

## Apr. 9th, 2019 - All exports are now compressed with GZIP

All exports compressed with GZIP; headers set to `Content-Encoding: gzip` and appropriate `Content-Type`.

## Mar. 7th, 2019 - Drop the field `plan_type` from the `Membership` API

`plan_type` field dropped for organizations using new billing system.

## Feb. 22, 2019 - New Base URL

API base URL changed from `https://app.close.io/api/v1/` to `https://api.close.com/api/v1/`. Old URL deprecated.

## Feb. 18, 2019 - Additional country fields

Country information added to Contact API (phone numbers), Phone Number API (SMS countries), and SMS API responses.

## Jan. 25, 2019 - Event Log Fields

Non-admin events include `data` and `previous_data` fields for events not older than 1 hour; older events exclude these fields.

## Nov. 28, 2018 - Webhooks Subscription API

Webhooks Subscription API added.

---

# Quick Reference: All Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/event/{id}/` | Retrieve single event |
| `GET` | `/event/` | List/filter events |
| `GET` | `/webhook/` | List webhook subscriptions |
| `POST` | `/webhook/` | Create webhook subscription |
| `GET` | `/webhook/{id}/` | Get webhook subscription |
| `PUT` | `/webhook/{id}/` | Update webhook subscription |
| `DELETE` | `/webhook/{id}/` | Delete webhook subscription |
| `GET` | `/scheduling_link/` | List user scheduling links |
| `POST` | `/scheduling_link/` | Create user scheduling link |
| `GET` | `/scheduling_link/{id}/` | Get user scheduling link |
| `PUT` | `/scheduling_link/{id}/` | Update user scheduling link |
| `DELETE` | `/scheduling_link/{id}/` | Delete user scheduling link |
| `POST` | `/scheduling_link/integration/` | Create/update OAuth scheduling link |
| `DELETE` | `/scheduling_link/integration/{source_id}/` | Delete OAuth scheduling link |
| `GET` | `/shared_scheduling_link/` | List shared scheduling links |
| `POST` | `/shared_scheduling_link/` | Create shared scheduling link |
| `GET` | `/shared_scheduling_link/{id}/` | Get shared scheduling link |
| `PUT` | `/shared_scheduling_link/{id}/` | Update shared scheduling link |
| `DELETE` | `/shared_scheduling_link/{id}/` | Delete shared scheduling link |
| `POST` | `/shared_scheduling_link_association/` | Map shared scheduling link |
| `POST` | `/shared_scheduling_link_association/unmap` | Unmap shared scheduling link |
| `GET` | `/custom_field/lead/` | List lead custom fields |
| `POST` | `/custom_field/lead/` | Create lead custom field |
| `GET` | `/custom_field/lead/{id}/` | Get lead custom field |
| `PUT` | `/custom_field/lead/{id}/` | Update lead custom field |
| `DELETE` | `/custom_field/lead/{id}/` | Delete lead custom field |
| `GET` | `/custom_field/contact/` | List contact custom fields |
| `POST` | `/custom_field/contact/` | Create contact custom field |
| `GET` | `/custom_field/contact/{id}/` | Get contact custom field |
| `PUT` | `/custom_field/contact/{id}/` | Update contact custom field |
| `DELETE` | `/custom_field/contact/{id}/` | Delete contact custom field |
| `GET` | `/custom_field/opportunity/` | List opportunity custom fields |
| `POST` | `/custom_field/opportunity/` | Create opportunity custom field |
| `GET` | `/custom_field/opportunity/{id}/` | Get opportunity custom field |
| `PUT` | `/custom_field/opportunity/{id}/` | Update opportunity custom field |
| `DELETE` | `/custom_field/opportunity/{id}/` | Delete opportunity custom field |
| `GET` | `/custom_field/activity/` | List activity custom fields |
| `POST` | `/custom_field/activity/` | Create activity custom field |
| `GET` | `/custom_field/activity/{id}/` | Get activity custom field |
| `PUT` | `/custom_field/activity/{id}/` | Update activity custom field |
| `DELETE` | `/custom_field/activity/{id}/` | Delete activity custom field |
| `GET` | `/custom_field/custom_object_type/` | List custom object custom fields |
| `POST` | `/custom_field/custom_object_type/` | Create custom object custom field |
| `GET` | `/custom_field/custom_object_type/{id}/` | Get custom object custom field |
| `PUT` | `/custom_field/custom_object_type/{id}/` | Update custom object custom field |
| `DELETE` | `/custom_field/custom_object_type/{id}/` | Delete custom object custom field |
| `GET` | `/custom_field/shared/` | List shared custom fields |
| `POST` | `/custom_field/shared/` | Create shared custom field |
| `PUT` | `/custom_field/shared/{id}/` | Update shared custom field |
| `DELETE` | `/custom_field/shared/{id}/` | Delete shared custom field |
| `POST` | `/custom_field/shared/{id}/association/` | Associate shared field |
| `PUT` | `/custom_field/shared/{id}/association/{type}/` | Update association |
| `DELETE` | `/custom_field/shared/{id}/association/{type}/` | Disassociate shared field |
| `GET` | `/custom_field_schema/{object_type}/` | Get custom field schema |
| `PUT` | `/custom_field_schema/{object_type}/` | Reorder custom fields |
| `GET` | `/custom_activity/` | List custom activity types |
| `POST` | `/custom_activity/` | Create custom activity type |
| `GET` | `/custom_activity/{id}/` | Get custom activity type |
| `PUT` | `/custom_activity/{id}/` | Update custom activity type |
| `DELETE` | `/custom_activity/{id}/` | Delete custom activity type |
| `GET` | `/activity/custom/` | List custom activity instances |
| `POST` | `/activity/custom/` | Create custom activity instance |
| `GET` | `/activity/custom/{id}/` | Get custom activity instance |
| `PUT` | `/activity/custom/{id}/` | Update custom activity instance |
| `DELETE` | `/activity/custom/{id}/` | Delete custom activity instance |
| `GET` | `/custom_object_type/` | List custom object types |
| `POST` | `/custom_object_type/` | Create custom object type |
| `GET` | `/custom_object_type/{id}/` | Get custom object type |
| `PUT` | `/custom_object_type/{id}/` | Update custom object type |
| `DELETE` | `/custom_object_type/{id}/` | Delete custom object type |
| `GET` | `/custom_object/` | List custom object instances |
| `POST` | `/custom_object/` | Create custom object instance |
| `GET` | `/custom_object/{id}/` | Get custom object instance |
| `PUT` | `/custom_object/{id}/` | Update custom object instance |
| `DELETE` | `/custom_object/{id}/` | Delete custom object instance |

**Base URL:** `https://api.close.com/api/v1/`
**Authentication:** HTTP Basic Auth with API key as username, empty password. OAuth also supported.
