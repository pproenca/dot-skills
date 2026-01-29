---
title: Enable Framework Plugins Explicitly
impact: CRITICAL
impactDescription: detects framework-specific entry points automatically
tags: config, plugins, frameworks, detection
---

## Enable Framework Plugins Explicitly

Knip auto-detects many plugins, but explicit configuration ensures correct entry points for your framework and prevents missed dead code.

**Incorrect (relying on auto-detection, missing custom config paths):**

```json
{
  "entry": ["src/index.ts"]
}
```

**Correct (explicit plugin configuration):**

```json
{
  "next": {
    "entry": ["pages/**/*.tsx", "app/**/*.tsx", "middleware.ts"]
  },
  "jest": {
    "config": "jest.config.ts",
    "entry": ["**/*.test.ts", "**/*.spec.ts"]
  },
  "storybook": {
    "entry": [".storybook/main.ts", "**/*.stories.tsx"]
  }
}
```

**Disable unused plugins:**

```json
{
  "webpack": false,
  "rollup": false
}
```

Reference: [Knip Plugins](https://knip.dev/reference/plugins)
