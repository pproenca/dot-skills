---
title: Use Dynamic Functions for Per-Instance Style Values
impact: HIGH
impactDescription: avoids inline style objects for prop-driven values
tags: style, unistyles, dynamic-functions, props
---

## Use Dynamic Functions for Per-Instance Style Values

When a style depends on a runtime prop (a progress ratio, a chart height), the temptation is to merge an inline object — which reintroduces per-render allocation and raw values. A Unistyles dynamic function takes the prop as an argument while keeping the rest of the style token-driven and theme-aware.

**Incorrect (inline object to inject a prop value):**

```typescript
function ProgressBar({ ratio }: { ratio: number }) {
  // an inline object is recreated each render just to thread the ratio into width
  return (
    <View style={styles.track}>
      <View style={[styles.fillBase, { width: `${ratio * 100}%`, backgroundColor: '#0F766E' }]} />
    </View>
  )
}
```

**Correct (a dynamic function inside the StyleSheet):**

```typescript
const styles = StyleSheet.create((theme) => ({
  track: { height: theme.space.xs, borderRadius: theme.radius.sm,
           backgroundColor: theme.colors.surfaceMuted },
  fill: (ratio: number) => ({
    width: `${Math.min(ratio, 1) * 100}%`,
    height: theme.space.xs,
    backgroundColor: theme.colors.accent,
  }),
}))

function ProgressBar({ ratio }: { ratio: number }) {
  return <View style={styles.track}><View style={styles.fill(ratio)} /></View>
}
// The function keeps width prop-driven while color and height stay token-driven.
```

Reference: [Unistyles dynamic functions](https://www.unistyl.es/v3/references/dynamic-functions/)
