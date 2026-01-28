---
title: Use browser Namespace Over chrome
impact: LOW-MEDIUM
impactDescription: enables cross-browser compatibility with single API
tags: ts, browser, chrome, api, cross-browser
---

## Use browser Namespace Over chrome

Use the `browser` namespace from WXT instead of `chrome`. WXT polyfills this for cross-browser compatibility and adds Promise support.

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

**Note:** WXT automatically provides the `browser` global. No import needed. It works across Chrome, Firefox, Safari, and Edge with consistent Promise-based APIs.

Reference: [WXT Extension APIs](https://wxt.dev/guide/essentials/extension-apis)
