---
title: "Use Grid for Aligned Tabular Layouts"
impact: CRITICAL
impactDescription: "enables tabular alignment for 2-4 columns without manual offset calculations"
tags: layout, grid, tables, alignment, settings
---

## Use Grid for Aligned Tabular Layouts

Building table-like layouts with nested HStacks requires manually matching widths across rows, which breaks when content length changes or dynamic type is enabled. The `Grid` container automatically sizes each column to fit the widest cell, keeping all rows aligned without any hardcoded dimensions. This is the right tool for settings screens, data tables, and any row-column layout.

**Incorrect (hardcoded widths break when content or text size changes):**

```swift
struct SystemInfoView: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Device")
                    .frame(width: 100, alignment: .leading) // breaks with longer labels
                Text("iPhone 15 Pro")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Text("Storage")
                    .frame(width: 100, alignment: .leading)
                Text("256 GB")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Text("Battery Health")
                    .frame(width: 100, alignment: .leading) // truncated at larger text sizes
                Text("98%")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Text("OS Version")
                    .frame(width: 100, alignment: .leading)
                Text("iOS 18.2")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
}
```

**Correct (Grid auto-sizes columns to the widest cell in each column):**

```swift
struct SystemInfoView: View {
    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
            GridRow {
                Text("Device")
                    .foregroundStyle(.secondary)
                Text("iPhone 15 Pro") // column width adapts to longest value
            }
            GridRow {
                Text("Storage")
                    .foregroundStyle(.secondary)
                Text("256 GB")
            }
            GridRow {
                Text("Battery Health")
                    .foregroundStyle(.secondary)
                Text("98%")
            }
            GridRow {
                Text("OS Version")
                    .foregroundStyle(.secondary)
                Text("iOS 18.2")
            }
        }
        .padding()
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
