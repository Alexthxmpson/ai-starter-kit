---
source: https://trigger.dev/docs/guides/example-projects/claude-github-wiki
scraped: 2026-02-28
---

# Claude GitHub Wiki

## Project Overview

The Claude GitHub wiki is a demonstration application that combines Anthropic's Claude Agent SDK with Trigger.dev to create an AI-powered code analysis tool. Users can ask questions about any public GitHub repository, and the system analyzes the codebase to provide detailed answers.

## Core Technology Stack

The project leverages three main technologies:

- **Next.js** with App Router for the user interface
- **Claude Agent SDK** for AI-powered code exploration
- **Trigger.dev** for workflow orchestration and real-time communication

## How the System Works

The workflow follows these steps:

1. A user submits a GitHub repository URL and a question
2. The system performs a shallow clone of the repository
3. Claude explores the codebase using Grep and Read tools
4. Analysis results stream back to the frontend in real-time
5. Temporary files are cleaned up automatically

## Key Capabilities

The agent can investigate repositories to answer questions about architecture, security considerations, API design, and testing approaches. Users can cancel operations at any time, and the system tracks progress throughout the analysis process.

## Important Configuration

The Trigger.dev configuration requires marking the Claude Agent SDK as external to prevent bundling issues. The platform supports up to 60-minute execution times for analyzing large repositories.

## Additional Resources

The documentation references guides for building agents with Claude, implementing real-time streaming, and handling errors appropriately.
