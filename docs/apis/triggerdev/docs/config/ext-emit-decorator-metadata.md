---
source: https://trigger.dev/docs/config/extensions/emitDecoratorMetadata
scraped: 2026-02-28
---

# Emit Decorator Metadata

The `emitDecoratorMetadata` build extension enables support for TypeScript's `emitDecoratorMetadata` compiler option in Trigger.dev projects.

## Setup

To use this extension, import it from the build extensions and configure it in your `trigger.config.ts`:

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { emitDecoratorMetadata } from "@trigger.dev/build/extensions/typescript";

export default defineConfig({
  project: "<project ref>",
  // Your other config settings...
  build: {
    extensions: [emitDecoratorMetadata()],
  },
});
```

## Use Cases

This extension is particularly useful when working with "ORMs that require this option to be enabled" such as TypeORM. It remains disabled by default due to associated performance considerations.

## Technical Details

The extension integrates with the esbuild bundling process, leveraging the TypeScript compiler API to compile files containing decorators. Two requirements must be met:

- `emitDecoratorMetadata` must be enabled in your `tsconfig.json` file
- TypeScript must be installed in your `devDependencies`
