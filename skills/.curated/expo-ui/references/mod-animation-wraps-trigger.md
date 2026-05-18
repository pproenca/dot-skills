---
title: Wrap State-Driven Prop Changes in withAnimation for Smooth Transitions
impact: HIGH
impactDescription: enables SwiftUI's implicit transitions for value changes — without it, transitions snap instantly
tags: mod, animation, withAnimation, transitions
---

## Wrap State-Driven Prop Changes in withAnimation for Smooth Transitions

When a prop change triggers a layout, color, or opacity transition, SwiftUI animates the change *only* if the state update happens inside `withAnimation`. The expo-ui `withAnimation` helper takes a callback and an animation config — it tags the state update so the native side runs the transition. Calling state setters directly produces an instant snap.

**Incorrect (state setter called bare — sheet appears with no animation):**

```tsx
import { Host, Button, BottomSheet, Group } from '@expo/ui/swift-ui';

const [open, setOpen] = useState(false);

<Host matchContents>
  <Button label="Open editor" onPress={() => setOpen(true)} />
  <BottomSheet isPresented={open} onIsPresentedChange={setOpen}>
    <Group><EditorContent /></Group>
  </BottomSheet>
</Host>
```

**Correct (withAnimation wraps the setter — sheet eases in):**

```tsx
import { Host, Button, BottomSheet, Group, withAnimation } from '@expo/ui/swift-ui';

const [open, setOpen] = useState(false);

<Host matchContents>
  <Button
    label="Open editor"
    onPress={() => withAnimation({ type: 'spring' }, () => setOpen(true))}
  />
  <BottomSheet isPresented={open} onIsPresentedChange={setOpen}>
    <Group><EditorContent /></Group>
  </BottomSheet>
</Host>
```

**When NOT to use this pattern:**

- One-off state updates that have no visible transition target (e.g., updating a hidden counter).

Reference: [withAnimation in expo-ui](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/withAnimation.ts)
