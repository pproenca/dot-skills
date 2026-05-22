---
title: Merge Visible Into Explored as You Reveal, Never Rebuild It
impact: HIGH
impactDescription: maintains O(1) explored updates
tags: update, explored, memory-layer, monotonic
---

## Merge Visible Into Explored as You Reveal, Never Rebuild It

The "explored" (remembered) layer is the cumulative union of everything ever seen, so deriving it by re-scanning the map or re-OR-ing every viewer each frame redoes work that never needs redoing. Treat explored as monotonic: the instant a tile becomes visible, set its explored bit, and never clear it. The merge is then a single write at reveal time — O(1) per newly-lit tile — instead of a full-map pass.

**Incorrect (rebuild explored from all viewers each frame):**

```typescript
function rebuildExplored(world: World): void {
  // Re-derives the entire memory layer every frame from scratch.
  for (let i = 0; i < world.explored.length; i++) {
    let seen = world.explored[i];
    for (const v of world.viewers) {
      if (everSaw(v, i)) seen = 1;
    }
    world.explored[i] = seen;
  }
}
```

**Correct (set the explored bit at reveal time):**

```typescript
function reveal(world: World, i: number): void {
  world.visible[i] = 1;
  world.explored[i] = 1; // one write, set-once, never cleared
}

function clearVisibleForNewFrame(world: World): void {
  world.visible.fill(0); // wipe transient visibility only
  // explored is left untouched — it only ever grows
}
```

**Warning (this rule is about cost, not the clear bug):**
- This rule is about *not rebuilding* explored (O(map) per frame to O(1) at reveal). The related *correctness* failure — collapsing visible and explored into one tristate value, so clearing visibility erases memory — is a separate concern covered in `correct-explored-not-overwritten`.

Reference: [rot.js field-of-view documentation](https://ondras.github.io/rot.js/manual/#fov)
