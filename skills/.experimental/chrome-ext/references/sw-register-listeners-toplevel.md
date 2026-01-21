---
title: Register Event Listeners at Top Level of Service Worker
impact: CRITICAL
impactDescription: prevents missed events when SW restarts
tags: sw, events, listeners, service-worker, initialization
---

## Register Event Listeners at Top Level of Service Worker

Event listeners must be registered synchronously at the top level of your service worker. If listeners are registered inside async callbacks or conditionally, events may be missed when the service worker wakes up.

**Incorrect (listeners registered conditionally or async):**

```javascript
// background.js
chrome.storage.local.get(['isEnabled']).then(({ isEnabled }) => {
  if (isEnabled) {
    // Listener registered too late - events during startup are lost
    chrome.tabs.onUpdated.addListener(handleTabUpdate);
  }
});

async function initialize() {
  await loadConfiguration();
  // Registered after async operation - may miss events
  chrome.runtime.onMessage.addListener(handleMessage);
}

initialize();
```

**Correct (listeners registered synchronously at top level):**

```javascript
// background.js
// Register ALL listeners synchronously at the top level
chrome.tabs.onUpdated.addListener(handleTabUpdate);
chrome.runtime.onMessage.addListener(handleMessage);
chrome.runtime.onInstalled.addListener(handleInstall);
chrome.alarms.onAlarm.addListener(handleAlarm);

// Check conditions INSIDE the handlers
async function handleTabUpdate(tabId, changeInfo, tab) {
  const { isEnabled } = await chrome.storage.local.get(['isEnabled']);
  if (!isEnabled) return;  // Early return if disabled

  if (changeInfo.status === 'complete') {
    await processTab(tab);
  }
}

async function handleMessage(message, sender, sendResponse) {
  const config = await loadConfiguration();
  // Use config in handler logic
  return true;
}
```

**Why this matters:**
Chrome only dispatches events to listeners that exist when the SW starts. If your listener is registered after an async operation, Chrome doesn't know about it and won't wake your SW for those events.

Reference: [Extension Service Worker Lifecycle](https://developer.chrome.com/docs/extensions/develop/concepts/service-workers/lifecycle)
