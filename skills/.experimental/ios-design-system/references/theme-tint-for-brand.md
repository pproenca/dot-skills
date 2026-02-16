---
title: Use .tint() as the Primary Brand Expression Mechanism
impact: MEDIUM
impactDescription: .tint() at the app root colors every interactive element (buttons, toggles, links, progress views) with a single line — the lightest possible brand integration
tags: theme, tint, brand, accent-color, minimal
---

## Use .tint() as the Primary Brand Expression Mechanism

Apple designed `.tint()` as the single point of brand expression for iOS apps. Applied at the root of the view hierarchy, it propagates to every `Button`, `Toggle`, `Link`, `ProgressView`, `Slider`, and `Stepper` in the app. This is the highest-leverage line of code in your design system — one modifier, total brand consistency across all interactive controls.

**Incorrect (manually applying brand color to each interactive element):**

```swift
struct CheckoutView: View {
    @State private var agreeToTerms = false
    @State private var quantity = 1

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Must remember to apply brand color to every control
            Toggle("I agree to terms", isOn: $agreeToTerms)
                .tint(Color("brandTeal"))           // Manual per-control

            Stepper("Quantity: \(quantity)", value: $quantity, in: 1...10)
                .tint(Color("brandTeal"))           // Easy to forget

            Button("Place Order") { placeOrder() }
                .buttonStyle(.borderedProminent)
                .tint(Color("brandTeal"))           // Repetitive

            // This link was missed — still shows default blue
            Link("View return policy", destination: returnPolicyURL)

            if isLoading {
                ProgressView()
                    .tint(Color("brandTeal"))       // Even more repetition
            }
        }
    }
}
```

**Correct (.tint() at app root, all controls inherit automatically):**

```swift
@main
struct ShopApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(.accentPrimary)   // One line — every control is branded
        }
    }
}

// All interactive elements automatically use the tint color
@Equatable
struct CheckoutView: View {
    @State private var agreeToTerms = false
    @State private var quantity = 1

    var body: some View {
        VStack(spacing: Spacing.md) {
            Toggle("I agree to terms", isOn: $agreeToTerms)  // Branded ✓

            Stepper("Quantity: \(quantity)", value: $quantity, in: 1...10)  // Branded ✓

            Button("Place Order") { placeOrder() }
                .buttonStyle(.borderedProminent)  // Branded ✓

            Link("View return policy", destination: returnPolicyURL)  // Branded ✓

            if isLoading {
                ProgressView()  // Branded ✓
            }
        }
    }
}

// Override tint for specific subtrees when needed
struct DestructiveSection: View {
    var body: some View {
        VStack {
            Button("Delete Account", role: .destructive) {
                deleteAccount()
            }
        }
        .tint(.red)  // Override for this subtree only
    }
}
```

**Controls that respond to .tint():**

| Control | Tint Effect |
|---------|------------|
| `Button` (.borderedProminent) | Background fill color |
| `Button` (.bordered, .borderless) | Label color |
| `Toggle` | On-state fill color |
| `Slider` | Track fill and thumb highlight |
| `Stepper` | Button tint |
| `ProgressView` | Indicator color |
| `Link` | Text color |
| `DatePicker` | Selection highlight |
| `Picker` (segmented) | Selected segment |

The `.tint()` modifier follows the SwiftUI environment inheritance model — apply it once at the top, override in subtrees where needed.
