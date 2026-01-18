---
title: Batch Badge Updates to Avoid Flicker
impact: MEDIUM
impactDescription: prevents visual flicker and reduces API calls
tags: ui, badge, batching, updates, performance
---

## Batch Badge Updates to Avoid Flicker

Rapidly updating the browser action badge (text and color) causes visual flicker and unnecessary API calls. Debounce badge updates and set both properties in a single logical update.

**Incorrect (rapid updates cause flicker):**

```javascript
// background.js - Badge flickers with each message
chrome.runtime.onMessage.addListener((message) => {
  if (message.type === 'item-added') {
    updateBadgeCount();  // Called many times rapidly
  }
});

async function updateBadgeCount() {
  const { items } = await chrome.storage.local.get('items');
  const count = items?.length ?? 0;

  // Multiple rapid calls cause flicker
  await chrome.action.setBadgeText({ text: String(count) });
  await chrome.action.setBadgeBackgroundColor({
    color: count > 10 ? '#FF0000' : '#4CAF50'
  });
}
```

**Correct (debounced batch updates):**

```javascript
// background.js - Debounced, batched updates
let badgeUpdateTimeout = null;

chrome.runtime.onMessage.addListener((message) => {
  if (message.type === 'item-added') {
    scheduleBadgeUpdate();
  }
});

function scheduleBadgeUpdate() {
  if (badgeUpdateTimeout) {
    clearTimeout(badgeUpdateTimeout);
  }

  badgeUpdateTimeout = setTimeout(async () => {
    const { items } = await chrome.storage.local.get('items');
    const count = items?.length ?? 0;

    // Update both properties together
    await Promise.all([
      chrome.action.setBadgeText({ text: count > 0 ? String(count) : '' }),
      chrome.action.setBadgeBackgroundColor({
        color: count > 10 ? '#FF0000' : '#4CAF50'
      })
    ]);

    badgeUpdateTimeout = null;
  }, 100);  // 100ms debounce
}
```

**Tab-specific badges:**

```javascript
// background.js - Per-tab badge without global interference
async function updateTabBadge(tabId, count) {
  await Promise.all([
    chrome.action.setBadgeText({ tabId, text: String(count) }),
    chrome.action.setBadgeBackgroundColor({ tabId, color: '#4CAF50' })
  ]);
}

// Clear when tab closes
chrome.tabs.onRemoved.addListener((tabId) => {
  // Badge automatically cleared, no action needed
});
```

Reference: [chrome.action API](https://developer.chrome.com/docs/extensions/reference/api/action)
