---
title: Honor the reduced-motion preference
tags: access, motion, preferences
---

## Honor the reduced-motion preference

Large transforms, parallax, and auto-playing motion can trigger nausea or vestibular discomfort for users who have asked their OS to reduce motion. Honour `prefers-reduced-motion` by cutting movement while keeping opacity and colour fades, which aid comprehension, rather than removing all feedback.

```css
.modal { transition: opacity 200ms, transform 200ms; }
@media (prefers-reduced-motion: reduce) {
  .modal { transition: opacity 200ms; } /* keep the fade, drop the movement */
}
```

Reference: [MDN — prefers-reduced-motion](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-reduced-motion)
