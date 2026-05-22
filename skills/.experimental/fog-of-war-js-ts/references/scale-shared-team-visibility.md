---
title: Share One Refcounted Visibility Buffer Per Team
impact: MEDIUM
impactDescription: O(units) to O(1) per tile query
tags: scale, team-visibility, refcount, rts, shared-buffer
---

## Share One Refcounted Visibility Buffer Per Team

In an RTS, every unit on a team contributes to one shared fog map, so giving each unit its own visibility buffer and OR-ing all of them every frame is O(units) per tile and per frame. Keep a single per-team reference-count buffer (`update-refcount-visibility`): each unit's field of view increments the tiles it sees, and a tile is visible to the team when its count is above zero. Querying or rendering team visibility is then one buffer lookup regardless of army size.

**Incorrect (per-unit buffers unioned every frame):**

```typescript
function teamVisible(team: Unit[], i: number): boolean {
  // O(units) per tile query, and the union is rebuilt every frame.
  return team.some((u) => u.visible[i] === 1);
}
```

**Correct (one shared refcounted buffer):**

```typescript
interface Team {
  seenBy: Uint16Array;  // count of team units currently seeing tile i
  explored: Uint32Array;
}

function teamVisible(team: Team, i: number): boolean {
  return team.seenBy[i] > 0; // O(1) regardless of army size
}

// On unit move, only that unit's old/new FOV adjust the shared counts
// (see update-refcount-visibility) — no per-frame union over all units.
```

**Benefits:**
- Visibility queries and rendering are O(1) per tile no matter how many units exist.
- One buffer per team instead of one per unit cuts memory linearly with army size.

Reference: [Roguelike Vision Algorithms (Adam Milazzo)](http://www.adammil.net/blog/v125_Roguelike_Vision_Algorithms.html)
