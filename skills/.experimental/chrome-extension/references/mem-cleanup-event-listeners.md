---
title: Clean Up Event Listeners When Content Script Unloads
impact: MEDIUM
impactDescription: prevents memory accumulation on long-running tabs
tags: mem, events, listeners, cleanup, memory-leak
---

## Clean Up Event Listeners When Content Script Unloads

Event listeners attached to page elements persist even after your content script context is destroyed. These orphaned listeners accumulate memory and can cause unexpected behavior.

**Incorrect (listeners never removed):**

```javascript
// content.js - Listeners accumulate on SPA navigation
document.addEventListener('scroll', handleScroll);
document.addEventListener('click', handleClick);
window.addEventListener('resize', handleResize);

const targetElement = document.querySelector('.target');
targetElement.addEventListener('mouseenter', showTooltip);
// On SPA navigation, new content script runs, old listeners remain
```

**Correct (cleanup on unload):**

```javascript
// content.js - Track and remove listeners
const listeners = [];

function addTrackedListener(target, event, handler) {
  target.addEventListener(event, handler);
  listeners.push({ target, event, handler });
}

addTrackedListener(document, 'scroll', handleScroll);
addTrackedListener(document, 'click', handleClick);
addTrackedListener(window, 'resize', handleResize);

// Clean up when content script context is invalidated
window.addEventListener('unload', cleanup);
chrome.runtime.onMessage.addListener((message) => {
  if (message.type === 'cleanup') cleanup();
});

function cleanup() {
  listeners.forEach(({ target, event, handler }) => {
    target.removeEventListener(event, handler);
  });
  listeners.length = 0;
}
```

**AbortController pattern (modern approach):**

```javascript
// content.js - Single signal aborts all listeners
const controller = new AbortController();
const { signal } = controller;

document.addEventListener('scroll', handleScroll, { signal });
document.addEventListener('click', handleClick, { signal });
window.addEventListener('resize', handleResize, { signal });

// Clean up all at once
window.addEventListener('unload', () => controller.abort());
```

**MutationObserver cleanup:**

```javascript
// content.js
const observer = new MutationObserver(handleMutations);
observer.observe(document.body, { childList: true, subtree: true });

window.addEventListener('unload', () => {
  observer.disconnect();
});
```

Reference: [Memory Management MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Memory_Management)
