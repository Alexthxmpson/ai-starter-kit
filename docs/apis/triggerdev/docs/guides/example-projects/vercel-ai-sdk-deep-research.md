---
source: https://trigger.dev/docs/guides/example-projects/vercel-ai-sdk-deep-research
scraped: 2026-02-28
---

# Deep Research Agent Using Vercel's AI SDK

## Overview

This full-stack project creates an intelligent deep research agent that autonomously conducts multi-layered web research and generates comprehensive PDF reports. The system uses a recursive depth-first search approach to expand queries and collect results across multiple levels.

## Technology Stack

- **Next.js** - web application framework
- **Vercel's AI SDK** - AI model integration and structured generation
- **Trigger.dev** - task orchestration and real-time progress updates
- **OpenAI's GPT-4o** - query generation, content analysis, and report creation
- **Exa API** - semantic web search with live crawling
- **LibreOffice** - PDF generation
- **Cloudflare R2** - cloud storage for generated reports

## Key Features

The system implements recursive research capabilities that allow the AI to generate search queries, evaluate their relevance, and pursue deeper investigations based on initial findings. Real-time progress updates stream to the frontend using Trigger.dev Realtime, while intelligent source evaluation ensures only relevant content gets processed. Final research outputs are converted to structured HTML reports and then to PDF files before uploading to cloud storage.

## Orchestration Architecture

Three interconnected Trigger.dev tasks manage the workflow:

1. `deepResearchOrchestrator` - coordinates the entire research process
2. `generateReport` - transforms research data into structured HTML using GPT-4o
3. `generatePdfAndUpload` - converts HTML to PDF and uploads to R2

Tasks use `triggerAndWait()` to establish dependency chains with proper sequencing and error handling.

## Research Process

The recursive logic uses adjustable parameters:

- **Depth**: Controls recursion levels (default: 2)
- **Breadth**: Number of queries per level (default: 2, halved each recursion)

The workflow follows: query generation -> web search -> relevance evaluation -> learning extraction -> recursive deepening -> accumulation of all findings across levels.

## Real-Time Frontend Integration

The `useRealtimeTaskTrigger` React hook triggers research tasks and subscribes to updates. Task metadata maintains progress information that the frontend continuously receives and displays as research advances.

## GitHub Repository

The complete codebase is available in the [triggerdotdev/examples repository](https://github.com/triggerdotdev/examples/tree/main/vercel-ai-sdk-deep-research-agent) on GitHub.
