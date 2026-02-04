---
title: Reanimated Components Work Without withUniwind
impact: MEDIUM-HIGH
impactDescription: avoids unnecessary wrapping of animated components
tags: comp, reanimated, animation, compatibility
---

## Reanimated Components Work Without withUniwind

React Native Reanimated's components are built on core RN components and support `className` automatically. Don't wrap them with `withUniwind`.

**Incorrect (unnecessary wrapping):**

```tsx
import { withUniwind } from 'uniwind'
import Animated from 'react-native-reanimated'

// Unnecessary - adds overhead without benefit
const AnimatedView = withUniwind(Animated.View)
```

**Correct (use directly):**

```tsx
import Animated from 'react-native-reanimated'

function AnimatedCard() {
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }))

  return (
    <Animated.View
      className="bg-card rounded-xl p-4"
      style={animatedStyle}
    />
  )
}
```

**Components that work without wrapping:**
- `Animated.View`
- `Animated.Text`
- `Animated.Image`
- `Animated.ScrollView`
- Any component created with `Animated.createAnimatedComponent()`

Reference: [Uniwind withUniwind API](https://docs.uniwind.dev/api/with-uniwind)
