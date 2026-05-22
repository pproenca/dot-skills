---
title: Avoid Raw Color and Size Literals in Components
impact: CRITICAL
impactDescription: eliminates ungoverned values that drift across screens
tags: token, colors, lint, consistency
---

## Avoid Raw Color and Size Literals in Components

Hex strings and off-scale numbers written directly in component styles are invisible to the token system — they cannot be themed, audited, or changed in one place. Routing every value through theme tokens lets a single edit update all usages and lets a lint rule reject literals before they merge.

**Incorrect (hex strings and off-scale numbers in the component):**

```typescript
const styles = StyleSheet.create(() => ({
  vitalsRow: {
    backgroundColor: '#F1F5F9',        // ungoverned hex, invisible to dark mode
    padding: 13,                       // off-scale number nobody else uses
    borderRadius: 7,
    borderColor: 'rgba(0,0,0,0.08)',   // hardcoded alpha breaks in dark theme
  },
}))
```

**Correct (theme tokens only):**

```typescript
const styles = StyleSheet.create((theme) => ({
  vitalsRow: {
    backgroundColor: theme.colors.surfaceMuted,
    padding: theme.space.md,
    borderRadius: theme.radius.sm,
    borderColor: theme.colors.border,
  },
}))
// Every value resolves through the theme, so the dark theme overrides them all
// and an ESLint rule can ban color-literal strings inside feature files.
```

**When NOT to use this pattern:**

- The token definition files themselves — the raw palette and the Unistyles theme — necessarily hold literal hex and numbers; that is where they are sanctioned. The ban applies to component and feature code.

Reference: [Unistyles theming](https://www.unistyl.es/v3/guides/theming/)
