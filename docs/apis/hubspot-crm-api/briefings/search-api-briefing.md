# HubSpot CRM API — Search API Briefing
**Source:** agent5-search-ai-patterns.md, agent1-auth-core-objects.md
**Date:** 2026-03-18

---

## Quick Summary

The HubSpot CRM Search API lets you query any CRM object type with complex filter conditions. It supports AND/OR logic through filter groups, 16 operators, sorting, property selection, and cursor-based pagination. The critical constraint: results are capped at **10,000 records per query**. There is a dedicated rate limit of **5 requests per second** for search (stricter than the standard 100-150/10s limit). For AI agents, search is the primary way to find records matching specific criteria before taking action.

---

## Endpoint and Request Structure

The search endpoint follows a consistent pattern across all standard and custom object types:

```
POST https://api.hubspot.com/crm/v3/objects/{objectType}/search
Authorization: Bearer {ACCESS_TOKEN}
Content-Type: application/json
```

**Object types:** `contacts`, `companies`, `deals`, `tickets`, `line_items`, `products`, `quotes`, `{customObjectTypeId}`

**Full request body structure:**
```json
{
  "filterGroups": [
    {
      "filters": [
        {
          "propertyName": "lifecyclestage",
          "operator": "EQ",
          "value": "customer"
        }
      ]
    }
  ],
  "sorts": [
    {
      "propertyName": "createdate",
      "direction": "DESCENDING"
    }
  ],
  "properties": ["email", "firstname", "lastname", "lifecyclestage"],
  "limit": 100,
  "after": null
}
```

**Response structure:**
```json
{
  "total": 1543,
  "results": [
    {
      "id": "123456",
      "properties": {
        "email": "john@example.com",
        "firstname": "John",
        "lastname": "Doe",
        "lifecyclestage": "customer"
      },
      "createdAt": "2024-01-15T10:00:00Z",
      "updatedAt": "2024-02-20T14:30:00Z",
      "archived": false
    }
  ],
  "paging": {
    "next": {
      "after": "100",
      "link": "https://api.hubspot.com/crm/v3/objects/contacts/search?after=100"
    }
  }
}
```

---

## All Operators

| Operator | Description | Value Required | Example |
|---|---|---|---|
| `EQ` | Equals | Yes | `"value": "customer"` |
| `NEQ` | Not equals | Yes | `"value": "subscriber"` |
| `LT` | Less than | Yes | `"value": "100"` |
| `LTE` | Less than or equal | Yes | `"value": "100"` |
| `GT` | Greater than | Yes | `"value": "50"` |
| `GTE` | Greater than or equal | Yes | `"value": "50"` |
| `BETWEEN` | Between two values | Two values | `"highValue": "100", "value": "50"` |
| `IN` | Value is in list | List in `values` | `"values": ["a", "b", "c"]` |
| `NOT_IN` | Value not in list | List in `values` | `"values": ["a", "b"]` |
| `HAS_PROPERTY` | Property is set (not null) | No | No value field needed |
| `NOT_HAS_PROPERTY` | Property is not set (null) | No | No value field needed |
| `CONTAINS_TOKEN` | Contains substring (string search) | Yes | `"value": "acme"` |
| `NOT_CONTAINS_TOKEN` | Does not contain substring | Yes | `"value": "test"` |
| `STARTS_WITH` | Starts with prefix | Yes | `"value": "John"` |

**BETWEEN example:**
```json
{
  "propertyName": "amount",
  "operator": "BETWEEN",
  "highValue": "10000",
  "value": "1000"
}
```

**IN example:**
```json
{
  "propertyName": "lifecyclestage",
  "operator": "IN",
  "values": ["customer", "evangelist"]
}
```

---

## AND/OR Logic Explained

The filter structure uses two levels:
- **Within a filterGroup** → filters are combined with **AND** (all must match)
- **Between filterGroups** → groups are combined with **OR** (any can match)

```
filterGroups[0].filters[0] AND filterGroups[0].filters[1]
                   OR
filterGroups[1].filters[0] AND filterGroups[1].filters[1]
```

**Example: "(lifecyclestage = customer) OR (amount > 10000 AND dealstage = closedwon)"**
```json
{
  "filterGroups": [
    {
      "filters": [
        {
          "propertyName": "lifecyclestage",
          "operator": "EQ",
          "value": "customer"
        }
      ]
    },
    {
      "filters": [
        {
          "propertyName": "amount",
          "operator": "GT",
          "value": "10000"
        },
        {
          "propertyName": "dealstage",
          "operator": "EQ",
          "value": "closedwon"
        }
      ]
    }
  ]
}
```

**Limits:** Maximum 5 filterGroups per query, maximum 6 filters per filterGroup.

---

## Pagination Pattern

The search API uses cursor-based pagination with an `after` token.

