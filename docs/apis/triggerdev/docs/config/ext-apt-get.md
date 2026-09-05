---
source: https://trigger.dev/docs/config/extensions/aptGet
scraped: 2026-02-28
---

# apt-get

## Overview

The `aptGet` build extension enables installation of system packages into your deployed image.

## Basic Usage

Install packages using the `aptGet` extension in your Trigger.dev configuration:

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { aptGet } from "@trigger.dev/build/extensions/core";

export default defineConfig({
  project: "<project ref>",
  // Your other config settings...
  build: {
    extensions: [aptGet({ packages: ["ffmpeg"] })],
  },
});
```

## Installing Specific Versions

To install a particular version of a package, specify the version string:

```ts
import { defineConfig } from "@trigger.dev/sdk";

export default defineConfig({
  project: "<project ref>",
  // Your other config settings...
  build: {
    extensions: [aptGet({ packages: ["ffmpeg=6.0-4"] })],
  },
});
```

Pass version information directly within the package string using the `package=version` format to control which release gets deployed.
