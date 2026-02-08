---
title: Replace navigationBarItems with toolbar Modifier
impact: CRITICAL
impactDescription: enables 4-platform support (iOS, macOS, watchOS, visionOS) with semantic placement
tags: api, toolbar, navigation-bar, deprecated, migration
---

## Replace navigationBarItems with toolbar Modifier

`.navigationBarItems(leading:trailing:)` was deprecated in iOS 14 and is iOS-only. The `.toolbar` modifier works across all Apple platforms (iOS, macOS, watchOS, visionOS) and uses semantic placements that adapt automatically to each platform's conventions.

**Incorrect (deprecated navigationBarItems, iOS-only):**

```swift
struct TaskListView: View {
    var body: some View {
        NavigationStack {
            List(tasks) { task in
                TaskRow(task: task)
            }
            .navigationTitle("Tasks")
            .navigationBarItems(
                leading: Button("Edit") { startEditing() },
                trailing: HStack {
                    Button(action: filter) {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                    Button(action: addTask) {
                        Image(systemName: "plus")
                    }
                }
            )
        }
    }
}
```

**Correct (toolbar with semantic placements, cross-platform):**

```swift
struct TaskListView: View {
    var body: some View {
        NavigationStack {
            List(tasks) { task in
                TaskRow(task: task)
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Edit") { startEditing() }
                }
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: filter) {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                    Button(action: addTask) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
```

Use `ToolbarItemGroup` to group multiple items under one placement instead of repeating `ToolbarItem` for each:

```swift
.toolbar {
    ToolbarItemGroup(placement: .bottomBar) {
        Button("Archive") { archiveTasks() }
        Spacer()
        Text("\(tasks.count) tasks")
            .font(.caption)
        Spacer()
        Button("Compose") { composeDraft() }
    }
}
```

Reference: [toolbar(content:) - Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/view/toolbar(content:)-5w0tj)
