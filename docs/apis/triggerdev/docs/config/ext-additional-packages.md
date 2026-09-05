---
source: https://trigger.dev/docs/config/extensions/additionalPackages
scraped: 2026-02-28
---

# Additional Packages

## Overview

The `additionalPackages` build extension enables inclusion of extra packages in your build that aren't automatically detected through imports.

## Basic Usage

Import and configure the extension in your `trigger.config.ts`:

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { additionalPackages } from "@trigger.dev/build/extensions/core";

export default defineConfig({
  project: "<project ref>",
  // Your other config settings...
  build: {
    extensions: [additionalPackages({ packages: ["wrangler"] })],
  },
});
```

## Specifying Package Versions

You can optionally specify explicit versions using the `@` symbol:

```ts
import { defineConfig } from "@trigger.dev/sdk";

export default defineConfig({
  project: "<project ref>",
  // Your other config settings...
  build: {
    extensions: [additionalPackages({ packages: ["wrangler@1.19.0"] })],
  },
});
```

The system attempts automatic version resolution when no version is specified.

## Behavior

This extension "does not do anything in `dev` mode, but it will install the packages in the build directory when you run `deploy`." Packages are installed in the `node_modules` directory within your build directory.

## Use Cases

This is particularly useful for including CLI tools that you want to invoke within tasks using `exec`.
