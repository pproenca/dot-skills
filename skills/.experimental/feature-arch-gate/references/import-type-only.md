---
title: Use Type-Only Imports for Types
impact: MEDIUM
impactDescription: Enables cross-feature type sharing without runtime coupling
tags: import, types, typescript, type-only
---

## Use Type-Only Imports for Types

Use `import type` syntax when importing only TypeScript types. This ensures types are stripped at compile time and allows sharing types across features without creating runtime dependencies.

**Incorrect (mixing type and value imports):**

```typescript
// src/features/checkout/components/CheckoutForm.tsx
import { User, useUser } from '@/features/user';  // Creates runtime dependency for type

export function CheckoutForm({ userId }: { userId: string }) {
  // We only need the User type, not useUser
  const [user, setUser] = useState<User | null>(null);
}
```

**Correct (separate type imports):**

```typescript
// src/features/checkout/components/CheckoutForm.tsx
import type { User } from '@/features/user';  // Type-only, no runtime dependency

export function CheckoutForm({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);
}
```

**Shared types for cross-feature contracts:**

```typescript
// src/shared/types/entities.ts
export interface User {
  id: string;
  email: string;
  name: string;
}

export interface Product {
  id: string;
  name: string;
  price: number;
}

// Features import shared types
// src/features/checkout/types.ts
import type { User, Product } from '@/shared/types/entities';

export interface CheckoutItem {
  product: Product;
  quantity: number;
}

export interface CheckoutSession {
  user: User;
  items: CheckoutItem[];
}
```

**Benefits:**
- No runtime bundle impact for type-only imports
- Clear distinction between runtime and compile-time dependencies
- Enables type sharing without architectural coupling

**TypeScript configuration:**

```json
{
  "compilerOptions": {
    "verbatimModuleSyntax": true  // Enforces type-only imports
  }
}
```

Reference: [TypeScript Handbook - Type-Only Imports](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-8.html#type-only-imports-and-export)
