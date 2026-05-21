---
title: Layer Tokens as Raw, Semantic, and Component Scales
impact: CRITICAL
impactDescription: prevents palette-wide rebrands from touching component code
tags: token, design-tokens, theme, scales
---

## Layer Tokens as Raw, Semantic, and Component Scales

A flat token map where components reference raw palette names couples every screen to specific brand values. When the brand changes, you edit every file. Three layers — raw palette, semantic roles, and component tokens — give you one place to change a value while keeping component code stable.

**Incorrect (raw palette used as the only layer — a rebrand edits every screen):**

```typescript
// design-system/theme.ts
export const lightTheme = {
  colors: { teal500: '#0F766E', gray50: '#F9FAFB', gray900: '#111827' },
}

// features/appointments/AppointmentCard.tsx
const styles = StyleSheet.create((theme) => ({
  card: {
    backgroundColor: theme.colors.gray50,
    borderColor: theme.colors.teal500, // brand value hardcoded at the call site
  },
}))
// Switching the brand from teal to indigo means renaming teal500 in every
// component that referenced it — there is no single place to change.
```

**Correct (raw to semantic to component layers — a rebrand edits one map):**

```typescript
// design-system/theme.ts
const palette = { teal500: '#0F766E', gray50: '#F9FAFB', gray900: '#111827' }

export const lightTheme = {
  palette,                                   // layer 1: raw values
  colors: { surface: palette.gray50, accent: palette.teal500, textPrimary: palette.gray900 },
  components: { card: { background: palette.gray50, border: palette.teal500 } }, // layer 3
}

// features/appointments/AppointmentCard.tsx
const styles = StyleSheet.create((theme) => ({
  card: {
    backgroundColor: theme.components.card.background,
    borderColor: theme.components.card.border,
  },
}))
// A rebrand changes palette.teal500 once; the semantic and component layers follow.
```

Reference: [Unistyles theming](https://www.unistyl.es/v3/guides/theming/), [Building the Airbnb Design System](https://www.infoq.com/news/2020/02/airbnb-design-system-react-conf/)
