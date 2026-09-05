# Stripe API — Use Cases

## Overview

This document maps common payment and billing scenarios to the Stripe API endpoints and features needed to implement them. Difficulty ratings are relative to a developer with basic REST API experience.

| Difficulty | Meaning |
|---|---|
| Beginner | Single API call or hosted UI; minimal backend logic |
| Intermediate | Multiple API calls, webhook handling, or state management required |
| Advanced | Complex orchestration, multi-party flows, or significant business logic |

---

## Use Case Reference Table

| Use Case | Key Endpoints | Difficulty |
|---|---|---|
| Accept one-time payments | `POST /v1/checkout/sessions` (mode=payment), `POST /v1/payment_intents`, Stripe.js `confirmPayment()` | Beginner |
| Build subscription billing | `POST /v1/products`, `POST /v1/prices` (recurring), `POST /v1/subscriptions`, `invoice.paid` webhook | Intermediate |
| Create a customer portal | Stripe Billing Portal (`POST /v1/billing_portal/sessions`), `customer.subscription.*` webhooks | Beginner |
| Handle failed payments and retries | `invoice.payment_failed` webhook, `POST /v1/subscriptions/{id}` (payment retry), Smart Retries config | Intermediate |
| Issue refunds programmatically | `POST /v1/refunds`, `GET /v1/charges`, `charge.refunded` webhook | Beginner |
| Track revenue and transactions | `GET /v1/balance`, `GET /v1/balance_transactions`, `GET /v1/charges`, `GET /v1/invoices` | Beginner |
| Build marketplace payments (Connect) | `POST /v1/accounts`, `POST /v1/payment_intents` (transfer_data), `POST /v1/transfers`, `POST /v1/payouts` | Advanced |

---

## Detailed Use Case Notes

### Accept One-Time Payments

The fastest path is Stripe Checkout — a hosted page that handles card validation, 3D Secure, and mobile wallets automatically.

Workflow:
1. Create a Checkout Session (`mode=payment`) with line items and redirect URLs
2. Redirect the user to `session.url`
3. Stripe redirects back to `success_url` after payment
4. Listen for `checkout.session.completed` or `payment_intent.succeeded` to fulfill the order

For custom UIs, use Stripe Elements client-side paired with `POST /v1/payment_intents` server-side and `stripe.confirmPayment()` in the browser.

Key endpoints:
- `POST /v1/checkout/sessions`
- `POST /v1/payment_intents`
- `GET /v1/payment_intents/{id}`
- Webhook: `payment_intent.succeeded`

---

### Build Subscription Billing

Recurring billing requires setting up Products and Prices, attaching them to Customers, and handling the subscription lifecycle via webhooks.

Workflow:
1. Create a Product and a recurring Price (monthly/annual)
2. Create or retrieve a Customer
3. Create a Subscription tied to the Customer and Price
4. Handle `invoice.paid` to activate access and `customer.subscription.deleted` to revoke it
5. Use `payment_behavior=default_incomplete` and expand `latest_invoice.payment_intent` to collect payment on first invoice

Key endpoints:
- `POST /v1/products`, `POST /v1/prices`
- `POST /v1/customers`, `POST /v1/subscriptions`
- `POST /v1/subscriptions/{id}` (upgrades/downgrades)
- `DELETE /v1/subscriptions/{id}` (cancellation)
- Webhooks: `invoice.paid`, `invoice.payment_failed`, `customer.subscription.created`, `customer.subscription.deleted`

---

### Create a Customer Portal

Stripe's hosted Billing Portal lets customers manage their own subscriptions, update payment methods, and view invoices — no custom UI required.

Workflow:
1. Enable the Billing Portal in the Stripe Dashboard
2. When a customer wants to manage their account, create a portal session server-side
3. Redirect to `session.url`
4. Stripe handles plan changes, cancellations, and payment method updates
5. Receive `customer.subscription.*` webhooks to sync state in your database

