---
title: Avoid Exposing a Raw style Prop on Components
impact: CRITICAL
impactDescription: prevents one-off overrides that bypass design tokens
tags: api, encapsulation, style, tokens
---

## Avoid Exposing a Raw style Prop on Components

A `style` prop that gets spread onto the root view hands every caller permission to override padding, color, and radius — bypassing the token system the design system exists to enforce. Replacing it with intent props (`tone`, `inset`) keeps the surface area closed while still covering the real customization needs.

**Incorrect (spreading an arbitrary style prop):**

```typescript
type CardProps = PropsWithChildren<{ style?: StyleProp<ViewStyle> }>

function PatientCard({ style, children }: CardProps) {
  return <View style={[styles.card, style]}>{children}</View>
}
// A screen passes style={{ padding: 3, backgroundColor: '#abc' }} and quietly breaks
// the card's spacing and theming — the design system cannot reject it.
```

**Correct (expose intent props, keep the style internal):**

```typescript
type CardProps = PropsWithChildren<{ tone?: 'default' | 'alert'; inset?: 'comfortable' | 'compact' }>

const styles = StyleSheet.create((theme) => ({
  card: {
    variants: {
      tone: { default: { backgroundColor: theme.colors.surface },
              alert: { backgroundColor: theme.colors.surfaceAlert } },
      inset: { comfortable: { padding: theme.space.lg },
               compact: { padding: theme.space.sm } },
    },
  },
}))

function PatientCard({ tone = 'default', inset = 'comfortable', children }: CardProps) {
  styles.useVariants({ tone, inset })
  return <View style={styles.card}>{children}</View>
}
// Callers choose from sanctioned options; padding and color stay token-driven.
```

**When NOT to use this pattern:**

- Layout-only props on a composition wrapper (a `flex`, `gap`, or `width` to fit the parent) are fine to expose. What stays closed is visual styling — color, padding, radius, typography — that the tokens own.

Reference: [Building the Airbnb Design System](https://www.infoq.com/news/2020/02/airbnb-design-system-react-conf/)
