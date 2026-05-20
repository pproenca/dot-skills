---
title: Draw Cells with Instanced Rendering, Not One Draw Call Each
impact: HIGH
impactDescription: O(n) draw calls to O(1); 10-100x more marks
tags: gpu, instancing, draw-calls, webgl, deckgl
---

## Draw Cells with Instanced Rendering, Not One Draw Call Each

Each WebGL draw call carries fixed CPU and driver overhead; issuing one per cell caps you at a few thousand marks before the CPU — not the GPU — becomes the bottleneck. Instanced rendering uploads the cell quad once plus a per-instance attribute buffer (position, size, colour) and draws every cell in a single call, so the GPU does the work it is good at. This is exactly what a deck.gl layer does internally — reach for a layer before hand-rolling per-cell draws.

**Incorrect (one draw call per cell):**

```typescript
for (const c of cells) {
  setUniforms(gl, c.xy, c.radius, c.color);
  gl.drawArrays(gl.TRIANGLE_FAN, 0, 4);   // CPU-bound at a few thousand cells
}
```

**Correct (upload per-instance attributes once, draw all cells in one call):**

```typescript
gl.bindBuffer(gl.ARRAY_BUFFER, instanceBuffer);
gl.bufferData(gl.ARRAY_BUFFER, packed, gl.DYNAMIC_DRAW);   // [x,y,r,rgba] per cell
gl.drawArraysInstanced(gl.TRIANGLE_FAN, 0, 4, cells.length); // one call, all cells
```

Pack that instance buffer without per-frame allocation ([[gpu-pack-attributes-into-typed-arrays]]).

**When NOT to apply:**
- A static map rendered once to an image (server-side PNG export) does not care about per-frame draw-call overhead.

Reference: [MDN — WebGL best practices](https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/WebGL_best_practices); [deck.gl](https://deck.gl/)
