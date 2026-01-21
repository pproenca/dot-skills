---
title: Debounce High-Frequency Events Before Messaging
impact: HIGH
impactDescription: reduces message volume by 90%+ for scroll/resize events
tags: msg, debounce, throttle, events, performance
---

## Debounce High-Frequency Events Before Messaging

Events like scroll, resize, and mousemove fire dozens of times per second. Sending a message for each event overwhelms the message channel and wastes CPU on redundant processing.

**Incorrect (message storm from every event):**

```javascript
// content.js - 60+ messages per second during scroll
window.addEventListener('scroll', () => {
  chrome.runtime.sendMessage({
    type: 'scroll',
    position: window.scrollY
  });
});

// User scrolls for 5 seconds = 300+ messages
```

**Correct (debounced messaging):**

```javascript
// content.js - Debounce to reduce message frequency
function debounce(fn, delay) {
  let timeoutId;
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
}

const sendScrollPosition = debounce((position) => {
  chrome.runtime.sendMessage({
    type: 'scroll',
    position
  });
}, 100);  // Max 10 messages/second

window.addEventListener('scroll', () => {
  sendScrollPosition(window.scrollY);
});
```

**Throttle for continuous updates:**

```javascript
// content.js - Throttle for regular sampling
function throttle(fn, limit) {
  let lastCall = 0;
  return (...args) => {
    const now = Date.now();
    if (now - lastCall >= limit) {
      lastCall = now;
      fn(...args);
    }
  };
}

const trackMousePosition = throttle((x, y) => {
  chrome.runtime.sendMessage({ type: 'mouse', x, y });
}, 200);  // At most every 200ms

document.addEventListener('mousemove', (e) => {
  trackMousePosition(e.clientX, e.clientY);
});
```

**When to use each:**
- **Debounce**: Final value matters (search input, resize end)
- **Throttle**: Regular sampling matters (scroll position, animations)

Reference: [Debouncing and Throttling Explained](https://css-tricks.com/debouncing-throttling-explained-examples/)
