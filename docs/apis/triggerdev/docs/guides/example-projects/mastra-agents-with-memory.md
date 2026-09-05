---
source: https://trigger.dev/docs/guides/example-projects/mastra-agents-with-memory
scraped: 2026-02-28
---

# Mastra Agents with Memory Sharing + Trigger.dev Task Orchestration

## Overview

This project demonstrates a multi-agent workflow that provides clothing recommendations based on weather data. Users enter a city and activity to receive personalized suggestions generated from current weather conditions.

The architecture combines two powerful frameworks: Mastra handles agent orchestration and persistent memory management, while Trigger.dev manages durable task execution with built-in retry capabilities and observability features.

## Core Technologies

The stack includes Node.js as the runtime, Mastra for AI agent coordination, PostgreSQL for persistent storage, and Trigger.dev for task orchestration. The system leverages OpenAI's GPT-4 for language processing, the Open-Meteo API for weather data retrieval, and Zod for schema validation.

## Key Architectural Patterns

**Agent Memory Sharing**: Agents efficiently exchange data through Mastra's working memory system, enabling context preservation across operations.

**Task Orchestration**: The workflow uses `triggerAndWait` to execute agents sequentially while maintaining shared memory context.

**Centralized Storage**: A single PostgreSQL instance serves all agents, preventing duplicate connections and ensuring consistent data access.

**Custom Tools**: External APIs integrate with structured validation, using Zod schemas for type safety.

**Agent Specialization**: Purpose-built agents handle specific responsibilities - one collects weather data, another generates clothing recommendations.

## Project Organization

The codebase separates concerns into two main directories: `mastra/` contains agents, tools, and schemas, while `trigger/` houses orchestration tasks. This structure supports scalability and maintainability.

## Storage Implementation

The system employs centralized PostgreSQL storage that all Mastra agents inherit automatically. This approach eliminates connection duplication warnings and works across both local development and serverless environments with providers like Supabase, Neon, Railway, or AWS RDS.
