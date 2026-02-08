---
title: Replace onAppear Closures with .task Modifier
impact: CRITICAL
impactDescription: automatic cancellation on view disappear, prevents memory leaks
tags: state, task, onappear, lifecycle, async
---

## Replace onAppear Closures with .task Modifier

Using `.onAppear` with a manually created `Task` has no built-in cancellation: if the view disappears before the async work completes, the task keeps running, wasting resources and causing updates to stale views. The `.task` modifier ties the task lifecycle to the view -- SwiftUI automatically cancels it when the view disappears. It also supports `.task(id:)` to cancel and restart the task whenever a dependency value changes.

**Incorrect (manual task with no automatic cancellation):**

```swift
struct ArticleView: View {
    let articleID: String
    @State private var content: ArticleContent?

    var body: some View {
        ScrollView {
            if let content {
                ArticleBody(content: content)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            Task {
                // This task keeps running if the view disappears,
                // and does not re-trigger if articleID changes
                content = await ArticleService.fetch(id: articleID)
            }
        }
    }
}
```

**Correct (automatic cancellation and re-trigger on dependency change):**

```swift
struct ArticleView: View {
    let articleID: String
    @State private var content: ArticleContent?

    var body: some View {
        ScrollView {
            if let content {
                ArticleBody(content: content)
            } else {
                ProgressView()
            }
        }
        .task(id: articleID) {
            // Cancelled automatically when view disappears
            // or when articleID changes, then re-started
            content = await ArticleService.fetch(id: articleID)
        }
    }
}
```

Reference: [task(priority:_:)](https://developer.apple.com/documentation/swiftui/view/task(priority:_:))
