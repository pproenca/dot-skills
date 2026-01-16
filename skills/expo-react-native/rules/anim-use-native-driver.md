---
title: Enable useNativeDriver for Animated API
impact: MEDIUM
impactDescription: offloads animation to native thread, prevents JS thread blocking
tags: anim, animated, native-driver, performance
---

## Enable useNativeDriver for Animated API

When using React Native's built-in Animated API, always enable `useNativeDriver: true` to run animations on the native UI thread instead of the JavaScript thread.

**Incorrect (animation runs on JS thread):**

```typescript
import { Animated } from 'react-native'

function FadeInView({ children }) {
  const opacity = useRef(new Animated.Value(0)).current

  useEffect(() => {
    Animated.timing(opacity, {
      toValue: 1,
      duration: 300,
      // Missing useNativeDriver - runs on JS thread
    }).start()
  }, [])

  return <Animated.View style={{ opacity }}>{children}</Animated.View>
}
// Animation competes with JS work, may drop frames
```

**Correct (animation runs on native thread):**

```typescript
import { Animated } from 'react-native'

function FadeInView({ children }) {
  const opacity = useRef(new Animated.Value(0)).current

  useEffect(() => {
    Animated.timing(opacity, {
      toValue: 1,
      duration: 300,
      useNativeDriver: true,  // Runs on UI thread
    }).start()
  }, [])

  return <Animated.View style={{ opacity }}>{children}</Animated.View>
}
// Smooth animation regardless of JS thread activity
```

**Supported properties with useNativeDriver:**
- `opacity`
- `transform` (translateX, translateY, scale, rotate, etc.)

**Not supported (use Reanimated instead):**
- `width`, `height`
- `backgroundColor`
- `borderRadius`
- `margin`, `padding`
- Layout properties

**Parallel animations:**

```typescript
Animated.parallel([
  Animated.timing(opacity, {
    toValue: 1,
    duration: 300,
    useNativeDriver: true,
  }),
  Animated.spring(scale, {
    toValue: 1,
    useNativeDriver: true,
  }),
]).start()
```

**Note:** If you need to animate layout properties (height, width, position), use React Native Reanimated instead, which supports all style properties on the native thread.

Reference: [Animated API useNativeDriver](https://reactnative.dev/docs/animations#using-the-native-driver)
