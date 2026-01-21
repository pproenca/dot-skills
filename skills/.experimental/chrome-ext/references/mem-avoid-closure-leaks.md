---
title: Avoid Accidental Closure Memory Leaks
impact: MEDIUM
impactDescription: prevents large objects from being retained unexpectedly
tags: mem, closures, scope, retention, memory-leak
---

## Avoid Accidental Closure Memory Leaks

Closures capture their enclosing scope. If a long-lived callback references a large object from an outer scope, that object stays in memory for the lifetime of the callback.

**Incorrect (closure retains large data):**

```javascript
// content.js - processedData stays in memory forever
function processPage() {
  const processedData = extractAllData();  // 10MB of page data

  chrome.runtime.onMessage.addListener((message) => {
    // This closure captures entire scope including processedData
    if (message.type === 'get-summary') {
      return processedData.summary;  // Only need summary, but entire object retained
    }
  });
}
```

**Correct (capture only needed values):**

```javascript
// content.js - Only summary stays in memory
function processPage() {
  const processedData = extractAllData();  // 10MB of page data
  const summary = processedData.summary;   // Extract what we need

  // processedData can be garbage collected
  chrome.runtime.onMessage.addListener((message) => {
    if (message.type === 'get-summary') {
      return summary;  // Only 1KB captured
    }
  });
}
```

**Alternative (nullify after use):**

```javascript
// content.js - Explicitly release reference
function processPage() {
  let processedData = extractAllData();

  // Process immediately
  const results = transformData(processedData);
  sendResults(results);

  // Allow garbage collection
  processedData = null;
}
```

**Closure leak in event handlers:**

```javascript
// Incorrect - largeData retained
function setup() {
  const largeData = generateLargeDataset();
  element.onclick = () => console.log(largeData.length);
}

// Correct - extract needed value
function setup() {
  const largeData = generateLargeDataset();
  const length = largeData.length;
  element.onclick = () => console.log(length);
}
```

Reference: [Closures MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Closures)
