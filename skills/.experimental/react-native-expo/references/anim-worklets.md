---
title: Use Worklets for UI Thread Computation
impact: MEDIUM
impactDescription: maintains 60 FPS during complex computations
tags: anim, worklets, reanimated, ui-thread, performance
---

## Use Worklets for UI Thread Computation

Worklets run JavaScript on the UI thread, enabling complex animation logic without frame drops.

**Incorrect (JS thread computation during animation):**

```tsx
import { Animated } from 'react-native'

function ProgressBar({ progress }) {
  // Computed on JS thread during animation
  const width = progress.interpolate({
    inputRange: [0, 100],
    outputRange: ['0%', '100%'],
  })

  // Color logic can't run during animation
  const getColor = (value) => {
    if (value < 30) return 'red'
    if (value < 70) return 'yellow'
    return 'green'
  }

  return (
    <Animated.View style={{ width, backgroundColor: getColor(progress._value) }}>
      <Text>{Math.round(progress._value)}%</Text>
    </Animated.View>
  )
}
// Color doesn't update smoothly with animation
```

**Correct (worklet on UI thread):**

```tsx
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  useDerivedValue,
  withTiming,
  interpolateColor,
} from 'react-native-reanimated'

function ProgressBar({ targetProgress }) {
  const progress = useSharedValue(0)

  useEffect(() => {
    progress.value = withTiming(targetProgress, { duration: 500 })
  }, [targetProgress])

  // Worklet: runs on UI thread
  const animatedStyle = useAnimatedStyle(() => {
    'worklet'  // Explicit worklet annotation (optional in useAnimatedStyle)

    const backgroundColor = interpolateColor(
      progress.value,
      [0, 30, 70, 100],
      ['#ff0000', '#ff0000', '#ffff00', '#00ff00']
    )

    return {
      width: `${progress.value}%`,
      backgroundColor,
    }
  })

  // Derived value for text (also runs on UI thread)
  const progressText = useDerivedValue(() => {
    return `${Math.round(progress.value)}%`
  })

  return (
    <Animated.View style={[styles.bar, animatedStyle]}>
      <ReText text={progressText} style={styles.text} />
    </Animated.View>
  )
}
// All computation runs on UI thread at 60 FPS
```

**Define custom worklets:**

```tsx
import { runOnJS } from 'react-native-reanimated'

// Worklet function
function clamp(value, min, max) {
  'worklet'
  return Math.min(Math.max(value, min), max)
}

// Worklet with complex logic
function getSnapPoint(position, velocity, snapPoints) {
  'worklet'
  const projectedPosition = position + velocity * 0.2
  return snapPoints.reduce((closest, point) =>
    Math.abs(point - projectedPosition) < Math.abs(closest - projectedPosition)
      ? point
      : closest
  )
}

function SnapDrawer() {
  const translateY = useSharedValue(0)
  const snapPoints = [0, -200, -400]

  const gesture = Gesture.Pan()
    .onUpdate((event) => {
      translateY.value = clamp(event.translationY, -400, 0)
    })
    .onEnd((event) => {
      const destination = getSnapPoint(
        translateY.value,
        event.velocityY,
        snapPoints
      )
      translateY.value = withSpring(destination)
    })

  // ...
}
```

**Call JS functions from worklets (when needed):**

```tsx
function SwipeToDelete({ onDelete }) {
  const translateX = useSharedValue(0)

  const gesture = Gesture.Pan()
    .onEnd((event) => {
      if (translateX.value < -150) {
        // Run JS function from UI thread
        runOnJS(onDelete)()
      } else {
        translateX.value = withSpring(0)
      }
    })

  // ...
}
```

**Worklet limitations:**
- Can't access React state directly
- Can't call non-worklet functions (use runOnJS)
- Limited to synchronous operations
- Must be pure functions

Reference: [Reanimated Worklets](https://docs.swmansion.com/react-native-reanimated/docs/fundamentals/worklets/)
