---
title: Use Notifications Sparingly
impact: MEDIUM
impactDescription: prevents notification fatigue and user annoyance
tags: feedback, notifications, system, alerts, user-attention
---

## Use Notifications Sparingly

Reserve system notifications for truly important events. Overusing notifications trains users to ignore them or disable your extension entirely.

**Incorrect (notification spam):**

```typescript
// background.js - Too many notifications
async function onDataSync() {
  await syncData()

  chrome.notifications.create({
    type: 'basic',
    iconUrl: 'icon.png',
    title: 'Sync Complete',
    message: 'Your data has been synced'
  })
  // Fires every 5 minutes → user disables notifications or extension
}

async function onNewItem(item) {
  chrome.notifications.create({
    type: 'basic',
    iconUrl: 'icon.png',
    title: 'New Item',
    message: `${item.title} was added`
  })
  // 20 new items = 20 notifications → user rage-quits
}
```

**Correct (meaningful notifications only):**

```typescript
// background.js - Thoughtful notification strategy
const NOTIFICATION_COOLDOWN = 30 * 60 * 1000 // 30 minutes
let lastNotificationTime = 0

async function shouldNotify(importance) {
  // Check user preferences
  const { notificationsEnabled } = await chrome.storage.sync.get('notificationsEnabled')
  if (!notificationsEnabled) return false

  // Respect cooldown for non-critical notifications
  if (importance !== 'critical') {
    const now = Date.now()
    if (now - lastNotificationTime < NOTIFICATION_COOLDOWN) {
      return false
    }
  }

  return true
}

async function notifyIfImportant(event) {
  const notificationRules = {
    // Critical - always notify
    'subscription_expiring': {
      importance: 'critical',
      title: 'Subscription Expiring',
      message: 'Your subscription expires tomorrow'
    },

    // Important - notify with cooldown
    'important_update': {
      importance: 'high',
      title: 'Important Update Available',
      message: 'A security update is ready to install'
    },

    // Batched - collect and summarize
    'new_items': {
      importance: 'low',
      batch: true
    }
  }

  const rule = notificationRules[event.type]
  if (!rule) return

  if (rule.batch) {
    // Batch low-priority events
    await addToBatch(event)
    return
  }

  if (await shouldNotify(rule.importance)) {
    chrome.notifications.create({
      type: 'basic',
      iconUrl: 'icon.png',
      title: rule.title,
      message: rule.message,
      priority: rule.importance === 'critical' ? 2 : 0
    })
    lastNotificationTime = Date.now()
  }
}

// Batch notifications - summarize multiple events
let batchedItems = []
let batchTimeout = null

async function addToBatch(event) {
  batchedItems.push(event)

  // Debounce batch notification
  clearTimeout(batchTimeout)
  batchTimeout = setTimeout(async () => {
    if (batchedItems.length > 0 && await shouldNotify('low')) {
      chrome.notifications.create({
        type: 'basic',
        iconUrl: 'icon.png',
        title: 'New Items',
        message: `${batchedItems.length} new items since last check`
      })
      batchedItems = []
      lastNotificationTime = Date.now()
    }
  }, 60000) // Wait 1 minute to batch
}
```

**Notification worthiness guide:**

| Event | Notify? | Why |
|-------|---------|-----|
| Sync complete | No | Expected background operation |
| New item added | Badge only | Low urgency, user can check later |
| Important deadline | Yes | Time-sensitive, user needs to act |
| Error requiring action | Yes | User must intervene |
| Extension updated | Once | Informational, not recurring |

Reference: [Notifications API](https://developer.chrome.com/docs/extensions/reference/api/notifications)
