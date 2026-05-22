---
title: Animate Fog Reveal by Lerping Alpha, Not Recomputing FOV
impact: MEDIUM
impactDescription: avoids sub-frame FOV recompute
tags: render, animation, alpha, interpolation, fade
---

## Animate Fog Reveal by Lerping Alpha, Not Recomputing FOV

Making fog fade in and out smoothly by recomputing field of view at sub-frame granularity (a growing radius, fractional steps) multiplies the most expensive operation by the animation duration. Recompute visibility once, on the discrete tile change, then animate each tile's fog alpha toward its target in the renderer. The field of view is computed a single time while the visuals interpolate for free every frame.

**Incorrect (recompute FOV per frame for the fade):**

```typescript
// Re-sweeps the whole FOV every frame just to grow the lit radius smoothly.
function fadeIn(state: GameState, t: number): void {
  const r = state.player.sight * easeOut(t); // fractional radius
  state.visible.fill(0);
  computeFov(state.grid, state.player.x, state.player.y, Math.ceil(r));
  renderFog(state);
}
```

**Correct (FOV once; renderer eases alpha toward target):**

```typescript
// curAlpha is the displayed opacity; fog holds the discrete target state.
function animateFog(curAlpha: Float32Array, fog: Uint8Array, dt: number): void {
  const rate = Math.min(1, dt * 6); // ease speed, frame-rate independent
  for (let i = 0; i < curAlpha.length; i++) {
    const target = fog[i] & VISIBLE ? 0 : fog[i] & EXPLORED ? 0.55 : 1;
    curAlpha[i] += (target - curAlpha[i]) * rate; // smooth approach, no FOV work
  }
}
```

**Benefits:**
- One FOV recompute per actual visibility change; the fade is pure interpolation.
- Easing in a shader (sampling the fog texture) moves even the per-tile lerp off the CPU.

Reference: [MDN — requestAnimationFrame](https://developer.mozilla.org/en-US/docs/Web/API/Window/requestAnimationFrame)
