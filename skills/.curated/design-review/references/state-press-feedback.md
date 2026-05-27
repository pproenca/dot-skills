---
title: Give pressable elements active feedback
tags: state, feedback, buttons
---

## Give pressable elements active feedback

A button that only changes on hover feels inert on click and on touch, where hover barely exists, leaving the user unsure the press registered. Add a small `:active` transform so the element visibly responds the instant it is pressed.

```css
.button {
  transition: transform 150ms cubic-bezier(0.23, 1, 0.32, 1);
}
.button:active {
  transform: scale(0.97); /* subtle, instant confirmation of the press */
}
```

Reference: [Emil Kowalski — 7 practical animation tips](https://emilkowal.ski/ui/7-practical-animation-tips)
