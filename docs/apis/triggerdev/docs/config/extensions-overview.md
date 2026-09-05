---
source: https://trigger.dev/docs/config/extensions/overview
scraped: 2026-02-28
---

# Build Extensions Documentation

Build extensions enable customization of the Trigger.dev build and deployment process through hooks into the build system.

## Configuration

Extensions are configured in `trigger.config.ts` under the `build.extensions` property. You can either create custom extensions or import pre-built ones from `@trigger.dev/build`.

## Available Built-in Extensions

Trigger.dev offers these ready-to-use extensions:

| Extension | Purpose |
|-----------|---------|
| prismaExtension | Prisma integration for tasks |
| pythonExtension | Execute Python scripts |
| puppeteer | Puppeteer browser automation |
| ffmpeg | FFmpeg multimedia processing |
| aptGet | System package installation |
| additionalFiles | Copy extra files to build |
| additionalPackages | Install npm packages |
| syncEnvVars | External service environment sync |
| syncVercelEnvVars | Vercel environment variable sync |
| esbuildPlugin | Custom esbuild configuration |
| emitDecoratorMetadata | TypeScript decorator metadata |
| audioWaveform | Audio waveform processing |

## Custom Extensions

For needs beyond built-in options, you can develop your own extension following the custom build extensions guide.
