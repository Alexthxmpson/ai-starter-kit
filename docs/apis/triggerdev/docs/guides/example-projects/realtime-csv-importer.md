---
source: https://trigger.dev/docs/guides/example-projects/realtime-csv-importer
scraped: 2026-02-28
---

# Next.js Realtime CSV Importer

## Overview

This example demonstrates a Next.js application that leverages Trigger.dev Realtime to build a CSV upload system with real-time progress streaming to users.

The architecture combines several key technologies: **Next.js** provides the frontend framework, **Trigger.dev** handles background task processing, **UploadThing** manages file uploads, and **Trigger.dev Realtime** streams live updates back to the client.

## Key Components

**Task Architecture:**
The solution uses a parent-child task structure where `csvValidator` downloads and parses the CSV file, then distributes row processing across multiple `handleCSVRow` tasks using batch triggering. Each child task validates data and reports progress through the parent task's metadata.

**Frontend Implementation:**
The `useRealtimeCSVValidator` hook subscribes to task updates via `useRealtimeRun`, while the `CSVProcessor` component manages the upload interface and progress visualization.

**Real-time Updates:**
Progress updates flow from child tasks back to the parent through `metadata.parent`, which is then streamed to the frontend using Trigger.dev Realtime capabilities.

## Resources

- **GitHub Repository:** Full project code available in the examples repository
- **Relevant Files:** Task logic in `src/trigger/csv.ts`, hooks in `src/hooks/useRealtimeCSVValidator.ts`, and UI components in `src/components/CSVProcessor.tsx`

## Related Documentation

- Trigger.dev Realtime fundamentals
- Realtime data streaming from tasks
- Batch task triggering patterns
- React hooks for API interaction
