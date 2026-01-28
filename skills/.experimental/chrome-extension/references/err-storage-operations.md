---
title: Storage operation error handling
impact: HIGH
impactDescription: Storage APIs can fail silently; proper handling prevents extension crashes
tags: error-handling, storage, browser-extension
---

# Storage operation error handling

Wrap storage operations in try-catch blocks. Storage can be unavailable in private browsing, when quota is exceeded, or when the user has disabled storage.

## Incorrect

```typescript
// Unprotected storage access
sessionStorage.setItem('theme', JSON.stringify(theme));
const settings = JSON.parse(localStorage.getItem('settings') || '{}');

// Unprotected chrome.storage
const result = await chrome.storage.local.get('settings');
```

## Correct

```typescript
// Session/local storage with try-catch
function saveToSession(key: string, value: unknown): void {
    try {
        sessionStorage.setItem(key, JSON.stringify(value));
    } catch (err) {
        // Storage unavailable (private browsing, quota exceeded)
        logWarn('Session storage unavailable:', err);
    }
}

function loadFromSession<T>(key: string): T | null {
    try {
        const raw = sessionStorage.getItem(key);
        return raw ? JSON.parse(raw) : null;
    } catch (err) {
        return null;
    }
}

// Chrome storage with error check
async function saveSettings(settings: UserSettings): Promise<void> {
    await chrome.storage.local.set({ settings });

    if (chrome.runtime.lastError) {
        logWarn('Failed to save settings:', chrome.runtime.lastError);
    }
}

// Chrome storage sync with fallback
async function loadSettings(): Promise<UserSettings> {
    try {
        const result = await chrome.storage.sync.get('settings');
        if (chrome.runtime.lastError) {
            throw new Error(chrome.runtime.lastError.message);
        }
        return result.settings ?? DEFAULT_SETTINGS;
    } catch (err) {
        // Fall back to local storage if sync fails
        const local = await chrome.storage.local.get('settings');
        return local.settings ?? DEFAULT_SETTINGS;
    }
}
```

## Storage Wrapper Pattern

```typescript
class StorageWrapper {
    static async get<T>(key: string, defaultValue: T): Promise<T> {
        try {
            const result = await chrome.storage.local.get(key);
            return result[key] ?? defaultValue;
        } catch (err) {
            logWarn(`Storage get failed for "${key}":`, err);
            return defaultValue;
        }
    }

    static async set(key: string, value: unknown): Promise<boolean> {
        try {
            await chrome.storage.local.set({ [key]: value });
            return !chrome.runtime.lastError;
        } catch (err) {
            logWarn(`Storage set failed for "${key}":`, err);
            return false;
        }
    }
}
```

## Why This Matters

- **Private browsing**: Storage APIs throw in incognito mode in some browsers
- **Quota limits**: Storage can fill up, especially for themes/large data
- **User settings**: Users can disable storage in browser settings
- **Graceful degradation**: Extension should work even if storage fails
