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
    @State var viewModel: ArticleViewModel

    var body: some View {
        ArticleContent(article: viewModel.article)
            .onAppear {
                Task {
                    // This task continues even if view disappears
                    await viewModel.loadArticle()
                }
            }
    }
}
```

**Correct (.task auto-cancels on disappearance):**

```swift
struct ArticleView: View {
    @State var viewModel: ArticleViewModel

    var body: some View {
        ArticleContent(article: viewModel.article)
            .task {
                await viewModel.loadArticle()
            }
    }
}

@Observable
@MainActor
class ArticleViewModel {
    let articleID: String
    var article: Article?
    private let fetchArticleUseCase: any FetchArticleUseCase

    init(articleID: String, fetchArticleUseCase: any FetchArticleUseCase) {
        self.articleID = articleID
        self.fetchArticleUseCase = fetchArticleUseCase
    }

    func loadArticle() async {
        article = try? await fetchArticleUseCase.execute(id: articleID)
    }
}
```

**Handling cancellation explicitly:**

```swift
.task {
    do {
        await viewModel.loadArticle()
    } catch is CancellationError {
        // View disappeared -- no action needed
    } catch {
        viewModel.error = error
    }
}
```

**Multiple async operations in parallel:**

```swift
.task {
    async let articles = viewModel.loadArticles()
    async let user = viewModel.loadUser()

    // Both cancelled if view disappears
    await articles
    await user
}
```

**When to use .onAppear instead:**
- Synchronous work only
- Fire-and-forget analytics
- UI state setup (focus, scroll position)

**See also:** [`conc-task-id-pattern`](conc-task-id-pattern.md) for re-triggering async work when a value changes using `.task(id:)`. See [`data-task-modifier`](../../swift-ui-architect/references/data-task-modifier.md) in swift-ui-architect for the architectural usage pattern with ViewModels.

Reference: [task(priority:_:) Documentation](https://developer.apple.com/documentation/swiftui/view/task(priority:_:))
