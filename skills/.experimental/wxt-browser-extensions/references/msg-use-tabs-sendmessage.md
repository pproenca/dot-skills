---
title: Use tabs.sendMessage for Content Scripts
impact: HIGH
impactDescription: prevents silent message delivery failures
tags: msg, tabs, sendMessage, content-script, targeting
---

## Use tabs.sendMessage for Content Scripts

Use `browser.tabs.sendMessage` to send messages from background to specific content scripts. Using `runtime.sendMessage` from background won't reach content scripts.

**Incorrect (runtime.sendMessage from background):**

```typescript
// background.ts
export default defineBackground(() => {
  browser.action.onClicked.addListener(async (tab) => {
    // This goes to popup/options, NOT content scripts
    await browser.runtime.sendMessage({ type: 'TOGGLE_FEATURE' })
  })
})
```

**Correct (tabs.sendMessage targets content scripts):**

```typescript
// background.ts
export default defineBackground(() => {
  browser.action.onClicked.addListener(async (tab) => {
    if (!tab.id) return

    try {
      await browser.tabs.sendMessage(tab.id, { type: 'TOGGLE_FEATURE' })
    } catch (error) {
      // Content script not injected on this page
      console.log('Content script not available on this tab')
    }
  })
})

// content.ts
export default defineContentScript({
  matches: ['*://*/*'],
  main() {
    browser.runtime.onMessage.addListener((message) => {
      if (message.type === 'TOGGLE_FEATURE') {
        toggleFeature()
      }
    })
  }
})
```

**Note:** `tabs.sendMessage` throws if no content script is listening. Always wrap in try-catch or check if the tab URL matches your content script patterns first.

**Note:** [`@webext-core/messaging`](msg-type-safe-messaging.md) provides `sendMessage` with built-in tab targeting via the `tabId` option, handling this pattern automatically.

Reference: [Chrome Tabs sendMessage](https://developer.chrome.com/docs/extensions/reference/api/tabs#method-sendMessage)
