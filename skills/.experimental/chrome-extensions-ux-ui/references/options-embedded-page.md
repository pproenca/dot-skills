---
title: Use Embedded Options for Simple Settings
impact: MEDIUM
impactDescription: keeps users in context without tab switching
tags: options, embedded, settings, options-ui, manifest
---

## Use Embedded Options for Simple Settings

Use embedded options pages for extensions with few settings. Embedded pages display inline on the extensions management page, avoiding unnecessary tab switches.

**Incorrect (full-page options for simple settings):**

```json
{
  "options_ui": {
    "page": "options.html",
    "open_in_tab": true
  }
}
```

```html
<!-- options.html - Full page for just 2 settings -->
<!DOCTYPE html>
<html>
<head>
  <title>Extension Settings</title>
  <link rel="stylesheet" href="options.css">
</head>
<body>
  <h1>Settings</h1>
  <label>
    <input type="checkbox" id="enabled">
    Enable extension
  </label>
  <label>
    <input type="checkbox" id="notifications">
    Show notifications
  </label>
  <button id="save">Save</button>
</body>
</html>
<!-- Opens new tab for 2 checkboxes - overkill -->
```

**Correct (embedded options for simple settings):**

```json
{
  "options_ui": {
    "page": "options.html",
    "open_in_tab": false
  }
}
```

```html
<!-- options.html - Designed for embedded display -->
<!DOCTYPE html>
<html>
<head>
  <style>
    body {
      min-width: 300px;
      padding: 16px;
      font-family: -apple-system, BlinkMacSystemFont, sans-serif;
    }

    .setting {
      display: flex;
      align-items: center;
      padding: 12px 0;
      border-bottom: 1px solid #e0e0e0;
    }

    .setting:last-child {
      border-bottom: none;
    }

    .setting label {
      flex: 1;
    }
  </style>
</head>
<body>
  <div class="setting">
    <label for="enabled">Enable extension</label>
    <input type="checkbox" id="enabled">
  </div>
  <div class="setting">
    <label for="notifications">Show notifications</label>
    <input type="checkbox" id="notifications">
  </div>
  <script src="options.js"></script>
</body>
</html>
<!-- Displays inline in chrome://extensions without leaving page -->
```

**When to use full-page options:**
- Many settings requiring scrolling
- Complex configuration with tabs/sections
- Settings requiring significant explanation
- Advanced features needing documentation

```json
{
  "options_ui": {
    "page": "options.html",
    "open_in_tab": true
  }
}
```

**Providing both embedded and full-page access:**

```typescript
// options.js - Link to full page from embedded view
if (window.location.protocol === 'chrome-extension:' &&
    window.parent !== window) {
  // Running embedded - show link to full page
  document.body.insertAdjacentHTML('beforeend', `
    <a href="#" id="open-full" style="display: block; margin-top: 16px; font-size: 12px;">
      Open full settings page
    </a>
  `)

  document.getElementById('open-full').onclick = (e) => {
    e.preventDefault()
    chrome.runtime.openOptionsPage()
  }
}
```

Reference: [Options Page](https://developer.chrome.com/docs/extensions/develop/ui/options-page)
