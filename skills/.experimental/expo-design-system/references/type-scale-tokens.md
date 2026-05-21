---
title: Define a Typography Scale as Named Tokens
impact: HIGH
impactDescription: prevents arbitrary fontSize values across screens
tags: type, typography, scale, tokens
---

## Define a Typography Scale as Named Tokens

When each screen picks its own `fontSize` and `fontWeight`, two headings end up a point and a weight apart and the visual hierarchy reads as noise. A named type scale (title, body, caption) bundles size, line height, and weight so every heading is literally the same token.

**Incorrect (arbitrary font sizes per screen):**

```typescript
<Text style={{ fontSize: 22, fontWeight: '600' }}>Patient overview</Text>
// elsewhere, a near-identical heading drifts
<Text style={{ fontSize: 21, fontWeight: '700' }}>Patient overview</Text>
// Two "headings" differ by a point and a weight; hierarchy is inconsistent.
```

**Correct (named type tokens with line height baked in):**

```typescript
// theme.ts
typography: {
  titleL: { fontSize: 22, lineHeight: 28, fontWeight: '600' },
  body: { fontSize: 16, lineHeight: 22, fontWeight: '400' },
  caption: { fontSize: 13, lineHeight: 18, fontWeight: '400' },
}

const styles = StyleSheet.create((theme) => ({
  screenTitle: theme.typography.titleL,
}))

<Text style={styles.screenTitle}>Patient overview</Text>
// Every title resolves to titleL, so headings match across the app.
```

Reference: [Unistyles theming](https://www.unistyl.es/v3/guides/theming/)
