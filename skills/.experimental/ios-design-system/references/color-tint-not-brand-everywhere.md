---
title: Set Brand Color as App Tint, Don't Scatter It
impact: CRITICAL
impactDescription: brand color applied via .tint() at app root automatically colors every interactive element — manual application creates 50+ callsites that drift independently
tags: color, brand, tint, accent-color, app-level
---

## Set Brand Color as App Tint, Don't Scatter It

SwiftUI's `.tint()` modifier cascades through the entire view hierarchy. Setting it once at the app root automatically colors every `Button`, `Toggle`, `Link`, `ProgressView`, `Stepper`, `Slider`, `DatePicker`, `NavigationLink`, and `TabView` icon. When developers manually apply brand color to each interactive element instead, the app accumulates 50+ individual color callsites that can independently drift to the wrong shade, miss updates during a rebrand, or disagree with each other.

**Incorrect (brand color applied manually to each interactive element):**

```swift
struct CheckoutView: View {
    @State private var agreeToTerms = false
    @State private var quantity = 1

    var body: some View {
        VStack(spacing: 16) {
            Stepper("Quantity: \(quantity)", value: $quantity, in: 1...10)
                .tint(Color("brandPurple"))                          // Manual tint #1

            Toggle("I agree to terms", isOn: $agreeToTerms)
                .tint(Color("brandPurple"))                          // Manual tint #2

            Button("Place Order") { placeOrder() }
                .buttonStyle(.borderedProminent)
                .tint(Color("brandPurple"))                          // Manual tint #3

            NavigationLink("View order history") {
                OrderHistoryView()
            }
            .foregroundStyle(Color("brandPurple"))                   // Manual tint #4 (wrong API)

            if isProcessing {
                ProgressView()
                    .tint(Color("brandPurple"))                      // Manual tint #5
            }
        }
    }
}
// 5 callsites in one view. 40 views = 200 callsites to maintain.
// Developer on another screen uses Color("brandBlue") — now there are two brand colors.
```

**Correct (tint set once at app root):**

```swift
@main
struct ShopApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(.accentPrimary)   // Single source of truth for brand color
        }
    }
}

// Every view inherits the tint automatically — zero manual color application
struct CheckoutView: View {
    @State private var agreeToTerms = false
    @State private var quantity = 1

    var body: some View {
        VStack(spacing: Spacing.md) {
            Stepper("Quantity: \(quantity)", value: $quantity, in: 1...10)
            // Stepper inherits .accentPrimary tint ✓

            Toggle("I agree to terms", isOn: $agreeToTerms)
            // Toggle inherits .accentPrimary tint ✓

            Button("Place Order") { placeOrder() }
                .buttonStyle(.borderedProminent)
            // Button inherits .accentPrimary tint ✓

            NavigationLink("View order history") {
                OrderHistoryView()
            }
            // NavigationLink inherits .accentPrimary tint ✓

            if isProcessing {
                ProgressView()
                // ProgressView inherits .accentPrimary tint ✓
            }
        }
    }
}
// 0 manual tint applications. Brand color changes in 1 place.
```

**Overriding tint for specific elements (when genuinely needed):**

```swift
struct NotificationBanner: View {
    let type: BannerType

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: type.iconName)
                .foregroundStyle(type.color)     // Status color overrides brand tint

            Text(type.message)
                .foregroundStyle(.textPrimary)

            Spacer()

            Button("Dismiss") { dismiss() }
            // This button still uses the app tint — correct for interactive elements
        }
        .padding(Spacing.md)
        .background(type.color.opacity(0.12))
    }
}

enum BannerType {
    case success, warning, error

    var color: Color {
        switch self {
        case .success: .statusSuccess    // Green — overrides brand tint for status
        case .warning: .statusWarning    // Amber — overrides brand tint for status
        case .error: .statusError        // Red — overrides brand tint for status
        }
    }

    var iconName: String {
        switch self {
        case .success: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .error: "xmark.circle.fill"
        }
    }
}
```

**Alternative: AccentColor in asset catalog:**

```text
// You can also set the global accent color via the asset catalog:
// Assets.xcassets/AccentColor.colorset — Xcode uses this as the default tint
// This works, but .tint() in code is more explicit and discoverable.
// The recommendation is to use BOTH:
// 1. AccentColor in asset catalog (for storyboards, Info.plist references)
// 2. .tint() at app root (for SwiftUI, explicit and greppable)
```

**Benefits:**
- Rebrand: change 1 line (`.tint(.newBrandColor)`), every interactive element updates instantly
- Consistency: impossible for one screen to use a different brand shade than another
- Less code: views are shorter and more focused on layout, not color management
- Correct by default: new views automatically get the brand color without any developer action

Reference: [tint(_:) — Apple Developer](https://developer.apple.com/documentation/swiftui/view/tint(_:)-93mfq), [WWDC22 — What's new in SwiftUI](https://developer.apple.com/videos/play/wwdc2022/10052/)
