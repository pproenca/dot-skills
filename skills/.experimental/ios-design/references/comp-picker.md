---
title: Choose the Right Picker Style
impact: HIGH
impactDescription: prevents poor UX from mismatched picker for data type and context
tags: comp, picker, segmented, wheel, menu, selection, input
---

## Choose the Right Picker Style

SwiftUI offers multiple picker styles. Choose based on the number of options, frequency of change, and context.

**Incorrect (wrong picker for context):**

```swift
// Menu for frequently-changed options
Picker("Time Range", selection: $timeRange) {
    Text("Day").tag(TimeRange.day)
    Text("Week").tag(TimeRange.week)
    Text("Month").tag(TimeRange.month)
}
.pickerStyle(.menu)  // Hidden in menu, requires tap to see options

// Wheel picker for 3 options - overkill
Picker("Status", selection: $status) {
    Text("Active").tag(Status.active)
    Text("Inactive").tag(Status.inactive)
    Text("Pending").tag(Status.pending)
}
.pickerStyle(.wheel)  // Takes too much space
```

**Correct (segmented for 2-5 frequent options):**

```swift
Picker("Time Range", selection: $timeRange) {
    Text("Day").tag(TimeRange.day)
    Text("Week").tag(TimeRange.week)
    Text("Month").tag(TimeRange.month)
}
.pickerStyle(.segmented)  // Always visible, one-tap switching
```

**Use menu for infrequent selections:**

```swift
// Inline menu for moderate lists (5-15 items)
Form {
    Picker("Category", selection: $category) {
        ForEach(categories) { category in
            Text(category.name).tag(category)
        }
    }
}
// Uses .menu style by default in Form
```

**Use navigation link for long lists:**

```swift
NavigationLink {
    CountryPickerView(selection: $country)
} label: {
    HStack {
        Text("Country")
        Spacer()
        Text(country.name)
            .foregroundStyle(.secondary)
    }
}
```

**Date and time pickers:**

```swift
// Compact for inline date
DatePicker("Due Date", selection: $date)
    .datePickerStyle(.compact)

// Graphical for date range selection
DatePicker("Start", selection: $startDate)
    .datePickerStyle(.graphical)
```

**Decision matrix:**

| Options | Frequency | Context | Style |
|---------|-----------|---------|-------|
| 2-5 | High | View mode | `.segmented` |
| 3-15 | Low-Medium | Form row | `.menu` (default) |
| 15+ | Any | Selection | Navigation link |
| Dates/times | Any | Any | DatePicker |
| Color | Any | Any | ColorPicker |

Reference: [Human Interface Guidelines - Pickers](https://developer.apple.com/design/human-interface-guidelines/pickers)
