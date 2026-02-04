---
title: Use useResolveClassNames Sparingly
impact: MEDIUM-HIGH
impactDescription: runtime resolution is slower than build-time compilation
tags: perf, use-resolve-class-names, runtime, hook
---

## Use useResolveClassNames Sparingly

The `useResolveClassNames` hook resolves styles at runtime. Use it only when className prop isn't available, as it's slower than build-time compilation.

**Incorrect (using hook for standard components):**

```tsx
function Card() {
  // Unnecessary runtime resolution
  const styles = useResolveClassNames('bg-card rounded-xl p-4')

  return (
    <View style={styles}>
      <Text>Content</Text>
    </View>
  )
}
```

**Correct (use className directly):**

```tsx
function Card() {
  // Build-time compiled, faster
  return (
    <View className="bg-card rounded-xl p-4">
      <Text>Content</Text>
    </View>
  )
}
```

**When useResolveClassNames IS appropriate:**

```tsx
// Library configuration that requires style objects
import { NavigationContainer, DefaultTheme } from '@react-navigation/native'

function App() {
  const cardStyle = useResolveClassNames('bg-card')
  const textStyle = useResolveClassNames('text-foreground')

  const theme = {
    ...DefaultTheme,
    colors: {
      ...DefaultTheme.colors,
      card: cardStyle.backgroundColor,
      text: textStyle.color,
    },
  }

  return <NavigationContainer theme={theme}>...</NavigationContainer>
}
```

Reference: [Uniwind useResolveClassNames](https://docs.uniwind.dev/api/use-resolve-class-names)
