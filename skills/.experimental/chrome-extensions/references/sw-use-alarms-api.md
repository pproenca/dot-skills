---
title: Use chrome.alarms Instead of setTimeout/setInterval
impact: CRITICAL
impactDescription: prevents timer callbacks from being lost on SW termination
tags: sw, alarms, timers, setTimeout, service-worker
---

## Use chrome.alarms Instead of setTimeout/setInterval

`setTimeout` and `setInterval` are canceled when service workers terminate. For any delayed or periodic operations, use the `chrome.alarms` API which persists across service worker restarts.

**Incorrect (timer lost when SW terminates):**

```javascript
// background.js
chrome.runtime.onInstalled.addListener(() => {
  // This timer will be lost if SW terminates before 5 minutes
  setTimeout(() => {
    checkForUpdates();
  }, 5 * 60 * 1000);

  // This interval stops when SW terminates
  setInterval(() => {
    syncBookmarks();
  }, 30 * 60 * 1000);
});
```

**Correct (alarms persist across SW restarts):**

```javascript
// background.js
chrome.runtime.onInstalled.addListener(() => {
  chrome.alarms.create('check-updates', { delayInMinutes: 5 });
  chrome.alarms.create('sync-bookmarks', { periodInMinutes: 30 });
});

chrome.alarms.onAlarm.addListener((alarm) => {
  switch (alarm.name) {
    case 'check-updates':
      checkForUpdates();
      break;
    case 'sync-bookmarks':
      syncBookmarks();
      break;
  }
});
```

**Limitations to know:**
- Minimum alarm period is 1 minute (shorter values are rounded up)
- Alarms cannot be set from content scripts
- Alarms do not persist across browser restarts

**When setTimeout IS acceptable:**
- Short delays under 30 seconds while SW is actively processing
- Debouncing rapid events within a single SW session

Reference: [chrome.alarms API](https://developer.chrome.com/docs/extensions/reference/api/alarms)
