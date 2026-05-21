---
title: Read Theme Values From the StyleSheet Argument
impact: CRITICAL
impactDescription: prevents per-render theme subscriptions and inline style objects
tags: theme, unistyles, stylesheet, render
---

## Read Theme Values From the StyleSheet Argument

Reading the theme through a hook inside render forces a subscription and rebuilds an inline style object on every pass. Unistyles passes the theme as the argument to `StyleSheet.create`, producing a stable style reference that the engine re-resolves natively when the theme changes.

**Incorrect (theme hook in render — subscription plus fresh object each pass):**

```typescript
function MedicationRow() {
  const theme = useContext(ThemeContext)
  // a new style object is allocated every render, and the row re-renders on theme reads
  return (
    <Text style={{ color: theme.colors.textPrimary, fontSize: 16 }}>Amoxicillin 500mg</Text>
  )
}
```

**Correct (theme arrives as the StyleSheet.create argument):**

```typescript
const styles = StyleSheet.create((theme) => ({
  name: { color: theme.colors.textPrimary, fontSize: theme.typography.body.fontSize },
}))

function MedicationRow() {
  // styles.name is a stable reference; Unistyles repaints it natively on theme change
  return <Text style={styles.name}>Amoxicillin 500mg</Text>
}
```

Reference: [Unistyles StyleSheet](https://www.unistyl.es/v3/references/stylesheet/)
