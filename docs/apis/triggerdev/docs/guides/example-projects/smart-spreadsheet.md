---
source: https://trigger.dev/docs/guides/example-projects/smart-spreadsheet
scraped: 2026-02-28
---

# Smart Spreadsheet

## Overview

Smart Spreadsheet is an AI-powered enrichment platform that uses Exa search and Claude to extract verified company data with source attribution. Users input company names or URLs to receive structured information about industry, headcount, and funding details.

## Technology Stack

The application combines several key technologies:

- **Next.js** for the frontend interface
- **Trigger.dev** for orchestrating background tasks
- **Exa** as an AI-native search engine providing structured content
- **Claude** (via Vercel AI SDK) for data extraction
- **Supabase PostgreSQL** for data persistence
- **Trigger.dev Realtime** for live frontend updates

## Workflow Process

The enrichment follows five sequential steps:

1. User initiates enrichment by entering company details
2. Four data-gathering subtasks execute in parallel
3. Each subtask leverages Exa search plus Claude for extraction
4. Results populate in real-time as tasks complete
5. Enriched data persists to Supabase with source attribution

## Key Features

- **Parallel processing** using batch task triggering
- Every data point includes the URL it was extracted from
- Live UI updates as each task finishes
- Zod schemas for consistent data output

## Core Code Patterns

Parallel execution uses `batch.triggerByTaskAndWait()` to trigger four subtasks simultaneously. Child tasks update parent metadata via `metadata.parent.set()`, enabling frontend subscribers to see fields populate in real-time.

## Repository

[View the complete codebase at the Smart Spreadsheet GitHub repository](https://github.com/triggerdotdev/examples/tree/main/smart-spreadsheet)
