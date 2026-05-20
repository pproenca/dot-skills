---
title: Batch by State to Cut Draw Calls and GPU State Changes
impact: HIGH
impactDescription: prevents a pipeline flush per domain group
tags: gpu, batching, state-changes, draw-calls, sorting
---

## Batch by State to Cut Draw Calls and GPU State Changes

Beyond instancing, the next cost is *state changes* — switching shader program, texture, or blend mode between draws flushes the GPU pipeline. Drawing cells grouped by domain, each group binding a different texture or shader, multiplies these flushes. Sort and group draws so all geometry sharing a program and texture goes out together, and pass per-cell variation (colour, size) as attributes rather than as state. Fewer, larger batches keep the pipeline full.

**Incorrect (rebind program and texture per domain group):**

```typescript
for (const [domain, group] of byDomain) {
  gl.useProgram(programs[domain]);
  gl.bindTexture(gl.TEXTURE_2D, textures[domain]);  // pipeline flush each group
  drawInstanced(group);
}
```

**Correct (one program plus one atlas; an attribute selects the look):**

```typescript
gl.useProgram(cellProgram);
gl.bindTexture(gl.TEXTURE_2D, atlas);             // bound once for the frame
gl.drawArraysInstanced(gl.TRIANGLE_FAN, 0, 4, cells.length); // single batch
```

The shared atlas this depends on is its own concern ([[gpu-atlas-tiles-and-glyphs]]).

**When NOT to apply:**
- If every cell genuinely needs a unique shader (rare for a map), batching cannot help — but most "different look per domain" needs are an attribute, not a program.

Reference: [MDN — WebGL best practices](https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/WebGL_best_practices); [W3C — WebGPU](https://www.w3.org/TR/webgpu/)
