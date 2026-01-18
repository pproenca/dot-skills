---
title: Prefer Programmatic Injection Over Manifest Declaration
impact: CRITICAL
impactDescription: loads scripts only when user invokes feature
tags: content, scripting, executeScript, injection, on-demand
---

## Prefer Programmatic Injection Over Manifest Declaration

Manifest-declared content scripts run on every matching page load, even if unused. Programmatic injection using `chrome.scripting.executeScript` loads scripts only when the user actually needs the feature.

**Incorrect (always loaded on every matching page):**

```json
{
  "content_scripts": [{
    "matches": ["https://*.com/*"],
    "js": ["page-analyzer.js"]
  }]
}
```

```javascript
// page-analyzer.js - 50KB of code loaded on every page
// Even if user never clicks the extension
import { analyzeDOM } from './analyzer';
import { renderOverlay } from './overlay';
// ...all this code parsed and compiled on every page visit
```

**Correct (loaded only when user clicks):**

```json
{
  "permissions": ["activeTab", "scripting"]
}
```

```javascript
// background.js
chrome.action.onClicked.addListener(async (tab) => {
  await chrome.scripting.executeScript({
    target: { tabId: tab.id },
    files: ['page-analyzer.js']
  });
});

// popup.js (or from popup button click)
document.getElementById('analyze-btn').addEventListener('click', async () => {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  await chrome.scripting.executeScript({
    target: { tabId: tab.id },
    files: ['page-analyzer.js']
  });
});
```

**Benefits of programmatic injection:**
- `activeTab` permission shows no warning (vs host permissions)
- Zero performance impact on pages where feature isn't used
- Script can be injected into any tab when needed
- Smaller initial extension footprint

**When manifest declaration IS appropriate:**
- Script must observe page from very beginning
- Script modifies page appearance immediately (CSS injection)
- Script intercepts page events before they fire

Reference: [chrome.scripting API](https://developer.chrome.com/docs/extensions/reference/api/scripting)
