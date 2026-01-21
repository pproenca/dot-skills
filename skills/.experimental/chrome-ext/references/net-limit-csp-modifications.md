---
title: Avoid Modifying Content Security Policy Headers
impact: MEDIUM-HIGH
impactDescription: prevents security degradation and site breakage
tags: net, csp, headers, security, compatibility
---

## Avoid Modifying Content Security Policy Headers

Stripping or weakening Content Security Policy headers breaks site security and can cause functionality issues. If you must modify CSP, do so surgically for specific use cases.

**Incorrect (removes all CSP protection):**

```json
[
  {
    "id": 1,
    "priority": 1,
    "action": {
      "type": "modifyHeaders",
      "responseHeaders": [
        { "header": "Content-Security-Policy", "operation": "remove" }
      ]
    },
    "condition": {
      "urlFilter": "*",
      "resourceTypes": ["main_frame"]
    }
  }
]
```

**Correct (minimal, targeted modification):**

```json
[
  {
    "id": 1,
    "priority": 1,
    "action": {
      "type": "modifyHeaders",
      "responseHeaders": [
        {
          "header": "Content-Security-Policy",
          "operation": "set",
          "value": "script-src 'self' https://trusted-cdn.example.com; default-src 'self'"
        }
      ]
    },
    "condition": {
      "urlFilter": "||specific-site.com",
      "resourceTypes": ["main_frame"]
    }
  }
]
```

**Better approach (inject content script instead):**

```javascript
// content.js - Work within CSP constraints
// Instead of injecting <script> tags that CSP blocks,
// use content script messaging

// Incorrect - blocked by CSP
const script = document.createElement('script');
script.src = 'https://external.com/script.js';
document.head.appendChild(script);

// Correct - content script approach
chrome.runtime.sendMessage({ type: 'fetch-data' }, (response) => {
  processData(response);
});
```

**When CSP modification IS acceptable:**
- Developer tools that need to debug CSP issues
- Explicit user opt-in for specific sites
- Enterprise deployments with IT approval

Reference: [Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
