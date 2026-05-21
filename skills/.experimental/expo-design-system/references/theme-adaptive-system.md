---
title: Follow the System Color Scheme by Default
impact: HIGH
impactDescription: eliminates manual light and dark branching in views
tags: theme, dark-mode, adaptive, accessibility
---

## Follow the System Color Scheme by Default

Branching on `useColorScheme` in each component scatters dark-mode logic and lets every screen pick slightly different dark values. Enabling adaptive themes lets Unistyles resolve light or dark from the OS once, so components reference semantic tokens and never branch on the scheme.

**Incorrect (manual scheme branching repeated per screen):**

```typescript
function AppointmentSummary() {
  const scheme = useColorScheme()
  const background = scheme === 'dark' ? '#0B1220' : '#FFFFFF'
  const foreground = scheme === 'dark' ? '#E5E7EB' : '#111827'
  return (
    <View style={{ backgroundColor: background }}>
      <Text style={{ color: foreground }}>Follow-up in 2 weeks</Text>
    </View>
  )
}
// Each screen repeats the branch and can choose inconsistent dark colors.
```

**Correct (adaptive themes resolve the scheme once):**

```typescript
StyleSheet.configure({
  themes: { light: lightTheme, dark: darkTheme },
  settings: { adaptiveThemes: true }, // follows the OS appearance automatically
})

const styles = StyleSheet.create((theme) => ({
  card: { backgroundColor: theme.colors.surface },
  title: { color: theme.colors.textPrimary },
}))

function AppointmentSummary() {
  return <View style={styles.card}><Text style={styles.title}>Follow-up in 2 weeks</Text></View>
}
```

Reference: [Unistyles adaptive themes](https://www.unistyl.es/v3/guides/theming/)
