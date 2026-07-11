---
title: Use Consistent File Naming Conventions
impact: LOW
impactDescription: Enables pattern-based tooling; reduces cognitive load
tags: name, files, conventions, consistency
---

## Use Consistent File Naming Conventions

Default to kebab-case for every file and folder name — components included. Kebab-case survives case-insensitive filesystems (macOS/Windows git rename bugs), matches Next.js route segments, and removes the "which casing does this file use?" decision entirely. The component itself stays PascalCase; only the filename is kebab-case.

**Incorrect (mixed casing per file type):**

```text
src/features/user/
├── components/
│   ├── UserProfile.tsx      # PascalCase
│   ├── user-avatar.tsx      # kebab-case
│   └── userBadge.tsx        # camelCase
├── hooks/
│   ├── useUser.ts           # camelCase
│   └── use-auth.ts          # kebab-case
└── api/
    ├── getUser.ts           # camelCase
    └── user-api.ts          # kebab-case
```

**Correct (kebab-case throughout):**

```text
src/features/user/
├── components/
│   ├── user-profile.tsx     # exports UserProfile
│   ├── user-avatar.tsx      # exports UserAvatar
│   └── user-settings.tsx    # exports UserSettings
├── hooks/
│   ├── use-user.ts          # exports useUser
│   └── use-user-auth.ts
├── queries/
│   ├── get-user.ts          # get- prefix for reads
│   └── get-users.ts
├── actions/
│   ├── update-user-action.ts   # -action suffix for server actions
│   └── delete-user-action.ts
├── stores/
│   └── user-store.ts
├── types.ts
└── utils/
    └── format-user-name.ts
```

**Recommended conventions:**

| File Type | Convention | Example |
|-----------|------------|---------|
| React components | kebab-case, PascalCase export | `user-profile.tsx` → `UserProfile` |
| Hooks | kebab-case with use- prefix | `use-user.ts` → `useUser` |
| Queries (reads) | kebab-case with get- prefix | `get-user.ts` |
| Server actions | kebab-case with -action suffix | `update-user-action.ts` |
| Stores | kebab-case with -store suffix | `user-store.ts` |
| Utilities | kebab-case | `format-date.ts` |
| Tests | match source + .test | `user-profile.test.tsx` |

**Acceptable alternative:** PascalCase filenames for component files (`UserProfile.tsx`) remain a widespread house convention. If the codebase already uses it, keep it — consistency beats migration churn. Do not mix both in one project.

**ESLint enforcement:**

```javascript
// .eslintrc.js
rules: {
  'unicorn/filename-case': ['error', {
    case: 'kebabCase',
  }],
}
```

Reference: [Robin Wieruch - React Folder Structure](https://www.robinwieruch.de/react-folder-structure/)
