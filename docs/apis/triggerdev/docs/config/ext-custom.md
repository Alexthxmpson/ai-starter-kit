---
source: https://trigger.dev/docs/config/extensions/custom
scraped: 2026-02-28
---

# Custom Build Extensions

Build extensions enable customization of the Trigger.dev project build and deployment process. They integrate into the `trigger.config.ts` file and offer hooks for manipulating builds, dependencies, and container images.

## Core Capabilities

Extensions can:
- Incorporate additional files into builds
- Modify the externals dependency list
- Integrate esbuild plugins
- Add npm packages
- Include system packages in image builds
- Execute container commands
- Configure environment variables
- Synchronize variables to Trigger.dev projects

## Implementation Structure

Extensions require a `name` property and optional build hook functions. There are two approaches: inline definitions within `trigger.config.ts` or extracted functions using the `BuildExtension` type from `@trigger.dev/build`.

## Available Build Hooks

**externalsForTarget**: Adds dependencies to the externals list for runtime availability without bundling.

**onBuildStart**: Executes before building begins. This hook is required for registering esbuild plugins and supports target detection ("dev" vs "deploy").

**onBuildComplete**: Runs after building finishes, allowing addition of `BuildLayer` objects via the context.

## BuildContext Methods

The context object provides:
- `addLayer()` - incorporates build layers with dependencies, commands, and environment configurations
- `registerPlugin()` - registers esbuild plugins with optional placement control
- `resolvePath()` - resolves paths relative to the project directory
- Property access to build target, configuration details, and logging utilities

## BuildLayer Structure

Layers support commands, system packages, Dockerfile instructions, build-stage environment variables, and deployment variables that sync securely to Trigger.dev without container inclusion.

## Debugging Resources

Use `--log-level debug` flags during development and the `--dry-run` deployment option to inspect generated Containerfiles without actual deployment.
