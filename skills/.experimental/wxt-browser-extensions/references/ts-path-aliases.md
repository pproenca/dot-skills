---
title: Use Path Aliases for Clean Imports
impact: LOW-MEDIUM
impactDescription: prevents broken imports during file refactoring
tags: ts, imports, paths, aliases, refactoring
---

## Use Path Aliases for Clean Imports

Configure path aliases to avoid deep relative imports. This improves readability and makes moving files safer during refactoring.

**Incorrect (deep relative imports):**

```typescript
// entrypoints/popup/components/Settings.tsx
import { storage } from '../../../utils/storage'
import { formatDate } from '../../../utils/dates'
import type { Settings } from '../../../types/settings'
import { useSettings } from '../../../hooks/useSettings'
// Hard to read, breaks when files move
```

**Correct (path aliases):**

```typescript
// wxt.config.ts
export default defineConfig({
  alias: {
    '@': resolve(__dirname, './'),
    '@/utils': resolve(__dirname, './utils'),
    '@/types': resolve(__dirname, './types'),
    '@/hooks': resolve(__dirname, './hooks'),
    '@/components': resolve(__dirname, './components')
  }
})

// tsconfig.json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./*"],
      "@/utils/*": ["./utils/*"],
      "@/types/*": ["./types/*"],
      "@/hooks/*": ["./hooks/*"],
      "@/components/*": ["./components/*"]
    }
  }
}

// entrypoints/popup/components/Settings.tsx
import { storage } from '@/utils/storage'
import { formatDate } from '@/utils/dates'
import type { Settings } from '@/types/settings'
import { useSettings } from '@/hooks/useSettings'
// Clean, consistent, refactor-safe
```

**WXT default alias:**

```typescript
// WXT provides '@' alias by default pointing to project root
import { settings } from '@/utils/storage'
```

Reference: [WXT Configuration - Alias](https://wxt.dev/guide/essentials/config/build#alias)
