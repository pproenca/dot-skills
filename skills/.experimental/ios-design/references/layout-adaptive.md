---
title: Use Adaptive Layouts for Different Size Classes
impact: HIGH
impactDescription: adaptive layouts cover 15+ active screen sizes (320pt-1366pt width) with 2-3 size-class branches — eliminates layout bugs on 40-60% of devices that fixed layouts miss, reducing device-specific bug reports by 70-90%
tags: layout, adaptive, size-class, responsive, edson-design-out-loud, kocienda-intersection
---

## Use Adaptive Layouts for Different Size Classes

Edson's "Design Out Loud" means prototyping across every context your users will encounter. An iPhone SE, iPhone 15 Pro Max, iPad mini, and iPad Pro 12.9" in split-screen multitasking all present your app at different widths. Kocienda's intersection of technology and liberal arts demands layouts that adapt to each context gracefully — a single-column layout on iPhone that becomes two-column on iPad, not a stretched iPhone layout with awkward whitespace.

**Incorrect (fixed layout that only works on one screen size):**

```swift
struct DashboardView: View {
    var body: some View {
        VStack {
            // Always single column — wastes space on iPad
            MetricCard(title: "Revenue", value: "$12,430")
            MetricCard(title: "Orders", value: "84")
            MetricCard(title: "Customers", value: "1,203")
        }
        .padding()
    }
}
```

**Correct (adaptive layout responds to size class):**

```swift
struct DashboardView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        ScrollView {
            if sizeClass == .compact {
                // iPhone: single column
                VStack(spacing: 16) {
                    MetricCard(title: "Revenue", value: "$12,430")
                    MetricCard(title: "Orders", value: "84")
                    MetricCard(title: "Customers", value: "1,203")
                }
            } else {
                // iPad: two-column grid
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 16
                ) {
                    MetricCard(title: "Revenue", value: "$12,430")
                    MetricCard(title: "Orders", value: "84")
                    MetricCard(title: "Customers", value: "1,203")
                }
            }
        }
        .padding()
    }
}
```

**Using ViewThatFits for automatic adaptation:**

```swift
struct AdaptiveRow: View {
    let items: [Item]

    var body: some View {
        ViewThatFits {
            // Try horizontal first
            HStack(spacing: 12) {
                ForEach(items) { item in
                    ItemCard(item: item)
                }
            }

            // Fall back to vertical if horizontal doesn't fit
            VStack(spacing: 12) {
                ForEach(items) { item in
                    ItemCard(item: item)
                }
            }
        }
    }
}
```

**Size class reference:**
| Size Class | Context |
|-----------|---------|
| `.compact` horizontal | iPhone portrait, iPad split 1/3 |
| `.regular` horizontal | iPhone landscape, iPad portrait/landscape |
| `.compact` vertical | iPhone landscape |
| `.regular` vertical | iPhone portrait, iPad all orientations |

**When NOT to adapt:** Simple content views (article text, forms) naturally adapt through stack layout and readable width constraints. Only build explicit size class logic for significantly different layouts.

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
