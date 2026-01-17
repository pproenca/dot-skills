---
title: Prefer Transform Animations Over Layout Animations
impact: MEDIUM
impactDescription: avoids layout recalculation on every frame
tags: anim, transform, layout, performance
---

## Prefer Transform Animations Over Layout Animations

Animating `transform` properties (translateX, scale, rotate) is significantly faster than animating layout properties (width, height, margin) because transforms don't trigger layout recalculation.

**Incorrect (animates layout properties):**

```typescript
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
} from 'react-native-reanimated'

function ExpandingCard() {
  const height = useSharedValue(100)

  const animatedStyle = useAnimatedStyle(() => ({
    height: height.value,  // Triggers layout recalculation
  }))

  const expand = () => {
    height.value = withTiming(300)
  }

  return (
    <Animated.View style={[styles.card, animatedStyle]}>
      <CardContent />
    </Animated.View>
  )
}
// Layout recalculates on every animation frame
```

**Correct (uses transform for visual effect):**

```typescript
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
} from 'react-native-reanimated'

function ExpandingCard() {
  const scale = useSharedValue(1)

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scaleY: scale.value }],  // No layout recalculation
  }))

  const expand = () => {
    scale.value = withTiming(1.5)
  }

  return (
    <Animated.View style={[styles.card, animatedStyle]}>
      <CardContent />
    </Animated.View>
  )
}
// GPU-accelerated, no layout work
```

**When layout animation is unavoidable, use LayoutAnimation:**

```typescript
import { LayoutAnimation, UIManager, Platform } from 'react-native'

// Enable on Android
if (Platform.OS === 'android') {
  UIManager.setLayoutAnimationEnabledExperimental?.(true)
}

function ExpandingList() {
  const [expanded, setExpanded] = useState(false)

  const toggleExpand = () => {
    LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut)
    setExpanded(!expanded)
  }

  return (
    <View style={{ height: expanded ? 300 : 100 }}>
      <ListContent />
    </View>
  )
}
```

**Performance hierarchy (fastest to slowest):**
1. `opacity` - GPU compositing only
2. `transform` - GPU transform matrix
3. `backgroundColor` - repaint (no layout)
4. `width/height` - full layout + repaint

Reference: [Reanimated Performance Guide](https://docs.swmansion.com/react-native-reanimated/docs/guides/performance/)
