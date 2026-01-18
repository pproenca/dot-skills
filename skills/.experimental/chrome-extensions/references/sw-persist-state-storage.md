---
title: Persist State with chrome.storage Instead of Global Variables
impact: CRITICAL
impactDescription: prevents complete state loss on SW termination
tags: sw, state-management, storage, service-worker, persistence
---

## Persist State with chrome.storage Instead of Global Variables

Service workers terminate after 30 seconds of inactivity. Any global variables are lost when this happens. Use `chrome.storage.local` or `chrome.storage.session` to persist state across service worker restarts.

**Incorrect (state lost on SW termination):**

```javascript
// background.js (service worker)
let userSettings = { theme: 'dark', notifications: true };

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'get-settings') {
    sendResponse(userSettings);  // Returns undefined after SW restart
  }
  if (message.type === 'set-settings') {
    userSettings = message.settings;  // Lost when SW terminates
  }
});
```

**Correct (state persisted across restarts):**

```javascript
// background.js (service worker)
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'get-settings') {
    chrome.storage.local.get(['userSettings']).then(({ userSettings }) => {
      sendResponse(userSettings ?? { theme: 'dark', notifications: true });
    });
    return true;  // Keep channel open for async response
  }
  if (message.type === 'set-settings') {
    chrome.storage.local.set({ userSettings: message.settings });
  }
});
```

**When to use each storage type:**
- `chrome.storage.local` - Persists across browser restarts (10MB limit)
- `chrome.storage.session` - Cleared when browser closes, not synced (10MB limit)
- `chrome.storage.sync` - Synced across devices (100KB limit, 8KB per item)

Reference: [Migrate to a Service Worker](https://developer.chrome.com/docs/extensions/develop/migrate/to-service-workers)
