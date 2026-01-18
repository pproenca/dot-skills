---
title: Use Promise-Based API Calls Over Callbacks
impact: LOW-MEDIUM
impactDescription: reduces callback nesting by 3-5 levels
tags: api, promises, callbacks, async, modern
---

## Use Promise-Based API Calls Over Callbacks

Modern Chrome Extension APIs support promises. Promise-based calls are cleaner, support async/await, and make error handling easier with try/catch.

**Incorrect (callback hell):**

```javascript
// background.js - Nested callbacks, hard to read
chrome.tabs.query({ active: true }, (tabs) => {
  if (chrome.runtime.lastError) {
    console.error(chrome.runtime.lastError);
    return;
  }
  chrome.tabs.sendMessage(tabs[0].id, { type: 'get-data' }, (response) => {
    if (chrome.runtime.lastError) {
      console.error(chrome.runtime.lastError);
      return;
    }
    chrome.storage.local.set({ data: response }, () => {
      if (chrome.runtime.lastError) {
        console.error(chrome.runtime.lastError);
        return;
      }
      console.log('Data saved');
    });
  });
});
```

**Correct (async/await with promises):**

```javascript
// background.js - Clean, linear flow
async function processActiveTab() {
  try {
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    const response = await chrome.tabs.sendMessage(tab.id, { type: 'get-data' });
    await chrome.storage.local.set({ data: response });
    console.log('Data saved');
  } catch (error) {
    console.error('Operation failed:', error);
  }
}
```

**Promise.all for parallel operations:**

```javascript
// background.js - Parallel API calls
async function gatherExtensionData() {
  const [tabs, storage, bookmarks] = await Promise.all([
    chrome.tabs.query({}),
    chrome.storage.local.get(null),
    chrome.bookmarks.getTree()
  ]);

  return { tabs, storage, bookmarks };
}
```

**Note:** All Chrome Extension APIs in the `chrome.*` namespace support promises as of Manifest V3. The `browser.*` namespace (available since Chrome 144) also uses promises.

Reference: [Chrome Extension APIs](https://developer.chrome.com/docs/extensions/reference/api)
