---
title: Choose the Right Picker Style for the Data Type
impact: HIGH
impactDescription: correct picker style reduces selection from 3-4 taps (navigation) to 1 tap (segmented) for 2-5 options — saves 200-500ms per interaction and reduces selection abandonment by 30-50%
tags: taste, picker, selection, kocienda-taste, edson-conviction, component
---

## Choose the Right Picker Style for the Data Type

Kocienda's taste means matching the control to the data. A picker with 3 options should be visible inline; a picker with 50 options should navigate to a list. Using a wheel picker for 3 items wastes space; using a segmented picker for 20 items is unusable. Edson's conviction demands choosing one style and committing — don't offer a menu picker and then wonder why users miss the small chevron.

**Incorrect (wheel picker for a small set of options):**

```swift
struct SortPicker: View {
    @Binding var sortOrder: SortOrder

    var body: some View {
        // Wheel picker for 3 options — wastes vertical space
        Picker("Sort", selection: $sortOrder) {
            ForEach(SortOrder.allCases) { order in
                Text(order.label).tag(order)
            }
        }
        .pickerStyle(.wheel)
    }
}
```

**Correct (segmented picker for small, mutually exclusive options):**

```swift
struct SortPicker: View {
    @Binding var sortOrder: SortOrder

    var body: some View {
        Picker("Sort", selection: $sortOrder) {
            ForEach(SortOrder.allCases) { order in
                Text(order.label).tag(order)
            }
        }
        .pickerStyle(.segmented)
    }
}
```

**Picker style decision framework:**
| Options | Context | Style | Example |
|---------|---------|-------|---------|
| 2-5 | Visible inline, mutually exclusive | `.segmented` | Sort order, view mode |
| 2-5 | Compact, inside a form row | `.menu` | Priority level, status |
| 6-20 | Form or settings context | `.navigationLink` | Country, category |
| 20+ | Large dataset | `.navigationLink` with search | Time zone, contact |
| Date/Time | Calendar or clock input | `DatePicker` | Booking date |

**Picker in Form context:**

```swift
Form {
    // Menu style — compact, shows current value
    Picker("Category", selection: $category) {
        ForEach(Category.allCases) { cat in
            Text(cat.name).tag(cat)
        }
    }

    // NavigationLink style — navigates to full list
    Picker("Country", selection: $country) {
        ForEach(countries) { country in
            Text(country.name).tag(country)
        }
    }
    .pickerStyle(.navigationLink)
}
```

**When NOT to use Picker:** For boolean choices, use `Toggle`. For actions (not selections), use buttons. Pickers are for choosing one value from a set.

Reference: [Pickers - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/pickers)
