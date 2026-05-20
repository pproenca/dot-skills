---
title: Show content-shaped placeholders while loading
impact: MEDIUM
impactDescription: reduces perceived wait with content-shaped placeholders
tags: motion, loading, skeletons, feedback
---

## Show content-shaped placeholders while loading

A full-screen spinner tells the user nothing about what is coming and makes the wait feel longer because the screen is empty until everything arrives. A skeleton that mirrors the eventual layout previews the structure, so the content appears to "fill in" rather than pop in, which reads as faster even at the same latency. Reserve spinners for short, indeterminate waits and use skeletons for primary content.

**Incorrect (blank screen behind a centered spinner):**

```tsx
import { ActivityIndicator, View } from 'react-native';

// Empty screen until everything loads; the wait feels long and contentless
function TrailsScreen({ isLoading, trails }: TrailsScreenProps) {
  if (isLoading) return <View style={styles.center}><ActivityIndicator /></View>;
  return <TrailList trails={trails} />;
}
```

**Correct (skeleton mirrors the final layout):**

```tsx
import { TrailListSkeleton } from '../components/TrailListSkeleton';

// Skeleton rows preview the layout, so content fills in instead of popping in
function TrailsScreen({ isLoading, trails }: TrailsScreenProps) {
  if (isLoading) return <TrailListSkeleton rows={8} />;
  return <TrailList trails={trails} />;
}
```

Reference: [Apple HIG — Loading](https://developer.apple.com/design/human-interface-guidelines/loading)
