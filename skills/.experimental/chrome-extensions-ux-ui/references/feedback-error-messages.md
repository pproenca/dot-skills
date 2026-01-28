---
title: Write Actionable Error Messages
impact: MEDIUM
impactDescription: 60% faster error recovery when users know what to do
tags: feedback, errors, messages, recovery, user-guidance
---

## Write Actionable Error Messages

Provide specific, actionable error messages that tell users what happened and how to fix it. Generic errors leave users confused and helpless.

**Incorrect (vague, unhelpful errors):**

```typescript
// popup.js - Generic error messages
async function saveBookmark() {
  try {
    await chrome.bookmarks.create({ title, url })
  } catch (error) {
    showError('Error occurred')  // User: "What error? What do I do?"
  }
}

async function syncData() {
  try {
    await fetch(apiUrl)
  } catch (error) {
    showError('Something went wrong')  // User: "Great, now what?"
  }
}
```

**Correct (specific, actionable errors):**

```typescript
// popup.js - Helpful error messages
async function saveBookmark() {
  try {
    await chrome.bookmarks.create({ title, url })
  } catch (error) {
    if (error.message.includes('invalid url')) {
      showError({
        title: 'Invalid URL',
        message: 'The URL format is not valid. Check for typos.',
        action: { label: 'Edit URL', handler: focusUrlInput }
      })
    } else if (error.message.includes('quota')) {
      showError({
        title: 'Storage Full',
        message: 'You\'ve reached the bookmark limit. Delete some bookmarks to add more.',
        action: { label: 'Manage Bookmarks', handler: openBookmarkManager }
      })
    } else {
      showError({
        title: 'Could Not Save Bookmark',
        message: 'An unexpected error occurred. Try again or restart Chrome.',
        action: { label: 'Try Again', handler: () => saveBookmark() }
      })
    }
  }
}

async function syncData() {
  try {
    const response = await fetch(apiUrl)
    if (!response.ok) throw new Error(`HTTP ${response.status}`)
    return await response.json()
  } catch (error) {
    if (!navigator.onLine) {
      showError({
        title: 'No Internet Connection',
        message: 'Check your network connection and try again.',
        action: { label: 'Retry', handler: () => syncData() }
      })
    } else if (error.message.includes('401')) {
      showError({
        title: 'Session Expired',
        message: 'Please sign in again to continue.',
        action: { label: 'Sign In', handler: openSignInPage }
      })
    } else {
      showError({
        title: 'Sync Failed',
        message: 'Unable to reach our servers. Try again in a few minutes.',
        action: { label: 'Retry', handler: () => syncData() }
      })
    }
  }
}

function showError({ title, message, action }) {
  const errorEl = document.getElementById('error-container')
  errorEl.innerHTML = `
    <div class="error-banner" role="alert">
      <strong>${title}</strong>
      <p>${message}</p>
      ${action ? `<button id="error-action">${action.label}</button>` : ''}
    </div>
  `
  if (action) {
    document.getElementById('error-action').onclick = action.handler
  }
}
```

**Error message checklist:**
- What happened? (specific title)
- Why did it happen? (explanation)
- What can the user do? (actionable button)

Reference: [Error Message UX](https://www.pencilandpaper.io/articles/ux-pattern-analysis-error-feedback)
