---
title: Enable strict Flags One at a Time, Not All at Once
impact: CRITICAL
impactDescription: reduces error floods to fixable batches
tags: strict, ratcheting, tsconfig, incremental
---

## Enable strict Flags One at a Time, Not All at Once

Flipping `"strict": true` on a freshly migrated JavaScript codebase turns on eight checks simultaneously and surfaces thousands of errors at once — far too many to fix in one reviewable change. Enabling a single flag, fixing its errors, and committing converts an unbounded backlog into a sequence of bounded, reviewable batches that keep `main` green throughout.

**Incorrect (full strict at once — thousands of errors in one branch):**

```json
{
  "compilerOptions": {
    "allowJs": true,
    "strict": true
  }
}
```

`strict` enables eight flags together. On a 50k-line migration this can be
3,000+ errors in a single branch that is impossible to review or merge.

**Correct (ratchet one flag per change):**

```json
{
  "compilerOptions": {
    "allowJs": true,
    "noImplicitAny": true,
    "strictNullChecks": false
  }
}
```

Land `noImplicitAny` as its own PR, then flip `strictNullChecks`, then the
remaining flags — each a bounded batch. Once all are on, replace them with
`"strict": true` and delete the individual entries.

Reference: [tsconfig: strict](https://www.typescriptlang.org/tsconfig/#strict)
