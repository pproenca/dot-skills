---
title: Clean Up Injected Elements on Removal
impact: MEDIUM-HIGH
impactDescription: prevents memory leaks and DOM pollution
tags: inject, cleanup, memory, lifecycle, content-script
---

## Clean Up Injected Elements on Removal

Remove all injected elements and event listeners when the extension is disabled or the UI is dismissed. Orphaned elements cause memory leaks and interfere with pages.

**Incorrect (elements remain after dismissal):**

```typescript
// content.js - No cleanup mechanism
function showTooltip(target) {
  const tooltip = document.createElement('div')
  tooltip.className = 'ext-tooltip'
  tooltip.textContent = 'Helpful information'
  document.body.appendChild(tooltip)

  // Tooltip never removed
  // Event listeners never cleaned up
  // Memory accumulates with each show
}

document.addEventListener('mouseover', handleHover)
// Listener remains even if extension disabled
```

**Correct (proper cleanup on removal):**

```typescript
// content.js - Complete lifecycle management
class ExtensionUI {
  constructor() {
    this.elements = new Set()
    this.listeners = []
    this.root = null
  }

  init() {
    this.root = document.createElement('div')
    this.root.id = 'my-extension-root'
    document.body.appendChild(this.root)
    this.elements.add(this.root)

    this.addListener(document, 'mouseover', this.handleHover.bind(this))
  }

  createElement(tag, parent = this.root) {
    const element = document.createElement(tag)
    parent.appendChild(element)
    this.elements.add(element)
    return element
  }

  addListener(target, event, handler) {
    target.addEventListener(event, handler)
    this.listeners.push({ target, event, handler })
  }

  showTooltip(content, position) {
    this.hideTooltip() // Remove existing tooltip first

    const tooltip = this.createElement('div')
    tooltip.className = 'ext-tooltip'
    tooltip.textContent = content
    tooltip.style.cssText = `
      position: fixed;
      left: ${position.x}px;
      top: ${position.y}px;
    `
  }

  hideTooltip() {
    const existing = this.root?.querySelector('.ext-tooltip')
    if (existing) {
      existing.remove()
      this.elements.delete(existing)
    }
  }

  destroy() {
    // Remove all event listeners
    this.listeners.forEach(({ target, event, handler }) => {
      target.removeEventListener(event, handler)
    })
    this.listeners = []

    // Remove all DOM elements
    this.elements.forEach(element => {
      element.remove()
    })
    this.elements.clear()

    this.root = null
  }
}

// Initialize
const extensionUI = new ExtensionUI()
extensionUI.init()

// Listen for extension disable/reload
chrome.runtime.onSuspend?.addListener(() => {
  extensionUI.destroy()
})
```

**AbortController for cleaner listener cleanup:**

```typescript
// content.js - Modern cleanup with AbortController
const controller = new AbortController()

document.addEventListener('click', handleClick, { signal: controller.signal })
document.addEventListener('mouseover', handleHover, { signal: controller.signal })
window.addEventListener('scroll', handleScroll, { signal: controller.signal })

// Single call removes all listeners
function cleanup() {
  controller.abort()
  document.getElementById('my-extension-root')?.remove()
}
```

Reference: [AbortController](https://developer.mozilla.org/en-US/docs/Web/API/AbortController)
