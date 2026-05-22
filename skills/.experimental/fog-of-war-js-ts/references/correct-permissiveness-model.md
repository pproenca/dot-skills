---
title: Pick One Permissiveness Model and Apply It Everywhere
impact: LOW-MEDIUM
impactDescription: prevents inconsistent visibility
tags: correct, permissiveness, symmetry, consistency, model
---

## Pick One Permissiveness Model and Apply It Everywhere

FOV algorithms differ in how generously they reveal partially-blocked tiles: restrictive (a tile is visible only if its whole face is unblocked), permissive (visible if any part is), and symmetric (visible if its center is, guaranteeing mutual sight). Mixing models across systems — display fog uses one, AI line-of-sight uses another — produces tiles the player sees but enemies cannot react to, or shots that hit targets the player cannot see. Choose one model and route every visibility query through it.

**Incorrect (display and AI use different models):**

```typescript
function renderFog(grid: Grid, p: Viewer): void {
  computePermissiveFov(grid, p); // generous: reveals partially-blocked tiles
}
function enemyCanSeePlayer(grid: Grid, e: Viewer, p: Viewer): boolean {
  return restrictiveLos(grid, e, p); // strict: disagrees with what the player sees
}
```

**Correct (one shared model for all queries):**

```typescript
// Single source of truth: symmetric FOV (fov-symmetric-shadowcasting).
function isVisibleBetween(grid: Grid, a: Viewer, b: Viewer): boolean {
  return symmetricVisible(grid, a.x, a.y, b.x, b.y); // mutual by construction
}

function renderFog(grid: Grid, p: Viewer): void { computeSymmetricFov(grid, p); }
function enemyCanSeePlayer(grid: Grid, e: Viewer, p: Viewer): boolean {
  return isVisibleBetween(grid, e, p); // same rule the fog display uses
}
```

**Benefits:**
- What the player sees and what enemies react to always agree — fair stealth and combat.
- Symmetric models make "A sees B" imply "B sees A", removing a whole class of bugs.

Reference: [Symmetric Shadowcasting (Albert Ford)](https://www.albertford.com/shadowcasting/)
