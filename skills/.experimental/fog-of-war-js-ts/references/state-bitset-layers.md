---
title: Use a Bitset for Boolean Visibility Layers
impact: MEDIUM-HIGH
impactDescription: reduces boolean-layer memory 8x
tags: state, bitset, uint32, memory, fast-clear
---

## Use a Bitset for Boolean Visibility Layers

A purely boolean layer — visible or not — stored as a `Uint8Array` spends eight bits to record one, and clearing it each recompute writes `width × height` bytes. A bitset packs 32 tiles into each `Uint32Array` word: 8× less memory, and `fill(0)` clears 32 tiles per write, which matters because the transient visible layer is wiped on every recompute. Use it when a tile needs no per-tile metadata beyond a single flag.

**Incorrect (one byte per boolean):**

```typescript
const visible = new Uint8Array(width * height); // 1 byte to store 1 bit
visible[i] = 1;
const lit = visible[i] === 1;
visible.fill(0); // writes width*height bytes every frame
```

**Correct (packed bitset):**

```typescript
class BitGrid {
  private readonly words: Uint32Array;
  constructor(public readonly width: number, public readonly height: number) {
    this.words = new Uint32Array(Math.ceil((width * height) / 32));
  }
  get(i: number): boolean { return (this.words[i >>> 5] & (1 << (i & 31))) !== 0; }
  set(i: number): void { this.words[i >>> 5] |= 1 << (i & 31); }
  unset(i: number): void { this.words[i >>> 5] &= ~(1 << (i & 31)); }
  clearAll(): void { this.words.fill(0); } // 32 tiles cleared per word write
}
```

**When NOT to use this pattern:**
- Multi-viewer reference counting needs a per-tile integer, not a bit — use `Uint16Array` counts (`update-refcount-visibility`).
- When you also need explored/opaque per tile, bit flags in one byte (`state-three-state-encoding`) are simpler than parallel bitsets.

Reference: [MDN — Uint32Array](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Uint32Array)
