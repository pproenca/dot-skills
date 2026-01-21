---
title: Use activeTab Permission Instead of Broad Host Permissions
impact: MEDIUM-HIGH
impactDescription: eliminates permission warning, 0 scary prompts
tags: net, activeTab, permissions, security, user-experience
---

## Use activeTab Permission Instead of Broad Host Permissions

The `activeTab` permission grants temporary access to the current tab when the user clicks your extension icon. It shows no install warning and works on any site without requesting `<all_urls>`.

**Incorrect (scary permission warning):**

```json
{
  "host_permissions": ["<all_urls>"],
  "permissions": ["scripting"]
}
```

User sees: "Read and change all your data on all websites"

**Correct (no warning, same functionality):**

```json
{
  "permissions": ["activeTab", "scripting"]
}
```

```javascript
// background.js - Inject when user clicks icon
chrome.action.onClicked.addListener(async (tab) => {
  // activeTab grants temporary access to this specific tab
  await chrome.scripting.executeScript({
    target: { tabId: tab.id },
    files: ['content.js']
  });
});
```

**What activeTab grants:**
- Temporary host permission for the active tab
- Access to tab's URL, title, and favicon
- Ability to inject scripts/CSS into that tab
- Permission expires when tab navigates or closes

**Combining with user gestures:**

```javascript
// popup.js - User explicitly clicks button
document.getElementById('extract-btn').addEventListener('click', async () => {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });

  // activeTab permission is active due to popup interaction
  const results = await chrome.scripting.executeScript({
    target: { tabId: tab.id },
    func: () => document.title
  });

  displayResult(results[0].result);
});
```

**When host_permissions ARE needed:**
- Background processing without user interaction
- Modifying requests via declarativeNetRequest
- Content scripts that must run on page load

Reference: [activeTab Permission](https://developer.chrome.com/docs/extensions/develop/concepts/activeTab)
