---
title: Use Consistent Path Aliases
impact: HIGH
impactDescription: Eliminates ../../../ chains; makes imports self-documenting
tags: import, aliases, paths, navigation
---

## Use Consistent Path Aliases

Configure path aliases to avoid relative import chains. Aliases make imports self-documenting by showing feature ownership clearly and survive file relocations within the same feature.

**Incorrect (deep relative paths):**

```typescript
// src/features/checkout/components/PaymentForm.tsx
import { Button } from '../../../shared/components/Button';
import { useAuth } from '../../../features/auth/hooks/useAuth';  // Also wrong: cross-feature
import { formatCurrency } from '../../../shared/utils/formatCurrency';
import { useCheckout } from '../hooks/useCheckout';
```

**Correct (path aliases):**

```typescript
// src/features/checkout/components/PaymentForm.tsx
import { Button } from '@/shared/components/Button';
import { formatCurrency } from '@/shared/utils/formatCurrency';
import { useCheckout } from '../hooks/useCheckout';  // Same feature = relative OK
```

**tsconfig.json:**

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@/shared/*": ["src/shared/*"],
      "@/features/*": ["src/features/*"],
      "@/app/*": ["src/app/*"]
    }
  }
}
```

**Guidelines:**
- Use `@/` prefix for absolute imports from src
- Use relative imports (`./`, `../`) within the same feature
- Relative imports within a feature make the feature more portable

**Vite configuration:**

```typescript
// vite.config.ts
export default defineConfig({
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});
```

Reference: [Robin Wieruch - React Folder Structure](https://www.robinwieruch.de/react-folder-structure/)
