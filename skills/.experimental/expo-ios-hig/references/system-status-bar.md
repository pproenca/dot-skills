---
title: Match the status bar style to the content behind it
impact: MEDIUM
impactDescription: prevents an invisible status bar over content
tags: system, status-bar, expo-status-bar, appearance
---

## Match the status bar style to the content behind it

The status bar text and icons are drawn over your content, so a dark status bar on a dark hero image vanishes, and a light one on a white screen is invisible. Leaving it fixed means it disappears on whichever appearance doesn't match. Use `expo-status-bar` with `style="auto"` so it inverts against the current color scheme, or set it per screen for full-bleed media that doesn't follow the scheme.

**Incorrect (fixed style regardless of content):**

```tsx
import { StatusBar } from 'expo-status-bar';

// Dark icons stay dark in dark mode and over dark imagery — they disappear
function App() {
  return (
    <>
      <StatusBar style="dark" />
      <RootNavigator />
    </>
  );
}
```

**Correct (style follows the appearance):**

```tsx
import { StatusBar } from 'expo-status-bar';

// Inverts against the color scheme, so the bar stays legible in both modes
function App() {
  return (
    <>
      <StatusBar style="auto" />
      <RootNavigator />
    </>
  );
}
```

Reference: [Expo — StatusBar (expo-status-bar)](https://docs.expo.dev/versions/latest/sdk/status-bar/)
