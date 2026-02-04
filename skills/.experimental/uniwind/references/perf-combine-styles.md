---
title: Combine className and style Prop Correctly
impact: MEDIUM
impactDescription: ensures both static and dynamic styles apply properly
tags: perf, className, style, combination
---

## Combine className and style Prop Correctly

When combining className with style prop (for animations or dynamic values), both apply with style taking precedence for conflicts.

**Incorrect (style overwriting all className styles):**

```tsx
function AnimatedCard({ scale }: { scale: number }) {
  // Trying to pass object directly, won't work as expected
  return (
    <View
      className="bg-card p-4 rounded"
      style={{ transform: `scale(${scale})` }}  // Wrong: string transform
    />
  )
}
```

**Correct (proper style array with Reanimated):**

```tsx
import Animated, { useAnimatedStyle } from 'react-native-reanimated'

function AnimatedCard({ scale }: { scale: SharedValue<number> }) {
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }))

  return (
    <Animated.View
      className="bg-card p-4 rounded"  // Static styles via className
      style={animatedStyle}             // Dynamic styles via style
    />
  )
}
```

**Combining with StyleSheet:**

```tsx
import { useResolveClassNames } from 'uniwind'

function Card() {
  const tailwindStyles = useResolveClassNames('p-4 rounded-lg')
  const customStyles = StyleSheet.create({
    shadow: {
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.25,
      elevation: 5,
    },
  })

  return (
    <View style={[tailwindStyles, customStyles.shadow]}>
      Content
    </View>
  )
}
```

Reference: [Uniwind useResolveClassNames](https://docs.uniwind.dev/api/use-resolve-class-names)
