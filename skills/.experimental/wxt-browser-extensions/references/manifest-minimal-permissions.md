---
title: Request Minimal Required Permissions
impact: MEDIUM
impactDescription: reduces install friction by 30-50% fewer permission warnings
tags: manifest, permissions, security, minimal
---

## Request Minimal Required Permissions

Request only the permissions your extension actually needs. Excessive permissions trigger Chrome Web Store review delays and reduce user trust.

**Incorrect (over-permissioned):**

```typescript
// wxt.config.ts
export default defineConfig({
  manifest: {
    permissions: [
      'tabs',
      'storage',
      'activeTab',
      'scripting',
      'webRequest',
      'webNavigation',
      'cookies',
      'history',
      'bookmarks', // Never used
      'downloads', // Never used
      '<all_urls>' // Too broad
    ]
  }
})
```

**Correct (minimal permissions):**

```typescript
// wxt.config.ts
export default defineConfig({
  manifest: {
    permissions: [
      'storage', // For user preferences
      'activeTab' // For current tab access on user action
    ],
    optional_permissions: [
      'tabs', // Request when user needs tab listing feature
      'bookmarks' // Request when user enables bookmark feature
    ],
    host_permissions: [
      'https://api.example.com/*' // Only your API domain
    ],
    optional_host_permissions: [
      'https://*/*' // Request broad access only when needed
    ]
  }
})
```

**Permission alternatives:**
| Instead of | Use | Why |
|------------|-----|-----|
| `<all_urls>` | `activeTab` | Only accesses current tab on user action |
| `tabs` | `activeTab` | Unless you need to list/query tabs |
| `host_permissions: [*]` | Specific domains | Limits data access scope |

Reference: [Chrome Permissions Best Practices](https://developer.chrome.com/docs/extensions/develop/concepts/permission-warnings)
