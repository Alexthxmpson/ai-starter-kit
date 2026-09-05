---
source: https://trigger.dev/docs/observability/query
scraped: 2026-02-28
---

# Query Documentation

## Overview

The Query feature enables custom data analysis using TRQL, a SQL-style language based on ClickHouse. Users can query through the dashboard, SDK, or REST API.

## Available Data Tables

**Runs Table**: Contains task execution data including status, timing, costs, and outputs.

**Metrics Table**: Stores performance data with these key columns:

| Column | Description |
|--------|-------------|
| `metric_name` | Identifier like `process.cpu.utilization` |
| `metric_type` | gauge, sum, or histogram |
| `value` | The observed measurement |
| `bucket_start` | 10-second aggregation window |
| `run_id` | Associated run ID |
| `task_identifier` | Task identifier |
| `attempt_number` | Attempt number |
| `machine_id` | Machine ID |
| `machine_name` | Machine name |
| `worker_version` | Worker version |
| `environment_type` | PRODUCTION, STAGING, DEVELOPMENT, or PREVIEW |
| `attributes` | Custom JSON data |

## Query Interfaces

### Dashboard

Offers AI-powered query generation, syntax highlighting, query history, built-in help, and CSV/JSON export options.

### SDK Usage

```typescript
import { query } from "@trigger.dev/sdk";
const result = await query.execute("SELECT run_id, status FROM runs LIMIT 10");
```

Type-safe queries use the `QueryTable` type for inferred result types.

### REST API

Execute queries via POST to `/api/v1/query` with authorization headers.

## TRQL Language Features

### Core Syntax
- `SELECT` specific columns or use `*` (returns core columns only)
- `WHERE` with comparison operators, `IN`, `LIKE`/`ILIKE`, `BETWEEN`, NULL checks
- `ORDER BY` with `ASC`/`DESC`
- `GROUP BY` with aggregate functions
- `LIMIT` to restrict rows

### Comparison Operators

```
= != > >= < <= IN BETWEEN LIKE ILIKE
```

### Aggregate Functions

- Counting: `count()`, `countIf()`, `countDistinct()`
- Statistics: `avg()`, `sum()`, `min()`, `max()`, `median()`, `quantile(p)()`
- Deviation: `stddevPop()`, `stddevSamp()`

### Date/Time Functions

- `timeBucket()`: Auto-bucket by period
- `toYear()`, `toMonth()`, `toDayOfWeek()`, `toHour()`
- `toStartOfDay()`, `toStartOfMonth()`: Truncate to period
- `dateAdd()`, `dateDiff()`: Arithmetic operations
- `now()`, `today()`

### String Functions

- Case: `lower()`, `upper()`
- Manipulation: `concat()`, `substring()`, `trim()`, `replace()`
- Testing: `startsWith()`, `endsWith()`

### Conditional Logic

- `if(condition, then, else)`
- `multiIf(c1, t1, c2, t2, ..., else)`
- `coalesce(a, b, ...)`: First non-null value

### Array Operations

- `has(array, value)`: Contains check
- `hasAny()`, `hasAll()`: Multiple value checks
- `arrayJoin()`: Expand array to rows

### JSON Access

Use dot notation directly: `output.message`, `output.count`

## Query Configuration

**Scope Options**:
- `environment` (default): Current environment only
- `project`: All environments in project
- `organization`: All projects in organization

**Time Ranges**:
- Shorthand: `period: "7d"`, `"30d"`, `"1h"` etc.
- Explicit: `from` and `to` Date objects or Unix timestamps

**Response Format**: `json` (default) or `csv`

## Practical Examples

**Failed runs in 24 hours**:
```sql
SELECT task_identifier, run_id, error, triggered_at
FROM runs WHERE status = 'Failed'
ORDER BY triggered_at DESC
```

**Success rate by day**:
```sql
SELECT toDate(triggered_at) AS day, task_identifier,
  countIf(status = 'Completed') AS completed,
  countIf(status = 'Failed') AS failed,
  round(completed / (completed + failed) * 100, 2) AS success_rate_pct
FROM runs WHERE status IN ('Completed', 'Failed')
GROUP BY day, task_identifier ORDER BY day DESC
```

**Memory usage by task**:
```sql
SELECT task_identifier, avg(value) AS avg_memory
FROM metrics WHERE metric_name = 'process.memory.usage'
GROUP BY task_identifier ORDER BY avg_memory DESC LIMIT 20
```

## Best Practices

1. Use built-in time filtering rather than hardcoding dates
2. Always include `LIMIT` for large datasets
3. Employ approximation functions like `uniq()` instead of `uniqExact()` for performance

## System Limits

- Concurrent query limit per organization
- 10,000 maximum rows returned
- Time period restrictions apply
- Memory and execution time constraints
- AST complexity limits
