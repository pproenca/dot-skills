---
title: Use Reanimated for Complex Animations
impact: HIGH
impactDescription: 60-120 FPS for all properties vs 15-30 FPS
tags: anim, reanimated, worklets, performance
---

## Use Reanimated for Complex Animations

React Native Reanimated runs animation logic on the UI thread using worklets, bypassing the JS bridge entirely. This enables smooth 60-120 FPS animations for any property, including layout properties the native driver doesn't support.

**Incorrect (Animated API with layout, causes jank):**

```typescript
// components/ExpandingCard.tsx
export function ExpandingCard({ expanded }: Props) {
  const height = useRef(new Animated.Value(100)).current;

  useEffect(() => {
    Animated.timing(height, {
      toValue: expanded ? 300 : 100,
      duration: 300,
      useNativeDriver: false,  // Required for height, but janky
    }).start();
  }, [expanded]);

  return <Animated.View style={{ height }} />;
}
```

**Correct (Reanimated with worklets):**

```typescript
// components/ExpandingCard.tsx
import Animated, { useAnimatedStyle, withTiming } from 'react-native-reanimated';

export function ExpandingCard({ expanded }: Props) {
  const animatedStyle = useAnimatedStyle(() => ({
    height: withTiming(expanded ? 300 : 100, { duration: 300 }),
  }));

  return <Animated.View style={animatedStyle} />;
}
// Runs entirely on UI thread, smooth 60+ FPS
```

**Reanimated advantages:**
- Animates any style property (height, width, backgroundColor)
- Worklets execute on UI thread
- Gesture-driven animations with react-native-gesture-handler
- Supports 120 FPS on ProMotion displays

Reference: [React Native Reanimated](https://docs.swmansion.com/react-native-reanimated/)
