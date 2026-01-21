---
title: Minimize Message Payload Size
impact: HIGH
impactDescription: reduces serialization overhead by 2-10×
tags: msg, payload, serialization, messaging, performance
---

## Minimize Message Payload Size

Messages between extension contexts are JSON-serialized. Large payloads increase serialization time and memory usage. Send only the data needed, not entire objects or DOM snapshots.

**Incorrect (sending entire objects with unused data):**

```javascript
// content.js - Sends much more than needed
const pageData = {
  url: location.href,
  title: document.title,
  html: document.documentElement.outerHTML,  // 500KB+
  cookies: document.cookie,
  allLinks: Array.from(document.querySelectorAll('a')).map(a => ({
    href: a.href,
    text: a.textContent,
    classList: Array.from(a.classList),
    dataset: { ...a.dataset },
    rect: a.getBoundingClientRect()  // Non-serializable triggers error
  }))
};

chrome.runtime.sendMessage({ type: 'page-data', data: pageData });
```

**Correct (send only required fields):**

```javascript
// content.js - Minimal payload for the use case
const relevantLinks = Array.from(document.querySelectorAll('a.product-link'))
  .slice(0, 50)  // Limit quantity
  .map(a => ({
    href: a.href,
    price: a.dataset.price
  }));

chrome.runtime.sendMessage({
  type: 'page-data',
  url: location.href,
  links: relevantLinks
});
```

**For large data transfers:**

```javascript
// content.js - Use storage for large payloads
async function sendLargeData(data) {
  const key = `temp-${Date.now()}`;
  await chrome.storage.local.set({ [key]: data });
  await chrome.runtime.sendMessage({ type: 'data-ready', key });
}

// background.js
chrome.runtime.onMessage.addListener(async (message) => {
  if (message.type === 'data-ready') {
    const { [message.key]: data } = await chrome.storage.local.get(message.key);
    await processData(data);
    await chrome.storage.local.remove(message.key);  // Clean up
  }
});
```

**Non-serializable types to avoid:**
Functions, DOM elements, `Map`/`Set` (use arrays), circular references

Reference: [Message Passing](https://developer.chrome.com/docs/extensions/develop/concepts/messaging)
