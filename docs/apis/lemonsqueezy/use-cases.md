# LemonSqueezy — Use Cases

## What You Can Do

### Free (License API — no auth)
| Use Case | Endpoint | Notes |
|----------|----------|-------|
| Activate license key | `POST /v1/licenses/activate` | Client-side safe, no API key needed |
| Validate license key | `POST /v1/licenses/validate` | Daily re-validation from Chrome ext |
| Deactivate license | `POST /v1/licenses/deactivate` | User-initiated, frees activation slot |

### Requires API Key
| Use Case | Endpoint | Notes |
|----------|----------|-------|
| Create dynamic checkout | `POST /v1/checkouts` | Pre-fill email, custom data |
| Register webhooks | `POST /v1/webhooks` | Order/subscription lifecycle events |
| List orders | `GET /v1/orders` | Revenue tracking |
| Manage subscriptions | `GET/PATCH /v1/subscriptions` | Cancel, pause, update |
| List customers | `GET /v1/customers` | CRM-style queries |

## Practical Ideas

| Idea | Complexity | Description |
|------|------------|-------------|
| Chrome ext freemium | Easy | License activate/validate from background.js, no server needed |
| Lifetime scarcity counter | Medium | Webhook counts lifetime orders, disables variant at 500 |
| Weekly revenue report | Easy | Trigger.dev cron → GET /v1/orders → Discord webhook |
| Subscription churn alerts | Medium | Webhook on subscription_cancelled → Discord notification |
| Auto-refund window | Medium | Webhook on order_created → schedule refund check at 30 days |

## Key Limits & Gotchas

- License API rate limit: 60/min (vs 300/min for main API)
- No built-in inventory/stock limit on variants — must implement via webhooks
- Checkout URLs from `/checkout/buy/` are shareable; `/checkout/?cart=` URLs are single-use
- API key shown only once on creation — copy immediately
- Test mode keys only work with test mode data
- Transaction fee: 5% + $0.50 — higher than Stripe (2.9% + 30c) but includes MoR

## Existing Scripts/Tools

- **Extension integration**: `chrome-extensions/pinterest-board-mover/background.js` — full license activate/validate/deactivate flow
- **Env var**: `LEMONSQUEEZY_API_KEY` (to be set after store creation)
