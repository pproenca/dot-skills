---
title: Use will-change Sparingly for Animation Hints
impact: LOW-MEDIUM
impactDescription: enables GPU layer promotion without overusing memory
tags: anim, will-change, gpu, performance, css
---

## Use will-change Sparingly for Animation Hints

The `will-change` property hints that an element will animate, allowing the browser to optimize ahead of time. But overuse consumes GPU memory and can hurt performance.

**Incorrect (will-change on too many elements):**

```css
/* Applied to everything "just in case" */
* {
  will-change: transform, opacity;
}

/* Or on static elements that rarely animate */
.card {
  will-change: transform;
}

.button {
  will-change: transform, opacity, background-color;
}
/* Hundreds of GPU layers created */
/* Memory consumption spikes, performance degrades */
```

**Correct (will-change only when needed):**

```css
/* Apply via JavaScript just before animation */
.element-about-to-animate {
  will-change: transform;
}

/* Or apply on parent hover when child will animate */
.card:hover .card-image {
  will-change: transform;
}

/* Remove after animation completes */
.element.animation-complete {
  will-change: auto;
}
```

```javascript
// Apply will-change just before animation
element.addEventListener('mouseenter', () => {
  element.style.willChange = 'transform';
});

element.addEventListener('animationend', () => {
  element.style.willChange = 'auto'; // Release GPU layer
});

// Or for scroll-triggered animations
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    entry.target.style.willChange = entry.isIntersecting
      ? 'transform, opacity'
      : 'auto';
  });
});
```

**will-change guidelines:**
- Never use `will-change: *` globally
- Apply just before animation starts
- Remove after animation completes
- Limit to 3-4 promoted layers per view
- Use for: modal opens, complex hover states, scroll animations

Reference: [MDN will-change](https://developer.mozilla.org/en-US/docs/Web/CSS/will-change)
