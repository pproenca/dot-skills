---
title: Prevent Feature Modules From Defining Local Tokens
impact: MEDIUM
impactDescription: eliminates shadow token systems inside features
tags: govern, tokens, boundary, consistency
---

## Prevent Feature Modules From Defining Local Tokens

A feature that defines its own colors and spacing creates a shadow token system that drifts from the design system and never inherits dark mode or rebrands. Adding the role to the central theme keeps one source of truth, so the feature gets theming and consistency automatically.

**Incorrect (a feature defines a parallel token set):**

```typescript
// features/billing/theme.ts — tokens nobody else knows about
export const billingColors = { accent: '#7C3AED', surface: '#F5F3FF' }
export const billingSpacing = { gutter: 14 }
// Billing screens drift from the design system and never get dark mode.
```

**Correct (extend the central theme instead):**

```typescript
// design-system/theme.ts — add the role to the one theme, available app-wide
const lightTheme = {
  colors: { accent: '#0F766E', billingAccent: '#7C3AED', surface: '#FFFFFF' },
  space: { xs: 4, sm: 8, md: 16, gutter: 16 },
}

// features/billing reads it like any other token, so dark mode comes for free
const styles = StyleSheet.create((theme) => ({ total: { color: theme.colors.billingAccent } }))
```

Reference: [Unistyles theming](https://www.unistyl.es/v3/guides/theming/)
