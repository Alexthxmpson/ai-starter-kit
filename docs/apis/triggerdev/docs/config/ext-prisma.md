---
source: https://trigger.dev/docs/config/extensions/prismaExtension
scraped: 2026-02-28
---

# Prisma

The `prismaExtension` supports multiple Prisma versions and deployment strategies through **three distinct modes** that handle the evolving Prisma ecosystem, from legacy setups to Prisma 7.

The `prismaExtension` requires an explicit `mode` parameter. All configurations must specify a mode.

## Migration from previous versions

### Before (pre 4.1.1)

```ts
import { prismaExtension } from "@trigger.dev/build/extensions/prisma";

extensions: [
  prismaExtension({
    schema: "prisma/schema.prisma",
    migrate: true,
    typedSql: true,
    directUrlEnvVarName: "DATABASE_URL_UNPOOLED",
  }),
];
```

### After (4.1.1+)

```ts
import { prismaExtension } from "@trigger.dev/build/extensions/prisma";

extensions: [
  prismaExtension({
    mode: "legacy", // MODE IS REQUIRED
    schema: "prisma/schema.prisma",
    migrate: true,
    typedSql: true,
    directUrlEnvVarName: "DATABASE_URL_UNPOOLED",
  }),
];
```

## Choosing the right mode

- **Prisma 7 or 6.20+ beta** → Modern Mode
- **Prisma 6.16+ with `engineType='client'`** → Modern Mode
- **Custom client output path, managing generate yourself** → Engine-only Mode
- **Everything else** → Legacy Mode

## Extension modes

### Legacy mode

**Use when:** You're using Prisma 6.x or earlier with the `prisma-client-js` provider.

**Features:**
- Automatic `prisma generate` during deployment
- Supports single-file schemas (`prisma/schema.prisma`)
- Supports multi-file schemas (Prisma 6.7+, directory-based schemas)
- Supports Prisma config files (`prisma.config.ts`) via `@prisma/config` package
- Migration support with `migrate: true`
- TypedSQL support with `typedSql: true`
- Custom generator selection
- Handles Prisma client versioning automatically

**Schema configuration:**

```prisma
generator client {
  provider        = "prisma-client-js"
  previewFeatures = ["typedSql"]
}

datasource db {
  provider  = "postgresql"
  url       = env("DATABASE_URL")
  directUrl = env("DATABASE_URL_UNPOOLED")
}
```

**Extension configuration:**

```ts
// Single-file schema
prismaExtension({
  mode: "legacy",
  schema: "prisma/schema.prisma",
  migrate: true,
  typedSql: true,
  directUrlEnvVarName: "DATABASE_URL_UNPOOLED",
});

// Multi-file schema (Prisma 6.7+)
prismaExtension({
  mode: "legacy",
  schema: "./prisma", // Point to directory
  migrate: true,
  typedSql: true,
  directUrlEnvVarName: "DATABASE_URL_UNPOOLED",
});
```

**Tested versions:** Prisma 6.14.0, Prisma 6.7.0+, Prisma 5.x

---

### Engine-only mode

**Use when:** You have a custom Prisma client output path and want to manage `prisma generate` yourself.

**Features:**
- Only installs Prisma engine binaries (no client generation)
- Automatic version detection from `@prisma/client`
- Manual override of version and binary target
- Minimal overhead — just ensures engines are available
- You control when and how `prisma generate` runs

**Schema configuration:**

```prisma
generator client {
  provider      = "prisma-client-js"
  output        = "../src/generated/prisma"
  binaryTargets = ["native", "debian-openssl-3.0.x"]
}

datasource db {
  provider  = "postgresql"
  url       = env("DATABASE_URL")
  directUrl = env("DATABASE_URL_UNPOOLED")
}
```

**Extension configuration:**

```ts
// Auto-detect version
prismaExtension({
  mode: "engine-only",
});

// Explicit version (recommended for reproducible builds)
prismaExtension({
  mode: "engine-only",
  version: "6.19.0",
});
```

**Important notes:**
- You **must** run `prisma generate` yourself (typically in a prebuild script)
- Your schema **must** include the correct `binaryTargets` for deployment. The binary target is `debian-openssl-3.0.x`.
- The extension sets `PRISMA_QUERY_ENGINE_LIBRARY` and `PRISMA_QUERY_ENGINE_SCHEMA_ENGINE` env vars

**package.json example:**

```json
{
  "scripts": {
    "prebuild": "prisma generate",
    "dev": "trigger dev",
    "deploy": "trigger deploy"
  }
}
```

**Tested versions:** Prisma 6.19.0, Prisma 6.16.0+

---

### Modern mode

**Use when:** You're using Prisma 6.16+ with the new `prisma-client` provider (with `engineType = "client"`) or preparing for Prisma 7.

**Features:**
- Designed for the new Prisma architecture
- Zero configuration required
- Automatically marks `@prisma/client` as external
- Works with Prisma 7 beta releases and Prisma 7 when released
- You manage client generation (like engine-only mode)

**Schema configuration (Prisma 6.16+ with engineType):**

```prisma
generator client {
  provider        = "prisma-client"
  output          = "../src/generated/prisma"
  engineType      = "client"
  previewFeatures = ["views"]
}

datasource db {
  provider  = "postgresql"
  url       = env("DATABASE_URL")
  directUrl = env("DATABASE_URL_UNPOOLED")
}
```

**Schema configuration (Prisma 7):**

```prisma
generator client {
  provider = "prisma-client"
  output   = "../src/generated/prisma"
}

datasource db {
  provider = "postgresql"
}
```

**Extension configuration:**

```ts
prismaExtension({
  mode: "modern",
});
```

