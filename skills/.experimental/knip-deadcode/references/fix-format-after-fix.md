---
title: Format Code After Auto-Fix
impact: MEDIUM
impactDescription: maintains consistent code style after removals
tags: fix, format, prettier, style
---

## Format Code After Auto-Fix

Run your code formatter after Knip auto-fix to clean up formatting artifacts. Use `--format` for automatic formatting.

**Incorrect (unformatted code after removal):**

```bash
knip --fix
# Leaves trailing commas, inconsistent spacing
```

```typescript
// Before fix
export { used, unused, another } from './utils'

// After fix (unformatted)
export { used,  another } from './utils'
//          ^^ extra space
```

**Correct (auto-format after fix):**

```bash
knip --fix --format
```

Or format manually:

```bash
knip --fix
npx prettier --write .
# or
npm run format
```

**Supported formatters:**
- Prettier (detected automatically)
- Biome
- dprint
- deno fmt

**Configuration for specific formatter:**

```bash
KNIP_FORMATTER=biome knip --fix --format
```

Reference: [Auto-fix](https://knip.dev/features/auto-fix)
