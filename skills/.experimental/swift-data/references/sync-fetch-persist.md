---
title: Use Injected Sync Services to Fetch and Persist API Data
impact: HIGH
impactDescription: prevents main-thread blocking and data races during network-to-persistence sync
tags: sync, api, fetch, persist, service, dto, networking, architecture
---

## Use Injected Sync Services to Fetch and Persist API Data

Network sync services should be injected as protocol dependencies, not instantiated in views. The ViewModel delegates sync operations to the service, which handles networking and persistence in the Data layer. The sync service uses `@ModelActor` for background SwiftData work and maps DTOs to entities. Views never see network or persistence code.

**Incorrect (view creates service and calls sync directly — persistence logic in presentation):**

```swift
@Equatable
struct TripListView: View {
    @Query(sort: \.startDate) private var trips: [TripEntity]
    @Environment(\.modelContext) private var context

    var body: some View {
        List(trips) { trip in
            Text(trip.name)
        }
        .task {
            // Concrete service instantiation in view — untestable, coupled
            let service = TripSyncService(modelContainer: context.container)
            try? await service.syncTrips(from: tripsURL)
        }
    }
}
```

**Correct (injected sync service, ViewModel coordinates, view is pure layout):**

```swift
// Domain/Services/TripSyncServiceProtocol.swift — pure Swift

protocol TripSyncServiceProtocol: Sendable {
    func syncTrips() async throws
}

// Data/Services/TripSyncService.swift — SwiftData implementation

import SwiftData

@ModelActor
actor TripSyncService: TripSyncServiceProtocol {
    private let httpClient: URLSession
    private let tripsURL: URL

    init(modelContainer: ModelContainer, httpClient: URLSession = .shared, tripsURL: URL) {
        self.modelContainer = modelContainer
        let context = ModelContext(modelContainer)
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: context)
        self.httpClient = httpClient
        self.tripsURL = tripsURL
    }

    func syncTrips() async throws {
        let (data, _) = try await httpClient.data(from: tripsURL)
        let dtos = try JSONDecoder().decode([TripDTO].self, from: data)

        for dto in dtos {
            let predicate = #Predicate<TripEntity> { $0.remoteId == dto.id }
            let existing = try modelContext.fetch(FetchDescriptor(predicate: predicate))

            if let entity = existing.first {
                entity.name = dto.name
                entity.startDate = dto.startDate
            } else {
                modelContext.insert(TripEntity(
                    remoteId: dto.id, name: dto.name, startDate: dto.startDate, endDate: dto.endDate
                ))
            }
        }
        try modelContext.save()
    }
}
```

**ViewModel coordinates sync and exposes state:**

```swift
@Observable
final class TripListViewModel {
    private let tripRepository: TripRepository
    private let syncService: TripSyncServiceProtocol

    var trips: [Trip] = []
    var syncError: String?

    init(tripRepository: TripRepository, syncService: TripSyncServiceProtocol) {
        self.tripRepository = tripRepository
        self.syncService = syncService
    }

    func loadTrips() async {
        trips = (try? await tripRepository.fetchAll()) ?? []
    }

    func sync() async {
        do {
            try await syncService.syncTrips()
            await loadTrips() // Refresh after sync
        } catch {
            syncError = error.localizedDescription
        }
    }
}
```

**View is pure template:**

```swift
@Equatable
struct TripListView: View {
    @State private var viewModel: TripListViewModel

    init(tripRepository: TripRepository, syncService: TripSyncServiceProtocol) {
        _viewModel = State(initialValue: TripListViewModel(
            tripRepository: tripRepository, syncService: syncService
        ))
    }

    var body: some View {
        List(viewModel.trips) { trip in
            Text(trip.name)
        }
        .task { await viewModel.loadTrips() }
        .task { await viewModel.sync() }
        .refreshable { await viewModel.sync() }
    }
}
```

**When NOT to use:**
- Small, fast responses that take <100ms to decode — main-actor persistence is acceptable
- Data that does not come from a network source (user-created content)

**Benefits:**
- UI remains responsive during large imports (actor isolation)
- Sync service is testable with mock HTTP clients
- Views have zero knowledge of networking or SwiftData
- ViewModel coordinates without owning persistence logic

Reference: [SwiftData Architecture Patterns and Practices — AzamSharp](https://azamsharp.com/2025/03/28/swiftdata-architecture-patterns-and-practices.html)
