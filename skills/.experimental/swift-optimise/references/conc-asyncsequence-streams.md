---
title: Replace NotificationCenter Observers with AsyncSequence
impact: HIGH
impactDescription: automatic cleanup eliminates stale-observer crashes and notification leaks that cause ~2% of observer-related bugs
tags: conc, asyncsequence, notifications, observer, migration
---

## Replace NotificationCenter Observers with AsyncSequence

Traditional `NotificationCenter.addObserver` requires a matching `removeObserver` call in `deinit` or at teardown. Forgetting the removal causes notifications to be delivered to a deallocated object (potential crash) or to a stale handler (logic bug). The `notifications(named:)` AsyncSequence stops iteration automatically when the enclosing task is cancelled -- no manual cleanup is needed.

**Incorrect (manual observer removal required in deinit):**

```swift
@Observable
@MainActor
class ConnectivityMonitor {
    var isReachable = true
    private var observer: NSObjectProtocol?

    func startMonitoring() {
        observer = NotificationCenter.default.addObserver(
            forName: .connectivityChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let status = notification.userInfo?["reachable"] as? Bool
            MainActor.assumeIsolated {
                self?.isReachable = status ?? false
            }
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
