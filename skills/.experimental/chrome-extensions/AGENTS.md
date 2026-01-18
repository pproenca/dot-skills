# Chrome Extensions

**Version 0.1.0**  
Chrome Developer Relations  
January 2026

> **Note:**
> This document is mainly for agents and LLMs to follow when maintaining,
> generating, or refactoring chrome extensions codebases. Humans may also find it useful,
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization guide for Chrome Extensions (Manifest V3), designed for AI agents and LLMs. Contains 40+ rules across 8 categories, prioritized by impact from critical (service worker lifecycle, content script optimization) to incremental (API usage patterns). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Service Worker Lifecycle](#1-service-worker-lifecycle) — **CRITICAL**
   - 1.1 [Avoid Artificial Service Worker Keep-Alive Patterns](#11-avoid-artificial-service-worker-keep-alive-patterns)
   - 1.2 [Persist State with chrome.storage Instead of Global Variables](#12-persist-state-with-chromestorage-instead-of-global-variables)
   - 1.3 [Register Event Listeners at Top Level of Service Worker](#13-register-event-listeners-at-top-level-of-service-worker)
   - 1.4 [Return true from Message Listeners for Async Responses](#14-return-true-from-message-listeners-for-async-responses)
   - 1.5 [Use chrome.alarms Instead of setTimeout/setInterval](#15-use-chromealarms-instead-of-settimeoutsetinterval)
   - 1.6 [Use Offscreen Documents for DOM APIs](#16-use-offscreen-documents-for-dom-apis)
2. [Content Script Optimization](#2-content-script-optimization) — **CRITICAL**
   - 2.1 [Batch DOM Operations to Minimize Reflows](#21-batch-dom-operations-to-minimize-reflows)
   - 2.2 [Minimize Content Script Bundle Size](#22-minimize-content-script-bundle-size)
   - 2.3 [Prefer Programmatic Injection Over Manifest Declaration](#23-prefer-programmatic-injection-over-manifest-declaration)
   - 2.4 [Use document_idle for Content Script Injection](#24-use-documentidle-for-content-script-injection)
   - 2.5 [Use MutationObserver Instead of Polling for DOM Changes](#25-use-mutationobserver-instead-of-polling-for-dom-changes)
   - 2.6 [Use Specific URL Match Patterns Instead of All URLs](#26-use-specific-url-match-patterns-instead-of-all-urls)
3. [Message Passing Efficiency](#3-message-passing-efficiency) — **HIGH**
   - 3.1 [Always Check chrome.runtime.lastError in Callbacks](#31-always-check-chromeruntimelasterror-in-callbacks)
   - 3.2 [Avoid Broadcasting Messages to All Tabs](#32-avoid-broadcasting-messages-to-all-tabs)
   - 3.3 [Debounce High-Frequency Events Before Messaging](#33-debounce-high-frequency-events-before-messaging)
   - 3.4 [Minimize Message Payload Size](#34-minimize-message-payload-size)
   - 3.5 [Use Port Connections for Frequent Message Exchange](#35-use-port-connections-for-frequent-message-exchange)
4. [Storage Operations](#4-storage-operations) — **HIGH**
   - 4.1 [Avoid Storing Large Binary Blobs in chrome.storage](#41-avoid-storing-large-binary-blobs-in-chromestorage)
   - 4.2 [Batch Storage Operations Instead of Individual Calls](#42-batch-storage-operations-instead-of-individual-calls)
   - 4.3 [Cache Frequently Accessed Storage Values in Memory](#43-cache-frequently-accessed-storage-values-in-memory)
   - 4.4 [Choose the Correct Storage Type for Your Use Case](#44-choose-the-correct-storage-type-for-your-use-case)
   - 4.5 [Use storage.session for Temporary Runtime Data](#45-use-storagesession-for-temporary-runtime-data)
5. [Network & Permissions](#5-network-permissions) — **MEDIUM-HIGH**
   - 5.1 [Avoid Modifying Content Security Policy Headers](#51-avoid-modifying-content-security-policy-headers)
   - 5.2 [Request Minimal Required Permissions](#52-request-minimal-required-permissions)
   - 5.3 [Use activeTab Permission Instead of Broad Host Permissions](#53-use-activetab-permission-instead-of-broad-host-permissions)
   - 5.4 [Use declarativeNetRequest Instead of webRequest for Blocking](#54-use-declarativenetrequest-instead-of-webrequest-for-blocking)
6. [Memory Management](#6-memory-management) — **MEDIUM**
   - 6.1 [Avoid Accidental Closure Memory Leaks](#61-avoid-accidental-closure-memory-leaks)
   - 6.2 [Avoid Holding References to Detached DOM Nodes](#62-avoid-holding-references-to-detached-dom-nodes)
   - 6.3 [Clean Up Event Listeners When Content Script Unloads](#63-clean-up-event-listeners-when-content-script-unloads)
   - 6.4 [Clear Intervals and Timeouts on Cleanup](#64-clear-intervals-and-timeouts-on-cleanup)
   - 6.5 [Use WeakMap and WeakSet for DOM Element References](#65-use-weakmap-and-weakset-for-dom-element-references)
7. [UI Performance](#7-ui-performance) — **MEDIUM**
   - 7.1 [Batch Badge Updates to Avoid Flicker](#71-batch-badge-updates-to-avoid-flicker)
   - 7.2 [Lazy Load Options Page Sections](#72-lazy-load-options-page-sections)
   - 7.3 [Minimize Popup Bundle Size for Fast Startup](#73-minimize-popup-bundle-size-for-fast-startup)
   - 7.4 [Render Popup UI with Cached Data First](#74-render-popup-ui-with-cached-data-first)
8. [API Usage Patterns](#8-api-usage-patterns) — **LOW-MEDIUM**
   - 8.1 [Avoid Redundant API Calls in Loops](#81-avoid-redundant-api-calls-in-loops)
   - 8.2 [Handle Extension Context Invalidated Errors](#82-handle-extension-context-invalidated-errors)
   - 8.3 [Query Tabs with Specific Filters](#83-query-tabs-with-specific-filters)
   - 8.4 [Respect Alarms API Minimum Period](#84-respect-alarms-api-minimum-period)
   - 8.5 [Use Declarative Content API for Page Actions](#85-use-declarative-content-api-for-page-actions)
   - 8.6 [Use Promise-Based API Calls Over Callbacks](#86-use-promise-based-api-calls-over-callbacks)

---

## 1. Service Worker Lifecycle

**Impact: CRITICAL**

Service workers are ephemeral with 30-second idle timeouts. Global state loss, improper persistence, and unnecessary keep-alive patterns are the #1 performance killers in Manifest V3 extensions.

### 1.1 Avoid Artificial Service Worker Keep-Alive Patterns

**Impact: CRITICAL (reduces memory usage by 50-100MB per idle extension)**

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

### 1.2 Persist State with chrome.storage Instead of Global Variables

**Impact: CRITICAL (prevents complete state loss on SW termination)**

Service workers terminate after 30 seconds of inactivity. Any global variables are lost when this happens. Use `chrome.storage.local` or `chrome.storage.session` to persist state across service worker restarts.

**Incorrect (state lost on SW termination):**

```javascript
// background.js (service worker)
let userSettings = { theme: 'dark', notifications: true };

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'get-settings') {
    sendResponse(userSettings);  // Returns undefined after SW restart
  }
  if (message.type === 'set-settings') {
    userSettings = message.settings;  // Lost when SW terminates
  }
});
```

**Correct (state persisted across restarts):**

```javascript
// background.js (service worker)
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'get-settings') {
    chrome.storage.local.get(['userSettings']).then(({ userSettings }) => {
      sendResponse(userSettings ?? { theme: 'dark', notifications: true });
    });
    return true;  // Keep channel open for async response
  }
  if (message.type === 'set-settings') {
    chrome.storage.local.set({ userSettings: message.settings });
  }
});
```

**When to use each storage type:**
- `chrome.storage.local` - Persists across browser restarts (10MB limit)
- `chrome.storage.session` - Cleared when browser closes, not synced (10MB limit)
- `chrome.storage.sync` - Synced across devices (100KB limit, 8KB per item)

Reference: [Migrate to a Service Worker](https://developer.chrome.com/docs/extensions/develop/migrate/to-service-workers)

### 1.3 Register Event Listeners at Top Level of Service Worker

**Impact: CRITICAL (prevents missed events when SW restarts)**

Event listeners must be registered synchronously at the top level of your service worker. If listeners are registered inside async callbacks or conditionally, events may be missed when the service worker wakes up.

**Incorrect (listeners registered conditionally or async):**

```javascript
// background.js
chrome.storage.local.get(['isEnabled']).then(({ isEnabled }) => {
  if (isEnabled) {
    // Listener registered too late - events during startup are lost
    chrome.tabs.onUpdated.addListener(handleTabUpdate);
  }
});

async function initialize() {
  await loadConfiguration();
  // Registered after async operation - may miss events
  chrome.runtime.onMessage.addListener(handleMessage);
}

initialize();
```

**Correct (listeners registered synchronously at top level):**

```javascript
// background.js
// Register ALL listeners synchronously at the top level
chrome.tabs.onUpdated.addListener(handleTabUpdate);
chrome.runtime.onMessage.addListener(handleMessage);
chrome.runtime.onInstalled.addListener(handleInstall);
chrome.alarms.onAlarm.addListener(handleAlarm);

// Check conditions INSIDE the handlers
async function handleTabUpdate(tabId, changeInfo, tab) {
  const { isEnabled } = await chrome.storage.local.get(['isEnabled']);
  if (!isEnabled) return;  // Early return if disabled

  if (changeInfo.status === 'complete') {
    await processTab(tab);
  }
}

async function handleMessage(message, sender, sendResponse) {
  const config = await loadConfiguration();
  // Use config in handler logic
  return true;
}
```

**Why this matters:**
Chrome only dispatches events to listeners that exist when the SW starts. If your listener is registered after an async operation, Chrome doesn't know about it and won't wake your SW for those events.

Reference: [Extension Service Worker Lifecycle](https://developer.chrome.com/docs/extensions/develop/concepts/service-workers/lifecycle)

### 1.4 Return true from Message Listeners for Async Responses

**Impact: CRITICAL (prevents undefined responses and message channel closure)**

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

### 1.5 Use chrome.alarms Instead of setTimeout/setInterval

**Impact: CRITICAL (prevents timer callbacks from being lost on SW termination)**

`setTimeout` and `setInterval` are canceled when service workers terminate. For any delayed or periodic operations, use the `chrome.alarms` API which persists across service worker restarts.

**Incorrect (timer lost when SW terminates):**

```javascript
// background.js
chrome.runtime.onInstalled.addListener(() => {
  // This timer will be lost if SW terminates before 5 minutes
  setTimeout(() => {
    checkForUpdates();
  }, 5 * 60 * 1000);

  // This interval stops when SW terminates
  setInterval(() => {
    syncBookmarks();
  }, 30 * 60 * 1000);
});
```

**Correct (alarms persist across SW restarts):**

```javascript
// background.js
chrome.runtime.onInstalled.addListener(() => {
  chrome.alarms.create('check-updates', { delayInMinutes: 5 });
  chrome.alarms.create('sync-bookmarks', { periodInMinutes: 30 });
});

chrome.alarms.onAlarm.addListener((alarm) => {
  switch (alarm.name) {
    case 'check-updates':
      checkForUpdates();
      break;
    case 'sync-bookmarks':
      syncBookmarks();
      break;
  }
});
```

**Limitations to know:**
- Minimum alarm period is 1 minute (shorter values are rounded up)
- Alarms cannot be set from content scripts
- Alarms do not persist across browser restarts

**When setTimeout IS acceptable:**
- Short delays under 30 seconds while SW is actively processing
- Debouncing rapid events within a single SW session

Reference: [chrome.alarms API](https://developer.chrome.com/docs/extensions/reference/api/alarms)

### 1.6 Use Offscreen Documents for DOM APIs

**Impact: CRITICAL (enables DOM manipulation without content script injection)**

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

---

## 2. Content Script Optimization

**Impact: CRITICAL**

Content scripts run on every matching page. Heavy script injection, poor timing, and DOM manipulation bottlenecks cascade across all user browsing sessions.

### 2.1 Batch DOM Operations to Minimize Reflows

**Impact: CRITICAL (reduces layout thrashing by 10-100×)**

Reading layout properties and modifying the DOM in alternating sequence causes layout thrashing. Batch all reads together, then all writes, to minimize expensive browser reflow calculations.

**Incorrect (layout thrashing with read-write alternation):**

```javascript
// content.js - Forces reflow on every iteration
function highlightElements(selectors) {
  selectors.forEach(selector => {
    const element = document.querySelector(selector);
    const height = element.offsetHeight;    // Read - forces layout
    element.style.height = height + 10 + 'px';  // Write - invalidates
    const width = element.offsetWidth;      // Read - forces reflow again
    element.style.width = width + 10 + 'px';    // Write - invalidates again
  });
}
// N elements = 4N layout calculations
```

**Correct (batched reads then writes):**

```javascript
// content.js - Single reflow for all operations
function highlightElements(selectors) {
  const elements = selectors.map(s => document.querySelector(s));

  // Batch all reads first
  const measurements = elements.map(el => ({
    element: el,
    height: el.offsetHeight,
    width: el.offsetWidth
  }));

  // Batch all writes together
  measurements.forEach(({ element, height, width }) => {
    element.style.height = height + 10 + 'px';
    element.style.width = width + 10 + 'px';
  });
}
// N elements = 2 layout calculations total
```

**Alternative (using DocumentFragment):**

```javascript
// content.js - Build DOM off-screen
function createOverlay(items) {
  const fragment = document.createDocumentFragment();

  items.forEach(item => {
    const div = document.createElement('div');
    div.className = 'overlay-item';
    div.textContent = item.label;
    fragment.appendChild(div);  // No reflow yet
  });

  document.body.appendChild(fragment);  // Single reflow
}
```

**Properties that trigger layout:**
`offsetHeight`, `offsetWidth`, `offsetTop`, `clientHeight`, `scrollHeight`, `getComputedStyle()`, `getBoundingClientRect()`

Reference: [What forces layout/reflow](https://gist.github.com/paulirish/5d52fb081b3570c81e3a)

### 2.2 Minimize Content Script Bundle Size

**Impact: CRITICAL (reduces page load impact by 100-500ms per page)**

Content script JavaScript must be parsed and compiled on every page load. Unlike web pages, extension scripts don't benefit from HTTP cache for compilation. Large bundles significantly slow down every page the user visits.

**Incorrect (large monolithic bundle):**

```javascript
// content.js - 200KB bundle with unused code
import React from 'react';           // 40KB
import ReactDOM from 'react-dom';    // 40KB
import lodash from 'lodash';         // 70KB
import moment from 'moment';         // 50KB

// Only uses 2 functions from each library
const result = lodash.debounce(() => {});
const date = moment().format('YYYY-MM-DD');
```

**Correct (minimal targeted imports):**

```javascript
// content.js - 5KB bundle with only what's needed
import debounce from 'lodash/debounce';  // 1KB

// Use native alternatives when possible
const date = new Date().toISOString().split('T')[0];

// Lazy-load heavy features
let heavyModule = null;
async function loadHeavyFeature() {
  if (!heavyModule) {
    heavyModule = await import('./heavy-feature.js');
  }
  return heavyModule;
}
```

**Bundle optimization strategies:**
- Use tree-shakeable ES modules
- Import specific functions, not entire libraries
- Use native APIs instead of libraries (Date vs moment)
- Split code and lazy-load non-critical features
- Analyze bundle with tools like webpack-bundle-analyzer

**Target sizes:**
- Simple content scripts: < 10KB
- Feature-rich scripts: < 50KB
- Heavy UI overlays: lazy-load separately

Reference: [Content Scripts](https://developer.chrome.com/docs/extensions/develop/concepts/content-scripts)

### 2.3 Prefer Programmatic Injection Over Manifest Declaration

**Impact: CRITICAL (loads scripts only when user invokes feature)**

Manifest-declared content scripts run on every matching page load, even if unused. Programmatic injection using `chrome.scripting.executeScript` loads scripts only when the user actually needs the feature.

**Incorrect (always loaded on every matching page):**

```json
{
  "content_scripts": [{
    "matches": ["https://*.com/*"],
    "js": ["page-analyzer.js"]
  }]
}
```

```javascript
// page-analyzer.js - 50KB of code loaded on every page
// Even if user never clicks the extension
import { analyzeDOM } from './analyzer';
import { renderOverlay } from './overlay';
// ...all this code parsed and compiled on every page visit
```

**Correct (loaded only when user clicks):**

```json
{
  "permissions": ["activeTab", "scripting"]
}
```

```javascript
// background.js
chrome.action.onClicked.addListener(async (tab) => {
  await chrome.scripting.executeScript({
    target: { tabId: tab.id },
    files: ['page-analyzer.js']
  });
});

// popup.js (or from popup button click)
document.getElementById('analyze-btn').addEventListener('click', async () => {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  await chrome.scripting.executeScript({
    target: { tabId: tab.id },
    files: ['page-analyzer.js']
  });
});
```

**Benefits of programmatic injection:**
- `activeTab` permission shows no warning (vs host permissions)
- Zero performance impact on pages where feature isn't used
- Script can be injected into any tab when needed
- Smaller initial extension footprint

**When manifest declaration IS appropriate:**
- Script must observe page from very beginning
- Script modifies page appearance immediately (CSS injection)
- Script intercepts page events before they fire

Reference: [chrome.scripting API](https://developer.chrome.com/docs/extensions/reference/api/scripting)

### 2.4 Use document_idle for Content Script Injection

**Impact: CRITICAL (eliminates page load blocking, faster initial render)**

The default `document_idle` timing injects scripts after the DOM is ready but before all resources load. Using `document_start` blocks the page while your script runs. Only use earlier injection when absolutely necessary.

**Incorrect (blocks page rendering):**

```json
{
  "content_scripts": [{
    "matches": ["https://example.com/*"],
    "js": ["content.js"],
    "run_at": "document_start"
  }]
}
```

```javascript
// content.js - Heavy initialization at document_start
const config = loadExtensionConfig();  // Synchronous
setupMutationObservers();
initializeFeatures();
// All this runs before page renders anything
```

**Correct (non-blocking injection):**

```json
{
  "content_scripts": [{
    "matches": ["https://example.com/*"],
    "js": ["content.js"],
    "run_at": "document_idle"
  }]
}
```

```javascript
// content.js - Runs after DOM is ready
async function initialize() {
  const config = await chrome.storage.local.get(['config']);
  setupMutationObservers();
  initializeFeatures();
}

initialize();
```

**When document_start IS appropriate:**
- Injecting CSS to prevent flash of unstyled content
- Intercepting/modifying page scripts before they run
- Observing very early DOM mutations

**Injection timing reference:**
- `document_start` - Before DOM construction begins
- `document_end` - After DOM ready, before subresources
- `document_idle` - After DOM ready, during/after subresource load (default)

Reference: [Content Scripts](https://developer.chrome.com/docs/extensions/develop/concepts/content-scripts)

### 2.5 Use MutationObserver Instead of Polling for DOM Changes

**Impact: CRITICAL (eliminates polling overhead, event-driven detection)**

Polling the DOM with setInterval wastes CPU cycles checking for changes that haven't happened. MutationObserver is event-driven and only runs when the DOM actually changes.

**Incorrect (continuous polling wastes CPU):**

```javascript
// content.js - Checks every 100ms even when nothing changes
let lastContent = null;

setInterval(() => {
  const element = document.querySelector('.dynamic-content');
  if (element && element.textContent !== lastContent) {
    lastContent = element.textContent;
    processNewContent(element);
  }
}, 100);  // 10 checks per second, 600 per minute
```

**Correct (event-driven observation):**

```javascript
// content.js - Only runs when DOM actually changes
const observer = new MutationObserver((mutations) => {
  for (const mutation of mutations) {
    if (mutation.type === 'childList') {
      const newContent = mutation.target.querySelector('.dynamic-content');
      if (newContent) {
        processNewContent(newContent);
      }
    }
  }
});

observer.observe(document.body, {
  childList: true,
  subtree: true
});

// Clean up when content script is done
window.addEventListener('unload', () => observer.disconnect());
```

**Optimized observation (narrow scope):**

```javascript
// content.js - Watch only the relevant container
async function watchForContent() {
  // Wait for container to exist
  const container = await waitForElement('#app-container');

  const observer = new MutationObserver((mutations) => {
    for (const mutation of mutations) {
      processAddedNodes(mutation.addedNodes);
    }
  });

  observer.observe(container, {
    childList: true,
    subtree: false  // Don't watch deeply if not needed
  });
}

function waitForElement(selector) {
  return new Promise(resolve => {
    const el = document.querySelector(selector);
    if (el) return resolve(el);

    const observer = new MutationObserver(() => {
      const el = document.querySelector(selector);
      if (el) {
        observer.disconnect();
        resolve(el);
      }
    });
    observer.observe(document.body, { childList: true, subtree: true });
  });
}
```

Reference: [MutationObserver MDN](https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver)

### 2.6 Use Specific URL Match Patterns Instead of All URLs

**Impact: CRITICAL (reduces script injection by 90%+, faster browsing)**

Using `<all_urls>` or overly broad match patterns injects your content script into every page, slowing down all browsing and increasing memory usage. Specify the exact domains and paths your extension needs.

**Incorrect (injected into every page):**

```json
{
  "content_scripts": [{
    "matches": ["<all_urls>"],
    "js": ["content.js"]
  }]
}
```

```json
{
  "content_scripts": [{
    "matches": ["*://*/*"],
    "js": ["content.js"]
  }]
}
```

**Correct (injected only where needed):**

```json
{
  "content_scripts": [{
    "matches": [
      "https://github.com/*",
      "https://gitlab.com/*"
    ],
    "js": ["content.js"]
  }]
}
```

**Even better (path-specific):**

```json
{
  "content_scripts": [{
    "matches": [
      "https://github.com/*/*/pull/*",
      "https://github.com/*/*/issues/*"
    ],
    "js": ["pr-tools.js"]
  }]
}
```

**If you need broad access conditionally:**

```javascript
// background.js - Inject only when needed
chrome.action.onClicked.addListener(async (tab) => {
  // User explicitly requested the feature
  await chrome.scripting.executeScript({
    target: { tabId: tab.id },
    files: ['content.js']
  });
});
```

**Note:** Over-requesting permissions is the #1 rejection reason in Chrome Web Store review.

Reference: [Match Patterns](https://developer.chrome.com/docs/extensions/develop/concepts/match-patterns)

---

## 3. Message Passing Efficiency

**Impact: HIGH**

Cross-context messaging between service workers, content scripts, and popups adds latency. Poor patterns cause N×M message storms and serialization overhead.

### 3.1 Always Check chrome.runtime.lastError in Callbacks

**Impact: HIGH (prevents silent failures and memory leaks)**

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

### 3.2 Avoid Broadcasting Messages to All Tabs

**Impact: HIGH (reduces message overhead from O(n) to O(1))**

Sending messages to all tabs wastes resources when only specific tabs need the update. Query for relevant tabs and target messages specifically.

**Incorrect (message sent to every tab):**

```javascript
// background.js - Broadcasts to all tabs
async function notifySettingsChange(settings) {
  const tabs = await chrome.tabs.query({});  // All tabs

  // Sends message to 50+ tabs, most don't care
  for (const tab of tabs) {
    chrome.tabs.sendMessage(tab.id, {
      type: 'settings-updated',
      settings
    }).catch(() => {});  // Many will fail (no content script)
  }
}
```

**Correct (targeted messaging):**

```javascript
// background.js - Message only relevant tabs
async function notifySettingsChange(settings) {
  // Query only tabs where content script is active
  const tabs = await chrome.tabs.query({
    url: ['https://github.com/*', 'https://gitlab.com/*']
  });

  await Promise.all(
    tabs.map(tab =>
      chrome.tabs.sendMessage(tab.id, {
        type: 'settings-updated',
        settings
      }).catch(() => {})  // Tab might have navigated away
    )
  );
}
```

**Alternative (track interested tabs):**

```javascript
// background.js - Registry pattern
const subscribedTabs = new Set();

chrome.runtime.onMessage.addListener((message, sender) => {
  if (message.type === 'subscribe') {
    subscribedTabs.add(sender.tab.id);
  }
  if (message.type === 'unsubscribe') {
    subscribedTabs.delete(sender.tab.id);
  }
});

chrome.tabs.onRemoved.addListener((tabId) => {
  subscribedTabs.delete(tabId);
});

async function notifySubscribers(data) {
  for (const tabId of subscribedTabs) {
    chrome.tabs.sendMessage(tabId, data).catch(() => {
      subscribedTabs.delete(tabId);
    });
  }
}
```

**When broadcast IS acceptable:**
- Critical security updates that affect all contexts
- Extension-wide state changes (like disable/enable)

Reference: [chrome.tabs.query](https://developer.chrome.com/docs/extensions/reference/api/tabs#method-query)

### 3.3 Debounce High-Frequency Events Before Messaging

**Impact: HIGH (reduces message volume by 90%+ for scroll/resize events)**

Events like scroll, resize, and mousemove fire dozens of times per second. Sending a message for each event overwhelms the message channel and wastes CPU on redundant processing.

**Incorrect (message storm from every event):**

```javascript
// content.js - 60+ messages per second during scroll
window.addEventListener('scroll', () => {
  chrome.runtime.sendMessage({
    type: 'scroll',
    position: window.scrollY
  });
});

// User scrolls for 5 seconds = 300+ messages
```

**Correct (debounced messaging):**

```javascript
// content.js - Debounce to reduce message frequency
function debounce(fn, delay) {
  let timeoutId;
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
}

const sendScrollPosition = debounce((position) => {
  chrome.runtime.sendMessage({
    type: 'scroll',
    position
  });
}, 100);  // Max 10 messages/second

window.addEventListener('scroll', () => {
  sendScrollPosition(window.scrollY);
});
```

**Throttle for continuous updates:**

```javascript
// content.js - Throttle for regular sampling
function throttle(fn, limit) {
  let lastCall = 0;
  return (...args) => {
    const now = Date.now();
    if (now - lastCall >= limit) {
      lastCall = now;
      fn(...args);
    }
  };
}

const trackMousePosition = throttle((x, y) => {
  chrome.runtime.sendMessage({ type: 'mouse', x, y });
}, 200);  // At most every 200ms

document.addEventListener('mousemove', (e) => {
  trackMousePosition(e.clientX, e.clientY);
});
```

**When to use each:**
- **Debounce**: Final value matters (search input, resize end)
- **Throttle**: Regular sampling matters (scroll position, animations)

Reference: [Debouncing and Throttling Explained](https://css-tricks.com/debouncing-throttling-explained-examples/)

### 3.4 Minimize Message Payload Size

**Impact: HIGH (reduces serialization overhead by 2-10×)**

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

### 3.5 Use Port Connections for Frequent Message Exchange

**Impact: HIGH (reduces messaging overhead by 50-80% for repeated messages)**

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

---

## 4. Storage Operations

**Impact: HIGH**

Storage I/O is asynchronous and can block extension responsiveness. Excessive reads/writes, wrong storage type selection, and unbatched operations create significant delays.

### 4.1 Avoid Storing Large Binary Blobs in chrome.storage

**Impact: HIGH (prevents quota exhaustion and serialization overhead)**

`chrome.storage` JSON-serializes all data. Binary data like images or files become base64-encoded, increasing size by ~33%. Use IndexedDB or Cache API for binary data.

**Incorrect (base64-encoded images in storage):**

```javascript
// background.js - Images bloat storage
async function cacheScreenshot(tabId) {
  const dataUrl = await chrome.tabs.captureVisibleTab();
  // 1MB image becomes ~1.3MB base64 string
  await chrome.storage.local.set({
    [`screenshot:${tabId}`]: dataUrl
  });
}
// 10 screenshots = 13MB, quota nearly exhausted
```

**Correct (use IndexedDB for binary data):**

```javascript
// background.js - Binary data in IndexedDB
const DB_NAME = 'extension-cache';
const STORE_NAME = 'screenshots';

async function openDatabase() {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, 1);
    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve(request.result);
    request.onupgradeneeded = (event) => {
      event.target.result.createObjectStore(STORE_NAME);
    };
  });
}

async function cacheScreenshot(tabId) {
  const dataUrl = await chrome.tabs.captureVisibleTab();
  // Convert to Blob for efficient storage
  const response = await fetch(dataUrl);
  const blob = await response.blob();

  const db = await openDatabase();
  const tx = db.transaction(STORE_NAME, 'readwrite');
  tx.objectStore(STORE_NAME).put(blob, `screenshot:${tabId}`);
}

async function getScreenshot(tabId) {
  const db = await openDatabase();
  const tx = db.transaction(STORE_NAME, 'readonly');
  return new Promise((resolve) => {
    const request = tx.objectStore(STORE_NAME).get(`screenshot:${tabId}`);
    request.onsuccess = () => resolve(request.result);
  });
}
```

**When to use each storage:**

| Data Type | Best Storage |
|-----------|-------------|
| JSON config/settings | chrome.storage |
| Small strings (<100KB) | chrome.storage |
| Images, files, audio | IndexedDB |
| HTTP responses | CacheStorage |

Reference: [IndexedDB API](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API)

### 4.2 Batch Storage Operations Instead of Individual Calls

**Impact: HIGH (reduces storage overhead by 5-20× for multiple values)**

Each `chrome.storage` call has async overhead. Reading or writing multiple values in separate calls multiplies this overhead. Use object syntax to batch operations.

**Incorrect (separate call per value):**

```javascript
// background.js - 5 separate async operations
async function saveUserPreferences(prefs) {
  await chrome.storage.local.set({ theme: prefs.theme });
  await chrome.storage.local.set({ fontSize: prefs.fontSize });
  await chrome.storage.local.set({ language: prefs.language });
  await chrome.storage.local.set({ notifications: prefs.notifications });
  await chrome.storage.local.set({ autoSave: prefs.autoSave });
}

async function loadUserPreferences() {
  const theme = await chrome.storage.local.get('theme');
  const fontSize = await chrome.storage.local.get('fontSize');
  const language = await chrome.storage.local.get('language');
  // 5 round trips to storage
}
```

**Correct (single batched operation):**

```javascript
// background.js - Single async operation
async function saveUserPreferences(prefs) {
  await chrome.storage.local.set({
    theme: prefs.theme,
    fontSize: prefs.fontSize,
    language: prefs.language,
    notifications: prefs.notifications,
    autoSave: prefs.autoSave
  });
}

async function loadUserPreferences() {
  const prefs = await chrome.storage.local.get([
    'theme', 'fontSize', 'language', 'notifications', 'autoSave'
  ]);
  return prefs;
}
```

**Get all stored data at once:**

```javascript
// Get everything (use sparingly for large datasets)
const allData = await chrome.storage.local.get(null);

// Get with defaults
const settings = await chrome.storage.local.get({
  theme: 'light',      // Default if not set
  fontSize: 14,
  language: 'en'
});
```

**Note:** Batching is especially important in content scripts where message passing adds additional latency to each operation.

Reference: [chrome.storage API](https://developer.chrome.com/docs/extensions/reference/api/storage)

### 4.3 Cache Frequently Accessed Storage Values in Memory

**Impact: HIGH (eliminates repeated async storage reads)**

Reading from `chrome.storage` on every access adds async overhead. For values read frequently (like feature flags or user settings), cache them in memory and update via storage change listeners.

**Incorrect (reads storage on every access):**

```javascript
// content.js - Storage read on every page element
async function processElement(element) {
  // Reads storage for EVERY element processed
  const { highlightColor } = await chrome.storage.local.get('highlightColor');
  element.style.backgroundColor = highlightColor;
}

document.querySelectorAll('.target').forEach(processElement);
// 100 elements = 100 storage reads
```

**Correct (read once, cache in memory):**

```javascript
// content.js - Single read, memory cache
let settings = null;

async function initializeSettings() {
  settings = await chrome.storage.local.get({
    highlightColor: 'yellow',
    enabled: true
  });
}

function processElement(element) {
  if (!settings.enabled) return;
  element.style.backgroundColor = settings.highlightColor;
}

// Listen for changes and update cache
chrome.storage.onChanged.addListener((changes, areaName) => {
  if (areaName === 'local') {
    for (const [key, { newValue }] of Object.entries(changes)) {
      settings[key] = newValue;
    }
  }
});

// Initialize then process
initializeSettings().then(() => {
  document.querySelectorAll('.target').forEach(processElement);
});
```

**Service worker cache pattern:**

```javascript
// background.js - Cache with lazy loading
let cachedConfig = null;

async function getConfig() {
  if (!cachedConfig) {
    cachedConfig = await chrome.storage.local.get({
      apiUrl: 'https://api.example.com',
      maxRetries: 3
    });
  }
  return cachedConfig;
}

chrome.storage.onChanged.addListener((changes, areaName) => {
  if (areaName === 'local') {
    cachedConfig = null;  // Invalidate on any change
  }
});
```

Reference: [chrome.storage.onChanged](https://developer.chrome.com/docs/extensions/reference/api/storage#event-onChanged)

### 4.4 Choose the Correct Storage Type for Your Use Case

**Impact: HIGH (prevents quota errors and sync throttling)**

Using `storage.sync` for large data hits quota limits and throttling. Using `storage.local` for cross-device settings creates inconsistent user experience. Match storage type to data characteristics.

**Incorrect (wrong storage type for use case):**

```javascript
// background.js - Large cache in sync storage (102KB limit)
async function cachePageData(url, data) {
  await chrome.storage.sync.set({
    [`cache:${url}`]: data  // 500KB of cached pages
  });  // Error: QUOTA_BYTES_PER_ITEM quota exceeded
}

// Temporary data in persistent storage
async function saveProcessingState(state) {
  await chrome.storage.local.set({ processingState: state });
  // Stays forever, never cleaned up
}
```

**Correct (appropriate storage for each use case):**

```javascript
// User preferences that should sync across devices
await chrome.storage.sync.set({
  theme: 'dark',
  fontSize: 14
});  // ~100 bytes, well under 8KB/item limit

// Large caches that don't need syncing
await chrome.storage.local.set({
  [`cache:${url}`]: pageData
});  // Up to 10MB (unlimited with permission)

// Temporary session data
await chrome.storage.session.set({
  processingState: state,
  tempAuthToken: token
});  // Cleared when browser closes
```

**Storage type comparison:**

| Type | Limit | Syncs | Persists | Use For |
|------|-------|-------|----------|---------|
| `local` | 10MB | No | Yes | Caches, large data |
| `sync` | 100KB total, 8KB/item | Yes | Yes | User preferences |
| `session` | 10MB | No | No | Temporary state |

**Sync throttling limits:**
- Max 120 writes per minute
- Max 1,800 writes per hour
- Exceeding causes `MAX_WRITE_OPERATIONS_PER_MINUTE` error

Reference: [chrome.storage API](https://developer.chrome.com/docs/extensions/reference/api/storage)

### 4.5 Use storage.session for Temporary Runtime Data

**Impact: HIGH (auto-cleanup on browser close, faster access)**

`storage.session` is designed for data that should only exist during the browser session. It's faster than `storage.local` and automatically cleans up when the browser closes, preventing storage bloat.

**Incorrect (temporary data in persistent storage):**

```javascript
// background.js - Temp data stays forever
async function startProcessing(jobId) {
  await chrome.storage.local.set({
    [`job:${jobId}`]: {
      status: 'running',
      startTime: Date.now()
    }
  });
  // Never cleaned up, accumulates over time
}

// Months later: storage full of stale job entries
```

**Correct (session storage for temporary data):**

```javascript
// background.js - Automatically cleaned up
async function startProcessing(jobId) {
  await chrome.storage.session.set({
    [`job:${jobId}`]: {
      status: 'running',
      startTime: Date.now()
    }
  });
  // Cleared when browser closes
}

async function getJobStatus(jobId) {
  const { [`job:${jobId}`]: job } = await chrome.storage.session.get(`job:${jobId}`);
  return job?.status ?? 'unknown';
}
```

**Use cases for storage.session:**
- Auth tokens that shouldn't persist
- Processing state and progress
- Temporary caches
- Undo/redo stacks
- Form draft data

**Use cases for storage.local:**
- User preferences
- Persistent caches
- Download history
- Data that should survive restarts

**Note:** `storage.session` is not shared between content scripts and service worker by default. Set `chrome.storage.session.setAccessLevel({ accessLevel: 'TRUSTED_AND_UNTRUSTED_CONTEXTS' })` to share.

Reference: [chrome.storage.session](https://developer.chrome.com/docs/extensions/reference/api/storage#property-session)

---

## 5. Network & Permissions

**Impact: MEDIUM-HIGH**

Over-requesting permissions triggers store rejection. Using webRequest instead of declarativeNetRequest blocks the main thread and degrades browsing performance.

### 5.1 Avoid Modifying Content Security Policy Headers

**Impact: MEDIUM-HIGH (prevents security degradation and site breakage)**

Stripping or weakening Content Security Policy headers breaks site security and can cause functionality issues. If you must modify CSP, do so surgically for specific use cases.

**Incorrect (removes all CSP protection):**

```json
[
  {
    "id": 1,
    "priority": 1,
    "action": {
      "type": "modifyHeaders",
      "responseHeaders": [
        { "header": "Content-Security-Policy", "operation": "remove" }
      ]
    },
    "condition": {
      "urlFilter": "*",
      "resourceTypes": ["main_frame"]
    }
  }
]
```

**Correct (minimal, targeted modification):**

```json
[
  {
    "id": 1,
    "priority": 1,
    "action": {
      "type": "modifyHeaders",
      "responseHeaders": [
        {
          "header": "Content-Security-Policy",
          "operation": "set",
          "value": "script-src 'self' https://trusted-cdn.example.com; default-src 'self'"
        }
      ]
    },
    "condition": {
      "urlFilter": "||specific-site.com",
      "resourceTypes": ["main_frame"]
    }
  }
]
```

**Better approach (inject content script instead):**

```javascript
// content.js - Work within CSP constraints
// Instead of injecting <script> tags that CSP blocks,
// use content script messaging

// Incorrect - blocked by CSP
const script = document.createElement('script');
script.src = 'https://external.com/script.js';
document.head.appendChild(script);

// Correct - content script approach
chrome.runtime.sendMessage({ type: 'fetch-data' }, (response) => {
  processData(response);
});
```

**When CSP modification IS acceptable:**
- Developer tools that need to debug CSP issues
- Explicit user opt-in for specific sites
- Enterprise deployments with IT approval

Reference: [Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)

### 5.2 Request Minimal Required Permissions

**Impact: MEDIUM-HIGH (reduces permission warnings, higher install rates)**

Over-requesting permissions is the #1 rejection reason in Chrome Web Store review. Request only what your extension actually needs, and prefer `activeTab` over broad host permissions.

**Incorrect (over-requesting):**

```json
{
  "permissions": [
    "tabs",
    "history",
    "bookmarks",
    "storage",
    "webRequest",
    "webRequestBlocking"
  ],
  "host_permissions": [
    "<all_urls>"
  ]
}
```

**Correct (minimal permissions):**

```json
{
  "permissions": [
    "activeTab",
    "storage"
  ]
}
```

**Use optional_permissions for advanced features:**

```json
{
  "permissions": ["storage"],
  "optional_permissions": ["tabs", "history"],
  "optional_host_permissions": ["https://api.example.com/*"]
}
```

```javascript
// popup.js - Request when user enables feature
async function enableHistoryFeature() {
  const granted = await chrome.permissions.request({
    permissions: ['history']
  });

  if (granted) {
    initializeHistoryFeature();
  }
}
```

**Permission alternatives:**

| Instead of | Use |
|-----------|-----|
| `<all_urls>` | `activeTab` + programmatic injection |
| `tabs` (for URL access) | `activeTab` |
| `webRequest` + `webRequestBlocking` | `declarativeNetRequest` |
| Broad host permissions | Specific domains or `optional_host_permissions` |

**Permissions that show warnings:**
- Host permissions show "Read and change your data on..."
- `history`, `bookmarks`, `downloads` show specific warnings
- `activeTab` shows NO warning

Reference: [Declare Permissions](https://developer.chrome.com/docs/extensions/develop/concepts/declare-permissions)

### 5.3 Use activeTab Permission Instead of Broad Host Permissions

**Impact: MEDIUM-HIGH (eliminates permission warning, 0 scary prompts)**

The `activeTab` permission grants temporary access to the current tab when the user clicks your extension icon. It shows no install warning and works on any site without requesting `<all_urls>`.

**Incorrect (scary permission warning):**

```json
{
  "host_permissions": ["<all_urls>"],
  "permissions": ["scripting"]
}
```

User sees: "Read and change all your data on all websites"

**Correct (no warning, same functionality):**

```json
{
  "permissions": ["activeTab", "scripting"]
}
```

```javascript
// background.js - Inject when user clicks icon
chrome.action.onClicked.addListener(async (tab) => {
  // activeTab grants temporary access to this specific tab
  await chrome.scripting.executeScript({
    target: { tabId: tab.id },
    files: ['content.js']
  });
});
```

**What activeTab grants:**
- Temporary host permission for the active tab
- Access to tab's URL, title, and favicon
- Ability to inject scripts/CSS into that tab
- Permission expires when tab navigates or closes

**Combining with user gestures:**

```javascript
// popup.js - User explicitly clicks button
document.getElementById('extract-btn').addEventListener('click', async () => {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });

  // activeTab permission is active due to popup interaction
  const results = await chrome.scripting.executeScript({
    target: { tabId: tab.id },
    func: () => document.title
  });

  displayResult(results[0].result);
});
```

**When host_permissions ARE needed:**
- Background processing without user interaction
- Modifying requests via declarativeNetRequest
- Content scripts that must run on page load

Reference: [activeTab Permission](https://developer.chrome.com/docs/extensions/develop/concepts/activeTab)

### 5.4 Use declarativeNetRequest Instead of webRequest for Blocking

**Impact: MEDIUM-HIGH (eliminates request interception latency, lower memory usage)**

The `webRequest` API intercepts every request in JavaScript, adding latency. `declarativeNetRequest` uses browser-native rule matching that's significantly faster and doesn't require a persistent background page.

**Incorrect (JavaScript intercepts every request):**

```javascript
// background.js - Runs JS for every network request
chrome.webRequest.onBeforeRequest.addListener(
  (details) => {
    if (details.url.includes('ads.example.com')) {
      return { cancel: true };
    }
    if (details.url.includes('tracker.example.com')) {
      return { cancel: true };
    }
  },
  { urls: ['<all_urls>'] },
  ['blocking']
);
// Every request wakes SW, runs JS, adds latency
```

**Correct (browser-native rule matching):**

```json
{
  "permissions": ["declarativeNetRequest"],
  "declarative_net_request": {
    "rule_resources": [{
      "id": "ruleset_1",
      "enabled": true,
      "path": "rules.json"
    }]
  }
}
```

```json
[
  {
    "id": 1,
    "priority": 1,
    "action": { "type": "block" },
    "condition": {
      "urlFilter": "ads.example.com",
      "resourceTypes": ["script", "image", "xmlhttprequest"]
    }
  },
  {
    "id": 2,
    "priority": 1,
    "action": { "type": "block" },
    "condition": {
      "urlFilter": "tracker.example.com",
      "resourceTypes": ["script", "xmlhttprequest"]
    }
  }
]
```

**Dynamic rules when needed:**

```javascript
// background.js - Update rules programmatically
await chrome.declarativeNetRequest.updateDynamicRules({
  addRules: [{
    id: 100,
    priority: 1,
    action: { type: 'block' },
    condition: { urlFilter: userBlockedDomain }
  }],
  removeRuleIds: [99]
});
```

**When webRequest IS still needed:**
- Modifying request headers dynamically
- Logging requests for debugging
- Complex conditional logic

Reference: [Migrate to declarativeNetRequest](https://developer.chrome.com/docs/extensions/develop/migrate/blocking-web-requests)

---

## 6. Memory Management

**Impact: MEDIUM**

Memory leaks from detached DOM nodes, uncleaned event listeners, and closure retention accumulate over the extension's lifetime, eventually degrading browser performance.

### 6.1 Avoid Accidental Closure Memory Leaks

**Impact: MEDIUM (prevents large objects from being retained unexpectedly)**

Closures capture their enclosing scope. If a long-lived callback references a large object from an outer scope, that object stays in memory for the lifetime of the callback.

**Incorrect (closure retains large data):**

```javascript
// content.js - processedData stays in memory forever
function processPage() {
  const processedData = extractAllData();  // 10MB of page data

  chrome.runtime.onMessage.addListener((message) => {
    // This closure captures entire scope including processedData
    if (message.type === 'get-summary') {
      return processedData.summary;  // Only need summary, but entire object retained
    }
  });
}
```

**Correct (capture only needed values):**

```javascript
// content.js - Only summary stays in memory
function processPage() {
  const processedData = extractAllData();  // 10MB of page data
  const summary = processedData.summary;   // Extract what we need

  // processedData can be garbage collected
  chrome.runtime.onMessage.addListener((message) => {
    if (message.type === 'get-summary') {
      return summary;  // Only 1KB captured
    }
  });
}
```

**Alternative (nullify after use):**

```javascript
// content.js - Explicitly release reference
function processPage() {
  let processedData = extractAllData();

  // Process immediately
  const results = transformData(processedData);
  sendResults(results);

  // Allow garbage collection
  processedData = null;
}
```

**Closure leak in event handlers:**

```javascript
// Incorrect - largeData retained
function setup() {
  const largeData = generateLargeDataset();
  element.onclick = () => console.log(largeData.length);
}

// Correct - extract needed value
function setup() {
  const largeData = generateLargeDataset();
  const length = largeData.length;
  element.onclick = () => console.log(length);
}
```

Reference: [Closures MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Closures)

### 6.2 Avoid Holding References to Detached DOM Nodes

**Impact: MEDIUM (prevents DOM trees from being garbage collected)**

When a DOM element is removed from the page but your JavaScript still references it, the element (and its entire subtree) cannot be garbage collected. This is a common source of memory leaks in content scripts.

**Incorrect (holds reference to removed elements):**

```javascript
// content.js - Elements stay in memory forever
const elementsCache = new Map();

function cacheElement(id) {
  const element = document.getElementById(id);
  elementsCache.set(id, element);  // Holds reference
}

cacheElement('sidebar');
// Later, page removes #sidebar via SPA navigation
// Element tree stays in memory because elementsCache holds reference
```

**Correct (use WeakRef or re-query):**

```javascript
// content.js - WeakRef allows garbage collection
const elementsCache = new Map();

function cacheElement(id) {
  const element = document.getElementById(id);
  if (element) {
    elementsCache.set(id, new WeakRef(element));
  }
}

function getElement(id) {
  const weakRef = elementsCache.get(id);
  if (!weakRef) return null;

  const element = weakRef.deref();
  if (!element || !document.contains(element)) {
    elementsCache.delete(id);  // Clean up stale reference
    return null;
  }
  return element;
}
```

**Alternative (re-query pattern):**

```javascript
// content.js - Query fresh each time
const selectors = {
  sidebar: '#sidebar',
  header: '.main-header'
};

function getElement(name) {
  return document.querySelector(selectors[name]);
}

// No cached references, always gets current element
const sidebar = getElement('sidebar');
if (sidebar) {
  processSidebar(sidebar);
}
```

**Detecting detached nodes:**
Use Chrome DevTools → Memory → Take heap snapshot → Search for "Detached"

Reference: [Fix Memory Problems](https://developer.chrome.com/docs/devtools/memory-problems)

### 6.3 Clean Up Event Listeners When Content Script Unloads

**Impact: MEDIUM (prevents memory accumulation on long-running tabs)**

Event listeners attached to page elements persist even after your content script context is destroyed. These orphaned listeners accumulate memory and can cause unexpected behavior.

**Incorrect (listeners never removed):**

```javascript
// content.js - Listeners accumulate on SPA navigation
document.addEventListener('scroll', handleScroll);
document.addEventListener('click', handleClick);
window.addEventListener('resize', handleResize);

const targetElement = document.querySelector('.target');
targetElement.addEventListener('mouseenter', showTooltip);
// On SPA navigation, new content script runs, old listeners remain
```

**Correct (cleanup on unload):**

```javascript
// content.js - Track and remove listeners
const listeners = [];

function addTrackedListener(target, event, handler) {
  target.addEventListener(event, handler);
  listeners.push({ target, event, handler });
}

addTrackedListener(document, 'scroll', handleScroll);
addTrackedListener(document, 'click', handleClick);
addTrackedListener(window, 'resize', handleResize);

// Clean up when content script context is invalidated
window.addEventListener('unload', cleanup);
chrome.runtime.onMessage.addListener((message) => {
  if (message.type === 'cleanup') cleanup();
});

function cleanup() {
  listeners.forEach(({ target, event, handler }) => {
    target.removeEventListener(event, handler);
  });
  listeners.length = 0;
}
```

**AbortController pattern (modern approach):**

```javascript
// content.js - Single signal aborts all listeners
const controller = new AbortController();
const { signal } = controller;

document.addEventListener('scroll', handleScroll, { signal });
document.addEventListener('click', handleClick, { signal });
window.addEventListener('resize', handleResize, { signal });

// Clean up all at once
window.addEventListener('unload', () => controller.abort());
```

**MutationObserver cleanup:**

```javascript
// content.js
const observer = new MutationObserver(handleMutations);
observer.observe(document.body, { childList: true, subtree: true });

window.addEventListener('unload', () => {
  observer.disconnect();
});
```

Reference: [Memory Management MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Memory_Management)

### 6.4 Clear Intervals and Timeouts on Cleanup

**Impact: MEDIUM (prevents orphaned timers from running after context destroyed)**

Uncleaned intervals continue running after content script context is destroyed, causing errors and wasted CPU. Always clear timers when your script unloads.

**Incorrect (interval runs forever):**

```javascript
// content.js - Never cleared
setInterval(() => {
  const element = document.querySelector('.dynamic-content');
  updateElement(element);  // Error after SPA navigation
}, 1000);

setTimeout(() => {
  heavyComputation();  // Runs even if no longer needed
}, 60000);
```

**Correct (tracked and cleared):**

```javascript
// content.js - Track all timers
const timers = {
  intervals: [],
  timeouts: []
};

function setTrackedInterval(callback, delay) {
  const id = setInterval(callback, delay);
  timers.intervals.push(id);
  return id;
}

function setTrackedTimeout(callback, delay) {
  const id = setTimeout(callback, delay);
  timers.timeouts.push(id);
  return id;
}

setTrackedInterval(() => {
  const element = document.querySelector('.dynamic-content');
  if (element) updateElement(element);
}, 1000);

// Cleanup function
function cleanup() {
  timers.intervals.forEach(clearInterval);
  timers.timeouts.forEach(clearTimeout);
  timers.intervals = [];
  timers.timeouts = [];
}

window.addEventListener('unload', cleanup);
```

**AbortSignal pattern (for newer APIs):**

```javascript
// content.js - Using AbortSignal with setTimeout (proposal)
const controller = new AbortController();

// For fetch requests with timeout
const timeoutId = setTimeout(() => controller.abort(), 5000);

fetch(url, { signal: controller.signal })
  .then(response => response.json())
  .finally(() => clearTimeout(timeoutId));
```

**Service worker note:**
In service workers, `setTimeout`/`setInterval` are unreliable due to termination. Use `chrome.alarms` instead for persistent timing needs.

Reference: [WindowOrWorkerGlobalScope.clearInterval()](https://developer.mozilla.org/en-US/docs/Web/API/clearInterval)

### 6.5 Use WeakMap and WeakSet for DOM Element References

**Impact: MEDIUM (allows automatic garbage collection of cached elements)**

When caching data associated with DOM elements, use `WeakMap` instead of `Map`. WeakMap allows elements to be garbage collected when removed from the page, preventing memory leaks.

**Incorrect (Map prevents garbage collection):**

```javascript
// content.js - Elements never garbage collected
const elementData = new Map();

document.querySelectorAll('.item').forEach(element => {
  elementData.set(element, {
    originalColor: element.style.color,
    processedAt: Date.now()
  });
});

// When elements removed from DOM, Map still holds references
// elementData grows unboundedly on SPAs
```

**Correct (WeakMap allows garbage collection):**

```javascript
// content.js - Elements can be garbage collected
const elementData = new WeakMap();

document.querySelectorAll('.item').forEach(element => {
  elementData.set(element, {
    originalColor: element.style.color,
    processedAt: Date.now()
  });
});

// When elements removed from DOM, WeakMap entries are automatically cleaned
```

**WeakSet for tracking processed elements:**

```javascript
// content.js - Track without preventing GC
const processedElements = new WeakSet();

function processNewElements() {
  document.querySelectorAll('.item').forEach(element => {
    if (processedElements.has(element)) return;  // Skip already processed

    processElement(element);
    processedElements.add(element);
  });
}

// Call on mutations
const observer = new MutationObserver(processNewElements);
observer.observe(document.body, { childList: true, subtree: true });
```

**WeakMap/WeakSet limitations:**
- Keys must be objects (not strings/numbers)
- Not iterable (can't loop over entries)
- No `.size` property
- Use regular Map/Set when you need these features

Reference: [WeakMap MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakMap)

---

## 7. UI Performance

**Impact: MEDIUM**

Popup startup time, options page rendering, and badge updates affect perceived responsiveness and user experience.

### 7.1 Batch Badge Updates to Avoid Flicker

**Impact: MEDIUM (prevents visual flicker and reduces API calls)**

Rapidly updating the browser action badge (text and color) causes visual flicker and unnecessary API calls. Debounce badge updates and set both properties in a single logical update.

**Incorrect (rapid updates cause flicker):**

```javascript
// background.js - Badge flickers with each message
chrome.runtime.onMessage.addListener((message) => {
  if (message.type === 'item-added') {
    updateBadgeCount();  // Called many times rapidly
  }
});

async function updateBadgeCount() {
  const { items } = await chrome.storage.local.get('items');
  const count = items?.length ?? 0;

  // Multiple rapid calls cause flicker
  await chrome.action.setBadgeText({ text: String(count) });
  await chrome.action.setBadgeBackgroundColor({
    color: count > 10 ? '#FF0000' : '#4CAF50'
  });
}
```

**Correct (debounced batch updates):**

```javascript
// background.js - Debounced, batched updates
let badgeUpdateTimeout = null;

chrome.runtime.onMessage.addListener((message) => {
  if (message.type === 'item-added') {
    scheduleBadgeUpdate();
  }
});

function scheduleBadgeUpdate() {
  if (badgeUpdateTimeout) {
    clearTimeout(badgeUpdateTimeout);
  }

  badgeUpdateTimeout = setTimeout(async () => {
    const { items } = await chrome.storage.local.get('items');
    const count = items?.length ?? 0;

    // Update both properties together
    await Promise.all([
      chrome.action.setBadgeText({ text: count > 0 ? String(count) : '' }),
      chrome.action.setBadgeBackgroundColor({
        color: count > 10 ? '#FF0000' : '#4CAF50'
      })
    ]);

    badgeUpdateTimeout = null;
  }, 100);  // 100ms debounce
}
```

**Tab-specific badges:**

```javascript
// background.js - Per-tab badge without global interference
async function updateTabBadge(tabId, count) {
  await Promise.all([
    chrome.action.setBadgeText({ tabId, text: String(count) }),
    chrome.action.setBadgeBackgroundColor({ tabId, color: '#4CAF50' })
  ]);
}

// Clear when tab closes
chrome.tabs.onRemoved.addListener((tabId) => {
  // Badge automatically cleared, no action needed
});
```

Reference: [chrome.action API](https://developer.chrome.com/docs/extensions/reference/api/action)

### 7.2 Lazy Load Options Page Sections

**Impact: MEDIUM (faster initial options page load)**

Options pages with many settings and complex UI can take time to render. Load only the visible section initially, then lazy load other tabs/sections when accessed.

**Incorrect (all sections rendered upfront):**

```javascript
// options.js - Everything loaded immediately
async function initOptions() {
  const settings = await chrome.storage.sync.get(null);

  // All sections rendered even if user never opens them
  renderGeneralSettings(settings);
  renderAdvancedSettings(settings);
  renderKeyboardShortcuts(settings);
  renderPrivacySettings(settings);
  renderExperimentalFeatures(settings);
  renderDataExport(settings);  // Heavy: generates preview
}
```

**Correct (lazy load on tab switch):**

```javascript
// options.js - Load sections on demand
const loadedSections = new Set();

async function initOptions() {
  setupTabs();
  await loadSection('general');  // Load default tab only
}

function setupTabs() {
  document.querySelectorAll('.tab-button').forEach(button => {
    button.addEventListener('click', async () => {
      const section = button.dataset.section;
      await loadSection(section);
      showSection(section);
    });
  });
}

async function loadSection(sectionId) {
  if (loadedSections.has(sectionId)) return;

  const container = document.getElementById(`section-${sectionId}`);
  container.innerHTML = '<div class="loading">Loading...</div>';

  const settings = await chrome.storage.sync.get(null);

  switch (sectionId) {
    case 'general':
      renderGeneralSettings(container, settings);
      break;
    case 'advanced':
      renderAdvancedSettings(container, settings);
      break;
    case 'export':
      // Lazy import heavy module
      const { renderExport } = await import('./export-section.js');
      renderExport(container, settings);
      break;
  }

  loadedSections.add(sectionId);
}

function showSection(sectionId) {
  document.querySelectorAll('.section').forEach(s => s.hidden = true);
  document.getElementById(`section-${sectionId}`).hidden = false;
}
```

**Benefits:**
- Faster initial page load
- Reduced memory for unused features
- Better user experience for complex options

Reference: [Dynamic Import MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/import)

### 7.3 Minimize Popup Bundle Size for Fast Startup

**Impact: MEDIUM (reduces popup open time by 100-500ms)**

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

### 7.4 Render Popup UI with Cached Data First

**Impact: MEDIUM (eliminates loading spinners, instant perceived load)**

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

---

## 8. API Usage Patterns

**Impact: LOW-MEDIUM**

Chrome API misuse including wrong timer APIs, sync vs async patterns, and inefficient query patterns causes subtle but cumulative performance degradation.

### 8.1 Avoid Redundant API Calls in Loops

**Impact: LOW-MEDIUM (reduces API overhead from N calls to 1)**

Calling Chrome APIs inside loops creates unnecessary overhead. Fetch data once before the loop, or batch operations where the API supports it.

**Incorrect (API call per iteration):**

```javascript
// content.js - Reads storage for each element
async function processElements() {
  const elements = document.querySelectorAll('.item');

  for (const element of elements) {
    // Storage read on EVERY element
    const { settings } = await chrome.storage.local.get('settings');
    applySettings(element, settings);
  }
}
// 100 elements = 100 storage reads
```

**Correct (single API call before loop):**

```javascript
// content.js - Read once, use many times
async function processElements() {
  const { settings } = await chrome.storage.local.get('settings');
  const elements = document.querySelectorAll('.item');

  for (const element of elements) {
    applySettings(element, settings);
  }
}
// 100 elements = 1 storage read
```

**Batch tab operations:**

```javascript
// background.js - Incorrect: update tabs one by one
async function muteAllTabs() {
  const tabs = await chrome.tabs.query({ audible: true });
  for (const tab of tabs) {
    await chrome.tabs.update(tab.id, { muted: true });  // Sequential
  }
}

// background.js - Correct: parallel batch update
async function muteAllTabs() {
  const tabs = await chrome.tabs.query({ audible: true });
  await Promise.all(
    tabs.map(tab => chrome.tabs.update(tab.id, { muted: true }))
  );
}
```

**Batch storage writes:**

```javascript
// Incorrect: separate writes
for (const item of items) {
  await chrome.storage.local.set({ [item.id]: item });
}

// Correct: single batched write
const updates = Object.fromEntries(items.map(i => [i.id, i]));
await chrome.storage.local.set(updates);
```

Reference: [chrome.storage API](https://developer.chrome.com/docs/extensions/reference/api/storage)

### 8.2 Handle Extension Context Invalidated Errors

**Impact: LOW-MEDIUM (prevents errors after extension update or reload)**

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

### 8.3 Query Tabs with Specific Filters

**Impact: LOW-MEDIUM (reduces processing from all tabs to relevant subset)**

Querying all tabs and filtering in JavaScript wastes resources. Use `chrome.tabs.query` filter options to let the browser return only relevant tabs.

**Incorrect (query all, filter in JS):**

```javascript
// background.js - Fetches all tabs, filters manually
async function getGitHubTabs() {
  const allTabs = await chrome.tabs.query({});  // All tabs
  return allTabs.filter(tab =>
    tab.url?.includes('github.com')
  );
}

async function getActiveTabs() {
  const allTabs = await chrome.tabs.query({});
  return allTabs.filter(tab => tab.active);  // Most are false
}
```

**Correct (let browser filter):**

```javascript
// background.js - Browser returns filtered results
async function getGitHubTabs() {
  return chrome.tabs.query({
    url: ['https://github.com/*', 'https://gist.github.com/*']
  });
}

async function getActiveTab() {
  const [tab] = await chrome.tabs.query({
    active: true,
    currentWindow: true
  });
  return tab;
}

async function getAudibleTabs() {
  return chrome.tabs.query({ audible: true });
}
```

**Useful query filters:**

```javascript
// Pinned tabs
const pinned = await chrome.tabs.query({ pinned: true });

// Tabs with unsaved content
const unsaved = await chrome.tabs.query({ autoDiscardable: false });

// Tabs in specific window
const windowTabs = await chrome.tabs.query({ windowId: someWindowId });

// Muted tabs
const muted = await chrome.tabs.query({ muted: true });

// Discarded (sleeping) tabs
const discarded = await chrome.tabs.query({ discarded: true });
```

**Note:** URL filtering requires `tabs` permission or appropriate host permissions.

Reference: [chrome.tabs.query](https://developer.chrome.com/docs/extensions/reference/api/tabs#method-query)

### 8.4 Respect Alarms API Minimum Period

**Impact: LOW-MEDIUM (prevents unexpected 1-minute rounding)**

The chrome.alarms API enforces a minimum period of 1 minute. Shorter values are silently rounded up, which can cause unexpected behavior if you're expecting sub-minute intervals.

**Incorrect (assumes short intervals work):**

```javascript
// background.js - Won't work as expected
chrome.runtime.onInstalled.addListener(() => {
  // These all become 1-minute alarms
  chrome.alarms.create('quick-poll', { periodInMinutes: 0.1 });  // Rounded to 1
  chrome.alarms.create('check', { delayInMinutes: 0.5 });        // Rounded to 1
  chrome.alarms.create('update', { periodInMinutes: 0.25 });     // Rounded to 1
});

// Expecting 10-second intervals, gets 60-second intervals
```

**Correct (design for minimum constraints):**

```javascript
// background.js - Use appropriate timing
chrome.runtime.onInstalled.addListener(() => {
  // Respect the 1-minute minimum
  chrome.alarms.create('sync-data', { periodInMinutes: 1 });

  // For less frequent operations, use longer periods
  chrome.alarms.create('daily-report', { periodInMinutes: 1440 });
});

// For sub-minute polling while SW is active, combine approaches
let pollingInterval = null;

function startActivePolling() {
  // Use setInterval while actively processing
  pollingInterval = setInterval(checkForUpdates, 5000);

  // Backup alarm ensures recovery if SW dies
  chrome.alarms.create('polling-backup', { periodInMinutes: 1 });
}

chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === 'polling-backup') {
    checkForUpdates();
    startActivePolling();  // Resume fast polling
  }
});
```

**When you need sub-minute updates:**
- Keep service worker active with ongoing operations
- Use setInterval while actively processing
- Accept 1-minute minimum for background wake-ups

Reference: [chrome.alarms API](https://developer.chrome.com/docs/extensions/reference/api/alarms)

### 8.5 Use Declarative Content API for Page Actions

**Impact: LOW-MEDIUM (reduces service worker wake-ups for icon state changes)**

Instead of waking the service worker on every navigation to check if your icon should be enabled, use `declarativeContent` to let the browser handle it natively.

**Incorrect (SW wakes on every navigation):**

```javascript
// background.js - Wakes SW on every tab update
chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (changeInfo.status === 'complete') {
    // Check every page load
    if (tab.url?.includes('github.com')) {
      chrome.action.enable(tabId);
      chrome.action.setIcon({ tabId, path: 'icon-active.png' });
    } else {
      chrome.action.disable(tabId);
    }
  }
});
```

**Correct (browser handles declaratively):**

```javascript
// background.js - Runs once at install, browser handles rest
chrome.runtime.onInstalled.addListener(() => {
  // Clear any existing rules
  chrome.declarativeContent.onPageChanged.removeRules(undefined, () => {
    // Add new rules
    chrome.declarativeContent.onPageChanged.addRules([{
      conditions: [
        new chrome.declarativeContent.PageStateMatcher({
          pageUrl: { hostSuffix: 'github.com' }
        }),
        new chrome.declarativeContent.PageStateMatcher({
          pageUrl: { hostSuffix: 'gitlab.com' }
        })
      ],
      actions: [
        new chrome.declarativeContent.ShowAction()
      ]
    }]);
  });
});
```

**Manifest configuration:**

```json
{
  "action": {
    "default_icon": "icon.png"
  },
  "permissions": ["declarativeContent"]
}
```

**Available conditions:**
- `pageUrl` - Match URL patterns
- `css` - Match pages with specific CSS selectors
- `isBookmarked` - Page is bookmarked

**Available actions:**
- `ShowAction` - Enable the action icon
- `SetIcon` - Change the icon
- `RequestContentScript` - Inject content script

Reference: [chrome.declarativeContent](https://developer.chrome.com/docs/extensions/reference/api/declarativeContent)

### 8.6 Use Promise-Based API Calls Over Callbacks

**Impact: LOW-MEDIUM (reduces callback nesting by 3-5 levels)**

Modern Chrome Extension APIs support promises. Promise-based calls are cleaner, support async/await, and make error handling easier with try/catch.

**Incorrect (callback hell):**

```javascript
// background.js - Nested callbacks, hard to read
chrome.tabs.query({ active: true }, (tabs) => {
  if (chrome.runtime.lastError) {
    console.error(chrome.runtime.lastError);
    return;
  }
  chrome.tabs.sendMessage(tabs[0].id, { type: 'get-data' }, (response) => {
    if (chrome.runtime.lastError) {
      console.error(chrome.runtime.lastError);
      return;
    }
    chrome.storage.local.set({ data: response }, () => {
      if (chrome.runtime.lastError) {
        console.error(chrome.runtime.lastError);
        return;
      }
      console.log('Data saved');
    });
  });
});
```

**Correct (async/await with promises):**

```javascript
// background.js - Clean, linear flow
async function processActiveTab() {
  try {
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    const response = await chrome.tabs.sendMessage(tab.id, { type: 'get-data' });
    await chrome.storage.local.set({ data: response });
    console.log('Data saved');
  } catch (error) {
    console.error('Operation failed:', error);
  }
}
```

**Promise.all for parallel operations:**

```javascript
// background.js - Parallel API calls
async function gatherExtensionData() {
  const [tabs, storage, bookmarks] = await Promise.all([
    chrome.tabs.query({}),
    chrome.storage.local.get(null),
    chrome.bookmarks.getTree()
  ]);

  return { tabs, storage, bookmarks };
}
```

**Note:** All Chrome Extension APIs in the `chrome.*` namespace support promises as of Manifest V3. The `browser.*` namespace (available since Chrome 144) also uses promises.

Reference: [Chrome Extension APIs](https://developer.chrome.com/docs/extensions/reference/api)

---

## References

1. [https://developer.chrome.com/docs/extensions/](https://developer.chrome.com/docs/extensions/)
2. [https://developer.chrome.com/docs/extensions/develop/migrate](https://developer.chrome.com/docs/extensions/develop/migrate)
3. [https://developer.chrome.com/docs/extensions/develop/concepts/service-workers/lifecycle](https://developer.chrome.com/docs/extensions/develop/concepts/service-workers/lifecycle)
4. [https://developer.chrome.com/docs/extensions/develop/concepts/content-scripts](https://developer.chrome.com/docs/extensions/develop/concepts/content-scripts)
5. [https://developer.chrome.com/docs/extensions/reference/api/storage](https://developer.chrome.com/docs/extensions/reference/api/storage)
6. [https://developer.chrome.com/docs/extensions/develop/concepts/messaging](https://developer.chrome.com/docs/extensions/develop/concepts/messaging)
7. [https://developer.chrome.com/blog/longer-esw-lifetimes](https://developer.chrome.com/blog/longer-esw-lifetimes)
8. [https://developer.chrome.com/blog/Offscreen-Documents-in-Manifest-v3](https://developer.chrome.com/blog/Offscreen-Documents-in-Manifest-v3)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |