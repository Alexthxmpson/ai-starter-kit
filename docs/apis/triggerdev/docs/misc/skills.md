---
source: https://trigger.dev/docs/skills
scraped: 2026-02-28
---

# Skills

## Overview

Skills function as portable instruction sets designed to educate AI coding assistants in Trigger.dev best practices. These differ from vendor-specific configuration files by operating across multiple AI platforms through an open standard.

## Core Concept

Skills are portable instruction sets that teach AI coding assistants how to use Trigger.dev effectively. They're structured as directories containing a `SKILL.md` file with YAML frontmatter and markdown guidance on patterns, examples, and recommended approaches.

## Installation Process

Users can install skills via the command line:

```bash
npx skills add triggerdotdev/skills
```

The installation automatically detects available AI tools and places files in their respective locations (`.claude/skills/`, `.cursor/skills/`, etc.).

## Available Skill Categories

| Skill | Purpose | Key Topics |
|-------|---------|-----------|
| `trigger-setup` | Initial configuration | SDK installation, project structure |
| `trigger-tasks` | Background and scheduled tasks | Triggering, retries, cron jobs |
| `trigger-agents` | AI workflows and orchestration | Prompt chaining, parallelization |
| `trigger-realtime` | Live updates and streaming | React hooks, progress indicators |
| `trigger-config` | Build configuration | `trigger.config.ts`, extensions |

## Compatibility

The skills standard works with major AI coding assistants including Claude Code, Cursor, GitHub Copilot, Cline, and others that support the Agent Skills standard.
