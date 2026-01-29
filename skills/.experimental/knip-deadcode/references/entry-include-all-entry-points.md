---
title: Include All Application Entry Points
impact: CRITICAL
impactDescription: missing entries cause entire dependency trees to appear unused
tags: entry, configuration, false-positives, coverage
---

## Include All Application Entry Points

Include all entry points in your configuration: main files, CLI scripts, server files, and worker files. Missing entries cause cascading false positives.

**Incorrect (only main entry, CLI and workers unreachable):**

```json
{
  "entry": ["src/index.ts"]
}
```

**Correct (all entry points included):**

```json
{
  "entry": [
    "src/index.ts",
    "src/cli.ts",
    "src/server.ts",
    "src/worker.ts",
    "scripts/*.ts"
  ]
}
```

**Check package.json for entry points:**

```json
{
  "main": "dist/index.js",
  "bin": {
    "mycli": "dist/cli.js"
  },
  "exports": {
    ".": "./dist/index.js",
    "./server": "./dist/server.js"
  }
}
```

Knip reads these fields automatically, but custom scripts in `scripts/` need explicit configuration.

Reference: [Entry Files](https://knip.dev/explanations/entry-files)
