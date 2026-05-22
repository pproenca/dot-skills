---
title: Compute a Visibility Polygon for Smooth 2D Fog
impact: MEDIUM-HIGH
impactDescription: O(n log n) for n wall endpoints
tags: fov, visibility-polygon, angular-sweep, vector, lighting
---

## Compute a Visibility Polygon for Smooth 2D Fog

Tile-based shadowcasting produces blocky edges that look wrong for smooth vector lighting or non-grid worlds built from polygon walls. Casting a ray through every screen pixel to find shadows is O(pixels × walls) and resolution-dependent. An angular sweep instead casts one ray at each wall endpoint, sorts the hits by angle, and stitches them into the exact visibility polygon in O(n log n) for n endpoints — resolution-independent and far cheaper.

**Incorrect (per-pixel raycast):**

```typescript
interface Segment { ax: number; ay: number; bx: number; by: number; }

// O(pixels x walls): a ray for every pixel on screen, every frame.
function buildShadowMask(px: number, py: number, walls: Segment[], w: number, h: number): void {
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      if (rayHitsAnyWall(px, py, x, y, walls)) markShadowed(x, y);
    }
  }
}
```

**Correct (angular endpoint sweep):**

```typescript
interface Pt { x: number; y: number; }

// One ray per endpoint (plus a nudge each side of corners), sorted by angle.
function visibilityPolygon(px: number, py: number, walls: Segment[]): Pt[] {
  const angles: number[] = [];
  for (const s of walls) {
    const a1 = Math.atan2(s.ay - py, s.ax - px);
    const a2 = Math.atan2(s.by - py, s.bx - px);
    angles.push(a1 - 1e-5, a1, a1 + 1e-5, a2 - 1e-5, a2, a2 + 1e-5);
  }
  angles.sort((m, n) => m - n);
  const poly: Pt[] = [];
  for (const a of angles) {
    const hit = nearestHit(px, py, Math.cos(a), Math.sin(a), walls);
    if (hit) poly.push(hit); // closest intersection along this ray
  }
  return poly; // render as a light/visibility mask; outside the polygon is fog
}
```

**Common use cases:**
- 2D stealth/lighting where shadows must follow arbitrary wall angles.
- Top-down games with polygon (not tile) collision geometry.

Reference: [2D Visibility (Red Blob Games)](https://www.redblobgames.com/articles/visibility/)
