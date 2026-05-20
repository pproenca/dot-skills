---
title: Keep Transitions Interruptible and Budgeted
impact: MEDIUM
impactDescription: prevents queued animations from lagging input
tags: anim, interruptible, budget, transitions, responsiveness
---

## Keep Transitions Interruptible and Budgeted

If a new interaction starts a fresh animation without cancelling the one in flight, transitions queue up and the camera lurches through stale targets — click three results quickly and you watch all three fly-bys in sequence. Make transitions interruptible: cancel or retarget the running tween from its current mid-animation state toward the new target, and cap how many marks animate at once so a huge update does not tween 100k cells simultaneously. Motion should always be heading toward the user's latest intent.

**Incorrect (each call starts another loop):**

```typescript
function goTo(target: ViewState) {
  requestAnimationFrame(function step() { /* ...tween... */ requestAnimationFrame(step); });
} // queued fly-bys through stale targets
```

**Correct (one cancellable tween, retargeted from the current state):**

```typescript
let raf = 0;
function goTo(target: ViewState, ms = 400) {
  cancelAnimationFrame(raf);                         // drop the in-flight animation
  const from = { ...view }, t0 = performance.now();  // retarget from where we are now
  raf = requestAnimationFrame(function step(now) {
    const k = easeInOutCubic(Math.min(1, (now - t0) / ms));
    view = lerpViewState(from, target, k); render();
    if (k < 1) raf = requestAnimationFrame(step);
  });
}
```

**When NOT to apply:**
- Short, non-overlapping transitions that can never collide do not need cancellation machinery.

Reference: [van Wijk & Nuij, Smooth and Efficient Zooming and Panning](https://vanwijk.win.tue.nl/zoompan.pdf); [MDN — cancelAnimationFrame](https://developer.mozilla.org/en-US/docs/Web/API/Window/cancelAnimationFrame)
