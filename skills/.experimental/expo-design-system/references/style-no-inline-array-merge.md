---
title: Avoid Merging Styles With Inline Arrays in Lists
impact: HIGH
impactDescription: prevents per-row array and object allocation in long lists
tags: style, performance, lists, allocation
---

## Avoid Merging Styles With Inline Arrays in Lists

A `style={[base, { ... }]}` merge inside `renderItem` allocates a new array and a new object for every visible row on every render — multiplied across a 500-row schedule, that is real frame-time pressure. Encoding the condition as a boolean variant lets Unistyles pick the row style with no per-row allocation.

**Incorrect (inline array plus object per row):**

```typescript
const renderItem = ({ item }: { item: Appointment }) => (
  <View style={[styles.row, { backgroundColor: item.urgent ? '#FEF2F2' : '#FFFFFF' }]}>
    <AppText>{item.patientName}</AppText>
  </View>
)
// For a full schedule this allocates a fresh array and object per row, per render.
```

**Correct (a boolean variant picks the row style):**

```typescript
const styles = StyleSheet.create((theme) => ({
  row: {
    padding: theme.space.md,
    variants: { urgent: { true: { backgroundColor: theme.colors.surfaceAlert },
                          false: { backgroundColor: theme.colors.surface } } },
  },
}))

const AppointmentRow = memo(({ item }: { item: Appointment }) => {
  styles.useVariants({ urgent: item.urgent })
  return <View style={styles.row}><AppText>{item.patientName}</AppText></View>
})
```

Reference: [Unistyles variants](https://www.unistyl.es/v3/references/variants/)
