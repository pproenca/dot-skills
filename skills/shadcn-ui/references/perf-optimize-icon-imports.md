---
title: Optimize Icon Imports from Lucide
impact: MEDIUM
impactDescription: reduces bundle by 200-500KB with direct imports
tags: perf, icons, lucide, tree-shaking, imports
---

## Optimize Icon Imports from Lucide

Import Lucide icons directly from their paths or use Next.js optimizePackageImports to avoid loading the entire icon library.

**Incorrect (barrel import loads all icons):**

```tsx
import { Check, X, Menu, Settings, User, Bell } from "lucide-react"
// In dev mode: loads 1,500+ icons, adds ~2.8s to startup
// In production: tree-shaking may not fully eliminate unused icons
```

**Correct (direct imports):**

```tsx
import Check from "lucide-react/dist/esm/icons/check"
import X from "lucide-react/dist/esm/icons/x"
import Menu from "lucide-react/dist/esm/icons/menu"
import Settings from "lucide-react/dist/esm/icons/settings"
import User from "lucide-react/dist/esm/icons/user"
import Bell from "lucide-react/dist/esm/icons/bell"
// Loads only 6 icons (~2KB each)
```

**Alternative (Next.js 13.5+ optimizePackageImports):**

```js
// next.config.js
module.exports = {
  experimental: {
    optimizePackageImports: ["lucide-react"],
  },
}
```

```tsx
// Now barrel imports are automatically optimized
import { Check, X, Menu, Settings, User, Bell } from "lucide-react"
// Next.js transforms this to direct imports at build time
```

**Creating an icon wrapper for consistency:**

```tsx
// components/icons.tsx
export { default as CheckIcon } from "lucide-react/dist/esm/icons/check"
export { default as XIcon } from "lucide-react/dist/esm/icons/x"
export { default as MenuIcon } from "lucide-react/dist/esm/icons/menu"
export { default as SettingsIcon } from "lucide-react/dist/esm/icons/settings"
// Centralized icon exports with consistent naming
```

Reference: [Vercel Package Import Optimization](https://vercel.com/blog/how-we-optimized-package-imports-in-next-js)
