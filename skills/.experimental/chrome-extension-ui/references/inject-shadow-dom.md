---
title: Use Shadow DOM for Style Isolation
impact: MEDIUM-HIGH
impactDescription: prevents 100% of CSS conflicts with host pages
tags: inject, shadow-dom, isolation, css, content-script
---

## Use Shadow DOM for Style Isolation

Wrap injected UI in Shadow DOM to prevent style leakage. Without isolation, your styles affect the page and page styles break your UI.

**Incorrect (styles leak in both directions):**

```typescript
// content.js - Styles conflict with page
function injectToolbar() {
  const toolbar = document.createElement('div')
  toolbar.className = 'extension-toolbar'
  toolbar.innerHTML = `
    <button class="btn">Save</button>
    <button class="btn">Share</button>
  `
  document.body.appendChild(toolbar)
}

// styles.css injected via manifest
.extension-toolbar {
  position: fixed;
  top: 10px;
  right: 10px;
}

.btn {
  padding: 8px 16px;
  background: blue;
}
// Problem: Page's .btn styles override yours
// Problem: Your styles might affect page's .btn elements
```

**Correct (Shadow DOM isolates styles):**

```typescript
// content.js - Complete style isolation
function injectToolbar() {
  const host = document.createElement('div')
  host.id = 'my-extension-root'

  const shadow = host.attachShadow({ mode: 'closed' })

  shadow.innerHTML = `
    <style>
      .toolbar {
        position: fixed;
        top: 10px;
        right: 10px;
        z-index: 2147483647;
        font-family: -apple-system, BlinkMacSystemFont, sans-serif;
        font-size: 14px;
      }

      .btn {
        padding: 8px 16px;
        background: #4A90D9;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
      }

      .btn:hover {
        background: #357ABD;
      }
    </style>

    <div class="toolbar">
      <button class="btn">Save</button>
      <button class="btn">Share</button>
    </div>
  `

  document.body.appendChild(host)
}
// Page styles cannot affect .btn
// Extension styles cannot leak to page
```

**Loading external stylesheets in Shadow DOM:**

```typescript
// content.js - Use CSS file instead of inline styles
function injectToolbar() {
  const host = document.createElement('div')
  const shadow = host.attachShadow({ mode: 'closed' })

  // Load CSS from extension
  const styleLink = document.createElement('link')
  styleLink.rel = 'stylesheet'
  styleLink.href = chrome.runtime.getURL('toolbar.css')

  const toolbar = document.createElement('div')
  toolbar.className = 'toolbar'
  toolbar.innerHTML = `
    <button class="btn">Save</button>
    <button class="btn">Share</button>
  `

  shadow.appendChild(styleLink)
  shadow.appendChild(toolbar)
  document.body.appendChild(host)
}
```

Reference: [Shadow DOM](https://developer.mozilla.org/en-US/docs/Web/Web_Components/Using_shadow_DOM)
