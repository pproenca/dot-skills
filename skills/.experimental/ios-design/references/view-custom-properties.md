---
title: Use Properties to Make Views Configurable
impact: CRITICAL
impactDescription: enables view reuse across the app, prevents duplication
tags: view, swiftui, reuse, properties, configuration, parameters
---

## Use Properties to Make Views Configurable

Hardcoding text, colors, and images inside a view creates a one-off component that must be duplicated whenever the same layout is needed with different content. Exposing stored properties turns a view into a reusable template that call sites can configure, eliminating copy-paste drift.

**Incorrect (hardcoded values make the view single-use):**

```swift
struct FeatureCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "star.fill")
                .font(.title)
                .foregroundStyle(.yellow)
            Text("Premium Feature")
                .font(.headline)
            Text("Unlock advanced analytics and reporting tools.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

**Correct (properties make the view reusable across screens):**

```swift
struct FeatureCard: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: iconName)
                .font(.title)
                .foregroundStyle(iconColor)
            Text(title)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Call sites configure each instance
FeatureCard(
    iconName: "star.fill",
    iconColor: .yellow,
    title: "Premium Feature",
    description: "Unlock advanced analytics and reporting tools."
)

FeatureCard(
    iconName: "lock.shield",
    iconColor: .green,
    title: "Secure Storage",
    description: "End-to-end encrypted file storage for your team."
)
```

**Property patterns:**
- Stored properties for data input
- Computed properties for derived values
- Default values for optional customization
- Use structs for models to group related properties

Reference: [Develop in Swift Tutorials - Customize views with properties](https://developer.apple.com/tutorials/develop-in-swift/customize-views-with-properties)
