---
source: https://trigger.dev/docs/quick-start
scraped: 2026-02-28
---

# Trigger.dev Quick Start Guide

## Overview

This documentation provides a three-minute setup guide for Trigger.dev using the CLI and SDK.

## Setup Steps

### 1. Create Account
Sign up at Trigger.dev Cloud or self-host. The onboarding guides you through creating your first organization and project.

### 2. Initialize Your Project
Run the CLI init command in your project root:

```bash
npx trigger.dev@latest init
```

Available for npm, pnpm, and yarn package managers.

The initialization process:
- Optionally installs the Trigger.dev MCP server for AI assistant integration
- Authenticates your CLI session
- Prompts project selection
- Installs required SDK packages
- Creates a `/trigger` directory with example task
- Generates `trigger.config.ts` configuration file

The guide recommends installing the "Hello World" example task for testing.

### 3. Run Development Server
Execute the CLI dev command to start your task server:

```bash
npx trigger.dev@latest dev
```

This server monitors your `/trigger` directory, registers tasks with the platform, executes runs, and manages package version updates.

### 4. Test via Dashboard
Access the Test page from the dev command output. Select the example task and press "Run test" to execute it.

### 5. Monitor Execution
View live-updating run pages showing current task status, with links and feedback available in the terminal.

## Next Steps

The documentation suggests exploring:
- AI-assisted project building
- Task triggering mechanisms
- Task writing fundamentals
- Guides and example projects
