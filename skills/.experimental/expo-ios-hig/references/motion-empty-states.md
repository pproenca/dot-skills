---
title: Design empty states that guide the next action
impact: MEDIUM
impactDescription: prevents dead-end blank screens
tags: motion, empty-states, feedback, onboarding
---

## Design empty states that guide the next action

The first time a user opens a list it is empty, and a blank screen reads as broken or stuck. An empty state that names what belongs here and offers the action to create it turns a dead end into an on-ramp — it is often a user's first real interaction with the feature. Render a deliberate empty state with an icon, a short explanation, and a primary action, distinct from the loading and error states.

**Incorrect (empty list renders nothing):**

```tsx
import { FlatList } from 'react-native';

// With no saved trails the user sees a blank screen and no way forward
function SavedTrailsScreen({ savedTrails }: { savedTrails: Trail[] }) {
  return <FlatList data={savedTrails} renderItem={renderTrailRow} />;
}
```

**Correct (guiding empty state):**

```tsx
import { FlatList } from 'react-native';
import { EmptyState } from '../components/EmptyState';

// Names what belongs here and offers the action to fill it
function SavedTrailsScreen({ savedTrails }: { savedTrails: Trail[] }) {
  return (
    <FlatList
      data={savedTrails}
      renderItem={renderTrailRow}
      ListEmptyComponent={
        <EmptyState
          symbol="bookmark"
          title="No saved trails yet"
          actionLabel="Browse trails"
          onAction={goToTrails}
        />
      }
    />
  );
}
```

Reference: [Apple HIG — Onboarding](https://developer.apple.com/design/human-interface-guidelines/onboarding)
