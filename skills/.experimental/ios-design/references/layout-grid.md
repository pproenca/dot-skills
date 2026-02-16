---
title: Use Grid for Aligned Non-Scrolling Tabular Content
impact: HIGH
impactDescription: VStack of HStacks cannot align columns — Grid provides automatic column alignment that keeps labels and values perfectly lined up across rows
tags: layout, grid, table, alignment, edson-design-out-loud, kocienda-intersection
---

## Use Grid for Aligned Non-Scrolling Tabular Content

Edson's "Design Out Loud" means choosing the layout tool that expresses the content's structure. When data has rows and columns — spec sheets, comparison tables, form summaries — `Grid` (iOS 16+) provides automatic column alignment that `VStack` of `HStack`s cannot achieve. Kocienda's intersection of technology and liberal arts demands that tabular data be presented with the visual clarity of a well-set table, not the ragged edges of manually positioned text.

**Incorrect (VStack/HStack — columns don't align):**

```swift
struct SpecSheet: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Weight").foregroundStyle(.secondary)
                Text("364 g")
            }
            HStack {
                Text("Dimensions").foregroundStyle(.secondary)
                Text("160.8 × 78.1 × 7.65 mm")
            }
            HStack {
                Text("Display").foregroundStyle(.secondary)
                Text("6.7\" Super Retina XDR")
            }
            // "Weight" and "Dimensions" are different lengths
            // so values don't align vertically
        }
    }
}
```

**Correct (Grid — columns automatically align):**

```swift
struct SpecSheet: View {
    var body: some View {
        Grid(alignment: .leading, verticalSpacing: 8) {
            GridRow {
                Text("Weight")
                    .foregroundStyle(.secondary)
                Text("364 g")
            }
            GridRow {
                Text("Dimensions")
                    .foregroundStyle(.secondary)
                Text("160.8 × 78.1 × 7.65 mm")
            }
            GridRow {
                Text("Display")
                    .foregroundStyle(.secondary)
                Text("6.7\" Super Retina XDR")
            }
        }
    }
}
```

**Grid features:**

```swift
// Spanning multiple columns
GridRow {
    Text("Full-width note")
        .gridCellColumns(2)
        .font(.caption)
        .foregroundStyle(.secondary)
}

// Custom column alignment
Grid(alignment: .leading) {
    GridRow(alignment: .firstTextBaseline) {
        Text("Label")
        Text("Multi-line\nvalue text")
    }
}
```

**When NOT to use Grid:** For scrollable content with many items, use `LazyVGrid`. Grid loads all content at once and is designed for small, fixed datasets (< 50 rows).

Reference: [Grid - Apple Documentation](https://developer.apple.com/documentation/swiftui/grid)
