# PostHog API — Full Technical Reference

**Source:** https://posthog.com/docs/api and https://posthog.com/docs/product-analytics/capture-events
**Date:** 2026-02-27

---

## Table of Contents

1. [Authentication](#authentication)
2. [Base URL and Conventions](#base-url-and-conventions)
3. [Event Capture](#event-capture)
4. [Batch Capture](#batch-capture)
5. [Persons](#persons)
6. [Feature Flags](#feature-flags)
7. [Experiments](#experiments)
8. [Cohorts](#cohorts)
9. [Insights and Queries](#insights-and-queries)
10. [Projects](#projects)
11. [Self-Hosted vs Cloud](#self-hosted-vs-cloud)
12. [Available SDKs](#available-sdks)
13. [Rate Limits](#rate-limits)

---

## Authentication

PostHog uses two distinct API key types with different scopes and use cases.

### Project API Key (Public Token)

- Used for client-side event capture (capture events, identify users, evaluate feature flags)
- Safe to include in frontend JavaScript — it is not secret
- Found in: Project Settings → Project Variables → Project API Key
- Also called the "write key" or "token"

**Used in request body:**
```json
{ "api_key": "phc_your_project_api_key" }
```

### Personal API Key

- Used for server-side management API calls (reading data, managing resources)
- Must be kept secret — never expose in frontend code
- Found in: Settings → My Settings → Personal API Keys → Create Personal API Key
- Acts as a Bearer token

**HTTP Header:**
```
Authorization: Bearer <personal_api_key>
```

**Example:**
```bash
curl -H "Authorization: Bearer phx_your_personal_api_key" \
  "https://us.posthog.com/api/projects/123/persons/"
```

### Key Type Summary

| Key Type      | Purpose                                | Secret? | Header / Field               |
|---------------|----------------------------------------|---------|------------------------------|
| Project API Key | Event capture, feature flag evaluation | No      | Body: `api_key`              |
| Personal API Key | Management API (read/write data)      | Yes     | Header: `Authorization: Bearer` |

---

## Base URL and Conventions

**PostHog Cloud (US):** `https://us.posthog.com`
**PostHog Cloud (EU):** `https://eu.posthog.com`
**Self-Hosted:** `https://your-posthog-instance.com`

All management API paths follow:
```
/api/projects/{project_id}/...
```

Your `project_id` (integer) is visible in the URL when logged into PostHog.

**Standard response envelope (management API):**
```json
{
  "count": 100,
  "next": "https://us.posthog.com/api/projects/1/persons/?page=2",
  "previous": null,
  "results": [...]
}
```

---

## Event Capture

The capture endpoint is a public POST-only endpoint. No personal API key needed — only the project API key.

### Capture a Single Event

```
POST /i/v0/e/
```

Also available as: `POST /capture/` (alias)

**Required fields:**

| Field       | Type   | Description                                             |
|-------------|--------|---------------------------------------------------------|
| api_key     | string | Your project API key                                    |
| event       | string | Event name (e.g., "page_viewed", "button_clicked")      |
| distinct_id | string | Unique identifier for the user or entity                |

**Optional fields:**

| Field      | Type   | Description                                                |
|------------|--------|------------------------------------------------------------|
| properties | object | Arbitrary key-value pairs attached to the event            |
| timestamp  | string | ISO 8601 timestamp. Omit to use server receive time        |
| uuid       | string | UUID for the event (used for deduplication)                |

**Minimal example:**
```bash
curl -X POST "https://us.posthog.com/i/v0/e/" \
  -H "Content-Type: application/json" \
  --data '{
    "api_key": "phc_your_project_api_key",
    "event": "page_viewed",
    "distinct_id": "user-123"
  }'
```

**Full example with properties and timestamp:**
```bash
curl -X POST "https://us.posthog.com/i/v0/e/" \
  -H "Content-Type: application/json" \
  --data '{
    "api_key": "phc_your_project_api_key",
    "event": "purchase_completed",
    "distinct_id": "user-123",
    "timestamp": "2026-02-27T14:30:00Z",
    "properties": {
      "amount": 99.99,
      "currency": "USD",
      "product_id": "prod_abc123",
      "source": "mobile_app",
      "$current_url": "https://shop.example.com/checkout",
      "$browser": "Chrome",
      "$os": "Windows"
    }
  }'
```

### The $identify Event

Used to attach a person profile to a distinct ID and/or merge anonymous + identified users.

```bash
curl -X POST "https://us.posthog.com/i/v0/e/" \
  -H "Content-Type: application/json" \
  --data '{
    "api_key": "phc_your_project_api_key",
    "event": "$identify",
    "distinct_id": "user-123",
    "properties": {
      "$anon_distinct_id": "anon-id-before-login",
      "$set": {
        "email": "alex@example.com",
        "name": "Alexander Thompson",
        "plan": "pro"
      },
      "$set_once": {
        "first_seen_at": "2026-01-01"
      }
    }
  }'
```

**`$set` vs `$set_once`:**
- `$set` — always overwrites the person property
- `$set_once` — only sets the property if it doesn't already have a value

### Update Person Properties (without an event)

Send a `$set` event specifically designed to update person properties without recording a behavioral event:

```bash
curl -X POST "https://us.posthog.com/i/v0/e/" \
  -H "Content-Type: application/json" \
  --data '{
    "api_key": "phc_your_project_api_key",
    "event": "$set",
    "distinct_id": "user-123",
    "properties": {
      "$set": {
        "subscription_tier": "enterprise",
        "company": "Acme Corp"
      }
    }
  }'
```

### Group Analytics

Groups let you track activity for organizations/companies, not just individual users.

**Associate a user with a group:**
```bash
curl -X POST "https://us.posthog.com/i/v0/e/" \
  -H "Content-Type: application/json" \
  --data '{
    "api_key": "phc_your_project_api_key",
    "event": "$groupidentify",
    "distinct_id": "user-123",
    "properties": {
      "$group_type": "company",
      "$group_key": "company-456",
      "$group_set": {
        "name": "Acme Corporation",
        "industry": "Technology",
        "employees": 500
      }
    }
  }'
```

**Send event attributed to a group:**
```bash
--data '{
  ...
  "properties": {
    "$groups": { "company": "company-456" },
    "feature": "dashboard"
  }
}'
```

---

## Batch Capture

Send multiple events in a single HTTP request. Maximum payload size: 20MB.

```
POST /batch/
```

```bash
curl -X POST "https://us.posthog.com/batch/" \
  -H "Content-Type: application/json" \
  --data '{
    "api_key": "phc_your_project_api_key",
    "batch": [
      {
        "event": "page_viewed",
        "distinct_id": "user-123",
        "timestamp": "2026-02-27T10:00:00Z",
        "properties": { "$current_url": "https://example.com/" }
      },
      {
        "event": "button_clicked",
        "distinct_id": "user-123",
        "timestamp": "2026-02-27T10:00:05Z",
        "properties": { "button_id": "cta-hero", "text": "Get Started" }
      },
      {
        "event": "$identify",
        "distinct_id": "user-456",
        "timestamp": "2026-02-27T10:01:00Z",
        "properties": {
          "$set": { "email": "jane@example.com" }
        }
      }
    ]
  }'
```

**Response (success):**
```json
{ "status": 1 }
```

**No rate limits** on the capture and batch endpoints. There is no limit on number of events per batch, only the 20MB body size limit.

---

## Persons

Persons API requires a personal API key (Bearer token).

### List Persons

```
GET /api/projects/{project_id}/persons/
```

**Query Parameters:**

| Parameter     | Type    | Description                                          |
|---------------|---------|------------------------------------------------------|
| distinct_id   | string  | Filter by specific distinct ID                       |
| email         | string  | Filter by email property                             |
| properties    | string  | JSON filter: `[{"key":"plan","value":"pro","operator":"exact"}]` |
| search        | string  | Search distinct_id or email                          |
| page          | integer | Page number                                          |
| page_size     | integer | Results per page (default: 100)                      |

```bash
curl -H "Authorization: Bearer phx_personal_key" \
  "https://us.posthog.com/api/projects/123/persons/?distinct_id=user-123"
```

**Response:**
```json
{
  "count": 1,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "name": "Alexander Thompson",
      "distinct_ids": ["user-123", "anon-abc"],
      "properties": {
        "email": "alex@example.com",
        "plan": "pro",
        "$os": "Windows",
        "$browser": "Chrome"
      },
      "created_at": "2026-01-01T00:00:00.000000Z",
      "uuid": "01234567-89ab-cdef-0123-456789abcdef"
    }
  ]
}
```

### Get a Specific Person

```
GET /api/projects/{project_id}/persons/{id}/
```

### Update Person Properties

```
PATCH /api/projects/{project_id}/persons/{id}/
```
```json
{
  "properties": {
    "plan": "enterprise",
    "company": "Acme Corp"
  }
}
```

### Delete a Person

```
DELETE /api/projects/{project_id}/persons/{id}/
```

Query parameter: `delete_events=true` to also delete all events associated with this person.

### Merge Persons

```
POST /api/projects/{project_id}/persons/{id}/merge/
```
```json
{ "ids": [2, 3] }
```
Merges persons 2 and 3 into person `{id}`.

### Get Person Properties (schema)

Returns the list of property keys that exist across all persons.

```
GET /api/projects/{project_id}/persons/properties/
```

---

## Feature Flags

### Evaluate Feature Flags for a User (Public Endpoint)

```
POST /flags/
```

This is the public evaluation endpoint (no personal API key needed, only project API key). Used for real-time flag evaluation.

**Request body:**
```json
{
  "api_key": "phc_your_project_api_key",
  "distinct_id": "user-123",
  "person_properties": {
    "email": "alex@example.com",
    "plan": "pro"
  },
  "groups": {
    "company": "company-456"
  },
  "group_properties": {
    "company": {
      "industry": "Technology"
    }
  }
}
```

**Response:**
```json
{
  "featureFlags": {
    "beta-dashboard": true,
    "new-checkout": "variant-b",
    "pricing-test": false
  },
  "featureFlagPayloads": {
    "beta-dashboard": "{\"max_items\": 10}"
  },
  "errorsWhileComputingFlags": false
}
```

**Query parameter:** `?config=true` — adds flag configuration details to the response.

### List All Feature Flags (Management API)

```
GET /api/projects/{project_id}/feature_flags/
```

**Response:**
```json
{
  "results": [
    {
      "id": 1,
      "name": "Beta Dashboard",
      "key": "beta-dashboard",
      "active": true,
      "filters": {
        "groups": [
          {
            "properties": [
              { "key": "plan", "value": "pro", "operator": "exact", "type": "person" }
            ],
            "rollout_percentage": 100
          }
        ],
        "multivariate": null
      },
      "created_at": "2026-01-15T00:00:00Z"
    }
  ]
}
```

### Get a Specific Feature Flag

```
GET /api/projects/{project_id}/feature_flags/{flag_id}/
```

### Create a Feature Flag

```
POST /api/projects/{project_id}/feature_flags/
```

**Boolean flag (all users):**
```json
{
  "name": "My New Feature",
  "key": "my-new-feature",
  "active": true,
  "filters": {
    "groups": [
      { "properties": [], "rollout_percentage": 100 }
    ]
  }
}
```

**Multivariate flag with variants:**
```json
{
  "name": "Checkout A/B Test",
  "key": "checkout-ab-test",
  "active": true,
  "filters": {
    "groups": [
      { "properties": [], "rollout_percentage": 100 }
    ],
    "multivariate": {
      "variants": [
        { "key": "control", "name": "Control", "rollout_percentage": 50 },
        { "key": "variant-b", "name": "Variant B", "rollout_percentage": 50 }
      ]
    }
  }
}
```

**Flag for specific user segment (pro users only, 20% rollout):**
```json
{
  "name": "Pro Feature Beta",
  "key": "pro-feature-beta",
  "active": true,
  "filters": {
    "groups": [
      {
        "properties": [
          { "key": "plan", "value": "pro", "operator": "exact", "type": "person" }
        ],
        "rollout_percentage": 20
      }
    ]
  }
}
```

### Update a Feature Flag

```
PATCH /api/projects/{project_id}/feature_flags/{flag_id}/
```

**Toggle a flag on/off:**
```json
{ "active": false }
```

### Delete a Feature Flag

```
DELETE /api/projects/{project_id}/feature_flags/{flag_id}/
```

### Local Evaluation (Server-Side SDKs)

Server-side SDKs can evaluate flags locally without an HTTP call per request by downloading flag rules and evaluating them in memory. Requires a personal API key with feature flag read permissions.

```python
import posthog

posthog.api_key = "phx_personal_key"
posthog.project_api_key = "phc_project_key"
posthog.host = "https://us.posthog.com"
posthog.enable_exception_autocapture()

# Local evaluation — no network call
is_enabled = posthog.feature_enabled("beta-dashboard", "user-123")

# Get variant
variant = posthog.get_feature_flag("checkout-ab-test", "user-123",
  person_properties={"plan": "pro"})
```

---

## Experiments

Experiments (A/B tests) are built on top of multivariate feature flags.

### List Experiments

```
GET /api/projects/{project_id}/experiments/
```

**Response:**
```json
{
  "results": [
    {
      "id": 1,
      "name": "Checkout Button Color Test",
      "description": "Testing red vs green CTA button",
      "start_date": "2026-02-01T00:00:00Z",
      "end_date": null,
      "feature_flag_key": "checkout-color-test",
      "parameters": {
        "feature_flag_variants": [
          { "key": "control", "name": "Control (blue)", "rollout_percentage": 33 },
          { "key": "red", "name": "Red button", "rollout_percentage": 33 },
          { "key": "green", "name": "Green button", "rollout_percentage": 34 }
        ],
        "recommended_running_time": 14,
        "recommended_sample_size": 5000
      },
      "metrics": [
        { "type": "primary", "action_id": 1, "name": "Purchase" }
      ],
      "status": "running"
    }
  ]
}
```

### Get Experiment Results

```
GET /api/projects/{project_id}/experiments/{experiment_id}/results/
```

**Response includes:** variant results, statistical significance, p-values, confidence intervals, recommended winner.

### Create an Experiment

```
POST /api/projects/{project_id}/experiments/
```
```json
{
  "name": "Homepage CTA Test",
  "description": "Test two CTA variants",
  "feature_flag_key": "homepage-cta-test",
  "start_date": "2026-03-01T00:00:00Z",
  "parameters": {
    "feature_flag_variants": [
      { "key": "control", "rollout_percentage": 50 },
      { "key": "variant-b", "rollout_percentage": 50 }
    ],
    "minimum_detectable_effect": 5
  }
}
```

### End an Experiment

```
PATCH /api/projects/{project_id}/experiments/{experiment_id}/
```
```json
{ "end_date": "2026-03-15T00:00:00Z" }
```

---

## Cohorts

Cohorts are saved groups of persons matching specific criteria.

### List Cohorts

```
GET /api/projects/{project_id}/cohorts/
```

**Response:**
```json
{
  "results": [
    {
      "id": 1,
      "name": "Pro Plan Users",
      "description": "Users on the Pro plan",
      "filters": {
        "properties": {
          "type": "AND",
          "values": [
            {
              "type": "AND",
              "values": [
                { "key": "plan", "value": "pro", "operator": "exact", "type": "person" }
              ]
            }
          ]
        }
      },
      "count": 1234,
      "created_at": "2026-01-01T00:00:00Z"
    }
  ]
}
```

### Create a Cohort

```
POST /api/projects/{project_id}/cohorts/
```

**Static cohort (by distinct IDs):**
```json
{
  "name": "Beta Testers List",
  "is_static": true
}
```
Then add persons via:
```
POST /api/projects/{project_id}/cohorts/{cohort_id}/persons_list/
```
```json
{ "distinct_ids": ["user-1", "user-2", "user-3"] }
```

**Dynamic cohort (by property filter):**
```json
{
  "name": "Active Pro Users",
  "is_static": false,
  "filters": {
    "properties": {
      "type": "AND",
      "values": [
        {
          "type": "AND",
          "values": [
            { "key": "plan", "value": "pro", "operator": "exact", "type": "person" },
            { "key": "$last_seen", "value": "-7d", "operator": "is_date_after", "type": "person" }
          ]
        }
      ]
    }
  }
}
```

### Get Cohort Details

```
GET /api/projects/{project_id}/cohorts/{cohort_id}/
```

### Update a Cohort

```
PATCH /api/projects/{project_id}/cohorts/{cohort_id}/
```

### Delete a Cohort

```
DELETE /api/projects/{project_id}/cohorts/{cohort_id}/
```

### Get Persons in a Cohort

```
GET /api/projects/{project_id}/cohorts/{cohort_id}/persons/
```

---

## Insights and Queries

### List Saved Insights

```
GET /api/projects/{project_id}/insights/
```

**Query Parameters:**

| Parameter   | Type    | Description                            |
|-------------|---------|----------------------------------------|
| saved       | boolean | Only return saved insights             |
| my_last_viewed | boolean | Return insights you recently viewed |

### Get a Saved Insight

```
GET /api/projects/{project_id}/insights/{insight_id}/
```

### Create/Run an Insight (Trend)

```
POST /api/projects/{project_id}/insights/trend/
```
```json
{
  "events": [
    { "id": "page_viewed", "name": "Page Viewed", "type": "events" },
    { "id": "purchase_completed", "name": "Purchase Completed", "type": "events" }
  ],
  "date_from": "-30d",
  "interval": "day",
  "breakdown": "properties.$browser"
}
```

### Run a Funnel

```
POST /api/projects/{project_id}/insights/funnel/
```
```json
{
  "events": [
    { "id": "page_viewed", "order": 0 },
    { "id": "signup_started", "order": 1 },
    { "id": "signup_completed", "order": 2 }
  ],
  "date_from": "-14d",
  "funnel_window_days": 7
}
```

### HogQL Query (SQL-like custom queries)

```
POST /api/projects/{project_id}/query/
```
```json
{
  "query": {
    "kind": "HogQLQuery",
    "query": "SELECT event, count() as count FROM events WHERE timestamp > now() - INTERVAL 7 DAY GROUP BY event ORDER BY count DESC LIMIT 20"
  }
}
```

**Response:**
```json
{
  "results": [
    ["page_viewed", 15234],
    ["button_clicked", 8901],
    ["purchase_completed", 432]
  ],
  "columns": ["event", "count"],
  "types": ["String", "UInt64"]
}
```

### Persons Analytics Query

```
POST /api/projects/{project_id}/query/
```
```json
{
  "query": {
    "kind": "HogQLQuery",
    "query": "SELECT distinct_id, properties.email, properties.plan FROM persons WHERE properties.plan = 'pro' LIMIT 100"
  }
}
```

---

## Projects

### List Projects (for an Organization)

```
GET /api/organizations/{organization_id}/projects/
```

### Get a Project

```
GET /api/projects/{project_id}/
```

**Response includes:** project name, API key, timezone, data attributes.

---

## Self-Hosted vs Cloud

| Dimension            | PostHog Cloud                               | Self-Hosted (Open Source)                    |
|----------------------|---------------------------------------------|----------------------------------------------|
| Setup                | Sign up at posthog.com — immediate          | Deploy via Docker/Helm on your own infra     |
| Maintenance          | Managed by PostHog team                     | You manage updates, backups, scaling         |
| Data residency       | US (us.posthog.com) or EU (eu.posthog.com)  | Your infrastructure, any region              |
| Recommended scale    | Unlimited (auto-scales)                     | Up to ~100k events/month before migration    |
| Paid features        | All features available on paid plans        | Paid-plan features are Cloud-only            |
| Updates              | Continuous, automatic                       | Manual — you must pull and redeploy          |
| API host             | `https://us.posthog.com` or `https://eu.posthog.com` | `https://your-instance.com`         |
| GDPR/compliance      | EU region available, DPA available          | Full data control on your infrastructure    |

**API difference for self-hosted:** Replace the base URL in all requests:
```bash
# Cloud
curl "https://us.posthog.com/i/v0/e/" ...

# Self-hosted
curl "https://your-posthog.example.com/i/v0/e/" ...
```

---

## Available SDKs

PostHog provides official SDKs for all major platforms:

| Platform        | Install                                     |
|-----------------|---------------------------------------------|
| JavaScript (Web)| `npm install posthog-js`                    |
| Node.js         | `npm install posthog-node`                  |
| React           | `npm install posthog-js` (same package)     |
| React Native    | `npm install posthog-react-native`          |
| Python          | `pip install posthog`                       |
| PHP             | `composer require posthog/posthog-php`      |
| Ruby            | `gem install posthog-ruby`                  |
| Go              | `go get github.com/posthog/posthog-go`      |
| Java            | Maven: `com.posthog.java:posthog`           |
| iOS (Swift)     | Swift Package Manager                       |
| Android         | Gradle: `com.posthog:posthog-android`       |
| Flutter         | `flutter pub add posthog_flutter`           |
| Rust            | `cargo add posthog`                         |
| Elixir          | Hex: `{:posthog, "~> 0.1"}`               |

### Python SDK Quick Reference

```python
import posthog

posthog.project_api_key = "phc_your_key"
posthog.host = "https://us.posthog.com"

# Capture event
posthog.capture("user-123", "purchase_completed", {
    "amount": 99.99,
    "currency": "USD"
})

# Identify
posthog.identify("user-123", {
    "email": "alex@example.com",
    "name": "Alexander Thompson",
    "plan": "pro"
})

# Feature flag
is_enabled = posthog.feature_enabled("beta-feature", "user-123")
variant = posthog.get_feature_flag("ab-test", "user-123")

# Flush (important in short-lived scripts)
posthog.shutdown()
```

### JavaScript SDK Quick Reference

```javascript
import posthog from "posthog-js";

posthog.init("phc_your_project_key", {
  api_host: "https://us.posthog.com",
  autocapture: true,     // Auto-capture clicks, forms, page views
  capture_pageview: true
});

// Identify user
posthog.identify("user-123", {
  email: "alex@example.com",
  plan: "pro"
});

// Capture custom event
posthog.capture("button_clicked", {
  button_id: "cta-hero",
  page: "/home"
});

// Feature flag
if (posthog.isFeatureEnabled("new-dashboard")) {
  // Show new dashboard
}

// Get multivariate flag
const variant = posthog.getFeatureFlag("ab-test");

// Reset (on logout)
posthog.reset();
```

### Node.js SDK Quick Reference

```javascript
const { PostHog } = require("posthog-node");

const client = new PostHog("phc_your_project_key", {
  host: "https://us.posthog.com"
});

// Capture
client.capture({
  distinctId: "user-123",
  event: "api_called",
  properties: { endpoint: "/checkout", method: "POST" }
});

// Identify
client.identify({
  distinctId: "user-123",
  properties: { email: "alex@example.com", plan: "pro" }
});

// Feature flag (requires personal API key for local evaluation)
const isEnabled = await client.isFeatureEnabled("beta-feature", "user-123");

// Flush before shutdown
await client.shutdown();
```

---

## Rate Limits

| Endpoint Category                           | Limit                      |
|---------------------------------------------|----------------------------|
| Event capture (`/i/v0/e`, `/batch`)         | No rate limit              |
| Feature flag evaluation (`/flags`)          | No rate limit              |
| Management API (insights, persons, cohorts) | 240 requests/minute        |
| Management API burst                        | 1,200 requests/hour        |

**Rate limit response:**
```json
{
  "type": "throttled_error",
  "detail": "Request was throttled. Expected available in X seconds."
}
```
HTTP Status: `429 Too Many Requests`

---

*Sources: [PostHog API Overview](https://posthog.com/docs/api) | [Capture Events](https://posthog.com/docs/product-analytics/capture-events) | [Feature Flags API](https://posthog.com/docs/api/feature-flags) | [Persons API](https://posthog.com/docs/api/persons) | [Cohorts API](https://posthog.com/docs/api/cohorts) | [Insights API](https://posthog.com/docs/api/insights) | [SDK Libraries](https://posthog.com/docs/libraries)*
