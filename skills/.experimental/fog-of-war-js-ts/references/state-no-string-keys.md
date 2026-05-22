---
title: Avoid String-Keyed Maps for Per-Tile Visibility
impact: MEDIUM
impactDescription: eliminates per-tile string hashing
tags: state, anti-pattern, map, string-keys, hashing
---

## Avoid String-Keyed Maps for Per-Tile Visibility

Keying visibility by a template-literal coordinate in a `Map` or `Set` allocates and hashes a fresh string on every tile touch, and the entries live as scattered heap objects the GC must trace — orders of magnitude slower than a typed-array index, and impossible to clear with a single `fill(0)`. Convert the coordinate to the integer index `y * width + x` and index a flat buffer instead.

**Incorrect (string-keyed Set):**

```typescript
const visible = new Set<string>();

// Each call allocates a string and computes a hash.
const reveal = (x: number, y: number): void => { visible.add(`${x},${y}`); };
const isVisible = (x: number, y: number): boolean => visible.has(`${x},${y}`);
const clearFrame = (): void => visible.clear(); // frees scattered string entries
```

**Correct (integer index into a typed array):**

```typescript
const visible = new Uint8Array(width * height);

const reveal = (x: number, y: number): void => { visible[y * width + x] = 1; };
const isVisible = (x: number, y: number): boolean => visible[y * width + x] === 1;
const clearFrame = (): void => visible.fill(0); // single contiguous wipe
```

**When NOT to use this pattern:**
- Sparse, unbounded coordinate spaces (e.g. an infinite procedural world with no fixed `width`) where a dense buffer would be mostly empty — there, key a `Map` by a packed integer (`(x << 16) | (y & 0xffff)`), still avoiding string allocation.

Reference: [MDN — Typed arrays](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Typed_arrays)
