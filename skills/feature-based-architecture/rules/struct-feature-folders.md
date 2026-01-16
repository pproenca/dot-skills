---
title: Organize by Feature, Not Technical Type
impact: CRITICAL
impactDescription: Eliminates cross-file navigation; reduces onboarding time by 50%+
tags: struct, organization, feature-folders, scalability
---

## Organize by Feature, Not Technical Type

Technical grouping (components/, hooks/, utils/) forces developers to navigate multiple directories for single features. Feature-based organization colocates all related code, making features self-documenting and independently deployable.

**Incorrect (technical grouping):**

```
src/
├── components/
│   ├── PostCard.tsx
│   ├── CommentList.tsx
│   └── UserAvatar.tsx
├── hooks/
│   ├── usePost.ts
│   ├── useComments.ts
│   └── useUser.ts
├── api/
│   ├── posts.ts
│   ├── comments.ts
│   └── users.ts
└── utils/
    ├── postHelpers.ts
    └── commentHelpers.ts
```

**Correct (feature-based grouping):**

```
src/
├── features/
│   ├── post/
│   │   ├── components/
│   │   │   └── PostCard.tsx
│   │   ├── hooks/
│   │   │   └── usePost.ts
│   │   ├── api/
│   │   │   └── get-post.ts
│   │   └── utils/
│   │       └── postHelpers.ts
│   ├── comment/
│   │   ├── components/
│   │   │   └── CommentList.tsx
│   │   ├── hooks/
│   │   │   └── useComments.ts
│   │   └── api/
│   │       └── get-comments.ts
│   └── user/
│       ├── components/
│       │   └── UserAvatar.tsx
│       └── hooks/
│           └── useUser.ts
└── shared/
    └── components/
        └── Button.tsx
```

**Benefits:**
- Adding a feature = adding one folder
- Removing a feature = removing one folder
- Feature ownership is immediately clear
- Teams can work on different features without conflicts

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)
