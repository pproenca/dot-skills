---
title: Extension context invalidation handling
impact: HIGH
impactDescription: Content scripts survive extension updates but lose connection to background
tags: error-handling, browser-extension, content-scripts
---

# Extension context invalidation handling

Handle "Extension context invalidated" errors gracefully in content scripts. This error occurs when the extension updates or reloads while a content script is still running on a page.

## The Problem

When a browser extension updates:
1. The background script restarts immediately
2. Content scripts already injected in tabs continue running
3. Those content scripts can no longer communicate with the extension
4. Any `chrome.runtime` call throws "Extension context invalidated"

## Incorrect

```typescript
// Unprotected messaging - will throw after extension update
function notifyBackground(data: unknown): void {
    chrome.runtime.sendMessage({ type: 'update', data });
}

// Event listener keeps running after context invalidated
chrome.runtime.onMessage.addListener((message) => {
    handleMessage(message);  // Will fail
});
```

## Correct

```typescript
let isContextValid = true;

function checkContext(): boolean {
    try {
        // Simple check - will throw if context invalid
        void chrome.runtime.id;
        return true;
    } catch {
        return false;
    }
}

function sendMessageSafe(message: Message): void {
    if (!isContextValid) return;

    try {
        chrome.runtime.sendMessage(message);
    } catch (error) {
        if (error.message === 'Extension context invalidated.') {
            handleContextInvalidation();
        } else {
            throw error;
        }
    }
}

function handleContextInvalidation(): void {
    isContextValid = false;

    // Clean up injected content
    removeInjectedStyles();
    removeInjectedElements();

    // Remove event listeners
    document.removeEventListener('visibilitychange', onVisibilityChange);

    // Clear any intervals/timeouts
    clearAllTimers();

    // Optionally notify user
    console.info('Dark Reader: Extension was updated. Please refresh the page.');
}

// Wrap message listener
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (!isContextValid) {
        return false;
    }

    try {
        return handleMessage(message, sender, sendResponse);
    } catch (error) {
        if (error.message === 'Extension context invalidated.') {
            handleContextInvalidation();
            return false;
        }
        throw error;
    }
});
```

## Port-based Communication Pattern

```typescript
// Using ports for more reliable communication
let port: chrome.runtime.Port | null = null;

function connectToBackground(): void {
    try {
        port = chrome.runtime.connect({ name: 'content-script' });

        port.onMessage.addListener(onMessage);

        port.onDisconnect.addListener(() => {
            if (chrome.runtime.lastError) {
                handleContextInvalidation();
            } else {
                // Normal disconnect - try to reconnect
                setTimeout(connectToBackground, 1000);
            }
        });
    } catch (error) {
        handleContextInvalidation();
    }
}

function sendMessage(message: Message): void {
    if (!port || !isContextValid) return;

    try {
        port.postMessage(message);
    } catch {
        handleContextInvalidation();
    }
}
```

## Why This Matters

- **User experience**: Clean degradation instead of broken functionality
- **Resource cleanup**: Prevent memory leaks from orphaned listeners
- **Error prevention**: Avoid console spam from failed API calls
- **Extension updates**: Users don't need to manually refresh all tabs
