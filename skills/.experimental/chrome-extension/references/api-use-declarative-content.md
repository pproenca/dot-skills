---
title: Use Declarative Content API for Page Actions
impact: LOW-MEDIUM
impactDescription: reduces service worker wake-ups for icon state changes
tags: api, declarativeContent, pageAction, icons, performance
---

## Use Declarative Content API for Page Actions

Instead of waking the service worker on every navigation to check if your icon should be enabled, use `declarativeContent` to let the browser handle it natively.

**Incorrect (SW wakes on every navigation):**

```javascript
// background.js - Wakes SW on every tab update
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (changeInfo.status === 'complete') {
    // Check every page load
    if (tab.url?.includes('github.com')) {
      chrome.action.enable(tabId);
      chrome.action.setIcon({ tabId, path: 'icon-active.png' });
    } else {
      chrome.action.disable(tabId);
    }
  }
});
```

**Correct (browser handles declaratively):**

```javascript
// background.js - Runs once at install, browser handles rest
chrome.runtime.onInstalled.addListener(() => {
  // Clear any existing rules
  chrome.declarativeContent.onPageChanged.removeRules(undefined, () => {
    // Add new rules
    chrome.declarativeContent.onPageChanged.addRules([{
      conditions: [
        new chrome.declarativeContent.PageStateMatcher({
          pageUrl: { hostSuffix: 'github.com' }
        }),
        new chrome.declarativeContent.PageStateMatcher({
          pageUrl: { hostSuffix: 'gitlab.com' }
        })
      ],
      actions: [
        new chrome.declarativeContent.ShowAction()
      ]
    }]);
  });
});
```

**Manifest configuration:**

```json
{
  "action": {
    "default_icon": "icon.png"
  },
  "permissions": ["declarativeContent"]
}
```

**Available conditions:**
- `pageUrl` - Match URL patterns
- `css` - Match pages with specific CSS selectors
- `isBookmarked` - Page is bookmarked

**Available actions:**
- `ShowAction` - Enable the action icon
- `SetIcon` - Change the icon
- `RequestContentScript` - Inject content script

Reference: [chrome.declarativeContent](https://developer.chrome.com/docs/extensions/reference/api/declarativeContent)
