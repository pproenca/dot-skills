---
title: Move Filter and Sort Logic from ForEach into ViewModel
impact: MEDIUM
impactDescription: eliminates redundant computation on every body evaluation — filter once, not per render
tags: list, filter, sort, viewmodel, performance
---

## Move Filter and Sort Logic from ForEach into ViewModel

Filtering or sorting inside the view body re-executes on every render pass — even when the data hasn't changed. Move these operations into the ViewModel as computed properties or cached results. The view body receives the already-filtered array and simply iterates it.

**Incorrect (filtering in view body — re-executes on every render):**

```swift
struct TaskListView: View {
    @State var viewModel: TaskListViewModel

    var body: some View {
        List {
            // This filter runs on EVERY body evaluation
            ForEach(viewModel.tasks.filter { $0.status == viewModel.selectedFilter }) { task in
                TaskRow(task: task)
            }
        }
        .toolbar {
            Picker("Filter", selection: $viewModel.selectedFilter) {
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    Text(status.label).tag(status)
                }
            }
        }
    }
}
```

**Correct (filtering in ViewModel — computed once, view just iterates):**

```swift
@Observable
class TaskListViewModel {
    var tasks: [TaskItem] = []
    var selectedFilter: TaskStatus = .all

    var filteredTasks: [TaskItem] {
        guard selectedFilter != .all else { return tasks }
        return tasks.filter { $0.status == selectedFilter }
    }

    private let fetchTasks: FetchTasksUseCase

    init(fetchTasks: FetchTasksUseCase) {
        self.fetchTasks = fetchTasks
    }

    func load() async {
        tasks = (try? await fetchTasks.execute()) ?? []
    }
}

struct TaskListView: View {
    @State var viewModel: TaskListViewModel

    var body: some View {
        List {
            ForEach(viewModel.filteredTasks) { task in
                TaskRow(task: task)
            }
        }
        .toolbar {
            Picker("Filter", selection: $viewModel.selectedFilter) {
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    Text(status.label).tag(status)
                }
            }
        }
        .task { await viewModel.load() }
    }
}
```

Reference: [Managing model data in your app](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
