---
title: Respect Alarms API Minimum Period
impact: LOW-MEDIUM
impactDescription: prevents unexpected 1-minute rounding
tags: api, alarms, timing, intervals, constraints
---

## Respect Alarms API Minimum Period

The chrome.alarms API enforces a minimum period of 1 minute. Shorter values are silently rounded up, which can cause unexpected behavior if you're expecting sub-minute intervals.

**Incorrect (assumes short intervals work):**

```javascript
// background.js - Won't work as expected
chrome.runtime.onInstalled.addListener(() => {
  // These all become 1-minute alarms
  chrome.alarms.create('quick-poll', { periodInMinutes: 0.1 });  // Rounded to 1
  chrome.alarms.create('check', { delayInMinutes: 0.5 });        // Rounded to 1
  chrome.alarms.create('update', { periodInMinutes: 0.25 });     // Rounded to 1
});

// Expecting 10-second intervals, gets 60-second intervals
```

**Correct (design for minimum constraints):**

```javascript
// background.js - Use appropriate timing
chrome.runtime.onInstalled.addListener(() => {
  // Respect the 1-minute minimum
  chrome.alarms.create('sync-data', { periodInMinutes: 1 });

  // For less frequent operations, use longer periods
  chrome.alarms.create('daily-report', { periodInMinutes: 1440 });
});

// For sub-minute polling while SW is active, combine approaches
let pollingInterval = null;

function startActivePolling() {
  // Use setInterval while actively processing
  pollingInterval = setInterval(checkForUpdates, 5000);

  // Backup alarm ensures recovery if SW dies
  chrome.alarms.create('polling-backup', { periodInMinutes: 1 });
}

chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === 'polling-backup') {
    checkForUpdates();
    startActivePolling();  // Resume fast polling
  }
});
```

**When you need sub-minute updates:**
- Keep service worker active with ongoing operations
- Use setInterval while actively processing
- Accept 1-minute minimum for background wake-ups

Reference: [chrome.alarms API](https://developer.chrome.com/docs/extensions/reference/api/alarms)
