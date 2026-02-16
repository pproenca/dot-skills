---
title: Choose Grid for Aligned Data, LazyVGrid for Scrollable Collections
impact: HIGH
impactDescription: LazyVGrid reduces memory from O(n) to O(visible) — for 500 items, this cuts peak memory by 80-90% and initial render time from 800ms+ to under 50ms vs Grid which allocates all items upfront
tags: taste, grid, lazygrid, kocienda-taste, edson-conviction, layout, performance
---

## Choose Grid for Aligned Data, LazyVGrid for Scrollable Collections

Kocienda's taste means choosing based on the data's nature, not developer convenience. `Grid` (iOS 16+) creates an aligned, non-scrolling table where columns stay perfectly aligned — ideal for structured data like spec sheets, comparison tables, and stat rows. `LazyVGrid` creates a scrollable grid that loads items on demand — ideal for photo galleries, product catalogs, and any collection that might grow. Using Grid for 500 photos causes memory problems; using LazyVGrid for a 6-row spec table adds unnecessary complexity.

**Incorrect (using Grid for a large scrollable collection — loads all items at once):**

```swift
struct PhotoGallery: View {
    let photos: [Photo] // Could be 500+ photos

    var body: some View {
        ScrollView {
            Grid {
                // Grid loads ALL 500 photos into memory at once
                ForEach(photos) { photo in
                    GridRow {
                        AsyncImage(url: photo.url)
                    }
                }
            }
        }
    }
}
```

**Correct (LazyVGrid loads items on demand for scrollable collections):**

```swift
struct PhotoGallery: View {
    let photos: [Photo]
    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 2)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(photos) { photo in
                    AsyncImage(url: photo.thumbnailURL) { image in
                        image.resizable().scaledToFill()
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

**Grid for aligned tabular data (small, fixed dataset):**

```swift
struct NutritionLabel: View {
    let nutrients: [Nutrient]

    var body: some View {
        Grid(alignment: .leading, verticalSpacing: 8) {
            GridRow {
                Text("Nutrient").font(.caption.bold())
                Text("Amount").font(.caption.bold())
                Text("Daily %").font(.caption.bold())
            }

            Divider().gridCellColumns(3)

            ForEach(nutrients) { nutrient in
                GridRow {
                    Text(nutrient.name)
                    Text(nutrient.amount)
                    Text(nutrient.dailyPercent)
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
            }
        }
        .padding()
    }
}
```

**LazyVGrid for scrollable collections (dynamic, 50-10,000+ items):**

```swift
struct PhotoGalleryView: View {
    let photos: [Photo]
    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 2)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(photos) { photo in
                    AsyncImage(url: photo.thumbnailURL) { image in
                        image.resizable().scaledToFill()
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

**Decision framework:**
| Data Size | Scrolling | Alignment Needed | Choose |
|-----------|-----------|-----------------|--------|
| <50 items | No | Column alignment | `Grid` |
| Any size | Yes | Not critical | `LazyVGrid` |
| Any size | Yes | Column alignment | `LazyVGrid` with fixed columns |

**When NOT to choose:** For a simple vertical list of items, use `List` or `LazyVStack` instead of either grid. Grids are for multi-column layouts.

Reference: [Grid - Apple Documentation](https://developer.apple.com/documentation/swiftui/grid), [LazyVGrid - Apple Documentation](https://developer.apple.com/documentation/swiftui/lazyvgrid)
