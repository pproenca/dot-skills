---
title: Set Accessibility Identifiers for UI Testing
impact: LOW-MEDIUM
impactDescription: enables reliable automated UI test targeting
tags: ally, identifier, ui-testing, automation
---

## Set Accessibility Identifiers for UI Testing

UI tests that locate elements by text content break when copy changes, when the app is localized, or when multiple elements share the same label. Accessibility identifiers are invisible to users but provide a stable, locale-independent hook for XCUITest queries. Setting them in Interface Builder's Identity Inspector ensures they are always present without requiring code changes.

**Incorrect (UI test targeting element by visible text):**

```swift
// CheckoutUITests.swift
func testApplyPromoCode() {
    let app = XCUIApplication()
    app.launch()
    // Breaks when text is localized or copy changes
    app.textFields["Enter promo code"].tap()
    app.textFields["Enter promo code"].typeText("SAVE20")
    app.buttons["Apply"].tap()
    XCTAssertTrue(app.staticTexts["20% discount applied"].exists)
}
```

**Correct (UI test targeting element by stable accessibility identifier):**

Set the identifier in the storyboard:

```xml
<textField id="promo-field" placeholder="Enter promo code">
    <accessibility key="accessibilityConfiguration"
                   identifier="promo_code_field"/>
</textField>
<button id="apply-btn" buttonType="system">
    <state key="normal" title="Apply"/>
    <accessibility key="accessibilityConfiguration"
                   identifier="apply_promo_button"/>
</button>
```

Then reference it in the test:

```swift
// CheckoutUITests.swift
func testApplyPromoCode() {
    let app = XCUIApplication()
    app.launch()
    app.textFields["promo_code_field"].tap()
    app.textFields["promo_code_field"].typeText("SAVE20")
    app.buttons["apply_promo_button"].tap()
    XCTAssertTrue(app.staticTexts["discount_confirmation_label"].exists)
}
```

**Benefits:**

- Tests survive localization into any language
- Copy changes by the design team never break CI
- Identifiers serve as a contract between design and QA

Reference: [accessibilityIdentifier](https://developer.apple.com/documentation/uikit/uiaccessibilityidentification/1623132-accessibilityidentifier)
