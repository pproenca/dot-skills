---
title: Extract Protocol Interfaces for External Dependencies
impact: MEDIUM
impactDescription: enables unit testing and SwiftUI previews with mock data
tags: arch, protocol, dependency-injection, testing, previews
---

## Extract Protocol Interfaces for External Dependencies

Views that call concrete services like URLSession or database clients directly cannot be tested without network access, and SwiftUI previews either crash or hang waiting for real responses. Extracting a protocol interface lets you inject a lightweight mock for tests and previews while keeping the real implementation for production. This one change makes the difference between previews that load instantly and previews that timeout.

**Incorrect (concrete dependency makes previews and tests impossible without network):**

```swift
struct ArticleListView: View {
    @State private var articles: [Article] = []
    @State private var isLoading = false

    var body: some View {
        List(articles) { article in
            Text(article.title)
        }
        .task {
            isLoading = true
            let url = URL(string: "https://api.example.com/articles")!
            let (data, _) = try! await URLSession.shared.data(from: url)
            articles = try! JSONDecoder().decode([Article].self, from: data)
            isLoading = false
        }
    }
}
```

**Correct (protocol enables mock injection for previews and tests):**

```swift
protocol ArticleFetching {
    func fetchArticles() async throws -> [Article]
}

struct ArticleListView: View {
    let fetcher: ArticleFetching
    @State private var articles: [Article] = []
    @State private var isLoading = false

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

struct LiveArticleFetcher: ArticleFetching {
    func fetchArticles() async throws -> [Article] {
        let url = URL(string: "https://api.example.com/articles")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Article].self, from: data)
    }
}

struct MockArticleFetcher: ArticleFetching {
    func fetchArticles() async throws -> [Article] {
        [Article(id: "1", title: "Preview Article")]
    }
}

#Preview {
    ArticleListView(fetcher: MockArticleFetcher())
}
```

Reference: [Previews in Xcode](https://developer.apple.com/documentation/swiftui/previews-in-xcode)
