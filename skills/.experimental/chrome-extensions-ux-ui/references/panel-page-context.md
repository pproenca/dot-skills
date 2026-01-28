---
title: Sync Panel Content with Page Context
impact: HIGH
impactDescription: makes panel feel integrated rather than disconnected
tags: panel, context, sync, page-awareness, relevance
---

## Sync Panel Content with Page Context

Update side panel content to reflect the current page when relevant. A panel showing stale or unrelated content feels disconnected and useless.

**Incorrect (panel ignores page context):**

```typescript
// sidepanel.js - Loads once, never updates
document.addEventListener('DOMContentLoaded', async () => {
  const data = await loadGenericData()
  renderPanel(data)
})
// User navigates to different pages → panel shows same content
// Panel feels disconnected from browsing
```

**Correct (panel responds to page changes):**

```typescript
// sidepanel.js - Updates with page context
async function initPanel() {
  // Initial load
  await updateForCurrentTab()

  // Listen for tab changes
  chrome.tabs.onActivated.addListener(async ({ tabId }) => {
    await updateForCurrentTab()
  })

  // Listen for URL changes within same tab
  chrome.tabs.onUpdated.addListener(async (tabId, changeInfo, tab) => {
    if (changeInfo.status === 'complete') {
      await updateForCurrentTab()
    }
  })
}

async function updateForCurrentTab() {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true })

  // Update page-specific section
  document.getElementById('current-url').textContent = tab.url
  document.getElementById('page-title').textContent = tab.title

  // Load related content
  const relatedNotes = await getNotesForUrl(tab.url)
  renderNotes(relatedNotes)

  // Show relevant actions based on page type
  const pageType = detectPageType(tab.url)
  updateActionsForPageType(pageType)
}

function detectPageType(url) {
  if (url.includes('github.com')) return 'github'
  if (url.includes('docs.google.com')) return 'google-docs'
  if (url.includes('youtube.com')) return 'youtube'
  return 'generic'
}

function updateActionsForPageType(pageType) {
  const actionsContainer = document.getElementById('context-actions')

  const actionsByType = {
    'github': '<button>Save Repository</button><button>View Issues</button>',
    'youtube': '<button>Save Video</button><button>Add to Playlist</button>',
    'google-docs': '<button>Export Notes</button>',
    'generic': '<button>Save Page</button>'
  }

  actionsContainer.innerHTML = actionsByType[pageType]
}

initPanel()
```

**Showing "no content for this page" gracefully:**

```typescript
async function updateForCurrentTab() {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true })
  const content = await getContentForUrl(tab.url)

  const container = document.getElementById('page-content')

  if (content && content.length > 0) {
    container.innerHTML = renderContent(content)
  } else {
    container.innerHTML = `
      <div class="empty-state">
        <p>No saved items for this page</p>
        <button id="add-first">Add your first note</button>
      </div>
    `
  }
}
```

Reference: [Tabs API](https://developer.chrome.com/docs/extensions/reference/api/tabs)
