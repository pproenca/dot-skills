---
title: Clear the Visible Buffer With fill, Not Reallocation or a Loop
impact: MEDIUM
impactDescription: avoids per-frame allocation
tags: mem, clear, fill, typed-array, reset
---

## Clear the Visible Buffer With fill, Not Reallocation or a Loop

Resetting the transient visible layer each recompute by allocating a new array creates garbage (`mem-reuse-buffers`), and resetting it with a hand-written element loop is slower than the engine's intrinsic. `TypedArray.prototype.fill(0)` is a single optimised memset over contiguous memory — the fastest and allocation-free way to wipe the frame's visibility before the next sweep writes into it.

**Incorrect (reallocate or loop):**

```typescript
// Reallocates — garbage every frame.
state.visible = new Uint8Array(width * height);

// Or loops element by element — slower than the intrinsic memset.
for (let i = 0; i < state.visible.length; i++) state.visible[i] = 0;
```

**Correct (single intrinsic clear):**

```typescript
state.visible.fill(0); // contiguous memset, no allocation

// Clear only the box that could have been touched, to skip untouched memory:
state.visible.fill(0, rowStart, rowEnd); // fill supports start/end bounds
```

**When NOT to use this pattern:**
- On very large maps where the lit area is tiny relative to the buffer, a generation stamp (`mem-generation-stamp`) avoids the clear entirely instead of memset-ing the whole buffer.

Reference: [MDN — TypedArray.prototype.fill](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/TypedArray/fill)
