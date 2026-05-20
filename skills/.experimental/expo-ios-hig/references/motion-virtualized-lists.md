---
title: Render long lists with a virtualized list
impact: MEDIUM-HIGH
impactDescription: maintains 60fps scrolling over 10K+ rows
tags: motion, flashlist, virtualization, performance
---

## Render long lists with a virtualized list

Mapping an array into a `ScrollView` mounts every row at once, so a list of a few hundred items allocates hundreds of views up front, spikes memory, and drops frames while scrolling. A virtualized list only renders the rows near the viewport and recycles them. `FlashList` recycles row views for sustained 60fps even over thousands of items, where a naive `ScrollView` already stutters in the hundreds.

**Incorrect (map every row into a ScrollView):**

```tsx
import { ScrollView } from 'react-native';

// Mounts every trail at once: memory spike and dropped frames while scrolling
function AllTrailsScreen({ trails }: { trails: Trail[] }) {
  return (
    <ScrollView>
      {trails.map((trail) => <TrailRow key={trail.id} trail={trail} />)}
    </ScrollView>
  );
}
```

**Correct (virtualized, recycling list):**

```tsx
import { FlashList } from '@shopify/flash-list';

// Only viewport rows are rendered and recycled; holds 60fps over large lists
function AllTrailsScreen({ trails }: { trails: Trail[] }) {
  return (
    <FlashList
      data={trails}
      keyExtractor={(trail) => trail.id}
      renderItem={({ item }) => <TrailRow trail={item} />}
    />
  );
}
```

Reference: [FlashList documentation](https://shopify.github.io/flash-list/docs/)
