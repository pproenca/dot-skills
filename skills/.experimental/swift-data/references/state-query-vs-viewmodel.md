---
title: Route All Data Access Through @Observable ViewModels
impact: CRITICAL
impactDescription: enforces single responsibility — views handle layout, ViewModels handle data, repositories handle persistence
tags: state, architecture, viewmodel, observable, clean-mvvm, repository
---

## Route All Data Access Through @Observable ViewModels

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

Views never access `ModelContext`, `@Query`, or repositories directly. All data flows through `@Observable` ViewModels, which delegate directly to repository protocols. ViewModels expose display-ready Domain structs, not `@Model` entities. This enforces modular MVVM-C boundaries, enables unit testing without SwiftUI, and keeps views as pure layout templates.

**Incorrect (view accesses SwiftData directly — coupled to persistence, untestable):**

```swift
@Equatable
struct TripListView: View {
    @Query(sort: \.startDate) private var trips: [TripEntity]
    @Environment(\.modelContext) private var context

    var body: some View {
        List {
            ForEach(trips) { trip in
                Text(trip.name) // @Model entity in view — framework coupling
            }
            .onDelete { indexSet in
                for index in indexSet {
                    context.delete(trips[index]) // Persistence logic in view
                }
            }
        }
    }
}
```

**Correct (View -> ViewModel -> Repository — clean layer separation):**

```swift
// Domain/Models/Trip.swift — pure Swift

struct Trip: Equatable, Sendable, Identifiable {
    let id: String
    let name: String
    let startDate: Date
}

// Domain/Repositories/TripRepository.swift — protocol only

protocol TripRepository: Sendable {
    func fetchAll() async throws -> [Trip]
    func delete(id: String) async throws
}
```

```swift
// Presentation/ViewModels/TripListViewModel.swift

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

    func deleteTrip(at offsets: IndexSet) async {
        let idsToDelete = offsets.map { trips[$0].id }
        trips.remove(atOffsets: offsets) // Optimistic UI update
        for id in idsToDelete {
            do { try await tripRepository.delete(id: id) }
            catch { errorMessage = error.localizedDescription; await loadTrips() }
        }
    }
}
```

```swift
// Presentation/Views/TripListView.swift

@Equatable
struct TripListView: View {
    @State private var viewModel: TripListViewModel

    init(tripRepository: TripRepository) {
        _viewModel = State(initialValue: TripListViewModel(tripRepository: tripRepository))
    }

    var body: some View {
        List {
            ForEach(viewModel.trips) { trip in
                Text(trip.name)
            }
            .onDelete { offsets in
                Task { await viewModel.deleteTrip(at: offsets) }
            }
        }
        .task { await viewModel.loadTrips() }
    }
}
```

**Where SwiftData fits (Data layer only):**

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
    func delete(id: String) async throws {
        let predicate = #Predicate<TripEntity> { $0.remoteId == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        guard let entity = try modelContainer.mainContext.fetch(descriptor).first else { return }
        modelContainer.mainContext.delete(entity)
        try modelContainer.mainContext.save()
    }
}
```

**Trade-off:** This pattern sacrifices `@Query`'s automatic view updates. To detect data changes from background sync, observe `ModelContext.didSave` notifications in the ViewModel and re-fetch. See [`query-background-refresh`](query-background-refresh.md) for the notification pattern.

**Benefits:**
- Views are pure layout templates — testable via snapshot tests
- ViewModels are testable with mock repositories — no SwiftData or simulator needed
- Domain layer has zero framework imports
- Data source is swappable (SwiftData, CoreData, network-only) without touching views

Reference: [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
