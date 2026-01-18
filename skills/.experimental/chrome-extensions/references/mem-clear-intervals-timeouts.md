---
title: Clear Intervals and Timeouts on Cleanup
impact: MEDIUM
impactDescription: prevents orphaned timers from running after context destroyed
tags: mem, timers, intervals, cleanup, memory-leak
---

## Clear Intervals and Timeouts on Cleanup

Uncleaned intervals continue running after content script context is destroyed, causing errors and wasted CPU. Always clear timers when your script unloads.

**Incorrect (interval runs forever):**

```javascript
// content.js - Never cleared
setInterval(() => {
  const element = document.querySelector('.dynamic-content');
  updateElement(element);  // Error after SPA navigation
}, 1000);

setTimeout(() => {
  heavyComputation();  // Runs even if no longer needed
}, 60000);
```

**Correct (tracked and cleared):**

```javascript
// content.js - Track all timers
const timers = {
  intervals: [],
  timeouts: []
};

function setTrackedInterval(callback, delay) {
  const id = setInterval(callback, delay);
  timers.intervals.push(id);
  return id;
}

function setTrackedTimeout(callback, delay) {
  const id = setTimeout(callback, delay);
  timers.timeouts.push(id);
  return id;
}

setTrackedInterval(() => {
  const element = document.querySelector('.dynamic-content');
  if (element) updateElement(element);
}, 1000);

// Cleanup function
function cleanup() {
  timers.intervals.forEach(clearInterval);
  timers.timeouts.forEach(clearTimeout);
  timers.intervals = [];
  timers.timeouts = [];
}

window.addEventListener('unload', cleanup);
```

**AbortSignal pattern (for newer APIs):**

```javascript
// content.js - Using AbortSignal with setTimeout (proposal)
const controller = new AbortController();

// For fetch requests with timeout
const timeoutId = setTimeout(() => controller.abort(), 5000);

fetch(url, { signal: controller.signal })
  .then(response => response.json())
  .finally(() => clearTimeout(timeoutId));
```

**Service worker note:**
In service workers, `setTimeout`/`setInterval` are unreliable due to termination. Use `chrome.alarms` instead for persistent timing needs.

Reference: [WindowOrWorkerGlobalScope.clearInterval()](https://developer.mozilla.org/en-US/docs/Web/API/clearInterval)