```python
def search_all_contacts(filters: list, properties: list) -> list:
    """Paginate through all results."""
    all_results = []
    after = None

    while True:
        payload = {
            "filterGroups": [{"filters": filters}],
            "properties": properties,
            "limit": 100,  # max per page
        }
        if after:
            payload["after"] = after

        response = client.post("/crm/v3/objects/contacts/search", json=payload)
        results = response.get("results", [])
        all_results.extend(results)

        # Check for next page
        paging = response.get("paging", {})
        next_page = paging.get("next", {})
        after = next_page.get("after")

        if not after or len(results) == 0:
            break

        # Respect 5 req/s Search API limit
        time.sleep(0.2)

    return all_results
```

**Note:** `total` in the response shows the total matching records, but you can only retrieve up to 10,000 regardless.

---

## 10,000 Record Limit Workarounds

HubSpot caps search results at 10,000 records per query (offset cannot exceed 10,000). For large datasets, use one of these strategies:

**Strategy 1: Date-window chunking (recommended for time-series data)**
Break the query into time-windowed chunks, each returning under 10,000 records.

```python
from datetime import datetime, timedelta

def search_contacts_by_date_windows(
    base_filters: list,
    properties: list,
    start_date: datetime,
    end_date: datetime,
    window_days: int = 30
) -> list:
    all_contacts = []
    current = start_date

    while current < end_date:
        window_end = min(current + timedelta(days=window_days), end_date)

        date_filters = base_filters + [
            {
                "propertyName": "createdate",
                "operator": "GTE",
                "value": str(int(current.timestamp() * 1000))
            },
            {
                "propertyName": "createdate",
                "operator": "LT",
                "value": str(int(window_end.timestamp() * 1000))
            }
        ]

        chunk = search_all_contacts(date_filters, properties)
        all_contacts.extend(chunk)
        print(f"Window {current.date()} to {window_end.date()}: {len(chunk)} records")

        current = window_end
        time.sleep(0.2)  # Rate limit

    return all_contacts
```

**Strategy 2: Property-range splitting**
Sort by a numeric property and split at the midpoint.

```python
def search_with_range_split(filters, properties, sort_prop="hs_object_id"):
    """Recursively split by ID range if > 10K results."""
    result = search_all_contacts(filters, properties)

    if len(result) >= 9900:  # Close to limit — split
        ids = [int(r["id"]) for r in result]
        mid = (min(ids) + max(ids)) // 2

        low_filters = filters + [{"propertyName": sort_prop, "operator": "LTE", "value": str(mid)}]
        high_filters = filters + [{"propertyName": sort_prop, "operator": "GT", "value": str(mid)}]

        low = search_with_range_split(low_filters, properties, sort_prop)
        high = search_with_range_split(high_filters, properties, sort_prop)
        return low + high

    return result
```

**Strategy 3: Use the Export API for full data dumps**
For truly large exports (100K+ records), use `POST /crm/v3/exports/` instead of search. Export runs async and provides a download URL. Note: Export API not covered in round-1 research — see GAP-ANALYSIS.md.

---

## Code Examples

**Search contacts created in the last 7 days:**
```python
import time
from datetime import datetime, timedelta

def find_recent_contacts(days: int = 7) -> list:
    cutoff = datetime.now() - timedelta(days=days)
    cutoff_ms = int(cutoff.timestamp() * 1000)

    payload = {
        "filterGroups": [
            {
                "filters": [
                    {
                        "propertyName": "createdate",
                        "operator": "GTE",
                        "value": str(cutoff_ms)
                    }
                ]
            }
        ],
        "sorts": [{"propertyName": "createdate", "direction": "DESCENDING"}],
        "properties": ["email", "firstname", "lastname", "createdate", "lifecyclestage"],
        "limit": 100
    }

    all_contacts = []
    after = None

    while True:
        if after:
            payload["after"] = after

        response = client.post("/crm/v3/objects/contacts/search", json=payload)
        all_contacts.extend(response.get("results", []))

        paging = response.get("paging", {})
        after = paging.get("next", {}).get("after")
        if not after:
            break
        time.sleep(0.2)

    return all_contacts
```

**Search deals in a specific pipeline stage:**
```python
def find_deals_in_stage(stage_id: str) -> list:
    payload = {
        "filterGroups": [
            {
                "filters": [
                    {"propertyName": "dealstage", "operator": "EQ", "value": stage_id},
                    {"propertyName": "closedate", "operator": "HAS_PROPERTY"}
                ]
            }
        ],
        "properties": ["dealname", "amount", "dealstage", "closedate", "hubspot_owner_id"],
        "sorts": [{"propertyName": "amount", "direction": "DESCENDING"}],
        "limit": 100
    }

    response = client.post("/crm/v3/objects/deals/search", json=payload)
    return response.get("results", [])
```

**Search contacts by email domain:**
```python
def find_contacts_by_domain(domain: str) -> list:
    payload = {
        "filterGroups": [
            {
                "filters": [
                    {
                        "propertyName": "email",
                        "operator": "CONTAINS_TOKEN",
                        "value": f"@{domain}"
                    }
                ]
            }
        ],
        "properties": ["email", "firstname", "lastname", "company"],
        "limit": 100
    }
    response = client.post("/crm/v3/objects/contacts/search", json=payload)
    return response.get("results", [])
```
