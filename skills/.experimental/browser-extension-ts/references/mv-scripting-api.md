---
title: Scripting API for dynamic injection
impact: CRITICAL
impactDescription: MV3 replaces tabs.executeScript with the new scripting API
tags: manifest-v3, scripting, content-scripts
---

# Scripting API for dynamic injection

Use `chrome.scripting` API instead of `chrome.tabs.executeScript` for dynamic script injection in MV3. The new API provides better security and more features.

## Manifest Configuration

```json
{
    "manifest_version": 3,
    "permissions": ["scripting", "activeTab"],
    "host_permissions": ["<all_urls>"
}
```

## Incorrect (MV2)

```typescript
// MV2 pattern - deprecated in MV3
chrome.tabs.executeScript(tabId, {
    code: 'document.body.style.background = "black"',
});

chrome.tabs.executeScript(tabId, {
    file: 'content-script.js',
});

chrome.tabs.insertCSS(tabId, {
    css: 'body { filter: invert(1); }',
});
```

## Correct (MV3)

```typescript
// Execute inline function
await chrome.scripting.executeScript({
    target: { tabId },
    func: () => {
        document.body.style.background = 'black';
    },
});

// Execute function with arguments
await chrome.scripting.executeScript({
    target: { tabId },
    func: (color: string) => {
        document.body.style.background = color;
    },
    args: ['#181a1b'],
});

// Execute script file
await chrome.scripting.executeScript({
    target: { tabId },
    files: ['content-script.js'],
});

// Inject CSS
await chrome.scripting.insertCSS({
    target: { tabId },
    css: 'body { filter: invert(1); }',
});

// Remove CSS (new in MV3!)
await chrome.scripting.removeCSS({
    target: { tabId },
    css: 'body { filter: invert(1); }',
});
```

## Registered Content Scripts

```typescript
// Register content scripts programmatically
await chrome.scripting.registerContentScripts([{
    id: 'dark-theme-script',
    matches: ['<all_urls>'],
    excludeMatches: ['*://example.com/*'],
    js: ['inject/index.js'],
    css: ['inject/style.css'],
    runAt: 'document_start',
    world: 'ISOLATED',  // or 'MAIN' for page context
}]);

// Update registered script
await chrome.scripting.updateContentScripts([{
    id: 'dark-theme-script',
    excludeMatches: ['*://example.com/*', '*://another.com/*'],
}]);

// Unregister
await chrome.scripting.unregisterContentScripts({
    ids: ['dark-theme-script'],
});

// Get all registered scripts
const scripts = await chrome.scripting.getRegisteredContentScripts();
```

## Target Options

```typescript
// Single tab
await chrome.scripting.executeScript({
    target: { tabId: 123 },
    func: myFunction,
});

// Multiple tabs
await chrome.scripting.executeScript({
    target: { tabIds: [123, 456, 789] },
    func: myFunction,
});

// Specific frames
await chrome.scripting.executeScript({
    target: { tabId: 123, frameIds: [0] },  // Main frame only
    func: myFunction,
});

// All frames
await chrome.scripting.executeScript({
    target: { tabId: 123, allFrames: true },
    func: myFunction,
});
```

## Error Handling

```typescript
async function injectTheme(tabId: number, css: string): Promise<boolean> {
    try {
        await chrome.scripting.insertCSS({
            target: { tabId },
            css,
        });
        return true;
    } catch (error) {
        // Common errors:
        // - "Cannot access a chrome:// URL"
        // - "No tab with id: X"
        // - "Missing host permission"
        logWarn(`Failed to inject CSS to tab ${tabId}:`, error);
        return false;
    }
}
```

## Why This Matters

- **Security**: No arbitrary code strings, only functions/files
- **Type safety**: Function parameters are typed
- **CSS removal**: Can cleanly remove injected CSS
- **Programmatic registration**: Dynamic content script management
- **Frame targeting**: Fine-grained control over injection targets
