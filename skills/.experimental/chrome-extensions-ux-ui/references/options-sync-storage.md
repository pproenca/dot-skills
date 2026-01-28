---
title: Sync Settings Across Devices
impact: MEDIUM
impactDescription: seamless experience across user's computers
tags: options, sync, storage, cross-device, persistence
---

## Sync Settings Across Devices

Use `chrome.storage.sync` for user preferences so settings follow users across their devices. Local-only storage forces users to reconfigure on each computer.

**Incorrect (settings don't sync):**

```typescript
// options.js - Settings only on this device
async function saveSettings(settings) {
  await chrome.storage.local.set({ settings })
}

async function loadSettings() {
  const { settings } = await chrome.storage.local.get('settings')
  return settings || defaultSettings
}
// User configures on laptop → sits at desktop → must reconfigure
```

**Correct (settings sync across devices):**

```typescript
// options.js - Settings follow the user
async function saveSettings(settings) {
  await chrome.storage.sync.set({ settings })
}

async function loadSettings() {
  const { settings } = await chrome.storage.sync.get('settings')
  return settings || defaultSettings
}
// User configures on laptop → sits at desktop → same settings
```

**Handling sync quota limits:**

```typescript
// options.js - Sync has storage limits (102,400 bytes total)
const SYNC_QUOTA = chrome.storage.sync.QUOTA_BYTES // 102400
const SYNC_QUOTA_PER_ITEM = chrome.storage.sync.QUOTA_BYTES_PER_ITEM // 8192

async function saveWithFallback(key, data) {
  const serialized = JSON.stringify(data)

  if (serialized.length > SYNC_QUOTA_PER_ITEM) {
    // Too large for sync - use local storage
    console.warn(`${key} too large for sync, using local storage`)
    await chrome.storage.local.set({ [key]: data })
    return
  }

  try {
    await chrome.storage.sync.set({ [key]: data })
  } catch (error) {
    if (error.message.includes('QUOTA_BYTES')) {
      // Quota exceeded - fall back to local
      console.warn('Sync quota exceeded, using local storage')
      await chrome.storage.local.set({ [key]: data })
    } else {
      throw error
    }
  }
}

// Separate what should sync vs. stay local
const storageStrategy = {
  // Small user preferences - SYNC
  preferences: 'sync',    // theme, language, notifications
  shortcuts: 'sync',      // keyboard shortcuts

  // Large or device-specific data - LOCAL
  cache: 'local',         // cached API responses
  largeDatasets: 'local', // user's full history
  deviceSettings: 'local' // window positions, local paths
}

async function saveSetting(category, key, value) {
  const storage = storageStrategy[category] === 'sync'
    ? chrome.storage.sync
    : chrome.storage.local

  await storage.set({ [`${category}.${key}`]: value })
}
```

**Sync storage limits:**

| Limit | Value |
|-------|-------|
| Total storage | 102,400 bytes |
| Per item | 8,192 bytes |
| Max items | 512 |
| Write operations/hour | 1,800 |

Reference: [Storage API](https://developer.chrome.com/docs/extensions/reference/api/storage)
