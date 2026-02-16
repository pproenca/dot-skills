---
title: Reduce View Body to Maximum 10 Nodes
impact: HIGH
impactDescription: bodies exceeding 10 nodes prevent isolated diffing, multiplying re-render cost
tags: view, body, complexity, diffing, performance, swiftlint
---

## Reduce View Body to Maximum 10 Nodes

When a view body contains more than ~10 direct child nodes, SwiftUI cannot efficiently isolate which subtree changed. The entire body re-evaluates on any property change. Decompose monolithic bodies into focused subviews — each subview creates a diffing checkpoint that SwiftUI can skip when its inputs haven't changed.

**Incorrect (monolithic body with 15+ inline nodes — entire body re-evaluates on any change):**

```swift
struct ActivityFeedView: View {
    @State var viewModel: ActivityFeedViewModel

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Filter", selection: $viewModel.filter) {
                    ForEach(ActivityFilter.allCases, id: \.self) { filter in
                        Text(filter.displayName).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if viewModel.filteredActivities.isEmpty {
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
                    List(viewModel.filteredActivities) { activity in
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
            .searchable(text: $viewModel.searchText)
            .navigationTitle("Activity")
        }
    }
}
```

**Correct (decomposed to under 10 nodes — each subview diffs independently):**

```swift
struct ActivityFeedView: View {
    @State var viewModel: ActivityFeedViewModel

    var body: some View {
        NavigationStack {
            VStack {
                ActivityFilterPicker(selection: $viewModel.filter)
                if viewModel.filteredActivities.isEmpty {
                    ActivityEmptyState()
                } else {
                    ActivityList(activities: viewModel.filteredActivities)
                }
            }
            .searchable(text: $viewModel.searchText)
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

struct ActivityRow: View {
    let activity: Activity

    var body: some View {
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
```

Reference: [Understanding and Improving SwiftUI Performance - Airbnb](https://medium.com/airbnb-engineering/understanding-and-improving-swiftui-performance-37b77ac61896)
