---
title: "Unowned Reference Crashes After Owner Deallocation"
impact: HIGH
impactDescription: "EXC_BAD_ACCESS, 100% crash when lifecycle timing shifts"
tags: mem, unowned, crash, exc-bad-access, lifecycle
---

## Unowned Reference Crashes After Owner Deallocation

`unowned` assumes the referenced object outlives the referencing object. When lifecycle assumptions break -- such as an async callback returning after a coordinator's parent has been dismissed -- `unowned` dereferences a freed pointer and triggers an immediate `EXC_BAD_ACCESS`. This crash is deterministic once timing shifts, but invisible during development.

**Incorrect (crashes when parent deallocates before coordinator finishes):**

```swift
import UIKit

final class AppCoordinator {
    var childCoordinators: [Any] = []

    func startCheckout() {
        let checkout = CheckoutCoordinator(parent: self)
        childCoordinators.append(checkout)
        checkout.begin()
    }

    deinit { print("AppCoordinator deallocated") }
}

final class CheckoutCoordinator {
    unowned let parent: AppCoordinator // assumes parent outlives self

    init(parent: AppCoordinator) {
        self.parent = parent
    }

    func begin() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            // EXC_BAD_ACCESS if parent was deallocated during async work
            print("Reporting to \(self.parent)")
        }
    }
}
```

**Proof Test (exposes the crash — accessing unowned after deallocation):**

```swift
import XCTest
@testable import MyApp

final class UnownedCrashTests: XCTestCase {

    func testAccessingUnownedAfterDeallocationCrashes() {
        var coordinator: CheckoutCoordinator?

        autoreleasepool {
            let parent = AppCoordinator()
            coordinator = CheckoutCoordinator(parent: parent)
            // parent is deallocated here
        }

        // This access triggers EXC_BAD_ACCESS — unowned references a freed object
        // In a real test, this would crash the test runner
        XCTAssertNotNil(coordinator, "Coordinator exists but its parent is freed")
        // coordinator!.parent would crash here — proves unowned is unsafe
    }
}
```

**Correct (weak reference with guard-let, survives parent deallocation):**

```swift
import UIKit

final class AppCoordinator {
    var childCoordinators: [Any] = []

    func startCheckout() {
        let checkout = CheckoutCoordinator(parent: self)
        childCoordinators.append(checkout)
        checkout.begin()
    }

    deinit { print("AppCoordinator deallocated") }
}

final class CheckoutCoordinator {
    weak var parent: AppCoordinator? // weak — survives parent deallocation

    init(parent: AppCoordinator) {
        self.parent = parent
    }

    func begin() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self, let parent = self.parent else { return } // safe unwrap
            print("Reporting to \(parent)")
        }
    }
}
```
