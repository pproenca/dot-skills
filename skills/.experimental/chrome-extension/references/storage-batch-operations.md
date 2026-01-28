---
title: Batch Storage Operations Instead of Individual Calls
impact: HIGH
impactDescription: reduces storage overhead by 5-20× for multiple values
tags: storage, batch, operations, performance, async
---

## Batch Storage Operations Instead of Individual Calls

Each `chrome.storage` call has async overhead. Reading or writing multiple values in separate calls multiplies this overhead. Use object syntax to batch operations.

**Incorrect (separate call per value):**

```javascript
// background.js - 5 separate async operations
async function saveUserPreferences(prefs) {
  await chrome.storage.local.set({ theme: prefs.theme });
  await chrome.storage.local.set({ fontSize: prefs.fontSize });
  await chrome.storage.local.set({ language: prefs.language });
  await chrome.storage.local.set({ notifications: prefs.notifications });
  await chrome.storage.local.set({ autoSave: prefs.autoSave });
}

async function loadUserPreferences() {
  const theme = await chrome.storage.local.get('theme');
  const fontSize = await chrome.storage.local.get('fontSize');
  const language = await chrome.storage.local.get('language');
  // 5 round trips to storage
}
```

**Correct (single batched operation):**

```javascript
// background.js - Single async operation
async function saveUserPreferences(prefs) {
  await chrome.storage.local.set({
    theme: prefs.theme,
    fontSize: prefs.fontSize,
    language: prefs.language,
    notifications: prefs.notifications,
    autoSave: prefs.autoSave
  });
}

async function loadUserPreferences() {
  const prefs = await chrome.storage.local.get([
    'theme', 'fontSize', 'language', 'notifications', 'autoSave'
  ]);
  return prefs;
}
```

**Get all stored data at once:**

```javascript
// Get everything (use sparingly for large datasets)
const allData = await chrome.storage.local.get(null);

// Get with defaults
const settings = await chrome.storage.local.get({
  theme: 'light',      // Default if not set
  fontSize: 14,
  language: 'en'
});
```

**Note:** Batching is especially important in content scripts where message passing adds additional latency to each operation.

Reference: [chrome.storage API](https://developer.chrome.com/docs/extensions/reference/api/storage)
