---
title: Use Notifications Judiciously
impact: HIGH
impactDescription: respects user attention and maintains trust
tags: feed, notifications, push, alerts
---

## Use Notifications Judiciously

Only send notifications for information the user truly needs. Every notification should be actionable and timely. Over-notifying leads to users disabling all notifications.

**Incorrect (notification spam):**

```swift
// Marketing notifications
UNUserNotificationCenter.current().add(
    UNNotificationRequest(
        identifier: "promo",
        content: {
            let content = UNMutableNotificationContent()
            content.title = "Don't miss out!"
            content.body = "Check out our new features!"
            return content
        }(),
        trigger: nil
    )
)
// User didn't ask for marketing

// Notification for minor events
// "John viewed your profile" - Not actionable

// Duplicate notifications
// Push + in-app alert for same event
```

**Correct (valuable notifications):**

```swift
// Timely, actionable notification
let content = UNMutableNotificationContent()
content.title = "Your order is arriving"
content.body = "Driver is 5 minutes away"
content.categoryIdentifier = "ORDER_ARRIVING"
content.sound = .default

// Rich notification with actions
let trackAction = UNNotificationAction(
    identifier: "TRACK",
    title: "Track Order",
    options: [.foreground]
)

let category = UNNotificationCategory(
    identifier: "ORDER_ARRIVING",
    actions: [trackAction],
    intentIdentifiers: []
)

UNUserNotificationCenter.current()
    .setNotificationCategories([category])

// Badge for unread count
UIApplication.shared.applicationIconBadgeNumber = unreadCount

// Clear when seen
UIApplication.shared.applicationIconBadgeNumber = 0
```

**Notification guidelines:**
- Only notify for user-relevant events
- Include actionable information
- Use sound sparingly
- Update badge count accurately
- Clear badges when content is read
- Provide notification settings in-app
- Group related notifications

**Good notification examples:**
- Message from a person
- Reminder user created
- Order status change
- Time-sensitive event

**Bad notification examples:**
- "We miss you!"
- Minor activity updates
- Promotional content
- Feature announcements

Reference: [Notifications - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/notifications)
