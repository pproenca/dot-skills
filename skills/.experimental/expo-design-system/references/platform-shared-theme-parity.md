---
title: Drive Web and Native From One Theme, With a Known Divergence Map
impact: HIGH
impactDescription: prevents web and native styling from drifting through a forked theme
tags: platform, web, theme, safe-area
---

## Drive Web and Native From One Theme, With a Known Divergence Map

The point of Unistyles is that one theme renders on web and native, so forking a separate web stylesheet reintroduces the drift tokens exist to prevent. Keep a single theme, and handle the few places platforms legitimately differ explicitly — chiefly safe-area insets, which are real on iOS but `0` on web, so spacing that leans on them alone collapses on web.

**Incorrect (header spacing depends on insets — flush to the top on web):**

```typescript
const styles = StyleSheet.create((theme, rt) => ({
  header: { paddingTop: rt.insets.top }, // rt.insets.top is 0 on web → the header jams against the edge
}))
```

**Correct (a token floor under the inset):**

```typescript
const styles = StyleSheet.create((theme, rt) => ({
  header: { paddingTop: Math.max(rt.insets.top, theme.space.md) }, // the device notch on iOS, token spacing on web
}))
```

Known divergences to design for: safe-area insets (0 on web), haptics (no-op on web — see [`platform-guard-native-only`](platform-guard-native-only.md)), and hover/cursor (web-only — see [`platform-web-pseudo-states`](platform-web-pseudo-states.md)). For iOS-specific native-feel decisions beyond styling — native navigation, system controls, Liquid Glass — use the `expo-ios-hig` skill.

Reference: [Unistyles mini runtime (insets)](https://www.unistyl.es/v3/references/mini-runtime/)
