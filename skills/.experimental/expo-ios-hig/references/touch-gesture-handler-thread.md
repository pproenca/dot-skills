---
title: Drive interactive gestures with Gesture Handler
impact: HIGH
impactDescription: maintains 60fps gestures off the JS thread
tags: touch, gesture-handler, reanimated, performance
---

## Drive interactive gestures with Gesture Handler

`PanResponder` runs gesture logic on the JavaScript thread, so any work happening there — a list re-render, a network callback — stalls the gesture and the drag visibly stutters or lags the finger. `react-native-gesture-handler` recognizes and tracks gestures on the UI thread, and paired with Reanimated worklets the follow-the-finger animation also runs off the JS thread, staying smooth under load. Native iOS interactions never lag the finger; yours shouldn't either.

**Incorrect (gesture on the JS thread via PanResponder):**

```tsx
import { PanResponder, Animated } from 'react-native';

// Drag tracking runs on the JS thread, so it stutters whenever JS is busy
const pan = useRef(new Animated.Value(0)).current;
const responder = PanResponder.create({
  onMoveShouldSetPanResponder: () => true,
  onPanResponderMove: (_, g) => pan.setValue(g.dx),
});
```

**Correct (gesture and animation on the UI thread):**

```tsx
import { Gesture, GestureDetector } from 'react-native-gesture-handler';
import Animated, { useSharedValue, useAnimatedStyle } from 'react-native-reanimated';

// Pan is tracked and animated on the UI thread, so it follows the finger under load
const offsetX = useSharedValue(0);
const pan = Gesture.Pan().onChange((e) => { offsetX.value += e.changeX; });
const style = useAnimatedStyle(() => ({ transform: [{ translateX: offsetX.value }] }));
```

Reference: [React Native Gesture Handler](https://docs.swmansion.com/react-native-gesture-handler/docs/)
