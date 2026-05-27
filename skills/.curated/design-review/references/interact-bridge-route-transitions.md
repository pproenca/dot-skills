---
title: Bridge route changes so the screen never flashes blank
tags: interact, motion, navigation
---

## Bridge route changes so the screen never flashes blank

A route change that unmounts the old view and shows white space until data resolves reads as a broken cut, and the layout jumps a second time when the content finally lands. Hold the previous view or a skeleton during the pending phase, and for navigations that share a layout use the View Transitions API so the change cross-fades instead of snapping — gated behind `prefers-reduced-motion` so it degrades to an instant swap.

```tsx
// Same-document view transition: old and new views cross-fade instead of cutting to blank
function navigate(url: string) {
  if (!document.startViewTransition) return router.push(url);
  document.startViewTransition(() => router.push(url));
}
```

Reference: [MDN — View Transition API](https://developer.mozilla.org/en-US/docs/Web/API/View_Transition_API)
