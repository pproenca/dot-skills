---
title: Accept Slot Props for Flexible Composition
impact: HIGH
impactDescription: eliminates a new boolean prop for every content permutation
tags: api, slots, composition, children
---

## Accept Slot Props for Flexible Composition

A component that adds a `show*` boolean and a payload prop for every optional element grows an unbounded API and still cannot express combinations its author did not predict. Named slots that accept any `ReactNode` let callers compose arbitrary content — an avatar, a badge, an icon — without the component knowing about each case.

**Incorrect (a prop pair per content variation):**

```typescript
type RowProps = {
  title: string
  showAvatar?: boolean; avatarUri?: string
  showBadge?: boolean; badgeText?: string
  showChevron?: boolean
}
// Every new trailing element adds two more props; the surface keeps growing.
function ListRow(props: RowProps) { /* conditionally renders each optional piece */ }
```

**Correct (named slots accept any node):**

```typescript
type RowProps = PropsWithChildren<{ leading?: ReactNode; trailing?: ReactNode }>

const styles = StyleSheet.create((theme) => ({
  row: { flexDirection: 'row', alignItems: 'center', gap: theme.space.sm, padding: theme.space.md },
}))

function ListRow({ leading, trailing, children }: RowProps) {
  return (
    <View style={styles.row}>
      {leading}
      <View style={{ flex: 1 }}>{children}</View>
      {trailing}
    </View>
  )
}
// A caller drops <PatientAvatar/> into leading and <StatusBadge/> into trailing — no new props.
```

Reference: [Building the Airbnb Design System](https://www.infoq.com/news/2020/02/airbnb-design-system-react-conf/)
