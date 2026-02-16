---
title: "Array Index Access Without Bounds Check Crashes"
impact: MEDIUM
impactDescription: "fatal error: Index out of range, 100% crash on invalid index"
tags: mut, array, bounds-check, subscript, crash
---

## Array Index Access Without Bounds Check Crashes

Direct array subscript access (`array[index]`) triggers a fatal error when the index is out of bounds. Unlike dictionary subscript, array subscript does not return an optional. This crashes deterministically but often passes code review because the happy path works.

**Incorrect (direct subscript access crashes on out-of-bounds index):**

```swift
import Foundation

class PageController {
    private let pages: [String]
    private var currentIndex: Int = 0

    init(pages: [String]) {
        self.pages = pages
    }

    func navigateTo(index: Int) -> String {
        currentIndex = index
        return pages[index]  // fatal error if index >= pages.count
    }

    func currentPage() -> String {
        pages[currentIndex]
    }

    func nextPage() -> String {
        currentIndex += 1
        return pages[currentIndex]  // crashes on last page
    }
}
```

**Proof Test (exposes the crash with an out-of-bounds index):**

```swift
import XCTest

final class PageControllerBoundsTests: XCTestCase {
    func testNavigateToInvalidIndexDoesNotCrash() {
        let controller = PageController(pages: ["Home", "Settings", "Profile"])

        // Index beyond array count — crashes without bounds check
        let result = controller.navigateTo(index: 5)
        XCTAssertNil(result, "Out-of-bounds index should return nil, not crash")
    }

    func testNextPageBeyondEndDoesNotCrash() {
        let controller = PageController(pages: ["Home", "Settings"])

        _ = controller.navigateTo(index: 1)
        let result = controller.nextPage()  // index 2 — out of bounds
        XCTAssertNil(result, "Navigating past last page should return nil")
    }
}
```

**Correct (safe subscript returns nil for out-of-bounds access):**

```swift
import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

class PageController {
    private let pages: [String]
    private var currentIndex: Int = 0

    init(pages: [String]) {
        self.pages = pages
    }

    func navigateTo(index: Int) -> String? {
        guard let page = pages[safe: index] else { return nil }
        currentIndex = index
        return page  // safe — returns nil instead of crashing
    }

    func currentPage() -> String? {
        pages[safe: currentIndex]
    }

    func nextPage() -> String? {
        let next = currentIndex + 1
        guard let page = pages[safe: next] else { return nil }
        currentIndex = next
        return page
    }
}
```
