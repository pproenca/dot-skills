---
title: Replace onAppear Async Work with .task Modifier
impact: MEDIUM
impactDescription: automatic Task cancellation on disappear — prevents leaked async work
tags: data, task, onappear, async, cancellation
---

## Replace onAppear Async Work with .task Modifier

`.onAppear` with `Task { }` creates a detached task that continues running even after the view disappears — leaked network calls, database writes, and state mutations on deallocated ViewModels. The `.task` modifier creates a structured task that SwiftUI automatically cancels when the view disappears.

**Incorrect (onAppear + Task — leaked async work on disappear):**

```swift
struct ProfileView: View {
    @State var viewModel: ProfileViewModel

    var body: some View {
        VStack {
            Text(viewModel.name)
        }
        .onAppear {
            Task {
                // This task continues even after ProfileView disappears
                // Can mutate viewModel after the view is gone
                await viewModel.loadProfile()
            }
        }
    }
}
```

**Correct (.task — automatic cancellation on disappear):**

```swift
struct ProfileView: View {
    @State var viewModel: ProfileViewModel

    var body: some View {
        VStack {
            Text(viewModel.name)
        }
        .task {
            // Automatically cancelled when ProfileView disappears
            // Cooperative cancellation — async calls check Task.isCancelled
            await viewModel.loadProfile()
        }
    }
}
```

**Reacting to value changes:**

```swift
struct SearchResultsView: View {
    @State var viewModel: SearchViewModel

    var body: some View {
        List(viewModel.results) { result in
            Text(result.title)
        }
        .task(id: viewModel.query) {
            // Cancelled and restarted when query changes
            await viewModel.search()
        }
    }
}
```

Reference: [Managing model data in your app](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
