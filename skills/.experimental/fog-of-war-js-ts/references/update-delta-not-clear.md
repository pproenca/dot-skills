---
title: Emit Visibility Deltas Instead of Clear-All-Recompute
impact: HIGH
impactDescription: reduces redraw to changed tiles
tags: update, delta, diffing, rendering
---

## Emit Visibility Deltas Instead of Clear-All-Recompute

Clearing the whole visible buffer and handing the renderer a fresh full set forces it to treat every lit tile as changed, even though stepping one tile only flips a thin crescent of tiles at the radius edge. Diff the new field of view against the previous one and emit just the newly-visible and newly-hidden tiles. Downstream work — re-tinting sprites, updating a lightmap, uploading texture regions — then scales with the actual change, not the radius.

**Incorrect (treat the whole radius as changed):**

```typescript
function updateFov(state: VState, cx: number, cy: number, r: number): void {
  state.visible.fill(0);
  computeFov(state.grid, cx, cy, r);
  redrawEveryVisibleTile(state); // re-touches the entire lit disc each step
}
```

**Correct (diff and emit only the changes):**

```typescript
function updateFov(state: VState, cx: number, cy: number, r: number): number[] {
  const { curr, prev } = state;
  prev.set(curr);        // snapshot last frame's visibility
  curr.fill(0);
  computeFov(state.grid, cx, cy, r); // writes into curr via setVisible
  const changed: number[] = [];
  // Only the box either frame could touch needs diffing (see fov-radius-bounded-scan).
  forEachIndexInBox(cx, cy, r + 1, state.width, (i) => {
    if (curr[i] !== prev[i]) {
      changed.push(i);
      if (curr[i] === 1) state.explored[i] = 1;
    }
  });
  return changed; // hand only these to the renderer / lightmap
}
```

**Benefits:**
- Render cost tracks movement, not sight radius — a one-tile step updates a handful of tiles.
- Pairs naturally with dirty-region rendering (`render-dirty-region-only`).

Reference: [rot.js field-of-view documentation](https://ondras.github.io/rot.js/manual/#fov)
