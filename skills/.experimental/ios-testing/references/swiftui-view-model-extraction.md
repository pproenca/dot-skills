---
title: "Extract Logic From Views Into Testable Models"
impact: MEDIUM
impactDescription: "makes 80%+ of logic unit-testable without UI framework"
tags: swiftui, view-model, extraction, separation-of-concerns
---

## Extract Logic From Views Into Testable Models

Business logic embedded inside a View's body or action closures can only be exercised by rendering the full view hierarchy. Extracting that logic into an @Observable model makes it callable from plain unit tests with no SwiftUI dependency.

**Incorrect (validation and formatting logic trapped inside the view):**

```swift
struct CheckoutView: View {
    @State private var items: [CartItem] = []
    @State private var promoCode: String = ""
    @State private var errorMessage: String?

    var body: some View {
        List(items) { item in
            CartRowView(item: item)
        }
        TextField("Promo code", text: $promoCode)
        Button("Apply") {
            if promoCode.count < 4 || promoCode.count > 12 { // validation buried in view — untestable without rendering
                errorMessage = "Code must be 4–12 characters"
            } else {
                let discount = items.reduce(0.0) { $0 + $1.price } * 0.15
                errorMessage = nil
                applyDiscount(discount)
            }
        }
    }
}
```

**Correct (logic lives in a testable model, view only binds):**

```swift
@Observable
class CheckoutModel {
    var items: [CartItem] = []
    var promoCode: String = ""
    var errorMessage: String?

    func applyPromoCode() {
        guard promoCode.count >= 4, promoCode.count <= 12 else { // testable without any view
            errorMessage = "Code must be 4–12 characters"
            return
        }
        let discount = items.reduce(0.0) { $0 + $1.price } * 0.15
        errorMessage = nil
        applyDiscount(discount)
    }
}

struct CheckoutView: View {
    @State private var model = CheckoutModel()

    var body: some View {
        List(model.items) { item in
            CartRowView(item: item)
        }
        TextField("Promo code", text: $model.promoCode)
        Button("Apply") { model.applyPromoCode() } // view delegates, never decides
    }
}
```
