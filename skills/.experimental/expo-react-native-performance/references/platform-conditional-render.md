---
title: Use Platform-Specific Optimizations Conditionally
impact: LOW-MEDIUM
impactDescription: 2-3× better performance on target platform
tags: platform, conditional, ios, android
---

## Use Platform-Specific Optimizations Conditionally

iOS and Android have different performance characteristics. Apply platform-specific optimizations where they matter most.

**Incorrect (same approach for both platforms):**

```typescript
// components/AnimatedCard.tsx
import { Animated } from 'react-native';

export function AnimatedCard({ children, visible }: Props) {
  const opacity = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(opacity, {
      toValue: visible ? 1 : 0,
      duration: 300,
      // Can't use native driver with shadow on Android
      useNativeDriver: true,
    }).start();
  }, [visible]);

  return (
    <Animated.View style={[styles.card, { opacity }]}>
      {children}
    </Animated.View>
  );
}
```

**Correct (platform-optimized):**

```typescript
// components/AnimatedCard.tsx
import { Platform, Animated } from 'react-native';
import Reanimated, { useAnimatedStyle, withTiming } from 'react-native-reanimated';

export function AnimatedCard({ children, visible }: Props) {
  // iOS: Use Animated API (lightweight for simple opacity)
  // Android: Use Reanimated (better performance with shadows)
  const AnimatedContainer = Platform.select({
    ios: AnimatedContainerIOS,
    android: AnimatedContainerAndroid,
  })!;

  return <AnimatedContainer visible={visible}>{children}</AnimatedContainer>;
}

function AnimatedContainerIOS({ children, visible }: Props) {
  const opacity = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    Animated.timing(opacity, {
      toValue: visible ? 1 : 0,
      duration: 300,
      useNativeDriver: true,
    }).start();
  }, [visible]);
  return <Animated.View style={{ opacity }}>{children}</Animated.View>;
}

function AnimatedContainerAndroid({ children, visible }: Props) {
  const style = useAnimatedStyle(() => ({
    opacity: withTiming(visible ? 1 : 0, { duration: 300 }),
  }));
  return <Reanimated.View style={style}>{children}</Reanimated.View>;
}
```

**Common platform differences:**
- Shadow rendering (expensive on Android)
- List scrolling (FlashList critical on Android)
- Font rendering (iOS more efficient)

Reference: [Platform Module](https://reactnative.dev/docs/platform-specific-code)