Key endpoints:
- `POST /v1/billing_portal/sessions`
- Webhooks: `customer.subscription.updated`, `customer.subscription.deleted`

---

### Handle Failed Payments and Retries

Failed subscription payments are common. Stripe provides Smart Retries (automatic) and manual retry controls.

Workflow:
1. Listen for `invoice.payment_failed` webhook
2. Notify the user via email and link them to update their payment method
3. Use the Billing Portal or a custom UI to collect a new PaymentMethod
4. Attach the PaymentMethod and retry: `POST /v1/invoices/{id}/pay`
5. Configure Smart Retries and dunning settings in the Stripe Dashboard

Key endpoints:
- `GET /v1/invoices?status=open&customer=cus_xxx`
- `POST /v1/invoices/{id}/pay`
- `POST /v1/payment_methods/{id}/attach`
- `POST /v1/customers/{id}` (update `default_source`)
- Webhooks: `invoice.payment_failed`, `invoice.payment_action_required`

---

### Issue Refunds Programmatically

Refunds can be full or partial and are tied to a Charge or PaymentIntent.

Workflow:
1. Retrieve the Charge or PaymentIntent ID for the order
2. Create a Refund with an optional `amount` (omit for full refund) and `reason`
3. Listen for `charge.refunded` to update your records
4. Refunds typically reach the customer in 5–10 business days

Key endpoints:
- `POST /v1/refunds`
- `GET /v1/refunds?charge=ch_xxx`
- `GET /v1/charges/{id}`
- Webhook: `charge.refunded`

---

### Track Revenue and Transactions

Stripe provides balance and transaction APIs for reconciliation and reporting.

Workflow:
1. Retrieve the current account balance to see available and pending funds
2. List balance transactions for a full audit trail (includes charges, refunds, payouts, fees)
3. Filter by `type` (`charge`, `refund`, `payout`, `stripe_fee`) for specific reports
4. Use the `created` range parameters for date-scoped reports
5. Export data via the Stripe Dashboard or pull via API for custom dashboards

Key endpoints:
- `GET /v1/balance`
- `GET /v1/balance_transactions?type=charge&created[gte]=1700000000`
- `GET /v1/charges?created[gte]=1700000000`
- `GET /v1/invoices?status=paid`

---

### Build Marketplace Payments (Stripe Connect)

Stripe Connect allows platforms to route payments to third-party sellers or service providers, deducting a platform fee.

Workflow:
1. Create connected accounts for each seller (`POST /v1/accounts`)
2. Onboard sellers via Stripe's hosted onboarding (`POST /v1/account_links`)
3. Create a PaymentIntent with `transfer_data[destination]` pointing to the connected account
4. Stripe automatically routes funds and deducts platform fees
5. Connected accounts can manage their own payouts
6. Use `POST /v1/transfers` for manual payouts and `POST /v1/payouts` for bank transfers

Key endpoints:
- `POST /v1/accounts`, `POST /v1/account_links`
- `POST /v1/payment_intents` (with `transfer_data`, `application_fee_amount`)
- `POST /v1/transfers`
- `GET /v1/balance` (on connected account via `Stripe-Account` header)
- Webhooks: `account.updated`, `payment_intent.succeeded`

---

## Additional Patterns

### Saving a Card for Later

Use a SetupIntent to collect and save a PaymentMethod without charging:
- `POST /v1/setup_intents` + `stripe.confirmSetup()` client-side
- Attach the resulting PaymentMethod to a Customer for future charges

### Applying Discounts

1. Create a Coupon (`POST /v1/coupons`) with a percentage or fixed amount
2. Optionally create a PromotionCode for a customer-facing coupon code
3. Apply to a Subscription or Checkout Session via `discounts[0][coupon]`

### Testing Webhooks Locally

```bash
# Install Stripe CLI, then:
stripe listen --forward-to localhost:3000/webhook

# Trigger a specific event for testing:
stripe trigger invoice.paid
stripe trigger customer.subscription.created
```
