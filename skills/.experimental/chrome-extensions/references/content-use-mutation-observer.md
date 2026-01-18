---
title: Use MutationObserver Instead of Polling for DOM Changes
impact: CRITICAL
impactDescription: eliminates polling overhead, event-driven detection
tags: content, mutation-observer, polling, dom, performance
---

## Use MutationObserver Instead of Polling for DOM Changes

Polling the DOM with setInterval wastes CPU cycles checking for changes that haven't happened. MutationObserver is event-driven and only runs when the DOM actually changes.

**Incorrect (continuous polling wastes CPU):**

```javascript
// content.js - Checks every 100ms even when nothing changes
let lastContent = null;

setInterval(() => {
  const element = document.querySelector('.dynamic-content');
  if (element && element.textContent !== lastContent) {
    lastContent = element.textContent;
    processNewContent(element);
  }
}, 100);  // 10 checks per second, 600 per minute
```

**Correct (event-driven observation):**

```javascript
// content.js - Only runs when DOM actually changes
const observer = new MutationObserver((mutations) => {
  for (const mutation of mutations) {
    if (mutation.type === 'childList') {
      const newContent = mutation.target.querySelector('.dynamic-content');
      if (newContent) {
        processNewContent(newContent);
      }
    }
  }
});

observer.observe(document.body, {
  childList: true,
  subtree: true
});

// Clean up when content script is done
window.addEventListener('unload', () => observer.disconnect());
```

**Optimized observation (narrow scope):**

```javascript
// content.js - Watch only the relevant container
async function watchForContent() {
  // Wait for container to exist
  const container = await waitForElement('#app-container');

  const observer = new MutationObserver((mutations) => {
    for (const mutation of mutations) {
      processAddedNodes(mutation.addedNodes);
    }
  });

  observer.observe(container, {
    childList: true,
    subtree: false  // Don't watch deeply if not needed
  });
}

function waitForElement(selector) {
  return new Promise(resolve => {
    const el = document.querySelector(selector);
    if (el) return resolve(el);

    const observer = new MutationObserver(() => {
      const el = document.querySelector(selector);
      if (el) {
        observer.disconnect();
        resolve(el);
      }
    });
    observer.observe(document.body, { childList: true, subtree: true });
  });
}
```

Reference: [MutationObserver MDN](https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver)
