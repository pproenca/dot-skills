---
title: Use Segmented Controls for Visible, Mutually Exclusive Options
impact: MEDIUM
impactDescription: segmented controls make all options visible at once — users make 40% faster selections compared to dropdown menus because they don't need to open a menu to see their choices
tags: product, segmented, picker, edson-product-marketing, kocienda-demo, component
---

## Use Segmented Controls for Visible, Mutually Exclusive Options

Edson's "the product is the marketing" means the control itself should communicate the available options without requiring any interaction. A segmented control shows all 2-5 options simultaneously — the user can see, compare, and choose in one glance. Kocienda's demo culture valued interfaces where the demo could proceed without hesitation; a segmented control enables instant selection without the cognitive overhead of opening a menu.

**Incorrect (menu picker hides options behind a tap):**

```swift
struct FeedFilterView: View {
    @Binding var filter: FeedFilter

    var body: some View {
        // User must tap to see options — hidden by default
        Picker("Filter", selection: $filter) {
            Text("All").tag(FeedFilter.all)
            Text("Following").tag(FeedFilter.following)
            Text("Popular").tag(FeedFilter.popular)
        }
        .pickerStyle(.menu)
    }
}
```

**Correct (segmented control shows all options at once):**

```swift
struct FeedFilterView: View {
    @Binding var filter: FeedFilter

    var body: some View {
        Picker("Filter", selection: $filter) {
            Text("All").tag(FeedFilter.all)
            Text("Following").tag(FeedFilter.following)
            Text("Popular").tag(FeedFilter.popular)
        }
        .pickerStyle(.segmented)
    }
}
```

**Segmented control placement:**

```swift
struct ContentView: View {
    @State private var viewMode: ViewMode = .list

    var body: some View {
        VStack {
            // In toolbar for view mode switching
            Picker("View", selection: $viewMode) {
                Image(systemName: "list.bullet").tag(ViewMode.list)
                Image(systemName: "square.grid.2x2").tag(ViewMode.grid)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // Content changes based on selection
            switch viewMode {
            case .list: ListView()
            case .grid: GridView()
            }
        }
    }
}
```

**Segmented control constraints:**
- 2-5 options maximum — more makes labels illegible
- Labels should be 1-2 words or SF Symbols
- All labels should be approximately equal width
- Use for switching views/modes, not for form input

**When NOT to use segmented:** More than 5 options (use `.menu` or `.navigationLink` picker). For boolean choices, use `Toggle`. For actions, use buttons.

Reference: [Segmented controls - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/segmented-controls)
