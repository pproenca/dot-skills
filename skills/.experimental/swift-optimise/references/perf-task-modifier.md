---
title: Use .task Modifier Instead of .onAppear for Async Work
impact: HIGH
impactDescription: automatic cancellation prevents wasted network requests and memory leaks when views disappear mid-flight
tags: perf, task, async, await, lifecycle, cancellation
---

## Use .task Modifier Instead of .onAppear for Async Work

The `.task` modifier runs async work when a view appears and automatically cancels it when the view disappears. Using `.onAppear` with a manually created `Task` leaks work -- the task continues executing even after the view is gone, wasting CPU, network, and memory.

**Incorrect (onAppear doesn't cancel when view disappears):**

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

**Correct (.task auto-cancels on disappearance):**

```swift
struct ArticleView: View {
    let articleID: String
    @State private var article: Article?

    var body: some View {
        content
            .task {
                article = try? await fetchArticle(articleID)
            }
    }
}
```

**Handling cancellation explicitly:**

```swift
.task {
    do {
        article = try await fetchArticle(articleID)
    } catch is CancellationError {
        // View disappeared -- no action needed
    } catch {
        self.error = error
    }
}
```

**Multiple async operations in parallel:**

```swift
.task {
    async let articles = fetchArticles()
    async let user = fetchUser()

    // Both cancelled if view disappears
    self.articles = try? await articles
    self.user = try? await user
}
```

**When to use .onAppear instead:**
- Synchronous work only
- Fire-and-forget analytics
- UI state setup (focus, scroll position)

**See also:** [`conc-task-id-pattern`](conc-task-id-pattern.md) for re-triggering async work when a value changes using `.task(id:)`.

Reference: [task(priority:_:) Documentation](https://developer.apple.com/documentation/swiftui/view/task(priority:_:))
