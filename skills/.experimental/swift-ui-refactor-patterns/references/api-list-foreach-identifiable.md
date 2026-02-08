---
title: "Replace id: \\.self with Identifiable Conformance"
impact: CRITICAL
impactDescription: prevents animation glitches and incorrect diffing on data mutations
tags: api, list, foreach, identifiable, diffing
---

## Replace id: \.self with Identifiable Conformance

Using `id: \.self` or `id: \.name` in `ForEach` relies on hash-based identity. When two items share the same value, or when a value changes in place, SwiftUI cannot distinguish them and produces incorrect diffs -- rows jump, animations glitch, and state binds to the wrong element. Conforming your model to `Identifiable` with a stable `UUID` gives every item a permanent identity that survives mutations and duplicates.

**Incorrect (hash-based identity breaks on duplicates and mutations):**

```swift
struct GroceryListView: View {
    @State private var items = ["Milk", "Eggs", "Milk", "Bread"]

    var body: some View {
        List {
            // "Milk" appears twice -- SwiftUI sees identical hashes
            ForEach(items, id: \.self) { item in
                Text(item)
            }
            .onDelete { offsets in
                // Deleting one "Milk" may remove the wrong row
                items.remove(atOffsets: offsets)
            }
        }
    }
}
```

**Correct (stable UUID identity survives mutations and duplicates):**

```swift
struct GroceryItem: Identifiable {
    let id = UUID()
    var name: String
}

struct GroceryListView: View {
    @State private var items = [
        GroceryItem(name: "Milk"),
        GroceryItem(name: "Eggs"),
        GroceryItem(name: "Milk"),
        GroceryItem(name: "Bread"),
    ]

    var body: some View {
        List {
            // Each item has a unique id -- duplicates diff correctly
            ForEach(items) { item in
                Text(item.name)
            }
            .onDelete { offsets in
                items.remove(atOffsets: offsets)
            }
        }
    }
}
```

**Why `\.self` is unreliable:**
- Duplicate values produce identical hashes, so SwiftUI cannot tell them apart
- Renaming an item in place changes its hash, which SwiftUI interprets as a delete + insert instead of an update, breaking animations
- `\.self` on reference types uses `ObjectIdentifier`, which is stable but still prevents correct animated reordering

Reference: [ForEach - Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/foreach)
