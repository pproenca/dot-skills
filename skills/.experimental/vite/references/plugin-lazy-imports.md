---
title: Use Dynamic Imports in Plugin Code
impact: CRITICAL
impactDescription: reduces Node.js startup time by 50%+
tags: plugin, dynamic-import, startup, performance
---

## Use Dynamic Imports in Plugin Code

Large dependencies used only in certain plugin hooks should be dynamically imported. Top-level imports slow down Node.js startup for every dev server start.

**Incorrect (eager loading blocks startup):**

```javascript
// my-vite-plugin.js
import { parse } from 'heavy-parser'      // 500ms import
import { transform } from 'big-transformer' // 300ms import

export function myPlugin() {
  return {
    name: 'my-plugin',
    transform(code, id) {
      if (!id.endsWith('.special')) return
      return transform(parse(code))
    }
  }
}
// Startup blocked by 800ms even if .special files are rare
```

**Correct (lazy loading on demand):**

```javascript
// my-vite-plugin.js
export function myPlugin() {
  return {
    name: 'my-plugin',
    async transform(code, id) {
      if (!id.endsWith('.special')) return

      const { parse } = await import('heavy-parser')
      const { transform } = await import('big-transformer')
      return transform(parse(code))
    }
  }
}
// Only loads when .special files are processed
```

Reference: [Performance | Vite](https://vite.dev/guide/performance)
