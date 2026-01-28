---
title: Use Direct Imports for Icon Libraries
impact: MEDIUM-HIGH
impactDescription: reduces icon imports from 2MB+ to 10KB
tags: bundle, icons, tree-shaking, lucide, heroicons
---

## Use Direct Imports for Icon Libraries

Icon libraries like Lucide, Heroicons, and FontAwesome contain thousands of icons. Import individual icons directly instead of from barrel files.

**Incorrect (imports entire icon library):**

```typescript
// Imports all 1,500+ icons (2MB+)
import { Check, X, Menu } from 'lucide-react'
```

**Correct (direct icon imports):**

```typescript
// Imports only 3 icons (~6KB)
import Check from 'lucide-react/dist/esm/icons/check'
import X from 'lucide-react/dist/esm/icons/x'
import Menu from 'lucide-react/dist/esm/icons/menu'
```

**Alternative (unplugin-icons for automatic tree-shaking):**

```typescript
// wxt.config.ts
import Icons from 'unplugin-icons/vite'

export default defineConfig({
  vite: () => ({
    plugins: [
      Icons({
        compiler: 'jsx', // or 'vue3', 'svelte'
        autoInstall: true
      })
    ]
  })
})

// Usage - automatic tree-shaking
import IconCheck from '~icons/lucide/check'
import IconMenu from '~icons/lucide/menu'
```

**Icon library sizes (full vs tree-shaken):**
| Library | Full | Per Icon |
|---------|------|----------|
| Lucide | 2MB+ | ~2KB |
| Heroicons | 1.5MB | ~1KB |
| FontAwesome | 3MB+ | ~3KB |

Reference: [unplugin-icons](https://github.com/unplugin/unplugin-icons)
