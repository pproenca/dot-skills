---
title: Use Content Scripts for In-Page UI
impact: CRITICAL
impactDescription: eliminates context switching entirely
tags: comp, content-script, in-page-ui, dom-injection, user-flow
---

## Use Content Scripts for In-Page UI

Inject UI directly into web pages when users need to interact with page content. Forcing users to switch between page and popup/panel creates friction and breaks flow.

**Incorrect (context switch to popup):**

```typescript
// popup.js - User must click extension icon, breaking reading flow
document.getElementById('highlight-btn').addEventListener('click', async () => {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true })
  await chrome.tabs.sendMessage(tab.id, { action: 'highlight' })
})

// content.js
chrome.runtime.onMessage.addListener((message) => {
  if (message.action === 'highlight') {
    highlightSelectedText()
  }
})
// User: select text → click icon → click button → return to page
```

**Correct (inline UI appears at selection):**

```typescript
// content.js - Toolbar appears directly at text selection
document.addEventListener('mouseup', (event) => {
  const selection = window.getSelection()
  if (selection.toString().trim()) {
    showInlineToolbar(event.clientX, event.clientY)
  }
})

function showInlineToolbar(x, y) {
  const toolbar = document.createElement('div')
  toolbar.className = 'extension-inline-toolbar'
  toolbar.innerHTML = `
    <button data-action="highlight">Highlight</button>
    <button data-action="note">Add Note</button>
  `
  toolbar.style.cssText = `position: fixed; left: ${x}px; top: ${y}px;`
  document.body.appendChild(toolbar)
}
// User: select text → toolbar appears → click → done
```

**When NOT to use content script UI:**
- Complex multi-step workflows requiring significant screen space
- Settings or configuration interfaces
- Features unrelated to current page content

Reference: [Content Scripts](https://developer.chrome.com/docs/extensions/develop/concepts/content-scripts)
