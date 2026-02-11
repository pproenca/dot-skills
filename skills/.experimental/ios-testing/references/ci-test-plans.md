---
title: "Use Xcode Test Plans for Environment Configurations"
impact: LOW-MEDIUM
impactDescription: "reduces test duplication by 3-5× across locale configs"
tags: ci, test-plans, xcode, configurations, localization
---

## Use Xcode Test Plans for Environment Configurations

Duplicating test schemes per language or region creates a maintenance burden where every new test must be added to every scheme. Xcode Test Plans define a single set of tests with multiple configurations, so one plan runs the entire suite against every locale, environment variable set, or launch argument combination automatically.

**Incorrect (duplicated schemes drift out of sync):**

```swift
// Scheme: "Tests-English" — manually configured with:
//   Application Language: English
//   Application Region: United States
//
// Scheme: "Tests-Spanish" — identical test list, different locale:
//   Application Language: Spanish
//   Application Region: Spain
//
// Scheme: "Tests-Japanese" — yet another copy:
//   Application Language: Japanese
//   Application Region: Japan

// Each scheme must be updated whenever a test is added or removed
final class BookingFlowTests: XCTestCase {
    func testBookingConfirmationShowsLocalizedDate() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["Book Now"].tap()
        XCTAssertTrue(app.staticTexts["confirmationDate"].exists) // only tests one locale per scheme run
    }
}
```

**Correct (one plan, multiple configurations, zero duplication):**

```json
// BookingTests.xctestplan
{
  "configurations": [
    {
      "name": "English (US)",
      "options": {
        "language": "en",
        "region": "US"
      }
    },
    {
      "name": "Spanish (ES)",
      "options": {
        "language": "es",
        "region": "ES"
      }
    },
    {
      "name": "Japanese (JP)",
      "options": {
        "language": "ja",
        "region": "JP"
      }
    }
  ],
  "defaultOptions": {
    "testTimeoutsEnabled": true,
    "defaultTestExecutionTimeAllowance": 60
  },
  "testTargets": [
    {
      "target": {
        "containerPath": "container:App.xcodeproj",
        "identifier": "BookingFlowTests"
      }
    }
  ]
}
```

```swift
// Same test runs automatically in all 3 configurations
final class BookingFlowTests: XCTestCase {
    func testBookingConfirmationShowsLocalizedDate() {
        let app = XCUIApplication()
        app.launch() // test plan injects language/region per configuration
        app.buttons["Book Now"].tap()
        XCTAssertTrue(app.staticTexts["confirmationDate"].exists)
    }
}
```
