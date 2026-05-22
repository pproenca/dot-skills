---
title: Never Let the Visible Pass Overwrite the Explored Layer
impact: LOW-MEDIUM
impactDescription: preserves remembered tiles
tags: correct, explored, monotonic, memory-layer, state
---

## Never Let the Visible Pass Overwrite the Explored Layer

Fog of war remembers explored terrain even after it leaves sight, so the explored layer must be monotonic — once set, never cleared. The classic bug stores a single tristate value per tile and, when clearing visibility for the new frame, resets visible tiles all the way back to "unseen", erasing the memory of everything currently in view the moment the viewer looks away. Keep explored as an independent sticky bit that the visibility clear never touches.

**Incorrect (single state; clearing visible erases memory):**

```typescript
type FogState = 0 | 1 | 2; // 0 unseen, 1 explored, 2 visible
const state: Uint8Array = new Uint8Array(width * height);

function newFrame(): void {
  for (let i = 0; i < state.length; i++) {
    if (state[i] === 2) state[i] = 0; // BUG: visible -> unseen, memory lost
  }
}
```

**Correct (separate sticky explored bit):**

```typescript
const VISIBLE = 1;
const EXPLORED = 2;
const fog = new Uint8Array(width * height);

function reveal(i: number): void {
  fog[i] |= VISIBLE | EXPLORED; // explored is set once and stays set
}

function clearVisible(): void {
  for (let i = 0; i < fog.length; i++) fog[i] &= ~VISIBLE; // explored bit untouched
}
```

**Benefits:**
- Tiles leaving sight render as dimmed memory, not black — the expected fog-of-war look.
- Pairs with `update-merge-explored` (set explored at reveal) and `state-three-state-encoding` (the bit layout).

Reference: [rot.js field-of-view documentation](https://ondras.github.io/rot.js/manual/#fov)
