---
title: Drive Tablet Layouts With Breakpoints, Not Dimensions Checks
impact: HIGH
impactDescription: eliminates manual Dimensions branching that breaks on rotation
tags: theme, breakpoints, responsive, tablet
---

## Drive Tablet Layouts With Breakpoints, Not Dimensions Checks

`Dimensions.get()` captures a width once, so a clinician rotating an iPad keeps the phone layout until the screen remounts. Unistyles breakpoints are defined in the config and re-resolved natively on every size change, so responsive styles update without a manual resize listener.

**Incorrect (Dimensions captured once — wrong after rotation):**

```typescript
const { width } = Dimensions.get('window')
const columns = width > 768 ? 2 : 1 // read at module load; never updates on rotate

const styles = StyleSheet.create(() => ({
  scheduleGrid: { flexDirection: columns === 2 ? 'row' : 'column' },
}))
```

**Correct (breakpoints re-resolve automatically):**

```typescript
// design-system/unistyles.ts
StyleSheet.configure({ breakpoints: { phone: 0, tablet: 768 }, themes })

const styles = StyleSheet.create((theme) => ({
  scheduleGrid: {
    flexDirection: { phone: 'column', tablet: 'row' }, // resolved per active breakpoint
    gap: theme.space.md,
  },
}))
// Rotating an iPad re-resolves the breakpoint natively; no Dimensions listener needed.
```

Reference: [Unistyles breakpoints](https://www.unistyl.es/v3/references/breakpoints/)
