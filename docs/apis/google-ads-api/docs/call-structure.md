# API Call Structure
**Source:** https://developers.google.com/google-ads/api/docs/concepts/call-structure
**Date:** 2026-03-01

---

This guide describes the common structure of all API calls.

If you're using a client library to interact with the API, you won't need to know the underlying request details. However, some knowledge about the API call structure can come in handy when testing and debugging.

Google Ads API is a gRPC API, with REST bindings. This means that there are two ways of making calls to the API.

## Preferred (gRPC)

1. Create the body of the request as a protocol buffer.
2. Send it to the server using HTTP/2.
3. Deserialize the response to a protocol buffer.
4. Interpret the results.

Most of the documentation describes using gRPC (reference: `/google-ads/api/reference/rpc/v23`).

## Optional (REST)

1. Create the body of request as a JSON object.
2. Send it to the server using HTTP 1.1.
3. Deserialize the response as a JSON object.
4. Interpret the results.

Refer to the REST interface guide for more information on using REST.

> **Note:** This guide describes the structure and transport headers common to both gRPC and REST protocols.

## Resource Names

Most objects in the API are identified by their resource name strings. These strings also serve as URLs when using the REST interface.

> **Key Point:** Check out the resources documentation for all supported resources and their path representation (`resource_name`). The same format is used for other services.

## Composite IDs

If the ID of an object is not globally unique, a composite ID for that object is constructed by prepending its parent ID and a tilde (`~`).

For example, since an ad group ad ID is not globally unique, we prepend its parent object (ad group) ID to it to make a unique composite ID:

- `AdGroupId` of **`123`** + `~` + `AdGroupAdId` of **`45678`** = composite ad group ad ID of **`123~45678`**

## Request Headers

These are the HTTP headers (or grpc metadata) that accompany the body in the request:

### Authorization

You must include an OAuth2 access token in the form of `Authorization: Bearer YOUR_ACCESS_TOKEN` that identifies either a manager account acting on behalf of a client, or an advertiser directly managing their own account.

- Directions for retrieving an access token can be found in the OAuth2 guide.
- An access token is valid for an hour after you acquire it; when it expires, refresh the access token to retrieve a new one.
- Client libraries automatically refresh expired tokens.
- A `USER_PERMISSION_DENIED` error indicates that the authenticated user may not have access to the customer account specified in the request.

### developer-token

A developer token is a 22-character string that uniquely identifies a Google Ads API developer. Example: `ABcdeFGH93KL-NOPQ_STUv`

Include in requests as: `developer-token: ABcdeFGH93KL-NOPQ_STUv`

### login-customer-id

This is the customer ID of the authorized customer to use in the request, without hyphens (`-`).

- If your access to the customer account is through a manager account, this header is **required** and must be set to the customer ID of the manager account.
- If you fail to include `login-customer-id` when you authenticate through a manager account, this results in an `AuthorizationError.USER_PERMISSION_DENIED` error.

**Key Term:** The **operating customer** is the customer ID in the request payload. For example, the operating customer in the following `CampaignBudgetService` request is `1234567890`:

```
https://googleads.googleapis.com/v23/customers/1234567890/campaignBudgets:mutate
```

Setting the `login-customer-id` is equivalent to choosing an account in the Google Ads UI after signing in. If you don't include this header, it defaults to the **operating customer**.

> **Note:** You can retrieve the list of accounts directly accessible with your OAuth credentials by issuing a `CustomerService.ListAccessibleCustomers` request. The `login-customer-id` is not required for this request type.

### linked-customer-id

This header is only used by third-party app analytics providers when uploading conversions to a linked Google Ads account.

Consider the scenario where users on account `A` provide read and edit access to its entities to account `B` through a `ThirdPartyAppAnalyticsLink`. Once linked, a user on account `B` can make API calls against account `A`, subject to the permissions provided by the link.

The third-party app analytics provider makes an API call as follows:
- `linked-customer-id`: The third-party app analytics account that uploads the data (account `B`).
- `customer-id`: The Google Ads account to which data is uploaded (account `A`).
- `login-customer-id` and `Authorization` header: A combination of values to identify a user who has access to account `B`.

## Response Headers

The following headers (or grpc trailing-metadata) are returned with the response body. We recommend logging these values for debugging purposes.

### request-id

The `request-id` is a string that uniquely identifies this request.

---
*Last updated 2026-02-26 UTC. Content licensed under Creative Commons Attribution 4.0 License.*
