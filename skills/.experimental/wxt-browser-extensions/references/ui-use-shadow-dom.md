---
title: Use Shadow DOM for Injected UI
impact: MEDIUM
impactDescription: prevents style conflicts with host page
tags: ui, shadow-dom, isolation, css, content-script
---

## Use Shadow DOM for Injected UI

When injecting UI into web pages from content scripts, use Shadow DOM to isolate your styles from the host page. This prevents both directions of style leakage.

**Incorrect (styles leak between page and extension):**

```typescript
export default defineContentScript({
  matches: ['*://*/*'],
  main() {
    const container = document.createElement('div')
    container.innerHTML = `
      <style>
        .button { background: blue; } /* May conflict with page styles */
      </style>
      <button class="button">Click me</button>
    `
    document.body.appendChild(container)
    // Page CSS for .button overrides extension styles
  }
})
```

**Correct (Shadow DOM isolation with WXT helper):**

```typescript
import './panel.css'

export default defineContentScript({
  matches: ['*://*/*'],
  cssInjectionMode: 'ui',
  main(ctx) {
    const ui = createShadowRootUi(ctx, {
      name: 'my-extension-panel',
      position: 'inline',
      anchor: 'body',
      onMount: (container) => {
        const button = document.createElement('button')
        button.className = 'button'
        button.textContent = 'Click me'
        container.appendChild(button)
      }
    })

    ui.mount()
  }
})
```

**With framework (React example):**

```typescript
import './styles.css'

export default defineContentScript({
  matches: ['*://*/*'],
  cssInjectionMode: 'ui',
  async main(ctx) {
    const ui = await createShadowRootUi(ctx, {
      name: 'my-extension-panel',
      position: 'inline',
      anchor: 'body',
      onMount: (container) => {
        const root = createRoot(container)
        root.render(<Panel />)
        return root
      },
      onRemove: (root) => root?.unmount()
    })
    ui.mount()
  }
})
```

**WXT v0.20+ CSS reset:** Shadow roots now apply `all: initial` to reset inherited styles automatically. Use `inheritStyles: true` to preserve page style inheritance if needed (rare).

**Event isolation:** Use `isolateEvents` to prevent click/keyboard events from bubbling to the host page:

```typescript
createShadowRootUi(ctx, {
  name: 'my-panel',
  position: 'overlay',
  isolateEvents: ['click', 'keydown']
})
```

Reference: [WXT Content Script UI](https://wxt.dev/guide/essentials/content-script-ui)
