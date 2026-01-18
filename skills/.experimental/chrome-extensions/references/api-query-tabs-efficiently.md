---
title: Query Tabs with Specific Filters
impact: LOW-MEDIUM
impactDescription: reduces processing from all tabs to relevant subset
tags: api, tabs, query, filtering, performance
---

## Query Tabs with Specific Filters

Querying all tabs and filtering in JavaScript wastes resources. Use `chrome.tabs.query` filter options to let the browser return only relevant tabs.

**Incorrect (query all, filter in JS):**

```javascript
// background.js - Fetches all tabs, filters manually
async function getGitHubTabs() {
  const allTabs = await chrome.tabs.query({});  // All tabs
  return allTabs.filter(tab =>
    tab.url?.includes('github.com')
  );
}

async function getActiveTabs() {
  const allTabs = await chrome.tabs.query({});
  return allTabs.filter(tab => tab.active);  // Most are false
}
```

**Correct (let browser filter):**

```javascript
// background.js - Browser returns filtered results
async function getGitHubTabs() {
  return chrome.tabs.query({
    url: ['https://github.com/*', 'https://gist.github.com/*']
  });
}

async function getActiveTab() {
  const [tab] = await chrome.tabs.query({
    active: true,
    currentWindow: true
  });
  return tab;
}

async function getAudibleTabs() {
  return chrome.tabs.query({ audible: true });
}
```

**Useful query filters:**

```javascript
// Pinned tabs
const pinned = await chrome.tabs.query({ pinned: true });

// Tabs with unsaved content
const unsaved = await chrome.tabs.query({ autoDiscardable: false });

// Tabs in specific window
const windowTabs = await chrome.tabs.query({ windowId: someWindowId });

// Muted tabs
const muted = await chrome.tabs.query({ muted: true });

// Discarded (sleeping) tabs
const discarded = await chrome.tabs.query({ discarded: true });
```

**Note:** URL filtering requires `tabs` permission or appropriate host permissions.

Reference: [chrome.tabs.query](https://developer.chrome.com/docs/extensions/reference/api/tabs#method-query)
