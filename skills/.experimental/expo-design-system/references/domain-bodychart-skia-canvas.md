---
title: Draw Body-Chart Annotations on a Skia Canvas
impact: MEDIUM-HIGH
impactDescription: maintains 60fps freehand drawing off the JavaScript thread
tags: domain, skia, canvas, drawing
---

## Draw Body-Chart Annotations on a Skia Canvas

Rendering each touch point of a body-chart annotation as an absolutely positioned `View` creates hundreds of nodes per stroke, so the chart stutters and memory climbs. A Skia `Canvas` renders the whole stroke as a single GPU-accelerated vector path, independent of the JS thread.

**Incorrect (one View per drawn point):**

```typescript
// each touch point becomes an absolutely positioned dot
{points.map((point, index) => (
  <View key={index}
    style={{ position: 'absolute', left: point.x, top: point.y, width: 4, height: 4 }} />
))}
// A single stroke creates hundreds of Views; the body chart stutters and memory grows.
```

**Correct (a Skia Path on a Canvas):**

```typescript
import { Canvas, Path } from '@shopify/react-native-skia'
import type { SkPath } from '@shopify/react-native-skia'

function BodyChartLayer({ strokePath }: { strokePath: SkPath }) {
  return (
    <Canvas style={{ flex: 1 }}>
      <Path path={strokePath} style="stroke" strokeWidth={3} color="#DC2626" />
    </Canvas>
  )
}
// One Skia Path renders the entire stroke on the GPU, off the JS thread.
```

Reference: [React Native Skia](https://shopify.github.io/react-native-skia/)
