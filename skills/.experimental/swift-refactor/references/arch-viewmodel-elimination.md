---
title: Eliminate Unnecessary View Models
impact: MEDIUM
impactDescription: eliminates 1 class + 1 file per view, reduces boilerplate by 30-50%
tags: arch, viewmodel, mvvm, simplification, refactoring
---

## Eliminate Unnecessary View Models

SwiftUI views already manage their own state through property wrappers like @State and computed properties -- they ARE the view model in a declarative framework. Wrapping simple state in a separate ViewModel class adds an indirection layer without benefit: more files, more boilerplate, and a @StateObject lifecycle to manage. Reserve dedicated view models for complex business logic, multi-step flows, or when you need to unit test logic in isolation.

**Incorrect (unnecessary ViewModel wrapping simple state):**

```swift
class CounterViewModel: ObservableObject {
    @Published var count: Int = 0
    @Published var stepSize: Int = 1

    var countLabel: String {
        "Count: \(count)"
    }

    func increment() {
        count += stepSize
    }

    func decrement() {
        count -= stepSize
    }
}

struct CounterView: View {
    @StateObject private var viewModel = CounterViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text(viewModel.countLabel)
                .font(.title)
            Stepper("Step: \(viewModel.stepSize)", value: $viewModel.stepSize, in: 1...10)
            HStack {
                Button("Decrement") { viewModel.decrement() }
                Button("Increment") { viewModel.increment() }
            }
        }
    }
}
```

**Correct (state and logic live directly in the view):**

```swift
struct CounterView: View {
    @State private var count: Int = 0
    @State private var stepSize: Int = 1

    private var countLabel: String {
        "Count: \(count)"
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(countLabel)
                .font(.title)
            Stepper("Step: \(stepSize)", value: $stepSize, in: 1...10)
            HStack {
                Button("Decrement") { count -= stepSize }
                Button("Increment") { count += stepSize }
            }
        }
    }
}
```

Reference: [Building Large-Scale Apps with SwiftUI](https://azamsharp.com/2023/02/28/building-large-scale-apps-swiftui.html)
