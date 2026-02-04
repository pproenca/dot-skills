---
title: Enable Native Driver for Animations
impact: HIGH
impactDescription: consistent 60 FPS vs 15-30 FPS under JS load
tags: anim, native-driver, animated, performance
---

## Enable Native Driver for Animations

The Animated API runs on the JS thread by default, causing jank when the thread is busy. Enable `useNativeDriver: true` to run animations entirely on the UI thread, achieving smooth 60 FPS regardless of JS load.

**Incorrect (JS thread animation, drops frames under load):**

```typescript
// components/FadeInView.tsx
export function FadeInView({ children }: Props) {
  const opacity = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(opacity, {
      toValue: 1,
      duration: 300,
      useNativeDriver: false,  // Runs on JS thread
    }).start();
  }, []);

  return <Animated.View style={{ opacity }}>{children}</Animated.View>;
}
```

**Correct (native thread animation, always 60 FPS):**

```typescript
// components/FadeInView.tsx
export function FadeInView({ children }: Props) {
  const opacity = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(opacity, {
      toValue: 1,
      duration: 300,
      useNativeDriver: true,  // Runs on UI thread
    }).start();
  }, []);

  return <Animated.View style={{ opacity }}>{children}</Animated.View>;
}
```

**Native driver limitations:**
- Only supports non-layout properties: `transform`, `opacity`
- Cannot animate `width`, `height`, `backgroundColor`
- Use Reanimated for layout property animations

Reference: [React Native Animations](https://reactnative.dev/docs/animations#using-the-native-driver)
