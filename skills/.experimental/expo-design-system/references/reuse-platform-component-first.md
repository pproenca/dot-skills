---
title: Reach for a Native Control Before Reimplementing One in JavaScript
impact: HIGH
impactDescription: prevents hand-built controls that lose native behavior and accessibility
tags: reuse, expo-ui, native, accessibility
---

## Reach for a Native Control Before Reimplementing One in JavaScript

Rebuilding a switch, picker, segmented control, or menu out of `Pressable` and animated `View`s is the classic local optimum — it looks right in isolation while silently losing platform animation, haptics, accessibility, and dark-mode behavior. Reach for the existing control first: React Native's built-in `Switch` for cross-platform cases, and `@expo/ui/swift-ui` for richer iOS-native controls (segmented control, native picker, date picker) behind a platform split.

**Incorrect (hand-rolled toggle):**

```typescript
// loses the native animation, haptics, VoiceOver state, and dark-mode track color
function Toggle({ on, onChange }: { on: boolean; onChange: (v: boolean) => void }) {
  return (
    <Pressable onPress={() => onChange(!on)} style={[styles.track, on && styles.trackOn]}>
      <View style={[styles.thumb, on && styles.thumbOn]} />
    </Pressable>
  )
}
```

**Correct (use the platform's own control):**

```typescript
import { Switch } from 'react-native' // native on iOS/Android, real control on web — a11y for free

<Switch value={on} onValueChange={onChange} />
```

For controls React Native lacks, use `@expo/ui/swift-ui` on iOS behind a `.ios.tsx` split (see [`platform-divergence-split`](platform-divergence-split.md)) rather than a JavaScript reimplementation; the `expo-ui` skill documents that component API.

Reference: [@expo/ui SDK](https://docs.expo.dev/versions/latest/sdk/ui/)
