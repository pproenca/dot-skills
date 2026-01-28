---
title: Avoid JS Thread During Animations
impact: MEDIUM
impactDescription: prevents frame drops during scrolling and gestures
tags: anim, js-thread, useNativeDriver, performance, scrolling
---

## Avoid JS Thread During Animations

Any work on the JS thread during animations causes frame drops. Keep the JS thread free during scroll and gesture animations.

**Incorrect (JS work during scroll):**

```tsx
function ParallaxHeader({ scrollY }) {
  // Computed on every scroll event - JS thread work
  const headerHeight = scrollY > 100 ? 50 : 200 - scrollY

  // State update during scroll - triggers re-render
  const [isCollapsed, setIsCollapsed] = useState(false)

  useEffect(() => {
    // Listener runs on JS thread
    const listener = scrollY.addListener(({ value }) => {
      setIsCollapsed(value > 100)  // Re-render during scroll!
    })
    return () => scrollY.removeListener(listener)
  }, [])

  return (
    <Animated.View style={{ height: headerHeight }}>
      {isCollapsed ? <CollapsedHeader /> : <ExpandedHeader />}
    </Animated.View>
  )
}
```

**Correct (all computation on UI thread):**

```tsx
import Animated, {
  useAnimatedScrollHandler,
  useAnimatedStyle,
  useSharedValue,
  interpolate,
  Extrapolate,
} from 'react-native-reanimated'

function ParallaxHeader() {
  const scrollY = useSharedValue(0)

  // Scroll handler runs on UI thread
  const scrollHandler = useAnimatedScrollHandler({
    onScroll: (event) => {
      scrollY.value = event.contentOffset.y
    },
  })

  // Style computed on UI thread
  const headerStyle = useAnimatedStyle(() => ({
    height: interpolate(
      scrollY.value,
      [0, 100],
      [200, 50],
      Extrapolate.CLAMP
    ),
    opacity: interpolate(
      scrollY.value,
      [0, 100],
      [1, 0.8],
      Extrapolate.CLAMP
    ),
  }))

  return (
    <>
      <Animated.View style={[styles.header, headerStyle]}>
        <HeaderContent />
      </Animated.View>
      <Animated.ScrollView onScroll={scrollHandler} scrollEventThrottle={16}>
        <ScrollContent />
      </Animated.ScrollView>
    </>
  )
}
// Zero JS thread work during scroll
```

**Defer JS work until animation completes:**

```tsx
import { runOnJS, withTiming } from 'react-native-reanimated'

function SwipeAction({ onSwipeComplete }) {
  const translateX = useSharedValue(0)

  const gesture = Gesture.Pan()
    .onUpdate((event) => {
      translateX.value = event.translationX
    })
    .onEnd(() => {
      if (translateX.value > 150) {
        // Animate first, then run JS
        translateX.value = withTiming(300, {}, (finished) => {
          if (finished) {
            runOnJS(onSwipeComplete)()  // JS work after animation
          }
        })
      } else {
        translateX.value = withSpring(0)
      }
    })

  // ...
}
```

**Use scrollEventThrottle correctly:**

```tsx
// Without Reanimated - must throttle to reduce JS calls
<ScrollView
  onScroll={handleScroll}
  scrollEventThrottle={16}  // 60 FPS = 16ms per frame
/>

// With Reanimated - handler runs on UI thread
<Animated.ScrollView
  onScroll={animatedScrollHandler}
  scrollEventThrottle={16}  // Still set for smooth tracking
/>
```

**Avoid setState during gestures:**

```tsx
// Bad: setState during gesture
const gesture = Gesture.Pan().onUpdate((event) => {
  runOnJS(setPosition)({ x: event.x, y: event.y })  // Re-render!
})

// Good: shared values during gesture, sync after
const position = useSharedValue({ x: 0, y: 0 })

const gesture = Gesture.Pan()
  .onUpdate((event) => {
    position.value = { x: event.translationX, y: event.translationY }
  })
  .onEnd(() => {
    // Sync to React state only when gesture ends
    runOnJS(syncPosition)(position.value)
  })
```

Reference: [Reanimated Scroll Handler](https://docs.swmansion.com/react-native-reanimated/docs/scroll/useAnimatedScrollHandler/)
