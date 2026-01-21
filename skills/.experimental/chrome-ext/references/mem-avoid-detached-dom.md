---
title: Avoid Holding References to Detached DOM Nodes
impact: MEDIUM
impactDescription: prevents DOM trees from being garbage collected
tags: mem, dom, detached, references, memory-leak
---

## Avoid Holding References to Detached DOM Nodes

When a DOM element is removed from the page but your JavaScript still references it, the element (and its entire subtree) cannot be garbage collected. This is a common source of memory leaks in content scripts.

**Incorrect (holds reference to removed elements):**

```javascript
// content.js - Elements stay in memory forever
const elementsCache = new Map();

function cacheElement(id) {
  const element = document.getElementById(id);
  elementsCache.set(id, element);  // Holds reference
}

cacheElement('sidebar');
// Later, page removes #sidebar via SPA navigation
// Element tree stays in memory because elementsCache holds reference
```

**Correct (use WeakRef or re-query):**

```javascript
// content.js - WeakRef allows garbage collection
const elementsCache = new Map();

function cacheElement(id) {
  const element = document.getElementById(id);
  if (element) {
    elementsCache.set(id, new WeakRef(element));
  }
}

function getElement(id) {
  const weakRef = elementsCache.get(id);
  if (!weakRef) return null;

  const element = weakRef.deref();
  if (!element || !document.contains(element)) {
    elementsCache.delete(id);  // Clean up stale reference
    return null;
  }
  return element;
}
```

**Alternative (re-query pattern):**

```javascript
// content.js - Query fresh each time
const selectors = {
  sidebar: '#sidebar',
  header: '.main-header'
};

function getElement(name) {
  return document.querySelector(selectors[name]);
}

// No cached references, always gets current element
const sidebar = getElement('sidebar');
if (sidebar) {
  processSidebar(sidebar);
}
```

**Detecting detached nodes:**
Use Chrome DevTools → Memory → Take heap snapshot → Search for "Detached"

Reference: [Fix Memory Problems](https://developer.chrome.com/docs/devtools/memory-problems)
