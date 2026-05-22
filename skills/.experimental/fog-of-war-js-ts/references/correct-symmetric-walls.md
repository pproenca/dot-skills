---
title: Light Wall Tiles Consistently to Avoid Flickering Faces
impact: LOW-MEDIUM
impactDescription: prevents flickering wall faces
tags: correct, walls, symmetry, artifacts, lighting
---

## Light Wall Tiles Consistently to Avoid Flickering Faces

Walls are opaque, so a naive field of view that only lights floor tiles leaves wall tiles dark even when the player is standing right beside them, and as the viewer moves, individual wall tiles pop in and out depending on which ray happened to clip them. Adopt one consistent rule — a wall tile is visible if any floor tile it borders that faces the viewer is visible — so wall faces light up coherently and stay lit while in view.

**Incorrect (only floors get lit; walls flicker):**

```typescript
function reveal(grid: Grid, x: number, y: number): void {
  if (grid.isOpaque(x, y)) return; // walls never lit -> dark, flickering edges
  grid.setVisible(x, y);
}
```

**Correct (light a wall if a visible facing floor borders it):**

```typescript
function reveal(grid: Grid, x: number, y: number): void {
  grid.setVisible(x, y); // floors and walls both reachable by the sweep get lit
}

// During shadowcasting, walls ARE marked visible when the scan reaches them
// (they end the slope range but are revealed first). A symmetric algorithm
// (fov-symmetric-shadowcasting) reveals walls before clipping, so a wall is lit
// exactly when a visible floor faces it — no per-frame popping.
```

**Benefits:**
- Wall faces adjacent to lit floors render solidly instead of flickering.
- Symmetric reveal (`fov-symmetric-shadowcasting`) gives this for free; ad-hoc fixes do not.

Reference: [Roguelike Vision Algorithms (Adam Milazzo)](http://www.adammil.net/blog/v125_Roguelike_Vision_Algorithms.html)
