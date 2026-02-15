---
title: Filter and Sort in ViewModel, Never Inside ForEach
impact: MEDIUM
impactDescription: O(1) cached access vs O(N) filter on every body evaluation
tags: list, filter, sort, viewmodel, caching
---

## Filter and Sort in ViewModel, Never Inside ForEach

Filtering and sorting inside `ForEach` or the view body runs on EVERY `body` evaluation — even when the source data hasn't changed. A parent view state change that triggers re-evaluation will re-filter and re-sort the entire collection. Move these operations to the ViewModel where results can be cached and only recomputed when the source data actually changes.

**Incorrect (inline filter/sort in body — runs on every re-evaluation):**

```swift
struct TaskListView: View {
    @State var viewModel: TaskListViewModel

    var body: some View {
        List {
            // These run on EVERY body evaluation:
            // - Parent view changes unrelated state → body re-evaluates → filter + sort runs
            // - User scrolls → body re-evaluates → filter + sort runs
            // - Any @Observable property changes → body re-evaluates → filter + sort runs
            ForEach(
                viewModel.tasks
                    .filter { $0.isActive && !$0.isArchived }
                    .sorted(by: { $0.dueDate < $1.dueDate })
                    .sorted(by: { $0.priority.rawValue > $1.priority.rawValue })
            ) { task in
                TaskRow(task: task)
            }
        }
        .searchable(text: $viewModel.searchQuery)
    }
}

@Observable
class TaskListViewModel {
    var tasks: [TaskItem] = []
    var searchQuery: String = ""
    // No caching — filtering logic lives in the view
}
```

**Correct (ViewModel caches filtered and sorted results):**

```swift
struct TaskListView: View {
    @State var viewModel: TaskListViewModel

    var body: some View {
        List {
            // Pre-computed, cached — just iterates the result
            ForEach(viewModel.activeTasks) { task in
                TaskRow(task: task)
            }
        }
        .searchable(text: $viewModel.searchQuery)
    }
}

@Observable
class TaskListViewModel {
    var tasks: [TaskItem] = [] {
        didSet { recomputeActiveTasks() }
    }
    var searchQuery: String = "" {
        didSet { recomputeActiveTasks() }
    }

    // Cached result — only recomputed when tasks or searchQuery changes
    private(set) var activeTasks: [TaskItem] = []

    private func recomputeActiveTasks() {
        var result = tasks.filter { $0.isActive && !$0.isArchived }

        if !searchQuery.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        result.sort { lhs, rhs in
            if lhs.priority != rhs.priority {
                return lhs.priority.rawValue > rhs.priority.rawValue
            }
            return lhs.dueDate < rhs.dueDate
        }

        activeTasks = result
    }

    func loadTasks() async {
        tasks = try? await taskRepository.fetchAll() ?? []
    }
}
```

**Key benefits:**
- Filtering and sorting run only when source data or filter criteria change — not on every body evaluation
- View body is a simple `ForEach` iteration — no computation
- Easier to unit test: assert `viewModel.activeTasks` directly without rendering views

Reference: [WWDC23 — Demystify SwiftUI Performance](https://developer.apple.com/wwdc23/10160)
