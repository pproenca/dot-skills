---
title: Refactor ViewModels to Expose Display-Ready State Only
impact: MEDIUM
impactDescription: prevents views from transforming data — simpler bodies, easier testing
tags: layer, viewmodel, boundary, display-state, presentation
---

## Refactor ViewModels to Expose Display-Ready State Only

ViewModels that expose raw domain models force views to contain formatting, filtering, and transformation logic in their bodies. This logic re-executes on every render pass and is untestable. Refactor ViewModels to expose display-ready state — formatted strings, computed booleans, sorted arrays — so the view body is pure layout with zero data transformation.

**Incorrect (ViewModel exposes raw data, view transforms it):**

```swift
@Observable
class ProfileViewModel {
    var user: User?
    var joinDate: Date?
    var followerCount: Int = 0

    func load() async {
        user = try? await fetchProfileUseCase.execute()
        joinDate = user?.createdAt
        followerCount = user?.followers.count ?? 0
    }
}

struct ProfileView: View {
    @State var viewModel: ProfileViewModel

    var body: some View {
        VStack {
            // View transforms raw data — this runs on every render
            Text(viewModel.user?.name ?? "Unknown")
            Text("Joined \(viewModel.joinDate ?? Date(), style: .date)")
            Text("\(viewModel.followerCount) followers")
            Text(viewModel.followerCount > 1000 ? "Popular" : "Growing")
                .foregroundStyle(viewModel.followerCount > 1000 ? .blue : .secondary)
        }
    }
}
```

**Correct (ViewModel exposes display-ready state, view is pure layout):**

```swift
@Observable
class ProfileViewModel {
    var displayName: String = ""
    var joinDateLabel: String = ""
    var followerLabel: String = ""
    var popularityLabel: String = ""
    var isPopular: Bool = false

    private let fetchProfile: FetchProfileUseCase

    init(fetchProfile: FetchProfileUseCase) {
        self.fetchProfile = fetchProfile
    }

    func load() async {
        guard let user = try? await fetchProfile.execute() else { return }
        displayName = user.name
        joinDateLabel = "Joined \(user.createdAt.formatted(date: .abbreviated, time: .omitted))"
        followerLabel = "\(user.followers.count) followers"
        isPopular = user.followers.count > 1000
        popularityLabel = isPopular ? "Popular" : "Growing"
    }
}

struct ProfileView: View {
    @State var viewModel: ProfileViewModel

    var body: some View {
        VStack {
            Text(viewModel.displayName)
            Text(viewModel.joinDateLabel)
            Text(viewModel.followerLabel)
            Text(viewModel.popularityLabel)
                .foregroundStyle(viewModel.isPopular ? .blue : .secondary)
        }
        .task { await viewModel.load() }
    }
}
```

Reference: [Advanced iOS App Architecture (4th Ed.)](https://www.kodeco.com/books/advanced-ios-app-architecture)
