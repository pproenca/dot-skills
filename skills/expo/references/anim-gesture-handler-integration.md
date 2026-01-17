---
title: Use Gesture Handler with Reanimated for Gesture-Driven Animations
impact: MEDIUM
impactDescription: 2-5× smoother gesture response via native thread execution
tags: anim, gesture-handler, reanimated, interaction
---

## Use Gesture Handler with Reanimated for Gesture-Driven Animations

Combine React Native Gesture Handler with Reanimated for gesture-driven animations that run entirely on the native thread, avoiding JS thread roundtrips.

**Incorrect (JS-based gesture handling):**

```typescript
import { PanResponder, Animated, View } from 'react-native'

function DraggableCard() {
  const pan = useRef(new Animated.ValueXY()).current

  const panResponder = useRef(
    PanResponder.create({
      onMoveShouldSetPanResponder: () => true,
      onPanResponderMove: Animated.event(
        [null, { dx: pan.x, dy: pan.y }],
        { useNativeDriver: false }  // Can't use native driver with PanResponder
      ),
      onPanResponderRelease: () => {
        Animated.spring(pan, {
          toValue: { x: 0, y: 0 },
          useNativeDriver: true,
        }).start()
      },
    })
  ).current

  return (
    <Animated.View
      {...panResponder.panHandlers}
      style={{ transform: pan.getTranslateTransform() }}
    >
      <CardContent />
    </Animated.View>
  )
}
// Gesture events cross JS bridge, causing lag
```

**Correct (native gesture handling with Reanimated):**

```typescript
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated'
import { Gesture, GestureDetector } from 'react-native-gesture-handler'

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
      <Animated.View style={animatedStyle}>
        <CardContent />
      </Animated.View>
    </GestureDetector>
  )
}
// Entire gesture-animation pipeline on UI thread
```

**Installation:**

```bash
npx expo install react-native-gesture-handler
```

**Wrap app with GestureHandlerRootView:**

```typescript
import { GestureHandlerRootView } from 'react-native-gesture-handler'

export default function App() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <RootNavigator />
    </GestureHandlerRootView>
  )
}
```

Reference: [Gesture Handler Documentation](https://docs.swmansion.com/react-native-gesture-handler/)
