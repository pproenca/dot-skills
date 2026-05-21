---
title: Apply Safe-Area Insets at Screen Boundaries
impact: HIGH
impactDescription: prevents content under notches and the home indicator
tags: space, safe-area, insets, layout
---

## Apply Safe-Area Insets at Screen Boundaries

A hardcoded `paddingTop: 44` is wrong on devices without a notch and ignores the bottom home indicator entirely, so content collides with system UI. The Unistyles runtime exposes live `insets`, so a screen pads itself correctly on every device and updates if the safe area changes.

**Incorrect (hardcoded inset for the status bar):**

```typescript
<View style={{ paddingTop: 44, paddingBottom: 0 }}>
  <ScheduleHeader />
</View>
// 44 is wrong on devices without a notch, and the bottom content sits under the home indicator.
```

**Correct (runtime insets from Unistyles):**

```typescript
const styles = StyleSheet.create((theme, rt) => ({
  screen: {
    paddingTop: rt.insets.top,
    paddingBottom: rt.insets.bottom,
    paddingHorizontal: theme.space.md,
  },
}))

function ScheduleScreen() {
  return <View style={styles.screen}><ScheduleHeader /></View>
}
// rt.insets adapts per device and re-resolves natively if the safe area changes.
```

Reference: [Unistyles runtime insets](https://www.unistyl.es/v3/references/mini-runtime/)
