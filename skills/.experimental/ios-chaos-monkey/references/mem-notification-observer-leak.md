---
title: "NotificationCenter Observer Retains Closure After Removal Needed"
impact: HIGH
impactDescription: "zombie observer fires on deallocated instance, EXC_BAD_ACCESS"
tags: mem, notification-center, observer, zombie, deinit
---

## NotificationCenter Observer Retains Closure After Removal Needed

`NotificationCenter.default.addObserver(forName:using:)` returns an opaque token. If this token is not removed before the owning object deallocates, the closure fires on a freed instance. The observer becomes a zombie that processes stale state and crashes with `EXC_BAD_ACCESS` the next time the notification posts.

**Incorrect (observer fires after ViewModel deallocates):**

```swift
import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var lastSyncDate: Date?
    private var observerToken: Any?

    init() {
        observerToken = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: nil,
            queue: .main
        ) { _ in
            self.lastSyncDate = Date() // captures self strongly — zombie closure
        }
    }

    deinit {
        // observerToken is never removed — closure outlives self
        print("SettingsViewModel deallocated")
    }
}
```

**Proof Test (exposes the zombie — observer fires after deallocation):**

```swift
import XCTest
@testable import MyApp

final class NotificationObserverLeakTests: XCTestCase {

    func testViewModelDeallocatesAndObserverIsRemoved() {
        weak var weakVM: SettingsViewModel?

        autoreleasepool {
            let vm = SettingsViewModel()
            weakVM = vm
        }

        // Observer closure retains self — ViewModel is not deallocated
        XCTAssertNil(weakVM, "SettingsViewModel leaked — observer closure retained self")

        // Posting after expected deallocation would crash a zombie instance
        NotificationCenter.default.post(
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }
}
```

**Correct (weak self in closure, token removed in deinit):**

```swift
import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var lastSyncDate: Date?
    private var observerToken: Any?

    init() {
        observerToken = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: nil,
            queue: .main
        ) { [weak self] _ in // weak self prevents retention
            self?.lastSyncDate = Date()
        }
    }

    deinit {
        if let token = observerToken {
            NotificationCenter.default.removeObserver(token) // deterministic cleanup
        }
        print("SettingsViewModel deallocated")
    }
}
```
