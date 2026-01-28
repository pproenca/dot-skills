---
title: Use Badge for At-a-Glance Status
impact: MEDIUM
impactDescription: communicates state without opening extension
tags: feedback, badge, status, icon, notification
---

## Use Badge for At-a-Glance Status

Use the action badge to show important status without requiring users to open the extension. Keep badge text short (4 characters max visible).

**Incorrect (no badge feedback):**

```typescript
// background.js - User must open extension to see status
chrome.runtime.onMessage.addListener((message) => {
  if (message.type === 'NEW_ITEMS') {
    // Status only visible inside popup
    chrome.storage.local.set({ unreadCount: message.count })
  }
})
// User has no idea there are new items without opening extension
```

**Correct (badge shows status at a glance):**

```typescript
// background.js - Badge communicates status
async function updateBadge() {
  const { unreadCount } = await chrome.storage.local.get('unreadCount')

  if (unreadCount > 0) {
    // Show count (max 4 chars visible)
    const text = unreadCount > 99 ? '99+' : String(unreadCount)
    await chrome.action.setBadgeText({ text })
    await chrome.action.setBadgeBackgroundColor({ color: '#dc3545' })
  } else {
    await chrome.action.setBadgeText({ text: '' })
  }
}

// Update badge when data changes
chrome.storage.onChanged.addListener((changes) => {
  if (changes.unreadCount) {
    updateBadge()
  }
})
```

**Status-based badge colors:**

```typescript
// background.js - Color-coded status badges
async function setStatusBadge(status) {
  const statusConfig = {
    success: { text: '✓', color: '#28a745' },
    warning: { text: '!', color: '#ffc107' },
    error: { text: '✗', color: '#dc3545' },
    syncing: { text: '↻', color: '#17a2b8' },
    paused: { text: '⏸', color: '#6c757d' },
    active: { text: 'ON', color: '#28a745' },
    inactive: { text: 'OFF', color: '#6c757d' }
  }

  const config = statusConfig[status] || { text: '', color: '#666' }

  await chrome.action.setBadgeText({ text: config.text })
  await chrome.action.setBadgeBackgroundColor({ color: config.color })
}

// Usage examples
setStatusBadge('active')   // Green "ON" badge
setStatusBadge('error')    // Red "✗" badge
setStatusBadge('syncing')  // Blue "↻" badge
```

**Tab-specific badges:**

```typescript
// background.js - Different badge per tab
async function updateBadgeForTab(tabId, count) {
  const text = count > 0 ? String(count) : ''

  await chrome.action.setBadgeText({ tabId, text })
  await chrome.action.setBadgeBackgroundColor({
    tabId,
    color: count > 0 ? '#4A90D9' : '#666'
  })
}

// Each tab shows its own count
chrome.tabs.onActivated.addListener(async ({ tabId }) => {
  const tabData = await getDataForTab(tabId)
  updateBadgeForTab(tabId, tabData.itemCount)
})
```

**Badge best practices:**
- Use sparingly—constant badges lose meaning
- Clear badge after user acknowledges (opens popup)
- Use color meaningfully (red = attention needed)

Reference: [Action API Badge](https://developer.chrome.com/docs/extensions/reference/api/action#badge)
