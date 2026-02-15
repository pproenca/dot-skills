---
title: Pass @Binding Only for Two-Way Data Flow
impact: MEDIUM-HIGH
impactDescription: reduces mutation paths from O(N) @Binding to O(1) closure actions
tags: state, binding, two-way, unidirectional, actions
---

## Pass @Binding Only for Two-Way Data Flow

`@Binding` allows child views to WRITE back to the parent's state. Use it only when the child genuinely needs to mutate the value (form fields, toggles). For read-only data, pass plain properties. For actions, pass closures or use ViewModel methods. Overusing `@Binding` creates spaghetti mutation paths that are impossible to trace.

**Incorrect (@Binding for display-only data and actions — hidden mutation paths):**

```swift
struct OrderSummary: View {
    // BUG: @Binding implies this view can MODIFY the order
    // But it's a read-only summary — no mutation needed
    @Binding var orderTotal: Decimal
    @Binding var itemCount: Int

    // BUG: Using @Binding to trigger a parent action
    // This is a write path disguised as an action
    @Binding var shouldCheckout: Bool

    var body: some View {
        VStack {
            Text("Items: \(itemCount)")
            Text(orderTotal, format: .currency(code: "USD"))
            Button("Checkout") {
                shouldCheckout = true  // mutating parent state directly
            }
        }
    }
}
```

**Correct (let for display, closure for actions, @Binding only for form controls):**

```swift
struct OrderSummary: View {
    let orderTotal: Decimal       // read-only — plain property
    let itemCount: Int            // read-only — plain property
    let onCheckout: () -> Void    // action — closure, not mutation

    var body: some View {
        VStack {
            Text("Items: \(itemCount)")
            Text(orderTotal, format: .currency(code: "USD"))
            Button("Checkout", action: onCheckout)
        }
    }
}

// @Binding is correct HERE — TextField needs to write back
struct EditProfileForm: View {
    @Binding var name: String          // two-way — TextField writes
    @Binding var notificationsOn: Bool // two-way — Toggle writes

    var body: some View {
        Form {
            TextField("Name", text: $name)
            Toggle("Notifications", isOn: $notificationsOn)
        }
    }
}
```

**When to use each pattern:**
- `let` — display-only data (labels, counts, formatted values)
- Closure — actions (tap, submit, dismiss)
- `@Binding` — form controls that mutate the value (TextField, Toggle, Picker, DatePicker, Slider)

Reference: [Apple Documentation — State and data flow](https://developer.apple.com/documentation/swiftui/state-and-data-flow)
