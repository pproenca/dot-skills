---
title: Keep UI transitions under 300ms
tags: motion, timing, animation
---

## Keep UI transitions under 300ms

Durations of 400ms and up feel laggy for everyday UI because the motion outlasts the user's expectation of an instant response. Keep interface transitions in the 120–260ms range, and make the exit faster than the entrance since the user has already moved on.

```css
.toast {
  transition: transform 220ms cubic-bezier(0.23, 1, 0.32, 1);
}
.toast[data-state="closed"] {
  transition-duration: 150ms; /* leave faster than it arrived */
}
```

Reference: [Emil Kowalski — Good vs great animations](https://emilkowal.ski/ui/good-vs-great-animations)
