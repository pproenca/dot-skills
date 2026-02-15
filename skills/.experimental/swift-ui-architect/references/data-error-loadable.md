---
title: Model Loading States as Enum, Not Booleans
impact: MEDIUM
impactDescription: eliminates 2^N impossible state combinations down to exactly N valid states
tags: data, loadable, enum, state-machine, error-handling
---

## Model Loading States as Enum, Not Booleans

Replace scattered boolean flags (`isLoading`, `hasError`, `hasData`) with a single `Loadable<T>` enum with cases: `.idle`, `.loading`, `.loaded(T)`, `.error(Error)`. This eliminates impossible state combinations, makes exhaustive `switch` statements enforce handling all cases, and provides a consistent pattern across all data-loading ViewModels.

**Incorrect (boolean flags — allows impossible state combinations):**

```swift
@Observable
class ArticleListViewModel {
    var articles: [Article] = []
    var isLoading = false
    var error: Error?
    var hasLoaded = false

    func loadArticles() async {
        isLoading = true
        error = nil
        do {
            articles = try await articleRepository.fetchAll()
            hasLoaded = true
        } catch {
            self.error = error
        }
        isLoading = false
    }
}

struct ArticleListView: View {
    @State var viewModel: ArticleListViewModel

    var body: some View {
        VStack {
            // Impossible to handle all states correctly
            // What if isLoading == true AND error != nil? (bug: forgot to clear error)
            // What if hasLoaded == true AND articles.isEmpty? (no data vs not loaded)
            // What if isLoading == false AND hasLoaded == false AND error == nil? (idle? bug?)
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                ErrorView(error: error)
            } else if viewModel.articles.isEmpty {
                // Is this "no articles exist" or "hasn't loaded yet"?
                Text("No articles")  // BUG: shows before first load
            } else {
                ArticleList(articles: viewModel.articles)
            }
        }
    }
}
```

**Correct (Loadable<T> enum — exactly one state at a time):**

```swift
// Reusable generic enum — used across all ViewModels
enum Loadable<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)

    var value: T? {
        if case .loaded(let value) = self { return value }
        return nil
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

@Observable
class ArticleListViewModel {
    var articles: Loadable<[Article]> = .idle
    // Single property — impossible to have conflicting states

    func loadArticles() async {
        articles = .loading
        do {
            let result = try await articleRepository.fetchAll()
            articles = .loaded(result)
        } catch {
            articles = .error(error)
        }
    }
}

struct ArticleListView: View {
    @State var viewModel: ArticleListViewModel

    var body: some View {
        // Exhaustive switch — compiler forces handling of every case
        Group {
            switch viewModel.articles {
            case .idle:
                // Clearly distinct from "loaded but empty"
                Color.clear

            case .loading:
                ProgressView("Loading articles...")

            case .loaded(let articles):
                if articles.isEmpty {
                    ContentUnavailableView(
                        "No Articles",
                        systemImage: "doc.text",
                        description: Text("Articles you save will appear here.")
                    )
                } else {
                    List(articles) { article in
                        ArticleRow(article: article)
                    }
                }

            case .error(let error):
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error.localizedDescription)
                } actions: {
                    Button("Retry") {
                        Task { await viewModel.loadArticles() }
                    }
                }
            }
        }
        .task { await viewModel.loadArticles() }
    }
}
```

**Key benefits:**
- Exactly one state at any time — `.loading` and `.error` can never coexist
- Exhaustive `switch` — adding a new case produces a compiler error until all views handle it
- `.idle` vs `.loaded([])` distinction — "not loaded yet" vs "loaded but empty" are explicitly different states
- Reusable `Loadable<T>` works for any data type across the entire app

Reference: [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
