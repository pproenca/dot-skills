---
title: "Missing dynamic Keyword Breaks Method Swizzling"
impact: LOW
impactDescription: "swizzled method never called, silent behavior change"
tags: objc, dynamic, swizzle, dispatch, runtime
---

## Missing dynamic Keyword Breaks Method Swizzling

Swift can optimize method dispatch to bypass the Objective-C runtime. Without the `dynamic` keyword, the compiler may use static or vtable dispatch, which means method swizzling targets the original implementation but the optimized call path never goes through it. The swizzled method is silently never called.

**Incorrect (swizzles method without dynamic keyword, swizzle has no effect):**

```swift
import UIKit

class AnalyticsTracker: NSObject {
    static let shared = AnalyticsTracker()
    private(set) var trackedScreens: [String] = []

    static func startTracking() {
        let originalSelector = #selector(
            UIViewController.viewDidAppear(_:))
        let swizzledSelector = #selector(
            UIViewController.tracked_viewDidAppear(_:))

        guard let originalMethod = class_getInstanceMethod(
                UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(
                UIViewController.self, swizzledSelector)
        else { return }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    func track(screen: String) {
        trackedScreens.append(screen)
    }
}

extension UIViewController {
    // Missing @objc dynamic — Swift may use static dispatch
    func tracked_viewDidAppear(_ animated: Bool) {
        tracked_viewDidAppear(animated)  // calls original via swizzle
        let screenName = String(describing: type(of: self))
        AnalyticsTracker.shared.track(screen: screenName)
    }
}
```

**Proof Test (verifies swizzled method is actually invoked):**

```swift
import XCTest
import UIKit

final class AnalyticsTrackerSwizzleTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        AnalyticsTracker.startTracking()
    }

    func testViewDidAppearIsTracked() {
        let vc = UIViewController()
        let window = UIWindow(frame: .zero)
        window.rootViewController = vc
        window.makeKeyAndVisible()

        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()

        // Without dynamic, the swizzled method is never called
        XCTAssertFalse(
            AnalyticsTracker.shared.trackedScreens.isEmpty,
            "Swizzled viewDidAppear was never called — missing dynamic keyword"
        )
    }
}
```

**Correct (@objc dynamic forces Objective-C dispatch, making swizzle effective):**

```swift
import UIKit

class AnalyticsTracker: NSObject {
    static let shared = AnalyticsTracker()
    private(set) var trackedScreens: [String] = []

    static func startTracking() {
        let originalSelector = #selector(
            UIViewController.viewDidAppear(_:))
        let swizzledSelector = #selector(
            UIViewController.tracked_viewDidAppear(_:))

        guard let originalMethod = class_getInstanceMethod(
                UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(
                UIViewController.self, swizzledSelector)
        else { return }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    func track(screen: String) {
        trackedScreens.append(screen)
    }
}

extension UIViewController {
    @objc dynamic func tracked_viewDidAppear(_ animated: Bool) {
        tracked_viewDidAppear(animated)  // calls original via swizzle
        let screenName = String(describing: type(of: self))
        AnalyticsTracker.shared.track(screen: screenName)
    }
}
```
