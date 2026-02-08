---
title: Extract Repeated Modifiers into Custom ViewModifiers
impact: HIGH
impactDescription: reduces duplication, centralizes styling changes
tags: view, modifier, viewmodifier, styling, dry
---

## Extract Repeated Modifiers into Custom ViewModifiers

When the same chain of modifiers appears on multiple views, every styling change requires updating every occurrence. A single missed occurrence creates visual inconsistency. Extracting the chain into a custom ViewModifier centralizes the style definition so changes propagate everywhere automatically.

**Incorrect (duplicated modifier chains across multiple views):**

```swift
struct DashboardView: View {
    let metrics: [Metric]

    var body: some View {
        VStack(spacing: 16) {
            Text("Revenue: \(metrics[0].formatted)")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)

            Text("Users: \(metrics[1].formatted)")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)

            Text("Orders: \(metrics[2].formatted)")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
    }
}
```

**Correct (single ViewModifier applied via a View extension):**

```swift
struct MetricCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}

extension View {
    func metricCardStyle() -> some View {
        modifier(MetricCardStyle())
    }
}

struct DashboardView: View {
    let metrics: [Metric]

    var body: some View {
        VStack(spacing: 16) {
            Text("Revenue: \(metrics[0].formatted)").metricCardStyle()
            Text("Users: \(metrics[1].formatted)").metricCardStyle()
            Text("Orders: \(metrics[2].formatted)").metricCardStyle()
        }
    }
}
```

Reference: [ViewModifier](https://developer.apple.com/documentation/swiftui/viewmodifier)
