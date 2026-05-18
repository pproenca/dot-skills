---
title: Update ObservableState from Worklets — Not From the JS Thread
impact: MEDIUM
impactDescription: prevents the development-mode warning and ensures atomic same-frame updates on the native side
tags: state, observable, worklet, threading
---

## Update ObservableState from Worklets — Not From the JS Thread

Writing to `ObservableState.value` from the JS thread triggers a development-mode console warning ("set from JS thread, result may be unexpected"). The state update reaches the native side asynchronously, so the view can render an out-of-sync intermediate frame. Worklets run on the UI runtime and apply the write synchronously in the current frame — gestures, animations, and rapid drag updates feel instant.

**Incorrect (write from JS thread — async update, dev warning):**

```tsx
import { Host, Slider, useNativeState } from '@expo/ui/swift-ui';

const volume = useNativeState(50);

<Host matchContents>
  <Slider
    value={volume.value}
    min={0}
    max={100}
    onValueChange={(next) => {
      volume.value = next;
    }}
  />
</Host>
```

**Correct (worklet handler — writes on the UI runtime, no warning):**

```tsx
import { Host, Slider, useNativeState } from '@expo/ui/swift-ui';

const volume = useNativeState(50);

<Host matchContents>
  <Slider
    value={volume.value}
    min={0}
    max={100}
    onValueChange={(next) => {
      'worklet';
      volume.value = next;
    }}
  />
</Host>
```

**When NOT to use this pattern:**

- One-shot writes after a user explicitly commits (form submit, save button). The dev warning fires once but the user experience is unaffected.

Reference: [useNativeState worklet guidance](https://github.com/expo/expo/blob/main/packages/expo-ui/src/State/useNativeState.ts)
