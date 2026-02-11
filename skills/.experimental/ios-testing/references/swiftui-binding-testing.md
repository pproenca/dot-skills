---
title: "Test Binding Behavior With @Bindable"
impact: MEDIUM
impactDescription: "5× faster than view-based binding tests"
tags: swiftui, binding, bindable, two-way-data
---

## Test Binding Behavior With @Bindable

Testing two-way bindings by rendering a view, simulating user input, and reading the result back is slow and fragile. With @Observable models, @Bindable exposes writable properties directly — tests mutate the model property and assert the side effects without any view infrastructure.

**Incorrect (rendering view hierarchy to verify binding propagation):**

```swift
import XCTest
import ViewInspector
@testable import Settings

final class TemperatureSettingsTests: XCTestCase {
    func testToggleUpdatesUnit() throws {
        let model = TemperatureSettingsModel()
        let view = TemperatureSettingsView(model: model)

        let toggle = try view.inspect().find(ViewType.Toggle.self) // fragile — breaks if view hierarchy changes
        try toggle.tap()

        XCTAssertTrue(model.useCelsius)
    }
}
```

**Correct (mutate model directly — binding contract verified without views):**

```swift
import Testing
@testable import Settings

@Suite struct TemperatureSettingsModelTests {
    @Test func toggleUnitRecalculatesDisplayValue() {
        let model = TemperatureSettingsModel()
        model.temperatureFahrenheit = 98.6

        model.useCelsius = true // same mutation a @Bindable toggle would perform

        #expect(model.displayValue == "37.0°C") // verify computed output updates from property change
    }
}
```
