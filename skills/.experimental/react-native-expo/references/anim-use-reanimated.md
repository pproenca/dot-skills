---
title: Use Reanimated for 60 FPS Animations
impact: MEDIUM
impactDescription: 30→60 FPS improvement on busy JS thread
tags: anim, reanimated, native-driver, performance, worklets
---

## Use Reanimated for 60 FPS Animations

Reanimated runs animations on the UI thread via worklets, achieving consistent 60 FPS even when the JS thread is busy.

**Incorrect (Animated API on JS thread):**

```tsx
import { Animated } from 'react-native'

function FadeIn({ children }) {
  const opacity = useRef(new Animated.Value(0)).current

  useEffect(() => {
    Animated.timing(opacity, {
      toValue: 1,
      duration: 300,
      useNativeDriver: true,  // Limited to transform/opacity
    }).start()
  }, [])

  return (
    <Animated.View style={{ opacity }}>
      {children}
    </Animated.View>
  )
}
// Animation drops frames when JS thread is busy
// Can't animate layout properties (width, height, etc.)
```

**Correct (Reanimated on UI thread):**

```tsx
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
} from 'react-native-reanimated'

function FadeIn({ children }) {
  const opacity = useSharedValue(0)

  useEffect(() => {
    opacity.value = withTiming(1, { duration: 300 })
  }, [])

  const animatedStyle = useAnimatedStyle(() => ({
    opacity: opacity.value,
  }))

  return (
    <Animated.View style={animatedStyle}>
      {children}
    </Animated.View>
  )
}
// Runs on UI thread - consistent 60 FPS
```

**Animate layout properties (Reanimated only):**

```tsx
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated'

function ExpandingCard({ isExpanded }) {
  const height = useSharedValue(100)

  useEffect(() => {
    height.value = withSpring(isExpanded ? 300 : 100)
  }, [isExpanded])

  const animatedStyle = useAnimatedStyle(() => ({
    height: height.value,  // Can animate layout properties!
  }))

  return (
    <Animated.View style={[styles.card, animatedStyle]}>
      <CardContent />
    </Animated.View>
  )
}
// Animated API can't animate height with native driver
```

**Use entering/exiting animations:**

```tsx
import Animated, { FadeIn, FadeOut, SlideInRight } from 'react-native-reanimated'

function NotificationToast({ visible, message }) {
  if (!visible) return null

  return (
    <Animated.View
      entering={SlideInRight.duration(300)}
      exiting={FadeOut.duration(200)}
      style={styles.toast}
    >
      <Text>{message}</Text>
    </Animated.View>
  )
}
// Built-in animations with optimal performance
```

**Combine with gestures:**

```tsx
import { Gesture, GestureDetector } from 'react-native-gesture-handler'
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated'

function DraggableCard() {
  const translateX = useSharedValue(0)
  const translateY = useSharedValue(0)

  const gesture = Gesture.Pan()
    .onUpdate((event) => {
      translateX.value = event.translationX
      translateY.value = event.translationY
    })
    .onEnd(() => {
      translateX.value = withSpring(0)
      translateY.value = withSpring(0)
    })

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value },
      { translateY: translateY.value },
    ],
  }))

  return (
    <GestureDetector gesture={gesture}>
      <Animated.View style={[styles.card, animatedStyle]}>
        <Text>Drag me!</Text>
      </Animated.View>
    </GestureDetector>
  )
}
// 60 FPS gesture tracking and animation
```

Reference: [React Native Reanimated](https://docs.swmansion.com/react-native-reanimated/)
