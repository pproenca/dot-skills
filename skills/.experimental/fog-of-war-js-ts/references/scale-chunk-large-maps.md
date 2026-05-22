---
title: Chunk Large Maps and Keep Only Active Chunks Resident
impact: MEDIUM
impactDescription: reduces resident memory to active chunks
tags: scale, chunking, large-maps, streaming, memory
---

## Chunk Large Maps and Keep Only Active Chunks Resident

A full per-tile fog buffer for a very large or streaming world (tens of thousands of tiles per side, or an open world) does not fit comfortably in memory, and most of it is nowhere near any viewer. Divide the map into fixed-size chunks and keep the visible/explored buffers only for chunks near active viewers; persist distant chunks' explored layer (bit-packed, `mem-bitpack-explored`) to storage and evict their buffers.

**Incorrect (one buffer for the entire world):**

```typescript
// A 50,000 x 50,000 world = 2.5 billion tiles — multiple GB of fog buffers.
const visible = new Uint8Array(WORLD_W * WORLD_H);
const explored = new Uint8Array(WORLD_W * WORLD_H);
```

**Correct (resident set of active chunks):**

```typescript
const CHUNK = 64; // tiles per side

interface Chunk { visible: Uint8Array; explored: Uint32Array; }
const resident = new Map<number, Chunk>();

function chunkKey(cx: number, cy: number): number { return cy * chunksWide + cx; }

function ensureResident(cx: number, cy: number): Chunk {
  const key = chunkKey(cx, cy);
  let c = resident.get(key);
  if (!c) {
    c = { visible: new Uint8Array(CHUNK * CHUNK), explored: loadExplored(key) };
    resident.set(key, c);
  }
  return c;
}

function evictFarChunks(viewerChunks: Set<number>): void {
  for (const [key, c] of resident) {
    if (!viewerChunks.has(key)) { persistExplored(key, c.explored); resident.delete(key); }
  }
}
```

**Benefits:**
- Memory scales with the active area, not the world size.
- Explored memory persists per chunk, so revisiting a region restores its remembered state.

Reference: [MDN — Memory management](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Memory_management)
