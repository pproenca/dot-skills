---
title: Request Minimal Required Permissions
impact: MEDIUM-HIGH
impactDescription: reduces permission warnings, higher install rates
tags: net, permissions, host-permissions, security, approval
---

## Request Minimal Required Permissions

Over-requesting permissions is the #1 rejection reason in Chrome Web Store review. Request only what your extension actually needs, and prefer `activeTab` over broad host permissions.

**Incorrect (over-requesting):**

```json
{
  "permissions": [
    "tabs",
    "history",
    "bookmarks",
    "storage",
    "webRequest",
    "webRequestBlocking"
  ],
  "host_permissions": [
    "<all_urls>"
  ]
}
```

**Correct (minimal permissions):**

```json
{
  "permissions": [
    "activeTab",
    "storage"
  ]
}
```

**Use optional_permissions for advanced features:**

```json
{
  "permissions": ["storage"],
  "optional_permissions": ["tabs", "history"],
  "optional_host_permissions": ["https://api.example.com/*"]
}
```

```javascript
// popup.js - Request when user enables feature
async function enableHistoryFeature() {
  const granted = await chrome.permissions.request({
    permissions: ['history']
  });

  if (granted) {
    initializeHistoryFeature();
  }
}
```

**Permission alternatives:**

| Instead of | Use |
|-----------|-----|
| `<all_urls>` | `activeTab` + programmatic injection |
| `tabs` (for URL access) | `activeTab` |
| `webRequest` + `webRequestBlocking` | `declarativeNetRequest` |
| Broad host permissions | Specific domains or `optional_host_permissions` |

**Permissions that show warnings:**
- Host permissions show "Read and change your data on..."
- `history`, `bookmarks`, `downloads` show specific warnings
- `activeTab` shows NO warning

Reference: [Declare Permissions](https://developer.chrome.com/docs/extensions/develop/concepts/declare-permissions)
