---
title: Gate hover-only affordances behind a pointer query
tags: resp, hover, touch
---

## Gate hover-only affordances behind a pointer query

Putting essential controls or content behind `:hover` hides them on touch devices, where there is no hover and a tap can leave a sticky hover state behind. Reveal hover affordances only where a fine pointer exists, and keep the content reachable without hover.

```css
/* Row actions are always present; hover only enhances on a mouse */
.row__actions { opacity: 1; }
@media (hover: hover) and (pointer: fine) {
  .row__actions { opacity: 0; transition: opacity 150ms; }
  .row:hover .row__actions { opacity: 1; }
}
```

Reference: [MDN — hover media feature](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/hover)
