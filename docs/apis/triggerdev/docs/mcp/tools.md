---
source: https://trigger.dev/docs/mcp-tools
scraped: 2026-02-28
---

# MCP Tools

Learn about the tools available in the Trigger.dev MCP Server.

## Documentation and Search Tools

**search_docs** — Search the Trigger.dev documentation for guides, examples, and API references. Examples include queries like "How do I create a scheduled task?" or "What are the deployment options?"

## Project Management Tools

**list_orgs** — Retrieves all organizations you have access to.

**list_projects** — Displays all projects in your Trigger.dev account.

**create_project_in_org** — Enables you to establish a new project within an organization.

**initialize_project** — Sets up Trigger.dev in your project with automatic configuration.

## Task Management Tools

**get_current_worker** — Retrieves information about the current worker, including the worker version, SDK version, and registered tasks with their payload schemas.

**trigger_task** — Runs a task with a specific payload, allowing you to add delays, set tags, configure retries, choose machine sizes, set TTLs, or use idempotency keys.

## Run Monitoring Tools

**get_run_details** — Provides detailed information about a specific task run, including logs and status, with debug mode available for full traces.

**list_runs** — Displays runs for a project, filterable by status, task, tags, version, machine size, or time period.

**wait_for_run_to_complete** — Pauses execution until a specified run finishes and returns its result.

**cancel_run** — Stops a running or queued run.

## Deployment Tools

**deploy** — Publishes your project to staging or production environments.

**list_deploys** — Shows deployments for a project, filterable by status or time period.

**list_preview_branches** — Displays all preview branches in the project.

> Note: The `deploy` and `list_preview_branches` tools are unavailable when the MCP server runs with the `--dev-only` flag.
