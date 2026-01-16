---
title: Colocate Styles with Components
impact: MEDIUM
impactDescription: Enables complete component portability; prevents orphaned styles
tags: comp, styles, colocation, css
---

## Colocate Styles with Components

Keep component styles in the same location as the component. When styles are centralized or in a global stylesheet, components lose independence and style changes become risky.

**Incorrect (centralized styles):**

```
src/
├── styles/
│   ├── components/
│   │   ├── UserCard.css
│   │   ├── PostList.css
│   │   └── CommentSection.css
│   └── global.css
└── features/
    └── user/
        └── components/
            └── UserCard.tsx  # Imports from ../../styles/components/
```

**Correct (colocated styles):**

```
src/features/user/
├── components/
│   ├── UserCard.tsx
│   ├── UserCard.module.css   # CSS Modules
│   └── UserAvatar.tsx
└── ...
```

```typescript
// src/features/user/components/UserCard.tsx
import styles from './UserCard.module.css';

export function UserCard({ user }: { user: User }) {
  return (
    <div className={styles.card}>
      <UserAvatar user={user} className={styles.avatar} />
      <h2 className={styles.name}>{user.name}</h2>
    </div>
  );
}
```

**With Tailwind (styles in component):**

```typescript
// src/features/user/components/UserCard.tsx
export function UserCard({ user }: { user: User }) {
  return (
    <div className="rounded-lg border bg-white p-4 shadow-sm">
      <UserAvatar user={user} className="h-12 w-12 rounded-full" />
      <h2 className="mt-2 text-lg font-semibold">{user.name}</h2>
    </div>
  );
}
```

**Shared styles belong in shared:**

```
src/shared/
├── styles/
│   ├── reset.css         # Global reset
│   └── variables.css     # Design tokens
└── components/
    ├── Button/
    │   ├── Button.tsx
    │   └── Button.module.css
    └── Input/
        ├── Input.tsx
        └── Input.module.css
```

**Benefits:**
- Moving a component moves its styles
- Deleting a component deletes its styles
- No orphaned CSS

Reference: [CSS Modules Documentation](https://github.com/css-modules/css-modules)
