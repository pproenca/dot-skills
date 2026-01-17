---
title: Enable Debug Logging for Troubleshooting
impact: LOW-MEDIUM
impactDescription: provides visibility into nuqs internal operations
tags: debug, logging, localStorage, troubleshooting, devtools
---

## Enable Debug Logging for Troubleshooting

Enable nuqs debug logs to understand state changes, URL updates, and timing. Useful for diagnosing issues with state synchronization or unexpected behavior.

**Enable in browser console:**

```javascript
// Run in browser DevTools console
localStorage.debug = 'nuqs'
// Then reload the page
```

**Log output format:**

```
[nuqs] useQueryState 'page' initialized with 1
[nuqs] useQueryState 'page' updated to 2
[nuq+] useQueryStates update: { lat: 48.8566, lng: 2.3522 }
[nuqs] URL update throttled, scheduling...
[nuqs] URL updated: ?page=2
```

**Disable when done:**

```javascript
// Run in browser DevTools console
delete localStorage.debug
// Or set to empty
localStorage.debug = ''
```

**Performance timing markers:**

Debug mode also records User Timing markers visible in the Performance tab:
- `nuqs:parse` - Time to parse URL parameters
- `nuqs:serialize` - Time to serialize state to URL
- `nuqs:update` - Time for URL update

**Check timing in DevTools:**
1. Open Performance tab
2. Record while interacting with nuqs state
3. Look for "nuqs:" markers in the Timings row

**Migration note:** If upgrading from `next-usequerystate`, update the debug flag:

```javascript
if (localStorage.debug === 'next-usequerystate') {
  localStorage.debug = 'nuqs'
}
```

Reference: [nuqs Debugging](https://nuqs.dev/docs)
