---
title: Never Perform Work in View Init
impact: HIGH
impactDescription: prevents N redundant network calls per parent re-render — init runs every evaluation
tags: view, init, side-effects, task, lifecycle
---

## Never Perform Work in View Init

SwiftUI creates view structs on every parent body evaluation. Any work in `init` (network calls, database queries, heavy computation) runs repeatedly, not just "once on appear". Use `.task {}` for async initialization (auto-cancels on disappear) or `.onFirstAppear` for one-shot setup.

**Incorrect (work in init — re-executes on every parent body evaluation):**

```swift
struct UserProfileView: View {
    @State var viewModel: UserProfileViewModel

    // This init runs EVERY TIME the parent's body re-evaluates
    // Not just when UserProfileView first appears
    init(userId: String) {
        let vm = UserProfileViewModel(userId: userId)
        // Network call in init — fires on every parent re-render
        vm.startLoadingProfile()
        // Heavy computation in init — blocks the main thread
        vm.precomputeAnalytics()
        _viewModel = State(initialValue: vm)
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                ProfileContentView(profile: viewModel.profile)
            }
        }
    }
}

// Also incorrect — creating heavy objects in init
struct AnalyticsDashboardView: View {
    // Created on every parent re-evaluation
    let processor = DataProcessor(
        configuration: .full,
        cacheSize: 1024 * 1024  // 1MB allocation every time
    )

    var body: some View {
        Text("Dashboard")
    }
}
```

**Correct (trivial init, async work in .task — auto-cancels on disappear):**

```swift
struct UserProfileView: View {
    let userId: String
    @State private var viewModel: UserProfileViewModel

    // Init is trivial — only stores values
    init(userId: String) {
        self.userId = userId
        _viewModel = State(initialValue: UserProfileViewModel(userId: userId))
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                ProfileContentView(profile: viewModel.profile)
            }
        }
        // .task runs when the view appears and auto-cancels on disappear
        // Does NOT re-run on parent body re-evaluations
        .task {
            await viewModel.loadProfile()
        }
    }
}

// For one-shot work that should survive re-renders
struct AnalyticsDashboardView: View {
    @State private var viewModel = AnalyticsDashboardViewModel()

    var body: some View {
        DashboardContentView(data: viewModel.dashboardData)
            // .task with id re-runs only when the id value changes
            .task(id: viewModel.selectedTimeRange) {
                await viewModel.loadDashboard()
            }
    }
}

@Observable
final class AnalyticsDashboardViewModel {
    var selectedTimeRange: TimeRange = .month
    var dashboardData: DashboardData?

    // Heavy processing happens asynchronously, not in init
    func loadDashboard() async {
        let processor = DataProcessor(configuration: .full)
        dashboardData = await processor.compute(for: selectedTimeRange)
    }
}
```

Reference: [WWDC23 — Demystify SwiftUI Performance](https://developer.apple.com/wwdc23/10160)
