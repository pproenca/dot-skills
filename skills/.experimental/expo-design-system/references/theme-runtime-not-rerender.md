---
title: Switch Themes Through the Unistyles Runtime
impact: CRITICAL
impactDescription: prevents a full JavaScript re-render on every theme change
tags: theme, unistyles, runtime, performance
---

## Switch Themes Through the Unistyles Runtime

Storing the active theme in React context means every consumer re-renders when the theme toggles — on a clinic dashboard that is the entire screen. Unistyles holds the theme in its C++ layer and updates the native nodes directly, so a theme switch repaints without re-rendering the React tree.

**Incorrect (theme in React state re-renders every consumer):**

```typescript
const ThemeContext = createContext(lightTheme)

function ThemeProvider({ children }: PropsWithChildren) {
  const [theme, setTheme] = useState(lightTheme)
  // toggling re-renders every component that reads this context — the whole app
  return <ThemeContext.Provider value={theme}>{children}</ThemeContext.Provider>
}

function ScreenHeader() {
  const theme = useContext(ThemeContext) // subscribes the header to theme re-renders
  return <View style={{ backgroundColor: theme.colors.surface }} />
}
```

**Correct (the runtime updates native nodes without re-rendering):**

```typescript
import { StyleSheet, UnistylesRuntime } from 'react-native-unistyles'

const styles = StyleSheet.create((theme) => ({
  header: { backgroundColor: theme.colors.surface },
}))

function ScreenHeader() {
  return <View style={styles.header} /> // no hook, no subscription, no re-render
}

function toggleTheme() {
  UnistylesRuntime.setTheme(UnistylesRuntime.themeName === 'light' ? 'dark' : 'light')
}
```

Reference: [Unistyles 3.0 selective updates](https://www.unistyl.es/v3/start/new-features/)
