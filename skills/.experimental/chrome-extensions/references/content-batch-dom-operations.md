---
title: Batch DOM Operations to Minimize Reflows
impact: CRITICAL
impactDescription: reduces layout thrashing by 10-100×
tags: content, dom, reflow, performance, layout
---

## Batch DOM Operations to Minimize Reflows

Reading layout properties and modifying the DOM in alternating sequence causes layout thrashing. Batch all reads together, then all writes, to minimize expensive browser reflow calculations.

**Incorrect (layout thrashing with read-write alternation):**

```javascript
// content.js - Forces reflow on every iteration
function highlightElements(selectors) {
  selectors.forEach(selector => {
    const element = document.querySelector(selector);
    const height = element.offsetHeight;    // Read - forces layout
    element.style.height = height + 10 + 'px';  // Write - invalidates
    const width = element.offsetWidth;      // Read - forces reflow again
    element.style.width = width + 10 + 'px';    // Write - invalidates again
  });
}
// N elements = 4N layout calculations
```

**Correct (batched reads then writes):**

```javascript
// content.js - Single reflow for all operations
function highlightElements(selectors) {
  const elements = selectors.map(s => document.querySelector(s));

  // Batch all reads first
  const measurements = elements.map(el => ({
    element: el,
    height: el.offsetHeight,
    width: el.offsetWidth
  }));

  // Batch all writes together
  measurements.forEach(({ element, height, width }) => {
    element.style.height = height + 10 + 'px';
    element.style.width = width + 10 + 'px';
  });
}
// N elements = 2 layout calculations total
```

**Alternative (using DocumentFragment):**

```javascript
// content.js - Build DOM off-screen
function createOverlay(items) {
  const fragment = document.createDocumentFragment();

  items.forEach(item => {
    const div = document.createElement('div');
    div.className = 'overlay-item';
    div.textContent = item.label;
    fragment.appendChild(div);  // No reflow yet
  });

  document.body.appendChild(fragment);  // Single reflow
}
```

**Properties that trigger layout:**
`offsetHeight`, `offsetWidth`, `offsetTop`, `clientHeight`, `scrollHeight`, `getComputedStyle()`, `getBoundingClientRect()`

Reference: [What forces layout/reflow](https://gist.github.com/paulirish/5d52fb081b3570c81e3a)
