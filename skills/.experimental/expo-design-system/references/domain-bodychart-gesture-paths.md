---
title: Capture Drawing Strokes With Gestures and Shared Values
impact: MEDIUM
impactDescription: avoids a React state update per touch point
tags: domain, skia, gestures, reanimated
---

## Capture Drawing Strokes With Gestures and Shared Values

Accumulating drawn points into React state copies the whole array on every move event, so a long body-chart stroke drops frames as the array grows. Mutating a Skia path held in a Reanimated shared value lets points accumulate on the UI thread with no React render mid-stroke.

**Incorrect (state update and array copy per move):**

```typescript
const [points, setPoints] = useState<Point[]>([])
const pan = Gesture.Pan().onChange((e) => setPoints((prev) => [...prev, { x: e.x, y: e.y }]))
// Each move triggers a state update and a full array copy; long strokes drop frames.
```

**Correct (accumulate into a Skia path on the UI thread):**

```typescript
import { Skia, notifyChange } from '@shopify/react-native-skia'
import { useSharedValue } from 'react-native-reanimated'
import { Gesture } from 'react-native-gesture-handler'

function useStroke() {
  const path = useSharedValue(Skia.Path.Make())
  const pan = Gesture.Pan()
    .onStart((e) => { path.value.moveTo(e.x, e.y); notifyChange(path.value) })
    .onChange((e) => { path.value.lineTo(e.x, e.y); notifyChange(path.value) }) // repaint on UI thread
  return { path, pan }
}
// Points accumulate into the path on the UI thread; notifyChange repaints the
// Skia <Path> without a React render. (In-place mutation alone does not repaint.)
```

Reference: [React Native Skia](https://shopify.github.io/react-native-skia/), [Gesture Handler](https://docs.swmansion.com/react-native-gesture-handler/)
