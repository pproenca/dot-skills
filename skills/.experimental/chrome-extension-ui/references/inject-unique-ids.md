---
title: Use Unique IDs to Prevent Conflicts
impact: MEDIUM-HIGH
impactDescription: prevents ID collision with page elements
tags: inject, unique-id, namespace, collision, content-script
---

## Use Unique IDs to Prevent Conflicts

Prefix all injected element IDs with a unique namespace. Generic IDs like "container" or "modal" will conflict with page elements.

**Incorrect (generic IDs collide with page):**

```typescript
// content.js - Common names cause conflicts
const container = document.createElement('div')
container.id = 'container'

const modal = document.createElement('div')
modal.id = 'modal'

const btn = document.createElement('button')
btn.id = 'save-btn'

// Later...
document.getElementById('container')
// Returns page's #container, not yours!
```

**Correct (namespaced IDs prevent collisions):**

```typescript
// content.js - Unique prefix for all elements
const EXTENSION_PREFIX = 'my-extension-12345'

function createId(name) {
  return `${EXTENSION_PREFIX}-${name}`
}

const container = document.createElement('div')
container.id = createId('container') // 'my-extension-12345-container'

const modal = document.createElement('div')
modal.id = createId('modal') // 'my-extension-12345-modal'

const btn = document.createElement('button')
btn.id = createId('save-btn') // 'my-extension-12345-save-btn'

// Safe lookups
function getElement(name) {
  return document.getElementById(createId(name))
}

getElement('container') // Always returns your element
```

**Using data attributes instead of IDs:**

```typescript
// content.js - Data attributes for element references
const EXTENSION_ATTR = 'data-my-extension'

function createElement(type, name) {
  const element = document.createElement(type)
  element.setAttribute(EXTENSION_ATTR, name)
  return element
}

function getElement(name) {
  return document.querySelector(`[${EXTENSION_ATTR}="${name}"]`)
}

// Usage
const toolbar = createElement('div', 'toolbar')
const saveBtn = createElement('button', 'save-btn')

// Later
getElement('toolbar') // Always finds your toolbar
getElement('save-btn') // Always finds your button
```

**Class name namespacing:**

```typescript
// content.js - Namespaced classes for styling
const CSS_PREFIX = 'ext-myapp'

const toolbar = document.createElement('div')
toolbar.className = `${CSS_PREFIX}-toolbar ${CSS_PREFIX}-visible`

// In CSS
.ext-myapp-toolbar { /* Won't conflict with .toolbar on page */ }
.ext-myapp-visible { /* Won't conflict with .visible on page */ }
```

Reference: [Content Scripts Isolated World](https://developer.chrome.com/docs/extensions/develop/concepts/content-scripts#isolated_world)
