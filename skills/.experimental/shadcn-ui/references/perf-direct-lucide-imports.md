---
title: Import Lucide Icons Directly from Path
impact: LOW-MEDIUM
impactDescription: 200-500ms faster dev server, smaller production bundles
tags: perf, lucide, icons, imports, tree-shaking
---

## Import Lucide Icons Directly from Path

Import icons from their direct path instead of the barrel export. The barrel file imports all 1500+ icons, slowing builds and increasing bundle size.

**Incorrect (barrel import):**

```tsx
import { Check, X, Menu, Search, User, Settings } from "lucide-react"
// Imports entire lucide-react barrel file
// Dev: ~800ms slower, Production: larger bundle if tree-shaking fails
```

**Correct (direct path imports):**

```tsx
import Check from "lucide-react/dist/esm/icons/check"
import X from "lucide-react/dist/esm/icons/x"
import Menu from "lucide-react/dist/esm/icons/menu"
import Search from "lucide-react/dist/esm/icons/search"
import User from "lucide-react/dist/esm/icons/user"
import Settings from "lucide-react/dist/esm/icons/settings"
// Each icon is a separate module, only loads what's needed
```

**Alternative (Next.js 13.5+ optimizePackageImports):**

```javascript
// next.config.js
module.exports = {
  experimental: {
    optimizePackageImports: ["lucide-react"],
  },
}
```

Then use normal imports:
```tsx
import { Check, X, Menu } from "lucide-react"
// Next.js automatically transforms to direct imports
```

Reference: [Vercel Blog - Optimizing Package Imports](https://vercel.com/blog/how-we-optimized-package-imports-in-next-js)
