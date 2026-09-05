---
source: https://trigger.dev/docs/guides/examples/lightpanda
scraped: 2026-02-28
---

# Lightpanda Integration with Trigger.dev

## Overview

Lightpanda serves as a specialized browser optimized for AI and automation tasks. It delivers "10x faster" performance while consuming "10x less RAM than Chrome headless."

## Key Limitations

The integration has one notable constraint: Lightpanda does not support the `puppeteer` screenshot feature.

## Web Scraping Requirements

When scraping web content, you must employ a proxy service to align with terms of service. Direct scraping of third-party websites without permission via Trigger.dev Cloud is prohibited and can result in account suspension.

## Implementation Approaches

Three integration methods are available:

### 1. Lightpanda Cloud with Puppeteer

- Requires a Lightpanda cloud token stored as `LIGHTPANDA_TOKEN`
- Connects via WebSocket endpoint using puppeteer-core
- Supports proxy configuration with optional country codes
- Sessions persist until closure, with a 15-minute maximum duration

### 2. Direct Browser Usage

- Requires the Lightpanda build extension configuration
- Uses command-line execution: `lightpanda fetch --dump [url]`
- Returns HTML content directly

### 3. Chrome DevTools Protocol (CDP)

- Spawns a local Lightpanda CDP server
- Integrates with puppeteer-core over WebSocket
- Configurable host and port via environment variables

All three approaches support extracting page links and HTML content through standard browser automation techniques.
