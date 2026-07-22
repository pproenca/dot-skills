---
title: Order lists by a sort key instead of moving array entries
tags: model, yarray, reordering, duplication
---

## Order lists by a sort key instead of moving array entries

`Y.Array` has no move operation, so reordering gets implemented as delete-then-insert — the standard array idiom, and correct on one client. Under concurrency the two halves are independent operations: each client's insert survives and each client's delete applies to the entry it saw, so an item dragged by two people at once is duplicated rather than moved. Drag-and-drop lists are exactly where two users act on the same row simultaneously, so this is a routine collision rather than a rare race.

Verified with Yjs 13.6.31: starting from `['write', 'review', 'ship']`, two clients concurrently moving `'ship'` to the front converged to `["ship","ship","write","review"]` — the item duplicated and the list lost an entry.

**Incorrect (delete plus insert duplicates the row under concurrency):**

```typescript
function moveTask(tasks: Y.Array<Y.Map<string>>, from: number, to: number) {
  const task = tasks.get(from)
  tasks.delete(from, 1)
  tasks.insert(to, [task])
}
```

**Correct (position is a value that merges last-writer-wins):**

```typescript
// Each task carries its own order key; the list is derived, never reordered in place.
function moveTask(task: Y.Map<unknown>, previous?: number, next?: number) {
  const before = previous ?? 0
  const after = next ?? before + 2
  task.set('order', (before + after) / 2) // fractional index between the neighbours
}

const ordered = tasks.toArray().sort((a, b) => Number(a.get('order')) - Number(b.get('order')))
```

Two clients dragging the same task now write two values to one `order` key, one wins, and the task exists once. The tie-break to add when it matters is a stable secondary sort — a creation timestamp or client id — so that clients agree on ordering when two tasks land on the same fractional index.

Reference: [Yjs — Y.Array](https://docs.yjs.dev/api/shared-types/y.array)
