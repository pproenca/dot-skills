---
title: Extend a Shared Component With a Variant, Don't Fork a Local One
impact: HIGH
impactDescription: prevents near-duplicate components from diverging across features
tags: reuse, variants, system-fit, dls
---

## Extend a Shared Component With a Variant, Don't Fork a Local One

When a shared component is a near-match but missing one look, the local-optimum move is to copy it into the feature and tweak it. That fork drifts the moment either copy changes. Add the missing option as a variant on the shared component instead: the change lands once, every feature inherits it, and the system stays single-sourced.

**Incorrect (forked the whole component to get a red background):**

```typescript
// features/billing/PayButton.tsx — a second button re-implementing press, layout, and
// accessibility just to change one color; it drifts from AppButton the moment either changes.
function PayButton({ title, onPress }: { title: string; onPress: () => void }) {
  const [pressed, setPressed] = useState(false)
  return (
    <Pressable style={styles.payButton} onPress={onPress} accessibilityRole="button"
      onPressIn={() => setPressed(true)} onPressOut={() => setPressed(false)}>
      <Text style={styles.label}>{title}</Text>
    </Pressable>
  )
}
```

**Correct (add the variant to the shared component, then use it):**

```typescript
// @clinic/design-system AppButton — one new variant value, available everywhere
variants: {
  variant: {
    primary: { backgroundColor: theme.colors.accent },
    secondary: { backgroundColor: theme.colors.surfaceMuted },
    danger: { backgroundColor: theme.colors.danger },
  },
}

// feature call site:
<AppButton title="Pay" variant="danger" onPress={pay} />
```

This rule is about not forking the whole component file; for *why* the option is a variant prop rather than a `style` prop, see [`api-variants-over-style-prop`](api-variants-over-style-prop.md).

Reference: [Unistyles variants](https://www.unistyl.es/v3/references/variants/)
