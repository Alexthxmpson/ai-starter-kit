# LemonSqueezy API Documentation

**Source:** https://docs.lemonsqueezy.com/api
**Date saved:** 2026-03-14
**Used for:** Pinterest Board Mover Chrome extension payment + license validation

---

## Authentication

Main API: `Authorization: Bearer {api_key}` header
License API: No auth required (designed for client-side calls)

Base URL: `https://api.lemonsqueezy.com`

## Rate Limits

- Main API: 300 requests/minute
- License API: 60 requests/minute

---

## License API (No Auth Required)

### Activate License

```
POST /v1/licenses/activate
Content-Type: application/x-www-form-urlencoded
Accept: application/json

license_key=<key>&instance_name=<name>
```

Response:
```json
{
  "activated": true,
  "error": null,
  "license_key": { "id": 1, "status": "active", "key": "...", "activation_limit": 5, "activation_usage": 1, "expires_at": null },
  "instance": { "id": "uuid", "name": "Chrome Extension" },
  "meta": { "store_id": 1, "order_id": 2, "product_id": 4, "variant_id": 5, "customer_email": "..." }
}
```

### Validate License

```
POST /v1/licenses/validate
Content-Type: application/x-www-form-urlencoded
Accept: application/json

license_key=<key>&instance_id=<instance_uuid>
```

Response:
```json
{
  "valid": true,
  "error": null,
  "license_key": { "status": "active", ... },
  "instance": { "id": "...", ... },
  "meta": { ... }
}
```

License statuses: `active`, `inactive`, `expired`, `disabled`

### Deactivate License

```
POST /v1/licenses/deactivate
Content-Type: application/x-www-form-urlencoded
Accept: application/json

license_key=<key>&instance_id=<instance_uuid>
```

---

## Checkouts API (Auth Required)

### Create Checkout

```
POST /v1/checkouts
Authorization: Bearer {api_key}
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
```

Body:
```json
{
  "data": {
    "type": "checkouts",
    "attributes": {
      "product_options": { "enabled_variants": [123], "redirect_url": "https://..." },
      "checkout_data": { "email": "...", "custom": { "user_id": "..." } },
      "expires_at": "2026-04-30T23:59:59Z"
    },
    "relationships": {
      "store": { "data": { "type": "stores", "id": "STORE_ID" } },
      "variant": { "data": { "type": "variants", "id": "VARIANT_ID" } }
    }
  }
}
```

Response URL in: `data.attributes.url`

### Direct Checkout URLs (no API call)

```
https://{STORE}.lemonsqueezy.com/checkout/buy/{VARIANT_ID}
  ?checkout[email]=...
  &checkout[discount_code]=...
```

---

## Webhooks

### Create Webhook

```
POST /v1/webhooks
Authorization: Bearer {api_key}
```

Events: `order_created`, `subscription_created`, `subscription_updated`, `subscription_expired`, `subscription_cancelled`, `subscription_payment_success`, `subscription_payment_failed`, `license_key_created`, `license_key_updated`

Signature verification: `X-Signature` header = HMAC-SHA256 hex digest of raw body using signing secret.

---

## Key Facts

- No built-in variant stock/quantity limit (use webhook counter + variant disable for scarcity)
- Subscription licenses auto-expire when subscription expires
- Lifetime licenses: set `is_license_length_unlimited: true`
- Test mode and Live mode have separate API keys
- Transaction fee: 5% + $0.50 per transaction
