---
title: Tokenize Corner Radius by Component Role
impact: MEDIUM
impactDescription: prevents inconsistent rounding across surfaces
tags: space, radius, tokens, shape
---

## Tokenize Corner Radius by Component Role

When each surface picks its own `borderRadius`, cards, sheets, buttons, and inputs end up with four unrelated radii and the UI feels subtly off without anyone able to say why. Radius tokens keyed by role collapse those into a small, intentional set that every surface shares.

**Incorrect (assorted radii per component):**

```typescript
const styles = StyleSheet.create(() => ({
  card: { borderRadius: 12 },
  sheet: { borderRadius: 16 },
  button: { borderRadius: 10 },
  input: { borderRadius: 8 },
}))
// Four surfaces, four unrelated radii — the UI looks slightly inconsistent.
```

**Correct (radius tokens by role):**

```typescript
// theme.ts
radius: { sm: 8, md: 12, lg: 20, pill: 999 }

const styles = StyleSheet.create((theme) => ({
  card: { borderRadius: theme.radius.md },
  sheet: { borderRadius: theme.radius.lg },
  button: { borderRadius: theme.radius.md },
  chip: { borderRadius: theme.radius.pill },
}))
// Surfaces share a small set of radii, so rounding reads as intentional.
```

Reference: [Unistyles theming](https://www.unistyl.es/v3/guides/theming/)
