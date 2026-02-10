---
title: Clean Up UI on Unmount
impact: MEDIUM
impactDescription: prevents memory leaks and orphaned event listeners
tags: ui, cleanup, unmount, memory-leak, lifecycle
---

## Clean Up UI on Unmount

Content script UIs must clean up event listeners, observers, and timers when removed. Use `onRemove` for cleanup and `ctx` helpers for auto-cleanup.

**Incorrect (no cleanup):**

```typescript
export default defineContentScript({
  matches: ['*://*/*'],
  main(ctx) {
    const ui = createShadowRootUi(ctx, {
      name: 'my-panel',
      position: 'inline',
      anchor: 'body',
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

**Correct (cleanup via onRemove and ctx helpers):**

```typescript
export default defineContentScript({
  matches: ['*://*/*'],
  main(ctx) {
    const ui = createShadowRootUi(ctx, {
      name: 'my-panel',
      position: 'inline',
      anchor: 'body',
      onMount: (container) => {
        // ctx.addEventListener auto-removes on context invalidation
        ctx.addEventListener(window, 'resize', handleResize)

        const intervalId = ctx.setInterval(updateTime, 1000)

        const observer = new MutationObserver(handleMutation)
        observer.observe(document.body, { childList: true })

        // Return resources that onRemove needs to clean up
        return { observer }
      },
      onRemove: (mounted) => {
        // mounted is the return value from onMount
        mounted?.observer.disconnect()
      }
    })

    ui.mount()

    // Clean up UI when extension context invalidated (e.g., on update)
    ctx.onInvalidated(() => {
      ui.remove()
    })
  }
})
```

**With React (framework handles component cleanup):**

```typescript
export default defineContentScript({
  matches: ['*://*/*'],
  cssInjectionMode: 'ui',
  async main(ctx) {
    const ui = await createShadowRootUi(ctx, {
      name: 'my-panel',
      position: 'inline',
      anchor: 'body',
      onMount: (container) => {
        const root = createRoot(container)
        root.render(<Panel />)
        return root
      },
      onRemove: (root) => {
        root?.unmount()
      }
    })
    ui.mount()
  }
})
```

**Key pattern:** `onMount` returns a value (app instance, resources object), `onRemove` receives that value for cleanup. Use `ctx.addEventListener` and `ctx.setInterval` for auto-cleanup on context invalidation.

Reference: [WXT Content Script UI Lifecycle](https://wxt.dev/guide/essentials/content-script-ui)
