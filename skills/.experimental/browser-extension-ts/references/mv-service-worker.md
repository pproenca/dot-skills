---
title: Service worker architecture
impact: CRITICAL
impactDescription: MV3 replaces persistent background pages with ephemeral service workers
tags: manifest-v3, service-worker, architecture
---

# Service worker architecture

In Manifest V3, background scripts become service workers that can be terminated at any time. Design for statelessness and persistence.

## Key Differences from MV2

| Aspect | MV2 Background Page | MV3 Service Worker |
|--------|--------------------|--------------------|
| Lifetime | Persistent | Ephemeral (max ~5 min inactive) |
| DOM access | Yes | No |
| State | In-memory variables | Must persist to storage |
| setTimeout | Works indefinitely | Lost on termination |
| XMLHttpRequest | Available | Use fetch() only |

## Incorrect

```typescript
// MV2 pattern - global state is lost
let userSettings: UserSettings;
let themeCache: Map<string, Theme> = new Map();

async function init(): Promise<void> {
    userSettings = await loadSettings();
}

// Long timeout - won't work
setTimeout(() => {
    checkForUpdates();
}, 60 * 60 * 1000);  // 1 hour - service worker will be dead
```

## Correct

```typescript
// MV3 pattern - reload state on every wake
class Extension {
    private static settings: UserSettings | null = null;

    static async getSettings(): Promise<UserSettings> {
        if (!Extension.settings) {
            Extension.settings = await chrome.storage.local.get('settings')
                .then((r) => r.settings ?? DEFAULT_SETTINGS);
        }
        return Extension.settings;
    }

    static async updateSettings(partial: Partial<UserSettings>): Promise<void> {
        const current = await Extension.getSettings();
        const updated = { ...current, ...partial };
        await chrome.storage.local.set({ settings: updated });
        Extension.settings = updated;
    }
}

// Use alarms instead of setTimeout for long delays
chrome.alarms.create('check-updates', { periodInMinutes: 60 });

chrome.alarms.onAlarm.addListener((alarm) => {
    if (alarm.name === 'check-updates') {
        checkForUpdates();
    }
});

// Keep service worker alive during critical operations
async function criticalOperation(): Promise<void> {
    // Use offscreen document for long-running tasks
    await chrome.offscreen.createDocument({
        url: 'offscreen.html',
        reasons: [chrome.offscreen.Reason.WORKERS],
        justification: 'Process large dataset',
    });
}
```

## State Management Pattern

```typescript
// Service worker entry point
chrome.runtime.onInstalled.addListener(async () => {
    await initializeDefaults();
});

chrome.runtime.onStartup.addListener(async () => {
    await reloadState();
});

// Always reload state when handling messages
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    handleMessage(message, sender)
        .then(sendResponse)
        .catch((err) => sendResponse({ error: err.message }));
    return true;  // Keep channel open for async response
});

async function handleMessage(
    message: Message,
    sender: chrome.runtime.MessageSender
): Promise<unknown> {
    // Reload state on every message - can't assume previous state exists
    const settings = await Extension.getSettings();

    switch (message.type) {
        case MessageTypeUItoBG.GET_DATA:
            return Extension.collect();
        // ...
    }
}
```

## Why This Matters

- **Memory efficiency**: Chrome can reclaim memory from inactive extensions
- **Battery life**: Background work doesn't drain battery
- **Reliability**: Extensions must handle being terminated/restarted
- **MV3 requirement**: No choice - persistent background pages are gone
