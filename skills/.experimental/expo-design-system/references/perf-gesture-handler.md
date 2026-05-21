---
title: Handle Gestures With Gesture Handler, Not PanResponder
impact: HIGH
impactDescription: prevents touch handling from blocking the JavaScript thread
tags: perf, gestures, gesture-handler, native
---

## Handle Gestures With Gesture Handler, Not PanResponder

`PanResponder` delivers every move event to the JS thread, so calling `setState` per move makes dragging a body-chart marker lag whenever JS is busy. React Native Gesture Handler processes gestures natively and pairs with Reanimated shared values, so the drag stays smooth on the UI thread.

**Incorrect (PanResponder updates state on the JS thread):**

```typescript
const [x, setX] = useState(0)
const responder = PanResponder.create({
  onMoveShouldSetPanResponder: () => true,
  onPanResponderMove: (_, g) => setX(g.dx), // setState per move event, on the JS thread
})
return <View {...responder.panHandlers} style={{ transform: [{ translateX: x }] }} />
// Dragging a marker lags because each move crosses to JS and re-renders.
```

**Correct (Gesture Handler plus Reanimated on the UI thread):**

```typescript
import { Gesture, GestureDetector } from 'react-native-gesture-handler'
import Animated, { useSharedValue, useAnimatedStyle } from 'react-native-reanimated'

function DraggableMarker() {
  const x = useSharedValue(0)
  const pan = Gesture.Pan().onChange((e) => { x.value += e.changeX }) // runs on the UI thread
  const style = useAnimatedStyle(() => ({ transform: [{ translateX: x.value }] }))
  return <GestureDetector gesture={pan}><Animated.View style={style} /></GestureDetector>
}
```

Reference: [React Native Gesture Handler](https://docs.swmansion.com/react-native-gesture-handler/)
