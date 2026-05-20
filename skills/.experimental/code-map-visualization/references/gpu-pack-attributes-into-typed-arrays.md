---
title: Pack Per-Cell Attributes into Typed Arrays
impact: HIGH
impactDescription: prevents per-frame GC pauses from object churn
tags: gpu, typed-arrays, memory, garbage-collection, buffers
---

## Pack Per-Cell Attributes into Typed Arrays

Building an array of `{x, y, r, color}` objects every frame allocates tens of thousands of short-lived objects, and the resulting garbage-collection pauses surface as periodic frame drops during panning. Pack attributes into a single reusable `Float32Array` (or interleaved buffer) sized once, write into it in place each frame, and upload that. Zero per-frame allocation means no GC sawtooth, and the contiguous layout is what the GPU wants anyway.

**Incorrect (fresh objects every frame):**

```typescript
const data = cells.map((c) => ({ x: c.x, y: c.y, r: c.radius, color: c.color }));
upload(data);   // 100k allocations per frame -> GC sawtooth -> periodic jank
```

**Correct (one reusable buffer, written in place, uploaded each frame):**

```typescript
const buf = new Float32Array(cells.length * 6);   // [x,y,r,rgb] allocated once
for (let i = 0; i < cells.length; i++) {
  const c = cells[i], o = i * 6;
  buf[o] = c.x; buf[o + 1] = c.y; buf[o + 2] = c.radius;
  buf[o + 3] = c.r; buf[o + 4] = c.g; buf[o + 5] = c.b;
}
gl.bufferSubData(gl.ARRAY_BUFFER, 0, buf);        // no allocation, no GC
```

**When NOT to apply:**
- Small static datasets that upload once never hit the per-frame allocation path, so the readability cost of manual packing is not worth it.

Reference: [MDN — WebGL best practices](https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/WebGL_best_practices); [MDN — Optimizing canvas](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Optimizing_canvas)
