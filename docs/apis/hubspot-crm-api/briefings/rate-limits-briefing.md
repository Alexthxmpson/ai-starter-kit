# HubSpot CRM API — Rate Limits Briefing
**Source:** agent3-webhooks-rate-limits.md, agent1-auth-core-objects.md
**Date:** 2026-03-18

---

## Quick Summary

HubSpot enforces rate limits at the **portal level** (across all apps sharing that portal) and at the **app level** (per individual app/token). Limits vary by plan tier — free portals get 100 requests/10 seconds, Enterprise portals get 150 requests/10 seconds. A separate, stricter limit applies to the Search API (5 requests/second). Limits are enforced with HTTP 429 responses. The `Retry-After` header tells you exactly how long to wait.

**Key principle:** Use batch APIs wherever possible. A single batch call processing 100 records uses 1 API call, not 100.

---

## Limits by Plan Tier

| Plan | 10-Second Burst Limit | Daily Limit | Search API |
|---|---|---|---|
| Free | 100 req/10s | 250,000/day | 5 req/s |
| Starter | 100 req/10s | 250,000/day | 5 req/s |
| Professional | 150 req/10s | 500,000/day | 5 req/s |
| Enterprise | 150 req/10s | 500,000/day | 5 req/s |

**Additional limits:**
- Webhook delivery: no outbound rate limit on HubSpot side; your endpoint must handle bursts
- Batch endpoints: max 100 records per batch request
- Import API: no explicit rate limit but large imports queue asynchronously
- OAuth token refresh: 100 refresh requests per 10 seconds per app

**Private Apps vs OAuth Apps:**
- Private App tokens share the portal-level limit
- OAuth app tokens also share the portal-level limit, not the app-level limit (as of 2024 changes)
- If multiple OAuth apps are connected to the same portal, they collectively share the portal limit

---

## Rate Limit Response Headers

Every API response from HubSpot includes these headers:

| Header | Description | Example |
|---|---|---|
| `X-HubSpot-RateLimit-Daily` | Daily limit for the portal | `500000` |
| `X-HubSpot-RateLimit-Daily-Remaining` | Requests remaining today | `487234` |
| `X-HubSpot-RateLimit-Interval-Milliseconds` | Interval window in ms | `10000` |
| `X-HubSpot-RateLimit-Max` | Max requests per interval | `150` |
| `X-HubSpot-RateLimit-Remaining` | Requests remaining in current window | `47` |
| `Retry-After` | Seconds to wait (only on 429) | `2` |

**Reading the headers:**
```python
response = requests.get(url, headers=auth_headers)

remaining = int(response.headers.get("X-HubSpot-RateLimit-Remaining", 100))
daily_remaining = int(response.headers.get("X-HubSpot-RateLimit-Daily-Remaining", 100000))

# Proactive throttling — slow down when below 20% capacity
if remaining < 30:
    time.sleep(0.5)
if daily_remaining < 10000:
    # Alert: approaching daily limit
    send_alert("HubSpot daily limit almost reached")
```

---

## Retry Strategy Implementation

**The 429 response structure:**
```json
{
  "status": "error",
  "message": "You have reached your secondly limit.",
  "errorType": "RATE_LIMIT",
  "correlationId": "abc123",
  "policyName": "SECONDLY",
  "requestId": "xyz456"
}
```

**Complete retry with exponential backoff + jitter (Python):**
```python
import time
import random
import requests
from typing import Optional, Dict, Any

class HubSpotClient:
    def __init__(self, access_token: str):
        self.access_token = access_token
        self.base_url = "https://api.hubspot.com"
        self.session = requests.Session()
        self.session.headers.update({
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json"
        })

    def request(
        self,
        method: str,
        path: str,
        max_retries: int = 5,
        **kwargs
    ) -> Dict[str, Any]:
        url = f"{self.base_url}{path}"
        attempt = 0

        while attempt <= max_retries:
            try:
                response = self.session.request(method, url, **kwargs)

                if response.status_code == 429:
                    retry_after = int(response.headers.get("Retry-After", 10))
                    # Add jitter: ±20% of retry_after
                    wait = retry_after + random.uniform(0, retry_after * 0.2)
                    print(f"Rate limited. Waiting {wait:.1f}s (attempt {attempt + 1}/{max_retries})")
                    time.sleep(wait)
                    attempt += 1
                    continue

                if response.status_code in (500, 502, 503, 504):
                    # Server error — exponential backoff
                    wait = (2 ** attempt) + random.uniform(0, 1)
                    print(f"Server error {response.status_code}. Waiting {wait:.1f}s")
                    time.sleep(wait)
                    attempt += 1
                    continue

                response.raise_for_status()
                return response.json()

            except requests.exceptions.ConnectionError as e:
                wait = (2 ** attempt) + random.uniform(0, 1)
                print(f"Connection error: {e}. Retrying in {wait:.1f}s")
                time.sleep(wait)
                attempt += 1

        raise Exception(f"Max retries ({max_retries}) exceeded for {method} {path}")

    def get(self, path: str, **kwargs) -> Dict[str, Any]:
        return self.request("GET", path, **kwargs)

    def post(self, path: str, **kwargs) -> Dict[str, Any]:
        return self.request("POST", path, **kwargs)
```

