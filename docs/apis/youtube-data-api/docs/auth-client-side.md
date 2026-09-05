# Using OAuth 2.0 for JavaScript Web Applications
**Source:** https://developers.google.com/youtube/v3/guides/auth/client-side-web-apps
**Date:** 2026-03-01
---

## Overview

This document explains how to implement OAuth 2.0 authorization to access the YouTube Data API from a JavaScript web application. OAuth 2.0 allows users to share specific data with an application while keeping their usernames, passwords, and other information private.

This OAuth 2.0 flow is called the **implicit grant flow**. It is designed for applications that access APIs only while the user is present at the application. These applications are not able to store confidential information.

In this flow, your app opens a Google URL that uses query parameters to identify your app and the type of API access that the app requires. The user can authenticate with Google and grant the requested permissions. Google then redirects the user back to your app with an access token in the URL fragment.

**Recommendation:** If you use Google APIs client library for JavaScript to make authorized calls to Google, you should use Google Identity Services JavaScript library to handle the OAuth 2.0 flow. See Google Identity Services' token model, which is based upon the OAuth 2.0 implicit grant flow.

**Security note:** We strongly encourage you to use OAuth 2.0 libraries such as Google Identity Services' token model when interacting with Google's OAuth 2.0 endpoints. It is a best practice to use well-debugged code provided by others.

## Prerequisites

### Enable APIs for your project

Any application that calls Google APIs needs to enable those APIs in the API Console.