**Important notes:**
- You **must** run `prisma generate` yourself
- Requires Prisma 6.16.0+ or Prisma 7 beta
- The new `prisma-client` provider generates plain TypeScript (no Rust binaries)
- Requires database adapters (e.g., `@prisma/adapter-pg` for PostgreSQL)

**Tested versions:** Prisma 6.16.0 with `engineType = "client"`, Prisma 6.20.0-integration-next.8 (Prisma 7 beta)

---

## Version compatibility matrix

| Prisma version | Recommended mode | Notes |
|---|---|---|
| < 5.0 | Legacy | Older Prisma versions |
| 5.0 - 6.15 | Legacy | Standard Prisma setup |
| 6.7+ | Legacy | Multi-file schema support |
| 6.16+ | Engine-only or Modern | Modern mode requires `engineType = "client"` |
| 6.20+ (7.0 beta) | Modern | Prisma 7 with new architecture |

---

## Prisma config file support

Legacy mode supports loading configuration from a `prisma.config.ts` file using the official `@prisma/config` package.

**prisma.config.ts:**

```ts
import { defineConfig, env } from "prisma/config";
import "dotenv/config";

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
  },
  datasource: {
    url: env("DATABASE_URL"),
    directUrl: env("DATABASE_URL_UNPOOLED"),
  },
});
```

**trigger.config.ts:**

```ts
import { prismaExtension } from "@trigger.dev/build/extensions/prisma";

prismaExtension({
  mode: "legacy",
  configFile: "./prisma.config.ts", // Use config file instead of schema
  migrate: true,
  directUrlEnvVarName: "DATABASE_URL_UNPOOLED",
});
```

Note: Either `schema` or `configFile` must be specified, but not both.

---

## Multi-file schema support

Prisma 6.7 introduced support for splitting your schema across multiple files.

**Configuration:**

```ts
prismaExtension({
  mode: "legacy",
  schema: "./prisma", // Point to directory instead of file
  migrate: true,
  typedSql: true,
});
```

**package.json:**

```json
{
  "prisma": {
    "schema": "./prisma"
  }
}
```

---

## TypedSQL support

TypedSQL is available in legacy mode for Prisma 5.19.0+ with the `typedSql` preview feature.

**Extension configuration:**

```ts
prismaExtension({
  mode: "legacy",
  schema: "prisma/schema.prisma",
  typedSql: true,
});
```

---

## Database migration support

Migrations are supported in legacy mode only.

```ts
prismaExtension({
  mode: "legacy",
  schema: "prisma/schema.prisma",
  migrate: true,
  directUrlEnvVarName: "DATABASE_URL_UNPOOLED",
});
```

What this does:
1. Copies `prisma/migrations/` to the build output
2. Runs `prisma migrate deploy` before generating the client
3. Uses the `directUrlEnvVarName` for unpooled connections (required for migrations)

---

## Binary targets and deployment

### Trigger.dev Cloud

Default binary target is `debian-openssl-3.0.x`.

- **Legacy mode:** Handled automatically
- **Engine-only mode:** Specify in schema: `binaryTargets = ["native", "debian-openssl-3.0.x"]`
- **Modern mode:** Handled by database adapters

### Self-hosted / local deployment

```ts
prismaExtension({
  mode: "engine-only",
  version: "6.19.0",
  binaryTarget: "linux-arm64-openssl-3.0.x", // For macOS ARM64
});
```

---

## Environment variables

### Required variables

- `DATABASE_URL`: Your database connection string
- `DATABASE_URL_UNPOOLED` (or your custom `directUrlEnvVarName`): Direct database connection for migrations (legacy mode with migrations)

### Auto-set variables (engine-only mode)

- `PRISMA_QUERY_ENGINE_LIBRARY`: Path to the query engine
- `PRISMA_QUERY_ENGINE_SCHEMA_ENGINE`: Path to the schema engine

---

## Troubleshooting

### "Could not find Prisma schema"

```ts
prismaExtension({
  mode: "legacy",
  schema: "./prisma/schema.prisma", // Correct relative path
});
```

### "Could not determine @prisma/client version"

Specify the version explicitly:

```ts
prismaExtension({
  mode: "legacy",
  schema: "prisma/schema.prisma",
  version: "6.19.0",
});
```

### Debug logging

```bash
npx trigger.dev@latest deploy --log-level debug
```

Grep for `[PrismaExtension]` in build logs for detailed information.

---

## Complete examples

### Example 1: Standard Prisma 6 setup (legacy mode)

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { prismaExtension } from "@trigger.dev/build/extensions/prisma";

export default defineConfig({
  project: process.env.TRIGGER_PROJECT_REF!,
  build: {
    extensions: [
      prismaExtension({
        mode: "legacy",
        schema: "prisma/schema.prisma",
        migrate: true,
        typedSql: true,
        directUrlEnvVarName: "DATABASE_URL_UNPOOLED",
      }),
    ],
  },
});
```

### Example 2: Custom output path (engine-only mode)

```ts
prismaExtension({
  mode: "engine-only",
  version: "6.19.0",
  binaryTarget: "linux-arm64-openssl-3.0.x",
});
```

### Example 3: Prisma 7 beta (modern mode)

```ts
prismaExtension({
  mode: "modern",
});
```

---

## Resources

- [Prisma Documentation](https://www.prisma.io/docs)
- [Multi-File Schema (Prisma 6.7+)](https://www.prisma.io/docs/orm/prisma-schema/overview/location#multi-file-prisma-schema)
- [TypedSQL (Prisma 5.19+)](https://www.prisma.io/docs/orm/prisma-client/using-raw-sql/typedsql)
- [Prisma 7 Beta Documentation](https://www.prisma.io/docs)
