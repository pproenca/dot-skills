---
title: Use Offscreen Documents for DOM APIs
impact: CRITICAL
impactDescription: enables DOM manipulation without content script injection
tags: sw, offscreen, dom, service-worker, parsing
---

## Use Offscreen Documents for DOM APIs

Service workers have no DOM access. For operations requiring `DOMParser`, `canvas`, clipboard, or audio playback, create an offscreen document instead of injecting content scripts into arbitrary pages.

**Incorrect (injecting content script just for DOM parsing):**

```javascript
// background.js
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'parse-html') {
    // Injecting into current tab just to parse HTML - invasive and slow
    chrome.scripting.executeScript({
      target: { tabId: sender.tab.id },
      func: (html) => {
        const doc = new DOMParser().parseFromString(html, 'text/html');
        return doc.querySelector('title')?.textContent;
      },
      args: [message.html]
    }).then(results => sendResponse(results[0].result));
    return true;
  }
});
```

**Correct (using offscreen document):**

```javascript
// background.js
async function parseHtmlContent(html) {
  await ensureOffscreenDocument();
  return chrome.runtime.sendMessage({ type: 'parse-html', html });
}

async function ensureOffscreenDocument() {
  const existing = await chrome.offscreen.hasDocument();
  if (!existing) {
    await chrome.offscreen.createDocument({
      url: 'offscreen.html',
      reasons: ['DOM_PARSER'],
      justification: 'Parse HTML content'
    });
  }
}

// offscreen.js
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'parse-html') {
    const doc = new DOMParser().parseFromString(message.html, 'text/html');
    sendResponse(doc.querySelector('title')?.textContent);
  }
});
```

**Valid offscreen reasons:**
- `DOM_PARSER` - HTML parsing
- `CLIPBOARD` - Copy/paste operations
- `AUDIO_PLAYBACK` - Playing audio
- `BLOBS` - Creating blob URLs
- `CANVAS` - Image manipulation

**Note:** Only one offscreen document can exist at a time per extension.

Reference: [Offscreen Documents in Manifest V3](https://developer.chrome.com/blog/Offscreen-Documents-in-Manifest-v3)
