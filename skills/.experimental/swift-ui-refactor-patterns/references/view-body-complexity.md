---
title: Reduce View Body to Under 30 Lines
impact: HIGH
impactDescription: faster body evaluation, easier reasoning about re-renders
tags: view, body, complexity, readability, refactoring
---

## Reduce View Body to Under 30 Lines

Every line inside `body` executes on every state change. Long bodies that mix layout code, conditional logic, and data transformation make it hard to reason about what re-renders and why. Keeping body under 30 lines by extracting subviews and moving data transformations into model methods or computed properties makes re-render behavior obvious at a glance and reduces the work SwiftUI does on each evaluation pass.

**Incorrect (body mixes layout, conditionals, and data transformation):**

```swift
struct ActivityFeedView: View {
    @State private var activities: [Activity]
    @State private var filter: ActivityFilter = .all
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Filter", selection: $filter) {
                    ForEach(ActivityFilter.allCases, id: \.self) { filter in
                        Text(filter.displayName).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                let filtered = activities.filter { activity in
                    (filter == .all || activity.type == filter)
                        && (searchText.isEmpty || activity.title.localizedCaseInsensitiveContains(searchText))
                }

                if filtered.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No activities found")
                            .font(.headline)
                        Text("Try changing your filter or search term")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List(filtered) { activity in
                        HStack {
                            Image(systemName: activity.iconName)
                                .foregroundStyle(activity.accentColor)
                            VStack(alignment: .leading) {
                                Text(activity.title).font(.headline)
                                Text(activity.timestamp, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Activity")
        }
    }
}
```

**Correct (body under 20 lines, logic and sections extracted):**

```swift
struct ActivityFeedView: View {
    @State private var activities: [Activity]
    @State private var filter: ActivityFilter = .all
    @State private var searchText: String = ""

    private var filteredActivities: [Activity] {
        activities.matching(filter: filter, search: searchText)
    }

    var body: some View {
        NavigationStack {
            VStack {
                ActivityFilterPicker(selection: $filter)
                if filteredActivities.isEmpty {
                    ActivityEmptyState()
                } else {
                    ActivityList(activities: filteredActivities)
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Activity")
        }
    }
}

struct ActivityList: View {
    let activities: [Activity]

    var body: some View {
        List(activities) { activity in
            ActivityRow(activity: activity)
        }
    }
}
```

Reference: [Understanding and Improving SwiftUI Performance - Airbnb](https://medium.com/airbnb-engineering/understanding-and-improving-swiftui-performance-37b77ac61896)
