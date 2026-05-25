---
title: Build mobile-first with fluid widths
tags: resp, responsive, layout
---

## Build mobile-first with fluid widths

Hard-coding pixel widths (`width: 1200px`) produces layouts that overflow small screens and force horizontal scrolling. Start from the small-screen layout with fluid units, then add columns at larger breakpoints with `min-width` media queries.

**Incorrect (a fixed width overflows phones):**

```css
.dashboard-grid { width: 1200px; display: grid; grid-template-columns: repeat(3, 1fr); }
```

**Correct (fluid, mobile-first, enhancing upward):**

```css
.dashboard-grid { width: 100%; display: grid; gap: 16px; }
@media (min-width: 768px) {
  .dashboard-grid { grid-template-columns: repeat(3, 1fr); }
}
```

Reference: [web.dev — Responsive web design basics](https://web.dev/articles/responsive-web-design-basics)
