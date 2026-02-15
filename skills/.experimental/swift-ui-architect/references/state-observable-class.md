---
title: Use @Observable Classes for All ViewModels
impact: CRITICAL
impactDescription: 2-10× fewer view updates — only views reading changed property re-render
tags: state, observable, viewmodel, observation, ios17
---

## Use @Observable Classes for All ViewModels

`@Observable` (iOS 17+) automatically tracks which properties each view reads in its body and only triggers re-render when THOSE specific properties change. `ObservableObject` with `@Published` triggers re-render for ANY property change on the object — even unrelated ones. Every ViewModel MUST be an `@Observable` class held via `@State` in its owning view.

**Incorrect (ObservableObject with @Published — all views re-render on any change):**

```swift
// ObservableObject notifies ALL subscribers when ANY @Published changes
class ProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var bio: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
}

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    // When isLoading changes, EVERY view observing this ViewModel re-renders
    // Even views that only read 'name' get invalidated

    var body: some View {
        VStack {
            NameHeader(name: viewModel.name)
            BioSection(bio: viewModel.bio)
            if viewModel.isLoading { ProgressView() }
        }
    }
}
```

**Correct (@Observable class — only views reading the changed property re-render):**

```swift
// @Observable tracks property access per-view
@Observable
class ProfileViewModel {
    var name: String = ""
    var bio: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }
        // fetch profile...
    }
}

struct ProfileView: View {
    @State var viewModel = ProfileViewModel()
    // When isLoading changes, only the ProgressView branch re-evaluates
    // NameHeader and BioSection are untouched

    var body: some View {
        VStack {
            NameHeader(name: viewModel.name)
            BioSection(bio: viewModel.bio)
            LoadingOverlay(isLoading: viewModel.isLoading)
        }
        .task { await viewModel.loadProfile() }
    }
}
```

**Key differences:**
- `@Observable` replaces `ObservableObject` — no protocol conformance needed
- Plain `var` replaces `@Published` — the macro handles tracking
- `@State` replaces `@StateObject` — ownership semantics are the same

Reference: [WWDC23 — Discover Observation in SwiftUI](https://developer.apple.com/wwdc23/10149)
