# HubSpot CRM API — Authentication & Authorization Briefing
**Source:** agent1-auth-core-objects.md
**Date:** 2026-03-18

---

## Quick Summary (Executive View)

HubSpot supports two recommended authentication methods: **Private Apps** (recommended for internal tools and AI agents) and **OAuth 2.0** (required for multi-tenant third-party apps). Legacy API keys (`hapikey`) are deprecated and must not be used for new integrations. For AI agents and automated pipelines running on a single HubSpot portal, Private Apps are the right choice — they issue a non-expiring access token and have a simpler setup flow than OAuth.

All API calls require a `Bearer` token in the `Authorization` header:
```
Authorization: Bearer YOUR_ACCESS_TOKEN
```

---

## Private Apps Setup (Step by Step)

Private Apps are the simplest and most secure path for internal automation. The token never expires, scope changes are controlled by the developer, and there is no OAuth redirect flow to implement.

**Step 1: Navigate to Settings**
Go to: HubSpot Settings → Integrations → Private Apps

**Step 2: Create a New Private App**
- Click "Create private app"
- Give it a name (e.g., "CRM Automation Agent")
- Add a description for auditing purposes

**Step 3: Assign Scopes**
On the Scopes tab, select only the permissions your app needs (principle of least privilege). See the Scopes Reference table below.

**Step 4: Create the App**
Click "Create app" — HubSpot displays your access token once. Copy it immediately to a secrets manager or `.env` file. You can regenerate it but the old token is invalidated immediately.

**Step 5: Use the Token**
All API calls use:
```
Authorization: Bearer {your_token}
Content-Type: application/json
```

**Token rotation:** The token does not expire on its own. Rotate it manually if you suspect exposure. Rotation invalidates the previous token immediately.

---

## OAuth 2.0 Flow (When to Use)

