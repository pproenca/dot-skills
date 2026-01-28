---
title: Provide Descriptive Action Tooltips
impact: CRITICAL
impactDescription: prevents user confusion and misdirected clicks
tags: comp, tooltip, action-icon, discoverability, onboarding
---

## Provide Descriptive Action Tooltips

Set a clear, action-oriented tooltip for your extension icon. The default shows only the extension name, which doesn't tell users what clicking will do.

**Incorrect (no tooltip or name-only):**

```json
{
  "name": "PageMark",
  "action": {
    "default_icon": "icon.png"
  }
}
// Tooltip shows: "PageMark"
// User thinks: "What does clicking this do?"
```

**Correct (descriptive action tooltip):**

```json
{
  "name": "PageMark",
  "action": {
    "default_icon": "icon.png",
    "default_title": "Save this page to your reading list"
  }
}
// Tooltip shows: "Save this page to your reading list"
// User knows exactly what clicking will do
```

**Dynamic tooltips for state:**

```typescript
// Update tooltip to reflect current state
async function updateTooltipState(tabId, isSaved) {
  await chrome.action.setTitle({
    tabId,
    title: isSaved
      ? 'Page saved - Click to view or remove'
      : 'Save this page to your reading list'
  })
}

// Update on tab change
chrome.tabs.onActivated.addListener(async ({ tabId }) => {
  const tab = await chrome.tabs.get(tabId)
  const isSaved = await checkIfPageSaved(tab.url)
  await updateTooltipState(tabId, isSaved)
})
```

**Tooltip best practices:**
- Start with a verb: "Save", "Block", "Translate", "Capture"
- Keep under 45 characters for full visibility
- Update dynamically to reflect current state
- Match the tooltip to what actually happens on click

Reference: [Action API](https://developer.chrome.com/docs/extensions/reference/api/action)
