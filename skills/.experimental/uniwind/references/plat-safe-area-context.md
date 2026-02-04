---
title: Use react-native-safe-area-context for Safe Areas
impact: MEDIUM
impactDescription: correctly handles notches, status bars, and home indicators
tags: plat, safe-area, insets, notch
---

## Use react-native-safe-area-context for Safe Areas

Uniwind doesn't support `*-safe` utility classes. Use `react-native-safe-area-context` for safe area insets.

**Incorrect (NativeWind safe area classes):**

```tsx
// These classes don't work in Uniwind!
<View className="pt-safe pb-safe">
  Content that avoids notches
</View>
```

**Correct (safe area context):**

```tsx
import { useSafeAreaInsets } from 'react-native-safe-area-context'

function Screen() {
  const insets = useSafeAreaInsets()

  return (
    <View
      className="flex-1 bg-background"
      style={{
        paddingTop: insets.top,
        paddingBottom: insets.bottom,
      }}
    >
      <Text>Safe content</Text>
    </View>
  )
}
```

**Alternative (SafeAreaView component):**

```tsx
import { SafeAreaView } from 'react-native-safe-area-context'

function Screen() {
  return (
    <SafeAreaView className="flex-1 bg-background" edges={['top', 'bottom']}>
      <Text>Safe content</Text>
    </SafeAreaView>
  )
}
```

**App setup required:**

```tsx
import { SafeAreaProvider } from 'react-native-safe-area-context'

function App() {
  return (
    <SafeAreaProvider>
      <RootNavigator />
    </SafeAreaProvider>
  )
}
```

Reference: [react-native-safe-area-context](https://docs.expo.dev/versions/latest/sdk/safe-area-context/)