Use OAuth when building a product that connects to multiple HubSpot portals (customers' accounts). OAuth issues short-lived access tokens (6 hours) and long-lived refresh tokens.

**When to use OAuth vs Private Apps:**
- **Private App:** Your own portal, internal automation, AI agents, single-customer tools
- **OAuth:** Multi-tenant SaaS, marketplace apps, tools where customers authorize access to their portals

**Authorization Code Flow:**

```
1. Redirect user to HubSpot authorization URL:
   GET https://app.hubspot.com/oauth/authorize
     ?client_id={CLIENT_ID}
     &scope={space-separated scopes}
     &redirect_uri={YOUR_REDIRECT_URI}
     &response_type=code
     &state={random_nonce}

2. User approves → HubSpot redirects to:
   {redirect_uri}?code={AUTHORIZATION_CODE}&state={nonce}

3. Exchange code for tokens:
   POST https://api.hubspot.com/oauth/v1/token
   Content-Type: application/x-www-form-urlencoded
   Body: grant_type=authorization_code
         &code={AUTHORIZATION_CODE}
         &redirect_uri={REDIRECT_URI}
         &client_id={CLIENT_ID}
         &client_secret={CLIENT_SECRET}

4. Response:
   {
     "access_token": "...",       # valid 6 hours
     "refresh_token": "...",      # long-lived, use to get new access token
     "expires_in": 21600,
     "token_type": "bearer"
   }

5. Refresh when expired:
   POST https://api.hubspot.com/oauth/v1/token
   Body: grant_type=refresh_token
         &refresh_token={REFRESH_TOKEN}
         &client_id={CLIENT_ID}
         &client_secret={CLIENT_SECRET}
```

---

## Complete Scopes Reference Table

| Scope | Access Level | What It Enables |
|---|---|---|
| `crm.objects.contacts.read` | Read | Read contact records |
| `crm.objects.contacts.write` | Write | Create/update/archive contacts |
| `crm.objects.companies.read` | Read | Read company records |
| `crm.objects.companies.write` | Write | Create/update/archive companies |
| `crm.objects.deals.read` | Read | Read deal records |
| `crm.objects.deals.write` | Write | Create/update/archive deals |
| `crm.objects.tickets.read` | Read | Read ticket records |
| `crm.objects.tickets.write` | Write | Create/update/archive tickets |
| `crm.objects.line_items.read` | Read | Read line items |
| `crm.objects.line_items.write` | Write | Create/update line items |
| `crm.objects.custom.read` | Read | Read custom object records |
| `crm.objects.custom.write` | Write | Create/update custom objects |
| `crm.schemas.contacts.read` | Read | Read contact property schemas |
| `crm.schemas.contacts.write` | Write | Create/modify contact properties |
| `crm.schemas.companies.read` | Read | Read company property schemas |
| `crm.schemas.companies.write` | Write | Create/modify company properties |
| `crm.schemas.deals.read` | Read | Read deal property schemas |
| `crm.schemas.deals.write` | Write | Create/modify deal properties |
| `crm.schemas.custom.read` | Read | Read custom object schemas |
| `crm.schemas.custom.write` | Write | Create/modify custom object schemas |
| `crm.lists.read` | Read | Read CRM lists |
| `crm.lists.write` | Write | Create/manage CRM lists |
| `crm.import` | Write | Import records in bulk |
| `crm.export` | Read | Export records |
| `timeline` | Write | Create timeline events |
| `e-commerce` | Read/Write | E-commerce data |
| `oauth` | Special | Required for OAuth flow itself |
| `tickets` | Legacy | Legacy scope (use typed scopes above) |
| `contacts` | Legacy | Legacy scope (use typed scopes above) |

**Best practice:** Request only the scopes your agent actually uses. Fewer scopes = smaller blast radius if the token is compromised.

---

## Token Management for Automated Systems

For AI agents and scheduled pipelines using Private Apps, the primary concern is secure storage and retrieval, not expiry management.

**Python — Secure Token Loading:**
```python
import os
from dotenv import load_dotenv
import hubspot
from hubspot.crm.contacts import ApiException

# Load from environment
load_dotenv()
HUBSPOT_TOKEN = os.environ.get("HUBSPOT_ACCESS_TOKEN")

if not HUBSPOT_TOKEN:
    raise ValueError("HUBSPOT_ACCESS_TOKEN not set in environment")

# Initialize client
client = hubspot.Client.create(access_token=HUBSPOT_TOKEN)
```

**For OAuth in automated systems (refresh flow):**
```python
import requests
import json
import time
from pathlib import Path

TOKEN_FILE = Path(".hubspot_token.json")

def load_tokens():
    if TOKEN_FILE.exists():
        return json.loads(TOKEN_FILE.read_text())
    return None

def save_tokens(tokens):
    tokens["saved_at"] = time.time()
    TOKEN_FILE.write_text(json.dumps(tokens))

def get_valid_access_token():
    tokens = load_tokens()
    if not tokens:
        raise Exception("No tokens — complete OAuth flow first")

    # Check if access token is expired (6 hours = 21600 seconds)
    age = time.time() - tokens.get("saved_at", 0)
    if age < 21000:  # 600s buffer
        return tokens["access_token"]

    # Refresh
    response = requests.post(
        "https://api.hubspot.com/oauth/v1/token",
        data={
            "grant_type": "refresh_token",
            "refresh_token": tokens["refresh_token"],
            "client_id": os.environ["HUBSPOT_CLIENT_ID"],
            "client_secret": os.environ["HUBSPOT_CLIENT_SECRET"],
        }
    )
    response.raise_for_status()
    new_tokens = response.json()
    save_tokens(new_tokens)
    return new_tokens["access_token"]
```

**For long-running agents:** Always store tokens in environment variables or a secrets manager (AWS Secrets Manager, HashiCorp Vault, GCP Secret Manager). Never hardcode tokens in source code. Rotate Private App tokens every 90 days as a security practice.

---

## Security Best Practices

1. **Principle of least privilege** — Only request scopes actually needed. A read-only monitoring agent should have only `*.read` scopes.

2. **Never commit tokens to git** — Use `.env` files excluded via `.gitignore`, or environment variables in CI/CD.

3. **Separate tokens per environment** — Use a different Private App (and therefore different token) for dev, staging, and production portals.

4. **Audit token usage** — HubSpot logs API calls in Settings → Private Apps → Activity. Review regularly.

5. **Rotate on exposure** — If a token appears in logs, a public repo, or Slack, regenerate it immediately from the Private Apps dashboard.

6. **Validate HMAC on webhooks** — Even with a valid auth token, inbound webhook payloads should be validated with the app client secret to prevent spoofed requests.

7. **Never use legacy API keys** — `hapikey` parameters in URLs are deprecated, transmit credentials in plaintext query strings, and are no longer supported for new apps.

---

## Python Code Examples

**Basic authenticated request:**
```python
import requests

HUBSPOT_TOKEN = os.environ["HUBSPOT_ACCESS_TOKEN"]

def hubspot_get(path: str, params: dict = None) -> dict:
    response = requests.get(
        f"https://api.hubspot.com{path}",
        headers={
            "Authorization": f"Bearer {HUBSPOT_TOKEN}",
            "Content-Type": "application/json"
        },
        params=params
    )
    response.raise_for_status()
    return response.json()

# Example usage
contacts = hubspot_get("/crm/v3/objects/contacts", {"limit": 10})
```

**With SDK (recommended for production):**
```python
import hubspot
from hubspot.crm.contacts import SimplePublicObjectInputForCreate
from hubspot.crm.contacts import ApiException

client = hubspot.Client.create(access_token=os.environ["HUBSPOT_ACCESS_TOKEN"])

try:
    contact_input = SimplePublicObjectInputForCreate(
        properties={
            "email": "john@example.com",
            "firstname": "John",
            "lastname": "Doe"
        }
    )
    result = client.crm.contacts.basic_api.create(
        simple_public_object_input_for_create=contact_input
    )
    print(f"Created contact: {result.id}")
except ApiException as e:
    print(f"API error: {e.status} — {e.reason}")
```

---

## Common Errors and Fixes

| Error | HTTP Status | Cause | Fix |
|---|---|---|---|
| `MISSING_SCOPES` | 403 | Token lacks required scope | Add scope to Private App in HubSpot Settings |
| `INVALID_AUTHENTICATION` | 401 | Token invalid or revoked | Regenerate token; check token is from the right portal |
| `EXPIRED_AUTHENTICATION` | 401 | OAuth access token expired | Refresh using refresh_token |
| `RATE_LIMIT_REACHED` | 429 | Too many requests | Back off and retry; see rate-limits-briefing.md |
| `REQUEST_NOT_IN_ALLOWLIST` | 403 | IP allowlist violation (if configured) | Add your IP or use VPN |
| `This hapikey is no longer active` | 400 | Using deprecated API key | Switch to Private App token |
| `The token is associated with a different hub` | 403 | Token from wrong portal | Use correct portal's token |
