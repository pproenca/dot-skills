---
title: Use Port Connections for Frequent Message Exchange
impact: HIGH
impactDescription: reduces messaging overhead by 50-80% for repeated messages
tags: msg, ports, connect, messaging, performance
---

## Use Port Connections for Frequent Message Exchange

`sendMessage` creates overhead for each message. For frequent bidirectional communication between service worker and content scripts, use `chrome.runtime.connect` to establish a persistent port connection.

**Incorrect (new connection per message):**

```javascript
// content.js - High-frequency updates
setInterval(async () => {
  const position = getScrollPosition();
  // New message channel created each time
  await chrome.runtime.sendMessage({
    type: 'scroll-position',
    position
  });
}, 100);  // 10 messages/second, 10 connection setups/second
```

**Correct (reuse port connection):**

```javascript
// content.js - Single persistent connection
const port = chrome.runtime.connect({ name: 'scroll-tracker' });

setInterval(() => {
  const position = getScrollPosition();
  port.postMessage({  // Reuses existing connection
    type: 'scroll-position',
    position
  });
}, 100);

port.onDisconnect.addListener(() => {
  // Reconnect if SW restarts
  reconnect();
});
```

```javascript
// background.js - Handle port connections
chrome.runtime.onConnect.addListener((port) => {
  if (port.name === 'scroll-tracker') {
    port.onMessage.addListener((message) => {
      if (message.type === 'scroll-position') {
        processScrollData(message.position);
      }
    });
  }
});
```

**When to use each pattern:**
- `sendMessage`: One-off requests, infrequent communication
- `connect`: Streaming data, chat-like interactions, frequent updates
- Port connections keep the service worker alive while connected

Reference: [Message Passing - Long-lived Connections](https://developer.chrome.com/docs/extensions/develop/concepts/messaging)
