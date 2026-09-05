---
source: https://trigger.dev/docs/troubleshooting
scraped: 2026-02-28
---

# Common Problems - Trigger.dev Documentation

## Development Issues

### NPM Permission Errors
If you encounter `EACCES: permission denied` errors during npm operations, start by clearing the cache:

```sh
npm cache clean --force
```

If that doesn't resolve it, update npm folder permissions:

```sh
sudo chown -R $(whoami) ~/.npm
```

### Build Cache Issues
Stop your local development server, locate and delete the hidden `.trigger` folder in your project, then restart the server.

### Yarn Plug'n'Play Conflicts
When using Yarn v1.22 or other package managers, check for a `.pnp.cjs` file in your home directory. This legacy configuration file can cause import resolution errors. Remove it to fix the issue.

## Deployment Problems

### Getting Debug Information
Run `trigger.dev deploy` with the `--log-level debug` flag for detailed build information. Use `--dry-run` to build without deploying.

### Docker Configuration Issues
After uninstalling Docker Desktop, the system may reference old credential stores. Remove or update `~/.docker/config.json` to resolve credential errors.

### Native Module Bundling
`.node` files (native code) cannot be bundled. Add affected packages to the `build.external` array in `trigger.config.ts`:

```ts
export default defineConfig({
  build: {
    external: ["your-node-package"],
  },
});
```

### Resource Exhaustion
If deployment hits infrastructure limits, try the native builder option available in Trigger.dev.

### Module-Specific Errors

**Pino logger issues:**
Add pino packages to `external` build settings.

**React-email conflicts:**
```ts
build: {
  external: ["react", "react-dom", "@react-email/render", "@react-email/components"],
}
```

**Bun runtime indexing:**
Use pnpm patch on the `source-map` package as a temporary workaround.

### Node.js and Corepack Compatibility
With Node.js v22, either downgrade to v20 LTS or install the latest corepack globally: `npm i -g corepack@latest`

## Project Setup Requirements

Supported Node.js versions require these minimum releases:
- Version 18: 18.20+
- Version 20: 20.5+
- Version 21: 21.0+
- Version 22: 22.0+

## Runtime Configuration

### Environment Variables
Since task code runs separately, configure environment variables through the Trigger.dev dashboard.

### Prisma Integration
Prisma requires code generation before tasks execute. Configure this using the Prisma extension guide.

### Database Connectivity
Currently only IPv4 connections are supported. IPv6 addresses require workarounds.

## Task Execution Constraints

### Parallel Wait Limitations
The system does not support multiple concurrent waits. These operations include `wait.for()`, `wait.until()`, `task.triggerAndWait()`, and `task.batchTriggerAndWait()`. Use built-in batch functions instead of `Promise.all()`.

### Subtask Triggering
Always use `await` with trigger functions to ensure subtasks execute before parent task completion.

### Import Requirements
Use top-level imports for child tasks rather than dynamic imports:

```ts
import { myChildTask } from "~/trigger/my-child-task";

export const myTask = task({
  id: "my-task",
  run: async (payload: string) => {
    await myChildTask.trigger({ payload: "data" });
  },
});
```

### Rate Limiting
Replace task loop triggering with `batchTrigger()` (supports up to 1,000 tasks per call with SDK 4.3.1+).

### Queue Management
Monitor `QUEUED` runs by checking concurrency usage in the dashboard. Increase concurrency limits or adjust individual queue settings if needed.

### Event Loop Blocking
Infinite loops or CPU-intensive operations cause heartbeat failures. Use `heartbeats.yield()` periodically:

```ts
import { heartbeats } from "@trigger.dev/sdk";

for (const row of bigDataset) {
  await heartbeats.yield();
  process(row);
}
```

**Prisma 7.x note:** Query compilation can block the event loop during heavy database work in loops.

### Crypto Support
Plain string idempotency keys require Node v19.0.0+. Use `idempotencyKeys.create()` as an alternative.

## Framework-Specific Solutions

**NestJS:** Global exception filters swallow errors. Avoid using NestJS inside task implementations.

**React:** Either import React or update tsconfig to use `"jsx": "react-jsx"`.

**Next.js CI builds:** Mark routes as dynamic with `export const dynamic = "force-dynamic"` to prevent static compilation issues.

**Event handlers:** Wrap function calls in arrow functions: `<Button onClick={() => myTask()}>` instead of `<Button onClick={myTask()}>`.
