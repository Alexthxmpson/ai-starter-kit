---
source: https://trigger.dev/docs/building-with-ai
scraped: 2026-02-28
---

# Trigger.dev AI Coding Assistant Documentation

## Overview

Trigger.dev provides multiple tools to help AI coding assistants write correct code for their projects. The platform supports Claude Code, Cursor, Windsurf, VS Code (Copilot), and Zed.

## Quick Setup Options

### 1. MCP Server
Offers direct access to Trigger.dev capabilities through a live server connection. Install with:
```bash
npx trigger.dev@latest install-mcp
```
Enables searching docs, triggering tasks, deploying projects, and monitoring runs.

### 2. Skills
Portable instruction sets teaching best practices across any AI coding assistant. Install with:
```bash
npx skills add triggerdotdev/skills
```
Works with tools supporting the Agent Skills standard.

### 3. Agent Rules
Rule sets installed directly into AI client configuration files. Install with:
```bash
npx trigger.dev@latest install-rules
```
Supports Cursor, Claude Code, VS Code (Copilot), Windsurf, Gemini CLI, and Cline.

## Comparison

| Feature | Skills | Agent Rules | MCP Server |
|---------|--------|-------------|-----------|
| Installation | Project directories | Client config files | mcp.json configs |
| Updates | Manual re-run | Manual or auto-prompted | Always latest |
| Primary use | Pattern teaching | Code generation guidance | Live project interaction |
| Offline capable | Yes | Yes | No |

The documentation recommends installing all three for optimal results.

## Project-Level Context Alternative

For a lightweight approach, create context files matching your AI tool (CLAUDE.md, AGENTS.md, .cursor/rules/, etc.) with Trigger.dev conventions and task patterns.

## Key Task Patterns

Tasks must be exported using the `task()` function from `@trigger.dev/sdk`. The documentation emphasizes always importing from the main SDK path, never from deprecated v2/v3 patterns.

Tasks can be triggered from backends or other tasks, with options for fire-and-forget execution or waiting for results.

## Machine-Readable Documentation

Trigger.dev publishes llms.txt format documentation at:
- trigger.dev/docs/llms.txt (concise overview)
- trigger.dev/docs/llms-full.txt (comprehensive reference)
