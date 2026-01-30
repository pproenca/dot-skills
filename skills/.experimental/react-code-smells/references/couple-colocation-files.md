---
title: Colocate Related Files by Feature
impact: HIGH
impactDescription: reduces navigation by 70%, makes features self-contained
tags: couple, colocation, file-structure, feature-folders, organization
---

## Colocate Related Files by Feature

Organizing by file type (components/, hooks/, styles/) separates related code. Organize by feature to keep related files together.

**Code Smell Indicators:**
- Changing one feature requires edits in 5+ directories
- Related files have duplicated names (UserCard.tsx, UserCard.css, UserCard.test.tsx in different dirs)
- Hard to know which files belong to which feature
- Deleting a feature requires hunting across directories

**Incorrect (organized by type):**

```
src/
├── components/
│   ├── UserCard.tsx
│   ├── UserList.tsx
│   ├── ProductCard.tsx
│   └── ProductList.tsx
├── hooks/
│   ├── useUser.ts
│   ├── useUsers.ts
│   ├── useProduct.ts
│   └── useProducts.ts
├── styles/
│   ├── UserCard.css
│   ├── UserList.css
│   ├── ProductCard.css
│   └── ProductList.css
├── tests/
│   ├── UserCard.test.tsx
│   ├── useUser.test.ts
│   └── ...
└── types/
    ├── user.ts
    └── product.ts

// To understand "users" feature, look in 5 directories
// To delete "products", hunt through every directory
```

**Correct (organized by feature):**

```
src/
├── features/
│   ├── users/
│   │   ├── index.ts          # Public exports
│   │   ├── UserCard.tsx
│   │   ├── UserCard.css
│   │   ├── UserCard.test.tsx
│   │   ├── UserList.tsx
│   │   ├── useUser.ts
│   │   ├── useUsers.ts
│   │   ├── types.ts
│   │   └── api.ts
│   │
│   └── products/
│       ├── index.ts
│       ├── ProductCard.tsx
│       ├── ProductCard.css
│       ├── ProductCard.test.tsx
│       ├── ProductList.tsx
│       ├── useProduct.ts
│       └── types.ts
│
├── shared/                    # Truly shared code
│   ├── components/
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   └── Button.css
│   │   └── Card/
│   ├── hooks/
│   │   ├── useDebounce.ts
│   │   └── useLocalStorage.ts
│   └── utils/
│
└── app/                       # App shell, routing
    ├── layout.tsx
    └── routes.tsx

// To understand "users", look in one directory
// To delete "products", delete one directory
```

**Index file for public API:**

```tsx
// features/users/index.ts
export { UserCard } from './UserCard'
export { UserList } from './UserList'
export { useUser, useUsers } from './hooks'
export type { User, UserRole } from './types'

// Other features import from index
import { UserCard, useUser } from '@/features/users'
```

**What goes in shared vs feature:**

| Shared | Feature |
|--------|---------|
| Used by 3+ features | Used by 1-2 features |
| Generic (Button, useDebounce) | Domain-specific |
| No business logic | Contains business logic |

**Migration strategy:**
1. Create feature folder for one feature
2. Move related files into it
3. Update imports
4. Add index.ts for public API
5. Repeat for next feature
6. Move remaining shared code to shared/

Reference: [Screaming Architecture](https://blog.cleancoder.com/uncle-bob/2011/09/30/Screaming-Architecture.html)
