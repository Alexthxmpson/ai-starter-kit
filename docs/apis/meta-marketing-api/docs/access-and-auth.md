# Authorization - Marketing API

**Source:** https://developers.facebook.com/docs/marketing-api/get-started/authorization
**Date:** 2026-03-01

---

## Overview

To use the Marketing API, your app must be authorized to access ad accounts. Authorization is handled via OAuth 2.0 access tokens.

---

## App Roles

| Role | Description |
|------|-------------|
| Admin | Full control over the app, settings, and access levels |
| Developer | Can build and test the app; has access to development-level API calls |
| Tester | Can test the app with development access |

---

## Access Levels

The Marketing API has two access levels:

| Level | Description |
|-------|-------------|
| **Standard (Development)** | Default access level when app is created. Limited rate limits and account access. |
| **Advanced** | Required for production use, managing client accounts, or higher rate limits. Requires App Review. |

---

## Permissions

| Permission | Description | When to Request |
|------------|-------------|-----------------|
| `ads_read` | Read access to ad account data, campaigns, ad sets, ads, and insights | Read-only reporting tools |
| `ads_management` | Full read and write access to manage ads on behalf of users | Tools that create, edit, or delete ads |

### Requesting Permissions via OAuth

```
https://www.facebook.com/v25.0/dialog/oauth?client_id=<YOUR_APP_ID>&redirect_uri=<YOUR_URL>&scope=ads_management
```

---

## Marketing API Access vs Ads Management Standard Access

| Feature | Development Access | Standard Access | Advanced Access |
|---------|-------------------|-----------------|-----------------|
| Account Limits | Limited test accounts only | Own ad accounts | Client ad accounts |
| Rate Limits | Low | Standard | Higher |
| Business Manager Access | No | Limited | Full |
| System Users | No | No | Yes |
| Page Creation | No | No | Yes |

---

## Advanced Access Requirements

To qualify for Advanced Access, your app must:

- Have made **1,500 or more Marketing API calls** in the last 15 days
- Maintain a **less than 15% error rate** on those calls
- Pass App Review
- Complete Business Verification

---

## Example Use Cases

| Use Case | Permissions Needed | Access Level |
|----------|--------------------|--------------|
| Read and manage your own ad accounts | `ads_management` | Standard |
| Read reports for your own accounts | `ads_read` | Standard |
| Manage client ad accounts | `ads_management` | Advanced |
| Create pages and system users | `ads_management` | Advanced |

---

## Business Verification

Advanced Access and managing third-party ad accounts requires Business Verification. This confirms your business identity to Meta.

Steps:
1. Go to Business Settings in Meta Business Manager
2. Complete Business Verification under Business Info
3. Submit required documents (business registration, tax ID, etc.)
4. Wait for approval (typically a few business days)

---

## Related Resources

- [App Review](https://developers.facebook.com/docs/app-review)
- [Business Verification](https://developers.facebook.com/docs/development/release/business-verification)
- [Access Tokens](https://developers.facebook.com/docs/facebook-login/access-tokens)
- [OAuth 2.0](https://developers.facebook.com/docs/facebook-login/guides/access-tokens)
