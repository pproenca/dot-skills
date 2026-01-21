---
title: Use WeakMap and WeakSet for DOM Element References
impact: MEDIUM
impactDescription: allows automatic garbage collection of cached elements
tags: mem, weakmap, weakset, dom, garbage-collection
---

## Use WeakMap and WeakSet for DOM Element References

When caching data associated with DOM elements, use `WeakMap` instead of `Map`. WeakMap allows elements to be garbage collected when removed from the page, preventing memory leaks.

**Incorrect (Map prevents garbage collection):**

```javascript
// content.js - Elements never garbage collected
const elementData = new Map();

document.querySelectorAll('.item').forEach(element => {
  elementData.set(element, {
    originalColor: element.style.color,
    processedAt: Date.now()
  });
});

// When elements removed from DOM, Map still holds references
// elementData grows unboundedly on SPAs
```

**Correct (WeakMap allows garbage collection):**

```javascript
// content.js - Elements can be garbage collected
const elementData = new WeakMap();

document.querySelectorAll('.item').forEach(element => {
  elementData.set(element, {
    originalColor: element.style.color,
    processedAt: Date.now()
  });
});

// When elements removed from DOM, WeakMap entries are automatically cleaned
```

**WeakSet for tracking processed elements:**

```javascript
// content.js - Track without preventing GC
const processedElements = new WeakSet();

function processNewElements() {
  document.querySelectorAll('.item').forEach(element => {
    if (processedElements.has(element)) return;  // Skip already processed

    processElement(element);
    processedElements.add(element);
  });
}

// Call on mutations
const observer = new MutationObserver(processNewElements);
observer.observe(document.body, { childList: true, subtree: true });
```

**WeakMap/WeakSet limitations:**
- Keys must be objects (not strings/numbers)
- Not iterable (can't loop over entries)
- No `.size` property
- Use regular Map/Set when you need these features

Reference: [WeakMap MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakMap)
