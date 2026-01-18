---
title: Avoid Storing Large Binary Blobs in chrome.storage
impact: HIGH
impactDescription: prevents quota exhaustion and serialization overhead
tags: storage, blobs, binary, quota, performance
---

## Avoid Storing Large Binary Blobs in chrome.storage

`chrome.storage` JSON-serializes all data. Binary data like images or files become base64-encoded, increasing size by ~33%. Use IndexedDB or Cache API for binary data.

**Incorrect (base64-encoded images in storage):**

```javascript
// background.js - Images bloat storage
async function cacheScreenshot(tabId) {
  const dataUrl = await chrome.tabs.captureVisibleTab();
  // 1MB image becomes ~1.3MB base64 string
  await chrome.storage.local.set({
    [`screenshot:${tabId}`]: dataUrl
  });
}
// 10 screenshots = 13MB, quota nearly exhausted
```

**Correct (use IndexedDB for binary data):**

```javascript
// background.js - Binary data in IndexedDB
const DB_NAME = 'extension-cache';
const STORE_NAME = 'screenshots';

async function openDatabase() {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, 1);
    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve(request.result);
    request.onupgradeneeded = (event) => {
      event.target.result.createObjectStore(STORE_NAME);
    };
  });
}

async function cacheScreenshot(tabId) {
  const dataUrl = await chrome.tabs.captureVisibleTab();
  // Convert to Blob for efficient storage
  const response = await fetch(dataUrl);
  const blob = await response.blob();

  const db = await openDatabase();
  const tx = db.transaction(STORE_NAME, 'readwrite');
  tx.objectStore(STORE_NAME).put(blob, `screenshot:${tabId}`);
}

async function getScreenshot(tabId) {
  const db = await openDatabase();
  const tx = db.transaction(STORE_NAME, 'readonly');
  return new Promise((resolve) => {
    const request = tx.objectStore(STORE_NAME).get(`screenshot:${tabId}`);
    request.onsuccess = () => resolve(request.result);
  });
}
```

**When to use each storage:**

| Data Type | Best Storage |
|-----------|-------------|
| JSON config/settings | chrome.storage |
| Small strings (<100KB) | chrome.storage |
| Images, files, audio | IndexedDB |
| HTTP responses | CacheStorage |

Reference: [IndexedDB API](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API)
