---
title: Remove Direct Repository Access from Views
impact: HIGH
impactDescription: 100% view testability without mocking data layer — views receive only display-ready state
tags: layer, view, repository, boundary, clean-architecture
---

## Remove Direct Repository Access from Views

Views that call repositories or services directly mix presentation with data access — the view body contains network calls, error handling, and data transformation. Route all data access through the ViewModel: the view reads display-ready state, the ViewModel orchestrates use cases, and use cases call repositories.

**Incorrect (view calls repository directly — mixed concerns):**

```swift
struct BookmarkListView: View {
    @Environment(\.bookmarkRepository) private var repository
    @State private var bookmarks: [Bookmark] = []
    @State private var isLoading = false
    @State private var error: Error?

    var body: some View {
        List(bookmarks) { bookmark in
            Text(bookmark.title)
        }
        .task {
            isLoading = true
            do {
                bookmarks = try await repository.fetchAll()
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
}
```

**Correct (view reads ViewModel, ViewModel uses use cases):**

```swift
@Observable
class BookmarkListViewModel {
    var bookmarks: [Bookmark] = []
    var isLoading: Bool = false
    var errorMessage: String?

    private let fetchBookmarks: FetchBookmarksUseCase

    init(fetchBookmarks: FetchBookmarksUseCase) {
        self.fetchBookmarks = fetchBookmarks
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            bookmarks = try await fetchBookmarks.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct BookmarkListView: View {
    @State var viewModel: BookmarkListViewModel
    // View only reads display-ready state — no repository access

    var body: some View {
        List(viewModel.bookmarks) { bookmark in
            Text(bookmark.title)
        }
        .overlay {
            if viewModel.isLoading { ProgressView() }
        }
        .task { await viewModel.load() }
    }
}
```

Reference: [Managing model data in your app](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
