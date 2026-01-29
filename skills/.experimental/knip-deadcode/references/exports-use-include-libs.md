---
title: Use Include Libs for Type-Based Consumption
impact: MEDIUM-HIGH
impactDescription: catches exports consumed via types in external code
tags: exports, types, libs, detection
---

## Use Include Libs for Type-Based Consumption

External libraries may consume your exports through type definitions. Use `--include-libs` to analyze external library types and detect these usages.

**Incorrect (type-consumed exports appear unused):**

```typescript
// src/plugin.ts
export interface PluginConfig {
  name: string
  version: string
}

export const definePlugin = (config: PluginConfig) => config
```

External library uses `PluginConfig` type but Knip reports it unused.

**Correct (include external library types):**

```bash
knip --include-libs
```

Now Knip analyzes type definitions from `node_modules` and detects `PluginConfig` usage.

**Performance note:** This flag adds significant memory usage and processing time. Use sparingly for specific investigations:

```bash
# Trace specific export first
knip --trace-export PluginConfig

# If truly unused, it won't be found
# If used in libs, --include-libs reveals it
```

Reference: [Unused Exports](https://knip.dev/typescript/unused-exports)
