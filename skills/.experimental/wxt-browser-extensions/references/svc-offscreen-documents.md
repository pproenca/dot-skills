---
title: Use Offscreen Documents for DOM Operations
impact: CRITICAL
impactDescription: enables DOM APIs unavailable in service workers
tags: svc, offscreen, dom, clipboard, audio
---

## Use Offscreen Documents for DOM Operations

MV3 service workers cannot access DOM APIs. Use offscreen documents for operations requiring DOM like clipboard access, audio playback, or canvas manipulation.

**Incorrect (DOM API in service worker):**

```typescript
export default defineBackground(() => {
  browser.runtime.onMessage.addListener(async (message) => {
    if (message.type === 'COPY_TO_CLIPBOARD') {
      // Error: document is not defined in service worker
      const textarea = document.createElement('textarea')
      textarea.value = message.text
      document.body.appendChild(textarea)
      textarea.select()
      document.execCommand('copy')
    }
  })
})
```

**Correct (offscreen document with HTML entrypoint):**

```typescript
// entrypoints/background.ts
export default defineBackground(() => {
  browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (message.type === 'COPY_TO_CLIPBOARD') {
      copyToClipboard(message.text).then(sendResponse)
      return true
    }
  })
})

async function copyToClipboard(text: string) {
  await setupOffscreenDocument()
  await browser.runtime.sendMessage({
    type: 'OFFSCREEN_COPY',
    text
  })
}

async function setupOffscreenDocument() {
  const existingContexts = await browser.runtime.getContexts({
    contextTypes: ['OFFSCREEN_DOCUMENT']
  })
  if (existingContexts.length > 0) return

  await browser.offscreen.createDocument({
    url: '/offscreen.html',
    reasons: ['CLIPBOARD'],
    justification: 'Copy text to clipboard'
  })
}
```

```html
<!-- entrypoints/offscreen/index.html -->
<!doctype html>
<html>
  <head>
    <script type="module" src="./main.ts"></script>
  </head>
</html>
```

```typescript
// entrypoints/offscreen/main.ts
browser.runtime.onMessage.addListener((message) => {
  if (message.type === 'OFFSCREEN_COPY') {
    navigator.clipboard.writeText(message.text)
  }
})
```

**When NOT to use this pattern:**
- Operations that don't require DOM APIs
- Content scripts that already have DOM access

Reference: [Chrome Offscreen Documents](https://developer.chrome.com/docs/extensions/reference/api/offscreen)
