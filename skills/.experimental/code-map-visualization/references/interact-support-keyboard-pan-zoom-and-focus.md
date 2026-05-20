---
title: Drive the Camera and Selection from the Keyboard
impact: MEDIUM
impactDescription: prevents a pointer-only, unnavigable map
tags: interact, keyboard, focus, camera, navigation
---

## Drive the Camera and Selection from the Keyboard

Pan, zoom, and select are usually wired to mouse and wheel only, which makes the map unusable without a pointer and breaks power-user flow. Bind arrow keys to pan the camera, +/- to zoom around the focused point, and a roving focus that moves a selection cursor and keeps the focused cell in view by easing the camera to it ([[anim-ease-camera-transitions-not-jumps]]). This is the interaction-mechanics half of full keyboard operability ([[access-make-the-map-keyboard-operable]]).

**Incorrect (navigation is pointer-only):**

```typescript
canvas.addEventListener("wheel", onZoom);
canvas.addEventListener("pointerdown", onDragStart);  // no keyboard path at all
```

**Correct (keys drive the same view-state the pointer does):**

```typescript
canvas.tabIndex = 0;                                  // canvas can hold focus
canvas.addEventListener("keydown", (e) => {
  if (e.key === "ArrowRight") panBy(STEP, 0);
  else if (e.key === "+")     zoomTo(view.zoom + 1, focusedCell);
  else if (e.key === "Enter") select(focusedCell);
  else return;
  e.preventDefault();                                 // stop arrows scrolling the page
});
```

**When NOT to apply:**
- A purely decorative, non-interactive map exposes no actions to the keyboard because it has none — but any map with hover or click needs this.

Reference: [WCAG 2.2 — Keyboard (2.1.1)](https://www.w3.org/WAI/WCAG22/Understanding/keyboard.html); [MapLibre GL JS (keyboard handler)](https://maplibre.org/)
