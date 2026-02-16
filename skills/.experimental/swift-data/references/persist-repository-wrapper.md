---
title: Wrap SwiftData Behind Repository Protocols
impact: CRITICAL
impactDescription: O(1) data source swap — change one implementation file vs N view/ViewModel files
tags: persist, repository, protocol, clean-architecture, data-layer, testability
---

## Wrap SwiftData Behind Repository Protocols

Define repository protocols in the Domain layer describing WHAT data operations are available. Place SwiftData implementations (using `ModelContext`, `FetchDescriptor`, `@ModelActor`) in the Data layer. ViewModels and use cases depend only on the protocol — never on SwiftData types. This ensures persistence logic is swappable, testable with mocks, and invisible to the presentation layer.

**Incorrect (ViewModel directly uses SwiftData types — coupled to persistence framework):**

```swift
import SwiftData

@Observable
final class TripListViewModel {
    private let context: ModelContext // SwiftData type in presentation layer

    var trips: [TripEntity] = [] // @Model class leaks into ViewModel

    init(context: ModelContext) {
        self.context = context
    }

    func loadTrips() throws {
        // FetchDescriptor in ViewModel — persistence logic in wrong layer
        let descriptor = FetchDescriptor<TripEntity>(sortBy: [SortDescriptor(\.startDate)])
        trips = try context.fetch(descriptor)
    }

    func deleteTrip(_ trip: TripEntity) {
        context.delete(trip) // Direct ModelContext mutation in ViewModel
    }
}
```

**Correct (protocol in Domain, SwiftData implementation in Data):**

```swift
// Domain/Repositories/TripRepository.swift — pure Swift protocol

protocol TripRepository: Sendable {
    func fetchAll() async throws -> [Trip]
    func fetch(id: String) async throws -> Trip
    func save(_ trip: Trip) async throws
    func delete(id: String) async throws
}
```

```swift
// Data/Repositories/SwiftDataTripRepository.swift

import SwiftData

final class SwiftDataTripRepository: TripRepository, @unchecked Sendable {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    @MainActor
    func fetchAll() async throws -> [Trip] {
        let descriptor = FetchDescriptor<TripEntity>(sortBy: [SortDescriptor(\.startDate)])
        return try modelContainer.mainContext.fetch(descriptor).map { $0.toDomain() }
    }

    @MainActor
    func save(_ trip: Trip) async throws {
        let context = modelContainer.mainContext
        let predicate = #Predicate<TripEntity> { $0.remoteId == trip.id }
        if let entity = try context.fetch(FetchDescriptor(predicate: predicate)).first {
            entity.update(from: trip)
        } else {
            context.insert(TripEntity(from: trip))
        }
        try context.save()
    }

    @MainActor
    func delete(id: String) async throws {
        let context = modelContainer.mainContext
        let predicate = #Predicate<TripEntity> { $0.remoteId == id }
        guard let entity = try context.fetch(FetchDescriptor(predicate: predicate)).first else { return }
        context.delete(entity)
        try context.save()
    }
}
```

```swift
// ViewModel — depends on protocol, not SwiftData

@Observable
final class TripListViewModel {
    private let tripRepository: TripRepository
    var trips: [Trip] = []
    var errorMessage: String?

    init(tripRepository: TripRepository) {
        self.tripRepository = tripRepository
    }

    func loadTrips() async {
        do { trips = try await tripRepository.fetchAll() }
        catch { errorMessage = error.localizedDescription }
    }

    func deleteTrip(_ trip: Trip) async {
        do {
            try await tripRepository.delete(id: trip.id)
            trips.removeAll { $0.id == trip.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

```swift
// Testing — mock repository, no SwiftData needed

final class MockTripRepository: TripRepository {
    var trips: [Trip] = []

    func fetchAll() async throws -> [Trip] { trips }
    func fetch(id: String) async throws -> Trip {
        guard let trip = trips.first(where: { $0.id == id }) else {
            throw RepositoryError.notFound
        }
        return trip
    }
    func save(_ trip: Trip) async throws { trips.append(trip) }
    func delete(id: String) async throws { trips.removeAll { $0.id == id } }
}
```

**Dependency injection setup:**

```swift
// App/DependencyContainer.swift

extension EnvironmentValues {
    @Entry var tripRepository: any TripRepository = SwiftDataTripRepository(
        modelContainer: try! ModelContainer(for: TripEntity.self)
    )
}
```

**When NOT to use:**
- Prototype apps where speed matters more than testability
- Single-screen apps with trivial persistence needs

**Benefits:**
- ViewModels and use cases are testable without SwiftData or simulators
- Data source is swappable (SwiftData, CoreData, network-only) without touching presentation code
- Domain layer has zero framework imports
- Mock repositories enable fast, deterministic unit tests

Reference: [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
