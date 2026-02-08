---
title: Migrate to New onChange Signature
impact: CRITICAL
impactDescription: eliminates deprecation warnings, enables initial-value handling
tags: api, onchange, deprecated, lifecycle, migration
---

## Migrate to New onChange Signature

The original onChange(of:perform:) closure receives only the new value and was deprecated in iOS 17. The new onChange(of:initial:_:) provides both old and new values, enabling diff-based logic without manual state tracking. Setting initial: true fires the closure on view appearance, consolidating separate onAppear + onChange handlers into a single modifier.

**Incorrect (deprecated single-value closure):**

```swift
struct SearchView: View {
    @State private var query: String = ""
    @State private var selectedCategory: Category = .all

    var body: some View {
        VStack {
            TextField("Search", text: $query)
            CategoryPicker(selection: $selectedCategory)
        }
        .onAppear {
            performSearch(query: query, category: selectedCategory)
        }
        .onChange(of: query) { newValue in
            performSearch(query: newValue, category: selectedCategory)
        }
        .onChange(of: selectedCategory) { newValue in
            performSearch(query: query, category: newValue)
        }
    }
}
```

**Correct (new signature with old/new values and initial firing):**

```swift
struct SearchView: View {
    @State private var query: String = ""
    @State private var selectedCategory: Category = .all

    var body: some View {
        VStack {
            TextField("Search", text: $query)
            CategoryPicker(selection: $selectedCategory)
        }
        .onChange(of: query, initial: true) { oldValue, newValue in
            performSearch(query: newValue, category: selectedCategory)
        }
        .onChange(of: selectedCategory, initial: true) { oldValue, newValue in
            performSearch(query: query, category: newValue)
        }
        // Eliminates the double-trigger risk from separate onAppear + onChange
    }
}
```

Reference: [onChange(of:perform:)](https://developer.apple.com/documentation/swiftui/view/onchange(of:perform:))
