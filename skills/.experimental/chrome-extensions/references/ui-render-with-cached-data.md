---
title: Render Popup UI with Cached Data First
impact: MEDIUM
impactDescription: eliminates loading spinners, instant perceived load
tags: ui, popup, cache, rendering, perceived-performance
---

## Render Popup UI with Cached Data First

Users expect popups to open instantly. Waiting for fresh data before rendering causes perceived lag. Render immediately with cached data, then update when fresh data arrives.

**Incorrect (blocks render until data loads):**

```javascript
// popup.js - User sees blank popup while loading
async function init() {
  document.getElementById('app').innerHTML = '<div class="spinner">Loading...</div>';

  // User waits 500ms-2s for this
  const response = await fetch('https://api.example.com/status');
  const data = await response.json();

  renderUI(data);
}
```

**Correct (instant render, async refresh):**

```javascript
// popup.js - Instant render with cached data
async function init() {
  // 1. Render immediately with cached data
  const { cachedStatus } = await chrome.storage.local.get('cachedStatus');
  renderUI(cachedStatus ?? getDefaultStatus());

  // 2. Fetch fresh data in background
  refreshData();
}

async function refreshData() {
  try {
    const response = await fetch('https://api.example.com/status');
    const freshData = await response.json();

    // 3. Update UI and cache
    renderUI(freshData);
    await chrome.storage.local.set({ cachedStatus: freshData });
  } catch (error) {
    // Cached data already shown, just log error
    console.warn('Refresh failed:', error);
  }
}

function getDefaultStatus() {
  return { status: 'unknown', lastUpdated: null };
}

function renderUI(data) {
  document.getElementById('app').innerHTML = `
    <div class="status ${data.status}">
      <span class="indicator"></span>
      <span>Status: ${data.status}</span>
    </div>
    ${data.lastUpdated ? `<small>Updated: ${new Date(data.lastUpdated).toLocaleString()}</small>` : ''}
  `;
}
```

**Stale-while-revalidate pattern:**

```javascript
// popup.js - Show cache age indicator
function renderUI(data, isStale = false) {
  document.getElementById('app').innerHTML = `
    <div class="content ${isStale ? 'stale' : 'fresh'}">
      ${isStale ? '<span class="updating">Updating...</span>' : ''}
      <!-- rest of UI -->
    </div>
  `;
}
```

Reference: [Stale-While-Revalidate](https://web.dev/stale-while-revalidate/)
