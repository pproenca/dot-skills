---
title: Use browser Namespace Over chrome
impact: LOW-MEDIUM
impactDescription: enables cross-browser compatibility with single API
tags: ts, browser, chrome, api, cross-browser
---

## Use browser Namespace Over chrome

Use the `browser` namespace from WXT instead of `chrome`. WXT normalizes `chrome` to `browser` for cross-browser compatibility across Chrome, Firefox, Safari, and Edge.

**Incorrect (chrome namespace):**

```typescript
export default defineBackground(() => {
  async function pingActiveTab() {
    try {
      const [tab] = await chrome.tabs.query({ active: true, currentWindow: true })
      if (tab?.id) {
        const response = await chrome.tabs.sendMessage(tab.id, { type: 'PING' })
        return response
      }
    } catch (error) {
      console.error('Failed to ping tab:', error)
    }
  }

  chrome.action.onClicked.addListener(() => {
    pingActiveTab()
  })
})
```

**Correct (browser namespace):**

```typescript
export default defineBackground(() => {
  async function pingActiveTab() {
    try {
      const [tab] = await browser.tabs.query({ active: true, currentWindow: true })
      if (tab?.id) {
        const response = await browser.tabs.sendMessage(tab.id, { type: 'PING' })
        return response
      }
    } catch (error) {
      console.error('Failed to ping tab:', error)
    }
  }

  browser.action.onClicked.addListener(() => {
    pingActiveTab()
  })
})
```

**Important (WXT v0.20+):** WXT no longer uses `webextension-polyfill`. The `browser` global is a direct re-export of the native `browser` or `chrome` global. This means:
- Promise-based APIs work natively (Chrome 116+)
- For APIs that may not exist on all browsers, use optional chaining: `browser.runtime.onSuspend?.addListener(() => {})`
- `browser` is auto-imported by WXT -- no explicit import needed

Reference: [WXT Extension APIs](https://wxt.dev/guide/essentials/extension-apis)
