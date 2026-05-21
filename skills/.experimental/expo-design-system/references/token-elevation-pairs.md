---
title: Tokenize Elevation as Surface and Shadow Pairs
impact: HIGH
impactDescription: prevents inconsistent depth across light and dark themes
tags: token, elevation, shadow, surface
---

## Tokenize Elevation as Surface and Shadow Pairs

Shadows alone convey depth in light mode but vanish against dark backgrounds, so depth must be expressed as a *pair*: a surface tint plus a shadow. Copying raw shadow props into each component produces a dozen slightly different elevations that all break in dark mode. An elevation token bundles both halves so depth reads consistently in every theme.

**Incorrect (ad-hoc shadow props copied per component):**

```typescript
const styles = StyleSheet.create(() => ({
  card: {
    shadowColor: '#000',
    shadowOpacity: 0.2,
    shadowRadius: 8,
    shadowOffset: { width: 0, height: 2 },
    elevation: 4,
  },
}))
// Pasted into many components with drifting values; in dark mode the black
// shadow is invisible and no surface tint communicates that the card is raised.
```

**Correct (elevation token pairing a surface tint with a shadow):**

```typescript
// design-system/theme.ts
const lightTheme = {
  colors: { surfaceRaised: '#FFFFFF' },
  elevation: {
    raised: { shadowColor: '#0F172A', shadowOpacity: 0.16, shadowRadius: 8,
              shadowOffset: { width: 0, height: 2 }, elevation: 4 },
  },
}

const styles = StyleSheet.create((theme) => ({
  card: { ...theme.elevation.raised, backgroundColor: theme.colors.surfaceRaised },
}))
// The dark theme supplies a lighter surfaceRaised, so depth reads even when the
// shadow itself is barely visible.
```

Reference: [Unistyles theming](https://www.unistyl.es/v3/guides/theming/)
