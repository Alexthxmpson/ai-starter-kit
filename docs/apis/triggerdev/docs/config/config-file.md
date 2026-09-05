---
source: https://trigger.dev/docs/config/config-file
scraped: 2026-02-28
---

# The trigger.config.ts File

## Overview

The `trigger.config.ts` file configures your Trigger.dev project. It's a TypeScript file at the project root that exports a default configuration object using the `defineConfig` function.

## Core Configuration Options

### Project Reference
```ts
export default defineConfig({
  project: "<project ref>",
});
```

### Task Directories
Specify where your trigger tasks are located:
```ts
dirs: ["./trigger"],
```

You can also customize which files to ignore:
```ts
ignorePatterns: ["**/*.my-test.ts"],
```

### TypeScript Configuration
Point to a custom tsconfig file:
```ts
tsconfig: "./custom-tsconfig.json",
```

## Retry Settings

Configure default retry behavior for tasks:
```ts
retries: {
  enabledInDev: false,
  default: {
    maxAttempts: 3,
    minTimeoutInMs: 1000,
    maxTimeoutInMs: 10000,
    factor: 2,
    randomize: true,
  },
}
```

## Lifecycle Functions

Add global handlers for task execution events:
```ts
onStart: async ({ payload, ctx }) => { },
onSuccess: async ({ payload, output, ctx }) => { },
onFailure: async ({ payload, error, ctx }) => { },
init: async ({ payload, ctx }) => { },
```

## Telemetry Configuration

### Instrumentations

Add OpenTelemetry instrumentations for automatic logging:
```ts
telemetry: {
  instrumentations: [
    new PrismaInstrumentation(),
    new OpenAIInstrumentation(),
  ],
}
```

Recommended packages include:
- `@opentelemetry/instrumentation-http` (HTTP calls)
- `@prisma/instrumentation` (Prisma calls)
- `@traceloop/instrumentation-openai` (OpenAI calls)

### Telemetry Exporters

Send traces, logs, and metrics to external services:
```ts
telemetry: {
  logExporters: [
    new OTLPLogExporter({ url: "...", headers: { } }),
  ],
  exporters: [
    new OTLPTraceExporter({ url: "...", headers: { } }),
  ],
  metricExporters: [
    new OTLPMetricExporter({ url: "...", headers: { } }),
  ],
}
```

Avoid using `OTEL_*` environment variables, as they conflict with internal telemetry.

## Runtime Configuration

### Runtime Selection
```ts
runtime: "node", // or "node-22" or "bun"
```

### Supported Versions (v4)
- Node.js 21.7.3 (default)
- Node.js 22.16.0
- Bun 1.3.3

## Task Execution Settings

### Default Machine
```ts
defaultMachine: "large-1x",
```

### Maximum Duration
```ts
maxDuration: 60, // seconds
```

### Process Keep-Alive
Keep the process alive between executions:
```ts
processKeepAlive: {
  enabled: true,
  maxExecutionsPerProcess: 50,
  devMaxPoolSize: 25,
}
```

## Logging

### Log Level
```ts
logLevel: "debug",
```

Note: This controls logs sent via the `logger` API. Console logs are always sent.

### Console Logging
```ts
enableConsoleLogging: true,
disableConsoleInterceptor: false,
```

## Development Behavior

Control working directory behavior:
```ts
legacyDevProcessCwdBehaviour: false, // Default: true
```

When false, the working directory matches production behavior.

## Security

Add CA certificates for self-signed certs:
```ts
extraCACerts: "./certs/ca.crt", // Must start with "./"
```

## Build Configuration

Customize the bundling process:
```ts
build: {
  external: ["header-generator"],
  autoDetectExternal: true,
  keepNames: true,
  minify: false,
}
```

### External Dependencies

Exclude packages from bundling:
```ts
build: {
  external: ["ai"],
}
```

WASM packages and native binaries must be externalized, including `re2`, `sharp`, `sqlite3`, and similar packages.

### JSX Configuration
```ts
build: {
  jsx: {
    fragment: "Fragment",
    factory: "h",
    automatic: false,
  },
}
```

By default, automatic JSX runtime is enabled.

### Import Conditions
```ts
build: {
  conditions: ["react-server"],
}
```

### Build Extensions

Pre-built extensions available through `@trigger.dev/build`:
- `additionalFiles`
- `additionalPackages`
- `emitDecoratorMetadata`
- `prismaExtension`
- `syncEnvVars`
- `puppeteer`
- `ffmpeg`
- `esbuildPlugin`
- `aptGet`

## Important Notes

- The config file is bundled with your project, affecting build times and cold start duration
- Code in the `build` configuration is automatically stripped from the bundled file
- Imports used only in `build` config are tree-shaken out
- Console logs are always sent regardless of `logLevel` setting
- Process keep-alive provides no guarantees about process longevity
