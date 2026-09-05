---
source: https://trigger.dev/docs/config/extensions/pythonExtension
scraped: 2026-02-28
---

# Python Support in Trigger.dev

## Overview

Trigger.dev provides a Python build extension that enables execution of Python scripts within projects. To get started, install the `@trigger.dev/python` package:

```bash
npm add @trigger.dev/python
```

## Configuration

Add the `pythonExtension` to your `trigger.config.ts`:

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { pythonExtension } from "@trigger.dev/python/extension";

export default defineConfig({
  project: "<project ref>",
  build: {
    extensions: [pythonExtension()],
  },
});
```

## Running Python Code

### Inline Execution

Execute Python code directly within tasks:

```ts
import { task } from "@trigger.dev/sdk";
import { python } from "@trigger.dev/python";

export const myScript = task({
  id: "my-python-script",
  run: async () => {
    const result = await python.runInline(`print("Hello, world!")`);
    return result.stdout;
  },
});
```

### Script Files

Configure scripts to be automatically copied during deployment:

```ts
pythonExtension({
  scripts: ["./python/**/*.py"],
})
```

Then execute them in tasks:

```ts
const result = await python.runScript("./python/my_script.py", ["hello", "world"]);
```

## Dependencies Management

Use a `requirements.txt` file for package dependencies (production only):

```ts
pythonExtension({
  requirementsFile: "./requirements.txt",
})
```

## Development Configuration

Specify a virtual environment Python binary for development:

```ts
pythonExtension({
  devPythonBinaryPath: ".venv/bin/python",
})
```

## Advanced Features

### Streaming Output

Stream results as scripts execute:

```ts
const result = python.stream.runScript("./python/my_script.py", ["hello", "world"]);

for await (const chunk of result) {
  console.log(chunk);
}
```

### Environment Variables

Pass environment variables to scripts:

```ts
await python.runScript("./python/my_script.py", ["hello", "world"], {
  env: {
    MY_ENV_VAR: "my value",
  },
});
```

Scripts can access variables through Python's `os.environ` dictionary.
