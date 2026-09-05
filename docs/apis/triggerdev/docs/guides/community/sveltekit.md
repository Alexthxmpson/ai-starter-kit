---
source: https://trigger.dev/docs/guides/community/sveltekit
scraped: 2026-02-28
---

# SvelteKit Setup Guide

## Overview

This page documents a community-developed Vite plugin for integrating SvelteKit with Trigger.dev. The plugin, created by [@cptCrunch_](https://x.com/cptCrunch_), allows developers to use SvelteKit functions directly in Trigger.dev projects.

## Key Features

The plugin provides:

- Direct integration of SvelteKit functions within Trigger.dev tasks
- Automatic function discovery and export capabilities
- TypeScript support with preserved type information
- Compatibility with Trigger.dev V3
- Customizable directory scanning options

## Requirements

Before beginning setup, you'll need:

- An existing SvelteKit project
- TypeScript installed
- A Trigger.dev account (sign up at https://cloud.trigger.dev)
- A new Trigger.dev project created

## Installation

Install the plugin via npm:

```bash
npm i triggerkit
```

For complete setup instructions, refer to [the npm package documentation](https://www.npmjs.com/package/triggerkit).
