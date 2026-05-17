---
title: Hash Subtrees to Detect Componentization Opportunities
impact: HIGH
impactDescription: identifies repeated structure missed by symbol authors (typically 20-40% extra components)
tags: tree, structural-hashing, zhang-shasha, componentization
---

## Hash Subtrees to Detect Componentization Opportunities

Designers don't always promote repeated structure to symbols — a list row, a tag chip, or a price label might be duplicated 30 times across the file as raw groups. Compute a structural hash for every subtree (depth-first canonical serialization, excluding `do_objectID` and absolute coordinates), bucket equal hashes, and propose each bucket of size ≥ 3 as a component candidate. Doing this *before* emit avoids the 40-component-deduplication codemod you'd otherwise need post-conversion.

**Incorrect (emit every group as inline JSX):**

```ts
for (const layer of walk(page)) {
  if (layer._class === 'group') {
    emit(inlineGroup(layer));   // 30 copies of the same chip subtree
  }
}
// Codebase now has 30 near-identical 50-line JSX blocks.
```

**Correct (hash subtrees, propose components for ≥3 matches):**

```ts
// Canonical serialization: structure + style fingerprint, NO position or IDs.
function structuralHash(layer: Layer): string {
  const sig = {
    class: layer._class,
    style: styleFingerprint(layer.style),       // fills/borders/radii but not gradient stop positions
    children: (layer.layers ?? []).map(structuralHash),
    // Note: x, y, width, height excluded — pure shape, not placement.
  };
  return sha256(JSON.stringify(sig));
}

// Bucket every subtree by its hash.
const buckets = new Map<string, Layer[]>();
for (const layer of walkAll(doc)) {
  const h = structuralHash(layer);
  (buckets.get(h) ?? buckets.set(h, []).get(h)!).push(layer);
}

// Any bucket with ≥ 3 instances is a component candidate.
const candidates = [...buckets.values()].filter(b => b.length >= 3);
for (const bucket of candidates) {
  const name = inferName(bucket);              // common ancestor name, e.g., "Chip"
  await emitInferredComponent(name, bucket[0]);
  for (const occurrence of bucket) {
    await replaceWithComponentRef(occurrence, name);  // <Chip label={...} />
  }
}
```

**Why exclude position from the hash:** two chips at different (x, y) have the same *shape* and should componentize. Including coordinates would make every instance unique and defeat the bucketing.

**Implementation note:** for non-trivial trees, use Zhang-Shasha tree edit distance to also detect *near*-matches (one differing leaf), which catches "same chip with a different icon" — the leading source of missed componentization.

Reference: [Zhang & Shasha 1989 — Simple Fast Algorithms for the Editing Distance Between Trees](https://grantjenks.com/wiki/_media/ideas:simple_fast_algorithms_for_the_editing_distance_between_trees_and_related_problems.pdf)
