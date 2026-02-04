---
title: Animate Transform Instead of Dimensions
impact: HIGH
impactDescription: eliminates 60× layout recalculations per second
tags: anim, transform, scale, performance
---

## Animate Transform Instead of Dimensions

Animating `width` and `height` triggers layout recalculation on every frame. Use `transform: [{ scale }]` instead, which is GPU-accelerated and doesn't affect layout.

**Incorrect (animating dimensions, causes reflow):**

```typescript
// components/PulsingButton.tsx
export function PulsingButton({ onPress, children }: Props) {
  const size = useRef(new Animated.Value(100)).current;

  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(size, { toValue: 110, duration: 500, useNativeDriver: false }),
        Animated.timing(size, { toValue: 100, duration: 500, useNativeDriver: false }),
      ])
    ).start();
  }, []);

  return (
    <Animated.View style={{ width: size, height: size }}>
      <Pressable onPress={onPress}>{children}</Pressable>
    </Animated.View>
  );
}
// Layout recalculated 60× per second, affects surrounding elements
```

**Correct (animating transform, GPU-accelerated):**

```typescript
// components/PulsingButton.tsx
export function PulsingButton({ onPress, children }: Props) {
  const scale = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(scale, { toValue: 1.1, duration: 500, useNativeDriver: true }),
        Animated.timing(scale, { toValue: 1, duration: 500, useNativeDriver: true }),
      ])
    ).start();
  }, []);

  return (
    <Animated.View style={{ transform: [{ scale }] }}>
      <Pressable onPress={onPress}>{children}</Pressable>
    </Animated.View>
  );
}
// GPU-accelerated, no layout impact, native driver compatible
```

**Transform properties (all native driver compatible):**
- `scale`, `scaleX`, `scaleY`
- `translateX`, `translateY`
- `rotate`, `rotateX`, `rotateY`

Reference: [React Native Animations](https://reactnative.dev/docs/animations)
