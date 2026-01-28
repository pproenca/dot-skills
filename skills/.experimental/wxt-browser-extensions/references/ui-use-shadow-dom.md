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
import { createShadowRootUi } from 'wxt/client'

export default defineContentScript({
  matches: ['*://*/*'],
  main(ctx) {
    const ui = createShadowRootUi(ctx, {
      name: 'my-extension-panel',
      position: 'inline',
      anchor: 'body',
      onMount: (container, shadow) => {
        // Styles scoped to shadow root
        const style = document.createElement('style')
        style.textContent = `
          .button { background: blue; padding: 8px 16px; }
        `
        shadow.appendChild(style)

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

**With CSS file (recommended):**

```typescript
import { createShadowRootUi } from 'wxt/client'
import styles from './panel.css?inline'

export default defineContentScript({
  matches: ['*://*/*'],
  main(ctx) {
    const ui = createShadowRootUi(ctx, {
      name: 'my-extension-panel',
      position: 'inline',
      onMount: (container, shadow) => {
        const styleEl = document.createElement('style')
        styleEl.textContent = styles
        shadow.appendChild(styleEl)
        // Build UI
      }
    })
    ui.mount()
  }
})
```

Reference: [WXT Content Script UI](https://wxt.dev/guide/essentials/content-script-ui)
