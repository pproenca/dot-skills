---
title: Use Dynamic Popups for State-Based UI
impact: HIGH
impactDescription: reduces cognitive load by showing relevant UI
tags: popup, dynamic, state, conditional-ui, action-api
---

## Use Dynamic Popups for State-Based UI

Use `chrome.action.setPopup()` to display different popups based on application state. Show users only the UI relevant to their current context.

**Incorrect (single popup handles all states):**

```html
<!-- popup.html - Cluttered with conditional content -->
<div id="logged-out-section" style="display: none;">
  <h2>Please Sign In</h2>
  <button id="signin-btn">Sign in with Google</button>
</div>

<div id="logged-in-section" style="display: none;">
  <h2>Welcome back!</h2>
  <div id="user-content">...</div>
</div>

<div id="error-section" style="display: none;">
  <h2>Connection Error</h2>
  <button id="retry-btn">Retry</button>
</div>
```

```typescript
// popup.js - Complex state management in single popup
async function init() {
  const sections = ['logged-out', 'logged-in', 'error']
  sections.forEach(s => document.getElementById(`${s}-section`).style.display = 'none')

  try {
    const user = await checkAuth()
    if (user) {
      document.getElementById('logged-in-section').style.display = 'block'
    } else {
      document.getElementById('logged-out-section').style.display = 'block'
    }
  } catch {
    document.getElementById('error-section').style.display = 'block'
  }
}
```

**Correct (dedicated popup per state):**

```typescript
// background.js - Set appropriate popup based on state
chrome.runtime.onInstalled.addListener(updatePopupState)
chrome.storage.onChanged.addListener(updatePopupState)

async function updatePopupState() {
  const { user, hasError } = await chrome.storage.local.get(['user', 'hasError'])

  if (hasError) {
    await chrome.action.setPopup({ popup: 'popups/error.html' })
    await chrome.action.setBadgeText({ text: '!' })
    await chrome.action.setBadgeBackgroundColor({ color: '#dc3545' })
  } else if (user) {
    await chrome.action.setPopup({ popup: 'popups/main.html' })
    await chrome.action.setBadgeText({ text: '' })
  } else {
    await chrome.action.setPopup({ popup: 'popups/signin.html' })
    await chrome.action.setBadgeText({ text: '' })
  }
}
```

```text
popups/
├── signin.html   <!-- Clean sign-in form only -->
├── main.html     <!-- Full functionality for logged-in users -->
└── error.html    <!-- Error state with retry options -->
```

**Benefits of dynamic popups:**
- Each popup is simpler and focused
- Faster load times (less HTML/JS to parse)
- Easier to maintain and test
- Clearer user experience

Reference: [Action API setPopup](https://developer.chrome.com/docs/extensions/reference/api/action#method-setPopup)
