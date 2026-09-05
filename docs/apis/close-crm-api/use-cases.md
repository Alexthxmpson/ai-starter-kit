# Close CRM API — Use Cases & Practical Reference

> **Source**: https://developer.close.com
> **Date**: 2026-03-30
> **Auth**: API Key (Basic Auth) or OAuth 2.0 (Bearer Token)
> **Base URL**: `https://api.close.com/api/v1`
> **Env var**: `CLOSE_API_KEY` (not yet set)

---

## What You Can Do

### Free (included with any Close plan that has API access)

| Use Case | Difficulty | Endpoint(s) |
|----------|-----------|-------------|
| List/search leads | Easy | `GET /lead/` |
| Create/update leads | Easy | `POST /lead/`, `PUT /lead/{id}/` |
| Manage contacts | Easy | `GET /contact/`, `POST /contact/`, `PUT /contact/{id}/` |
| Log activities (calls, emails, notes) | Easy | `POST /activity/` |
| Manage opportunities | Easy | `GET /opportunity/`, `POST /opportunity/` |
| Manage tasks | Easy | `GET /task/`, `POST /task/` |
| Webhook subscriptions (up to 40) | Medium | `POST /webhook-subscription/` |
| Export data | Medium | Export API |
| Advanced filtering (Smart Views) | Medium | Advanced Filtering API |
| Custom fields CRUD | Medium | `GET /custom_field/`, `POST /custom_field/` |
| Custom objects | Complex | Custom Objects API |
| Full OAuth integration for public apps | Complex | OAuth 2.0 flow |

### Automation Ideas

| Idea | Skills Involved | Complexity |
|------|----------------|------------|
| Sync Close leads with Airtable CRM | Close API + Airtable | Medium |
| Auto-create leads from form submissions | Close API + webhook receiver | Easy |
| Daily pipeline report to Discord | Close API + Discord webhook | Medium |
| Bi-directional sync with ClickUp tasks | Close API + ClickUp API | Complex |
| Auto-log call activities from Retell AI | Close API + Retell webhook | Medium |
| Lead scoring based on activity count | Close API + custom logic | Medium |
| Automated follow-up task creation | Close API + Trigger.dev | Medium |
| Webhook-driven Slack notifications | Close webhooks + Slack | Easy |
| Export and analyze pipeline in Sheets | Close Export API + Google Sheets | Medium |
| OAuth app for multi-org management | Close OAuth + custom app | Complex |

---

## Key Limits & Gotchas

| Limit | Value |
|-------|-------|
| Rate limit (per API key) | ~20 RPS (varies by endpoint group) |
| Rate limit (per org) | 3x per-key limit (~60 RPS) |
| Webhook subscriptions max | 40 per org (500 for Zapier/Backendless/Integrately/Customer.io) |
| Webhook retry window | Up to 72 hours with exponential backoff |
| Webhook auto-pause | At 100K backlogged events or 3 days of failures |
| `_skip` max | Varies per resource (use date range for deep pagination) |
| OAuth token lifetime | 3600 seconds (1 hour), refresh with `refresh_token` |
| URL max length | 2000 chars recommended (use `_params` body for longer) |
| PUT = Patch | Only send changed fields, not full object |
| Undocumented fields | May change without warning -- only use fields in sample responses |

---

## Available Tools & Scripts

| Tool | Language | Link |
|------|----------|------|
| Official Python wrapper | Python | https://github.com/closeio/closeio-api |
| Official Node.js wrapper | Node.js | https://github.com/closeio/closeio-node |
| Ruby wrapper | Ruby | https://github.com/taylorbrooks/closeio |
| Laravel client | PHP | https://github.com/gyurobenjamin/closeio-laravel-api |
| .NET library | C# | https://github.com/MoreThanRewards/CloseIoDotNet |
| Go client | Go | https://github.com/veyo-care/closeio-golang-client |

---

## Local Documentation

- **Core resources reference**: `C:/Users/Aleki/api-docs/close-crm/core-resources.md` (16 resources, all endpoints)
- **Full topics reference**: `C:/Users/Aleki/api-docs/close-crm/topics.md`
- **Documentation folder**: `Documentation API/Close CRM API/documentation.md`
- **This file**: `Documentation API/Close CRM API/use-cases.md`
