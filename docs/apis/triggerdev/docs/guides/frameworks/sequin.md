---
source: https://trigger.dev/docs/guides/frameworks/sequin
scraped: 2026-02-28
---

# Sequin Database Triggers Integration Guide

## Overview

This documentation demonstrates how to establish a connection between Sequin, a database change detection service, and Trigger.dev tasks. The integration enables automated task execution whenever data modifications occur in your PostgreSQL database.

## Core Concept

Sequin captures every insert, update, and delete on a table and then ensures a task is triggered for each change. The workflow captures database events through Sequin and forwards them to Trigger.dev tasks via HTTP webhooks.

## Prerequisites

- Next.js project with Trigger.dev installed
- Active Sequin account
- PostgreSQL database (version 12+) containing target tables

## Implementation Structure

### Task Development

The guide provides a `createEmbeddingForPost` task that:
- Accepts Sequin change event payloads
- Generates embeddings using OpenAI's API
- Stores results in a `post_embeddings` table

The implementation uses the `@trigger.dev/sdk` to define task logic and includes database connectivity via the `pg` client.

### API Route Configuration

A Next.js route handler receives webhook deliveries from Sequin and triggers task execution. The endpoint validates incoming requests using bearer token authentication and invokes tasks through `tasks.trigger()`.

### Environment Variables

Required configuration includes:
- `SEQUIN_WEBHOOK_SECRET` - Authentication key
- `TRIGGER_SECRET_KEY` - API credentials
- `OPENAI_API_KEY` - Embedding service access
- `DATABASE_URL` - PostgreSQL connection string

## Sequin Setup Process

Configuration involves:
1. Database connection with publication and replication slot creation
2. HTTP endpoint tunnel setup for local development
3. Push consumer creation targeting specific tables
4. Sort/filter configuration for data processing

## Testing and Validation

The guide includes end-to-end testing steps:
- Starting development servers (Next.js, Trigger.dev, Sequin tunnel)
- Creating test database records
- Verifying event delivery through Sequin dashboard traces
- Confirming task execution in Trigger.dev dashboard

## Production Considerations

The documentation recommends implementing error handling through task retries and deploying to production environments with updated endpoint configurations and database references.
