---
title: Run animations on the UI thread
impact: MEDIUM-HIGH
impactDescription: maintains 60fps by animating off the JS thread
tags: motion, reanimated, native-driver, performance
---

## Run animations on the UI thread

The JavaScript thread also handles your component renders, network callbacks, and state updates, so an animation driven by `setState` or `Animated` without the native driver stutters whenever JS is busy — exactly when a screen is loading and animating at the same time. Reanimated runs the animation in a worklet on the UI thread, decoupled from JS, so it holds 60fps under load. iOS animations never drop frames; matching that is what makes motion feel native.

**Incorrect (animation tied to the JS thread):**

```tsx
import { useState, useEffect } from 'react';
import { View } from 'react-native';

// Re-rendering every frame on the JS thread; janks while the list loads
function FadeInCard({ children }: { children: React.ReactNode }) {
  const [opacity, setOpacity] = useState(0);
  useEffect(() => {
    const id = setInterval(() => setOpacity((o) => Math.min(o + 0.1, 1)), 16);
    return () => clearInterval(id);
  }, []);
  return <View style={{ opacity }}>{children}</View>;
}
```

**Correct (worklet animation on the UI thread):**

```tsx
import Animated, { useSharedValue, useAnimatedStyle, withTiming } from 'react-native-reanimated';
import { useEffect } from 'react';

// Animation runs in a UI-thread worklet, so it stays smooth while JS is busy
function FadeInCard({ children }: { children: React.ReactNode }) {
  const opacity = useSharedValue(0);
  useEffect(() => { opacity.value = withTiming(1, { duration: 250 }); }, []);
  const style = useAnimatedStyle(() => ({ opacity: opacity.value }));
  return <Animated.View style={style}>{children}</Animated.View>;
}
```

Reference: [React Native Reanimated — Performance](https://docs.swmansion.com/react-native-reanimated/docs/guides/performance/)
