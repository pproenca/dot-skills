---
title: Honor prefers-reduced-motion
impact: MEDIUM
impactDescription: prevents motion sickness from camera animation
tags: access, reduced-motion, animation, vestibular, media-query
---

## Honor prefers-reduced-motion

Large camera fly-tos, crossfades, and zoom animations ([[anim-ease-camera-transitions-not-jumps]]) can trigger nausea and disorientation for users with vestibular disorders. The OS-level `prefers-reduced-motion` setting is their explicit request to tone motion down; honour it by collapsing transitions to near-instant (a quick fade rather than a sweeping fly) rather than ignoring it. Read the media query and react to changes, since users can toggle it at runtime.

**Incorrect (always animate the full fly):**

```typescript
function goTo(target: ViewState) { flyTo(target, 400); } // 400ms sweep for everyone
```

**Correct (collapse duration when reduced motion is requested):**

```typescript
const reduce = matchMedia("(prefers-reduced-motion: reduce)");
function goTo(target: ViewState) {
  flyTo(target, reduce.matches ? 0 : 400);   // instant for reduced-motion users
}
reduce.addEventListener("change", rerenderControls); // honour a runtime toggle
```

**When NOT to apply:**
- There is no valid exception to skip the check — motion that conveys essential information should still be reduced and paired with a non-motion cue.

Reference: [MDN — prefers-reduced-motion](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-reduced-motion); [WCAG 2.2 — Animation from Interactions (2.3.3)](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html)
