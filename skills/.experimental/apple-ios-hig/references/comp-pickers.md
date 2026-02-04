---
title: Choose Appropriate Picker Styles
impact: MEDIUM
impactDescription: matches picker style to context and data type
tags: comp, picker, selection, input
---

## Choose Appropriate Picker Styles

Choose picker style based on the number of options and context. Use wheel pickers for long lists, menu pickers for moderate lists, and segmented for 2-5 view modes.

**Incorrect (wrong picker for context):**

```swift
// Wheel picker for 3 options - overkill
Picker("Status", selection: $status) {
    Text("Active").tag(Status.active)
    Text("Inactive").tag(Status.inactive)
    Text("Pending").tag(Status.pending)
}
.pickerStyle(.wheel)
// Takes too much space

// Menu picker for country list - hard to navigate
Picker("Country", selection: $country) {
    ForEach(countries, id: \.self) { country in
        Text(country)
    }
}
// Long list needs better navigation
```

**Correct (appropriate picker styles):**

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

// Navigation link for long lists
NavigationLink {
    CountryPickerView(selection: $country)
} label: {
    HStack {
        Text("Country")
        Spacer()
        Text(country.name)
            .foregroundColor(.secondary)
    }
}

// Wheel for date/time
DatePicker("Date", selection: $date)
    .datePickerStyle(.wheel)

// Compact for inline date
DatePicker("Due Date", selection: $date)
    .datePickerStyle(.compact)

// Graphical for date range selection
DatePicker("Start", selection: $startDate)
    .datePickerStyle(.graphical)

// Segmented for view modes (not data selection)
Picker("View", selection: $viewMode) {
    Text("List").tag(ViewMode.list)
    Text("Grid").tag(ViewMode.grid)
}
.pickerStyle(.segmented)
```

**Picker style guide:**
| Options | Context | Style |
|---------|---------|-------|
| 2-5 | View mode | `.segmented` |
| 3-15 | Form row | `.menu` (default) |
| 15+ | Selection | Navigation link |
| Date/Time | Any | DatePicker |
| Color | Any | ColorPicker |

Reference: [Pickers - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/pickers)
