---
title: "Use swift-snapshot-testing for Visual Regression"
impact: MEDIUM
impactDescription: "replaces 100% of manual visual QA per assertion"
tags: snap, swift-snapshot-testing, visual-regression, point-free
---

## Use swift-snapshot-testing for Visual Regression

Manual visual QA is slow, inconsistent, and scales linearly with every new screen. Point-Free's swift-snapshot-testing generates pixel-accurate reference images on the first run and fails automatically when any rendered output drifts, catching regressions that unit tests and code review cannot detect.

**Incorrect (relies on manual visual inspection to catch regressions):**

```swift
import XCTest
@testable import ProfileFeature

final class ProfileViewTests: XCTestCase {
    func testProfileRendersCorrectly() {
        let viewModel = ProfileViewModel(
            user: .stub(name: "Jane Doe", tier: .premium)
        )
        let controller = ProfileViewController(viewModel: viewModel)
        controller.loadViewIfNeeded()

        // No assertion on visual output — regressions discovered in QA or production
        XCTAssertNotNil(controller.view)
    }
}
```

**Correct (pixel-level regression caught automatically on every CI run):**

```swift
import Testing
import SnapshotTesting
@testable import ProfileFeature

@Suite struct ProfileViewTests {
    @Test func profileRendersCorrectly() {
        let viewModel = ProfileViewModel(
            user: .stub(name: "Jane Doe", tier: .premium)
        )
        let controller = ProfileViewController(viewModel: viewModel)

        assertSnapshot(of: controller, as: .image(on: .iPhone13)) // generates reference image on first run, fails on pixel drift
    }
}
```
