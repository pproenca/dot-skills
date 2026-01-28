---
title: Set RSC Flag Based on Framework Support
impact: HIGH
impactDescription: prevents client/server component mismatch errors
tags: setup, rsc, react-server-components, nextjs, configuration
---

## Set RSC Flag Based on Framework Support

The `rsc` flag in components.json determines whether components include the "use client" directive. Incorrect settings cause hydration errors or missing interactivity.

**Incorrect (RSC enabled for non-RSC framework):**

```json
// components.json for Vite project
{
  "rsc": true
}
```

```typescript
// Generated button.tsx
"use client"  // Unnecessary directive, Vite doesn't support RSC

export function Button() { ... }
```

**Correct (RSC disabled for Vite/CRA):**

```json
// components.json for Vite project
{
  "rsc": false
}
```

```typescript
// Generated button.tsx - no directive needed
export function Button() { ... }
```

**Correct (RSC enabled for Next.js App Router):**

```json
// components.json for Next.js
{
  "rsc": true
}
```

```typescript
// Generated button.tsx
"use client"  // Required for interactive components in Next.js App Router

export function Button() { ... }
```

| Framework | RSC Setting |
|-----------|-------------|
| Next.js App Router | `true` |
| Next.js Pages Router | `false` |
| Vite | `false` |
| Remix | `false` |

Reference: [shadcn/ui components.json](https://ui.shadcn.com/docs/components-json)
