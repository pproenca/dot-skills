---
title: Animate on the UI Thread With Reanimated Worklets
impact: HIGH
impactDescription: maintains 60-120fps during gestures and transitions
tags: perf, reanimated, ui-thread, animation
---

## Animate on the UI Thread With Reanimated Worklets

Driving an animation through React state re-renders the component on every frame, so under any JS-thread load the motion stutters. Reanimated runs the animation as a worklet on the UI thread using shared values, so it holds frame rate independently of React rendering.

**Incorrect (animating via React state):**

```typescript
const [offset, setOffset] = useState(-40)
useEffect(() => {
  const id = setInterval(() => setOffset((o) => Math.min(o + 2, 0)), 16) // re-render per frame
  return () => clearInterval(id)
}, [])
return <Animated.View style={{ transform: [{ translateX: offset }] }} />
// Each frame round-trips through React state; the slide stutters under load.
```

**Correct (a shared value on the UI thread):**

```typescript
import Animated, { useSharedValue, useAnimatedStyle, withTiming } from 'react-native-reanimated'

function SlideIn({ children }: PropsWithChildren) {
  const x = useSharedValue(-40)
  useEffect(() => { x.value = withTiming(0, { duration: 200 }) }, [])
  const style = useAnimatedStyle(() => ({ transform: [{ translateX: x.value }] }))
  return <Animated.View style={style}>{children}</Animated.View>
}
// The worklet animates on the UI thread, holding frame rate without React renders.
```

Reference: [Reanimated performance](https://docs.swmansion.com/react-native-reanimated/docs/guides/performance/)
