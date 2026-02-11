---
title: "Encapsulate Screens in Page Objects"
impact: MEDIUM
impactDescription: "reduces UI test maintenance by 60%+"
tags: ui, page-object, pattern, maintainability, encapsulation
---

## Encapsulate Screens in Page Objects

Scattering raw XCUIElement queries across test methods means a single UI change — a renamed identifier or restructured hierarchy — forces updates in every test that touches that screen. Page objects centralize element access so changes propagate from one place.

**Incorrect (duplicated element queries across tests):**

```swift
func testLoginShowsDashboard() {
    let app = XCUIApplication()
    app.launch()

    app.textFields["emailField"].tap()
    app.textFields["emailField"].typeText("user@example.com")
    app.secureTextFields["passwordField"].tap()
    app.secureTextFields["passwordField"].typeText("securePass1")
    app.buttons["loginButton"].tap()

    XCTAssertTrue(app.staticTexts["dashboardTitle"].waitForExistence(timeout: 5))
}

func testLoginShowsErrorForInvalidCredentials() {
    let app = XCUIApplication()
    app.launch()

    // Same queries duplicated — if "emailField" identifier changes, both tests break
    app.textFields["emailField"].tap()
    app.textFields["emailField"].typeText("bad@example.com")
    app.secureTextFields["passwordField"].tap()
    app.secureTextFields["passwordField"].typeText("wrong")
    app.buttons["loginButton"].tap()

    XCTAssertTrue(app.staticTexts["loginErrorLabel"].waitForExistence(timeout: 5))
}
```

**Correct (single point of change per screen):**

```swift
// Page object encapsulates all element access for the login screen
struct LoginPage {
    private let app: XCUIApplication

    init(app: XCUIApplication) { self.app = app }

    var emailField: XCUIElement { app.textFields["emailField"] }
    var passwordField: XCUIElement { app.secureTextFields["passwordField"] }
    var loginButton: XCUIElement { app.buttons["loginButton"] }
    var errorLabel: XCUIElement { app.staticTexts["loginErrorLabel"] }

    func login(email: String, password: String) {
        emailField.tap()
        emailField.typeText(email)
        passwordField.tap()
        passwordField.typeText(password)
        loginButton.tap()
    }
}

func testLoginShowsDashboard() {
    let app = XCUIApplication()
    app.launch()
    let loginPage = LoginPage(app: app)

    loginPage.login(email: "user@example.com", password: "securePass1")

    XCTAssertTrue(app.staticTexts["dashboardTitle"].waitForExistence(timeout: 5))
}

func testLoginShowsErrorForInvalidCredentials() {
    let app = XCUIApplication()
    app.launch()
    let loginPage = LoginPage(app: app)

    loginPage.login(email: "bad@example.com", password: "wrong")

    // Identifier change only requires updating LoginPage, not every test
    XCTAssertTrue(loginPage.errorLabel.waitForExistence(timeout: 5))
}
```
