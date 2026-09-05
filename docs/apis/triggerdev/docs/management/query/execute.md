---
source: https://trigger.dev/docs/management/query/execute
scraped: 2026-02-28
---

# Execute a Query

Execute a TRQL (Trigger.dev Query Language) query against your run data. TRQL is a SQL-style query language that allows you to analyze runs, calculate metrics, and export data.

See the [Query documentation](https://trigger.dev/docs/observability/query#example-queries) for comprehensive examples including failed run analysis, task success rates, cost tracking, and performance metrics.

## Endpoint

`POST /api/v1/query`

## Authentication

Bearer token using your project-specific Secret API key (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.). The TypeScript SDK defaults to the `TRIGGER_SECRET_KEY` environment variable.

## Request Body

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `query` | string | Yes | — | The TRQL query to execute |
| `scope` | string | No | `environment` | Scope of data: `environment`, `project`, or `organization` |
| `period` | string | No | null | Time period shorthand (e.g., `7d`, `30d`, `1h`). Cannot be used with `from`/`to`. |
| `from` | string (ISO 8601) | No | null | Start of time range. Must be used with `to`. |
| `to` | string (ISO 8601) | No | null | End of time range. Must be used with `from`. |
| `format` | string | No | `json` | Response format: `json` or `csv` |

## Response

**200 - Successful request**

- **JSON format**: Array of result row objects
- **CSV format**: CSV-formatted string

**400 - Invalid query or request parameters**

**401 - Unauthorized**

**500 - Internal server error during query execution**

## TypeScript SDK Examples

### Basic Query

```typescript
import { query } from "@trigger.dev/sdk";

const result = await query.execute(
  "SELECT run_id, status FROM runs LIMIT 10"
);
console.log(result.results);
```

### Type-Safe Query

```typescript
import { query, type QueryTable } from "@trigger.dev/sdk";

const result = await query.execute<
  QueryTable<"runs", "run_id" | "status" | "triggered_at">
>(
  "SELECT run_id, status, triggered_at FROM runs LIMIT 10"
);

result.results.forEach(row => {
  console.log(row.run_id, row.status);
});
```

### With Options

```typescript
import { query } from "@trigger.dev/sdk";

const result = await query.execute(
  "SELECT COUNT(*) as count FROM runs WHERE status = 'Failed'",
  {
    scope: "project",
    period: "7d",
    format: "json"
  }
);
```

### CSV Export

```typescript
import { query } from "@trigger.dev/sdk";

const csvResult = await query.execute(
  "SELECT run_id, status, triggered_at FROM runs",
  {
    format: "csv",
    period: "30d"
  }
);

const lines = csvResult.results.split('\n');
```

## cURL Examples

### Basic Query

```bash
curl -X POST "https://api.trigger.dev/api/v1/query" \
  -H "Authorization: Bearer tr_dev_1234" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "SELECT run_id, status FROM runs LIMIT 10",
    "scope": "environment",
    "period": "7d",
    "format": "json"
  }'
```

### Aggregation Query

```bash
curl -X POST "https://api.trigger.dev/api/v1/query" \
  -H "Authorization: Bearer tr_dev_1234" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "SELECT task_identifier, count() as runs, countIf(status = '\''Failed'\'') as failures FROM runs GROUP BY task_identifier",
    "scope": "environment",
    "from": "2024-01-01T00:00:00Z",
    "to": "2024-01-31T23:59:59Z",
    "format": "json"
  }'
```
