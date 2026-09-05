---
source: https://trigger.dev/docs/troubleshooting-debugging-in-vscode
scraped: 2026-02-28
---

# Debugging in VS Code

The documentation provides guidance for debugging task code in development mode using VS Code without additional flags.

## Setup Instructions

To enable debugging, create a launch configuration file at `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Trigger.dev: Dev",
      "type": "node",
      "request": "launch",
      "cwd": "${workspaceFolder}",
      "runtimeExecutable": "npx",
      "runtimeArgs": ["trigger.dev@latest", "dev"],
      "skipFiles": ["<node_internals>/**"],
      "sourceMaps": true
    }
  ]
}
```

## Starting the Debugger

Once configured, open VS Code's debug panel and select the "Trigger.dev: Dev" configuration to begin. You can then set breakpoints in your tasks code as needed for troubleshooting.
