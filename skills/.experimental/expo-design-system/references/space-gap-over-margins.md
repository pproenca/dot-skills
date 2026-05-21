---
title: Lay Out Stacks With Gap, Not Per-Child Margins
impact: MEDIUM
impactDescription: eliminates stray trailing space from the last child in a stack
tags: space, layout, gap, flexbox
---

## Lay Out Stacks With Gap, Not Per-Child Margins

Putting `marginBottom` on every child also adds a margin after the last one, leaving stray space before the next section that someone later "fixes" with a negative margin. Setting `gap` on the container spaces children evenly and adds nothing after the last item.

**Incorrect (marginBottom on each child):**

```typescript
{medications.map((m) => (
  <View key={m.id} style={{ marginBottom: 12 }}>
    <MedicationRow medication={m} />
  </View>
))}
// The last child also gets a 12pt bottom margin, adding stray space before the next section.
```

**Correct (gap on the container):**

```typescript
const styles = StyleSheet.create((theme) => ({
  list: { gap: theme.space.sm }, // even spacing between children, none after the last
}))

<View style={styles.list}>
  {medications.map((m) => <MedicationRow key={m.id} medication={m} />)}
</View>
```

Reference: [Unistyles theming](https://www.unistyl.es/v3/guides/theming/)
