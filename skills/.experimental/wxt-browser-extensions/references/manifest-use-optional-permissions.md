---
title: Use Optional Permissions for Progressive Access
impact: MEDIUM
impactDescription: 2-3× higher install conversion from fewer warnings
tags: manifest, optional-permissions, progressive, ux
---

## Use Optional Permissions for Progressive Access

Use optional permissions to reduce install-time warnings. Request additional permissions only when the user needs the associated feature.

**Incorrect (all permissions at install):**

```typescript
// wxt.config.ts
export default defineConfig({
  manifest: {
    permissions: ['tabs', 'history', 'bookmarks', 'downloads'],
    host_permissions: ['<all_urls>']
  }
})
// User sees scary warnings at install, may abandon
```

**Correct (core permissions only, optional for features):**

```typescript
// wxt.config.ts
export default defineConfig({
  manifest: {
    permissions: ['storage'],
    optional_permissions: ['tabs', 'history', 'bookmarks', 'downloads'],
    optional_host_permissions: ['<all_urls>']
  }
})

// options.ts - request when user enables feature
async function enableBookmarkSync() {
  const granted = await browser.permissions.request({
    permissions: ['bookmarks']
  })

  if (granted) {
    await settings.setValue({ ...currentSettings, bookmarkSync: true })
    startBookmarkSync()
  } else {
    showPermissionDeniedMessage()
  }
}

// Check permission before using feature
async function getBookmarks() {
  const hasPermission = await browser.permissions.contains({
    permissions: ['bookmarks']
  })

  if (!hasPermission) {
    showEnableBookmarkSyncPrompt()
    return []
  }

  return browser.bookmarks.getTree()
}
```

Reference: [Chrome Optional Permissions](https://developer.chrome.com/docs/extensions/reference/api/permissions)
