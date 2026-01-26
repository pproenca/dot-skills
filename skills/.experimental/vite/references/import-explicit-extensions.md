---
title: Use Explicit File Extensions in Imports
impact: HIGH
impactDescription: reduces filesystem checks per import
tags: import, extensions, resolve, performance
---

## Use Explicit File Extensions in Imports

Omitting extensions forces Vite to check multiple possibilities (.ts, .tsx, .js, .jsx, etc.) for every import. Explicit extensions eliminate these lookups.

**Incorrect (multiple filesystem checks):**

```typescript
// Vite checks: Component.ts, Component.tsx, Component.js, Component.jsx, Component/index.ts...
import { Button } from './components/Button'
import { useAuth } from './hooks/useAuth'
import { formatDate } from './utils/date'
```

**Correct (single filesystem check):**

```typescript
import { Button } from './components/Button.tsx'
import { useAuth } from './hooks/useAuth.ts'
import { formatDate } from './utils/date.ts'
```

**Enable TypeScript support:**

```json
// tsconfig.json
{
  "compilerOptions": {
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true
  }
}
```

**Narrow resolve.extensions:**

```javascript
// vite.config.js
export default defineConfig({
  resolve: {
    extensions: ['.ts', '.tsx']  // Only check these
  }
})
```

**Tradeoff:** Explicit extensions are less portable but faster. Use for internal imports; external packages handle their own resolution.

Reference: [Performance | Vite](https://vite.dev/guide/performance)
