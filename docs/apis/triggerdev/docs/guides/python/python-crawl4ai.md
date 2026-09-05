---
source: https://trigger.dev/docs/guides/python/python-crawl4ai
scraped: 2026-02-28
---

# Python Headless Browser Web Crawler with Trigger.dev

## Overview

This documentation covers building a web crawler using Python, Crawl4AI, and Playwright integrated with Trigger.dev for background task orchestration.

## Key Requirements

- Trigger.dev initialized project
- Python installation on local machine

## Core Components

The solution leverages several technologies:

- **Trigger.dev** for task orchestration
- **Crawl4AI** - an open-source LLM-friendly web crawler
- **Playwright** - for headless Chromium browser automation
- Proxy support for compliant web scraping

## Important: Proxy Requirement

When web scraping, you MUST use a proxy to comply with Trigger.dev's terms of service. Direct scraping without site owner permission on Trigger.dev Cloud risks account suspension.

Recommended proxy services include Smartproxy, Bright Data, Browserbase, Oxylabs, and ScrapingBee.

## Implementation Structure

### Configuration

The `trigger.config.ts` file includes a custom build extension for Playwright/Chromium installation, with Docker layer setup for browser dependencies.

### Task Code

The TypeScript task (`convertUrlToMarkdown`) executes a Python script via `python.runScript`, passing the URL and proxy environment variables.

### Python Script

An async crawler function accepts a URL, configures proxy settings from environment variables, and outputs markdown content using Crawl4AI.

### Dependencies

Required packages: `crawl4ai`, `playwright`, and `urllib3` (version <2.0.0)

## Testing & Deployment

Local testing involves creating a virtual environment, installing dependencies, running the Trigger.dev CLI's `dev` command, and testing via the dashboard. Production deployment uses the `deploy` command.
