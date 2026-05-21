---
title: Combine Variant Dimensions With Compound Variants
impact: CRITICAL
impactDescription: reduces an N by M variant matrix to one component definition
tags: api, variants, compound-variants, composition
---

## Combine Variant Dimensions With Compound Variants

When a component varies along two axes (variant and size), writing one component per combination explodes: adding an axis multiplies the file count. Declaring each axis once and using compound variants only for the genuine exceptions keeps a single component that scales additively, not multiplicatively.

**Incorrect (one component per combination):**

```typescript
// a separate component for every (variant x size) pair
function PrimaryLargeButton() { /* ... */ }
function PrimarySmallButton() { /* ... */ }
function DangerLargeButton() { /* ... */ }
function DangerSmallButton() { /* ... */ }
// Adding a "ghost" variant or an "xl" size forces several new components at once.
```

**Correct (one component, compound variants for exceptions):**

```typescript
const styles = StyleSheet.create((theme) => ({
  button: {
    variants: {
      variant: { primary: { backgroundColor: theme.colors.accent },
                 danger: { backgroundColor: theme.colors.danger } },
      size: { sm: { paddingVertical: theme.space.xs },
              lg: { paddingVertical: theme.space.md } },
    },
    compoundVariants: [
      // only the special case is listed: a large danger button gets a stronger border
      { variant: 'danger', size: 'lg',
        styles: { borderWidth: 2, borderColor: theme.colors.dangerStrong } },
    ],
  },
}))

function AppButton({ variant, size }: { variant: 'primary' | 'danger'; size: 'sm' | 'lg' }) {
  styles.useVariants({ variant, size })
  return <Pressable style={styles.button} />
}
```

Reference: [Unistyles compound variants](https://www.unistyl.es/v3/references/compound-variants/)
