---
title: Upload Only the Dirty Rect of the Fog Texture in WebGL
impact: MEDIUM-HIGH
impactDescription: reduces upload to the dirty rect
tags: render, webgl, texsubimage2d, texture, gpu-upload
---

## Upload Only the Dirty Rect of the Fog Texture in WebGL

In a WebGL renderer, re-uploading the entire fog texture every frame with `texImage2D` transfers the whole buffer across the CPU-GPU bus even when only a few tiles changed. Keep the fog as a single-channel (`R8`) texture and push just the changed sub-rectangle with `texSubImage2D`, using `UNPACK_ROW_LENGTH` so the source rows line up with the full buffer. Sample the texture in the fragment shader, where blending and upscaling cost nothing extra.

**Incorrect (full texture upload every frame):**

```typescript
function uploadFog(gl: WebGL2RenderingContext, fog: Uint8Array): void {
  gl.bindTexture(gl.TEXTURE_2D, fogTex);
  // Re-sends the whole width*height buffer even if one tile changed.
  gl.texImage2D(gl.TEXTURE_2D, 0, gl.R8, width, height, 0, gl.RED, gl.UNSIGNED_BYTE, fog);
}
```

**Correct (upload only the changed sub-rectangle):**

```typescript
interface DirtyBox { x: number; y: number; w: number; h: number; }

function uploadDirtyFog(gl: WebGL2RenderingContext, fog: Uint8Array, box: DirtyBox): void {
  gl.bindTexture(gl.TEXTURE_2D, fogTex);
  gl.pixelStorei(gl.UNPACK_ROW_LENGTH, width); // source stride = full buffer width
  gl.texSubImage2D(
    gl.TEXTURE_2D, 0, box.x, box.y, box.w, box.h,
    gl.RED, gl.UNSIGNED_BYTE, fog, box.y * width + box.x, // offset to box origin
  );
  gl.pixelStorei(gl.UNPACK_ROW_LENGTH, 0); // reset for other uploads
}
```

**Benefits:**
- Bus traffic scales with the dirty rectangle, not the whole map.
- Sampling the fog texture in-shader gives free bilinear softness and per-pixel blending.

Reference: [WebGL2 — texSubImage2D and pixel store parameters](https://webgl2fundamentals.org/webgl/lessons/webgl-data-textures.html)
