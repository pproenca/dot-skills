---
title: Choose the Right Picker Style
impact: HIGH
impactDescription: prevents poor UX from mismatched picker for data type
tags: comp, picker, segmented, wheel, menu, selection
---

## Choose the Right Picker Style

SwiftUI offers multiple picker styles. Choose based on the number of options and frequency of change.

**Incorrect (menu for frequently-changed options):**

```swift
struct FilterView: View {
    @State private var timeRange = TimeRange.week

    var body: some View {
        Picker("Time Range", selection: $timeRange) {
            Text("Day").tag(TimeRange.day)
            Text("Week").tag(TimeRange.week)
            Text("Month").tag(TimeRange.month)
        }
        .pickerStyle(.menu)  // Hidden in menu, requires tap to see options
        // User can't quickly switch between common options
    }
}
```

**Correct (segmented for 2-5 frequent options):**

```swift
struct FilterView: View {
    @State private var timeRange = TimeRange.week

    var body: some View {
        Picker("Time Range", selection: $timeRange) {
            Text("Day").tag(TimeRange.day)
            Text("Week").tag(TimeRange.week)
            Text("Month").tag(TimeRange.month)
        }
        .pickerStyle(.segmented)  // Always visible, one-tap switching
    }
}
```

**Use menu for infrequent selections:**

```swift
struct SortOptions: View {
    @State private var sortOrder = SortOrder.dateDescending

    var body: some View {
        Picker("Sort By", selection: $sortOrder) {
            ForEach(SortOrder.allCases) { order in
                Text(order.displayName).tag(order)
            }
        }
        .pickerStyle(.menu)  // Compact, 10+ options
    }
}
```

**Decision matrix:**

| Options | Frequency | Style |
|---------|-----------|-------|
| 2-5 | High | .segmented |
| 3-15 | Low-Medium | .menu |
| Dates/times | Any | .wheel or .graphical |
| 15+ | Any | Navigation to list |

Reference: [Human Interface Guidelines - Pickers](https://developer.apple.com/design/human-interface-guidelines/pickers)
