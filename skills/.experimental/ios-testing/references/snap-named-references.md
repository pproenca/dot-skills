---
title: "Use Named Snapshot References for Clarity"
impact: LOW-MEDIUM
impactDescription: "reduces debugging time by 2-3× with descriptive filenames"
tags: snap, naming, references, clarity, debugging
---

## Use Named Snapshot References for Clarity

Default snapshot filenames derive from the test function name, producing opaque references like `testBanner.1.png` that reveal nothing about what state is captured. Adding a `named:` parameter produces filenames like `testBanner.emptyCart.png`, making failures self-documenting and reducing time to diagnose regressions in CI logs.

**Incorrect (generic numbered filenames obscure which state failed):**

```swift
import Testing
import SnapshotTesting
@testable import BannerFeature

@Suite struct PromoBannerTests {
    @Test func bannerStates() {
        let emptyController = PromoBannerViewController(viewModel: .stub(itemCount: 0))
        let fullController = PromoBannerViewController(viewModel: .stub(itemCount: 5))

        // Produces testBannerStates.1.png and testBannerStates.2.png — which state is which?
        assertSnapshot(of: emptyController, as: .image(on: .iPhone13))
        assertSnapshot(of: fullController, as: .image(on: .iPhone13))
    }
}
```

**Correct (descriptive names make failures immediately identifiable):**

```swift
import Testing
import SnapshotTesting
@testable import BannerFeature

@Suite struct PromoBannerTests {
    @Test func bannerStates() {
        let emptyController = PromoBannerViewController(viewModel: .stub(itemCount: 0))
        let fullController = PromoBannerViewController(viewModel: .stub(itemCount: 5))

        assertSnapshot(of: emptyController, as: .image(on: .iPhone13), named: "emptyCart") // failure file: bannerStates.emptyCart.png
        assertSnapshot(of: fullController, as: .image(on: .iPhone13), named: "fiveItems")
    }
}
```
