---
title: Migrate Ad-Hoc Styles to Tokens Incrementally
impact: MEDIUM
impactDescription: prevents a big-bang refactor that stalls feature work
tags: govern, migration, refactor, incremental
---

## Migrate Ad-Hoc Styles to Tokens Incrementally

A single pull request that rewrites every screen to tokens conflicts with every in-flight branch and is too large to review, so it sits open for weeks and blocks adoption. Migrating one surface per pull request behind a lint ratchet keeps the codebase shippable while the system spreads.

**Incorrect (one giant rewrite all at once):**

```typescript
// PR #482 "Adopt design tokens" — touches 137 files in a single commit
// - rewrites every StyleSheet across billing, scheduling, notes, and charts
// - conflicts with all six in-flight feature branches
// - too large to review, so it stays open for weeks and blocks token adoption
```

**Correct (one surface per PR behind a lint ratchet):**

```typescript
// 1. Add the token ESLint rules as "warn", so nothing breaks today.
// 2. Migrate one feature per PR: scheduling first, then notes, then charts.
const styles = StyleSheet.create((theme) => ({
  slot: { padding: theme.space.sm, backgroundColor: theme.colors.surface }, // migrated
}))
// 3. Flip the rule to "error" for a directory once it is clean, locking in the gain.
```

Reference: [Unistyles configuration](https://www.unistyl.es/v3/start/configuration/)
