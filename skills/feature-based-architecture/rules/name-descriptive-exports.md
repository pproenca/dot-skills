---
title: Use Descriptive Export Names
impact: LOW
impactDescription: Enables IDE autocomplete; makes imports self-documenting
tags: name, exports, descriptive, clarity
---

## Use Descriptive Export Names

Export names should be descriptive and unique across the codebase. Generic names like `Card`, `List`, or `Button` cause confusion when multiple features export similar components.

**Incorrect (generic export names):**

```typescript
// src/features/user/components/Card.tsx
export function Card({ user }) { ... }  // Which card?

// src/features/product/components/Card.tsx
export function Card({ product }) { ... }  // Collision!

// Import confusion
import { Card } from '@/features/user';    // UserCard? ProductCard?
import { Card as ProductCard } from '@/features/product';  // Requires alias
```

**Correct (descriptive export names):**

```typescript
// src/features/user/components/UserCard.tsx
export function UserCard({ user }: { user: User }) { ... }

// src/features/product/components/ProductCard.tsx
export function ProductCard({ product }: { product: Product }) { ... }

// Clear imports
import { UserCard } from '@/features/user';
import { ProductCard } from '@/features/product';
```

**Naming patterns:**

| Type | Pattern | Example |
|------|---------|---------|
| Feature component | `{Feature}{Component}` | `UserProfile`, `CartSummary` |
| Feature hook | `use{Feature}{Action}` | `useUserAuth`, `useCartItems` |
| Feature API | `{action}{Feature}` | `getUser`, `updateCart` |
| Feature store | `use{Feature}Store` | `useCartStore`, `useUserStore` |

**Exception for shared components:**

```typescript
// Shared components can use generic names - they're not feature-specific
// src/shared/components/Button.tsx
export function Button({ children, ...props }) { ... }

// src/shared/components/Card.tsx
export function Card({ children, ...props }) { ... }
```

**Benefits:**
- IDE autocomplete shows meaningful options
- Imports are self-documenting
- No aliasing required

Reference: [React Naming Conventions](https://react.dev/learn/thinking-in-react)
