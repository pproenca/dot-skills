---
title: Use .task {} for Async Data Loading
impact: MEDIUM
impactDescription: prevents 100% of leaked async requests with automatic lifecycle-bound cancellation
tags: data, task, async, loading, cancellation
---

## Use .task {} for Async Data Loading

The `.task {}` modifier is the standard way to perform async work tied to a view's lifecycle. It starts when the view appears and AUTOMATICALLY cancels when the view disappears. This prevents leaked network requests, race conditions from stale responses, and manual Task lifecycle management. Prefer `.task` over `.onAppear` + `Task {}`.

**Incorrect (.onAppear with manual Task — continues after view disappears):**

```swift
struct UserProfileView: View {
    @State var viewModel: UserProfileViewModel

    var body: some View {
        ProfileContent(user: viewModel.user)
            .onAppear {
                // Task created here is DETACHED from the view lifecycle
                // If user navigates away, this Task keeps running
                Task {
                    await viewModel.loadProfile()
                    // View may be deallocated by the time this completes
                    // Setting state on a gone view = wasted work or crash
                }
            }
    }
}

// Problems:
// 1. User taps profile → loadProfile starts
// 2. User taps back immediately → view disappears
// 3. loadProfile still running → response arrives → tries to update gone view
// 4. No automatic cancellation — network request completes wastefully
// 5. If user re-enters profile, ANOTHER Task starts (both running simultaneously)
```

**Correct (.task — automatically cancelled on view disappear):**

```swift
struct UserProfileView: View {
    @State var viewModel: UserProfileViewModel

    var body: some View {
        ProfileContent(user: viewModel.user)
            .task {
                // Structured concurrency: tied to view lifecycle
                // Automatically cancelled when view disappears
                await viewModel.loadProfile()
            }
    }
}

// Lifecycle:
// 1. View appears → .task starts → loadProfile begins
// 2. User taps back → view disappears → .task is CANCELLED
// 3. Any awaited work inside loadProfile receives cancellation
// 4. No wasted network requests, no stale responses
```

**Correct (.task(id:) — auto-restarts when dependency changes):**

```swift
struct CategoryProductsView: View {
    @State var viewModel: ProductsViewModel
    @State private var selectedCategory: Category = .all

    var body: some View {
        VStack {
            CategoryPicker(selection: $selectedCategory)

            ProductGrid(products: viewModel.products)
                .task(id: selectedCategory) {
                    // Runs when view appears AND when selectedCategory changes
                    // Previous task is cancelled before new one starts
                    await viewModel.loadProducts(category: selectedCategory)
                }
        }
    }
}

// Flow when user switches categories:
// 1. selectedCategory changes from .electronics to .clothing
// 2. .task(id:) detects the id changed
// 3. Previous loadProducts(.electronics) is CANCELLED
// 4. New loadProducts(.clothing) starts
// 5. No race condition — only one request active at a time
```

**Key benefits:**
- Automatic cancellation on view disappear — zero manual lifecycle code
- `.task(id:)` auto-cancels and restarts when the observed value changes
- Cooperative cancellation: `await` checkpoints in your async code respond to cancellation
- No need for `@State private var loadTask: Task<Void, Never>?` patterns

Reference: [Apple Documentation — View fundamentals](https://developer.apple.com/documentation/swiftui/view-fundamentals)
