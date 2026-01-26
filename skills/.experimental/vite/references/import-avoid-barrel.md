---
title: Avoid Barrel File Imports
impact: HIGH
impactDescription: prevents loading 100s of unused modules
tags: import, barrel-files, tree-shaking, performance
---

## Avoid Barrel File Imports

Barrel files (index.js re-exports) force Vite to load all modules even when you need just one. Import directly from source files.

**Incorrect (loads entire library):**

```javascript
// Barrel file loads all 600+ lodash functions
import { debounce } from 'lodash-es'

// Icon library loads all icons
import { IconCheck } from '@tabler/icons-react'

// Your own barrel file
import { Button } from '@/components'
// components/index.ts re-exports 50 components
```

**Correct (direct imports):**

```javascript
// Import specific module
import debounce from 'lodash-es/debounce'

// Direct icon import
import { IconCheck } from '@tabler/icons-react/dist/esm/icons/IconCheck'

// Direct component import
import { Button } from '@/components/Button'
```

**For icon libraries, configure optimizePackageImports:**

```javascript
// vite.config.js
export default defineConfig({
  // Experimental - auto-transforms barrel imports
  experimental: {
    optimizePackageImports: ['@tabler/icons-react', 'lucide-react']
  }
})
```

**In your own codebase:**
- Avoid creating index.ts barrel files
- Import components directly by path
- Use path aliases for cleaner imports

Reference: [Performance | Vite](https://vite.dev/guide/performance)
