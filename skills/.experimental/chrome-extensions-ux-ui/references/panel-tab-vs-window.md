---
title: Choose Tab-Specific vs Window-Wide Panels
impact: HIGH
impactDescription: determines context relevance and user expectations
tags: panel, tab-specific, window-wide, context, side-panel-api
---

## Choose Tab-Specific vs Window-Wide Panels

Decide whether your side panel should be tab-specific (different content per tab) or window-wide (same content across all tabs). The wrong choice confuses users.

**Incorrect (window-wide panel for tab-specific content):**

```typescript
// background.js - Panel shows same content regardless of tab
chrome.sidePanel.setOptions({
  enabled: true,
  path: 'sidepanel.html'
})

// sidepanel.js - Tries to show "current page" info
// But doesn't update when user switches tabs
async function loadCurrentPage() {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true })
  document.getElementById('page-title').textContent = tab.title
}

document.addEventListener('DOMContentLoaded', loadCurrentPage)
// User switches tabs → panel still shows old tab's info
```

**Correct (tab-specific panel for page-related content):**

```typescript
// background.js - Enable per-tab panel behavior
chrome.sidePanel.setPanelBehavior({ openPanelOnActionClick: true })

// Set panel per tab for page-specific features
chrome.tabs.onActivated.addListener(async ({ tabId }) => {
  await chrome.sidePanel.setOptions({
    tabId,
    path: 'sidepanel.html',
    enabled: true
  })
})

// sidepanel.js - Update when tab changes
chrome.tabs.onActivated.addListener(async ({ tabId }) => {
  const tab = await chrome.tabs.get(tabId)
  updatePanelForPage(tab)
})

async function updatePanelForPage(tab) {
  document.getElementById('page-title').textContent = tab.title
  const highlights = await getHighlightsForUrl(tab.url)
  renderHighlights(highlights)
}
```

**When to use each mode:**

| Use Tab-Specific When | Use Window-Wide When |
|----------------------|---------------------|
| Content relates to current page | Content is independent of page |
| Notes, highlights, page analysis | Task lists, timers, music players |
| Translation, reading tools | Global settings, dashboards |
| Page-specific data extraction | Cross-tab workflows |

**Window-wide panel example:**

```typescript
// background.js - Global panel for task management
chrome.sidePanel.setOptions({
  enabled: true,
  path: 'sidepanel.html'
})

// sidepanel.js - Content doesn't depend on current tab
async function loadTasks() {
  const { tasks } = await chrome.storage.sync.get('tasks')
  renderTasks(tasks)
}
// Same task list regardless of which tab is active
```

Reference: [Side Panel API](https://developer.chrome.com/docs/extensions/reference/api/sidePanel)
