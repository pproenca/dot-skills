---
title: Avoid Redundant API Calls in Loops
impact: LOW-MEDIUM
impactDescription: reduces API overhead from N calls to 1
tags: api, loops, redundant, batching, performance
---

## Avoid Redundant API Calls in Loops

Calling Chrome APIs inside loops creates unnecessary overhead. Fetch data once before the loop, or batch operations where the API supports it.

**Incorrect (API call per iteration):**

```javascript
// content.js - Reads storage for each element
async function processElements() {
  const elements = document.querySelectorAll('.item');

  for (const element of elements) {
    // Storage read on EVERY element
    const { settings } = await chrome.storage.local.get('settings');
    applySettings(element, settings);
  }
}
// 100 elements = 100 storage reads
```

**Correct (single API call before loop):**

```javascript
// content.js - Read once, use many times
async function processElements() {
  const { settings } = await chrome.storage.local.get('settings');
  const elements = document.querySelectorAll('.item');

  for (const element of elements) {
    applySettings(element, settings);
  }
}
// 100 elements = 1 storage read
```

**Batch tab operations:**

```javascript
// background.js - Incorrect: update tabs one by one
async function muteAllTabs() {
  const tabs = await chrome.tabs.query({ audible: true });
  for (const tab of tabs) {
    await chrome.tabs.update(tab.id, { muted: true });  // Sequential
  }
}

// background.js - Correct: parallel batch update
async function muteAllTabs() {
  const tabs = await chrome.tabs.query({ audible: true });
  await Promise.all(
    tabs.map(tab => chrome.tabs.update(tab.id, { muted: true }))
  );
}
```

**Batch storage writes:**

```javascript
// Incorrect: separate writes
for (const item of items) {
  await chrome.storage.local.set({ [item.id]: item });
}

// Correct: single batched write
const updates = Object.fromEntries(items.map(i => [i.id, i]));
await chrome.storage.local.set(updates);
```

Reference: [chrome.storage API](https://developer.chrome.com/docs/extensions/reference/api/storage)
