---
title: Use useNativeState for Every Bridged Input Value
impact: MEDIUM
impactDescription: enables zero-bridge text updates and worklet-friendly writes — eliminates per-keystroke JS renders
tags: state, useNativeState, observable, bridge
---

## Use useNativeState for Every Bridged Input Value

`useNativeState<T>(initial)` returns an `ObservableState<T>` that lives on the native side. SwiftUI views read and write its `value` directly without crossing the JS bridge — TextField text, Slider value, Toggle state, Picker selection. Pairing every input with a native state instead of React `useState` is the canonical pattern: per-keystroke updates stay native, and JS only sees the value when it explicitly reads `state.value` or registers a callback.

**Incorrect (React state — every keystroke triggers a JS render and bridge call):**

```tsx
import { useState } from 'react';
import { Host, TextField, Slider } from '@expo/ui/swift-ui';

const [name, setName] = useState('');
const [volume, setVolume] = useState(50);

<Host matchContents>
  <TextField placeholder="Name" onTextChange={setName} />
  <Slider value={volume} min={0} max={100} onValueChange={setVolume} />
</Host>
```

**Correct (useNativeState — native handles the per-keystroke / drag updates):**

```tsx
import { Host, TextField, Slider, useNativeState } from '@expo/ui/swift-ui';

const name = useNativeState('');
const volume = useNativeState(50);

<Host matchContents>
  <TextField text={name} placeholder="Name" />
  <Slider value={volume.value} min={0} max={100} onValueChange={(v) => (volume.value = v)} />
</Host>
```

**When NOT to use this pattern:**

- When the value must drive React-side computations (a derived label, a list filter). Then React state is the right home.

Reference: [useNativeState hook](https://github.com/expo/expo/blob/main/packages/expo-ui/src/State/useNativeState.ts)
