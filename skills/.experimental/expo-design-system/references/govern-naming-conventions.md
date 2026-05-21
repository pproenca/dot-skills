---
title: Enforce One Naming Convention for Tokens and Components
impact: MEDIUM
impactDescription: reduces ambiguity and guesswork when looking up tokens
tags: govern, naming, conventions, consistency
---

## Enforce One Naming Convention for Tokens and Components

When tokens mix PascalCase, snake_case, and abbreviated prefixes in one map, every lookup becomes guesswork and autocomplete stops helping. A single convention — role-first camelCase — makes related tokens cluster predictably (`surface`, `surfaceMuted`, `surfaceAlert`) so the right name is obvious.

**Incorrect (three conventions in one token map):**

```typescript
const lightTheme = {
  colors: {
    Accent: '#0F766E',         // PascalCase
    text_primary: '#111827',   // snake_case
    bgSurface: '#FFFFFF',      // abbreviated, prefix-first
  },
}
// Three conventions in one map; looking up a token name is guesswork.
```

**Correct (role-first camelCase everywhere):**

```typescript
const lightTheme = {
  colors: {
    accent: '#0F766E',
    textPrimary: '#111827',
    surface: '#FFFFFF',
    surfaceMuted: '#F9FAFB',
    surfaceAlert: '#FEF2F2',
  },
}
// Role-first camelCase clusters related tokens, so surfaceMuted is easy to predict.
```

Reference: [Unistyles theming](https://www.unistyl.es/v3/guides/theming/)
