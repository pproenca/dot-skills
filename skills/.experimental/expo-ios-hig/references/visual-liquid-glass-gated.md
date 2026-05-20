---
title: Apply Liquid Glass through a version-gated native view
impact: HIGH
impactDescription: prevents crashes on pre-iOS-26 while enabling glass
tags: visual, liquid-glass, expo-glass-effect, ios26
---

## Apply Liquid Glass through a version-gated native view

iOS 26's Liquid Glass is a real material rendered by the system — it lenses and refracts the content behind it and reacts to motion. A semi-transparent colored `View` is a flat fake that misses all of that and looks cheap beside genuine system glass. Use `expo-glass-effect`'s `GlassView`, which wraps the native effect, and gate it with `isGlassEffectAPIAvailable()` so devices below iOS 26 fall back to a solid surface instead of crashing.

**Incorrect (fake glass with a translucent view):**

```tsx
import { View } from 'react-native';

// A flat translucent overlay: no lensing, no refraction, not the system material
function TrailOverlayBar() {
  return <View style={{ backgroundColor: 'rgba(255,255,255,0.6)' }}><TrailControls /></View>;
}
```

**Correct (native glass, gated for availability):**

```tsx
import { View } from 'react-native';
import { GlassView, isGlassEffectAPIAvailable } from 'expo-glass-effect';

// Real Liquid Glass on iOS 26; a solid surface elsewhere instead of a crash
function TrailOverlayBar() {
  if (!isGlassEffectAPIAvailable()) {
    return <View style={styles.solidSurface}><TrailControls /></View>;
  }
  return <GlassView style={styles.glassSurface}><TrailControls /></GlassView>;
}
```

**When NOT to use this pattern:**

- Over already-glass system chrome (navigation/tab bars) — stacking glass on glass muddies both; let the system surface provide the material.

Reference: [Expo — GlassEffect (expo-glass-effect)](https://docs.expo.dev/versions/latest/sdk/glass-effect/) · [Apple — Liquid Glass](https://developer.apple.com/documentation/TechnologyOverviews/liquid-glass)
