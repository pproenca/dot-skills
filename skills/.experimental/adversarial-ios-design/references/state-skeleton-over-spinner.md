---
title: Show placeholder content while loading, not a whole-screen spinner
tags: state, loading, redacted, skeleton
---

## Show placeholder content while loading, not a whole-screen spinner

The wrong default for a content fetch is `if isLoading { ProgressView() } else { content }` at the screen root — a lone centered spinner replacing the entire screen. The HIG's direction is to show something as soon as possible: a blank screen with a spinner reads as a problem with the app, and the layout jump when content arrives makes the wait feel longer than it was. When the loaded layout's shape is known — a list, a grid, a detail screen of fixed structure — render placeholder data through that same layout with `.redacted(reason: .placeholder)`, or show cached/partial content immediately and scope an indicator to the region still loading.

**Evidence of violation:** the root of a content screen conditionally swaps all content for a bare `ProgressView()` (or equivalent full-screen spinner overlay) during initial load, while the loaded branch renders a layout of known shape (list, grid, detail of fixed structure) — cite the conditional and the loaded branch it hides. PASS: placeholder models rendered through the real layout under `.redacted(reason: .placeholder)`; cached or partial content shown immediately with a progress indicator scoped to the still-loading region — the reviewer must cite the placeholder or scoped-indicator mechanism. N/A: the loaded content's shape is genuinely unknowable before the response arrives (e.g. a server-driven layout), or the operation blocks all interaction by nature — the reviewer must cite why the shape is unknowable; absent that evidence, fail closed. N/A: no asynchronous content load in the target.

**Incorrect (a blank screen with a spinner, then a layout jump when content lands):**

```swift
import SwiftUI

struct Restaurant: Identifiable {
    let id = UUID()
    var name = ""
    var cuisine = ""
    var deliveryEstimate = ""
}

struct NearbyRestaurantsView: View {
    let restaurants: [Restaurant]
    let isLoading: Bool

    var body: some View {
        // ⚠️ The entire screen collapses to a spinner while loading
        if isLoading {
            ProgressView()
        } else {
            List(restaurants) { restaurant in
                VStack(alignment: .leading) {
                    Text(restaurant.name).font(.headline)
                    Text("\(restaurant.cuisine) · \(restaurant.deliveryEstimate)")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
```

**Correct (the known layout renders immediately as a skeleton and fills in place):**

```swift
import SwiftUI

struct Restaurant: Identifiable {
    let id = UUID()
    var name = ""
    var cuisine = ""
    var deliveryEstimate = ""
}

extension Restaurant {
    static let placeholders: [Restaurant] = (0..<6).map { _ in
        Restaurant(name: "Restaurant Name", cuisine: "Cuisine", deliveryEstimate: "25–35 min")
    }
}

struct NearbyRestaurantsView: View {
    let restaurants: [Restaurant]
    let isLoading: Bool

    var body: some View {
        List(isLoading ? Restaurant.placeholders : restaurants) { restaurant in
            VStack(alignment: .leading) {
                Text(restaurant.name).font(.headline)
                Text("\(restaurant.cuisine) · \(restaurant.deliveryEstimate)")
                    .foregroundStyle(.secondary)
            }
        }
        .redacted(reason: isLoading ? .placeholder : [])
    }
}
```

Reference: [HIG — Loading](https://developer.apple.com/design/human-interface-guidelines/loading), [redacted(reason:)](https://developer.apple.com/documentation/swiftui/view/redacted(reason:))
