---
title: Handle Context Invalidation
impact: CRITICAL
impactDescription: prevents orphaned listeners after extension update
tags: inject, context, invalidation, cleanup, update
---

## Handle Context Invalidation

When an extension updates, existing content scripts become "orphaned" - they still run but can't communicate with the new background script. Use WXT's context to detect invalidation and clean up.

**Incorrect (no invalidation handling):**

```typescript
export default defineContentScript({
  matches: ['*://*.example.com/*'],
  main() {
    setInterval(async () => {
      // Throws error after extension update
      const response = await browser.runtime.sendMessage({ type: 'PING' })
      updateUI(response)
    }, 5000)
  }
})
```

**Correct (handle context invalidation):**

```typescript
export default defineContentScript({
  matches: ['*://*.example.com/*'],
  main(ctx) {
    const intervalId = setInterval(async () => {
      if (ctx.isInvalidated) {
        clearInterval(intervalId)
        showReloadPrompt()
        return
      }

      try {
        const response = await browser.runtime.sendMessage({ type: 'PING' })
        updateUI(response)
      } catch (error) {
        if (isExtensionContextInvalidated(error)) {
          clearInterval(intervalId)
          showReloadPrompt()
        }
      }
    }, 5000)

    // Clean up when context becomes invalid
    ctx.onInvalidated(() => {
      clearInterval(intervalId)
      showReloadPrompt()
    })
  }
})

function isExtensionContextInvalidated(error: unknown): boolean {
  return error instanceof Error &&
    error.message.includes('Extension context invalidated')
}

function showReloadPrompt() {
  const banner = document.createElement('div')
  banner.textContent = 'Extension updated. Please refresh the page.'
  document.body.prepend(banner)
}
```

Reference: [WXT Content Script Context](https://wxt.dev/guide/essentials/content-scripts)
