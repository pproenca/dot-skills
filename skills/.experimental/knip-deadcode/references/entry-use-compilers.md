---
title: Use Compilers for Non-Standard File Types
impact: CRITICAL
impactDescription: analyzes imports in Vue, Svelte, and other template files
tags: entry, compilers, vue, svelte, templates
---

## Use Compilers for Non-Standard File Types

Knip supports TypeScript and JavaScript by default. Use compilers for Vue SFCs, Svelte components, and other file types with embedded scripts.

**Incorrect (Vue files not analyzed, imports missed):**

```json
{
  "entry": ["src/main.ts"],
  "project": ["src/**/*.ts"]
}
```

Vue component imports not tracked.

**Correct (Vue plugin handles SFC compilation):**

```json
{
  "vue": true
}
```

The Vue plugin automatically compiles `.vue` files and extracts imports.

**Custom compiler for unsupported format:**

```typescript
// knip.config.ts
import type { KnipConfig } from 'knip'

const config: KnipConfig = {
  compilers: {
    mdx: (source) => {
      // Extract imports from MDX
      const imports = source.match(/import .+ from ['"].+['"]/g)
      return imports?.join('\n') ?? ''
    }
  }
}

export default config
```

**Built-in compiler support:**
- Vue (via plugin)
- Svelte (via plugin)
- Astro (via plugin)

Reference: [Knip Configuration](https://knip.dev/reference/configuration)
