---
title: Always Check chrome.runtime.lastError in Callbacks
impact: HIGH
impactDescription: prevents silent failures and memory leaks
tags: msg, error-handling, lastError, debugging, reliability
---

## Always Check chrome.runtime.lastError in Callbacks

Chrome sets `chrome.runtime.lastError` when API calls fail (e.g., tab closed, SW not ready). Failing to check it causes silent failures and uncaught error warnings in the console.

**Incorrect (silent failures, uncaught errors):**

```javascript
// popup.js - Fails silently if tab doesn't exist
chrome.tabs.sendMessage(tabId, { type: 'get-data' }, (response) => {
  // If tab closed, response is undefined but no error handling
  displayData(response.data);  // TypeError: Cannot read 'data' of undefined
});

// background.js - Warning floods console
chrome.tabs.query({ active: true }, (tabs) => {
  chrome.tabs.sendMessage(tabs[0].id, { action: 'ping' }, (response) => {
    // "Unchecked runtime.lastError: Could not establish connection"
    console.log('Got response:', response);
  });
});
```

**Correct (proper error handling):**

```javascript
// popup.js - Check lastError before using response
chrome.tabs.sendMessage(tabId, { type: 'get-data' }, (response) => {
  if (chrome.runtime.lastError) {
    console.warn('Message failed:', chrome.runtime.lastError.message);
    showErrorState('Cannot connect to page');
    return;
  }
  displayData(response.data);
});
```

**With async/await (try-catch):**

```javascript
// popup.js - Promise-based error handling
async function sendMessageToTab(tabId, message) {
  try {
    const response = await chrome.tabs.sendMessage(tabId, message);
    return response;
  } catch (error) {
    console.warn('Message failed:', error.message);
    return null;
  }
}

const data = await sendMessageToTab(tabId, { type: 'get-data' });
if (data) {
  displayData(data);
} else {
  showErrorState('Page not available');
}
```

**Common lastError causes:**
- Tab closed or navigated away
- Content script not injected on target page
- Service worker terminated mid-operation
- Extension context invalidated

Reference: [chrome.runtime.lastError](https://developer.chrome.com/docs/extensions/reference/api/runtime#property-lastError)
