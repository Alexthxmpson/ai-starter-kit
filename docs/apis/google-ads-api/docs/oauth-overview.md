# Use OAuth 2.0 to Access Google Ads API
**Source:** https://developers.google.com/google-ads/api/docs/oauth/overview
**Date:** 2026-03-01

---

> **Note:** In addition to the OAuth 2.0 credentials, you also need a developer token to make API calls.

Just like other Google APIs, Google Ads API also uses the OAuth 2.0 protocol for authentication and authorization. OAuth 2.0 enables your Google Ads API client app to access a user's Google Ads account without having to handle or store the user's login info.

Broadly speaking, all the OAuth 2.0 authorization scenarios that Google supports also works with Google Ads API. However, the focus is on a handful of scenarios that are most common for Google Ads API developers.

## OAuth 2.0 Scenario Decision Table

| Scenario | Recommended Approach |
|----------|----------------------|
| My app already uses one or more Google APIs. I have already built support for OAuth 2.0 workflows for my app, and just need to add Google Ads API functionality to my existing app. | Make sure your authorized user or your service account has access to the Google Ads API accounts you are making API calls to. Refer to the multi-user authentication workflow or the service account workflow depending on the approach you are using with the rest of the Google APIs. |
| I am building an app that manages Google Ads accounts that I already have access to. If I need to manage new Google Ads accounts in the future, I will gain access to those accounts by linking them under my Google Ads Manager account. OR Someone will invite me to manage those accounts. | Use service account workflow. If you have organizational policies that prevent you from using service accounts, then use single-user authentication workflow as a fallback. |
| I am building an app that manages Google Ads accounts on behalf of other users. My app will build a user screen that lets the logged in users to connect to their Google Ads accounts and authorize my app to manage those accounts on their behalf. | Use multi-user authentication. |

## OAuth Workflow Types

### Service Account Workflow
Best for: Apps that manage accounts the developer already has access to, or accounts linked under a Manager account.

### Single-User Authentication Workflow
Best for: Fallback when service accounts are restricted by organizational policies.

### Multi-User Authentication Workflow
Best for: Apps that manage Google Ads accounts on behalf of other users (SaaS platforms, agencies).

## Managing Access

To review and revoke access for third-party applications connected to your Google Account, visit your Google Account permissions page at: https://myaccount.google.com/permissions

**Next:** Access model overview

---
*Last updated 2026-02-26 UTC. Content licensed under Creative Commons Attribution 4.0 License.*
