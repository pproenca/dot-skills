---
title: Cache Frequently Accessed Storage Values in Memory
impact: HIGH
impactDescription: eliminates repeated async storage reads
tags: storage, cache, memory, read, performance
---

## Cache Frequently Accessed Storage Values in Memory

Reading from `chrome.storage` on every access adds async overhead. For values read frequently (like feature flags or user settings), cache them in memory and update via storage change listeners.

**Incorrect (reads storage on every access):**

```javascript
// content.js - Storage read on every page element
async function processElement(element) {
  // Reads storage for EVERY element processed
  const { highlightColor } = await chrome.storage.local.get('highlightColor');
  element.style.backgroundColor = highlightColor;
}

document.querySelectorAll('.target').forEach(processElement);
// 100 elements = 100 storage reads
```

**Correct (read once, cache in memory):**

```javascript
// content.js - Single read, memory cache
let settings = null;

async function initializeSettings() {
  settings = await chrome.storage.local.get({
    highlightColor: 'yellow',
    enabled: true
  });
}

function processElement(element) {
  if (!settings.enabled) return;
  element.style.backgroundColor = settings.highlightColor;
}

// Listen for changes and update cache
chrome.storage.onChanged.addListener((changes, areaName) => {
  if (areaName === 'local') {
    for (const [key, { newValue }] of Object.entries(changes)) {
      settings[key] = newValue;
    }
  }
});

// Initialize then process
initializeSettings().then(() => {
  document.querySelectorAll('.target').forEach(processElement);
});
```

**Service worker cache pattern:**

```javascript
// background.js - Cache with lazy loading
let cachedConfig = null;

async function getConfig() {
  if (!cachedConfig) {
    cachedConfig = await chrome.storage.local.get({
      apiUrl: 'https://api.example.com',
      maxRetries: 3
    });
  }
  return cachedConfig;
}

chrome.storage.onChanged.addListener((changes, areaName) => {
  if (areaName === 'local') {
    cachedConfig = null;  // Invalidate on any change
  }
});
```

Reference: [chrome.storage.onChanged](https://developer.chrome.com/docs/extensions/reference/api/storage#event-onChanged)
