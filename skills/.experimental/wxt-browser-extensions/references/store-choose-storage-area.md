---
title: Choose the Correct Storage Area
impact: HIGH
impactDescription: prevents quota errors and sync failures from wrong area
tags: store, local, sync, session, area
---

## Choose the Correct Storage Area

WXT supports three storage areas with different characteristics. Choose based on persistence needs, sync requirements, and data size.

**Incorrect (wrong area for use case):**

```typescript
// Using sync for large data - exceeds quota
const pageCache = storage.defineItem<Record<string, string>>('sync:pageCache', {
  fallback: {}
})
// sync has 8KB per-item limit, 100KB total

// Using local for session-only data - wastes disk
const temporaryState = storage.defineItem<TemporaryState>('local:temp', {
  fallback: {}
})
// Persists across browser restarts unnecessarily
```

**Correct (appropriate area for each use case):**

```typescript
// Session: ephemeral data, cleared on browser restart
// Good for: active tab state, temporary flags, in-progress work
const activeTabData = storage.defineItem<TabData>('session:activeTab', {
  fallback: null
})

// Local: persistent data, not synced
// Good for: caches, large data, device-specific settings
const pageCache = storage.defineItem<Record<string, CachedPage>>('local:cache', {
  fallback: {}
})

// Sync: persistent data, synced across devices
// Good for: user preferences, small settings (8KB limit per item)
const userPreferences = storage.defineItem<UserPreferences>('sync:preferences', {
  fallback: { theme: 'light', language: 'en' }
})
```

**Storage area reference:**
| Area | Persistence | Synced | Quota |
|------|-------------|--------|-------|
| `session:` | Browser session | No | 10MB |
| `local:` | Permanent | No | 10MB |
| `sync:` | Permanent | Yes | 100KB total, 8KB/item |

Reference: [Chrome Storage Areas](https://developer.chrome.com/docs/extensions/reference/api/storage)
