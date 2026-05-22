---
title: Prefer Symmetric Shadowcasting for Consistent Visibility
impact: CRITICAL
impactDescription: prevents asymmetric visibility artifacts
tags: fov, symmetric-shadowcasting, symmetry, artifacts
---

## Prefer Symmetric Shadowcasting for Consistent Visibility

Classic recursive shadowcasting is not symmetric: a tile A can be lit from the origin while the origin is not lit from A. In gameplay this means a monster you cannot see can see you, and walls pop in and out as the viewer steps sideways. Albert Ford's symmetric shadowcasting reveals a floor tile only when its **center** lies inside the scanned slope range, which makes visibility mutual, and its row-by-row structure has fewer slope edge cases than the corner-based version.

**Incorrect (corner test — asymmetric):**

```typescript
interface FovWorld {
  isWall(x: number, y: number): boolean;
  reveal(x: number, y: number): void;
}

// A tile is lit if ANY corner falls in range, so A sees B but B may not see A.
function shouldReveal(depth: number, col: number, start: number, end: number): boolean {
  return col - 0.5 <= depth * end && col + 0.5 >= depth * start;
}
```

**Correct (center test — symmetric):**

```typescript
interface Quadrant {
  transform(depth: number, col: number): [number, number];
}

const slope = (depth: number, col: number): number => (2 * col - 1) / (2 * depth);
const roundUp = (n: number): number => Math.floor(n + 0.5);
const roundDown = (n: number): number => Math.ceil(n - 0.5);

function scan(
  world: FovWorld, q: Quadrant, depth: number,
  startSlope: number, endSlope: number, maxDepth: number,
): void {
  if (depth > maxDepth) return;
  const minCol = roundUp(depth * startSlope);
  const maxCol = roundDown(depth * endSlope);
  let prevWall: boolean | null = null;
  let start = startSlope;
  for (let col = minCol; col <= maxCol; col++) {
    const [x, y] = q.transform(depth, col);
    const wall = world.isWall(x, y);
    // Reveal walls always; reveal a floor only if its centre is within range.
    if (wall || (col >= depth * start && col <= depth * endSlope)) world.reveal(x, y);
    if (prevWall === true && !wall) start = slope(depth, col);
    if (prevWall === false && wall) {
      scan(world, q, depth + 1, start, slope(depth, col), maxDepth);
    }
    prevWall = wall;
  }
  if (prevWall === false) scan(world, q, depth + 1, start, endSlope, maxDepth);
}
```

**Benefits:**
- Mutual visibility — fair stealth and consistent reveal across viewers.
- Cleaner wall faces with no flicker as the viewer moves.

Reference: [Symmetric Shadowcasting (Albert Ford)](https://www.albertford.com/shadowcasting/)
