# Whop — Use Cases & Practical Guide

**Date:** 2026-07-30

---

## What You Can Do

### Requires Setup (company API key + webhook)
- Receive real-time **payment.succeeded** webhooks to confirm a sale, with amount + buyer email.
- Receive **membership.activated** to confirm a new member/opt-in.
- Verify webhook authenticity via Standard Webhooks HMAC-SHA256.
- Pull payments, members, memberships, plans via REST for reconciliation/backfill.
- Read Whop's own **Conversions / Ad reports / Stats** resources.

### What the API Cannot Do (for us)
- It does not know which **YouTube video** drove the sale — that's OUR job. Whop supplies the *money truth* (email + amount); we join it to the click via hashed email.
- Buyer email is only present if the webhook has `member:email:read` scope.

---

## Automation Ideas (for the Attribo tracker)

| Use Case | Complexity | What You Do | Key Event / Endpoint |
|---|---|---|---|
| Confirm a sale from a video | Easy | Handle `payment.succeeded` → hash email → match identity → attribute to video | `payment.succeeded` |
| Attribute new members | Easy | Handle `membership.activated` as an `optin`/member event | `membership.activated` |
| Reverse revenue on refund | Medium | On `refund.created`, negate the attributed conversion | `refund.created` |
| Flag disputed revenue | Medium | On `dispute.created`, mark the conversion disputed | `dispute.created` |
| Idempotent ingestion | Easy | Dedup on `webhook-id` (Standard Webhooks) | header `webhook-id` |
| Backfill historical sales | Medium | List payments via REST, match emails to clicks | Payments list |
| Renewal vs first sale | Medium | Use payload's initial-vs-renewal flag to weight LTV | `payment.succeeded` |
| No-code fallback | Easy | Zapier *Payment Completed* → POST our `/api/webhooks/whop` | Zapier |

---

## Key Limits and Gotchas

### Auth / Webhooks
- Webhook secret is `whsec_...`; must be **base64-decoded** before HMAC.
- Signed content is `"{webhook-id}.{webhook-timestamp}.{body}"` — verify against the RAW body, not re-serialized JSON.
- Return **2xx quickly** or Whop retries (do heavy matching async / via queue).
- Secret is only returned on webhook **create** and to dashboard sessions — store it at creation time.

### Data
- Buyer email requires `member:email:read` scope on the webhook.
- Amounts are per-payment; use the initial-vs-renewal flag to separate new sales from renewals.
- API version must be pinned to `v1`.

### For our attribution use
- Whop is the **money source of truth**; the email is the deterministic join key back to the click. Email mismatch (buys with a different email than opt-in) breaks the chain — store phone as a secondary anchor.
