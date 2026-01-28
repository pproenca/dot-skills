---
title: Limit Concurrent Animations
impact: LOW-MEDIUM
impactDescription: prevents frame drops from animation overload
tags: anim, concurrent, performance, reanimated, limits
---

## Limit Concurrent Animations

Too many simultaneous animations overwhelm even the UI thread. Keep concurrent animations under platform-specific limits.

**Incorrect (animating too many elements):**

```tsx
function AnimatedGrid({ items }) {
  return (
    <View style={styles.grid}>
      {items.map((item, index) => (
        <Animated.View
          key={item.id}
          // 500 items all animating at once!
          entering={FadeIn.delay(index * 10)}
          style={styles.gridItem}
        >
          <GridItem item={item} />
        </Animated.View>
      ))}
    </View>
  )
}
// Frame drops on low-end Android devices
```

**Correct (limit concurrent animations):**

```tsx
function AnimatedGrid({ items }) {
  // Only animate visible items (first ~20)
  const visibleCount = 20

  return (
    <View style={styles.grid}>
      {items.map((item, index) => (
        <Animated.View
          key={item.id}
          entering={
            index < visibleCount
              ? FadeIn.delay(index * 50)  // Staggered for visible
              : undefined  // No animation for off-screen
          }
          style={styles.gridItem}
        >
          <GridItem item={item} />
        </Animated.View>
      ))}
    </View>
  )
}
```

**Batch animations with useAnimatedReaction:**

```tsx
import { useAnimatedReaction, runOnJS } from 'react-native-reanimated'

function StaggeredList({ items, isAnimating }) {
  const animatedCount = useSharedValue(0)

  // Animate items in batches
  useAnimatedReaction(
    () => isAnimating,
    (shouldAnimate) => {
      if (shouldAnimate) {
        // Animate 5 items per batch, 100ms between batches
        const totalBatches = Math.ceil(items.length / 5)
        for (let batch = 0; batch < totalBatches; batch++) {
          animatedCount.value = withDelay(
            batch * 100,
            withTiming((batch + 1) * 5)
          )
        }
      }
    }
  )

  return (
    <View>
      {items.map((item, index) => (
        <AnimatedItem
          key={item.id}
          item={item}
          index={index}
          animatedCount={animatedCount}
        />
      ))}
    </View>
  )
}

function AnimatedItem({ item, index, animatedCount }) {
  const style = useAnimatedStyle(() => ({
    opacity: index < animatedCount.value ? 1 : 0,
    transform: [{
      translateY: index < animatedCount.value ? 0 : 20,
    }],
  }))

  return (
    <Animated.View style={style}>
      <ItemContent item={item} />
    </Animated.View>
  )
}
```

**Platform-specific limits:**

```tsx
import { Platform } from 'react-native'

// Recommended concurrent animation limits
const MAX_CONCURRENT_ANIMATIONS = Platform.select({
  ios: 500,      // iOS handles more
  android: 100,  // Android varies widely by device
})

function AnimatedList({ items }) {
  const shouldAnimate = items.length <= MAX_CONCURRENT_ANIMATIONS

  return (
    <FlatList
      data={items}
      renderItem={({ item, index }) => (
        <Animated.View
          entering={shouldAnimate ? FadeIn.delay(index * 20) : undefined}
        >
          <ListItem item={item} />
        </Animated.View>
      )}
    />
  )
}
```

**Use Skia for many animated elements:**

```tsx
// For 100+ animated elements, consider react-native-skia
import { Canvas, Circle, Group } from '@shopify/react-native-skia'

function ParticleAnimation({ particles }) {
  return (
    <Canvas style={{ flex: 1 }}>
      <Group>
        {particles.map((particle) => (
          <Circle
            key={particle.id}
            cx={particle.x}
            cy={particle.y}
            r={particle.radius}
            color={particle.color}
          />
        ))}
      </Group>
    </Canvas>
  )
}
// Skia renders on GPU, handles thousands of elements
```

**Guidelines:**
- Low-end Android: max 100 concurrent animations
- High-end Android: max 200 concurrent animations
- iOS: max 500 concurrent animations
- For more: use Skia or reduce to essential animations

Reference: [Reanimated Performance](https://docs.swmansion.com/react-native-reanimated/docs/guides/performance/)
