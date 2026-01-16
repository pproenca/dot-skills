---
title: Use Reanimated for UI Thread Animations
impact: MEDIUM
impactDescription: consistent 60fps vs 30-45fps with JS thread animations
tags: anim, reanimated, native-thread, performance
---

## Use Reanimated for UI Thread Animations

React Native Reanimated runs animation logic on the UI thread using worklets, avoiding JS thread bottlenecks and achieving consistent 60fps even during heavy JS work.

**Incorrect (Animated API blocks on JS thread):**

```typescript
import { Animated, Pressable } from 'react-native'
import { useRef } from 'react'

function AnimatedCard() {
  const scale = useRef(new Animated.Value(1)).current

  const handlePressIn = () => {
    Animated.spring(scale, {
      toValue: 0.95,
      useNativeDriver: true,
    }).start()
  }

  const handlePressOut = () => {
    Animated.spring(scale, {
      toValue: 1,
      useNativeDriver: true,
    }).start()
  }

  return (
    <Pressable onPressIn={handlePressIn} onPressOut={handlePressOut}>
      <Animated.View style={{ transform: [{ scale }] }}>
        <CardContent />
      </Animated.View>
    </Pressable>
  )
}
// Limited to transform and opacity with useNativeDriver
```

**Correct (Reanimated with worklets):**

```typescript
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated'
import { Pressable } from 'react-native'

function AnimatedCard() {
  const scale = useSharedValue(1)

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }))

  const handlePressIn = () => {
    scale.value = withSpring(0.95)
  }

  const handlePressOut = () => {
    scale.value = withSpring(1)
  }

  return (
    <Pressable onPressIn={handlePressIn} onPressOut={handlePressOut}>
      <Animated.View style={animatedStyle}>
        <CardContent />
      </Animated.View>
    </Pressable>
  )
}
```

**Installation:**

```bash
npx expo install react-native-reanimated
```

```javascript
// babel.config.js
module.exports = function (api) {
  api.cache(true)
  return {
    presets: ['babel-preset-expo'],
    plugins: ['react-native-reanimated/plugin'],  // Must be last
  }
}
```

**Reanimated advantages:**
- Animate any style property (height, color, borderRadius)
- Synchronous gesture-driven animations
- Shared values between components
- Layout animations

Reference: [React Native Reanimated Documentation](https://docs.swmansion.com/react-native-reanimated/)
