---
title: Choose ContextMenu OR SwipeActions per Row — Not Both
impact: HIGH
impactDescription: prevents discoverability ambiguity — long-press and edge-swipe gestures compete for the same affordance space
tags: nav, contextMenu, swipeActions, gestures, hig
---

## Choose ContextMenu OR SwipeActions per Row — Not Both

A list row that responds to both long-press (context menu) and edge swipe (swipe actions) overloads the user's gesture vocabulary. They typically discover one and don't notice the other, but the existence of both makes the row's interaction surface feel inconsistent. HIG guidance: pick the gesture that fits the primary use. SwipeActions for fast frequent actions (archive, delete in a mail list). ContextMenu for rare contextual options (share, copy link, rename) — particularly when there are more than two actions.

**Incorrect (both gestures attached to the same row — discoverability ambiguity):**

```tsx
import { List, ContextMenu, SwipeActions, Button, Text } from '@expo/ui/swift-ui';

<List>
  <ContextMenu>
    <ContextMenu.Trigger>
      <SwipeActions>
        <Text>Quarterly report</Text>
        <SwipeActions.Actions edge="trailing">
          <Button role="destructive" label="Delete" onPress={() => deleteFile(id)} />
        </SwipeActions.Actions>
      </SwipeActions>
    </ContextMenu.Trigger>
    <ContextMenu.Items>
      <Button label="Share" onPress={() => share(id)} />
      <Button label="Copy link" onPress={() => copyLink(id)} />
    </ContextMenu.Items>
  </ContextMenu>
</List>
```

**Correct (swipe for the frequent destructive action; context menu only if needed):**

```tsx
import { List, SwipeActions, Button, Text } from '@expo/ui/swift-ui';

<List>
  <SwipeActions>
    <Text>Quarterly report</Text>
    <SwipeActions.Actions edge="trailing">
      <Button role="destructive" label="Delete" onPress={() => deleteFile(id)} />
    </SwipeActions.Actions>
  </SwipeActions>
</List>
```

Reference: [SwipeActions in @expo/ui](https://github.com/expo/expo/blob/main/packages/expo-ui/src/swift-ui/SwipeActions/index.tsx)
