---
title: Use a Spacing Scale Instead of Ad-Hoc Numbers
impact: HIGH
impactDescription: eliminates ad-hoc padding values across screens
tags: space, spacing, scale, tokens
---

## Use a Spacing Scale Instead of Ad-Hoc Numbers

Padding and margin values like 9, 13, and 18 appear once and nowhere else, so the layout has no shared rhythm and small inconsistencies accumulate. A spacing scale on a consistent grid (4pt) gives every gap a named step, so spacing reads as deliberate and a reviewer can spot an off-scale value instantly.

**Incorrect (one-off spacing values):**

```typescript
const styles = StyleSheet.create(() => ({
  panel: { padding: 12, marginBottom: 18, gap: 9 },
  header: { marginTop: 13 },
}))
// Values like 9, 13, 18 appear nowhere else; layout rhythm is accidental.
```

**Correct (a spacing scale on a 4pt grid):**

```typescript
// theme.ts
space: { xs: 4, sm: 8, md: 16, lg: 24, xl: 32 }

const styles = StyleSheet.create((theme) => ({
  panel: { padding: theme.space.md, marginBottom: theme.space.lg, gap: theme.space.sm },
  header: { marginTop: theme.space.md },
}))
// Every gap is a step on the scale, so screens share a consistent rhythm.
```

Reference: [Unistyles theming](https://www.unistyl.es/v3/guides/theming/)
