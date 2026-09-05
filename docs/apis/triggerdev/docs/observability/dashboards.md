---
source: https://trigger.dev/docs/observability/dashboards
scraped: 2026-02-28
---

# Dashboards

Create custom dashboards with real-time metrics powered by TRQL queries. The platform offers both built-in dashboards and customizable options for monitoring application performance.

## Key Features

**Automatic Metrics Collection**: The system automatically gathers process metrics (CPU, memory) and Node.js runtime data without requiring configuration, available in SDK version 4.4.1 and later.

**Visualization Options**: Users can display data as:
- Line charts
- Bar charts
- Area charts
- Tables
- Single-value widgets
- Titles

**Filtering Capabilities**: Dashboards support filtering by:
- Environment
- Project
- Organization
- Tasks
- Queues

Unified time range controls apply across all widgets.

## Creating Dashboards

The creation process involves:
1. Clicking the plus icon next to "Dashboards"
2. Naming the dashboard
3. Adding charts through TRQL queries with selected visualization types

## Performance Optimization

Recommendations for optimal dashboard performance:
- Use time bucketing with `timeBucket()`
- Apply `LIMIT` clauses
- Prefer approximate functions like `uniq()` over exact counting methods

## Data Export and Limits

Users can export metric data as JSON or CSV through widget menus. A concurrent query limit of 30 per project applies to metric widgets, matching general Query service limitations.
