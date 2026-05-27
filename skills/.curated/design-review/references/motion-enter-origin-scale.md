---
title: Enter from a near scale and the trigger's origin
tags: motion, transform-origin, animation
---

## Enter from a near scale and the trigger's origin

Animating a popover in from `scale(0)` makes it appear out of nowhere, and the default `transform-origin: center` makes it grow from the middle of itself instead of from the control that opened it. Start around `scale(0.95)` with opacity, and anchor the origin to the trigger.

**Incorrect (appears from nothing, grows from its own centre):**

```css
.popover[data-state="open"] { animation: pop 150ms; }
@keyframes pop { from { transform: scale(0); } }
```

**Correct (scales up subtly from the trigger origin):**

```css
.popover { transform-origin: var(--radix-popover-content-transform-origin); }
.popover[data-state="open"] { animation: pop 150ms cubic-bezier(0.23, 1, 0.32, 1); }
@keyframes pop { from { opacity: 0; transform: scale(0.95); } }
```

**When NOT to use this pattern:** modals are not anchored to a trigger — keep `transform-origin: center` for them.

Reference: [Emil Kowalski — Great animations](https://emilkowal.ski/ui/great-animations)
