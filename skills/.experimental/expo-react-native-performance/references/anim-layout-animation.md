---
title: Use LayoutAnimation for Simple Transitions
impact: HIGH
impactDescription: 50% less code, native 60 FPS
tags: anim, layout-animation, transitions, native
---

## Use LayoutAnimation for Simple Transitions

For simple layout changes (showing/hiding, resizing), use `LayoutAnimation` instead of managing animation state. It automatically animates all layout changes in the next render using native animations.

**Incorrect (manual animation state management):**

```typescript
// components/ExpandableSection.tsx
export function ExpandableSection({ title, children }: Props) {
  const [expanded, setExpanded] = useState(false);
  const height = useRef(new Animated.Value(0)).current;

  const toggle = () => {
    setExpanded(!expanded);
    Animated.timing(height, {
      toValue: expanded ? 0 : 200,
      duration: 300,
      useNativeDriver: false,
    }).start();
  };

  return (
    <View>
      <Pressable onPress={toggle}><Text>{title}</Text></Pressable>
      <Animated.View style={{ height, overflow: 'hidden' }}>
        {children}
      </Animated.View>
    </View>
  );
}
```

**Correct (LayoutAnimation handles it):**

```typescript
// components/ExpandableSection.tsx
import { LayoutAnimation, UIManager, Platform } from 'react-native';

if (Platform.OS === 'android') {
  UIManager.setLayoutAnimationEnabledExperimental?.(true);
}

export function ExpandableSection({ title, children }: Props) {
  const [expanded, setExpanded] = useState(false);

  const toggle = () => {
    LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut);
    setExpanded(!expanded);
  };

  return (
    <View>
      <Pressable onPress={toggle}><Text>{title}</Text></Pressable>
      {expanded && children}
    </View>
  );
}
// Native animation applied automatically to layout change
```

**When to use LayoutAnimation:**
- Showing/hiding elements
- List item insertions/deletions
- Simple size changes

**When NOT to use:** Gesture-driven or interruptible animations.

Reference: [LayoutAnimation](https://reactnative.dev/docs/layoutanimation)
