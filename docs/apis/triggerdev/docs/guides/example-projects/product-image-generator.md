---
source: https://trigger.dev/docs/guides/example-projects/product-image-generator
scraped: 2026-02-28
---

# Product Image Generator Using Replicate and Trigger.dev

## Overview

This project showcases an AI-powered tool that elevates basic product photos into professional marketing variations. Users submit a product image and receive three styled versions: clean product shots, lifestyle scenes, and hero shots with dramatic lighting.

## Technology Stack

The application uses:
- **Next.js** for the frontend React framework
- **Replicate** for AI image generation via the `google/nano-banana` model
- **UploadThing** for file upload management
- **Cloudflare R2** for scalable image storage

## Core Architecture

The system employs two primary tasks for orchestration. The first coordinates batch processing across multiple images, while the second manages individual style generation. Each generation task:

- Enhances prompts with style-specific instructions
- Calls Replicate's image-to-image model
- Creates waitpoint tokens for asynchronous webhook handling
- Uploads results to Cloudflare R2

The frontend provides real-time progress updates through React hooks as each task completes.

## Key Implementation Details

Important code files include:
- Image generation tasks with waitpoints for webhook callbacks
- UploadThing integration triggering batch operations
- Live task update UI using React hooks
- Custom prompt interface for user-defined styles
- Main application component handling layout and state

## Related Resources

Users should explore documentation on waitpoints for pausing tasks, React hooks for real-time updates, batch operations for parallel execution, and the Replicate API for AI model integration.
