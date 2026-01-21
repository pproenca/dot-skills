---
title: Use Specific URL Match Patterns Instead of All URLs
impact: CRITICAL
impactDescription: reduces script injection by 90%+, faster browsing
tags: content, matches, permissions, injection, performance
---

## Use Specific URL Match Patterns Instead of All URLs

Using `<all_urls>` or overly broad match patterns injects your content script into every page, slowing down all browsing and increasing memory usage. Specify the exact domains and paths your extension needs.

**Incorrect (injected into every page):**

```json
{
  "content_scripts": [{
    "matches": ["<all_urls>"],
    "js": ["content.js"]
  }]
}
```

```json
{
  "content_scripts": [{
    "matches": ["*://*/*"],
    "js": ["content.js"]
  }]
}
```

**Correct (injected only where needed):**

```json
{
  "content_scripts": [{
    "matches": [
      "https://github.com/*",
      "https://gitlab.com/*"
    ],
    "js": ["content.js"]
  }]
}
```

**Even better (path-specific):**

```json
{
  "content_scripts": [{
    "matches": [
      "https://github.com/*/*/pull/*",
      "https://github.com/*/*/issues/*"
    ],
    "js": ["pr-tools.js"]
  }]
}
```

**If you need broad access conditionally:**

```javascript
// background.js - Inject only when needed
chrome.action.onClicked.addListener(async (tab) => {
  // User explicitly requested the feature
  await chrome.scripting.executeScript({
    target: { tabId: tab.id },
    files: ['content.js']
  });
});
```

**Note:** Over-requesting permissions is the #1 rejection reason in Chrome Web Store review.

Reference: [Match Patterns](https://developer.chrome.com/docs/extensions/develop/concepts/match-patterns)
