---
title: Drive Press and Disabled States From Variants
impact: MEDIUM
impactDescription: eliminates duplicated Pressable style callbacks across buttons
tags: style, variants, pressable, states
---

## Drive Press and Disabled States From Variants

The `style={({ pressed }) => [...]}` callback gets copy-pasted into every button with slightly different opacities, so press feedback drifts across the app. Modeling pressed and disabled as variants defines the feedback once inside the design system button, and call sites get consistent behavior for free.

**Incorrect (per-button pressed/disabled callback):**

```typescript
<Pressable
  style={({ pressed }) => [
    styles.button,
    pressed && { opacity: 0.7 },
    disabled && { opacity: 0.4 },
  ]}
  disabled={disabled}
/>
// Copied into every button with drifting opacity values; feedback is inconsistent.
```

**Correct (states modeled as variants in one component):**

```typescript
const styles = StyleSheet.create((theme) => ({
  button: {
    backgroundColor: theme.colors.accent,
    variants: {
      pressed: { true: { opacity: 0.7 } },
      disabled: { true: { opacity: 0.4 } },
    },
  },
}))

function AppButton({ disabled }: { disabled?: boolean }) {
  const [pressed, setPressed] = useState(false)
  styles.useVariants({ pressed, disabled })
  return (
    <Pressable style={styles.button} disabled={disabled}
      onPressIn={() => setPressed(true)} onPressOut={() => setPressed(false)} />
  )
}
```

Reference: [Unistyles variants](https://www.unistyl.es/v3/references/variants/)
