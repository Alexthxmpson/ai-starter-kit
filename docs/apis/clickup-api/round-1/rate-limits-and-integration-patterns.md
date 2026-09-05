# ClickUp API v2 — Rate Limits, Pagination & AI Automation Integration Patterns

**Source:** Official ClickUp Developer Docs + Community Research
**Date Compiled:** 2026-03-18
**API Version:** v2 (stable) / v3 (in transition)
**Base URL:** `https://api.clickup.com/api/v2`

---

## Table of Contents

1. [API Overview & Authentication](#1-api-overview--authentication)
2. [Rate Limits by Plan](#2-rate-limits-by-plan)
3. [Rate Limit Response Headers](#3-rate-limit-response-headers)
4. [HTTP 429 Handling & Retry-After](#4-http-429-handling--retry-after)
5. [Exponential Backoff Implementation](#5-exponential-backoff-implementation)
6. [Pagination: Tasks & Comments](#6-pagination-tasks--comments)
7. [Bulk Operations & Batch Processing](#7-bulk-operations--batch-processing)
8. [Error Codes Reference](#8-error-codes-reference)
9. [AI Automation Integration Patterns](#9-ai-automation-integration-patterns)
10. [Python SDK Options](#10-python-sdk-options)
11. [Official Integrations: n8n, Zapier, Make](#11-official-integrations-n8n-zapier-make)
12. [Webhooks for Event-Driven Automation](#12-webhooks-for-event-driven-automation)
13. [Long-Running Automation: Polling vs Webhooks](#13-long-running-automation-polling-vs-webhooks)
14. [Common Gotchas & Production Notes](#14-common-gotchas--production-notes)
15. [Quick Reference: Endpoint Table](#15-quick-reference-endpoint-table)
16. [Sources](#16-sources)

---

## 1. API Overview & Authentication

The ClickUp REST API v2 is the stable, production-ready generation of the ClickUp API. A v3 API is being built in parallel with improved consistency and standardized object models, but v2 covers the full range of workspace operations and is the version used by all current SDKs and integrations.

### Base URL

```
https://api.clickup.com/api/v2
```

All endpoints are prefixed with this base. Example:

```
GET https://api.clickup.com/api/v2/list/{list_id}/task
```

### Authentication Methods

**Personal API Token (pk_ prefix)**
- Used for personal scripts, testing, internal tools
- Never expires
- Retrieved from: ClickUp Settings > Apps > API Token
- Header format: `Authorization: pk_xxxxxxxx`

**OAuth 2.0 (Bearer token)**
- Required for apps serving other users
- Authorization URL: `https://app.clickup.com/api`
- Token URL: `https://api.clickup.com/api/v2/oauth/token`
- Grant type: Authorization Code
- OAuth access tokens do NOT expire at this time

```python
import requests

headers = {
    "Authorization": "pk_your_personal_token",
    "Content-Type": "application/json"
}

response = requests.get(
    "https://api.clickup.com/api/v2/team",
    headers=headers
)
```

### Content-Type Requirement

Always use `Content-Type: application/json`. Form-encoded data is not fully supported and causes unexpected behavior.

---

## 2. Rate Limits by Plan

Rate limits in ClickUp apply **per token**, not per IP or per application. Both personal API tokens and OAuth tokens are subject to the same limits based on the **Workspace Plan** that owns the token.

| Plan | Requests Per Minute Per Token |
|---|---|
| Free Forever | 100 |
| Unlimited | 100 |
| Business | 100 |
| Business Plus | 1,000 |
| Enterprise | 10,000 |

### Key Points

- **Rate window:** Per minute (resets on a rolling or fixed-minute boundary — confirmed via `X-RateLimit-Reset` header)
- **Per token, not per workspace:** If you have multiple tokens from the same workspace, each gets its own limit. An Enterprise workspace with 10 tokens theoretically has 100,000 effective requests/minute.
- **Both token types affected:** Personal tokens AND OAuth tokens count toward the same per-token limit.
- **Undocumented behavior:** Historical community reports mention limits as high as 900 req/min for some accounts. The R package `clickrup` documented this in 2024. Official docs confirm the table above — any higher observed limits may be legacy or undocumented enterprise behavior.

### Practical Ceiling for Free/Unlimited/Business

At 100 req/min = 1.67 req/sec. For any automation processing hundreds of tasks, this becomes a hard constraint. Design your system with rate limiting as a first-class concern, not an afterthought.

For Business Plus (1,000/min = 16.7 req/sec) and Enterprise (10,000/min = 166 req/sec), bulk processing becomes much more feasible, but proper backoff still applies.

---

## 3. Rate Limit Response Headers

Every API response (not just errors) includes rate limit state in the headers. You should read these on every response to proactively slow down before hitting the limit.

| Header | Description |
|---|---|
| `X-RateLimit-Limit` | The total request limit for your token per window |
| `X-RateLimit-Remaining` | Number of requests still available in the current window |
| `X-RateLimit-Reset` | Unix timestamp (seconds) when the rate limit window resets |

### Reading Headers in Python

```python
import requests
import time

def make_request_with_header_tracking(url, headers):
    response = requests.get(url, headers=headers)

    # Read rate limit headers from every response
    limit = int(response.headers.get("X-RateLimit-Limit", 100))
    remaining = int(response.headers.get("X-RateLimit-Remaining", 100))
    reset_at = int(response.headers.get("X-RateLimit-Reset", 0))

    print(f"Rate limit: {remaining}/{limit} remaining, resets at {reset_at}")

    # Proactive throttle: if fewer than 10 requests remain, pause until reset
    if remaining < 10 and reset_at > 0:
        sleep_seconds = max(0, reset_at - int(time.time())) + 1
        print(f"Proactive throttle: sleeping {sleep_seconds}s")
        time.sleep(sleep_seconds)

    return response
```

### Proactive vs Reactive Throttling

**Reactive:** Wait until you get a 429, then back off. Simple but introduces failed requests and wasted time.

**Proactive:** Monitor `X-RateLimit-Remaining` and pre-emptively slow down when the buffer drops below a threshold (e.g., 10% of limit remaining). Zero failed requests, smoother throughput.

Recommended: Use proactive throttling for batch operations, reactive + backoff as the safety net.

---

## 4. HTTP 429 Handling & Retry-After

When the rate limit is exceeded, ClickUp returns:

```
HTTP/1.1 429 Too Many Requests
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1742300460
Content-Type: application/json

{
  "err": "Rate limit reached",
  "ECODE": "OAUTH_RATELIMIT"
}
```

### Note on Retry-After Header

The official ClickUp docs list `X-RateLimit-Reset` (Unix timestamp) but NOT a `Retry-After` header. This is different from many other APIs. To compute the wait time from a 429:

```python
wait_seconds = reset_timestamp - int(time.time())
```

If `X-RateLimit-Reset` is missing from the 429 response (which can happen), fall back to a default wait time (typically 60 seconds for the reset window).

### Complete 429 Handler

```python
import requests
import time

def handle_429(response):
    """
    Handle a 429 response from ClickUp API.
    Returns number of seconds to wait before retrying.
    """
    reset_at = response.headers.get("X-RateLimit-Reset")

    if reset_at:
        wait = max(1, int(reset_at) - int(time.time())) + 2  # +2s buffer
    else:
        wait = 60  # Default: wait 60s for the rate limit window to reset

    print(f"Rate limited (429). Waiting {wait}s before retry...")
    return wait
```

---

## 5. Exponential Backoff Implementation

Exponential backoff is the standard strategy for handling both rate limit errors (429) and transient server errors (500, 503). The principle: after each failure, double the wait time before retrying, with optional jitter to avoid thundering herd issues.

### Full Implementation

```python
import requests
import time
import random
import logging
from typing import Optional, Dict, Any

logger = logging.getLogger(__name__)

class ClickUpClient:
    """
    ClickUp API v2 client with built-in rate limiting and
    exponential backoff.
    """

    BASE_URL = "https://api.clickup.com/api/v2"

    def __init__(
        self,
        api_token: str,
        max_retries: int = 5,
        base_delay: float = 1.0,
        max_delay: float = 64.0,
        jitter: bool = True
    ):
        self.headers = {
            "Authorization": api_token,
            "Content-Type": "application/json"
        }
        self.max_retries = max_retries
        self.base_delay = base_delay
        self.max_delay = max_delay
        self.jitter = jitter
        self.session = requests.Session()
        self.session.headers.update(self.headers)

    def _compute_backoff(self, attempt: int) -> float:
        """
        Exponential backoff with optional jitter.
        Attempt 0 -> 1s, attempt 1 -> 2s, attempt 2 -> 4s, etc.
        """
        delay = min(self.base_delay * (2 ** attempt), self.max_delay)
        if self.jitter:
            # Full jitter: random value between 0 and computed delay
            delay = random.uniform(0, delay)
        return delay

    def _update_rate_limit_state(self, response: requests.Response):
        """Read and log rate limit headers from any response."""
        remaining = response.headers.get("X-RateLimit-Remaining")
        limit = response.headers.get("X-RateLimit-Limit")
        reset = response.headers.get("X-RateLimit-Reset")

        if remaining is not None and limit is not None:
            pct = int(remaining) / int(limit) * 100
            logger.debug(
                f"Rate limit: {remaining}/{limit} remaining "
                f"({pct:.0f}%), resets at {reset}"
            )

            # Proactive throttle: pause when under 10% remaining
            if pct < 10 and reset:
                wait = max(0, int(reset) - int(time.time())) + 1
                if wait > 0:
                    logger.info(f"Proactive throttle: sleeping {wait}s")
                    time.sleep(wait)

    def request(
        self,
        method: str,
        endpoint: str,
        **kwargs
    ) -> Dict[Any, Any]:
        """
        Make a request with automatic retry and exponential backoff.

        Args:
            method: HTTP method (GET, POST, PUT, PATCH, DELETE)
            endpoint: API endpoint path (e.g., "/list/123/task")
            **kwargs: Additional args passed to requests (json=, params=)

        Returns:
            Parsed JSON response dict

        Raises:
            requests.HTTPError: If all retries exhausted
        """
        url = f"{self.BASE_URL}{endpoint}"

        for attempt in range(self.max_retries + 1):
            try:
                response = self.session.request(method, url, **kwargs)

                # Update rate limit state on every response
                self._update_rate_limit_state(response)

                if response.status_code == 200:
                    return response.json()

                elif response.status_code == 429:
                    # Rate limited
                    reset_at = response.headers.get("X-RateLimit-Reset")
                    if reset_at:
                        wait = max(1, int(reset_at) - int(time.time())) + 2
                    else:
                        wait = self._compute_backoff(attempt)

                    if attempt == self.max_retries:
                        raise requests.HTTPError(
                            f"Rate limit exhausted after {self.max_retries} retries",
                            response=response
                        )

                    logger.warning(
                        f"429 rate limited on attempt {attempt+1}/{self.max_retries+1}. "
                        f"Waiting {wait:.1f}s..."
                    )
                    time.sleep(wait)

                elif response.status_code in (500, 502, 503, 504):
                    # Transient server errors — exponential backoff
                    if attempt == self.max_retries:
                        response.raise_for_status()

                    wait = self._compute_backoff(attempt)
                    logger.warning(
                        f"HTTP {response.status_code} on attempt {attempt+1}. "
                        f"Retrying in {wait:.1f}s..."
                    )
                    time.sleep(wait)

                else:
                    # Non-retryable error (400, 401, 403, 404)
                    try:
                        error_body = response.json()
                        logger.error(
                            f"HTTP {response.status_code}: "
                            f"{error_body.get('err', 'Unknown error')} "
                            f"(ECODE: {error_body.get('ECODE', 'N/A')})"
                        )
                    except Exception:
                        pass
                    response.raise_for_status()

            except requests.ConnectionError as e:
                if attempt == self.max_retries:
                    raise
                wait = self._compute_backoff(attempt)
                logger.warning(f"Connection error on attempt {attempt+1}: {e}. Retrying in {wait:.1f}s...")
                time.sleep(wait)

        raise RuntimeError(f"Request failed after {self.max_retries} retries")

    # Convenience methods
    def get(self, endpoint: str, params: Optional[Dict] = None) -> Dict:
        return self.request("GET", endpoint, params=params)

    def post(self, endpoint: str, data: Dict) -> Dict:
        return self.request("POST", endpoint, json=data)

    def put(self, endpoint: str, data: Dict) -> Dict:
        return self.request("PUT", endpoint, json=data)

    def patch(self, endpoint: str, data: Dict) -> Dict:
        return self.request("PATCH", endpoint, json=data)

    def delete(self, endpoint: str) -> Dict:
        return self.request("DELETE", endpoint)


# Usage example
client = ClickUpClient(api_token="pk_your_token_here")
tasks = client.get("/list/123456/task", params={"page": 0})
```

### Backoff Delay Schedule (with base_delay=1.0)

| Attempt | Delay (no jitter) | Max Delay Capped At |
|---|---|---|
| 0 | 1s | 1s |
| 1 | 2s | 2s |
| 2 | 4s | 4s |
| 3 | 8s | 8s |
| 4 | 16s | 16s |
| 5 | 32s | 32s |
| 6+ | 64s | 64s (max_delay cap) |

---

## 6. Pagination: Tasks & Comments

### 6.1 Task Pagination

The `GET /list/{list_id}/task` endpoint returns up to **100 tasks per page**. Pagination uses a `page` query parameter starting at 0. The response includes a `last_page` boolean field to indicate when you've reached the end.

**Key parameters:**

| Parameter | Type | Description |
|---|---|---|
| `page` | integer | Page number, 0-indexed. Default: 0 |
| `order_by` | string | Sort field: `id`, `created`, `updated`, `due_date` |
| `reverse` | boolean | Reverse sort order. Default: false |
| `subtasks` | boolean | Include subtasks in response |
| `statuses[]` | array | Filter by status name (case-sensitive) |
| `include_closed` | boolean | Include closed tasks |
| `assignees[]` | array | Filter by assignee IDs |
| `due_date_gt` | integer | Filter tasks due after (Unix ms) |
| `due_date_lt` | integer | Filter tasks due before (Unix ms) |
| `date_created_gt` | integer | Filter by creation date (Unix ms) |
| `date_updated_gt` | integer | Filter by last updated (Unix ms) |
| `include_timl` | boolean | Include tasks with this list as a non-home list |

**Response format:**

```json
{
  "tasks": [...],
  "last_page": false
}
```

### Complete Pagination Loop

```python
def get_all_tasks(client: ClickUpClient, list_id: str) -> list:
    """
    Paginate through all tasks in a ClickUp list.
    Returns a flat list of all task objects.
    """
    all_tasks = []
    page = 0

    while True:
        response = client.get(
            f"/list/{list_id}/task",
            params={
                "page": page,
                "order_by": "created",
                "reverse": True,
                "subtasks": True,
                "include_closed": True
            }
        )

        tasks = response.get("tasks", [])
        all_tasks.extend(tasks)

        print(f"Page {page}: fetched {len(tasks)} tasks (total: {len(all_tasks)})")

        # Stop when last_page is True or no tasks returned
        if response.get("last_page", True) or not tasks:
            break

        page += 1

        # Optional: small delay between pages to be gentle on rate limits
        # (at 100 req/min, you have ~1.67s budget per request)
        # time.sleep(0.1)

    return all_tasks
```

### Important Notes on Task Pagination

1. **`last_page` is the signal** — do not assume you've fetched everything just because a page returns fewer than 100 items. Some queries return partial pages mid-way. Always check `last_page`.

2. **No `total` count in response** — ClickUp does not return a total count of tasks in the response body, so you cannot pre-compute the number of pages.

3. **Page indexing starts at 0** — Unlike some APIs that use page=1, ClickUp uses page=0 as the first page.

4. **`order_by` affects consistency** — If tasks are being created/updated during your pagination run, use a stable sort (e.g., `id` with `reverse: false`) to avoid missing tasks or seeing duplicates across pages.

5. **Filtered queries and pagination** — When using date filters like `date_updated_gt`, combine with pagination to implement incremental sync: fetch all tasks updated since your last run timestamp.

### 6.2 Comment Pagination

Comments use a different pagination mechanism than tasks. The `GET /task/{task_id}/comment` endpoint returns 25 comments per page in **reverse chronological order** (newest first). It uses cursor-style pagination, not a `page` number.

**How to paginate comments:**

```
Call 1: GET /task/{task_id}/comment
  -> Returns comments 1-25 (newest)
  -> Record: last_comment.id and last_comment.date

Call 2: GET /task/{task_id}/comment?start_id={last_id}&start={last_date}
  -> Returns comments 26-50
  -> Continue until response array is empty
```

```python
def get_all_comments(client: ClickUpClient, task_id: str) -> list:
    """
    Paginate through all comments on a task (cursor-based).
    """
    all_comments = []
    params = {}

    while True:
        response = client.get(f"/task/{task_id}/comment", params=params)
        comments = response.get("comments", [])

        if not comments:
            break

        all_comments.extend(comments)

        # Set cursor to the last comment in the current page
        last = comments[-1]
        params = {
            "start_id": last["id"],
            "start": last["date"]
        }

        # If fewer than 25 comments returned, we're on the last page
        if len(comments) < 25:
            break

    return all_comments
```

### 6.3 Filtered Task Queries for Incremental Sync

For AI agents that need to monitor changes without full re-syncs:

```python
import time

def get_tasks_updated_since(
    client: ClickUpClient,
    list_id: str,
    since_timestamp_ms: int
) -> list:
    """
    Get only tasks updated since a given Unix millisecond timestamp.
    Ideal for incremental sync in polling architectures.
    """
    all_tasks = []
    page = 0

    while True:
        response = client.get(
            f"/list/{list_id}/task",
            params={
                "page": page,
                "date_updated_gt": since_timestamp_ms,
                "order_by": "updated",
                "include_closed": True,
                "subtasks": True
            }
        )

        tasks = response.get("tasks", [])
        all_tasks.extend(tasks)

        if response.get("last_page", True) or not tasks:
            break

        page += 1

    return all_tasks

# Example: get tasks updated in the last hour
one_hour_ago_ms = int((time.time() - 3600) * 1000)
recent_tasks = get_tasks_updated_since(client, "list_id_here", one_hour_ago_ms)
```

---

## 7. Bulk Operations & Batch Processing

### What ClickUp Does and Does NOT Support for Bulk Operations

**Supported (single API call):**
- Update a single task: `PUT /task/{task_id}` (can update multiple fields in one call — name, description, status, assignees, due_date, priority, etc.)
- Create a task with custom fields: `POST /list/{list_id}/task` (pass `custom_fields` array in body)

**NOT supported (requires separate calls):**
- Updating multiple tasks in one API call — no bulk task update endpoint exists
- Updating multiple custom fields on one task in one call — each field requires `POST /task/{task_id}/field/{custom_field_id}`
- Bulk task creation — each task requires its own POST request

This is a known limitation. The ClickUp feedback board has 76+ votes on "Update multiple task fields in a single API call" that is marked "not on roadmap" as of late 2025.

### Batch Processing Pattern

Since there is no true bulk API, you must iterate — but do so efficiently:

```python
import asyncio
import aiohttp
import time
from typing import List, Dict

async def batch_update_tasks_async(
    api_token: str,
    updates: List[Dict],  # list of {task_id, fields_to_update}
    requests_per_minute: int = 90,  # stay under 100/min limit
    batch_size: int = 10
) -> List[Dict]:
    """
    Update multiple tasks concurrently using asyncio.
    Respects rate limits via a token bucket approach.

    Args:
        api_token: ClickUp API token
        updates: List of dicts with task_id and update fields
        requests_per_minute: Target rate (leave buffer below plan limit)
        batch_size: Number of concurrent requests per batch

    Returns:
        List of update results
    """
    results = []
    headers = {
        "Authorization": api_token,
        "Content-Type": "application/json"
    }

    # Calculate minimum interval between requests
    min_interval = 60.0 / requests_per_minute  # seconds per request

    async with aiohttp.ClientSession(headers=headers) as session:
        for i in range(0, len(updates), batch_size):
            batch = updates[i:i + batch_size]
            batch_start = time.time()

            # Create tasks for this batch
            tasks = []
            for update in batch:
                task_id = update.pop("task_id")
                tasks.append(
                    update_task_async(session, task_id, update)
                )

            # Execute batch concurrently
            batch_results = await asyncio.gather(*tasks, return_exceptions=True)
            results.extend(batch_results)

            # Rate limit: ensure minimum time between batches
            elapsed = time.time() - batch_start
            required_time = batch_size * min_interval
            if elapsed < required_time:
                await asyncio.sleep(required_time - elapsed)

            print(f"Processed batch {i//batch_size + 1}: "
                  f"{len(batch)} tasks ({len(results)} total)")

    return results


async def update_task_async(
    session: aiohttp.ClientSession,
    task_id: str,
    fields: Dict
) -> Dict:
    """Single async task update with retry on 429."""
    url = f"https://api.clickup.com/api/v2/task/{task_id}"

    for attempt in range(5):
        async with session.put(url, json=fields) as response:
            if response.status == 200:
                return await response.json()
            elif response.status == 429:
                reset_at = response.headers.get("X-RateLimit-Reset")
                wait = max(1, int(reset_at) - int(time.time())) + 2 if reset_at else (2 ** attempt)
                await asyncio.sleep(wait)
            else:
                data = await response.json()
                return {"error": data, "task_id": task_id}

    return {"error": "max retries exceeded", "task_id": task_id}
```

### Custom Field Batch Updates

Since each custom field requires its own API call, batch them with proper rate limiting:

```python
def update_task_custom_fields(
    client: ClickUpClient,
    task_id: str,
    field_updates: Dict[str, Any]  # {custom_field_id: value}
) -> Dict:
    """
    Update multiple custom fields on a task.
    Makes one API call per field (ClickUp limitation).
    """
    results = {}

    for field_id, value in field_updates.items():
        result = client.post(
            f"/task/{task_id}/field/{field_id}",
            data={"value": value}
        )
        results[field_id] = result
        # Small delay to avoid hitting rate limits on large field sets
        time.sleep(0.05)

    return results
```

### Assignee Update Format

The assignees field in update requests uses an add/remove object, NOT a simple list:

```python
# CORRECT — update assignees
client.put(f"/task/{task_id}", data={
    "assignees": {
        "add": [37577187, 12345678],  # user IDs to add
        "rem": [99887766]             # user IDs to remove
    }
})

# WRONG — do not pass a flat array for updates
# "assignees": [37577187]  <- This is only for task creation
```

---

## 8. Error Codes Reference

### HTTP Status Codes

| Status | Meaning | Retryable |
|---|---|---|
| 200 | Success | N/A |
| 400 | Bad Request — malformed request or invalid parameters | No |
| 401 | Unauthorized — missing or invalid token | No |
| 403 | Forbidden — valid token but insufficient permissions | No |
| 404 | Not Found — resource does not exist | No |
| 429 | Too Many Requests — rate limit exceeded | Yes (after delay) |
| 500 | Internal Server Error — ClickUp server issue | Yes (with backoff) |
| 502 | Bad Gateway | Yes (with backoff) |
| 503 | Service Unavailable | Yes (with backoff) |

### ClickUp-Specific Error Response Format

All error responses include a JSON body with two fields:

```json
{
  "err": "Human-readable error message",
  "ECODE": "MACHINE_READABLE_CODE"
}
```

### Known ClickUp Error Codes (ECODE)

| ECODE | Description |
|---|---|
| `OAUTH_007` | Redirect URI does not match app registration |
| `OAUTH_010` | Client application not created correctly |
| `OAUTH_017` | Authorization header missing OR redirect URI not passed |
| `OAUTH_019` | Token not found (authorization revoked) |
| `OAUTH_021` | Token not found |
| `OAUTH_023` | Team not authorized for this access token |
| `OAUTH_025` | Token not found |
| `OAUTH_026` | Team not authorized |
| `OAUTH_027` | Team not authorized |
| `OAUTH_029`–`OAUTH_045` | Team not authorized (range) |
| `OAUTH_077` | Token not found |
| `OAUTH_171` | Webhook configuration already exists for this location |
| `FIELD_375` | Invalid value for a custom field (check field type) |
| `INDEX_014` | Invalid orderindex type |
| `TIMEENTRY_052` | Team not found (when setting time entries) |

**Note:** ClickUp's error code documentation is incomplete by the company's own admission. The feedback board has an open request with over 76 votes to document all error codes. When you encounter an undocumented ECODE, log both the `err` message and the `ECODE` for debugging.

### Error Handling in Python

```python
def safe_api_call(client: ClickUpClient, method: str, endpoint: str, **kwargs):
    """
    Make an API call with structured error handling.
    """
    try:
        return client.request(method, endpoint, **kwargs)

    except requests.HTTPError as e:
        response = e.response
        status = response.status_code

        try:
            body = response.json()
            err_msg = body.get("err", "Unknown")
            ecode = body.get("ECODE", "N/A")
        except Exception:
            err_msg = response.text
            ecode = "PARSE_ERROR"

        if status == 400:
            raise ValueError(f"Bad request [{ecode}]: {err_msg}")
        elif status == 401:
            raise PermissionError(f"Authentication failed [{ecode}]: {err_msg}")
        elif status == 403:
            raise PermissionError(f"Insufficient permissions [{ecode}]: {err_msg}")
        elif status == 404:
            raise LookupError(f"Resource not found [{ecode}]: {err_msg}")
        else:
            raise RuntimeError(f"API error {status} [{ecode}]: {err_msg}")
```

---

## 9. AI Automation Integration Patterns

### 9.1 Using ClickUp as a Task Queue for AI Agents

ClickUp lists function naturally as work queues when you define statuses as pipeline stages. An AI agent polls tasks with a specific status, processes them, then updates the status on completion.

```python
from anthropic import Anthropic
import json

claude = Anthropic()

def process_task_queue(
    client: ClickUpClient,
    list_id: str,
    input_status: str = "ai-pending",
    processing_status: str = "ai-processing",
    done_status: str = "ai-complete",
    error_status: str = "ai-error"
):
    """
    AI agent that processes tasks in a ClickUp list as a work queue.
    Picks up tasks with 'ai-pending' status, processes them with Claude,
    writes output back to the task, and updates status.
    """
    # Get all tasks in the input queue
    response = client.get(
        f"/list/{list_id}/task",
        params={
            "statuses[]": input_status,
            "order_by": "created",
            "include_closed": False
        }
    )

    tasks = response.get("tasks", [])
    print(f"Found {len(tasks)} tasks in '{input_status}' queue")

    for task in tasks:
        task_id = task["id"]
        task_name = task["name"]
        task_description = task.get("description", "")

        # 1. Mark as processing (claim the task)
        client.put(f"/task/{task_id}", data={"status": processing_status})

        try:
            # 2. Call Claude with task context
            ai_result = call_claude_for_task(task_name, task_description, task)

            # 3. Write AI output back to task description
            updated_description = (
                f"{task_description}\n\n"
                f"---\n**AI Analysis (Claude)**\n\n{ai_result}"
            )

            # 4. Update task with result and mark complete
            client.put(f"/task/{task_id}", data={
                "status": done_status,
                "description": updated_description
            })

            # 5. Optionally post as a comment (preserves history)
            client.post(f"/task/{task_id}/comment", data={
                "comment_text": f"**AI Agent Output:**\n\n{ai_result}"
            })

            print(f"Processed task {task_id}: {task_name}")

        except Exception as e:
            # Move to error queue with error message
            client.put(f"/task/{task_id}", data={
                "status": error_status,
                "description": (
                    f"{task_description}\n\n"
                    f"---\n**AI Error:** {str(e)}"
                )
            })
            print(f"Error processing task {task_id}: {e}")


def call_claude_for_task(name: str, description: str, full_task: dict) -> str:
    """
    Call Claude API with task context to generate an analysis or action.
    """
    # Build context from custom fields
    custom_field_context = extract_custom_field_context(full_task)

    message = claude.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=2048,
        messages=[{
            "role": "user",
            "content": (
                f"Task Name: {name}\n\n"
                f"Description: {description}\n\n"
                f"Additional Context:\n{custom_field_context}\n\n"
                f"Please analyze this task and provide actionable next steps."
            )
        }]
    )

    return message.content[0].text


def extract_custom_field_context(task: dict) -> str:
    """
    Extract custom field values from a task for AI context injection.
    """
    custom_fields = task.get("custom_fields", [])
    context_lines = []

    for field in custom_fields:
        field_name = field.get("name", "Unknown Field")
        field_value = field.get("value")
        field_type = field.get("type", "")

        # Handle different custom field types
        if field_value is None:
            continue
        elif field_type == "users" and isinstance(field_value, list):
            names = [u.get("username", u.get("id")) for u in field_value]
            context_lines.append(f"{field_name}: {', '.join(names)}")
        elif field_type in ("drop_down", "labels"):
            # Value is an index into type_config options
            options = field.get("type_config", {}).get("options", [])
            if isinstance(field_value, int) and field_value < len(options):
                context_lines.append(f"{field_name}: {options[field_value]['name']}")
            else:
                context_lines.append(f"{field_name}: {field_value}")
        elif field_type == "date" and field_value:
            # Date is Unix ms — convert to readable
            import datetime
            dt = datetime.datetime.fromtimestamp(int(field_value) / 1000)
            context_lines.append(f"{field_name}: {dt.strftime('%Y-%m-%d')}")
        else:
            context_lines.append(f"{field_name}: {field_value}")

    return "\n".join(context_lines) if context_lines else "No custom field data"
```

### 9.2 Creating Tasks from Natural Language

An AI agent can parse unstructured input (emails, Slack messages, voice transcripts) and create structured ClickUp tasks:

```python
def create_task_from_natural_language(
    client: ClickUpClient,
    list_id: str,
    natural_language_input: str,
    available_assignees: Dict[str, int]  # {name: user_id}
) -> Dict:
    """
    Parse natural language into a structured ClickUp task using Claude.
    """
    # Ask Claude to extract task structure
    extraction_prompt = f"""
    Extract task information from the following text and return valid JSON only.

    Text: "{natural_language_input}"

    Available assignees: {json.dumps(list(available_assignees.keys()))}

    Return this JSON structure (use null for missing fields):
    {{
        "name": "task title",
        "description": "detailed description",
        "priority": 1-4 (1=urgent, 2=high, 3=normal, 4=low) or null,
        "due_date_description": "tomorrow" or "next friday" or "2026-04-01" or null,
        "assignee_names": ["name1", "name2"] or [],
        "tags": ["tag1", "tag2"] or []
    }}
    """

    message = claude.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=512,
        messages=[{"role": "user", "content": extraction_prompt}]
    )

    try:
        extracted = json.loads(message.content[0].text)
    except json.JSONDecodeError:
        # Fallback: create minimal task
        extracted = {"name": natural_language_input[:200]}

    # Build ClickUp task payload
    task_payload = {
        "name": extracted.get("name", "Untitled Task"),
        "description": extracted.get("description", ""),
        "priority": extracted.get("priority"),
        "tags": extracted.get("tags", [])
    }

    # Resolve assignee names to IDs
    assignee_names = extracted.get("assignee_names", [])
    assignee_ids = [
        available_assignees[name]
        for name in assignee_names
        if name in available_assignees
    ]
    if assignee_ids:
        task_payload["assignees"] = assignee_ids

    # Parse due date (simplified — use dateparser library in production)
    due_desc = extracted.get("due_date_description")
    if due_desc:
        due_ms = parse_due_date_to_unix_ms(due_desc)
        if due_ms:
            task_payload["due_date"] = due_ms

    # Create the task
    result = client.post(f"/list/{list_id}/task", data=task_payload)

    print(f"Created task: {result.get('id')} — {result.get('name')}")
    return result


def parse_due_date_to_unix_ms(description: str) -> Optional[int]:
    """
    Convert natural language date to Unix milliseconds.
    Uses dateparser library (pip install dateparser).
    """
    try:
        import dateparser
        dt = dateparser.parse(description, settings={"RETURN_AS_TIMEZONE_AWARE": False})
        if dt:
            return int(dt.timestamp() * 1000)
    except ImportError:
        pass
    return None
```

### 9.3 Auto-Assigning Tasks Based on Content Analysis

```python
def auto_assign_task(
    client: ClickUpClient,
    task_id: str,
    team_members: List[Dict],  # [{id, username, email, skills: [...]}]
) -> str:
    """
    Use Claude to analyze task content and auto-assign to the best team member.
    """
    # Get full task details
    task = client.get(f"/task/{task_id}")

    # Build team context
    team_context = "\n".join([
        f"- {m['username']} (ID: {m['id']}): Skills: {', '.join(m.get('skills', []))}"
        for m in team_members
    ])

    prompt = f"""
    Analyze this task and select the most appropriate assignee.

    Task Name: {task['name']}
    Description: {task.get('description', 'No description')}
    Tags: {', '.join([t['name'] for t in task.get('tags', [])])}

    Team Members:
    {team_context}

    Return JSON only:
    {{
        "assignee_id": <integer user ID>,
        "reasoning": "one sentence explanation"
    }}
    """

    message = claude.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=256,
        messages=[{"role": "user", "content": prompt}]
    )

    result = json.loads(message.content[0].text)
    assignee_id = result["assignee_id"]
    reasoning = result["reasoning"]

    # Assign the task
    client.put(f"/task/{task_id}", data={
        "assignees": {"add": [assignee_id]}
    })

    # Log reasoning as a comment
    client.post(f"/task/{task_id}/comment", data={
        "comment_text": f"**Auto-assigned by AI:** {reasoning}"
    })

    print(f"Assigned task {task_id} to user {assignee_id}: {reasoning}")
    return reasoning
```

### 9.4 Status Automation with AI Decision Making

```python
STATUS_TRANSITION_RULES = {
    "in progress": ["in review", "blocked", "done"],
    "in review": ["in progress", "done", "needs revision"],
    "blocked": ["in progress", "cancelled"]
}

def ai_status_transition(
    client: ClickUpClient,
    task_id: str,
    trigger_event: str,  # e.g., "code review passed", "PR merged"
) -> str:
    """
    Use AI to determine appropriate status transition based on trigger event.
    """
    task = client.get(f"/task/{task_id}")
    current_status = task["status"]["status"].lower()
    allowed_transitions = STATUS_TRANSITION_RULES.get(current_status, [])

    if not allowed_transitions:
        return f"No transitions available from '{current_status}'"

    prompt = f"""
    A task status needs to be updated.

    Task: {task['name']}
    Current status: {current_status}
    Trigger event: {trigger_event}
    Allowed next statuses: {', '.join(allowed_transitions)}

    Which status should this task move to?
    Return JSON only: {{"new_status": "status name", "reason": "brief explanation"}}
    """

    message = claude.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=256,
        messages=[{"role": "user", "content": prompt}]
    )

    result = json.loads(message.content[0].text)
    new_status = result["new_status"]

    if new_status in allowed_transitions:
        client.put(f"/task/{task_id}", data={"status": new_status})
        return f"Moved to '{new_status}': {result['reason']}"
    else:
        return f"AI suggested invalid status '{new_status}' — not applied"
```

### 9.5 Writing AI Outputs Back to Tasks

```python
def write_ai_analysis_to_task(
    client: ClickUpClient,
    task_id: str,
    ai_output: str,
    mode: str = "comment"  # "comment", "description_append", "custom_field"
):
    """
    Write AI-generated content back to a ClickUp task in various ways.

    Modes:
    - "comment": Post as a new comment (preserves history, timestamped)
    - "description_append": Append to task description (inline, persistent)
    - "custom_field": Write to a specific custom field (structured)
    """
    if mode == "comment":
        return client.post(f"/task/{task_id}/comment", data={
            "comment_text": f"**AI Output:**\n\n{ai_output}",
            "notify_all": False
        })

    elif mode == "description_append":
        task = client.get(f"/task/{task_id}")
        current_desc = task.get("description", "")
        timestamp = time.strftime("%Y-%m-%d %H:%M UTC")

        new_desc = (
            f"{current_desc}\n\n"
            f"---\n**AI Analysis — {timestamp}**\n\n{ai_output}"
        )

        return client.put(f"/task/{task_id}", data={
            "description": new_desc
        })

    elif mode == "custom_field":
        # Requires knowing the custom field ID upfront
        # Use GET /list/{list_id}/field to discover field IDs
        raise NotImplementedError(
            "Pass custom_field_id parameter to use this mode"
        )
```

---

## 10. Python SDK Options

There is no official Python SDK from ClickUp. The options are third-party packages of varying maturity:

| Package | PyPI Name | Status | Notes |
|---|---|---|---|
| clickup-python-sdk | `clickup-python-sdk` | Beta (v2.0.1, Apr 2025) | Most complete; covers Tasks, Custom Fields, Teams, Spaces, Folders, Lists |
| clickupython | `clickupython` | Stable (0.0.1) | Older, simpler; task-focused |
| clickuphelper | `clickuphelper` | Active (v0.5.0) | CLI + Python classes |
| clickup-apiv2 | `clickup-apiv2` | Active (v0.0.8, Apr 2025) | Lightweight; get/update tasks + custom fields |
| dlt ClickUp | `dlt[workspace]` | Active | Not a task client — data pipeline for loading ClickUp data into DBs |

### Recommendation

For production AI automation, **build your own thin client** (like the `ClickUpClient` class shown in Section 5) rather than depending on third-party SDKs. Reasons:

1. Rate limiting and backoff must be customized to your plan's limits
2. Most SDKs don't handle pagination automatically
3. You need direct access to response headers for proactive throttling
4. The ClickUp API surface is simple enough that a thin wrapper is sufficient

### Using clickup-python-sdk

```python
# pip install clickup-python-sdk
from clickup_python_sdk.api import ClickupClient

client = ClickupClient.init(user_token="pk_your_token")

teams = client.get_teams()
for team in teams:
    spaces = team.get_spaces()
    for space in spaces:
        lists = space.get_lists()
        for lst in lists:
            tasks = lst.get_tasks()
```

### Using clickupython (older but stable)

```python
# pip install clickupython
from clickupython import ClickUpClient

client = ClickUpClient("YOUR_API_KEY")
task = client.create_task("list_id", name="New task", due_date="march 2 2026")
print(task.id)
```

---

## 11. Official Integrations: n8n, Zapier, Make

### n8n (Recommended for AI Workflows)

n8n provides **native ClickUp nodes** with 1 trigger and 54 actions covering all major ClickUp resources. The ClickUp trigger in n8n listens to webhook events (see Section 12).

**Available n8n ClickUp actions:** Task CRUD, Comment CRUD, Folder CRUD, List CRUD, Space Tags, Goal/Key Result management, Time Entries, Task Dependencies, Checklists.

**AI-specific n8n templates using ClickUp:**
- "Classify Intercom messages & route to ClickUp or Slack with GPT-4o-mini"
- "Fireflies transcripts to meeting summaries & task extractor to Slack & ClickUp"
- "Generate multi-channel release notes from ClickUp tasks with GPT-4o, Notion & Slack"
- "Launch job vacancies from ATS to Google Calendar, ClickUp and LinkedIn with GPT-4o"
- "Bidirectional ClickUp task & Google Calendar sync with multi-calendar routing"

n8n's pricing model counts the entire workflow execution as 1 execution unit (vs. Make which counts each step), making it more economical for complex multi-step ClickUp automations.

### Make (formerly Integromat)

Make has a native ClickUp module. It counts each action as 1 operation — for workflows with many ClickUp API calls, costs scale up quickly. Better suited for simple Zap-like automations than complex AI pipelines.

### Zapier

Zapier supports ClickUp with standard trigger/action Zaps. Limited to simple trigger-action patterns. No native AI processing — must chain to OpenAI/Claude action steps separately. Good for quick integrations, not for complex AI agent workflows.

### Custom Webhook Endpoint (Best for AI Agents)

For production AI automation, the most reliable pattern is:
1. Register a ClickUp webhook (see Section 12)
2. Point it at a FastAPI/Flask endpoint
3. Process event in Python with Claude
4. Write result back to ClickUp via API

This gives full control, no per-operation billing, and supports complex processing logic.

---

## 12. Webhooks for Event-Driven Automation

Webhooks are ClickUp's push mechanism — they fire HTTP POST requests to your endpoint when workspace events occur. This is far more efficient than polling for changes.

### Webhook Event Types

**Task Events:**
- `taskCreated`, `taskUpdated`, `taskDeleted`
- `taskPriorityUpdated`, `taskStatusUpdated`, `taskAssigneeUpdated`
- `taskDueDateUpdated`, `taskTagUpdated`, `taskMoved`
- `taskCommentPosted`, `taskCommentUpdated`
- `taskTimeEstimateUpdated`, `taskTimeTrackedUpdated`

**Structural Events:**
- `listCreated`, `listUpdated`, `listDeleted`
- `folderCreated`, `folderUpdated`, `folderDeleted`
- `spaceCreated`, `spaceUpdated`, `spaceDeleted`

**Goal Events:**
- `goalCreated`, `goalUpdated`, `goalDeleted`
- `keyResultCreated`, `keyResultUpdated`, `keyResultDeleted`

### Creating a Webhook

```python
def create_webhook(
    client: ClickUpClient,
    team_id: str,
    endpoint_url: str,
    events: List[str] = ["*"]  # wildcard for all events
) -> Dict:
    """
    Register a webhook for a ClickUp workspace.
    """
    return client.post(f"/team/{team_id}/webhook", data={
        "endpoint": endpoint_url,
        "events": events
    })

# Create webhook for task status changes only
webhook = create_webhook(
    client,
    team_id="your_team_id",
    endpoint_url="https://your-server.com/clickup-webhook",
    events=["taskStatusUpdated", "taskCreated", "taskCommentPosted"]
)
print(f"Webhook created: {webhook['id']}")
print(f"Secret: {webhook['webhook']['secret']}")
```

### Webhook Payload Format

```json
{
  "webhook_id": "1a2b3c4d-...",
  "event": "taskStatusUpdated",
  "history_items": [
    {
      "id": "history_item_id",
      "type": 1,
      "date": "1742300000000",
      "field": "status",
      "parent_id": "list_id",
      "data": {
        "status_type": "done"
      },
      "source": null,
      "user": {
        "id": 12345,
        "username": "alex",
        "email": "alex@example.com"
      },
      "before": {
        "status": "in progress",
        "color": "#4169e1"
      },
      "after": {
        "status": "done",
        "color": "#008000"
      }
    }
  ],
  "task_id": "abc123def",
  "list_id": "123456"
}
```

### FastAPI Webhook Handler

```python
from fastapi import FastAPI, Request, HTTPException
import hmac
import hashlib

app = FastAPI()
WEBHOOK_SECRET = "your_webhook_secret_here"

@app.post("/clickup-webhook")
async def handle_clickup_webhook(request: Request):
    """
    Receive and process ClickUp webhook events.
    """
    # Verify webhook signature
    body = await request.body()
    signature = request.headers.get("X-Signature")

    if signature:
        expected = hmac.new(
            WEBHOOK_SECRET.encode(),
            body,
            hashlib.sha256
        ).hexdigest()

        if not hmac.compare_digest(signature, expected):
            raise HTTPException(status_code=401, detail="Invalid signature")

    payload = await request.json()
    event_type = payload.get("event")
    task_id = payload.get("task_id")

    # Route to appropriate handler
    if event_type == "taskCreated":
        await handle_task_created(payload, task_id)

    elif event_type == "taskStatusUpdated":
        history = payload.get("history_items", [{}])[0]
        new_status = history.get("after", {}).get("status")
        await handle_status_change(task_id, new_status)

    elif event_type == "taskCommentPosted":
        await handle_new_comment(payload, task_id)

    return {"status": "ok"}


async def handle_task_created(payload: dict, task_id: str):
    """Trigger AI analysis when a new task is created."""
    # Fetch full task details
    task = client.get(f"/task/{task_id}")

    # AI processing (async or queue to background job)
    result = call_claude_for_task(task["name"], task.get("description", ""), task)

    # Write AI output as comment
    client.post(f"/task/{task_id}/comment", data={
        "comment_text": f"**Auto-analysis:**\n\n{result}"
    })


async def handle_status_change(task_id: str, new_status: str):
    """Trigger actions when task status changes."""
    if new_status == "in review":
        # Auto-notify reviewer, run AI code review summary, etc.
        pass
    elif new_status == "done":
        # Update reporting metrics, trigger invoice generation, etc.
        pass
```

### Idempotency

Use `{webhook_id}:{history_item_id}` as an idempotency key. ClickUp may retry webhook deliveries if your endpoint returns an error or times out. Store processed history_item_ids to avoid duplicate processing.

```python
processed_events = set()  # Use Redis in production

def process_webhook_idempotent(payload: dict):
    webhook_id = payload.get("webhook_id")
    history_items = payload.get("history_items", [])

    for item in history_items:
        key = f"{webhook_id}:{item['id']}"
        if key in processed_events:
            print(f"Skipping duplicate event: {key}")
            continue

        processed_events.add(key)
        # Process event...
```

---

## 13. Long-Running Automation: Polling vs Webhooks

### Comparison

| Aspect | Polling | Webhooks |
|---|---|---|
| Latency | Up to poll interval (e.g., 1 min) | Near real-time (seconds) |
| Rate limit cost | Constant background requests | Only triggers on events |
| Infrastructure | Scheduled job (cron/Trigger.dev) | Always-on HTTP server |
| Reliability | Simpler — no inbound connectivity needed | Requires public HTTPS endpoint |
| Missed events | Never (catches up on next poll) | Possible if server is down |
| Complexity | Lower | Higher (signature verification, retry handling) |

### Recommended Architecture: Hybrid

Use webhooks for real-time triggers + polling as a catch-up/reconciliation layer.

```
[ClickUp] --webhook--> [FastAPI handler] --immediate--> [Claude processing]
    |
    +--[Trigger.dev scheduled job @ hourly]--> [Reconciliation poll]
         -> Fetch tasks updated in last 2 hours
         -> Re-process any that were missed by webhook
```

### Polling with Trigger.dev (TypeScript)

```typescript
// Trigger Workflows/my-workflows/trigger/clickup-sync.ts
import { schedules } from "@trigger.dev/sdk/v3";

export const clickupHourlySync = schedules.task({
  id: "clickup-hourly-sync",
  cron: "0 * * * *",  // Every hour

  run: async (payload) => {
    const oneHourAgoMs = Date.now() - 3600 * 1000;

    const response = await fetch(
      `https://api.clickup.com/api/v2/list/${LIST_ID}/task?` +
      `date_updated_gt=${oneHourAgoMs}&order_by=updated`,
      { headers: { Authorization: process.env.CLICKUP_API_TOKEN! } }
    );

    const data = await response.json();
    const tasks = data.tasks || [];

    for (const task of tasks) {
      // Process each updated task
      await processTaskWithAI(task);
    }

    return { processed: tasks.length };
  }
});
```

---

## 14. Common Gotchas & Production Notes

### 14.1 Date Format: Unix Milliseconds

All dates in the ClickUp API are **Unix timestamps in milliseconds**, not seconds.

```python
import time

# CORRECT — multiply by 1000 to get milliseconds
due_date_ms = int(time.time() * 1000)          # now
due_tomorrow_ms = int((time.time() + 86400) * 1000)  # 24 hours from now

# WRONG — this would set due date to 1970
due_date_seconds = int(time.time())  # Do NOT use this as due_date

# When reading dates from ClickUp, divide by 1000 to get Python timestamp
import datetime
task_created_ms = 1742300000000
task_created_dt = datetime.datetime.fromtimestamp(task_created_ms / 1000)
```

### 14.2 Assignee Format Differences: Create vs Update

This is a frequently encountered gotcha:

```python
# Creating a task — assignees is a flat list of user IDs
client.post(f"/list/{list_id}/task", data={
    "name": "New task",
    "assignees": [37577187, 12345678]  # flat array for CREATE
})

# Updating a task — assignees is an add/remove object
client.put(f"/task/{task_id}", data={
    "assignees": {
        "add": [37577187],   # users to add
        "rem": [99887766]    # users to remove
    }
})

# NOT: "assignees": [37577187]  <- does not work for updates
```

### 14.3 Status Names Are Case-Sensitive

Status names must match exactly as configured in your ClickUp workspace. Common mistakes:

```python
# If your status is "In Progress" (capitalized), this will FAIL:
client.put(f"/task/{task_id}", data={"status": "in progress"})

# This will work:
client.put(f"/task/{task_id}", data={"status": "In Progress"})

# Tip: Get available statuses for a list first:
list_info = client.get(f"/list/{list_id}")
statuses = [s["status"] for s in list_info.get("statuses", [])]
print("Available statuses:", statuses)
```

### 14.4 `team` vs `workspace` — Terminology Confusion

In v2 API, "Team" = "Workspace". This is a legacy naming issue.

```python
# Get your workspace ID (confusingly called team_id in v2)
teams = client.get("/team")
workspace_id = teams["teams"][0]["id"]

# All workspace-level endpoints use team_id:
# GET /team/{team_id}/webhook
# GET /team/{team_id}/space
# GET /team/{team_id}/member
```

### 14.5 Custom Field IDs Must Be Pre-Fetched

You cannot guess or construct custom field IDs. Always fetch them first:

```python
def get_custom_field_ids(client: ClickUpClient, list_id: str) -> Dict[str, str]:
    """
    Get a mapping of custom field names to their IDs for a list.
    Cache this result — field IDs don't change.
    """
    response = client.get(f"/list/{list_id}/field")
    return {
        field["name"]: field["id"]
        for field in response.get("fields", [])
    }

# Usage:
field_map = get_custom_field_ids(client, "your_list_id")
ai_score_field_id = field_map["AI Score"]
client.post(f"/task/{task_id}/field/{ai_score_field_id}", data={"value": 8})
```

### 14.6 OAuth Tokens Don't Expire (But Can Be Revoked)

```python
# Handle token revocation gracefully
def handle_auth_error(ecode: str):
    if ecode in ("OAUTH_019", "OAUTH_021", "OAUTH_025", "OAUTH_077"):
        # Token was revoked by user — need re-authentication
        raise AuthenticationError("ClickUp token revoked. Re-auth required.")
    elif ecode in ("OAUTH_023", "OAUTH_026", "OAUTH_027"):
        # Workspace not authorized for this token
        raise AuthorizationError("Workspace not authorized. Check OAuth scope.")
```

### 14.7 Webhook Gotchas

- **Duplicate endpoint error:** Error `OAUTH_171` means a webhook already exists for that endpoint URL + location combination. Check existing webhooks with `GET /team/{team_id}/webhook` before creating.
- **No Retry-After on 429 from ClickUp:** The API returns `X-RateLimit-Reset` (absolute timestamp) not `Retry-After` (relative seconds). Compute wait time manually.
- **CORS blocks browser requests:** Never call the ClickUp API directly from frontend JavaScript. Always proxy through your backend.

### 14.8 Custom Field Write Limits on Free Forever

Free Forever plan has a **60 uses** lifetime limit for custom field writes (Set Custom Field Value calls). Uses accumulate across the workspace and never reset. After hitting the limit, you can't set custom field values but won't lose existing data.

---

## 15. Quick Reference: Endpoint Table

| Resource | Method | Endpoint | Description |
|---|---|---|---|
| Teams/Workspaces | GET | `/team` | Get all workspaces |
| Spaces | GET | `/team/{team_id}/space` | Get all spaces |
| Folders | GET | `/space/{space_id}/folder` | Get folders |
| Lists (in folder) | GET | `/folder/{folder_id}/list` | Get lists in folder |
| Lists (in space) | GET | `/space/{space_id}/list` | Get folderless lists |
| List info | GET | `/list/{list_id}` | Get list + statuses + fields |
| Custom fields | GET | `/list/{list_id}/field` | Get custom field IDs |
| Tasks | GET | `/list/{list_id}/task` | Get tasks (paginated, 100/page) |
| Single task | GET | `/task/{task_id}` | Get full task detail |
| Create task | POST | `/list/{list_id}/task` | Create new task |
| Update task | PUT | `/task/{task_id}` | Update task fields |
| Delete task | DELETE | `/task/{task_id}` | Delete task |
| Comments | GET | `/task/{task_id}/comment` | Get comments (cursor-paged) |
| Add comment | POST | `/task/{task_id}/comment` | Post new comment |
| Set custom field | POST | `/task/{task_id}/field/{field_id}` | Set custom field value |
| Members | GET | `/team/{team_id}/member` | Get workspace members |
| Webhooks (list) | GET | `/team/{team_id}/webhook` | List registered webhooks |
| Webhooks (create) | POST | `/team/{team_id}/webhook` | Register new webhook |
| Webhooks (delete) | DELETE | `/webhook/{webhook_id}` | Remove webhook |
| Time entries | GET | `/team/{team_id}/time_entries` | Get time tracking entries |
| Views | GET | `/team/{team_id}/view` | Get workspace views |
| View tasks | GET | `/view/{view_id}/task` | Get tasks in a view |

---

## 16. Sources

- [ClickUp API Rate Limits — Official Docs](https://developer.clickup.com/docs/rate-limits)
- [ClickUp Get Tasks Reference](https://developer.clickup.com/reference/gettasks)
- [ClickUp Task Comments Pagination](https://developer.clickup.com/docs/task-comments-pagination)
- [ClickUp Date Formatting Guide](https://developer.clickup.com/docs/general-time)
- [ClickUp Custom Fields Reference](https://developer.clickup.com/docs/customfields)
- [ClickUp Create Task Reference](https://developer.clickup.com/reference/createtask)
- [ClickUp Common Errors](https://developer.clickup.com/docs/common_errors)
- [ClickUp Webhooks Documentation](https://developer.clickup.com/docs/webhooks)
- [ClickUp FAQ](https://developer.clickup.com/docs/faq)
- [ClickUp v2/v3 Terminology Guide](https://developer.clickup.com/docs/general-v2-v3-api)
- [clickup-python-sdk on PyPI](https://pypi.org/project/clickup-python-sdk/)
- [clickupython Documentation](https://clickupython.readthedocs.io/en/stable)
- [dltHub ClickUp Python API Docs](https://dlthub.com/context/source/clickup)
- [blockful/clickup-cli — AI-optimized CLI](https://github.com/blockful/clickup-cli)
- [n8n ClickUp Integration](https://n8n.io/integrations/clickup/)
- [ConsultEvo ClickUp Rate Limits Guide](https://consultevo.com/clickup-api-rate-limits-guide/)
- [ConsultEvo ClickUp Webhooks Guide](https://consultevo.com/clickup-webhooks-api-guide/)
- [ConsultEvo ClickUp Create Task Guide](https://consultevo.com/clickup-create-task-api-guide/)
- [ConsultEvo ClickUp Custom Fields Guide](https://consultevo.com/clickup-custom-fields-api-guide/)
- [ClickUp Feedback: Bulk Update Custom Fields](https://feedback.clickup.com/public-api/p/update-multiple-task-fields-in-a-single-api-call)
- [Batch update ClickUp tasks — GitHub Gist](https://gist.github.com/raymondctc/63755a57b17af51a0bebcaee17fbbd9e)
- [ClickUp AI Agents Workflow Guide](https://consultevo.com/clickup-ai-agents-workflow-integration/)
- [ClickUp API Guide — ConsultEvo](https://consultevo.com/clickup-api-how-to-guide/)
- [Zuplo ClickUp API Guide](https://zuplo.com/learning-center/clickup-api/)
