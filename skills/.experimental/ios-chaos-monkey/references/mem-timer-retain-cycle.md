---
title: "Timer Retains Target Creating Undiscoverable Retain Cycle"
impact: CRITICAL
impactDescription: "ViewController leaks ~50MB per navigation cycle"
tags: mem, timer, retain-cycle, invalidate, deinit
---

## Timer Retains Target Creating Undiscoverable Retain Cycle

`Timer.scheduledTimer(target:selector:)` retains its target strongly for the lifetime of the timer. If the target (a ViewController) owns the timer, a bidirectional strong reference forms. Neither `deinit` nor `invalidate` is ever called, leaking the entire view hierarchy on every navigation.

**Incorrect (ViewController never deallocates while timer runs):**

```swift
import UIKit

final class DashboardViewController: UIViewController {
    private var pollingTimer: Timer?
    private var dashboardData: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        pollingTimer = Timer.scheduledTimer(
            timeInterval: 5.0,
            target: self, // timer retains self strongly
            selector: #selector(fetchDashboard),
            userInfo: nil,
            repeats: true
        )
    }

    @objc private func fetchDashboard() {
        dashboardData.append("Polled at \(Date())")
    }

    deinit {
        pollingTimer?.invalidate() // never reached — deinit requires deallocation
        print("DashboardViewController deallocated")
    }
}
```

**Proof Test (exposes the leak — deinit never fires after dismissal):**

```swift
import XCTest
@testable import MyApp

final class DashboardTimerRetainTests: XCTestCase {

    func testViewControllerDeallocatesAfterDismissal() {
        weak var weakVC: DashboardViewController?

        autoreleasepool {
            let vc = DashboardViewController()
            weakVC = vc
            vc.loadViewIfNeeded()
            // Simulate dismissal by dropping all strong references
        }

        // Timer still holds vc alive — weakVC is non-nil
        XCTAssertNil(weakVC, "DashboardViewController leaked — timer retained target")
    }
}
```

**Correct (block-based timer with weak self, invalidated in viewDidDisappear):**

```swift
import UIKit

final class DashboardViewController: UIViewController {
    private var pollingTimer: Timer?
    private var dashboardData: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        pollingTimer = Timer.scheduledTimer(
            withTimeInterval: 5.0,
            repeats: true
        ) { [weak self] _ in // block-based API — no target retention
            self?.fetchDashboard()
        }
    }

    private func fetchDashboard() {
        dashboardData.append("Polled at \(Date())")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pollingTimer?.invalidate() // deterministic cleanup, does not depend on deinit
        pollingTimer = nil
    }

    deinit { print("DashboardViewController deallocated") }
}
```
