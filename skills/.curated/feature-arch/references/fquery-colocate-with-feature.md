---
title: Colocate Data Fetching with Features
impact: HIGH
impactDescription: Makes features self-contained; enables independent API evolution
tags: fquery, colocation, data-fetching, feature
---

## Colocate Data Fetching with Features

Data fetching logic belongs within the feature that owns the data. When API calls are scattered in a central api/ folder, features lose independence and changes require coordinating across multiple locations.

**Incorrect (centralized API layer):**

```text
src/
├── api/
│   ├── users.ts         # All user API calls
│   ├── posts.ts         # All post API calls
│   ├── comments.ts      # All comment API calls
│   └── orders.ts        # All order API calls
└── features/
    ├── user/
    │   └── components/  # Components import from ../../../api/users
    └── post/
        └── components/  # Components import from ../../../api/posts
```

**Correct (colocated with features):**

```text
src/features/
├── user/
│   ├── api/
│   │   ├── get-user.ts
│   │   ├── update-user.ts
│   │   └── delete-user.ts
│   ├── components/
│   │   └── UserProfile.tsx
│   └── hooks/
│       └── use-user.ts
└── post/
    ├── api/
    │   ├── get-post.ts
    │   ├── get-posts.ts
    │   └── create-post.ts
    ├── components/
    │   └── PostList.tsx
    └── hooks/
        └── use-posts.ts
```

```typescript
// src/features/user/hooks/use-user.ts
import { getUser } from '../api/get-user';

export function useUser(userId: string) {
  return useQuery({
    queryKey: ['user', userId],
    queryFn: () => getUser(userId),
  });
}
```

**Benefits:**
- Adding a feature includes its API calls
- Removing a feature removes its API calls
- Feature can evolve its API independently
- Related code is always together

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)
