---
title: Clean Up UI on Unmount
impact: MEDIUM
impactDescription: prevents memory leaks and orphaned event listeners
tags: ui, cleanup, unmount, memory-leak, lifecycle
---

## Clean Up UI on Unmount

Content script UIs must clean up event listeners, observers, and timers when removed. WXT's UI helpers provide cleanup hooks that must be used.

**Incorrect (no cleanup):**

```typescript
export default defineContentScript({
  matches: ['*://*/*'],
  main(ctx) {
    const ui = createShadowRootUi(ctx, {
      name: 'my-panel',
      onMount: (container) => {
        // Event listener never removed
        window.addEventListener('resize', handleResize)

        // Interval never cleared
        setInterval(updateTime, 1000)

        // MutationObserver never disconnected
        const observer = new MutationObserver(handleMutation)
        observer.observe(document.body, { childList: true })
      }
    })
    ui.mount()
  }
})
```

**Correct (proper cleanup):**

```typescript
export default defineContentScript({
  matches: ['*://*/*'],
  main(ctx) {
    const ui = createShadowRootUi(ctx, {
      name: 'my-panel',
      onMount: (container) => {
        window.addEventListener('resize', handleResize)

        const intervalId = setInterval(updateTime, 1000)

        const observer = new MutationObserver(handleMutation)
        observer.observe(document.body, { childList: true })

        // Return cleanup function
        return () => {
          window.removeEventListener('resize', handleResize)
          clearInterval(intervalId)
          observer.disconnect()
        }
      },
      onRemove: () => {
        // Additional cleanup after unmount
        console.log('UI removed')
      }
    })

    ui.mount()

    // Also clean up when extension context invalidated
    ctx.onInvalidated(() => {
      ui.remove()
    })
  }
})
```

**With React (useEffect cleanup):**

```typescript
function Panel() {
  useEffect(() => {
    const handleResize = () => updateLayout()
    window.addEventListener('resize', handleResize)

    const observer = new MutationObserver(handleMutation)
    observer.observe(document.body, { childList: true })

    // Cleanup when component unmounts
    return () => {
      window.removeEventListener('resize', handleResize)
      observer.disconnect()
    }
  }, [])

  return <div>Panel content</div>
}
```

Reference: [WXT Content Script UI Lifecycle](https://wxt.dev/guide/essentials/content-script-ui)
