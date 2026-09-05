---
source: https://trigger.dev/docs/mcp-introduction
scraped: 2026-02-28
---

# MCP Introduction

## What is the Trigger.dev MCP Server?

The Trigger.dev MCP (Model Context Protocol) Server is a tool that enables AI assistants to interact directly with your Trigger.dev projects. It offers capabilities including:
- Documentation search
- Project initialization
- Project management
- Task information retrieval
- Deployment functionality
- Run monitoring

## Installation

The simplest setup method uses an interactive installer:

```bash
npx trigger.dev@latest install-mcp
```

This command automatically detects and configures compatible clients on your system.

## Client Configuration

### Claude Code (`~/.claude.json` or `.mcp.json`)

```json
{
  "mcpServers": {
    "trigger": {
      "command": "npx",
      "args": ["trigger.dev@latest", "mcp"]
    }
  }
}
```

### Cursor (`~/.cursor/mcp.json` or `.cursor/mcp.json`)

```json
{
  "mcpServers": {
    "trigger": {
      "command": "npx",
      "args": ["trigger.dev@latest", "mcp"]
    }
  }
}
```

Windsurf, VS Code, Zed, Cline, Gemini CLI, AMP, Codex CLI, Crush, opencode, and Ruler all follow similar patterns with client-specific configuration paths.

After configuration, restart your client to establish the connection.

## Authentication

Documentation search functions without authentication. Other tools require login through the Trigger.dev CLI, with prompts appearing on first use of authenticated features.

## CLI Options

The `install-mcp` command accepts parameters:

| Flag | Description |
|------|-------------|
| `-p, --project-ref` | Target specific project |
| `-t, --tag` | CLI package version |
| `--yolo` | Install across all supported clients |
| `--client` | Install for specific client(s) |

## Getting Started

Users can interact with the MCP server through natural language queries requesting task lists, run details, deployments, and documentation searches.
