---
title: Choose Output Mode Based on API Size
impact: CRITICAL
impactDescription: 2-5× bundle size difference, affects tree-shaking
tags: orvalcfg, mode, bundle, tree-shaking
---

## Choose Output Mode Based on API Size

Select the appropriate output mode based on your API size. Wrong choices cause bundle bloat or unnecessary complexity.

**Incorrect (single mode for large API):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    input: './openapi.yaml',  // 200+ endpoints
    output: {
      target: 'src/api.ts',
      mode: 'single',  // Everything in one massive file
    },
  },
});
```

**Problem:** Single 50KB+ file imported everywhere, no tree-shaking possible.

**Correct (tags-split for large APIs):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    input: './openapi.yaml',
    output: {
      target: 'src/api',
      schemas: 'src/api/models',
      mode: 'tags-split',  // Separate folders per tag
      client: 'react-query',
    },
  },
});
```

**Mode selection guide:**

| API Size | Endpoints | Recommended Mode |
|----------|-----------|------------------|
| Small | 1-20 | `single` or `split` |
| Medium | 20-100 | `split` or `tags` |
| Large | 100+ | `tags-split` |

**Benefits of `tags-split`:**
- Each tag becomes its own folder
- Unused endpoints are tree-shaken
- Imports are more explicit: `import { useGetUser } from '@/api/users'`

Reference: [Orval Output Modes](https://orval.dev/reference/configuration/output)
