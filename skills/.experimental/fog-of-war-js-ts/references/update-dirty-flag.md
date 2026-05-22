---
title: Track a Dirty Flag Per Viewer and a Map Version Stamp
impact: HIGH
impactDescription: avoids clean viewer recomputes
tags: update, dirty-flag, invalidation, multi-viewer
---

## Track a Dirty Flag Per Viewer and a Map Version Stamp

With many independent viewers, recomputing all of them whenever any one moves does work proportional to the total viewer count on every single move. Give each viewer a `dirty` flag set on its own movement, plus a global integer map-version that increments on any map edit. A viewer needs recomputing only if it is dirty or its cached map-version is stale, so churn from one unit no longer drags in the rest.

**Incorrect (recompute everyone on any change):**

```typescript
function onAnyChange(world: World): void {
  for (const v of world.viewers) {
    // Even viewers that did not move and saw no map change are re-swept.
    computeFovInto(world, v);
  }
}
```

**Correct (per-viewer dirty + map version):**

```typescript
interface Viewer {
  x: number; y: number; sight: number;
  dirty: boolean;
  seenMapVersion: number;
}

function moveViewer(v: Viewer, nx: number, ny: number): void {
  if (nx !== v.x || ny !== v.y) { v.x = nx; v.y = ny; v.dirty = true; }
}

function recomputeDirty(world: World): void {
  for (const v of world.viewers) {
    if (v.dirty || v.seenMapVersion !== world.mapVersion) {
      computeFovInto(world, v);
      v.dirty = false;
      v.seenMapVersion = world.mapVersion;
    }
  }
}
```

**Benefits:**
- One unit walking re-sweeps one unit, not the whole army.
- A map edit invalidates everyone with a single counter bump (`world.mapVersion++`) — no per-viewer flag fan-out.

Reference: [rot.js field-of-view documentation](https://ondras.github.io/rot.js/manual/#fov)
