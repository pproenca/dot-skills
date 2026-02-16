---
title: "Strong Self Capture in Escaping Closures Creates Retain Cycle"
impact: CRITICAL
impactDescription: "permanent memory leak, ViewModel never deallocates"
tags: mem, closure, retain-cycle, escaping, observable
---

## Strong Self Capture in Escaping Closures Creates Retain Cycle

When an `@Observable` ViewModel stores an escaping closure that captures `self` strongly, neither the ViewModel nor the closure can be freed. The reference count never reaches zero because each object holds the other alive, leaking the ViewModel on every navigation.

**Incorrect (leaks ViewModel on every navigation):**

```swift
import Foundation
import Observation

@Observable
final class ProfileViewModel {
    var userName: String = ""
    var onUserFetched: (() -> Void)?

    func startFetching() {
        onUserFetched = { // strong capture of self — retain cycle
            self.userName = "Fetched User"
        }
        simulateNetworkCall(completion: onUserFetched!)
    }

    private func simulateNetworkCall(completion: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            completion()
        }
    }

    deinit { print("ProfileViewModel deallocated") }
}
```

**Proof Test (exposes the leak — deinit never fires):**

```swift
import XCTest
@testable import MyApp

final class ProfileViewModelRetainCycleTests: XCTestCase {

    func testViewModelDeallocatesAfterUse() async throws {
        weak var weakVM: ProfileViewModel?

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let vm = ProfileViewModel()
            weakVM = vm
            vm.startFetching()

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                continuation.resume()
            }
        }

        // weakVM is still non-nil — retain cycle keeps it alive
        addTeardownBlock { [weak weakVM] in
            XCTAssertNil(weakVM, "ProfileViewModel was not deallocated — retain cycle detected")
        }
    }
}
```

**Correct (weak self breaks the cycle, ViewModel deallocates normally):**

```swift
import Foundation
import Observation

@Observable
final class ProfileViewModel {
    var userName: String = ""
    var onUserFetched: (() -> Void)?

    func startFetching() {
        onUserFetched = { [weak self] in // weak capture breaks retain cycle
            self?.userName = "Fetched User"
        }
        simulateNetworkCall(completion: onUserFetched!)
    }

    private func simulateNetworkCall(completion: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            completion()
        }
    }

    deinit { print("ProfileViewModel deallocated") }
}
```
