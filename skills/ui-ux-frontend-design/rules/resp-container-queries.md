---
title: Use Container Queries for Component-Based Layouts
impact: HIGH
impactDescription: enables truly reusable responsive components
tags: resp, container-queries, css, components, responsive
---

## Use Container Queries for Component-Based Layouts

Media queries respond to viewport width, not component context. Container queries let components adapt to their container, making them truly reusable in any layout.

**Incorrect (media queries break in different contexts):**

```css
.product-card { display: flex; flex-direction: column; }

@media (min-width: 600px) {
  .product-card { flex-direction: row; }
}
/* Card goes horizontal at 600px viewport */
/* But what if it's in a 300px sidebar? Still horizontal = broken */
```

**Correct (container queries adapt to parent width):**

```css
.card-container {
  container-type: inline-size;
}

.product-card {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

@container (min-width: 400px) {
  .product-card {
    flex-direction: row;
  }

  .product-card .image {
    flex: 0 0 40%;
  }
}

@container (min-width: 600px) {
  .product-card .image {
    flex: 0 0 50%;
  }
}
/* Card responds to its container, not viewport */
/* Works in main content, sidebar, or modal */
```

**Container query use cases:**
- Cards that appear in multiple column layouts
- Navigation that collapses based on available space
- Widgets used in main content and sidebars
- Design system components that must work anywhere

**Browser support:** 90%+ (all modern browsers as of 2024)

Reference: [MDN Container Queries](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_containment/Container_queries)
