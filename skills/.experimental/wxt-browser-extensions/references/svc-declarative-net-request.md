---
title: Use Declarative Net Request for Blocking
impact: CRITICAL
impactDescription: 10× faster than webRequest, works when service worker inactive
tags: svc, declarative-net-request, blocking, mv3
---

## Use Declarative Net Request for Blocking

Declarative Net Request rules execute in the browser's network stack, not in JavaScript. They're faster than webRequest and work even when the service worker is inactive.

**Incorrect (webRequest blocking, deprecated in MV3):**

```typescript
export default defineBackground(() => {
  browser.webRequest.onBeforeRequest.addListener(
    (details) => {
      if (details.url.includes('tracking.js')) {
        return { cancel: true }
      }
    },
    { urls: ['<all_urls>'] },
    ['blocking'] // Not available in MV3
  )
})
```

**Correct (declarative net request rules):**

```typescript
// wxt.config.ts
export default defineConfig({
  manifest: {
    permissions: ['declarativeNetRequest'],
    declarative_net_request: {
      rule_resources: [{
        id: 'blocking_rules',
        enabled: true,
        path: 'rules/blocking.json'
      }]
    }
  }
})
```

```json
// public/rules/blocking.json
[
  {
    "id": 1,
    "priority": 1,
    "action": { "type": "block" },
    "condition": {
      "urlFilter": "tracking.js",
      "resourceTypes": ["script"]
    }
  }
]
```

**Alternative (dynamic rules from background):**

```typescript
export default defineBackground(() => {
  browser.runtime.onInstalled.addListener(async () => {
    await browser.declarativeNetRequest.updateDynamicRules({
      removeRuleIds: [1],
      addRules: [{
        id: 1,
        priority: 1,
        action: { type: 'block' },
        condition: {
          urlFilter: 'tracking.js',
          resourceTypes: ['script']
        }
      }]
    })
  })
})
```

Reference: [Chrome Declarative Net Request](https://developer.chrome.com/docs/extensions/reference/api/declarativeNetRequest)
