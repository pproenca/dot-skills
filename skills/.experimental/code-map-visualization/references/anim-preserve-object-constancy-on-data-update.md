---
title: Preserve Object Constancy on Data Updates
impact: MEDIUM
impactDescription: prevents cells teleporting when data refreshes
tags: anim, object-constancy, data-join, keys, transitions
---

## Preserve Object Constancy on Data Updates

When the map's data refreshes (a new commit, a recomputed metric), re-creating marks from scratch makes every cell disappear and reappear — even ones whose position is unchanged ([[encode-let-projection-own-position]]) — so the eye cannot tell what moved, split, or merged. Key marks by a stable identity (the file's geohash or path) so the renderer matches old to new and animates only the genuine changes: a cell that gained churn grows, a deleted file fades out, a moved file slides. This is the data-join / object-constancy principle.

**Incorrect (new objects each update):**

```typescript
function update(next: Cell[]) { current = next; render(current); } // every cell blinks
```

**Correct (match by stable key; animate only what changed):**

```typescript
function update(next: Cell[]) {
  const byKey = new Map(current.map((c) => [c.geohash, c]));
  const nextKeys = new Set(next.map((n) => n.geohash));
  for (const n of next) {
    const prev = byKey.get(n.geohash);
    prev ? tween(prev, n) : fadeIn(n);   // grow/recolour in place, or fade a new file in
  }
  for (const old of current) if (!nextKeys.has(old.geohash)) fadeOut(old); // deleted files
  current = next;
}
```

**When NOT to apply:**
- A one-shot static render that never updates has no transitions to preserve.

Reference: [Bostock — Object Constancy](https://bost.ocks.org/mike/constancy/); [Munzner, Visualization Analysis & Design](https://www.cs.ubc.ca/~tmm/vadbook/)