To enable an API for your project:
1. Open the API Library (https://console.developers.google.com/apis/library) in the Google API Console.
2. If prompted, select a project, or create a new one.
3. Use the Library page to find and enable the YouTube Data API.

### Create authorization credentials

Any application that uses OAuth 2.0 to access Google APIs must have authorization credentials that identify the application to Google's OAuth 2.0 server.

1. Go to the Clients page (https://console.developers.google.com/auth/clients).
2. Click Create Client.
3. Select the **Web application** application type.
4. Complete the form. Applications that use JavaScript to make authorized Google API requests must specify authorized JavaScript origins. The origins identify the domains from which your application can send requests to the OAuth 2.0 server.

### Identify access scopes

The YouTube Data API v3 uses the following scopes:

| Scope | Description |
|-------|-------------|
| `https://www.googleapis.com/auth/youtube` | Manage your YouTube account |
| `https://www.googleapis.com/auth/youtube.channel-memberships.creator` | See a list of your current active channel members, their current level, and when they became a member |
| `https://www.googleapis.com/auth/youtube.force-ssl` | See, edit, and permanently delete your YouTube videos, ratings, comments and captions |
| `https://www.googleapis.com/auth/youtube.readonly` | View your YouTube account |
| `https://www.googleapis.com/auth/youtube.upload` | Manage your YouTube videos |
| `https://www.googleapis.com/auth/youtubepartner` | View and manage your assets and associated content on YouTube |
| `https://www.googleapis.com/auth/youtubepartner-channel-audit` | View private information of your YouTube channel relevant during the audit process with a YouTube partner |

**Warning:** If your public application uses scopes that permit access to certain user data, it must complete a verification process. If you see "unverified app" on the screen when testing your application, you must submit a verification request to remove it.

## Obtaining OAuth 2.0 access tokens

### Step 1: Redirect to Google's OAuth 2.0 server

To request permission to access a user's data, redirect the user to Google's OAuth 2.0 server.

**Endpoint:** `https://accounts.google.com/o/oauth2/v2/auth` (HTTPS only)

**Query string parameters:**

| Parameter | Required | Description |
|-----------|----------|-------------|
| `client_id` | Required | The client ID for your application. Found in the Cloud Console Clients page. |
| `redirect_uri` | Required | Determines where the API server redirects the user after the user completes the authorization flow. Must exactly match one of the authorized redirect URIs for the OAuth 2.0 client. |
| `response_type` | Required | JavaScript applications need to set the parameter's value to `token`. This instructs the Google Authorization Server to return the access token as a name=value pair in the fragment identifier of the URI (`#`). |
| `scope` | Required | A space-delimited list of scopes that identify the resources that your application could access on the user's behalf. |
| `state` | Recommended | Specifies any string value that your application uses to maintain state between your authorization request and the authorization server's response. Used to prevent cross-site request forgery (CSRF). |
| `include_granted_scopes` | Optional | Enables applications to use incremental authorization. If set to `true` and the authorization request is granted, the new access token will also cover any scopes to which the user previously granted access. |
| `enable_granular_consent` | Optional | Defaults to `true`. If set to `false`, more granular Google Account permissions will be disabled for OAuth client IDs created before 2019. |
| `login_hint` | Optional | If your application knows which user is trying to authenticate, it can use this parameter to provide a hint to the Google Authentication Server (email address or `sub` identifier). |
| `prompt` | Optional | A space-delimited, case-sensitive list of prompts to present the user. Possible values: `none` (no authentication/consent screens), `consent` (prompt for consent), `select_account` (prompt to select an account). |

**Sample redirect URL:**
```
https://accounts.google.com/o/oauth2/v2/auth?
  scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fyoutube.readonly&
  include_granted_scopes=true&
  state=state_parameter_passthrough_value&
  redirect_uri=http%3A%2F%2Flocalhost%2Foauth2callback&
  response_type=token&
  client_id=client_id
```

**JavaScript sample code:**
```javascript
/* Create form to request access token from Google's OAuth 2.0 server. */
function oauthSignIn() {
  // Google's OAuth 2.0 endpoint for requesting an access token
  var oauth2Endpoint = 'https://accounts.google.com/o/oauth2/v2/auth';

  // Create <form> element to submit parameters to OAuth 2.0 endpoint.
  var form = document.createElement('form');
  form.setAttribute('method', 'GET');
  form.setAttribute('action', oauth2Endpoint);

  // Parameters to pass to OAuth 2.0 endpoint.
  var params = {
    'client_id': 'YOUR_CLIENT_ID',
    'redirect_uri': 'YOUR_REDIRECT_URI',
    'response_type': 'token',
    'scope': 'https://www.googleapis.com/auth/youtube.force-ssl',
    'include_granted_scopes': 'true',
    'state': 'pass-through value'
  };

  // Add form parameters as hidden input values.
  for (var p in params) {
    var input = document.createElement('input');
    input.setAttribute('type', 'hidden');
    input.setAttribute('name', p);
    input.setAttribute('value', params[p]);
    form.appendChild(input);
  }

  // Add form to page and submit it to open the OAuth 2.0 endpoint.
  document.body.appendChild(form);
  form.submit();
}
```

### Step 2: Google prompts user for consent

In this step, the user decides whether to grant your application the requested access. Google displays a consent window that shows the name of your application and the Google API services that it is requesting permission to access.

### Common Authorization Errors

| Error | Description |
|-------|-------------|
| `admin_policy_enforced` | The Google Account is unable to authorize one or more scopes requested due to the policies of their Google Workspace administrator. |
| `disallowed_useragent` | The authorization endpoint is displayed inside an embedded user-agent disallowed by Google's OAuth 2.0 Policies. |
| `org_internal` | The OAuth client ID in the request is part of a project limiting access to Google Accounts in a specific Google Cloud Organization. |
| `invalid_client` | The origin from which the request was made is not authorized for this client. See `origin_mismatch`. |
| `deleted_client` | The OAuth client being used to make the request has been deleted. Deleted clients can be restored within 30 days. |
| `invalid_grant` | The token may have expired or has been invalidated. Authenticate the user again and ask for user consent to obtain new tokens. |
| `origin_mismatch` | The scheme, domain, and/or port of the origin URL of the authorization request doesn't match an authorized origin registered for the OAuth client ID. |
| `redirect_uri_mismatch` | The redirect_uri in the authorization request does not match an authorized redirect URI for the OAuth client ID. |
| `invalid_request` | There is something wrong with the request you made. This could be due to various reasons - see the error description for details. |
| `unauthorized_client` | The OAuth client ID that was used in the request is not authorized to use this OAuth grant type. |
| `access_denied` | The user denied your application's request for access. |
| `unsupported_response_type` | The OAuth 2.0 endpoint does not support the requested response type. |
| `invalid_scope` | One or more scopes requested are invalid, unknown, or malformed. |
| `server_error` | Google's authorization server encountered an unexpected error. |
| `temporarily_unavailable` | Google's authorization server is temporarily unavailable. |

*Last updated page on Google Developers site.*
