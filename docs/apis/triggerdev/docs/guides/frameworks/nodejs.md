---
source: https://trigger.dev/docs/guides/frameworks/nodejs
scraped: 2026-02-28
---

# Node.js Setup Guide

## Prerequisites

- Setup a project in Node.js
- Ensure TypeScript is installed
- [Create a Trigger.dev account](https://cloud.trigger.dev)
- Create a new Trigger.dev project

## Initial Setup

### Step 1: Run the CLI `init` Command

The easiest way to get started is to use the CLI. It will add Trigger.dev to your existing project, create a `/trigger` folder and give you an example task.

Run this command in the root of your project:

```bash
# npm
npx trigger.dev@latest init

# pnpm
pnpm dlx trigger.dev@latest init

# yarn
yarn dlx trigger.dev@latest init
```

The init command will:

1. Ask if you want to install the Trigger.dev MCP server for your AI assistant
2. Log you into the CLI if you're not already logged in
3. Ask you to select your project
4. Install the required SDK packages
5. Ask where you'd like to create the `/trigger` directory and create it with an example task
6. Create a `trigger.config.ts` file in the root of your project

Install the "Hello World" example task when prompted.

### Step 2: Run the CLI `dev` Command

The CLI `dev` command runs a server for your tasks. It watches for changes in your `/trigger` directory and communicates with the Trigger.dev platform to register your tasks, perform runs, and send data back and forth.

```bash
# npm
npx trigger.dev@latest dev

# pnpm
pnpm dlx trigger.dev@latest dev

# yarn
yarn dlx trigger.dev@latest dev
```

### Step 3: Perform a Test Run Using the Dashboard

The CLI `dev` command outputs various useful URLs. Visit the Test page to:

- Select the Example task from the list
- View the JSON editor for task payload input
- Configure run options
- View recent payloads
- Create run templates
- Press the "Run test" button

### Step 4: View Your Run

After running the test, you'll see the run page which live reloads to show the current state of the run. The terminal will also display task status and links to the run log.

## Useful Next Steps

- [Tasks Overview](/tasks/overview) - Learn what tasks are and their options
- [Writing Tasks](/writing-tasks-introduction) - Learn how to write your own tasks
- [Deploy Using the CLI](/cli-deploy) - Learn how to deploy your task manually using the CLI
- [Deploy Using GitHub Actions](/github-actions) - Learn how to deploy your task using GitHub actions
