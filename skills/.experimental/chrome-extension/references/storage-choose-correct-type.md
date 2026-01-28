---
title: Choose the Correct Storage Type for Your Use Case
impact: HIGH
impactDescription: prevents quota errors and sync throttling
tags: storage, local, sync, session, quota, performance
---

## Choose the Correct Storage Type for Your Use Case

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
