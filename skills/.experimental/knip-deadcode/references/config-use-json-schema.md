---
title: Use JSON Schema for Configuration Validation
impact: CRITICAL
impactDescription: prevents configuration errors before runtime
tags: config, schema, validation, json
---

## Use JSON Schema for Configuration Validation

Add JSON schema to your knip.json for IDE autocompletion and instant validation of configuration options.

**Incorrect (no validation, typos undetected):**

```json
{
  "enrty": ["src/index.ts"],
  "projetc": ["src/**/*.ts"]
}
```

**Correct (schema validates configuration):**

```json
{
  "$schema": "https://unpkg.com/knip@5/schema.json",
  "entry": ["src/index.ts"],
  "project": ["src/**/*.ts"]
}
```

**Alternative (JSONC with comments):**

```jsonc
{
  "$schema": "https://unpkg.com/knip@5/schema-jsonc.json",
  // Entry points for analysis
  "entry": ["src/index.ts"],
  "project": ["src/**/*.ts"]
}
```

Reference: [Knip Configuration](https://knip.dev/reference/configuration)
