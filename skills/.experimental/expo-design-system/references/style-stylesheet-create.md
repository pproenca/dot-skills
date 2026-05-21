---
title: Define Styles With StyleSheet.create, Not Inline Objects
impact: HIGH
impactDescription: prevents a new style object on every render
tags: style, unistyles, stylesheet, performance
---

## Define Styles With StyleSheet.create, Not Inline Objects

An inline style object is rebuilt on every render and cannot carry variants or theme tokens, so it both costs allocations and hardcodes values. `StyleSheet.create` returns stable references that Unistyles tracks natively and re-resolves on theme change.

**Incorrect (inline object literal rebuilt each render):**

```typescript
function VitalCard({ status }: { status: 'normal' | 'high' }) {
  return (
    <View style={{ padding: 16, borderRadius: 12,
      backgroundColor: status === 'high' ? '#FEE2E2' : '#FFFFFF' }}>
      <Text style={{ fontSize: 15, color: '#111827' }}>Blood pressure</Text>
    </View>
  )
}
// A fresh object every render defeats native tracking and hardcodes raw values.
```

**Correct (StyleSheet.create with tokens and variants):**

```typescript
const styles = StyleSheet.create((theme) => ({
  card: {
    padding: theme.space.md,
    borderRadius: theme.radius.lg,
    variants: { status: { normal: { backgroundColor: theme.colors.surface },
                          high: { backgroundColor: theme.colors.surfaceAlert } } },
  },
  label: { fontSize: theme.typography.body.fontSize, color: theme.colors.textPrimary },
}))

function VitalCard({ status }: { status: 'normal' | 'high' }) {
  styles.useVariants({ status })
  return <View style={styles.card}><Text style={styles.label}>Blood pressure</Text></View>
}
```

Reference: [Unistyles StyleSheet](https://www.unistyl.es/v3/references/stylesheet/)
