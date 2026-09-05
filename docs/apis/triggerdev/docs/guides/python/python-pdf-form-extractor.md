---
source: https://trigger.dev/docs/guides/python/python-pdf-form-extractor
scraped: 2026-02-28
---

# Python PDF Form Extractor Example

## Overview

This documentation demonstrates how to build a PDF form data extraction system using Trigger.dev and Python. The example showcases integration of PyMuPDF for PDF processing and the Trigger.dev Python build extension.

## Key Components

**Prerequisites:**
- Initialized Trigger.dev project
- Python installed locally

**Main Technologies:**
- Trigger.dev task system
- PyMuPDF library for form extraction
- Requests library for downloading PDFs
- Python build extension for dependency management

## Configuration Setup

The `trigger.config.ts` file requires the Python extension configuration:

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

## Implementation

**Dependencies** (`requirements.txt`):
```txt
PyMuPDF==1.23.8
requests==2.31.0
```

**Task Handler** (`src/trigger/pythonPdfTask.ts`):
The task executes the Python script with a PDF URL parameter and parses the JSON output containing extracted form data.

**Python Script** (`src/python/extract-pdf-form.py`):
The script downloads PDFs from URLs, opens them with PyMuPDF, iterates through pages, and extracts form widget information including field names, types, and values.

## Testing Workflow

1. Create and activate Python virtual environment
2. Install dependencies via pip
3. Configure project reference in settings
4. Run development server via CLI
5. Test through dashboard with valid PDF URLs
6. Deploy using CLI deploy command

## Additional Resources

The Trigger.dev documentation provides detailed information about the Python build extension for dependency installation and script execution.
