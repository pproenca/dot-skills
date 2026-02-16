---
title: Ensure ForEach Produces Constant View Count Per Element
impact: MEDIUM
impactDescription: O(N) list rebuild → O(1) row diff — stable structural identity enables incremental updates
tags: list, foreach, viewcount, performance, identity
---

## Ensure ForEach Produces Constant View Count Per Element

When ForEach produces different numbers of views per element (conditional views inside the loop), SwiftUI cannot maintain stable structural identity. Each state change may shift which elements have extra views, causing the list to tear down and rebuild rows instead of diffing them. Ensure every ForEach iteration produces the same number of child views.

**Incorrect (variable view count per element — structural identity unstable):**

```swift
struct NotificationList: View {
    @State var viewModel: NotificationListViewModel

    var body: some View {
        List {
            ForEach(viewModel.notifications) { notification in
                VStack(alignment: .leading) {
                    Text(notification.title)
                    Text(notification.body)
                    // Variable view count: some items have 3 children, others have 2
                    if notification.hasAction {
                        Button(notification.actionLabel) {
                            viewModel.performAction(notification)
                        }
                    }
                }
            }
        }
    }
}
```

**Correct (constant view count — hide via opacity or move to subview):**

```swift
struct NotificationList: View {
    @State var viewModel: NotificationListViewModel

    var body: some View {
        List {
            ForEach(viewModel.notifications) { notification in
                NotificationRow(
                    notification: notification,
                    onAction: { viewModel.performAction(notification) }
                )
            }
        }
    }
}

@Equatable
struct NotificationRow: View {
    let notification: AppNotification
    @EquatableIgnored let onAction: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(notification.title)
            Text(notification.body)
            // Constant view count — button always present, hidden when no action
            Button(notification.actionLabel, action: onAction)
                .opacity(notification.hasAction ? 1 : 0)
                .disabled(!notification.hasAction)
        }
    }
}
```

Reference: [Demystify SwiftUI — WWDC21](https://developer.apple.com/videos/play/wwdc2021/10022/)
