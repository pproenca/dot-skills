---
title: Use Consistent File Naming Conventions
impact: LOW
impactDescription: Enables pattern-based tooling; reduces cognitive load
tags: name, files, conventions, consistency
---

## Use Consistent File Naming Conventions

Establish and follow consistent file naming patterns. This enables automated tooling, makes files predictable, and reduces decision fatigue.

**Incorrect (inconsistent naming):**

```
src/features/user/
├── components/
│   ├── UserProfile.tsx      # PascalCase
│   ├── user-avatar.tsx      # kebab-case
│   ├── userBadge.tsx        # camelCase
│   └── User_Settings.tsx    # Snake_Case
├── hooks/
│   ├── useUser.ts           # camelCase
│   └── use-auth.ts          # kebab-case
└── api/
    ├── getUser.ts           # camelCase
    └── user-api.ts          # kebab-case
```

**Correct (consistent conventions):**

```
src/features/user/
├── components/
│   ├── UserProfile.tsx      # PascalCase for components
│   ├── UserAvatar.tsx
│   ├── UserBadge.tsx
│   └── UserSettings.tsx
├── hooks/
│   ├── useUser.ts           # camelCase with use prefix
│   └── useUserAuth.ts
├── api/
│   ├── get-user.ts          # kebab-case for non-components
│   ├── update-user.ts
│   └── delete-user.ts
├── stores/
│   └── user-store.ts        # kebab-case
├── types/
│   └── index.ts
└── utils/
    └── format-user-name.ts  # kebab-case
```

**Recommended conventions:**

| File Type | Convention | Example |
|-----------|------------|---------|
| React components | PascalCase | `UserProfile.tsx` |
| Hooks | camelCase with use prefix | `useUser.ts` |
| API functions | kebab-case | `get-user.ts` |
| Stores | kebab-case | `user-store.ts` |
| Utilities | kebab-case | `format-date.ts` |
| Types | index.ts or kebab-case | `types/index.ts` |
| Tests | match source + .test | `UserProfile.test.tsx` |

**ESLint enforcement:**

```javascript
// .eslintrc.js
rules: {
  'unicorn/filename-case': ['error', {
    cases: {
      pascalCase: true,  // For .tsx files
      kebabCase: true,   // For .ts files
    },
  }],
}
```

Reference: [Airbnb React Style Guide](https://github.com/airbnb/javascript/tree/master/react)
