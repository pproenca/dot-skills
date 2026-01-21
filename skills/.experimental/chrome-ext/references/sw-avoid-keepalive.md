---
title: Avoid Artificial Service Worker Keep-Alive Patterns
impact: CRITICAL
impactDescription: reduces memory usage by 50-100MB per idle extension
tags: sw, memory, service-worker, lifecycle, performance
---

## Avoid Artificial Service Worker Keep-Alive Patterns

Service workers are designed to be ephemeral. Keeping them alive unnecessarily consumes memory and CPU, negating Manifest V3's efficiency benefits. Design for event-driven wake-ups instead.

**Incorrect (wastes memory keeping SW alive):**

```javascript
// background.js - Anti-pattern: keeping SW alive indefinitely
setInterval(() => {
  chrome.runtime.getPlatformInfo(() => {});  // Resets 30s idle timer
}, 25000);

// Or using a persistent WebSocket just to stay alive
const ws = new WebSocket('wss://keepalive.example.com');
ws.onclose = () => {
  setTimeout(() => connectWebSocket(), 1000);  // Reconnect loop
};
```

**Correct (event-driven, terminates when idle):**

```javascript
// background.js - Let SW terminate naturally
chrome.alarms.create('sync-data', { periodInMinutes: 15 });

chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === 'sync-data') {
    syncDataWithServer();  // SW wakes, runs task, terminates
  }
});

async function syncDataWithServer() {
  const { pendingChanges } = await chrome.storage.local.get(['pendingChanges']);
  if (pendingChanges?.length > 0) {
    await fetch('https://api.example.com/sync', {
      method: 'POST',
      body: JSON.stringify(pendingChanges)
    });
    await chrome.storage.local.remove(['pendingChanges']);
  }
}
```

**When keep-alive IS acceptable:**
- Active audio playback (use offscreen document)
- Active native messaging connection
- Long-running WebSocket with actual message traffic

Reference: [Extension Service Worker Lifecycle](https://developer.chrome.com/docs/extensions/develop/concepts/service-workers/lifecycle)
