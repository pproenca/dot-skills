---
title: Ignore Extra Touch Points During Drag
impact: MEDIUM-HIGH
impactDescription: prevents the element jumping when a second finger touches mid-drag
tags: interact, touch, drag, gesture, multi-touch
---

## Ignore Extra Touch Points During Drag

Once a drag is in progress, ignore any additional pointers. Without this guard, a second finger touching the screen mid-drag (or switching fingers) starts a new drag and the element snaps to the new pointer position.

**Incorrect (every pointer starts a drag):**

```tsx
function onPointerDown(event: React.PointerEvent) {
  startDrag(event.clientY)
}
// A second finger begins a fresh drag; the drawer jumps to it
```

**Correct (first pointer wins until released):**

```tsx
function onPointerDown(event: React.PointerEvent) {
  if (isDragging) return // ignore extra touch points once dragging
  startDrag(event.clientY)
}
```

Pair this with pointer capture so the original finger keeps control even if it leaves the element bounds.

Reference: [Building a Drawer Component](https://emilkowal.ski/ui/building-a-drawer-component)
