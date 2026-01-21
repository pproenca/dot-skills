---
title: Return true from Message Listeners for Async Responses
impact: CRITICAL
impactDescription: prevents undefined responses and message channel closure
tags: sw, messaging, async, sendResponse, service-worker
---

## Return true from Message Listeners for Async Responses

When using `sendResponse` asynchronously in a message listener, you must `return true` to keep the message channel open. Otherwise, the channel closes immediately and the sender receives `undefined`.

**Incorrect (channel closes before async response):**

```javascript
// background.js
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'fetch-user') {
    // Channel closes immediately, sendResponse does nothing
    fetch('https://api.example.com/user')
      .then(res => res.json())
      .then(user => sendResponse({ user }));  // Never received
  }
});

// content.js
const response = await chrome.runtime.sendMessage({ type: 'fetch-user' });
console.log(response);  // undefined
```

**Correct (channel kept open for async response):**

```javascript
// background.js
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'fetch-user') {
    fetch('https://api.example.com/user')
      .then(res => res.json())
      .then(user => sendResponse({ user }))
      .catch(err => sendResponse({ error: err.message }));
    return true;  // Keeps channel open until sendResponse is called
  }
});

// content.js
const response = await chrome.runtime.sendMessage({ type: 'fetch-user' });
console.log(response);  // { user: { ... } }
```

**Alternative (async/await pattern):**

```javascript
// background.js
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'fetch-user') {
    handleFetchUser().then(sendResponse);
    return true;
  }
});

async function handleFetchUser() {
  try {
    const res = await fetch('https://api.example.com/user');
    return { user: await res.json() };
  } catch (err) {
    return { error: err.message };
  }
}
```

Reference: [Message Passing](https://developer.chrome.com/docs/extensions/develop/concepts/messaging)
