---
title: "Test @Observable Models as Plain Objects"
impact: MEDIUM-HIGH
impactDescription: "10× faster than testing through views"
tags: swiftui, observable, model, unit-testing
---

## Test @Observable Models as Plain Objects

Rendering a SwiftUI view to test model behavior adds host-app boot time, view lifecycle overhead, and fragile UI assertions for logic that has nothing to do with layout. Instantiating the @Observable model directly exercises the same state mutations at unit-test speed with deterministic control.

**Incorrect (view rendering overhead to verify model logic):**

```swift
import XCTest
import ViewInspector
@testable import Recipes

final class RecipeListTests: XCTestCase {
    func testAddingRecipeUpdatesCount() throws {
        let model = RecipeListModel()
        let view = RecipeListView(model: model) // boots SwiftUI rendering pipeline to test a count
        let list = try view.inspect().find(ViewType.List.self)

        model.add(Recipe(name: "Margherita", servings: 4))

        let updatedList = try RecipeListView(model: model).inspect().find(ViewType.List.self)
        XCTAssertEqual(try updatedList.count, 1)
    }
}
```

**Correct (direct model test — no rendering, no view dependency):**

```swift
import Testing
@testable import Recipes

@Suite struct RecipeListModelTests {
    @Test func addingRecipeUpdatesCount() {
        let model = RecipeListModel() // plain object — no SwiftUI host required
        model.add(Recipe(name: "Margherita", servings: 4))

        #expect(model.recipes.count == 1)
        #expect(model.recipes.first?.name == "Margherita")
    }
}
```
