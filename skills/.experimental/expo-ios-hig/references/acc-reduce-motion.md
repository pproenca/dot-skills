---
title: Honor the Reduce Motion setting
impact: MEDIUM
impactDescription: prevents vestibular discomfort from animation
tags: acc, reduce-motion, animation, accessibility-info
---

## Honor the Reduce Motion setting

Large parallax, zoom, and slide animations can cause real nausea and dizziness for users with vestibular sensitivity, which is why iOS exposes a Reduce Motion setting. An app that animates regardless ignores an explicit accessibility request. Read the setting with `useReducedMotion()` (or `AccessibilityInfo`) and substitute a cross-fade or an instant change for the large movement, keeping the same outcome without the motion.

**Incorrect (always run the large animation):**

```tsx
import { withSpring } from 'react-native-reanimated';

// Big slide-and-scale regardless of the user's Reduce Motion setting
function presentTrailCard(translateY: SharedValue<number>) {
  translateY.value = withSpring(0, { damping: 12 });
}
```

**Correct (substitute a calm transition when requested):**

```tsx
import { withSpring, withTiming, useReducedMotion } from 'react-native-reanimated';

// Falls back to a quick fade-equivalent timing when Reduce Motion is on
function usePresentTrailCard(translateY: SharedValue<number>) {
  const reduceMotion = useReducedMotion();
  return () => {
    translateY.value = reduceMotion ? withTiming(0, { duration: 120 }) : withSpring(0, { damping: 12 });
  };
}
```

Reference: [Apple HIG — Motion](https://developer.apple.com/design/human-interface-guidelines/motion)
