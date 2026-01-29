---
title: Run Without Config First for Baseline
impact: CRITICAL
impactDescription: establishes baseline before customization
tags: config, baseline, initial, setup
---

## Run Without Config First for Baseline

Run Knip without configuration first to see what it detects automatically. This establishes a baseline before adding custom configuration.

**Incorrect (over-configuring immediately):**

```json
{
  "entry": ["src/**/*.ts"],
  "project": ["src/**/*.ts"],
  "ignore": ["src/legacy/**"],
  "ignoreDependencies": ["lodash", "react"]
}
```

**Correct (baseline first, then configure):**

```bash
# Step 1: Run without config
npx knip

# Step 2: Observe auto-detected plugins
# "Enabled plugins: next, jest, eslint"

# Step 3: Note false positives
# Check if they're config issues or real unused code

# Step 4: Add minimal configuration only for actual issues
```

```json
{
  "$schema": "https://unpkg.com/knip@5/schema.json"
}
```

**Use debug to see what Knip detects:**

```bash
knip --debug
```

Shows: enabled plugins, detected entries, workspace configs.

Reference: [Configuration](https://knip.dev/reference/configuration)
