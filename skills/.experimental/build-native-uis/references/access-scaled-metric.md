---
title: Use @ScaledMetric for Size-Adaptive Values
impact: MEDIUM
impactDescription: scales numeric values proportionally with Dynamic Type setting
tags: access, scaled-metric, dynamic-type, spacing, icon-size
---

## Use @ScaledMetric for Size-Adaptive Values

Dynamic Type scales text automatically, but hardcoded spacing, padding, and icon sizes stay fixed. This creates visual imbalance when users increase their text size: large text with tiny icons or cramped padding. `@ScaledMetric` scales any numeric value proportionally with the user's Dynamic Type setting.

**Incorrect (hardcoded icon size stays fixed at all text sizes):**

```swift
struct CategoryLabel: View {
    let category: Category

    var body: some View {
        Label {
            Text(category.name)
                .font(.body)
        } icon: {
            Image(systemName: category.icon)
                .frame(width: 24, height: 24)
                .padding(6)
                .background(category.color.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}
```

**Correct (@ScaledMetric values grow with Dynamic Type):**

```swift
struct CategoryLabel: View {
    let category: Category
    @ScaledMetric private var iconSize: CGFloat = 24 // scales with Dynamic Type
    @ScaledMetric private var iconPadding: CGFloat = 6

    var body: some View {
        Label {
            Text(category.name)
                .font(.body)
        } icon: {
            Image(systemName: category.icon)
                .frame(width: iconSize, height: iconSize)
                .padding(iconPadding)
                .background(category.color.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
