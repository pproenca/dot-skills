---
title: Use storage.session for Temporary Runtime Data
impact: HIGH
impactDescription: auto-cleanup on browser close, faster access
tags: storage, session, temporary, runtime, performance
---

## Use storage.session for Temporary Runtime Data

`storage.session` is designed for data that should only exist during the browser session. It's faster than `storage.local` and automatically cleans up when the browser closes, preventing storage bloat.

**Incorrect (temporary data in persistent storage):**

```javascript
// background.js - Temp data stays forever
async function startProcessing(jobId) {
  await chrome.storage.local.set({
    [`job:${jobId}`]: {
      status: 'running',
      startTime: Date.now()
    }
  });
  // Never cleaned up, accumulates over time
}

// Months later: storage full of stale job entries
```

**Correct (session storage for temporary data):**

```javascript
// background.js - Automatically cleaned up
async function startProcessing(jobId) {
  await chrome.storage.session.set({
    [`job:${jobId}`]: {
      status: 'running',
      startTime: Date.now()
    }
  });
  // Cleared when browser closes
}

async function getJobStatus(jobId) {
  const { [`job:${jobId}`]: job } = await chrome.storage.session.get(`job:${jobId}`);
  return job?.status ?? 'unknown';
}
```

**Use cases for storage.session:**
- Auth tokens that shouldn't persist
- Processing state and progress
- Temporary caches
- Undo/redo stacks
- Form draft data

**Use cases for storage.local:**
- User preferences
- Persistent caches
- Download history
- Data that should survive restarts

**Note:** `storage.session` is not shared between content scripts and service worker by default. Set `chrome.storage.session.setAccessLevel({ accessLevel: 'TRUSTED_AND_UNTRUSTED_CONTEXTS' })` to share.

Reference: [chrome.storage.session](https://developer.chrome.com/docs/extensions/reference/api/storage#property-session)
