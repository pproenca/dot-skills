---
title: Minimize Popup Bundle Size for Fast Startup
impact: MEDIUM
impactDescription: reduces popup open time by 100-500ms
tags: ui, popup, bundle, startup, performance
---

## Minimize Popup Bundle Size for Fast Startup

Popup HTML, CSS, and JavaScript are loaded fresh each time the popup opens. Large bundles cause noticeable delays. Keep popup bundles minimal and defer heavy operations.

**Incorrect (heavy popup with framework):**

```html
<!-- popup.html - Heavy initial load -->
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="popup.css">
</head>
<body>
  <div id="root"></div>
  <script src="popup.js"></script> <!-- 500KB React bundle -->
</body>
</html>
```

```javascript
// popup.js - Everything loaded upfront
import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'redux';
import App from './App';
import store from './store';

ReactDOM.render(
  <Provider store={store}><App /></Provider>,
  document.getElementById('root')
);
```

**Correct (minimal popup, lazy loading):**

```html
<!-- popup.html - Minimal markup -->
<!DOCTYPE html>
<html>
<head>
  <style>
    body { width: 300px; font-family: system-ui; }
    .loading { text-align: center; padding: 20px; }
  </style>
</head>
<body>
  <div id="app" class="loading">Loading...</div>
  <script src="popup.js"></script> <!-- 5KB vanilla JS -->
</body>
</html>
```

```javascript
// popup.js - Fast initial render, lazy load features
document.addEventListener('DOMContentLoaded', async () => {
  // Show UI immediately with cached data
  const { settings } = await chrome.storage.local.get('settings');
  renderQuickUI(settings);

  // Lazy load heavy features
  if (settings?.advancedMode) {
    const { initAdvanced } = await import('./advanced.js');
    initAdvanced();
  }
});

function renderQuickUI(settings) {
  document.getElementById('app').innerHTML = `
    <div class="settings-panel">
      <label>
        <input type="checkbox" id="enabled" ${settings?.enabled ? 'checked' : ''}>
        Enabled
      </label>
      <button id="options">More Options</button>
    </div>
  `;
}
```

**Target bundle sizes:**
- Popup JS: < 20KB
- Popup CSS: < 5KB
- Consider vanilla JS over frameworks for simple UIs

Reference: [Chrome Extension Documentation](https://developer.chrome.com/docs/extensions/)
