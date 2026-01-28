---
title: Cross-browser compatibility
impact: HIGH
impactDescription: Extensions should work on Chrome, Firefox, and Edge with minimal changes
tags: manifest-v3, cross-browser, compatibility
---

# Cross-browser compatibility

Design extensions to work across Chrome, Firefox, and Edge. Use feature detection and browser-specific flags for API differences.

## Browser Detection

```typescript
// Reliable browser detection
const isChromium = navigator.userAgent.includes('Chrome');
const isFirefox = navigator.userAgent.includes('Firefox');
const isEdge = navigator.userAgent.includes('Edg/');

// Or use global namespace check
const isFirefoxAPI = typeof browser !== 'undefined';
const isChromeAPI = typeof chrome !== 'undefined' && !isFirefoxAPI;

// Build-time flags (via bundler)
declare const __CHROMIUM_MV2__: boolean;
declare const __CHROMIUM_MV3__: boolean;
declare const __FIREFOX_MV2__: boolean;
```

## Manifest Differences

```json
// Chrome MV3 manifest.json
{
    "manifest_version": 3,
    "background": {
        "service_worker": "background.js",
        "type": "module"
    },
    "action": { "default_popup": "popup.html" }
}

// Firefox MV2 manifest.json
{
    "manifest_version": 2,
    "background": {
        "scripts": ["background.js"],
        "persistent": false
    },
    "browser_action": { "default_popup": "popup.html" },
    "browser_specific_settings": {
        "gecko": { "id": "addon@example.com" }
    }
}
```

## API Abstraction Layer

```typescript
// Unified browser API wrapper
const browserAPI = (() => {
    const api = typeof browser !== 'undefined' ? browser : chrome;

    return {
        // Promisify callback-based APIs for Chrome
        tabs: {
            query: (query: chrome.tabs.QueryInfo): Promise<chrome.tabs.Tab[]> => {
                if (isFirefoxAPI) {
                    return browser.tabs.query(query);
                }
                return chrome.tabs.query(query);
            },
            sendMessage: (tabId: number, message: unknown): Promise<unknown> => {
                if (isFirefoxAPI) {
                    return browser.tabs.sendMessage(tabId, message);
                }
                return chrome.tabs.sendMessage(tabId, message);
            },
        },
        storage: {
            local: {
                get: (keys: string | string[]): Promise<Record<string, unknown>> => {
                    return api.storage.local.get(keys);
                },
                set: (items: Record<string, unknown>): Promise<void> => {
                    return api.storage.local.set(items);
                },
            },
        },
    };
})();

// Usage
const tabs = await browserAPI.tabs.query({ active: true });
```

## Feature Detection Pattern

```typescript
// Scripting API (MV3 only, Chrome)
async function injectScript(tabId: number, script: string): Promise<void> {
    if (chrome.scripting) {
        // MV3
        await chrome.scripting.executeScript({
            target: { tabId },
            files: [script],
        });
    } else {
        // MV2 fallback
        await new Promise<void>((resolve, reject) => {
            chrome.tabs.executeScript(tabId, { file: script }, () => {
                if (chrome.runtime.lastError) {
                    reject(new Error(chrome.runtime.lastError.message));
                } else {
                    resolve();
                }
            });
        });
    }
}

// Session storage (MV3 only)
async function getSessionData<T>(key: string, defaultValue: T): Promise<T> {
    if (chrome.storage.session) {
        const result = await chrome.storage.session.get(key);
        return result[key] ?? defaultValue;
    }
    // Fallback to in-memory cache for MV2
    return memoryCache.get(key) ?? defaultValue;
}
```

## Browser-Specific Code Paths

```typescript
// Firefox-specific APIs
function getFirefoxContainers(): Promise<ContextualIdentity[]> {
    if (!isFirefox) {
        return Promise.resolve([]);
    }
    return browser.contextualIdentities.query({});
}

// Chrome-specific APIs
function useOffscreenDocument(): boolean {
    return isChromium && !!chrome.offscreen;
}

// Assert browser requirement
function assertFirefox(message: string): void {
    if (!isFirefox && __DEV__) {
        console.warn(`Firefox-specific function: ${message}`);
    }
}
```

## Why This Matters

- **Wider audience**: Support Firefox and Edge users
- **Firefox Add-ons store**: Additional distribution channel
- **Feature parity**: Users expect same features across browsers
- **Graceful fallback**: Extensions work with reduced features if APIs unavailable
