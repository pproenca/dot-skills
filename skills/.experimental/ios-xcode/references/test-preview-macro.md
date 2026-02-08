---
title: Use #Preview Macro for Live Development
impact: HIGH
impactDescription: instant visual feedback reduces iteration time by 5-10x, catches edge cases before QA
tags: test, swiftui, preview, development, iteration, xcode
---

## Use #Preview Macro for Live Development

Without previews, every visual change requires a full build-and-run cycle on a simulator. The `#Preview` macro renders the view directly in Xcode's canvas, giving sub-second feedback on layout and styling changes. Supplying realistic sample data in previews catches edge cases like long text and missing images before they reach QA.

**Incorrect (no preview, must build and run to see changes):**

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello")
    }
}

// No preview - must run app to see changes
```

**Correct (preview for rapid iteration):**

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

// Multiple previews for different states
#Preview("Light Mode") {
    ContentView()
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}

// Preview with sample data
#Preview("With User") {
    ProfileView(user: User(name: "Sophie", email: "sophie@example.com"))
}
```

**Previews with varied sample data for edge-case coverage:**

```swift
struct OrderSummaryCard: View {
    let itemName: String
    let quantity: Int
    let priceInCents: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(itemName)
                    .font(.headline)
                Text("Qty: \(quantity)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("$\(priceInCents / 100).\(String(format: "%02d", priceInCents % 100))")
                .font(.title3).bold()
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 2)
    }
}

#Preview("Standard Item") {
    OrderSummaryCard(itemName: "Wireless Charger", quantity: 1, priceInCents: 2999)
        .padding()
}

#Preview("Long Name & High Qty") { // catches truncation and layout overflow
    OrderSummaryCard(itemName: "Ultra-Premium Noise-Cancelling Headphones Pro Max", quantity: 150, priceInCents: 34999)
        .padding()
}
```

**Preview modes:**
- **Live Mode**: Interactive - tap buttons, scroll lists
- **Selectable Mode**: Click elements to highlight corresponding code
- **Variants**: Test different dynamic type sizes, color schemes

**Tips:**
- Press Option + Command + P to refresh preview
- Pin previews to keep them visible while editing other files
- Use `.previewLayout(.sizeThatFits)` for component-sized previews

Reference: [Develop in Swift Tutorials - Hello, SwiftUI](https://developer.apple.com/tutorials/develop-in-swift/hello-swiftui)
