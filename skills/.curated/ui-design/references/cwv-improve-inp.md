---
title: Improve Interaction to Next Paint
impact: CRITICAL
impactDescription: INP under 200ms makes UI feel responsive
tags: cwv, inp, responsiveness, javascript, performance
---

## Improve Interaction to Next Paint

INP measures responsiveness to user interactions. Slow INP (over 200ms) makes buttons feel broken and causes users to click repeatedly. INP replaced FID in March 2024.

**Incorrect (blocking main thread during interaction):**

```javascript
button.addEventListener('click', () => {
  // Synchronous heavy computation blocks UI
  const result = processLargeDataset(items); // 500ms blocking
  renderResults(result);
});
// User sees no response for 500ms after click

dropdown.addEventListener('change', (event) => {
  // DOM thrashing during interaction
  items.forEach(item => {
    item.style.display = shouldShow(item) ? 'block' : 'none';
    item.getBoundingClientRect(); // Forces reflow each iteration
  });
});
// Each dropdown change takes 300ms+
```

**Correct (non-blocking responsive interactions):**

```javascript
button.addEventListener('click', async () => {
  // Show immediate feedback
  button.disabled = true;
  showLoadingSpinner();

  // Defer heavy work
  await scheduler.yield();
  const result = await processLargeDatasetAsync(items);
  renderResults(result);
  button.disabled = false;
});
// User sees spinner within 16ms

dropdown.addEventListener('change', (event) => {
  // Batch DOM updates
  const updates = items.map(item => ({
    element: item,
    display: shouldShow(item) ? 'block' : 'none'
  }));

  requestAnimationFrame(() => {
    updates.forEach(({ element, display }) => {
      element.style.display = display;
    });
  });
});
// Single reflow, completes within 50ms
```

**INP optimization strategies:**
- Show immediate visual feedback on interaction
- Use `requestAnimationFrame` for DOM updates
- Break long tasks with `scheduler.yield()` or `setTimeout`
- Avoid synchronous layout (forced reflows)

Reference: [web.dev INP](https://web.dev/articles/inp)
