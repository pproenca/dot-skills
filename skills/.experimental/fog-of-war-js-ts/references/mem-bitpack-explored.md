---
title: Pack the Explored Layer Into Bits for Memory and Saves
impact: MEDIUM
impactDescription: reduces explored memory 8x
tags: mem, bit-packing, explored, serialization, save-files
---

## Pack the Explored Layer Into Bits for Memory and Saves

The explored layer is a pure boolean per tile (seen or not), so storing it as a `Uint8Array` wastes seven of every eight bits — and for a large or persistent world, that layer is also what you serialize into save files. Pack it into a `Uint32Array` bitset: 8× less memory resident, and the save blob shrinks proportionally (and compresses further, since explored regions are contiguous runs of set bits).

**Incorrect (one byte per explored bit, saved verbatim):**

```typescript
const explored = new Uint8Array(width * height); // 1 byte per tile
function save(): Uint8Array { return explored.slice(); } // 8x larger than needed
```

**Correct (packed bitset, compact save):**

```typescript
const explored = new Uint32Array(Math.ceil((width * height) / 32));

const markExplored = (i: number): void => { explored[i >>> 5] |= 1 << (i & 31); };
const wasExplored = (i: number): boolean => (explored[i >>> 5] & (1 << (i & 31))) !== 0;

function save(): Uint8Array {
  return new Uint8Array(explored.buffer.slice(0)); // 1 bit per tile on disk
}
```

**Benefits:**
- Resident memory and save size drop 8×; run-length or gzip compression shrinks it further.
- The persistent layer stays separate from the transient visible layer, which need not be saved.

Reference: [MDN — Uint32Array](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Uint32Array)
