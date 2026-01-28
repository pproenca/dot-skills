---
title: Use Layout Animations for Mount/Unmount
impact: MEDIUM
impactDescription: 50-100ms saved per animation setup, prevents state bugs
tags: anim, layout-animations, reanimated, entering, exiting
---

## Use Layout Animations for Mount/Unmount

Reanimated's layout animations handle enter/exit transitions automatically without managing animation state.

**Incorrect (manual animation state):**

```tsx
function ToastNotification({ message, visible, onDismiss }) {
  const [shouldRender, setShouldRender] = useState(visible)
  const opacity = useSharedValue(0)
  const translateY = useSharedValue(-50)

  useEffect(() => {
    if (visible) {
      setShouldRender(true)
      opacity.value = withTiming(1)
      translateY.value = withSpring(0)
    } else {
      opacity.value = withTiming(0, {}, (finished) => {
        if (finished) {
          runOnJS(setShouldRender)(false)
        }
      })
      translateY.value = withTiming(-50)
    }
  }, [visible])

  if (!shouldRender) return null

  // Complex manual animation management
  return (
    <Animated.View style={[styles.toast, animatedStyle]}>
      <Text>{message}</Text>
    </Animated.View>
  )
}
```

**Correct (layout animations):**

```tsx
import Animated, {
  FadeIn,
  FadeOut,
  SlideInUp,
  SlideOutUp,
  Layout,
} from 'react-native-reanimated'

function ToastNotification({ message, visible }) {
  if (!visible) return null

  return (
    <Animated.View
      entering={SlideInUp.springify().damping(15)}
      exiting={FadeOut.duration(200)}
      style={styles.toast}
    >
      <Text>{message}</Text>
    </Animated.View>
  )
}
// Automatic enter/exit animations
```

**Built-in animation presets:**

```tsx
import Animated, {
  // Fade animations
  FadeIn, FadeOut, FadeInUp, FadeOutDown,
  // Slide animations
  SlideInLeft, SlideOutRight, SlideInDown, SlideOutUp,
  // Zoom animations
  ZoomIn, ZoomOut, ZoomInRotate,
  // Bounce animations
  BounceIn, BounceOut,
  // Flip animations
  FlipInXUp, FlipOutXDown,
  // Lightspeed animations
  LightSpeedInLeft, LightSpeedOutRight,
} from 'react-native-reanimated'

function AnimatedList({ items }) {
  return (
    <View>
      {items.map((item, index) => (
        <Animated.View
          key={item.id}
          entering={FadeInUp.delay(index * 100)}
          exiting={FadeOutDown}
          layout={Layout.springify()}  // Animate layout changes
        >
          <ListItem item={item} />
        </Animated.View>
      ))}
    </View>
  )
}
```

**Customize animation parameters:**

```tsx
<Animated.View
  entering={
    SlideInRight
      .duration(500)
      .delay(200)
      .springify()
      .damping(12)
      .stiffness(100)
  }
  exiting={
    FadeOut
      .duration(300)
      .easing(Easing.bezier(0.25, 0.1, 0.25, 1))
  }
>
  {children}
</Animated.View>
```

**Custom keyframe animations:**

```tsx
import { Keyframe } from 'react-native-reanimated'

const customEntering = new Keyframe({
  0: {
    opacity: 0,
    transform: [{ scale: 0.5 }, { rotate: '-45deg' }],
  },
  50: {
    opacity: 0.5,
    transform: [{ scale: 1.1 }, { rotate: '10deg' }],
  },
  100: {
    opacity: 1,
    transform: [{ scale: 1 }, { rotate: '0deg' }],
  },
}).duration(600)

<Animated.View entering={customEntering}>
  <Badge />
</Animated.View>
```

**Animate list reordering:**

```tsx
function ReorderableList({ items }) {
  return (
    <View>
      {items.map(item => (
        <Animated.View
          key={item.id}
          layout={Layout.springify().damping(15)}  // Smooth reorder
        >
          <ListItem item={item} />
        </Animated.View>
      ))}
    </View>
  )
}
// Items smoothly animate to new positions when list reorders
```

Reference: [Reanimated Layout Animations](https://docs.swmansion.com/react-native-reanimated/docs/layout-animations/entering-exiting-animations/)
