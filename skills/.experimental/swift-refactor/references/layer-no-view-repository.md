---
title: Remove Direct Repository Access from Views
impact: HIGH
impactDescription: makes views testable as pure rendering templates
tags: layer, view, repository, boundary, modular-mvvm-c
---

## Remove Direct Repository Access from Views

Views should not read repositories directly. Route data access through `@Observable` ViewModels so refactors can preserve feature boundaries and swap Data implementations without touching UI code.

**Incorrect (view calls repository):**

```swift
struct BookmarkListView: View {
    @Environment(\.bookmarkRepository) private var repository
    @State private var bookmarks: [Bookmark] = []

    var body: some View {
        List(bookmarks) { bookmark in
            Text(bookmark.title)
        }
        .task {
            bookmarks = (try? await repository.fetchAll()) ?? []
        }
    }
}
```

**Correct (view reads ViewModel, ViewModel calls repository):**

```swift
protocol BookmarkRepository: Sendable {
    func fetchAll() async throws -> [Bookmark]
}

@Observable
final class BookmarkListViewModel {
    private let repository: any BookmarkRepository
    var bookmarks: [Bookmark] = []

    init(repository: any BookmarkRepository) {
        self.repository = repository
    }

    func load() async {
        bookmarks = (try? await repository.fetchAll()) ?? []
    }
}

struct BookmarkListView: View {
    @State var viewModel: BookmarkListViewModel

    var body: some View {
        List(viewModel.bookmarks) { bookmark in
            Text(bookmark.title)
        }
        .task { await viewModel.load() }
    }
}
```
