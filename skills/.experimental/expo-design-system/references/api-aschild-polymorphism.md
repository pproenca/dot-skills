---
title: Offer asChild Polymorphism Instead of Wrapper Nesting
impact: MEDIUM
impactDescription: eliminates redundant wrapper nodes and duplicate press targets
tags: api, polymorphism, aschild, composition
---

## Offer asChild Polymorphism Instead of Wrapper Nesting

Wrapping a navigation link inside a button produces two interactive nodes fighting for the same touch and an extra view layer per usage. An `asChild` prop merges the component's styling and behavior onto the child element, so the link itself becomes the styled button — one node, one press target.

**Incorrect (nesting a link inside a button):**

```typescript
// Pressable wrapping Link yields two press targets and an extra View per usage
<AppButton onPress={() => {}}>
  <Link href="/appointments/new">
    <Text>New appointment</Text>
  </Link>
</AppButton>
// The outer Pressable and inner Link both capture taps, and the tree gains a wrapper.
```

**Correct (asChild merges props onto the child):**

```typescript
type ButtonProps = PropsWithChildren<{ asChild?: boolean; onPress?: () => void }>

function AppButton({ asChild, children, ...rest }: ButtonProps) {
  styles.useVariants({ variant: 'primary' })
  if (asChild && isValidElement(children)) {
    return cloneElement(children, { style: styles.base, ...rest })
  }
  return <Pressable style={styles.base} {...rest}>{children}</Pressable>
}

// The Link becomes the styled button itself — a single node and a single press target:
<AppButton asChild>
  <Link href="/appointments/new"><Text>New appointment</Text></Link>
</AppButton>
```

Reference: [Radix asChild pattern](https://www.radix-ui.com/primitives/docs/guides/composition)
