---
source: https://trigger.dev/docs/guides/python/python-doc-to-markdown
scraped: 2026-02-28
---

# Convert Documents to Markdown Using Python and MarkItDown

## Overview

This guide demonstrates how to leverage Trigger.dev with Python to transform documents into markdown format using Microsoft's MarkItDown library, which proves valuable for structuring documents for AI applications.

## Prerequisites

- A Trigger.dev project that has been initialized
- Python 3.10 or higher installed locally

## Key Features

The implementation includes:

- A Trigger.dev task that retrieves documents from URLs and executes a Python conversion script
- A Python script utilizing Microsoft's MarkItDown library for document transformation
- Integration with Trigger.dev's Python build extension for dependency management and script execution

## GitHub Repository

The complete project code is available on GitHub at the examples repository, ready to fork and adapt for your needs.

## Implementation Details

### Build Configuration

Update your `trigger.config.ts` file with the Python extension settings:

```ts
import { pythonExtension } from "@trigger.dev/python/extension";
import { defineConfig } from "@trigger.dev/sdk";

export default defineConfig({
  runtime: "node",
  project: "<your-project-ref>",
  build: {
    extensions: [
      pythonExtension({
        requirementsFile: "./requirements.txt",
        devPythonBinaryPath: `venv/bin/python`,
        scripts: ["src/python/**/*.py"],
      }),
    ],
  },
});
```

### Task Implementation

```ts
import { task } from "@trigger.dev/sdk";
import { python } from "@trigger.dev/python";
import * as fs from "fs";
import * as path from "path";
import * as os from "os";

export const convertToMarkdown = task({
  id: "convert-to-markdown",
  run: async (payload: { url: string }) => {
    const { url } = payload;

    const tempDir = os.tmpdir();
    const fileName = `doc-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`;
    const urlPath = new URL(url).pathname;
    const extension = path.extname(urlPath) || ".docx";
    const tempFilePath = path.join(tempDir, `${fileName}${extension}`);

    const response = await fetch(url);
    const buffer = await response.arrayBuffer();
    await fs.promises.writeFile(tempFilePath, Buffer.from(buffer));

    const pythonResult = await python.runScript("./src/python/markdown-converter.py", [
      JSON.stringify({ file_path: tempFilePath }),
    ]);

    fs.unlink(tempFilePath, () => {});

    if (pythonResult.stdout) {
      const result = JSON.parse(pythonResult.stdout);
      return {
        url,
        markdown: result.status === "success" ? result.markdown : null,
        error: result.status === "error" ? result.error : null,
        success: result.status === "success",
      };
    }

    return {
      url,
      markdown: null,
      error: "No output from Python script",
      success: false,
    };
  },
});
```

### Dependencies

Include this in your `requirements.txt`:

```txt
markitdown[all]
```

### Python Script

```python
import json
import sys
import os
from markitdown import MarkItDown

def convert_to_markdown(file_path):
    """Convert a file to markdown format using MarkItDown"""
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"File not found: {file_path}")

    md = MarkItDown()

    try:
        result = md.convert(file_path)
        return result.text_content
    except Exception as e:
        raise Exception(f"Error converting file: {str(e)}")

def process_trigger_task(file_path):
    """Process a file and convert to markdown"""
    try:
        markdown_result = convert_to_markdown(file_path)
        return {
            "status": "success",
            "markdown": markdown_result
        }
    except Exception as e:
        return {
            "status": "error",
            "error": str(e)
        }

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(json.dumps({"status": "error", "error": "No file path provided"}))
        sys.exit(1)

    try:
        config = json.loads(sys.argv[1])
        file_path = config.get("file_path")

        if not file_path:
            print(json.dumps({"status": "error", "error": "No file path specified in config"}))
            sys.exit(1)

        result = process_trigger_task(file_path)
        print(json.dumps(result))
    except Exception as e:
        print(json.dumps({"status": "error", "error": str(e)}))
        sys.exit(1)
```

## Testing Steps

1. Create a virtual environment with `python -m venv venv`
2. Activate the environment (Mac/Linux: `source venv/bin/activate` | Windows: `venv\Scripts\activate`)
3. Install dependencies using `pip install -r requirements.txt`
4. Add your project reference from the Trigger.dev dashboard to `trigger.config.ts`
5. Run the CLI development command
6. Test through the dashboard using a valid document URL
7. Deploy to production with the CLI deploy command

## MarkItDown Capabilities

The library supports conversion of:

- Office formats (Word, PowerPoint, Excel)
- PDF documents
- Images with optional LLM-generated descriptions
- HTML, CSV, JSON, and XML files
- Audio files with optional transcription
- ZIP archives

It preserves document structure including headings, lists, and tables while supporting multiple input methods.
