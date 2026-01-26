---
title: Configure Path Aliases for Clean Imports
impact: MEDIUM-HIGH
impactDescription: eliminates brittle relative paths, simplifies refactoring
tags: import, aliases, paths, configuration
---

## Configure Path Aliases for Clean Imports

Path aliases eliminate long relative imports and make refactoring easier. Configure them in both Vite and TypeScript for consistency.

**Incorrect (fragile relative paths):**

```typescript
// Deep component importing from utils
import { formatDate } from '../../../utils/date'
import { useAuth } from '../../../hooks/useAuth'
import { Button } from '../../../components/Button'
// Breaks when files move
// Hard to read, error-prone
```

**Correct (stable path aliases):**

```typescript
import { formatDate } from '@/utils/date'
import { useAuth } from '@/hooks/useAuth'
import { Button } from '@/components/Button'
// Clear, consistent, refactor-friendly
```

**Vite configuration:**

```javascript
// vite.config.js
import { resolve } from 'path'

export default defineConfig({
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
      '@components': resolve(__dirname, './src/components'),
      '@utils': resolve(__dirname, './src/utils')
    }
  }
})
```

**TypeScript configuration:**

```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@utils/*": ["./src/utils/*"]
    }
  }
}
```

**Benefits:**
- Cleaner imports
- Easier refactoring
- Better IDE support

Reference: [Configuring Vite](https://vite.dev/config/)
