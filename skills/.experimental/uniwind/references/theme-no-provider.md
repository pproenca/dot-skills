---
title: Remove ThemeProvider Wrapper from App
impact: HIGH
impactDescription: eliminates unnecessary context and re-renders
tags: theme, provider, context, performance
---

## Remove ThemeProvider Wrapper from App

Uniwind handles themes via CSS variables, not React context. Remove NativeWind's ThemeProvider to avoid unnecessary wrapper and re-renders.

**Incorrect (keeping NativeWind's ThemeProvider):**

```tsx
import { ThemeProvider } from 'nativewind'

export default function App() {
  return (
    <ThemeProvider value={{ colorScheme: 'dark' }}>
      <NavigationContainer>
        <RootNavigator />
      </NavigationContainer>
    </ThemeProvider>
  )
}
```

**Correct (no theme provider needed):**

```tsx
export default function App() {
  return (
    <NavigationContainer>
      <RootNavigator />
    </NavigationContainer>
  )
}
```

**Switch themes programmatically:**

```typescript
import { Uniwind } from 'uniwind'
import { useColorScheme } from 'react-native'

function useSystemTheme() {
  const colorScheme = useColorScheme()

  useEffect(() => {
    Uniwind.setTheme(colorScheme ?? 'light')
  }, [colorScheme])
}
```

**Keep React Navigation's theme:**

```tsx
// NavigationContainer theme is still needed for navigation UI
<NavigationContainer theme={colorScheme === 'dark' ? DarkTheme : DefaultTheme}>
```

Reference: [Uniwind Migration Guide](https://docs.uniwind.dev/migration-from-nativewind)
