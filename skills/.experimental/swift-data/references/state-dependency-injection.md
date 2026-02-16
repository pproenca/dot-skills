---
title: Inject Repository Protocols via @Environment
impact: MEDIUM-HIGH
impactDescription: eliminates init parameter drilling and enables testing without SwiftData framework
tags: state, dependency-injection, testing, environment, protocol, architecture
---

## Inject Repository Protocols via @Environment

Services and repositories should be injected as protocol types via SwiftUI's `@Environment`, not as concrete SwiftData types (`ModelContainer`, `ModelContext`). Define custom `EnvironmentKey` types for each repository protocol and inject implementations at the app root. This keeps views and ViewModels decoupled from persistence frameworks and enables mock injection for testing.

**Incorrect (injecting concrete ModelContainer — coupled to SwiftData, hard to test):**

```swift
@Observable
final class TripListViewModel {
    private let container: ModelContainer // Concrete framework type

    init(container: ModelContainer) {
        self.container = container
    }

    func loadTrips() async throws {
        // Must create ModelContext here — framework coupling
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<TripEntity>()
        // ...
    }
}

// Cannot test without a real ModelContainer
```

**Correct (injecting protocol via @Environment — decoupled, testable):**

```swift
// Domain/Repositories/TripRepository.swift — pure Swift protocol

protocol TripRepository: Sendable {
    func fetchAll() async throws -> [Trip]
    func save(_ trip: Trip) async throws
    func delete(id: String) async throws
}

// App/Environment/RepositoryKeys.swift — @Entry shorthand (Xcode 16+)

import SwiftUI
import SwiftData

extension EnvironmentValues {
    @Entry var tripRepository: any TripRepository = SwiftDataTripRepository(
        modelContainer: try! ModelContainer(for: TripEntity.self)
    )
}
```

**App root injects the live implementation once:**

```swift
@main
struct TripApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: TripEntity.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            TripListView()
                .environment(\.tripRepository, SwiftDataTripRepository(modelContainer: container))
        }
    }
}
```

**ViewModel reads from @Environment via view init:**

```swift
@Equatable
struct TripListView: View {
    @Environment(\.tripRepository) private var tripRepository
    @State private var viewModel: TripListViewModel?

    var body: some View {
        Group {
            if let viewModel {
                TripListContent(viewModel: viewModel)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = TripListViewModel(tripRepository: tripRepository)
                await viewModel?.loadTrips()
            }
        }
    }
}
```

**Testing with mock repository:**

```swift
func testTripListLoading() async {
    let mockRepo = MockTripRepository()
    mockRepo.trips = [
        Trip(id: "1", name: "Paris", startDate: .now, endDate: .now.addingTimeInterval(86400))
    ]

    let viewModel = TripListViewModel(tripRepository: mockRepo)
    await viewModel.loadTrips()

    XCTAssertEqual(viewModel.trips.count, 1)
    XCTAssertEqual(viewModel.trips.first?.name, "Paris")
}
```

**When NOT to use:**
- Prototype apps where speed matters more than testability
- Simple apps with a single view and no unit tests

**Benefits:**
- ViewModels are testable with mock repositories — no SwiftData or simulator needed
- No parameter drilling — intermediate views are unaware of dependencies they don't use
- Repository implementations are swappable without touching views or ViewModels
- Testing injects mocks via `.environment(\.tripRepository, MockTripRepository())`

Reference: [Apple Documentation — Environment values](https://developer.apple.com/documentation/swiftui/environmentvalues)
