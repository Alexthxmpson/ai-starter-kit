# Whop API — Full Technical Documentation

**Source**: docs.whop.com (api-reference, developer/guides/webhooks), OpenAPI `api-v1-stable.json`
**Date Saved**: 2026-07-30
**Why harvested**: real sale/membership confirmation for the vita-attribution (Attribo) tracker — the "did this video make us a sale?" money layer.

---

## Base URLs
- Production: `https://api.whop.com/api/v1`
- Sandbox: `https://sandbox-api.whop.com/api/v1`
- OpenAPI spec: `https://docs.whop.com/openapi/api-v1-stable.json`  (version date 2026-07-29, API version `v1`)
- LLM index: `https://docs.whop.com/llms.txt`

## Authentication
- **Bearer token** in `Authorization` header: `Authorization: Bearer <key>`.
- Accepts a **company API key**, company-scoped JWT, app API key, or user OAuth token.
- Official SDK: `@whop/sdk` (also Python `whop_sdk`, Ruby `whop_sdk`).

## Webhooks (the money layer)
Whop webhooks follow the **Standard Webhooks** spec (github.com/standard-webhooks). POST to your endpoint.

**Signature headers:**
| Header | Meaning |
|--------|---------|
| `webhook-id` | unique event id (also use for idempotency/dedup) |
| `webhook-timestamp` | unix seconds |
| `webhook-signature` | `v1,<base64 HMAC-SHA256>` |

**Manual verification:** `signed_content = "{webhook-id}.{webhook-timestamp}.{raw_body}"`, then HMAC-SHA256 using the **base64-decoded** webhook secret (`whsec_...`), base64-encode the digest, compare to the value after `v1,`. The SDK's `whopsdk.webhooks.unwrap(body, {headers})` verifies + parses in one call (pass the secret base64-encoded to the client as `webhookKey`).

**Setup:** Dashboard → Developer → Create Webhook → choose events → copy secret to `WHOP_WEBHOOK_SECRET`. Ensure API version `v1`. Return a 2xx quickly or Whop retries.

### Webhook events (full enum)
`invoice.created`, `invoice.marked_uncollectible`, `invoice.paid`, `invoice.past_due`, `invoice.voided`, `membership.activated`, `membership.deactivated`, `membership.trial_ending_soon`, `membership.cancel_at_period_end_changed`, `entry.created`, `entry.approved`, `entry.denied`, `entry.deleted`, `setup_intent.requires_action`, `setup_intent.succeeded`, `setup_intent.canceled`, `ledger_account.funds_available`, `withdrawal.created`, `withdrawal.updated`, `course_lesson_interaction.completed`, `payout_method.created`, `verification.succeeded`, `identity_profile.*`, `payout_account.status_updated`, `resolution_center_case.*`, `chat.message.created`, `chat.reaction.created`, **`payment.created`**, **`payment.succeeded`**, `payment.failed`, `payment.pending`, `dispute.created`, `dispute.updated`, `refund.created`, `refund.updated`, `dispute_alert.created`.

### The events that matter for attribution
| Event | Meaning | Use |
|-------|---------|-----|
| **`payment.succeeded`** | a payment processed | primary SALE signal — carries amount + buyer email (with scopes) |
| `membership.activated` | someone joined a product | opt-in/new-member signal |
| `payment.failed` | declined | dunning / churn |
| `refund.created` | refunded | reverse attributed revenue |
| `dispute.created` | chargeback | flag revenue |

**`payment.succeeded` required scopes:** `payment:basic:read`, `plan:basic:read`, `access_pass:basic:read`, `member:email:read`, `member:basic:read`, `member:phone:read`, `webhook_receive:payments`. The `member:email:read` scope is what gives you the **buyer email** — the deterministic join key back to the click.

## Key REST resources (from OpenAPI tags)
Payments, Invoices, Memberships, Members, Plans, Promo codes, Refunds, Disputes, Payment intents, **Conversions**, **Stats**, **Affiliates**, **Ad reports**, Companies, Courses, Webhooks, Access tokens. Notable for us: `POST /webhooks` (create), Payments (retrieve/list), Members (email/phone), Conversions + Ad reports (Whop's own attribution surface).

## Third-party
- **Zapier**: triggers incl. *Payment Completed* (amount, currency, member details, product, plan, initial-vs-renewal), *Membership Went Valid/Invalid*, *New Member Joined* (email + product + membership id), *Payment Refunded*, *New Dispute*. Actions: Create/Refund/Retry Payment, Get Payment Fees. Good no-code fallback if not hitting the API directly.
