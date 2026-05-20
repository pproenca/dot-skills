---
title: Present secondary tasks as sheets with detents
impact: HIGH
impactDescription: enables partial-height sheets with grabber and swipe-to-dismiss
tags: nav, sheet, detents, modality
---

## Present secondary tasks as sheets with detents

A quick task — filtering trails, adding a note — shown as a full-screen modal hides the context the user came from and feels heavier than the task warrants. A native sheet at a medium detent keeps the parent screen visible behind it, exposes the grabber and swipe-to-dismiss gesture, and on iOS 26 adopts the Liquid Glass sheet treatment. Expo Router's native stack exposes these as screen options.

**Incorrect (full-screen modal for a small task):**

```tsx
import { Stack } from 'expo-router';

// Full-screen cover for a one-field filter hides the trail list behind it
export default function FilterModalLayout() {
  return <Stack.Screen options={{ presentation: 'fullScreenModal' }} />;
}
```

**Correct (resizable form sheet with detents):**

```tsx
import { Stack } from 'expo-router';

// Half-height sheet keeps the list visible, with grabber and swipe-to-dismiss
export default function FilterModalLayout() {
  return (
    <Stack.Screen
      options={{
        presentation: 'formSheet',
        sheetAllowedDetents: [0.5, 1.0],
        sheetGrabberVisible: true,
      }}
    />
  );
}
```

Reference: [Expo — Apple Maps style Liquid Glass sheets](https://expo.dev/blog/how-to-create-apple-maps-style-liquid-glass-sheets)
