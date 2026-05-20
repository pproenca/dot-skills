---
title: Ease Camera Transitions Instead of Jumping
impact: MEDIUM
impactDescription: prevents loss of spatial context on view changes
tags: anim, camera, easing, fly-to, transitions
---

## Ease Camera Transitions Instead of Jumping

When the user clicks a search result or a breadcrumb ([[nav-breadcrumb-prefix-path]]), teleporting the camera to the target discards the relationship between where they were and where they land, so they lose their bearings and re-orient from scratch. Easing the camera — interpolating centre and zoom over a few hundred milliseconds, ideally along a smooth zoom-out-then-in arc for distant jumps — lets the eye track the motion and preserves the mental map. Shorten or skip the tween for reduced-motion users ([[access-honor-prefers-reduced-motion]]).

**Incorrect (instant jump):**

```typescript
function goTo(target: ViewState) { view = target; render(); } // user loses the target's context
```

**Correct (ease centre and zoom so the eye can follow):**

```typescript
function goTo(target: ViewState, ms = 400) {
  const from = { ...view }, t0 = performance.now();
  const step = (now: number) => {
    const k = easeInOutCubic(Math.min(1, (now - t0) / ms));
    view = lerpViewState(from, target, k);
    render();
    if (k < 1) requestAnimationFrame(step);
  };
  requestAnimationFrame(step);
}
```

**When NOT to apply:**
- Reduced-motion users, or moves within the same screenful where there is no surrounding context to lose.

Reference: [van Wijk & Nuij, Smooth and Efficient Zooming and Panning (IEEE InfoVis 2003)](https://vanwijk.win.tue.nl/zoompan.pdf); [deck.gl — FlyToInterpolator](https://deck.gl/docs/api-reference/core/fly-to-interpolator)
