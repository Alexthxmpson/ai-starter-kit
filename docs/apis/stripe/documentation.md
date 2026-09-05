# Stripe API — Full Technical Reference

**Source:** https://stripe.com/docs/api | https://stripe.com/docs/api/customers
**Documented:** 2026-02-27

---

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [API Keys — Test vs Live Mode](#api-keys--test-vs-live-mode)
4. [Base URL & Request Format](#base-url--request-format)
5. [Idempotency](#idempotency)
6. [Rate Limits & Pagination](#rate-limits--pagination)
7. [Error Handling](#error-handling)
8. [Customers](#customers)
9. [Products](#products)
10. [Prices](#prices)
11. [Payment Intents](#payment-intents)
12. [Payment Methods](#payment-methods)
13. [Subscriptions](#subscriptions)
14. [Invoices](#invoices)
15. [Checkout Sessions](#checkout-sessions)
16. [Billing Portal](#billing-portal)
17. [Webhooks](#webhooks)
18. [Webhook Event Types Reference](#webhook-event-types-reference)

---

## Overview

Stripe is a payments platform offering a REST API that accepts form-encoded request bodies and returns JSON responses. All API calls must be made over HTTPS. The API is versioned; the current stable version is `2024-06-20` (pinned per account in the Dashboard).

Key design decisions:
- POST bodies use `application/x-www-form-urlencoded` (not JSON)
- Responses are always JSON
- Nested objects use bracket notation: `metadata[key]=value`
- Arrays use indexed notation: `items[0][price]=price_xxx`

---

## Authentication

Stripe uses **HTTP Basic Auth** with your API secret key as the username and an empty password — or equivalently, a **Bearer token** in the `Authorization` header.

```
Authorization: Bearer sk_test_YOUR_KEY_HERE
```

All server-side requests must include this header. Never expose your secret key in client-side code or version control.

### cURL Example

```bash
curl https://api.stripe.com/v1/customers \
  -H "Authorization: Bearer sk_test_YOUR_KEY_HERE"
```

### Python SDK Setup

```python
import stripe

stripe.api_key = "sk_test_YOUR_KEY_HERE"
# Optional: pin API version
stripe.api_version = "2024-06-20"
```

### Node.js SDK Setup

```javascript
const stripe = require('stripe')('sk_test_YOUR_KEY_HERE');

// ESM / TypeScript
import Stripe from 'stripe';
const stripe = new Stripe('sk_test_YOUR_KEY_HERE', {
  apiVersion: '2024-06-20',
});
```

---

## API Keys — Test vs Live Mode

| Mode | Key Prefix | Description |
|------|-----------|-------------|
| Test Secret | `sk_test_` | Server-side; safe sandbox, no real charges |
| Live Secret | `sk_live_` | Server-side; real money, production only |
| Test Publishable | `pk_test_` | Client-side (Stripe.js) in test mode |
| Live Publishable | `pk_live_` | Client-side in production |
| Restricted | `rk_test_` / `rk_live_` | Scoped to specific resources/permissions |

The API key used determines which mode is active — there is no mode-switching parameter.

### Test Card Numbers

| Scenario | Card Number | Details |
|----------|-------------|---------|
| Successful payment | `4242 4242 4242 4242` | Any future expiry, any CVC |
| 3DS authentication required | `4000 0025 0000 3155` | Triggers 3DS challenge |
| 3DS authenticated | `4000 0027 6000 3184` | Auto-passes 3DS |
| Declined (generic) | `4000 0000 0000 0002` | card_declined |
| Declined (insufficient funds) | `4000 0000 0000 9995` | insufficient_funds |
| Declined (expired) | `4000 0000 0000 0069` | expired_card |
| Declined (incorrect CVC) | `4000 0000 0000 0127` | incorrect_cvc |

All test cards use any future expiry date (e.g. `12/34`) and any 3-digit CVC.

---

## Base URL & Request Format

```
https://api.stripe.com/v1/{resource}
```

| Method | Action |
|--------|--------|
| `POST /v1/customers` | Create |
| `GET /v1/customers/{id}` | Retrieve |
| `POST /v1/customers/{id}` | Update |
| `DELETE /v1/customers/{id}` | Delete |
| `GET /v1/customers` | List |
| `GET /v1/customers/search` | Search |

**Content-Type for POST:** `application/x-www-form-urlencoded`

**Optional headers:**
- `Stripe-Version: 2024-06-20` — Override account API version
- `Idempotency-Key: <uuid>` — Safe retries
- `Stripe-Account: acct_xxx` — Connect: act on behalf of connected account

---

## Idempotency

To safely retry POST requests without duplicating operations, pass an `Idempotency-Key` header. Stripe stores results for 24 hours.

```bash
curl https://api.stripe.com/v1/payment_intents \
  -H "Authorization: Bearer sk_test_..." \
  -H "Idempotency-Key: a8f3c1d2-9b4e-4f21-b3c7-e5d6f7a8b9c0" \
  -d amount=2000 \
  -d currency=usd
```

```python
stripe.PaymentIntent.create(
    amount=2000,
    currency="usd",
    idempotency_key="order_12345_attempt_1"
)
```

Rules:
- Only for POST requests; GET and DELETE are inherently idempotent
- Reusing a key with different parameters returns a 409 Conflict
- Use UUIDs or a deterministic hash of your request intent

---

## Rate Limits & Pagination

### Rate Limits

- Default: approximately **100 read requests/second** and **100 write requests/second** per secret key
- Sustained over-limit triggers `429 Too Many Requests`
- Implement exponential backoff: wait 1s, 2s, 4s, 8s... between retries

```python
import time
import stripe

def stripe_with_retry(fn, *args, max_retries=5, **kwargs):
    for attempt in range(max_retries):
        try:
            return fn(*args, **kwargs)
        except stripe.error.RateLimitError:
            if attempt == max_retries - 1:
                raise
            time.sleep(2 ** attempt)
```

```javascript
async function stripeWithRetry(fn, maxRetries = 5) {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fn();
    } catch (err) {
      if (err.type !== 'StripeRateLimitError' || attempt === maxRetries - 1) throw err;
      await new Promise(r => setTimeout(r, Math.pow(2, attempt) * 1000));
    }
  }
}
```

### Pagination

All list endpoints use **cursor-based pagination**. Responses include `data` (array) and `has_more` (boolean).

| Parameter | Type | Description |
|-----------|------|-------------|
| `limit` | integer | Objects to return (1–100, default 10) |
| `starting_after` | string | Return objects after this object ID |
| `ending_before` | string | Return objects before this object ID |

```python
# Auto-paginate with SDK iterator
for customer in stripe.Customer.auto_paging_iter():
    print(customer.id)

# Manual pagination
page = stripe.Customer.list(limit=100)
while page.has_more:
    page = stripe.Customer.list(limit=100, starting_after=page.data[-1].id)
    for customer in page.data:
        print(customer.id)
```

```javascript
// Auto-paginate with SDK async iterator
for await (const customer of stripe.customers.list()) {
  console.log(customer.id);
}
```

### Response Expand

Expand related object IDs into full objects using the `expand[]` parameter:

```python
subscription = stripe.Subscription.retrieve(
    "sub_xxx",
    expand=["latest_invoice.payment_intent", "customer"]
)
```

```javascript
const subscription = await stripe.subscriptions.retrieve('sub_xxx', {
  expand: ['latest_invoice.payment_intent', 'customer'],
});
```

---

## Error Handling

### HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 400 | Bad Request — missing or invalid parameters |
| 401 | Unauthorized — invalid or missing API key |
| 402 | Request Failed — valid params but request failed (e.g. card declined) |
| 403 | Forbidden — restricted key lacks permission |
| 404 | Not Found — resource does not exist |
| 409 | Conflict — idempotency key reused with different params |
| 429 | Too Many Requests — rate limit exceeded |
| 500–504 | Server Error — Stripe-side issue, retry with backoff |

### Error Object

```json
{
  "error": {
    "type": "card_error",
    "code": "card_declined",
    "decline_code": "insufficient_funds",
    "message": "Your card has insufficient funds.",
    "param": null,
    "charge": "ch_3Mxxxxxxxxxxxxxxx",
    "payment_intent": {
      "id": "pi_3Mxxxxxxxxxxxxxxx",
      "status": "requires_payment_method"
    }
  }
}
```

### Error Types

| type | Description |
|------|-------------|
| `api_error` | Stripe server-side problem |
| `card_error` | Card was declined or invalid |
| `idempotency_error` | Idempotency key reused with different params |
| `invalid_request_error` | Missing or invalid request parameters |

### Python Error Handling

```python
import stripe

try:
    pi = stripe.PaymentIntent.create(amount=2000, currency="usd")
except stripe.error.CardError as e:
    # Card declined
    body = e.json_body
    err = body.get('error', {})
    print(f"Status: {e.http_status}")
    print(f"Type: {err.get('type')}")
    print(f"Code: {err.get('code')}")
    print(f"Decline code: {err.get('decline_code')}")
    print(f"Message: {err.get('message')}")
except stripe.error.RateLimitError:
    print("Rate limit hit — retry with backoff")
except stripe.error.InvalidRequestError as e:
    print(f"Invalid parameter: {e.param}")
except stripe.error.AuthenticationError:
    print("Invalid API key")
except stripe.error.APIConnectionError:
    print("Network error — retry")
except stripe.error.StripeError as e:
    print(f"General Stripe error: {e}")
except Exception as e:
    print(f"Non-Stripe error: {e}")
```

### Node.js Error Handling

```javascript
try {
  const paymentIntent = await stripe.paymentIntents.create({
    amount: 2000,
    currency: 'usd',
  });
} catch (err) {
  switch (err.type) {
    case 'StripeCardError':
      console.log(`Card declined: ${err.code}, decline: ${err.decline_code}`);
      break;
    case 'StripeRateLimitError':
      console.log('Rate limited — retry later');
      break;
    case 'StripeInvalidRequestError':
      console.log(`Invalid param: ${err.param}`);
      break;
    case 'StripeAuthenticationError':
      console.log('Bad API key');
      break;
    case 'StripeAPIError':
    default:
      console.log(`Stripe server error: ${err.message}`);
  }
}
```

---

## Customers

Customers represent people or organizations you charge. They store payment methods, subscriptions, and invoices.

**Base endpoint:** `https://api.stripe.com/v1/customers`

### The Customer Object

```json
{
  "id": "cus_NffrFeUfNV2Hib",
  "object": "customer",
  "address": {
    "city": "San Francisco",
    "country": "US",
    "line1": "510 Townsend St",
    "line2": null,
    "postal_code": "94103",
    "state": "CA"
  },
  "balance": 0,
  "created": 1680893993,
  "currency": "usd",
  "default_source": null,
  "delinquent": false,
  "description": "Premium subscriber",
  "discount": null,
  "email": "jenny.rosen@example.com",
  "invoice_prefix": "0759376C",
  "invoice_settings": {
    "custom_fields": null,
    "default_payment_method": "pm_xxxxxxxxxxxxxx",
    "footer": null
  },
  "livemode": false,
  "metadata": { "user_id": "usr_12345" },
  "name": "Jenny Rosen",
  "next_invoice_sequence": 5,
  "phone": "+15555555555",
  "preferred_locales": [],
  "shipping": null,
  "tax_exempt": "none",
  "test_clock": null
}
```

---

### Create a Customer

`POST /v1/customers`

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `email` | string | No | Customer email; used for receipts and dashboard search |
| `name` | string | No | Full name or business name |
| `phone` | string | No | E.164 format recommended |
| `description` | string | No | Internal description (not shown to customer) |
| `metadata` | object | No | Key-value pairs; up to 50 keys, 40-char key, 500-char value |
| `address` | object | No | `line1`, `line2`, `city`, `state`, `postal_code`, `country` |
| `shipping` | object | No | `name`, `phone`, `address` object |
| `payment_method` | string | No | ID of a PaymentMethod to attach immediately |
| `source` | string | No | Legacy token from Stripe.js |
| `tax_exempt` | string | No | `none` (default), `exempt`, `reverse` |
| `balance` | integer | No | Customer credit/debit in smallest currency unit |
| `coupon` | string | No | Coupon ID to apply a discount |
| `promotion_code` | string | No | Promotion code to apply |
| `invoice_settings` | object | No | `default_payment_method`, `footer`, `custom_fields` |
| `preferred_locales` | array | No | Ordered BCP-47 locale preferences |
| `cash_balance` | object | No | Cash balance settings |
| `tax_id_data` | array | No | Array of tax ID objects to attach |
| `next_invoice_sequence` | integer | No | Starting sequence number for invoice IDs |

**Python:**

```python
import stripe
stripe.api_key = "sk_test_..."

customer = stripe.Customer.create(
    email="jenny.rosen@example.com",
    name="Jenny Rosen",
    phone="+15555555555",
    description="Premium subscriber — acquired via landing page",
    metadata={"user_id": "usr_12345", "plan": "premium", "signup_source": "web"},
    address={
        "line1": "510 Townsend St",
        "city": "San Francisco",
        "state": "CA",
        "postal_code": "94103",
        "country": "US"
    },
    preferred_locales=["en-US"]
)
print(customer.id)  # cus_NffrFeUfNV2Hib
```

**Node.js:**

```javascript
const stripe = require('stripe')('sk_test_...');

const customer = await stripe.customers.create({
  email: 'jenny.rosen@example.com',
  name: 'Jenny Rosen',
  phone: '+15555555555',
  description: 'Premium subscriber',
  metadata: { user_id: 'usr_12345', plan: 'premium' },
  address: {
    line1: '510 Townsend St',
    city: 'San Francisco',
    state: 'CA',
    postal_code: '94103',
    country: 'US',
  },
});
console.log(customer.id);
```

**Response (200):**

```json
{
  "id": "cus_NffrFeUfNV2Hib",
  "object": "customer",
  "email": "jenny.rosen@example.com",
  "name": "Jenny Rosen",
  "created": 1680893993,
  "livemode": false,
  "metadata": { "user_id": "usr_12345", "plan": "premium" }
}
```

---

### Retrieve a Customer

`GET /v1/customers/{CUSTOMER_ID}`

```python
customer = stripe.Customer.retrieve("cus_NffrFeUfNV2Hib")
print(customer.email)
print(customer.subscriptions)
```

```javascript
const customer = await stripe.customers.retrieve('cus_NffrFeUfNV2Hib');
```

To expand related data:

```python
customer = stripe.Customer.retrieve(
    "cus_NffrFeUfNV2Hib",
    expand=["subscriptions", "default_source"]
)
```

---

### Update a Customer

`POST /v1/customers/{CUSTOMER_ID}`

Accepts the same parameters as create. Only supplied fields are updated — others remain unchanged.

```python
customer = stripe.Customer.modify(
    "cus_NffrFeUfNV2Hib",
    email="updated_email@example.com",
    metadata={"order_id": "6735", "updated": "true"},
    invoice_settings={"default_payment_method": "pm_xxxxxxxxxxxxxx"}
)
```

```javascript
const customer = await stripe.customers.update('cus_NffrFeUfNV2Hib', {
  email: 'updated_email@example.com',
  metadata: { order_id: '6735' },
  invoice_settings: { default_payment_method: 'pm_xxxxxxxxxxxxxx' },
});
```

---

### Delete a Customer

`DELETE /v1/customers/{CUSTOMER_ID}`

Permanently deletes the customer. Immediately cancels any active subscriptions. This action is **irreversible**.

```python
deleted = stripe.Customer.delete("cus_NffrFeUfNV2Hib")
print(deleted.deleted)  # True
```

```javascript
const deleted = await stripe.customers.del('cus_NffrFeUfNV2Hib');
console.log(deleted.deleted); // true
```

**Response:**

```json
{
  "id": "cus_NffrFeUfNV2Hib",
  "object": "customer",
  "deleted": true
}
```

---

### List Customers

`GET /v1/customers`

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `email` | string | Filter by exact email match |
| `created` | object | `{gt, gte, lt, lte}` Unix timestamp filters |
| `limit` | integer | 1–100, default 10 |
| `starting_after` | string | Cursor: objects after this ID |
| `ending_before` | string | Cursor: objects before this ID |
| `test_clock` | string | Filter by test clock ID |

```python
# List all customers with auto-pagination
for customer in stripe.Customer.auto_paging_iter():
    print(customer.id, customer.email)

# Filter by email
customers = stripe.Customer.list(email="jenny.rosen@example.com", limit=5)

# Filter by creation date range
import time
start = int(time.mktime((2026, 1, 1, 0, 0, 0, 0, 0, 0)))
end = int(time.mktime((2026, 1, 31, 23, 59, 59, 0, 0, 0)))
customers = stripe.Customer.list(created={"gte": start, "lte": end})
```

```javascript
// List with async iterator
for await (const customer of stripe.customers.list({ limit: 100 })) {
  console.log(customer.id);
}
```

---

### Search Customers

`GET /v1/customers/search`

| Parameter | Type | Description |
|-----------|------|-------------|
| `query` | string | Search expression |
| `limit` | integer | 1–100 |
| `page` | string | Pagination token |

Searchable fields: `email`, `name`, `phone`, `metadata[key]`.

```python
results = stripe.Customer.search(
    query="email:'jenny.rosen@example.com'"
)

results = stripe.Customer.search(
    query="name:'Jenny Rosen' AND metadata['plan']:'premium'"
)
```

```javascript
const results = await stripe.customers.search({
  query: "email:'jenny.rosen@example.com'",
});
```

---

## Products

Products define what you sell — goods or services. Each product can have multiple prices.

**Base endpoint:** `https://api.stripe.com/v1/products`

### Create a Product

`POST /v1/products`

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Product name (shown in checkout and invoices) |
| `description` | string | No | Shown on invoices, receipts, checkout |
| `active` | boolean | No | Default `true`; inactive products can't be purchased |
| `images` | array | No | Up to 8 public image URLs |
| `metadata` | object | No | Key-value pairs |
| `url` | string | No | URL for product marketing page |
| `tax_code` | string | No | Stripe Tax product code |
| `unit_label` | string | No | Unit label for metered billing (e.g. `"seat"`, `"GB"`) |
| `statement_descriptor` | string | No | Max 22 chars on card statement |
| `shippable` | boolean | No | Whether product requires shipping |
| `package_dimensions` | object | No | Height, length, weight, width for shipping |

```python
product = stripe.Product.create(
    name="Premium Plan",
    description="Unlimited access to all features with priority support",
    active=True,
    images=["https://yourapp.com/images/premium.png"],
    metadata={"tier": "premium", "internal_id": "plan_premium_v2"},
    unit_label="seat",
    tax_code="txcd_10000000"
)
print(product.id)  # prod_Nxxxxxxxxxxxxxx
```

```javascript
const product = await stripe.products.create({
  name: 'Premium Plan',
  description: 'Unlimited access with priority support',
  active: true,
  metadata: { tier: 'premium' },
  unit_label: 'seat',
});
```

### Retrieve / Update / Delete / List Products

```python
# Retrieve
product = stripe.Product.retrieve("prod_Nxxxxxxxxxxxxxx")

# Update
product = stripe.Product.modify(
    "prod_Nxxxxxxxxxxxxxx",
    name="Premium Plan v2",
    description="Updated description",
    metadata={"version": "2"}
)

# Delete (only possible if no active prices)
deleted = stripe.Product.delete("prod_Nxxxxxxxxxxxxxx")

# List active products
products = stripe.Product.list(active=True, limit=20)

# Search
results = stripe.Product.search(query="name:'Premium Plan'")
```

---

## Prices

Prices define the unit cost, currency, and billing interval for a product.

**Base endpoint:** `https://api.stripe.com/v1/prices`

### Create a Price

`POST /v1/prices`

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `currency` | string | Yes | ISO 4217 code (`usd`, `eur`, `gbp`, etc.) |
| `product` | string | Yes* | Existing Product ID |
| `product_data` | object | Yes* | Create a new product inline (alternative to `product`) |
| `unit_amount` | integer | Yes* | Amount in smallest currency unit (cents for USD) |
| `unit_amount_decimal` | string | No | Precise amount with decimals |
| `recurring` | object | No | Makes this a recurring price: `interval`, `interval_count`, `usage_type` |
| `recurring.interval` | string | No | `day`, `week`, `month`, `year` |
| `recurring.interval_count` | integer | No | Number of intervals (e.g. 3 = every 3 months) |
| `recurring.usage_type` | string | No | `licensed` (default) or `metered` |
| `billing_scheme` | string | No | `per_unit` (default) or `tiered` |
| `tiers` | array | No | Tiered pricing tiers |
| `tiers_mode` | string | No | `graduated` or `volume` |
| `nickname` | string | No | Internal label (not shown to customers) |
| `active` | boolean | No | Default `true` |
| `metadata` | object | No | Key-value pairs |
| `lookup_key` | string | No | Unique key for retrieval without knowing the ID |
| `transfer_lookup_key` | boolean | No | Migrate lookup_key from existing price |
| `tax_behavior` | string | No | `exclusive`, `inclusive`, or `unspecified` |
| `currency_options` | object | No | Multi-currency pricing |
| `custom_unit_amount` | object | No | Customer-set amount (pay-what-you-want) |

**Python — One-Time Price:**

```python
price = stripe.Price.create(
    product="prod_Nxxxxxxxxxxxxxx",
    unit_amount=999,    # $9.99
    currency="usd",
    nickname="One-time purchase"
)
```

**Python — Monthly Recurring Price:**

```python
price_monthly = stripe.Price.create(
    product="prod_Nxxxxxxxxxxxxxx",
    unit_amount=2999,   # $29.99/month
    currency="usd",
    recurring={
        "interval": "month",
        "interval_count": 1
    },
    nickname="Monthly Premium",
    lookup_key="premium_monthly"
)
print(price_monthly.id)  # price_1Mxxxxxxxxxxxxxx
```

**Python — Annual Price:**

```python
price_annual = stripe.Price.create(
    product="prod_Nxxxxxxxxxxxxxx",
    unit_amount=29900,  # $299/year
    currency="usd",
    recurring={"interval": "year"},
    nickname="Annual Premium",
    lookup_key="premium_annual"
)
```

**Node.js — Per-Seat Monthly:**

```javascript
const price = await stripe.prices.create({
  product: 'prod_Nxxxxxxxxxxxxxx',
  unit_amount: 1500,   // $15/seat/month
  currency: 'usd',
  recurring: { interval: 'month', usage_type: 'licensed' },
  nickname: 'Per-seat monthly',
});
```

**Python — Tiered Pricing (graduated):**

```python
price = stripe.Price.create(
    product="prod_Nxxxxxxxxxxxxxx",
    currency="usd",
    billing_scheme="tiered",
    tiers_mode="graduated",
    recurring={"interval": "month", "usage_type": "metered"},
    tiers=[
        {"up_to": 10, "unit_amount": 500},       # $5 each for first 10
        {"up_to": 100, "unit_amount": 300},       # $3 each for 11–100
        {"up_to": "inf", "unit_amount": 100},     # $1 each beyond 100
    ]
)
```

### Update / List / Retrieve Prices

```python
# Retrieve
price = stripe.Price.retrieve("price_1Mxxxxxxxxxxxxxx")

# Retrieve by lookup key
prices = stripe.Price.list(lookup_keys=["premium_monthly"])

# Update (only active, metadata, nickname, lookup_key are mutable)
price = stripe.Price.modify(
    "price_1Mxxxxxxxxxxxxxx",
    active=False,
    nickname="Deprecated monthly plan"
)

# List prices for a product
prices = stripe.Price.list(product="prod_Nxxxxxxxxxxxxxx", active=True)
```

---

## Payment Intents

A PaymentIntent tracks the complete lifecycle of a payment. Create one per order and confirm it with a payment method.

**Base endpoint:** `https://api.stripe.com/v1/payment_intents`

### PaymentIntent Status Lifecycle

```
requires_payment_method  →  requires_confirmation  →  requires_action
                                     ↓                        ↓
                                processing  ←────────────────┘
                                     ↓
                              succeeded  /  requires_payment_method (retry)
                              canceled
```

| Status | Description |
|--------|-------------|
| `requires_payment_method` | Awaiting a payment method |
| `requires_confirmation` | Ready to confirm |
| `requires_action` | Awaiting customer action (3DS, redirect) |
| `processing` | Payment is processing |
| `requires_capture` | Authorized; awaiting manual capture |
| `succeeded` | Payment complete |
| `canceled` | PaymentIntent was canceled |

### Create a PaymentIntent

`POST /v1/payment_intents`

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `amount` | integer | Yes | Amount in smallest currency unit |
| `currency` | string | Yes | Three-letter ISO currency code |
| `customer` | string | No | Customer ID |
| `description` | string | No | Internal description |
| `payment_method_types` | array | No | Default `["card"]` |
| `automatic_payment_methods` | object | No | `{"enabled": true}` uses Dashboard config |
| `payment_method` | string | No | PaymentMethod ID to use immediately |
| `confirm` | boolean | No | Confirm immediately on create |
| `capture_method` | string | No | `automatic` (default) or `manual` |
| `setup_future_usage` | string | No | `on_session` or `off_session` to save method |
| `metadata` | object | No | Key-value pairs |
| `receipt_email` | string | No | Email address for payment receipt |
| `return_url` | string | No | Redirect URL after 3DS authentication |
| `statement_descriptor` | string | No | Max 22 chars on card statement |
| `statement_descriptor_suffix` | string | No | Appended to account statement descriptor |
| `application_fee_amount` | integer | No | Connect: platform fee amount |
| `transfer_data` | object | No | Connect: `{destination: "acct_xxx"}` |
| `on_behalf_of` | string | No | Connect: connected account for settlement |
| `shipping` | object | No | Shipping info for fraud protection |
| `mandate_data` | object | No | For Indian payments |
| `payment_method_options` | object | No | Per-method-type options |

**Python — Standard Payment:**

```python
payment_intent = stripe.PaymentIntent.create(
    amount=2000,        # $20.00
    currency="usd",
    customer="cus_NffrFeUfNV2Hib",
    description="Order #1234 — 2x Widget",
    payment_method_types=["card"],
    metadata={"order_id": "1234", "product_ids": "sku_a,sku_b"},
    receipt_email="jenny.rosen@example.com",
    setup_future_usage="off_session",   # Save card for future charges
    statement_descriptor_suffix="ORDER1234"
)
# Send client_secret to your frontend
print(payment_intent.client_secret)
# "pi_3Mxxx_secret_xxx"
```

**Python — Auto Payment Methods (recommended):**

```python
payment_intent = stripe.PaymentIntent.create(
    amount=2000,
    currency="usd",
    customer="cus_NffrFeUfNV2Hib",
    automatic_payment_methods={"enabled": True},
    metadata={"order_id": "1234"}
)
```

**Node.js:**

```javascript
const paymentIntent = await stripe.paymentIntents.create({
  amount: 2000,
  currency: 'usd',
  customer: 'cus_NffrFeUfNV2Hib',
  description: 'Order #1234',
  automatic_payment_methods: { enabled: true },
  metadata: { order_id: '1234' },
});

// Send to frontend
res.json({ clientSecret: paymentIntent.client_secret });
```

**Frontend (Stripe.js) — Confirm Payment:**

```javascript
const stripe = Stripe('pk_test_...');
const elements = stripe.elements({ clientSecret });

const result = await stripe.confirmPayment({
  elements,
  confirmParams: {
    return_url: 'https://yourapp.com/payment/complete',
  },
});

if (result.error) {
  console.log(result.error.message);
}
```

### Retrieve a PaymentIntent

`GET /v1/payment_intents/{id}`

```python
pi = stripe.PaymentIntent.retrieve("pi_3Mxxxxxxxxxxxxxxx")
print(pi.status)
print(pi.amount_received)
```

### Confirm a PaymentIntent (server-side)

`POST /v1/payment_intents/{id}/confirm`

```python
pi = stripe.PaymentIntent.confirm(
    "pi_3Mxxxxxxxxxxxxxxx",
    payment_method="pm_card_visa",
    return_url="https://yourapp.com/complete"
)
```

### Capture a PaymentIntent (Manual Capture)

`POST /v1/payment_intents/{id}/capture`

Only valid when status is `requires_capture` (used with `capture_method=manual`).

```python
pi = stripe.PaymentIntent.capture(
    "pi_3Mxxxxxxxxxxxxxxx",
    amount_to_capture=1500   # Capture less than authorized (partial capture)
)
```

### Cancel a PaymentIntent

`POST /v1/payment_intents/{id}/cancel`

```python
pi = stripe.PaymentIntent.cancel(
    "pi_3Mxxxxxxxxxxxxxxx",
    cancellation_reason="requested_by_customer"
    # cancellation_reason: duplicate, fraudulent, requested_by_customer, abandoned
)
```

### Update a PaymentIntent

`POST /v1/payment_intents/{id}`

Updatable before confirmation: `amount`, `currency`, `customer`, `description`, `metadata`, `payment_method_types`, `receipt_email`, `setup_future_usage`, `shipping`.

```python
pi = stripe.PaymentIntent.modify(
    "pi_3Mxxxxxxxxxxxxxxx",
    amount=2500,    # Increase amount before confirming
    description="Updated order description"
)
```

---

## Payment Methods

PaymentMethod objects represent a customer's payment instrument.

**Base endpoint:** `https://api.stripe.com/v1/payment_methods`

### Supported Payment Method Types

| Type | Description | Countries |
|------|-------------|-----------|
| `card` | Credit/debit card (Visa, MC, Amex, etc.) | Global |
| `sepa_debit` | EU bank debit | EU |
| `us_bank_account` | US ACH bank debit | US |
| `ideal` | Bank transfer | Netherlands |
| `bancontact` | Bank transfer | Belgium |
| `giropay` | Bank transfer | Germany |
| `sofort` | Bank transfer | EU |
| `p24` | Bank transfer | Poland |
| `eps` | Bank transfer | Austria |
| `bacs_debit` | Bank debit | UK |
| `au_becs_debit` | Bank debit | Australia |
| `link` | Stripe Link one-click | US |
| `paypal` | PayPal | Many countries |
| `klarna` | Buy now, pay later | Many countries |
| `afterpay_clearpay` | Buy now, pay later | US/UK/AU/CA |
| `affirm` | Buy now, pay later | US |
| `amazon_pay` | Amazon Pay | US |
| `revolut_pay` | Revolut Pay | EU/UK |
| `wechat_pay` | WeChat | China |
| `alipay` | Alipay | China |

### Create a PaymentMethod

`POST /v1/payment_methods`

```python
pm = stripe.PaymentMethod.create(
    type="card",
    card={
        "number": "4242424242424242",
        "exp_month": 8,
        "exp_year": 2026,
        "cvc": "314"
    },
    billing_details={
        "name": "Jenny Rosen",
        "email": "jenny.rosen@example.com"
    }
)
```

In production, create PaymentMethods client-side using Stripe.js Elements (never pass raw card numbers to your server).

### Attach a PaymentMethod to a Customer

`POST /v1/payment_methods/{id}/attach`

```python
pm = stripe.PaymentMethod.attach(
    "pm_xxxxxxxxxxxxxx",
    customer="cus_NffrFeUfNV2Hib"
)
```

```javascript
const pm = await stripe.paymentMethods.attach('pm_xxxxxxxxxxxxxx', {
  customer: 'cus_NffrFeUfNV2Hib',
});
```

### Detach a PaymentMethod

`POST /v1/payment_methods/{id}/detach`

```python
pm = stripe.PaymentMethod.detach("pm_xxxxxxxxxxxxxx")
```

### List PaymentMethods for a Customer

`GET /v1/customers/{CUSTOMER_ID}/payment_methods`

```python
pms = stripe.Customer.list_payment_methods(
    "cus_NffrFeUfNV2Hib",
    type="card"
)
for pm in pms.data:
    print(pm.id, pm.card.brand, pm.card.last4)
```

```javascript
const paymentMethods = await stripe.customers.listPaymentMethods(
  'cus_NffrFeUfNV2Hib',
  { type: 'card' }
);
```

### Set Default Payment Method on Customer

```python
stripe.Customer.modify(
    "cus_NffrFeUfNV2Hib",
    invoice_settings={"default_payment_method": "pm_xxxxxxxxxxxxxx"}
)
```

---

## Subscriptions

Subscriptions automatically charge customers on a recurring schedule using Products and Prices.

**Base endpoint:** `https://api.stripe.com/v1/subscriptions`

### Subscription Statuses

| Status | Description |
|--------|-------------|
| `active` | Healthy; being billed normally |
| `past_due` | Payment failed; in retry window |
| `canceled` | Subscription ended |
| `unpaid` | All retries exhausted; invoice still open |
| `trialing` | In free trial period |
| `incomplete` | Initial payment failed or requires action |
| `incomplete_expired` | Incomplete subscription expired after 23 hours |
| `paused` | Paused via pause_collection |

### Create a Subscription

`POST /v1/subscriptions`

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `customer` | string | Yes | Customer ID |
| `items` | array | Yes | `[{price, quantity}]` array |
| `default_payment_method` | string | No | PaymentMethod ID |
| `default_source` | string | No | Legacy payment source |
| `trial_end` | integer/string | No | Unix timestamp or `"now"` |
| `trial_period_days` | integer | No | Number of free trial days |
| `cancel_at_period_end` | boolean | No | Cancel at end of current period |
| `cancel_at` | integer | No | Unix timestamp for scheduled cancellation |
| `proration_behavior` | string | No | `create_prorations`, `none`, `always_invoice` |
| `collection_method` | string | No | `charge_automatically` or `send_invoice` |
| `days_until_due` | integer | No | Days for `send_invoice` collection method |
| `metadata` | object | No | Key-value pairs |
| `billing_cycle_anchor` | integer | No | Unix timestamp for first billing date |
| `billing_cycle_anchor_config` | object | No | Day-of-month/year anchor config |
| `payment_behavior` | string | No | `default_incomplete` (recommended), `allow_incomplete`, `error_if_incomplete` |
| `coupon` | string | No | Discount coupon ID |
| `promotion_code` | string | No | Promotion code |
| `add_invoice_items` | array | No | One-time items on first invoice |
| `application_fee_percent` | decimal | No | Connect: platform fee percentage |
| `transfer_data` | object | No | Connect: destination account |
| `off_session` | boolean | No | Charge off-session (no customer present) |
| `expand` | array | No | Expand related objects |

**Python — Basic Subscription:**

```python
subscription = stripe.Subscription.create(
    customer="cus_NffrFeUfNV2Hib",
    items=[{"price": "price_1Mxxxxxxxxxxxxxx", "quantity": 1}],
    default_payment_method="pm_xxxxxxxxxxxxxx",
    metadata={"app_user_id": "usr_12345"}
)
print(subscription.id)    # sub_1Mxxxxxxxxxxxxxx
print(subscription.status) # active
```

**Python — With Trial (Payment Method Required Upfront):**

```python
subscription = stripe.Subscription.create(
    customer="cus_NffrFeUfNV2Hib",
    items=[{"price": "price_monthly_premium", "quantity": 1}],
    default_payment_method="pm_xxxxxxxxxxxxxx",
    trial_period_days=14,
    payment_behavior="default_incomplete",
    expand=["latest_invoice.payment_intent"],
    metadata={"trial_source": "signup_flow"}
)

# Handle incomplete payment if trial requires setup
if subscription.latest_invoice.payment_intent.status == "requires_action":
    client_secret = subscription.latest_invoice.payment_intent.client_secret
    # Send to frontend for 3DS confirmation
```

**Node.js — Multi-Seat Subscription:**

```javascript
const subscription = await stripe.subscriptions.create({
  customer: 'cus_NffrFeUfNV2Hib',
  items: [{ price: 'price_per_seat_monthly', quantity: 5 }],
  default_payment_method: 'pm_xxxxxxxxxxxxxx',
  payment_behavior: 'default_incomplete',
  expand: ['latest_invoice.payment_intent'],
  metadata: { team_id: 'team_abc', seats: '5' },
});
```

### Update a Subscription

`POST /v1/subscriptions/{id}`

**Python — Upgrade/Downgrade Plan:**

```python
# Get current subscription item ID
sub = stripe.Subscription.retrieve("sub_1Mxxxxxxxxxxxxxx")
item_id = sub.items.data[0].id

updated = stripe.Subscription.modify(
    "sub_1Mxxxxxxxxxxxxxx",
    items=[{
        "id": item_id,
        "price": "price_new_higher_plan",
        "quantity": 1
    }],
    proration_behavior="create_prorations"  # Charge/credit difference immediately
)
```

**Python — Add Seats:**

```python
sub = stripe.Subscription.retrieve("sub_1Mxxxxxxxxxxxxxx")
item_id = sub.items.data[0].id
current_qty = sub.items.data[0].quantity

stripe.Subscription.modify(
    "sub_1Mxxxxxxxxxxxxxx",
    items=[{"id": item_id, "quantity": current_qty + 3}],
    proration_behavior="create_prorations"
)
```

**Node.js — Apply Coupon:**

```javascript
await stripe.subscriptions.update('sub_1Mxxxxxxxxxxxxxx', {
  coupon: 'SAVE20',
});
```

### Cancel a Subscription

**Cancel Immediately:**

```python
canceled = stripe.Subscription.cancel("sub_1Mxxxxxxxxxxxxxx")
print(canceled.status)  # canceled
```

```javascript
const canceled = await stripe.subscriptions.cancel('sub_1Mxxxxxxxxxxxxxx');
```

**Cancel at Period End (recommended — lets customer use remaining paid time):**

```python
stripe.Subscription.modify(
    "sub_1Mxxxxxxxxxxxxxx",
    cancel_at_period_end=True
)
```

```javascript
await stripe.subscriptions.update('sub_1Mxxxxxxxxxxxxxx', {
  cancel_at_period_end: true,
});
```

**Cancel at Specific Future Date:**

```python
import time
cancel_date = int(time.mktime((2026, 12, 31, 23, 59, 59, 0, 0, 0)))
stripe.Subscription.modify("sub_1Mxxxxxxxxxxxxxx", cancel_at=cancel_date)
```

**Reactivate (undo cancel_at_period_end before it fires):**

```python
stripe.Subscription.modify(
    "sub_1Mxxxxxxxxxxxxxx",
    cancel_at_period_end=False
)
```

### Pause a Subscription

```python
stripe.Subscription.modify(
    "sub_1Mxxxxxxxxxxxxxx",
    pause_collection={"behavior": "mark_uncollectible"}
    # behavior: keep_as_draft | mark_uncollectible | void
)
```

### Resume a Subscription

```python
stripe.Subscription.modify(
    "sub_1Mxxxxxxxxxxxxxx",
    pause_collection=""  # Empty string removes pause
)
```

### Retrieve & List Subscriptions

```python
# Retrieve single
sub = stripe.Subscription.retrieve("sub_1Mxxxxxxxxxxxxxx")

# List for a customer
subs = stripe.Subscription.list(
    customer="cus_NffrFeUfNV2Hib",
    status="active",
    limit=10
)

# List all active subscriptions
for sub in stripe.Subscription.auto_paging_iter(status="active"):
    print(sub.id, sub.customer)
```

---

## Invoices

Invoices are statements of amounts owed. Subscriptions auto-generate them; you can also create them manually.

**Base endpoint:** `https://api.stripe.com/v1/invoices`

### Invoice Statuses

| Status | Description |
|--------|-------------|
| `draft` | Not yet finalized; editable |
| `open` | Finalized; awaiting payment |
| `paid` | Payment collected |
| `void` | Voided; cannot be paid |
| `uncollectible` | Marked as bad debt |

### Create a Manual Invoice

`POST /v1/invoices`

```python
invoice = stripe.Invoice.create(
    customer="cus_NffrFeUfNV2Hib",
    collection_method="charge_automatically",
    auto_advance=True,        # Auto-finalize after an hour
    description="Consulting services — January 2026",
    footer="Thank you for your business.",
    metadata={"project": "website_redesign", "hours": "10"}
)
```

```javascript
const invoice = await stripe.invoices.create({
  customer: 'cus_NffrFeUfNV2Hib',
  collection_method: 'charge_automatically',
  auto_advance: true,
  description: 'Consulting services — January 2026',
});
```

### Add Invoice Items

`POST /v1/invoiceitems`

Add line items to an invoice before finalizing:

```python
stripe.InvoiceItem.create(
    customer="cus_NffrFeUfNV2Hib",
    amount=10000,     # $100.00
    currency="usd",
    description="Strategic consulting — 5 hours @ $20/hr",
    invoice="in_xxxxxxxxxxxxxx"
)

# Or attach to next upcoming invoice (no invoice param)
stripe.InvoiceItem.create(
    customer="cus_NffrFeUfNV2Hib",
    amount=5000,
    currency="usd",
    description="One-time setup fee"
)
```

### Finalize an Invoice

`POST /v1/invoices/{id}/finalize`

Moves invoice from `draft` to `open`. Irreversible.

```python
invoice = stripe.Invoice.finalize_invoice("in_xxxxxxxxxxxxxx")
print(invoice.status)  # open
print(invoice.hosted_invoice_url)  # Shareable link
```

### Pay an Invoice

`POST /v1/invoices/{id}/pay`

```python
invoice = stripe.Invoice.pay(
    "in_xxxxxxxxxxxxxx",
    payment_method="pm_xxxxxxxxxxxxxx"
    # or leave empty to use customer's default method
)
print(invoice.status)  # paid
```

### Send an Invoice by Email

`POST /v1/invoices/{id}/send`

```python
invoice = stripe.Invoice.send_invoice("in_xxxxxxxxxxxxxx")
```

### Void an Invoice

`POST /v1/invoices/{id}/void`

```python
invoice = stripe.Invoice.void_invoice("in_xxxxxxxxxxxxxx")
```

### Mark Invoice as Uncollectible

`POST /v1/invoices/{id}/mark_uncollectible`

```python
invoice = stripe.Invoice.mark_uncollectible("in_xxxxxxxxxxxxxx")
```

### Retrieve & List Invoices

```python
# Retrieve
invoice = stripe.Invoice.retrieve("in_xxxxxxxxxxxxxx")

# List for customer
invoices = stripe.Invoice.list(
    customer="cus_NffrFeUfNV2Hib",
    status="open",
    limit=20
)

# All invoices for a subscription
invoices = stripe.Invoice.list(subscription="sub_1Mxxxxxxxxxxxxxx")
```

### Preview Upcoming Invoice

`GET /v1/invoices/upcoming`

```python
upcoming = stripe.Invoice.upcoming(
    customer="cus_NffrFeUfNV2Hib",
    subscription="sub_1Mxxxxxxxxxxxxxx"
)
print(f"Next charge: ${upcoming.amount_due / 100:.2f} on {upcoming.next_payment_attempt}")
print(f"Period: {upcoming.period_start} to {upcoming.period_end}")
```

---

## Checkout Sessions

Stripe's hosted payment page. Redirect customers to a Stripe-managed UI instead of building custom payment forms.

**Base endpoint:** `https://api.stripe.com/v1/checkout/sessions`

### Checkout Session Modes

| Mode | Use Case |
|------|----------|
| `payment` | One-time purchase |
| `subscription` | Recurring subscription |
| `setup` | Save payment method without charging |

### Create a Checkout Session

`POST /v1/checkout/sessions`

**Key Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `mode` | string | Yes | `payment`, `subscription`, or `setup` |
| `success_url` | string | Yes | Redirect on success; `{CHECKOUT_SESSION_ID}` is substituted |
| `cancel_url` | string | Yes | Redirect when customer clicks Back |
| `line_items` | array | Yes* | `[{price, quantity}]`; required for payment/subscription |
| `customer` | string | No | Existing Stripe customer ID |
| `customer_email` | string | No | Pre-fill customer email |
| `customer_creation` | string | No | `always` or `if_required` |
| `payment_method_types` | array | No | Defaults to Dashboard configuration |
| `allow_promotion_codes` | boolean | No | Show promo code input |
| `billing_address_collection` | string | No | `auto` or `required` |
| `shipping_address_collection` | object | No | `{allowed_countries: ["US", "CA"]}` |
| `shipping_options` | array | No | Shipping rates to offer |
| `subscription_data` | object | No | `trial_period_days`, `metadata`, `description` |
| `payment_intent_data` | object | No | `metadata`, `description`, `capture_method` |
| `metadata` | object | No | Key-value pairs |
| `expires_at` | integer | No | Expiry timestamp (30 min – 24 hours from now) |
| `automatic_tax` | object | No | `{enabled: true}` for Stripe Tax |
| `tax_id_collection` | object | No | `{enabled: true}` |
| `phone_number_collection` | object | No | `{enabled: true}` |
| `invoice_creation` | object | No | `{enabled: true}` for payment mode |
| `consent_collection` | object | No | Terms of service / promotions consent |
| `locale` | string | No | `auto` or BCP-47 locale |
| `ui_mode` | string | No | `hosted` (default) or `embedded` |
| `custom_text` | object | No | Custom text for checkout page |
| `custom_fields` | array | No | Collect additional info from customer |
| `after_expiration` | object | No | `{recovery: {enabled: true}}` for abandoned cart emails |
| `discounts` | array | No | `[{coupon: "SAVE10"}]` to pre-apply |

**Python — One-Time Payment:**

```python
session = stripe.checkout.Session.create(
    mode="payment",
    line_items=[
        {"price": "price_one_time_widget", "quantity": 2}
    ],
    success_url="https://yourapp.com/success?session_id={CHECKOUT_SESSION_ID}",
    cancel_url="https://yourapp.com/cancel",
    customer="cus_NffrFeUfNV2Hib",
    allow_promotion_codes=True,
    billing_address_collection="required",
    shipping_address_collection={"allowed_countries": ["US", "CA", "GB"]},
    metadata={"order_source": "homepage_cta"},
    automatic_tax={"enabled": True}
)
# Redirect customer to Stripe
print(session.url)
```

**Python — Subscription Checkout with Trial:**

```python
session = stripe.checkout.Session.create(
    mode="subscription",
    line_items=[{"price": "price_monthly_premium", "quantity": 1}],
    success_url="https://yourapp.com/welcome?session_id={CHECKOUT_SESSION_ID}",
    cancel_url="https://yourapp.com/pricing",
    customer="cus_NffrFeUfNV2Hib",
    subscription_data={
        "trial_period_days": 14,
        "metadata": {"user_id": "usr_12345", "source": "trial_signup"}
    },
    allow_promotion_codes=True,
    billing_address_collection="auto"
)
```

**Node.js — Subscription Checkout:**

```javascript
const session = await stripe.checkout.sessions.create({
  mode: 'subscription',
  line_items: [{ price: 'price_monthly_premium', quantity: 1 }],
  success_url: 'https://yourapp.com/success?session_id={CHECKOUT_SESSION_ID}',
  cancel_url: 'https://yourapp.com/pricing',
  customer: 'cus_NffrFeUfNV2Hib',
  subscription_data: {
    trial_period_days: 14,
    metadata: { user_id: 'usr_12345' },
  },
  allow_promotion_codes: true,
});

res.redirect(303, session.url);
```

**Node.js — Setup Mode (save card without charging):**

```javascript
const session = await stripe.checkout.sessions.create({
  mode: 'setup',
  customer: 'cus_NffrFeUfNV2Hib',
  success_url: 'https://yourapp.com/settings/payment?session_id={CHECKOUT_SESSION_ID}',
  cancel_url: 'https://yourapp.com/settings',
});
```

### Retrieve a Checkout Session

`GET /v1/checkout/sessions/{id}`

```python
session = stripe.checkout.Session.retrieve("cs_test_xxxxxxxxxxxxxx")
print(session.payment_status)   # "paid", "unpaid", "no_payment_required"
print(session.customer)          # cus_xxx
print(session.subscription)      # sub_xxx (for subscription mode)
print(session.payment_intent)    # pi_xxx (for payment mode)
print(session.amount_total)      # Total charged in smallest unit
```

### List Line Items for a Session

`GET /v1/checkout/sessions/{id}/line_items`

```python
line_items = stripe.checkout.Session.list_line_items(
    "cs_test_xxxxxxxxxxxxxx",
    limit=10
)
for item in line_items.data:
    print(item.description, item.quantity, item.amount_total)
```

### List Checkout Sessions

`GET /v1/checkout/sessions`

```python
sessions = stripe.checkout.Session.list(
    customer="cus_NffrFeUfNV2Hib",
    limit=10
)
```

---

## Billing Portal

A Stripe-hosted UI for customers to manage subscriptions, update payment methods, view invoice history, and cancel plans.

**Base endpoint:** `https://api.stripe.com/v1/billing_portal/sessions`

### Prerequisites

1. Configure the portal in the Stripe Dashboard (Billing > Customer Portal) or via the API.
2. Enable the features you want to offer.

### Create a Portal Session

`POST /v1/billing_portal/sessions`

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `customer` | string | Yes | Customer ID |
| `return_url` | string | Yes | URL to redirect after portal exit |
| `configuration` | string | No | Portal configuration ID (if multiple configs) |
| `flow_data` | object | No | Deep-link to specific portal section |
| `locale` | string | No | BCP-47 locale override |
| `on_behalf_of` | string | No | Connect: connected account |

**Python:**

```python
portal_session = stripe.billing_portal.Session.create(
    customer="cus_NffrFeUfNV2Hib",
    return_url="https://yourapp.com/account/billing"
)
# Redirect customer to the Stripe-hosted portal
print(portal_session.url)
```

```javascript
const portalSession = await stripe.billingPortal.sessions.create({
  customer: 'cus_NffrFeUfNV2Hib',
  return_url: 'https://yourapp.com/account/billing',
});

res.redirect(303, portalSession.url);
```

**Deep-Link to Subscription Update Flow:**

```python
portal_session = stripe.billing_portal.Session.create(
    customer="cus_NffrFeUfNV2Hib",
    return_url="https://yourapp.com/account",
    flow_data={
        "type": "subscription_update",
        "subscription_update": {
            "subscription": "sub_1Mxxxxxxxxxxxxxx"
        }
    }
)
```

### Configure the Billing Portal

`POST /v1/billing_portal/configurations`

```python
config = stripe.billing_portal.Configuration.create(
    business_profile={
        "headline": "Manage your Acme subscription",
        "privacy_policy_url": "https://yourapp.com/privacy",
        "terms_of_service_url": "https://yourapp.com/terms"
    },
    features={
        "invoice_history": {"enabled": True},
        "payment_method_update": {"enabled": True},
        "customer_update": {
            "enabled": True,
            "allowed_updates": ["email", "address", "shipping", "phone", "tax_id"]
        },
        "subscription_cancel": {
            "enabled": True,
            "mode": "at_period_end",       # "immediately" or "at_period_end"
            "proration_behavior": "none",
            "cancellation_reason": {
                "enabled": True,
                "options": [
                    "too_expensive",
                    "missing_features",
                    "switched_service",
                    "unused",
                    "other"
                ]
            }
        },
        "subscription_update": {
            "enabled": True,
            "default_allowed_updates": ["price", "quantity", "promotion_code"],
            "proration_behavior": "create_prorations",
            "products": [
                {
                    "product": "prod_Nxxxxxxxxxxxxxx",
                    "prices": ["price_monthly", "price_annual"]
                }
            ]
        },
        "subscription_pause": {"enabled": False}
    }
)
print(config.id)  # bpc_xxxxxxxxxxxxxx
```

---

## Webhooks

Webhooks are HTTP callbacks that Stripe sends when events occur. Use them to handle asynchronous flows like subscription renewals, payment confirmations, and failed payments.

**Base endpoint:** `https://api.stripe.com/v1/webhook_endpoints`

### Register a Webhook Endpoint

`POST /v1/webhook_endpoints`

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `url` | string | Yes | Your HTTPS endpoint URL |
| `enabled_events` | array | Yes | Event types, or `["*"]` for all |
| `description` | string | No | Internal label |
| `api_version` | string | No | Pin to specific Stripe API version |
| `connect` | boolean | No | Receive events from connected accounts |

```python
webhook = stripe.WebhookEndpoint.create(
    url="https://yourapp.com/webhooks/stripe",
    enabled_events=[
        "payment_intent.succeeded",
        "payment_intent.payment_failed",
        "customer.created",
        "customer.updated",
        "customer.deleted",
        "customer.subscription.created",
        "customer.subscription.updated",
        "customer.subscription.deleted",
        "customer.subscription.trial_will_end",
        "invoice.created",
        "invoice.finalized",
        "invoice.payment_succeeded",
        "invoice.payment_failed",
        "invoice.payment_action_required",
        "checkout.session.completed",
        "checkout.session.expired",
        "billing_portal.session.created"
    ],
    description="Production webhook endpoint"
)
# IMPORTANT: Save this secret immediately — shown only once
print(webhook.secret)  # whsec_YOUR_SECRET_HERE
```

### Verify Webhook Signatures

Always verify the `Stripe-Signature` header. This confirms the event came from Stripe and the payload was not tampered with.

**Python (Flask):**

```python
import stripe
from flask import Flask, request, jsonify

app = Flask(__name__)
WEBHOOK_SECRET = "whsec_YOUR_SECRET_HERE"

@app.route("/webhooks/stripe", methods=["POST"])
def stripe_webhook():
    payload = request.get_data()  # Raw bytes — do NOT decode
    sig_header = request.headers.get("Stripe-Signature")

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, WEBHOOK_SECRET
        )
    except ValueError as e:
        # Invalid payload
        return jsonify(error=str(e)), 400
    except stripe.error.SignatureVerificationError as e:
        # Invalid signature
        return jsonify(error=str(e)), 400

    event_type = event["type"]
    data_object = event["data"]["object"]

    if event_type == "payment_intent.succeeded":
        handle_payment_succeeded(data_object)
    elif event_type == "payment_intent.payment_failed":
        handle_payment_failed(data_object)
    elif event_type == "customer.subscription.created":
        provision_access(data_object)
    elif event_type == "customer.subscription.deleted":
        revoke_access(data_object)
    elif event_type == "customer.subscription.trial_will_end":
        send_trial_ending_email(data_object)
    elif event_type == "invoice.payment_failed":
        handle_failed_invoice(data_object)
    elif event_type == "checkout.session.completed":
        fulfill_order(data_object)

    return jsonify(status="ok"), 200

def provision_access(subscription):
    customer_id = subscription["customer"]
    # Grant feature access in your database
    print(f"Granting access to customer {customer_id}")

def revoke_access(subscription):
    customer_id = subscription["customer"]
    print(f"Revoking access for customer {customer_id}")
```

**Node.js (Express):**

```javascript
const express = require('express');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

const app = express();
const WEBHOOK_SECRET = process.env.STRIPE_WEBHOOK_SECRET;

// CRITICAL: Use express.raw() BEFORE express.json() for webhook route
app.post(
  '/webhooks/stripe',
  express.raw({ type: 'application/json' }),
  async (req, res) => {
    const sig = req.headers['stripe-signature'];
    let event;

    try {
      event = stripe.webhooks.constructEvent(req.body, sig, WEBHOOK_SECRET);
    } catch (err) {
      console.error(`Webhook signature failed: ${err.message}`);
      return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    const dataObject = event.data.object;

    switch (event.type) {
      case 'payment_intent.succeeded':
        console.log(`Payment succeeded: ${dataObject.id}, amount: ${dataObject.amount}`);
        await fulfillOrder(dataObject);
        break;

      case 'payment_intent.payment_failed':
        console.log(`Payment failed: ${dataObject.id}`);
        await notifyPaymentFailed(dataObject);
        break;

      case 'customer.subscription.created':
        console.log(`Subscription created: ${dataObject.id}`);
        await provisionAccess(dataObject.customer, dataObject.id);
        break;

      case 'customer.subscription.updated':
        console.log(`Subscription updated: ${dataObject.id}, status: ${dataObject.status}`);
        await updateAccessLevel(dataObject);
        break;

      case 'customer.subscription.deleted':
        console.log(`Subscription canceled: ${dataObject.id}`);
        await revokeAccess(dataObject.customer);
        break;

      case 'customer.subscription.trial_will_end':
        // Fired 3 days before trial ends
        console.log(`Trial ending soon for: ${dataObject.customer}`);
        await sendTrialEndingReminder(dataObject);
        break;

      case 'invoice.payment_succeeded':
        console.log(`Invoice paid: ${dataObject.id}`);
        break;

      case 'invoice.payment_failed':
        console.log(`Invoice payment failed: ${dataObject.id}`);
        await sendPaymentFailedEmail(dataObject);
        break;

      case 'checkout.session.completed':
        console.log(`Checkout complete: ${dataObject.id}`);
        if (dataObject.mode === 'subscription') {
          await provisionAccess(dataObject.customer, dataObject.subscription);
        } else if (dataObject.mode === 'payment') {
          await fulfillPurchase(dataObject);
        }
        break;

      default:
        console.log(`Unhandled event: ${event.type}`);
    }

    res.json({ received: true });
  }
);
```

### Webhook Event Object Structure

```json
{
  "id": "evt_3Mxxxxxxxxxxxxxxx",
  "object": "event",
  "api_version": "2024-06-20",
  "created": 1680893993,
  "data": {
    "object": {
      "id": "pi_3Mxxxxxxxxxxxxxxx",
      "object": "payment_intent",
      "amount": 2000,
      "status": "succeeded"
    },
    "previous_attributes": {
      "status": "processing"
    }
  },
  "livemode": false,
  "pending_webhooks": 1,
  "request": {
    "id": "req_xxxxx",
    "idempotency_key": null
  },
  "type": "payment_intent.succeeded"
}
```

### Retry Behavior

Stripe retries failed webhook deliveries with exponential backoff for up to 3 days:

| Attempt | Wait |
|---------|------|
| 1 | Immediate |
| 2 | 5 minutes |
| 3 | 30 minutes |
| 4 | 2 hours |
| 5 | 5 hours |
| ... | Up to 3 days total |

Your endpoint must respond with a 2xx status within **30 seconds** or Stripe considers it failed.

### Test Webhooks Locally

```bash
# Install Stripe CLI (macOS)
brew install stripe/stripe-cli/stripe

# Authenticate
stripe login

# Forward all events to local server
stripe listen --forward-to localhost:3000/webhooks/stripe

# Forward specific events
stripe listen \
  --events payment_intent.succeeded,customer.subscription.deleted \
  --forward-to localhost:3000/webhooks/stripe

# Trigger a test event
stripe trigger payment_intent.succeeded
stripe trigger customer.subscription.created
stripe trigger invoice.payment_failed
```

### Manage Webhook Endpoints

```python
# List all webhook endpoints
endpoints = stripe.WebhookEndpoint.list()

# Retrieve a specific endpoint
endpoint = stripe.WebhookEndpoint.retrieve("we_xxxxxxxxxxxxxx")

# Update events
endpoint = stripe.WebhookEndpoint.modify(
    "we_xxxxxxxxxxxxxx",
    enabled_events=["payment_intent.succeeded", "invoice.payment_failed"]
)

# Disable (but keep registered)
endpoint = stripe.WebhookEndpoint.modify("we_xxxxxxxxxxxxxx", disabled=True)

# Delete
stripe.WebhookEndpoint.delete("we_xxxxxxxxxxxxxx")
```

---

## Webhook Event Types Reference

### Payment Intent Events

| Event | Trigger |
|-------|---------|
| `payment_intent.created` | PaymentIntent created |
| `payment_intent.succeeded` | Payment successfully captured |
| `payment_intent.payment_failed` | Payment attempt failed |
| `payment_intent.canceled` | PaymentIntent canceled |
| `payment_intent.requires_action` | 3DS or redirect required |
| `payment_intent.processing` | Payment processing |
| `payment_intent.partially_funded` | Partial funding received |
| `payment_intent.amount_capturable_updated` | Authorized amount changed |

### Charge Events

| Event | Trigger |
|-------|---------|
| `charge.succeeded` | Charge completed |
| `charge.failed` | Charge failed |
| `charge.refunded` | Charge partially or fully refunded |
| `charge.updated` | Charge object updated |
| `charge.captured` | Authorized charge captured |
| `charge.expired` | Uncaptured authorization expired |
| `charge.dispute.created` | Customer initiated chargeback |
| `charge.dispute.updated` | Dispute evidence updated |
| `charge.dispute.closed` | Dispute resolved (won/lost/withdrawn) |
| `charge.dispute.funds_reinstated` | Dispute won; funds returned |
| `charge.dispute.funds_withdrawn` | Dispute lost; funds withdrawn |

### Customer Events

| Event | Trigger |
|-------|---------|
| `customer.created` | New customer created |
| `customer.updated` | Customer record updated |
| `customer.deleted` | Customer deleted |
| `customer.source.created` | Legacy payment source added |
| `customer.source.deleted` | Legacy payment source removed |
| `customer.source.expiring` | Card expiring soon |
| `customer.source.updated` | Payment source updated |
| `customer.discount.created` | Discount applied to customer |
| `customer.discount.updated` | Discount updated |
| `customer.discount.deleted` | Discount removed |
| `customer.tax_id.created` | Tax ID added |
| `customer.tax_id.deleted` | Tax ID removed |
| `customer.tax_id.updated` | Tax ID verification status changed |

### Subscription Events

| Event | Trigger |
|-------|---------|
| `customer.subscription.created` | Subscription created |
| `customer.subscription.updated` | Plan/quantity/status changed |
| `customer.subscription.deleted` | Subscription canceled or expired |
| `customer.subscription.paused` | Subscription paused |
| `customer.subscription.resumed` | Subscription resumed |
| `customer.subscription.trial_will_end` | Trial ends in 3 days |
| `customer.subscription.pending_update_applied` | Queued update applied |
| `customer.subscription.pending_update_expired` | Queued update expired |

### Invoice Events

| Event | Trigger |
|-------|---------|
| `invoice.created` | Draft invoice created (subscription cycle) |
| `invoice.finalized` | Invoice finalized, ready to pay |
| `invoice.updated` | Invoice updated |
| `invoice.deleted` | Draft invoice deleted |
| `invoice.payment_succeeded` | Invoice fully paid |
| `invoice.payment_failed` | Payment attempt on invoice failed |
| `invoice.payment_action_required` | 3DS required to pay invoice |
| `invoice.upcoming` | Upcoming invoice ~1 hour before billing |
| `invoice.marked_uncollectible` | Marked as uncollectible |
| `invoice.voided` | Invoice voided |
| `invoice.sent` | Invoice emailed to customer |
| `invoice.overdue` | Invoice past due date |
| `invoiceitem.created` | Invoice line item added |
| `invoiceitem.updated` | Invoice line item updated |
| `invoiceitem.deleted` | Invoice line item deleted |

### Checkout Events

| Event | Trigger |
|-------|---------|
| `checkout.session.completed` | Customer completed checkout |
| `checkout.session.expired` | Session expired without payment |
| `checkout.session.async_payment_succeeded` | Async payment (SEPA, ACH) succeeded |
| `checkout.session.async_payment_failed` | Async payment failed |

### Billing Portal Events

| Event | Trigger |
|-------|---------|
| `billing_portal.session.created` | Portal session created |
| `billing_portal.configuration.created` | Portal configuration created |
| `billing_portal.configuration.updated` | Portal configuration updated |

### Payment Method Events

| Event | Trigger |
|-------|---------|
| `payment_method.attached` | Method attached to customer |
| `payment_method.detached` | Method detached from customer |
| `payment_method.updated` | Method updated (billing details, etc.) |
| `payment_method.automatically_updated` | Card auto-updated by network |
| `payment_method.card_automatically_updated` | Replacement card number issued |

### Product & Price Events

| Event | Trigger |
|-------|---------|
| `product.created` | Product created |
| `product.updated` | Product updated |
| `product.deleted` | Product deleted |
| `price.created` | Price created |
| `price.updated` | Price updated |
| `price.deleted` | Price deleted (deactivated) |

### Payout Events

| Event | Trigger |
|-------|---------|
| `payout.created` | Payout created (pending) |
| `payout.updated` | Payout updated |
| `payout.paid` | Payout sent to bank account |
| `payout.failed` | Payout failed |
| `payout.canceled` | Payout canceled |
| `payout.reconciliation_completed` | Reconciliation complete |

### Refund Events

| Event | Trigger |
|-------|---------|
| `refund.created` | Refund initiated |
| `refund.updated` | Refund status changed |
| `refund.failed` | Refund failed |

### Radar & Fraud Events

| Event | Trigger |
|-------|---------|
| `radar.early_fraud_warning.created` | Card network flagged transaction |
| `radar.early_fraud_warning.updated` | Fraud warning status changed |
| `review.opened` | Stripe opened a payment review |
| `review.closed` | Review closed (approved/refunded/disputed) |

### Account & Balance Events

| Event | Trigger |
|-------|---------|
| `balance.available` | Balance is available for payouts |
| `account.updated` | Account details changed |
| `account.application.authorized` | App authorized by account (Connect) |
| `account.application.deauthorized` | App removed by account (Connect) |
| `account.external_account.created` | Bank account added (Connect) |
| `account.external_account.deleted` | Bank account removed (Connect) |
| `account.external_account.updated` | Bank account updated (Connect) |

---

## Sources

- [Stripe API Reference](https://docs.stripe.com/api)
- [Stripe API Authentication](https://docs.stripe.com/api/authentication)
- [Stripe API Keys](https://docs.stripe.com/keys)
- [Customers API](https://docs.stripe.com/api/customers)
- [Products API](https://docs.stripe.com/api/products)
- [Prices API](https://docs.stripe.com/api/prices)
- [Payment Intents API](https://docs.stripe.com/api/payment_intents)
- [Payment Methods API](https://docs.stripe.com/api/payment_methods)
- [Subscriptions API](https://docs.stripe.com/api/subscriptions)
- [Invoices API](https://docs.stripe.com/api/invoices)
- [Checkout Sessions API](https://docs.stripe.com/api/checkout/sessions)
- [Billing Portal API](https://docs.stripe.com/api/customer_portal)
- [Webhooks Guide](https://docs.stripe.com/webhooks)
- [Webhook Event Types](https://docs.stripe.com/api/events/types)
- [Rate Limits](https://docs.stripe.com/rate-limits)
- [Idempotency](https://docs.stripe.com/api/idempotent_requests)
- [Error Handling](https://docs.stripe.com/api/errors)
- [Stripe Billing APIs](https://docs.stripe.com/billing/billing-apis)
