---
title: Migrate ObservableObject to @Observable Macro
impact: CRITICAL
impactDescription: eliminates over-observation, 2-5× fewer re-renders with property-level tracking
tags: api, observable, observation, viewmodel, migration
---

## Migrate ObservableObject to @Observable Macro

`ObservableObject` uses push-based notification: any `@Published` change triggers re-renders in every observing view, even those that don't read the changed property. The `@Observable` macro (iOS 17+) uses pull-based tracking, where SwiftUI observes only the specific properties each view accesses. Every ViewModel MUST be an `@Observable` class held via `@State` in its owning view.

**Incorrect (push-based notification re-renders all observers):**

```swift
class ProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var bio: String = ""
    @Published var isLoading: Bool = false
    @Published var avatarURL: URL?
    // Changing isLoading re-renders views that only read name
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        VStack {
            NameHeader(name: viewModel.name)
            BioSection(bio: viewModel.bio)
            if viewModel.isLoading { ProgressView() }
        }
    }
}
```

**Correct (@Observable ViewModel — property-level tracking, @State ownership):**

```swift
@Observable
class ProfileViewModel {
    var name: String = ""
    var bio: String = ""
    var isLoading: Bool = false
    var avatarURL: URL?

    private let fetchProfileUseCase: FetchProfileUseCase

    init(fetchProfileUseCase: FetchProfileUseCase) {
        self.fetchProfileUseCase = fetchProfileUseCase
    }

    func loadProfile(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        if let profile = try? await fetchProfileUseCase.execute(userId: userId) {
            name = profile.name
            bio = profile.bio
            avatarURL = profile.avatarURL
        }
    }
}

struct ProfileView: View {
    @State var viewModel: ProfileViewModel
    // @State owns the @Observable — survives view rebuilds
    // Only views reading isLoading re-render when loading state changes

    var body: some View {
        VStack {
            NameHeader(name: viewModel.name)
            BioSection(bio: viewModel.bio)
            LoadingOverlay(isLoading: viewModel.isLoading)
        }
        .task { await viewModel.loadProfile(userId: "current") }
    }
}
```

**Key migration steps:**
- `ObservableObject` → `@Observable` macro
- `@Published var` → plain `var`
- `@StateObject` → `@State` (ownership)
- `@ObservedObject` → plain property (injected)
- `@EnvironmentObject` → `@Environment`

Reference: [Migrating from the Observable Object protocol to the Observable macro](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)
