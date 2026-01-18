---
title: Handle Extension Context Invalidated Errors
impact: LOW-MEDIUM
impactDescription: prevents errors after extension update or reload
tags: api, context, invalidated, error-handling, updates
---

## Handle Extension Context Invalidated Errors

When an extension is updated or reloaded, existing content scripts become orphaned. Their `chrome.*` API calls will throw "Extension context invalidated" errors. Handle this gracefully.

**Incorrect (crashes on extension update):**

```javascript
// content.js - Errors after extension update
setInterval(async () => {
  // Throws error if extension was updated
  const { settings } = await chrome.storage.local.get('settings');
  applySettings(settings);
}, 5000);

document.addEventListener('click', async (event) => {
  // Throws error if extension was reloaded
  await chrome.runtime.sendMessage({ type: 'click', target: event.target.id });
});
```

**Correct (graceful degradation):**

```javascript
// content.js - Handle context invalidation
function isExtensionContextValid() {
  try {
    // Quick check if extension context is still valid
    return !!chrome.runtime?.id;
  } catch {
    return false;
  }
}

async function safeStorageGet(keys) {
  if (!isExtensionContextValid()) {
    console.warn('Extension context invalidated');
    cleanup();
    return null;
  }

  try {
    return await chrome.storage.local.get(keys);
  } catch (error) {
    if (error.message?.includes('Extension context invalidated')) {
      cleanup();
      return null;
    }
    throw error;
  }
}

async function safeSendMessage(message) {
  if (!isExtensionContextValid()) {
    return null;
  }

  try {
    return await chrome.runtime.sendMessage(message);
  } catch (error) {
    if (error.message?.includes('Extension context invalidated')) {
      cleanup();
      return null;
    }
    throw error;
  }
}

function cleanup() {
  // Clear intervals, remove listeners, hide UI elements
  clearAllIntervals();
  removeInjectedElements();
  console.log('Content script cleaned up after context invalidation');
}
```

**Detect extension reload:**

```javascript
// content.js - Listen for disconnect
const port = chrome.runtime.connect({ name: 'heartbeat' });

port.onDisconnect.addListener(() => {
  if (chrome.runtime.lastError) {
    // Extension was reloaded or disabled
    cleanup();
  }
});
```

Reference: [Content Script Lifecycle](https://developer.chrome.com/docs/extensions/develop/concepts/content-scripts)
