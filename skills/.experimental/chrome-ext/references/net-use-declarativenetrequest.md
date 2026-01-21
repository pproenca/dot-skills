---
title: Use declarativeNetRequest Instead of webRequest for Blocking
impact: MEDIUM-HIGH
impactDescription: eliminates request interception latency, lower memory usage
tags: net, declarativeNetRequest, webRequest, blocking, performance
---

## Use declarativeNetRequest Instead of webRequest for Blocking

The `webRequest` API intercepts every request in JavaScript, adding latency. `declarativeNetRequest` uses browser-native rule matching that's significantly faster and doesn't require a persistent background page.

**Incorrect (JavaScript intercepts every request):**

```javascript
// background.js - Runs JS for every network request
chrome.webRequest.onBeforeRequest.addListener(
  (details) => {
    if (details.url.includes('ads.example.com')) {
      return { cancel: true };
    }
    if (details.url.includes('tracker.example.com')) {
      return { cancel: true };
    }
  },
  { urls: ['<all_urls>'] },
  ['blocking']
);
// Every request wakes SW, runs JS, adds latency
```

**Correct (browser-native rule matching):**

```json
{
  "permissions": ["declarativeNetRequest"],
  "declarative_net_request": {
    "rule_resources": [{
      "id": "ruleset_1",
      "enabled": true,
      "path": "rules.json"
    }]
  }
}
```

```json
[
  {
    "id": 1,
    "priority": 1,
    "action": { "type": "block" },
    "condition": {
      "urlFilter": "ads.example.com",
      "resourceTypes": ["script", "image", "xmlhttprequest"]
    }
  },
  {
    "id": 2,
    "priority": 1,
    "action": { "type": "block" },
    "condition": {
      "urlFilter": "tracker.example.com",
      "resourceTypes": ["script", "xmlhttprequest"]
    }
  }
]
```

**Dynamic rules when needed:**

```javascript
// background.js - Update rules programmatically
await chrome.declarativeNetRequest.updateDynamicRules({
  addRules: [{
    id: 100,
    priority: 1,
    action: { type: 'block' },
    condition: { urlFilter: userBlockedDomain }
  }],
  removeRuleIds: [99]
});
```

**When webRequest IS still needed:**
- Modifying request headers dynamically
- Logging requests for debugging
- Complex conditional logic

Reference: [Migrate to declarativeNetRequest](https://developer.chrome.com/docs/extensions/develop/migrate/blocking-web-requests)
