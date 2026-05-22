---
title: Express Visual Options as Variant Props
impact: CRITICAL
impactDescription: prevents unbounded style drift on shared components
tags: api, variants, dls, props
---

## Express Visual Options as Variant Props

Airbnb's Design Language System makes every visual choice a named prop — a button gets a `variant` prop, not a free `style` prop — so the same intent always renders the same way. A `style` escape hatch lets each call site invent its own look, and within weeks no two "primary" buttons match. Variants encode a closed, reviewable set of options.

**Incorrect (a style prop turns one component into many looks):**

```typescript
type ButtonProps = { title: string; style?: ViewStyle; onPress: () => void }

function AppButton({ title, style, onPress }: ButtonProps) {
  return <Pressable style={[styles.base, style]} onPress={onPress}><Text>{title}</Text></Pressable>
}

// Each caller passes a bespoke style, so "primary" means something different everywhere:
<AppButton title="Book" style={{ backgroundColor: '#0F766E', borderRadius: 6 }} onPress={book} />
<AppButton title="Save" style={{ backgroundColor: 'teal', borderRadius: 10 }} onPress={save} />
```

**Correct (a closed set of variant props, the DLS pattern):**

```typescript
type ButtonProps = { title: string; variant?: 'primary' | 'secondary'; onPress: () => void }

const styles = StyleSheet.create((theme) => ({
  base: {
    borderRadius: theme.radius.md,
    variants: {
      variant: {
        primary: { backgroundColor: theme.colors.accent },
        secondary: { backgroundColor: theme.colors.surfaceMuted },
      },
    },
  },
}))

function AppButton({ title, variant = 'primary', onPress }: ButtonProps) {
  styles.useVariants({ variant })
  return <Pressable style={styles.base} onPress={onPress}><Text>{title}</Text></Pressable>
}
// "primary" renders identically everywhere because callers pick a variant, not a style.
```

**When NOT to use this pattern:**

- A genuinely one-off surface that will never be reused (a single marketing splash) can take a local style. The moment a second instance appears, promote it to a variant.

Reference: [Building the Airbnb Design System](https://www.infoq.com/news/2020/02/airbnb-design-system-react-conf/), [Unistyles variants](https://www.unistyl.es/v3/references/variants/)
