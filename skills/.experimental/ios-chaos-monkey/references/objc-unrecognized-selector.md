---
title: "Missing @objc Annotation Crashes with Unrecognized Selector"
impact: LOW-MEDIUM
impactDescription: "NSInvalidArgumentException, 100% crash at runtime"
tags: objc, selector, annotation, crash, uikit
---

## Missing @objc Annotation Crashes with Unrecognized Selector

Using `#selector()` with a Swift method that is not marked `@objc` compiles successfully but crashes at runtime. The Objective-C runtime cannot find the method because Swift does not expose it without the annotation, producing `NSInvalidArgumentException: unrecognized selector sent to instance`.

**Incorrect (selector references method without @objc, crashes at runtime):**

```swift
import UIKit

class FormViewController: UIViewController {
    private let submitButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        submitButton.setTitle("Submit", for: .normal)
        submitButton.addTarget(
            self,
            action: #selector(handleSubmit),  // compiles, crashes at runtime
            for: .touchUpInside
        )
        view.addSubview(submitButton)
    }

    // Missing @objc — invisible to Objective-C runtime
    func handleSubmit() {
        print("Form submitted")
    }
}
```

**Proof Test (exposes unrecognized selector crash when button is tapped):**

```swift
import XCTest
import UIKit

final class FormViewControllerSelectorTests: XCTestCase {
    func testSubmitButtonDoesNotCrash() {
        let vc = FormViewController()
        vc.loadViewIfNeeded()

        // Simulate button tap — sends action to target
        XCTAssertNoThrow(
            vc.submitButton.sendActions(for: .touchUpInside),
            "Button tap should not crash with unrecognized selector"
        )
    }
}
```

**Correct (@objc annotation exposes method to Objective-C runtime):**

```swift
import UIKit

class FormViewController: UIViewController {
    private let submitButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        submitButton.setTitle("Submit", for: .normal)
        submitButton.addTarget(
            self,
            action: #selector(handleSubmit),
            for: .touchUpInside
        )
        view.addSubview(submitButton)
    }

    @objc func handleSubmit() {  // visible to ObjC runtime — no crash
        print("Form submitted")
    }
}
```