**Usage:**
```python
client = HubSpotClient(access_token=os.environ["HUBSPOT_ACCESS_TOKEN"])

# Automatically retries on 429
contacts = client.get("/crm/v3/objects/contacts", params={"limit": 100})
```

---

## Batch Optimization Patterns

The most effective rate limit management strategy is minimizing API calls through batching.

**Rule: 1 batch = 1 API call, regardless of records processed**

**Batch create (up to 100 records):**
```python
def batch_create_contacts(contacts_data: list[dict]) -> list[dict]:
    """Process in chunks of 100."""
    created = []
    for i in range(0, len(contacts_data), 100):
        chunk = contacts_data[i:i+100]
        payload = {
            "inputs": [{"properties": c} for c in chunk]
        }
        result = client.post("/crm/v3/objects/contacts/batch/create", json=payload)
        created.extend(result.get("results", []))
        # Brief pause between chunks to stay below burst limit
        if i + 100 < len(contacts_data):
            time.sleep(0.1)
    return created

# 1000 contacts = 10 API calls, not 1000
batch_create_contacts(contacts_list)
```

**Batch read (up to 100 IDs):**
```python
def batch_get_contacts(contact_ids: list[str], properties: list[str]) -> list[dict]:
    results = []
    for i in range(0, len(contact_ids), 100):
        chunk = contact_ids[i:i+100]
        payload = {
            "inputs": [{"id": cid} for cid in chunk],
            "properties": properties
        }
        result = client.post("/crm/v3/objects/contacts/batch/read", json=payload)
        results.extend(result.get("results", []))
    return results
```

**Search API rate limit management (5 req/s):**
```python
import threading

search_lock = threading.Lock()
last_search_time = 0

def rate_limited_search(payload: dict) -> dict:
    global last_search_time
    with search_lock:
        now = time.time()
        elapsed = now - last_search_time
        min_interval = 0.2  # 5 req/s = 1 req per 200ms
        if elapsed < min_interval:
            time.sleep(min_interval - elapsed)
        last_search_time = time.time()

    return client.post("/crm/v3/objects/contacts/search", json=payload)
```

---

## Monitoring and Alerting Recommendations

**Track these metrics:**

1. **Daily utilization %** — Alert at 80% (`daily_remaining < 0.2 * daily_limit`)
2. **429 rate per hour** — Alert if > 5 per hour (indicates architecture problem)
3. **Average `Retry-After` value** — Rising value indicates sustained burst
4. **Search API usage** — Track separately; 5 req/s limit is easy to hit

**Lightweight monitoring wrapper:**
```python
from dataclasses import dataclass, field
from collections import defaultdict
import threading

@dataclass
class RateLimitMonitor:
    _429_count: int = 0
    _daily_min_remaining: int = 999999
    _lock: threading.Lock = field(default_factory=threading.Lock)
    _hourly_counts: dict = field(default_factory=lambda: defaultdict(int))

    def record_429(self):
        with self._lock:
            self._429_count += 1
            hour = int(time.time() // 3600)
            self._hourly_counts[hour] += 1
            if self._hourly_counts[hour] > 5:
                print(f"ALERT: {self._hourly_counts[hour]} rate limits this hour")

    def record_headers(self, headers: dict):
        remaining = int(headers.get("X-HubSpot-RateLimit-Daily-Remaining", 999999))
        with self._lock:
            self._daily_min_remaining = min(self._daily_min_remaining, remaining)
            if remaining < 50000:
                print(f"ALERT: Only {remaining} daily requests remaining")

monitor = RateLimitMonitor()
```

**HubSpot's own monitoring:** Settings → Private Apps → select app → Usage tab shows request volume charts.
