---
title: Implement Component Variants With the Variants API
impact: HIGH
impactDescription: reduces conditional style branching to declarative variants
tags: style, variants, unistyles, declarative
---

## Implement Component Variants With the Variants API

Selecting styles with ternary-merged arrays means every new state adds another `&&` branch and another StyleSheet entry, and the merge runs on each render. The Unistyles variants API declares the options once and resolves the active one by key, keeping the component body free of conditional style logic.

**Incorrect (ternary-merged style arrays):**

```typescript
function StatusPill({ status }: { status: AppointmentStatus }) {
  return (
    <View style={[
      styles.pill,
      status === 'confirmed' && styles.confirmed,
      status === 'cancelled' && styles.cancelled,
      status === 'pending' && styles.pending,
    ]}>
      <AppText variant="caption">{status}</AppText>
    </View>
  )
}
// Each new status needs another && branch and another StyleSheet entry.
```

**Correct (variants resolve the status by key):**

```typescript
const styles = StyleSheet.create((theme) => ({
  pill: {
    paddingHorizontal: theme.space.sm,
    variants: {
      status: {
        confirmed: { backgroundColor: theme.colors.statusConfirmed },
        cancelled: { backgroundColor: theme.colors.statusCancelled },
        pending: { backgroundColor: theme.colors.statusPending },
      },
    },
  },
}))

function StatusPill({ status }: { status: AppointmentStatus }) {
  styles.useVariants({ status })
  return <View style={styles.pill}><AppText variant="caption">{status}</AppText></View>
}
```

Reference: [Unistyles variants](https://www.unistyl.es/v3/references/variants/)
