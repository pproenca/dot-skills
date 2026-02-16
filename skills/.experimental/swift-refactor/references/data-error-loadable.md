---
title: Model Loading States as Enum Instead of Boolean Flags
impact: MEDIUM
impactDescription: eliminates impossible states — cannot be both loading and error simultaneously
tags: data, loadable, enum, state-machine, error-handling
---

## Model Loading States as Enum Instead of Boolean Flags

Multiple boolean flags (`isLoading`, `hasError`, `isEmpty`) create impossible states — like being both loading and errored simultaneously. Model the loading lifecycle as an enum with distinct cases. The view switches on the enum, guaranteeing every state is handled and no invalid combinations exist.

**Incorrect (boolean flags create impossible state combinations):**

```swift
@Observable
class FeedViewModel {
    var posts: [Post] = []
    var isLoading: Bool = false
    var error: Error?
    // Possible invalid state: isLoading = true AND error != nil

    func load() async {
        isLoading = true
        error = nil
        do {
            posts = try await fetchPosts.execute()
        } catch {
            self.error = error
        }
        isLoading = false
    }
}

struct FeedView: View {
    @State var viewModel: FeedViewModel

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                Text(error.localizedDescription)
            } else if viewModel.posts.isEmpty {
                Text("No posts")
            } else {
                PostList(posts: viewModel.posts)
            }
        }
    }
}
```

**Correct (enum guarantees exactly one state at a time):**

```swift
enum Loadable<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(Error)
}

@Observable
class FeedViewModel {
    var state: Loadable<[Post]> = .idle

    private let fetchPosts: FetchPostsUseCase

    init(fetchPosts: FetchPostsUseCase) {
        self.fetchPosts = fetchPosts
    }

    func load() async {
        state = .loading
        do {
            let posts = try await fetchPosts.execute()
            state = .loaded(posts)
        } catch {
            state = .failed(error)
        }
    }
}

struct FeedView: View {
    @State var viewModel: FeedViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Color.clear
            case .loading:
                ProgressView()
            case .loaded(let posts):
                if posts.isEmpty {
                    ContentUnavailableView("No Posts", systemImage: "doc")
                } else {
                    PostList(posts: posts)
                }
            case .failed(let error):
                ContentUnavailableView("Error", systemImage: "exclamationmark.triangle",
                    description: Text(error.localizedDescription))
            }
        }
        .task { await viewModel.load() }
    }
}
```

Reference: [WWDC23 — Discover Observation in SwiftUI](https://developer.apple.com/wwdc23/10149)
