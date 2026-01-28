---
title: Keep Badge Text Under 4 Characters
impact: LOW-MEDIUM
impactDescription: ensures text is fully visible on toolbar
tags: brand, badge, text, toolbar, constraints
---

## Keep Badge Text Under 4 Characters

Limit badge text to 4 characters maximum. Longer text gets clipped and becomes unreadable in the small badge space.

**Incorrect (badge text too long):**

```typescript
// background.js - Text gets clipped
chrome.action.setBadgeText({ text: 'UPDATED' })  // Shows: "UPDA"
chrome.action.setBadgeText({ text: '12345' })    // Shows: "1234"
chrome.action.setBadgeText({ text: 'NEW!' })     // Shows: "NEW!" but cramped
```

**Correct (concise badge text):**

```typescript
// background.js - Text fits badge
chrome.action.setBadgeText({ text: '3' })    // Single digit count
chrome.action.setBadgeText({ text: '99+' })  // Capped count
chrome.action.setBadgeText({ text: 'ON' })   // Status indicator
chrome.action.setBadgeText({ text: '!' })    // Alert symbol
chrome.action.setBadgeText({ text: '✓' })    // Success indicator
```

**Badge text patterns:**

```typescript
// background.js - Smart badge text formatting
function formatBadgeCount(count) {
  if (count === 0) return ''
  if (count < 100) return String(count)
  if (count < 1000) return '99+'
  if (count < 10000) return `${Math.floor(count / 1000)}k`
  return '9k+'
}

async function updateBadge(itemCount) {
  await chrome.action.setBadgeText({ text: formatBadgeCount(itemCount) })
}

// Usage
updateBadge(5)      // "5"
updateBadge(42)     // "42"
updateBadge(150)    // "99+"
updateBadge(2500)   // "2k"
updateBadge(15000)  // "9k+"
```

**Status badges using symbols:**

```typescript
// background.js - Symbol-based status badges
const STATUS_BADGES = {
  syncing: '↻',
  success: '✓',
  error: '!',
  paused: '⏸',
  active: '●',
  new: 'N'
}

async function setStatusBadge(status) {
  const text = STATUS_BADGES[status] || ''
  const colors = {
    syncing: '#17a2b8',
    success: '#28a745',
    error: '#dc3545',
    paused: '#6c757d',
    active: '#28a745',
    new: '#007bff'
  }

  await chrome.action.setBadgeText({ text })
  await chrome.action.setBadgeBackgroundColor({ color: colors[status] || '#666' })
}
```

**Badge visibility rules:**
- Empty string (`''`) hides the badge completely
- Single character is most readable
- 2-3 characters work well
- 4 characters maximum before clipping
- Avoid lowercase letters (harder to read at small size)

Reference: [Action API Badge](https://developer.chrome.com/docs/extensions/reference/api/action#badge)
