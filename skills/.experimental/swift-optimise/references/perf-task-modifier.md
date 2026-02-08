---
title: Use task Modifier for Async Work
impact: MEDIUM
impactDescription: automatic cancellation when view disappears
tags: perf, task, async, await, lifecycle
---

## Use task Modifier for Async Work

The `.task` modifier runs async work when a view appears and automatically cancels it when the view disappears. This prevents memory leaks and wasted work.

**Incorrect (onAppear doesn't cancel):**

```swift
struct ArticleView: View {
    let articleID: String
    @State private var article: Article?

    var body: some View {
        content
            .onAppear {
                Task {
                    // This task continues even if view disappears
                    article = try? await fetchArticle(articleID)
                }
            }
    }
}
```

**Correct (task auto-cancels):**

```swift
struct ArticleView: View {
    let articleID: String
    @State private var article: Article?

    var body: some View {
        content
            .task {
                // Automatically cancelled if view disappears
                article = try? await fetchArticle(articleID)
            }
    }
}
```

**task with id for re-fetching:**

```swift
struct ArticleView: View {
    let articleID: String
    @State private var article: Article?

    var body: some View {
        content
            .task(id: articleID) {
                // Re-runs when articleID changes
                // Previous task is cancelled
                article = try? await fetchArticle(articleID)
            }
    }
}
```

**Handling cancellation:**

```swift
.task {
    do {
        article = try await fetchArticle(articleID)
    } catch is CancellationError {
        // View disappeared, task was cancelled
        // No action needed
    } catch {
        // Actual error
        self.error = error
    }
}
```

**Multiple async operations:**

```swift
.task {
    async let articles = fetchArticles()
    async let user = fetchUser()

    // Both cancelled if view disappears
    self.articles = try? await articles
    self.user = try? await user
}
```

**When to use onAppear instead:**
- Synchronous work
- Fire-and-forget analytics
- UI state setup (focus, scroll position)

Reference: [task(priority:_:) Documentation](https://developer.apple.com/documentation/swiftui/view/task(priority:_:))
