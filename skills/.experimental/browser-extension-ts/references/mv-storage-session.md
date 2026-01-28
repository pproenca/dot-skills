---
title: Session storage for temporary state
impact: HIGH
impactDescription: chrome.storage.session provides in-memory storage that survives service worker restarts
tags: manifest-v3, storage, state-management
---

# Session storage for temporary state

Use `chrome.storage.session` for temporary state that should survive service worker restarts but not persist across browser sessions.

## Storage Types Comparison

| Storage | Persists | Service Worker | Sync | Quota |
|---------|----------|----------------|------|-------|
| `local` | Yes | Survives | No | 10 MB |
| `sync` | Yes | Survives | Yes | 100 KB |
| `session` | No* | Survives | No | 10 MB |
| JS variables | No | Lost | No | RAM |

*Session storage is cleared when browser closes, but survives service worker termination.

## Incorrect

```typescript
// Lost when service worker terminates
let processingTabs = new Set<number>();
let pendingRequests = new Map<string, Promise<unknown>>();

// Overkill - persists forever
await chrome.storage.local.set({
    temporaryCache: data,  // Will accumulate garbage
});
```

## Correct

```typescript
// manifest.json
{
    "permissions": ["storage"
}

// Session storage for temporary state
class SessionState {
    static async setProcessingTabs(tabs: number[]): Promise<void> {
        await chrome.storage.session.set({ processingTabs: tabs });
    }

    static async getProcessingTabs(): Promise<number[]> {
        const { processingTabs } = await chrome.storage.session.get('processingTabs');
        return processingTabs ?? [];
    }

    static async addProcessingTab(tabId: number): Promise<void> {
        const tabs = await this.getProcessingTabs();
        if (!tabs.includes(tabId)) {
            await this.setProcessingTabs([...tabs, tabId]);
        }
    }

    static async removeProcessingTab(tabId: number): Promise<void> {
        const tabs = await this.getProcessingTabs();
        await this.setProcessingTabs(tabs.filter((id) => id !== tabId));
    }
}

// Use case: Track active operations
async function startProcessing(tabId: number): Promise<void> {
    await SessionState.addProcessingTab(tabId);
    try {
        await processTab(tabId);
    } finally {
        await SessionState.removeProcessingTab(tabId);
    }
}
```

## Session vs Local Decision

```typescript
// Session: Temporary state, caches, active operations
interface SessionData {
    processingTabs: number[];
    themeCache: Record<string, Theme>;
    pendingMessages: Message[];
    lastActiveTab: number;
}

// Local: User settings, preferences, permanent data
interface LocalData {
    settings: UserSettings;
    siteList: SiteListEntry[];
    customThemes: CustomTheme[];
}

// Pattern: Session cache with local fallback
async function getTheme(host: string): Promise<Theme> {
    // Check session cache first
    const { themeCache = {} } = await chrome.storage.session.get('themeCache');
    if (themeCache[host]) {
        return themeCache[host];
    }

    // Compute theme
    const theme = await computeTheme(host);

    // Cache in session storage
    themeCache[host] = theme;
    await chrome.storage.session.set({ themeCache });

    return theme;
}
```

## Access from Content Scripts

```typescript
// manifest.json - enable session access from content scripts
{
    "permissions": ["storage"],
    "storage": {
        "session": {
            "accessible_from_content_scripts": true
        }
    }
}

// Content script can now use
const { tempData } = await chrome.storage.session.get('tempData');
```

## Why This Matters

- **No memory leaks**: Variables in service worker are lost on termination
- **Clean slate**: Session storage auto-clears when browser closes
- **Efficient**: Faster than chrome.storage.local for frequently accessed data
- **Shared state**: Available to both service worker and content scripts
