---
title: Extract Protocol Dependencies through ViewModel Layer
impact: HIGH
impactDescription: enables unit testing and SwiftUI previews — views never touch repositories directly
tags: arch, protocol, dependency-injection, viewmodel, clean-architecture
---

## Extract Protocol Dependencies through ViewModel Layer

Views that call concrete services or protocol dependencies directly violate modular layer boundaries — the view layer reaches into the data layer. Extract protocol interfaces and route them through an `@Observable` ViewModel. The ViewModel calls Repository protocols directly, and the view only reads display-ready state. This makes views and ViewModels independently testable.

**Incorrect (view directly uses a service protocol — breaks layer boundary):**

```swift
protocol ArticleFetching {
    func fetchArticles() async throws -> [Article]
}

struct ArticleListView: View {
    let fetcher: ArticleFetching
    @State private var articles: [Article] = []
    @State private var isLoading = false
    // View directly accesses data layer — untestable without mocking at view level
    // Business logic (loading state, error handling) lives in the view

    var body: some View {
        List(articles) { article in
            Text(article.title)
        }
        .task {
            isLoading = true
            articles = (try? await fetcher.fetchArticles()) ?? []
            isLoading = false
        }
    }
}
```

**Correct (protocol routed through ViewModel — proper layer separation):**

```swift
// Domain layer — protocol and use case
protocol ArticleRepository: Sendable {
    func fetchArticles() async throws -> [Article]
}

protocol FetchArticlesUseCase {
    func execute() async throws -> [Article]
}

final class FetchArticlesUseCaseImpl: FetchArticlesUseCase {
    private let repository: ArticleRepository

    init(repository: ArticleRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Article] {
        try await repository.fetchArticles()
    }
}

// Presentation layer — ViewModel owns the logic
@Observable
class ArticleListViewModel {
    var articles: [Article] = []
    var isLoading: Bool = false
    var errorMessage: String?

    private let fetchArticles: FetchArticlesUseCase

    init(fetchArticles: FetchArticlesUseCase) {
        self.fetchArticles = fetchArticles
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            articles = try await fetchArticles.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// View — thin rendering layer, no data access
struct ArticleListView: View {
    @State var viewModel: ArticleListViewModel

    var body: some View {
        List(viewModel.articles) { article in
            Text(article.title)
        }
        .overlay {
            if viewModel.isLoading { ProgressView() }
        }
        .task { await viewModel.load() }
    }
}
```

Reference: [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
