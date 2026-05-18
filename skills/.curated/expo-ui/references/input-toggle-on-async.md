---
title: Use Toggle for Async State, SyncToggle for Instant Native Updates
impact: HIGH
impactDescription: prevents toggle-flicker — Toggle round-trips state through React, SyncToggle commits to the native state directly
tags: input, toggle, syncToggle, observable-state
---

## Use Toggle for Async State, SyncToggle for Instant Native Updates

`Toggle` accepts `isOn` + `onIsOnChange` like a controlled React component — the user flicks, the callback fires, React updates state, the prop comes back. On a slow JS thread or laggy bridge this produces a visible flicker. `SyncToggle` instead binds directly to an `ObservableState<boolean>` and commits the new value to native state synchronously — no bridge round-trip — so the toggle appears to flick instantly. Use Toggle when the change must trigger React side effects (server save, navigation); use SyncToggle for pure UI state.

**Incorrect (Toggle for pure UI state — visible flicker on JS-thread contention):**

```tsx
import { useState } from 'react';
import { Host, Toggle } from '@expo/ui/swift-ui';

const [pinned, setPinned] = useState(false);

<Host matchContents>
  <Toggle label="Pin to top" isOn={pinned} onIsOnChange={setPinned} />
</Host>
```

**Correct (SyncToggle bound to ObservableState — instant native flick):**

```tsx
import { Host, SyncToggle, useNativeState } from '@expo/ui/swift-ui';

const pinned = useNativeState(false);

<Host matchContents>
  <SyncToggle label="Pin to top" isOn={pinned} />
</Host>
```

**Alternative (Toggle when the change must persist server-side):**

```tsx
import { Host, Toggle } from '@expo/ui/swift-ui';

<Host matchContents>
  <Toggle
    label="Email digest"
    isOn={digestEnabled}
    onIsOnChange={async (next) => {
      setDigestEnabled(next);
      await api.updateNotificationPref({ digest: next });
    }}
  />
</Host>
```

Reference: [@expo/ui SyncToggle source](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/SyncToggle/index.tsx)
