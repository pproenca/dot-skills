---
title: Use LazyVGrid for Scrollable Multi-Column Layouts
impact: HIGH
impactDescription: LazyVGrid loads items on demand, enabling smooth scrolling through thousands of items — non-lazy Grid loads everything at once, causing memory spikes and frozen UI
tags: layout, lazygrid, scrollable, performance, edson-design-out-loud, kocienda-intersection
---

## Use LazyVGrid for Scrollable Multi-Column Layouts

Edson's "Design Out Loud" means iterating on grid layouts until the spatial rhythm feels right. `LazyVGrid` is SwiftUI's scrollable grid — it creates multi-column layouts where items load on demand as they scroll into view. Kocienda's intersection principle applies: the grid must work technically (lazy loading for performance) and visually (consistent column sizes and spacing for rhythm).

**Incorrect (non-lazy grid for large scrollable collection — loads everything at once):**

```swift
struct ProductCatalog: View {
    let products: [Product] // Hundreds of products

    var body: some View {
        ScrollView {
            // VStack loads ALL products — causes memory spike and frozen UI
            VStack {
                ForEach(products) { product in
                    ProductCard(product: product)
                }
            }
        }
    }
}
```

**Correct (LazyVGrid loads items on demand with multi-column layout):**

```swift
struct ProductCatalog: View {
    let products: [Product]
    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(products) { product in
                    ProductCard(product: product)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
```

**Grid column configuration:**

```swift
// Fixed: exact width per column
let columns = [
    GridItem(.fixed(100)),
    GridItem(.fixed(100)),
    GridItem(.fixed(100))
]

// Flexible: minimum and maximum width per column
let columns = [
    GridItem(.flexible(minimum: 100, maximum: 200)),
    GridItem(.flexible(minimum: 100, maximum: 200))
]

// Adaptive: as many columns as fit with minimum width
let columns = [
    GridItem(.adaptive(minimum: 150), spacing: 12)
]
```

**Photo gallery example:**

```swift
struct PhotoGalleryView: View {
    let photos: [Photo]
    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 2)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(photos) { photo in
                    AsyncImage(url: photo.thumbnailURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color(.systemFill)
                    }
                    .frame(minHeight: 100)
                    .clipped()
                }
            }
        }
    }
}
```

**Product catalog with sections:**

```swift
struct CatalogView: View {
    let categories: [Category]
    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16, pinnedViews: [.sectionHeaders]) {
                ForEach(categories) { category in
                    Section {
                        ForEach(category.products) { product in
                            ProductCard(product: product)
                        }
                    } header: {
                        Text(category.name)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                            .background(.bar)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
```

**When NOT to use LazyVGrid:** For aligned tabular data with fixed rows, use `Grid`. For single-column scrollable lists, use `List` or `LazyVStack`.

Reference: [LazyVGrid - Apple Documentation](https://developer.apple.com/documentation/swiftui/lazyvgrid)
