---
title: Choose Side Panel for Persistent Tasks
impact: CRITICAL
impactDescription: 5-10× longer engagement sessions
tags: comp, side-panel, popup, ui-surface, persistent-ui
---

## Choose Side Panel for Persistent Tasks

Use a side panel instead of a popup when users need to reference extension content while browsing. Popups close automatically when users click outside, forcing repeated re-opening for ongoing tasks.

**Incorrect (popup closes on every page interaction):**

```typescript
// manifest.json
{
  "action": {
    "default_popup": "popup.html"
  }
}

// popup.html - User loses context when clicking the page
<div class="note-taking-app">
  <textarea id="notes">User's research notes...</textarea>
  <button id="save">Save</button>
</div>
// User clicks page to copy text → popup closes → notes hidden
```

**Correct (side panel persists alongside browsing):**

```typescript
// manifest.json
{
  "side_panel": {
    "default_path": "sidepanel.html"
  },
  "permissions": ["sidePanel"]
}

// sidepanel.html - Remains visible while user browses
<div class="note-taking-app">
  <textarea id="notes">User's research notes...</textarea>
  <button id="save">Save</button>
</div>
// User clicks page to copy text → panel stays open → uninterrupted workflow
```

**When to use popup instead:**
- Quick, one-shot actions (toggle setting, copy to clipboard)
- Actions completed in under 5 seconds
- No need to reference content while on the page

Reference: [Side Panel API](https://developer.chrome.com/docs/extensions/reference/api/sidePanel)
