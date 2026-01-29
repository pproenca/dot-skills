---
title: Include Binary Scripts as Entry Points
impact: CRITICAL
impactDescription: prevents CLI tools from appearing unused
tags: entry, bin, scripts, cli
---

## Include Binary Scripts as Entry Points

Binary scripts in package.json `bin` field are entry points. Knip reads these automatically, but verify they're detected and add custom scripts explicitly.

**Incorrect (custom scripts not in bin, appear unused):**

```json
{
  "entry": ["src/index.ts"]
}
```

```text
// scripts/migrate.ts is reported as unused
```

**Correct (scripts added as entries):**

```json
{
  "entry": [
    "src/index.ts",
    "scripts/*.ts",
    "bin/*.js"
  ]
}
```

**Verify package.json bin is detected:**

```json
{
  "bin": {
    "mycli": "./dist/cli.js",
    "migrate": "./dist/migrate.js"
  }
}
```

Knip automatically includes files from `bin`. If source files are in `src/`, ensure the entry points to source:

```json
{
  "entry": ["src/cli.ts", "src/migrate.ts"]
}
```

Reference: [Entry Files](https://knip.dev/explanations/entry-files)
