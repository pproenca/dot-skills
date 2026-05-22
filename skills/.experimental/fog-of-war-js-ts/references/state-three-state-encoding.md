---
title: Encode the Three Fog States as Bit Flags in One Byte
impact: HIGH
impactDescription: reduces three layers to one byte
tags: state, bit-flags, encoding, three-state, branchless
---

## Encode the Three Fog States as Bit Flags in One Byte

Fog of war has three display states — never seen, explored-but-not-visible, and currently visible — and representing them as per-tile strings or enums forces string comparisons and 8+ bytes per tile, while three parallel boolean arrays triple the memory traffic of every update. Pack the orthogonal facts (visible, explored, opaque) into bit flags in a single byte: state tests become branchless bit masks, and one buffer holds everything.

**Incorrect (string state per tile):**

```typescript
type FogState = "unseen" | "explored" | "visible";
const state: FogState[] = new Array(width * height).fill("unseen");

// String compares on the hot path; boxed strings bloat memory.
if (state[i] === "visible") drawBright(i);
else if (state[i] === "explored") drawDim(i);
```

**Correct (bit flags in a Uint8Array):**

```typescript
const VISIBLE = 1;   // bit 0 — currently in sight
const EXPLORED = 2;  // bit 1 — seen at least once (sticky)
const OPAQUE = 4;    // bit 2 — blocks sight

const fog = new Uint8Array(width * height);

const f = fog[i];
if (f & VISIBLE) drawBright(i);
else if (f & EXPLORED) drawDim(i);

// Reveal sets both bits at once; clearing visibility leaves explored intact.
fog[i] |= VISIBLE | EXPLORED;
fog[i] &= ~VISIBLE; // tile leaves sight but stays remembered
```

**Benefits:**
- One byte per tile holds all fog facts; queries are single AND operations.
- Setting visible and explored together is one OR; the explored bit is never accidentally cleared (`correct-explored-not-overwritten`).

Reference: [MDN — Bitwise operators](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators#bitwise_operators)
