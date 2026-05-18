---
title: Use useNativeState for TextField text — Not React useState
impact: HIGH
impactDescription: enables zero-latency native text updates and worklet-thread writes — React state round-trips through the JS bridge
tags: input, textField, useNativeState, observable-state
---

## Use useNativeState for TextField text — Not React useState

`TextField`'s `text` prop expects an `ObservableState<string>` created with `useNativeState`. The state lives on the native side and updates in place as the user types — no JS bridge round-trip per keystroke. Passing a React `useState` value wired through `onTextChange` works but every keystroke costs a JS render and a bridge crossing, which feels laggy on long lists or rich forms. Reserve React state only when the value drives non-SwiftUI consumers.

**Incorrect (React state — keystroke triggers JS render and bridge call):**

```tsx
import { useState } from 'react';
import { Host, TextField } from '@expo/ui/swift-ui';

export function EmailField() {
  const [email, setEmail] = useState('');
  return (
    <Host matchContents>
      <TextField placeholder="you@example.com" onTextChange={setEmail} />
    </Host>
  );
}
```

**Correct (ObservableState — text updates stay on the native side):**

```tsx
import { Host, TextField, useNativeState } from '@expo/ui/swift-ui';

export function EmailField() {
  const email = useNativeState('');
  return (
    <Host matchContents>
      <TextField text={email} placeholder="you@example.com" />
    </Host>
  );
}
```

**Alternative (read the value when submitting, no per-keystroke React render):**

```tsx
import { Host, TextField, Button, useNativeState } from '@expo/ui/swift-ui';

export function EmailField({ onSubmit }: { onSubmit: (email: string) => void }) {
  const email = useNativeState('');
  return (
    <Host matchContents>
      <TextField text={email} placeholder="you@example.com" />
      <Button label="Send" onPress={() => onSubmit(email.value)} />
    </Host>
  );
}
```

Reference: [useNativeState](https://github.com/expo/expo/blob/main/packages/expo-ui/src/State/useNativeState.ts)
