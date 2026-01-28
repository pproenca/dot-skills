---
title: Request Minimal Permissions
impact: CRITICAL
impactDescription: 40-60% higher install conversion rate
tags: comp, permissions, trust, installation, privacy
---

## Request Minimal Permissions

Request only the permissions your extension absolutely needs. Excessive permissions trigger browser warnings that scare users away during installation.

**Incorrect (over-permissioned manifest):**

```json
{
  "name": "Reading Time Calculator",
  "permissions": [
    "tabs",
    "activeTab",
    "storage",
    "history",
    "bookmarks",
    "webRequest",
    "<all_urls>"
  ],
  "host_permissions": [
    "*://*/*"
  ]
}
// Warning: "Read and change all your data on all websites"
// User sees scary warning → abandons installation
```

**Correct (minimal required permissions):**

```json
{
  "name": "Reading Time Calculator",
  "permissions": [
    "activeTab"
  ]
}
// Warning: "Read and change data on the site you're viewing"
// Minimal warning → higher trust → more installations
```

**Permission reduction strategies:**

| Instead of... | Use... | Benefit |
|---------------|--------|---------|
| `tabs` | `activeTab` | No warning about reading all tabs |
| `<all_urls>` | Specific domains | Scoped access warning |
| `webRequest` | `declarativeNetRequest` | Modern, safer API |
| Upfront `host_permissions` | Optional permissions | Request when needed |

**Using optional permissions:**

```typescript
// Request permission only when user needs the feature
document.getElementById('advanced-feature').addEventListener('click', async () => {
  const granted = await chrome.permissions.request({
    permissions: ['history'],
    origins: ['https://example.com/*']
  })
  if (granted) {
    enableAdvancedFeature()
  }
})
```

Reference: [Declare Permissions](https://developer.chrome.com/docs/extensions/develop/concepts/declare-permissions)
