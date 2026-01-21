---
title: Avoid Broadcasting Messages to All Tabs
impact: HIGH
impactDescription: reduces message overhead from O(n) to O(1)
tags: msg, broadcast, tabs, targeted, performance
---

## Avoid Broadcasting Messages to All Tabs

Sending messages to all tabs wastes resources when only specific tabs need the update. Query for relevant tabs and target messages specifically.

**Incorrect (message sent to every tab):**

```javascript
// background.js - Broadcasts to all tabs
async function notifySettingsChange(settings) {
  const tabs = await chrome.tabs.query({});  // All tabs

  // Sends message to 50+ tabs, most don't care
  for (const tab of tabs) {
    chrome.tabs.sendMessage(tab.id, {
      type: 'settings-updated',
      settings
    }).catch(() => {});  // Many will fail (no content script)
  }
}
```

**Correct (targeted messaging):**

```javascript
// background.js - Message only relevant tabs
async function notifySettingsChange(settings) {
  // Query only tabs where content script is active
  const tabs = await chrome.tabs.query({
    url: ['https://github.com/*', 'https://gitlab.com/*']
  });

  await Promise.all(
    tabs.map(tab =>
      chrome.tabs.sendMessage(tab.id, {
        type: 'settings-updated',
        settings
      }).catch(() => {})  // Tab might have navigated away
    )
  );
}
```

**Alternative (track interested tabs):**

```javascript
// background.js - Registry pattern
const subscribedTabs = new Set();

chrome.runtime.onMessage.addListener((message, sender) => {
  if (message.type === 'subscribe') {
    subscribedTabs.add(sender.tab.id);
  }
  if (message.type === 'unsubscribe') {
    subscribedTabs.delete(sender.tab.id);
  }
});

chrome.tabs.onRemoved.addListener((tabId) => {
  subscribedTabs.delete(tabId);
});

async function notifySubscribers(data) {
  for (const tabId of subscribedTabs) {
    chrome.tabs.sendMessage(tabId, data).catch(() => {
      subscribedTabs.delete(tabId);
    });
  }
}
```

**When broadcast IS acceptable:**
- Critical security updates that affect all contexts
- Extension-wide state changes (like disable/enable)

Reference: [chrome.tabs.query](https://developer.chrome.com/docs/extensions/reference/api/tabs#method-query)
