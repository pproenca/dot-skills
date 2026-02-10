---
title: Use Segmented Controls for Mutually Exclusive Options
impact: MEDIUM
impactDescription: enables instant switching between 2-5 views without navigation
tags: comp, segmented-control, picker, toggle
---

## Use Segmented Controls for Mutually Exclusive Options

Use segmented controls for switching between 2-5 mutually exclusive views or modes. Keep labels short and balanced in width.

**Incorrect (misusing segmented controls):**

```swift
// Too many segments
Picker("Filter", selection: $filter) {
    Text("All").tag(0)
    Text("Active").tag(1)
    Text("Pending").tag(2)
    Text("Complete").tag(3)
    Text("Cancelled").tag(4)
    Text("Archived").tag(5)
}
.pickerStyle(.segmented)
// 6 segments is too many

// Unbalanced label lengths
Picker("View", selection: $view) {
    Text("A").tag(0)
    Text("Calendar View").tag(1)
}
.pickerStyle(.segmented)
// Segments should be similar width

// For non-view switching
Picker("Color", selection: $color) {
    Text("Red").tag(Color.red)
    Text("Blue").tag(Color.blue)
}
.pickerStyle(.segmented)
// Not for selecting values - use regular Picker
```

**Correct (appropriate segmented control usage):**

```swift
// View switching
Picker("View", selection: $viewMode) {
    Text("List").tag(ViewMode.list)
    Text("Grid").tag(ViewMode.grid)
}
.pickerStyle(.segmented)

// Time range filter
Picker("Period", selection: $period) {
    Text("Day").tag(Period.day)
    Text("Week").tag(Period.week)
    Text("Month").tag(Period.month)
}
.pickerStyle(.segmented)

// Tab-like content switching
VStack {
    Picker("Section", selection: $section) {
        Text("Info").tag(Section.info)
        Text("Reviews").tag(Section.reviews)
        Text("Related").tag(Section.related)
    }
    .pickerStyle(.segmented)
    .padding()

    switch section {
    case .info: InfoView()
    case .reviews: ReviewsView()
    case .related: RelatedView()
    }
}

// For 2 options, consider Toggle instead
Toggle("Show Completed", isOn: $showCompleted)
```

**Segmented control guidelines:**
- 2-5 segments maximum
- Equal or similar width labels
- Use for view modes, not value selection
- Keep labels to one short word
- Consider Toggle for binary choices

Reference: [Segmented controls - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/segmented-controls)
