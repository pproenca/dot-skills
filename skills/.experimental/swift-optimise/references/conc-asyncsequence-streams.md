---
title: Replace NotificationCenter Observers with AsyncSequence
impact: MEDIUM-HIGH
impactDescription: automatic cleanup, no removeObserver needed
tags: conc, asyncsequence, notifications, observer, migration
---

## Replace NotificationCenter Observers with AsyncSequence

Traditional `NotificationCenter.addObserver` requires a matching `removeObserver` call in `deinit` or at teardown. Forgetting the removal causes notifications to be delivered to a deallocated object (potential crash) or to a stale handler (logic bug). The `notifications(named:)` AsyncSequence stops iteration automatically when the enclosing task is cancelled -- no manual cleanup is needed.

**Incorrect (manual observer removal required in deinit):**

```swift
class ConnectivityMonitor: ObservableObject {
    @Published var isReachable = true
    private var observer: NSObjectProtocol?

    init() {
        observer = NotificationCenter.default.addObserver(
            forName: .connectivityChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let status = notification.userInfo?["reachable"] as? Bool
            self?.isReachable = status ?? false
        }
    }

    deinit {
        // Forgetting this causes stale delivery or crashes
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
```

**Correct (automatic cleanup when task is cancelled):**

```swift
@Observable
@MainActor
class ConnectivityMonitor {
    var isReachable = true

    func startMonitoring() async {
        let notifications = NotificationCenter.default.notifications(
            named: .connectivityChanged
        )
        // Iteration stops automatically when the task is cancelled
        for await notification in notifications {
            let status = notification.userInfo?["reachable"] as? Bool
            isReachable = status ?? false
        }
    }
}

// Usage in a view:
// .task { await monitor.startMonitoring() }
```

Reference: [notifications(named:object:)](https://developer.apple.com/documentation/foundation/notificationcenter/notifications(named:object:))
