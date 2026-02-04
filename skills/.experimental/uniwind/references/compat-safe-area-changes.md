---
title: Replace *-safe Classes with Safe Area Context
impact: LOW-MEDIUM
impactDescription: prevents content overlapping notch and home indicator
tags: compat, safe-area, migration, insets
---

## Replace *-safe Classes with Safe Area Context

NativeWind's `*-safe` utility classes don't exist in Uniwind. Use `react-native-safe-area-context` instead.

**Incorrect (NativeWind safe area classes):**

```tsx
// These classes don't work in Uniwind!
<View className="pt-safe pb-safe px-4">
  <View className="mt-safe-or-4">
    Content overlaps notch because classes are ignored
  </View>
</View>
```

**Correct (Safe Area Context hook):**

```tsx
import { useSafeAreaInsets } from 'react-native-safe-area-context'

function Screen() {
  const insets = useSafeAreaInsets()

  return (
    <View
      className="px-4"
      style={{
        paddingTop: insets.top,
        paddingBottom: insets.bottom,
      }}
    >
      <View
        className="px-4"
        style={{
          marginTop: Math.max(insets.top, 16),  // safe-or-4 equivalent
        }}
      >
        Content properly avoids notch
      </View>
    </View>
  )
}
```

**Alternative (SafeAreaView component):**

```tsx
import { SafeAreaView } from 'react-native-safe-area-context'

function Screen() {
  return (
    <SafeAreaView className="flex-1 px-4" edges={['top', 'bottom']}>
      Content with safe area padding
    </SafeAreaView>
  )
}
```

Reference: [react-native-safe-area-context](https://docs.expo.dev/versions/latest/sdk/safe-area-context/)
