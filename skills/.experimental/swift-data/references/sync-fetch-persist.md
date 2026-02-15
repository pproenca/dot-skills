---
title: Use @ModelActor Services to Fetch and Persist API Data
impact: HIGH
impactDescription: prevents main-thread blocking and data races during network-to-persistence sync
tags: sync, api, fetch, persist, model-actor, dto, networking
---

## Use @ModelActor Services to Fetch and Persist API Data

Network responses should be mapped to `@Model` types and persisted on a background actor, not the main thread. Fetching and inserting on the main actor blocks the UI during large responses. Use a dedicated `@ModelActor` service that accepts Sendable DTOs from the network layer, maps them to model objects, and upserts into its own `ModelContext`.

**Incorrect (fetching and inserting on the main actor — blocks UI):**

```swift
struct TripListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \.startDate) private var trips: [Trip]

    var body: some View {
        List(trips) { trip in
            Text(trip.name)
        }
        .task {
            // Runs on main actor — blocks UI during network + insert
            let response = try? await URLSession.shared.data(from: tripsURL)
            let dtos = try? JSONDecoder().decode([TripDTO].self, from: response?.0 ?? Data())
            for dto in dtos ?? [] {
                context.insert(Trip(name: dto.name, startDate: dto.startDate))
            }
        }
    }
}
```

**Correct (@ModelActor service handles fetch + persist off the main thread):**

```swift
struct TripDTO: Codable, Sendable {
    let id: String
    let name: String
    let startDate: Date
}

@ModelActor
actor TripSyncService {
    private let httpClient: URLSession

    init(modelContainer: ModelContainer, httpClient: URLSession = .shared) {
        self.modelContainer = modelContainer
        let context = ModelContext(modelContainer)
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: context)
        self.httpClient = httpClient
    }

    func syncTrips(from url: URL) async throws {
        let (data, _) = try await httpClient.data(from: url)
        let dtos = try JSONDecoder().decode([TripDTO].self, from: data)

        for dto in dtos {
            let existingPredicate = #Predicate<Trip> { $0.remoteId == dto.id }
            let existing = try modelContext.fetch(FetchDescriptor(predicate: existingPredicate))

            if let trip = existing.first {
                trip.name = dto.name
                trip.startDate = dto.startDate
            } else {
                let trip = Trip(remoteId: dto.id, name: dto.name, startDate: dto.startDate)
                modelContext.insert(trip)
            }
        }
        try modelContext.save()
    }
}

// Usage from a view:
struct TripListView: View {
    @Query(sort: \.startDate) private var trips: [Trip]
    @Environment(\.modelContext) private var context

    var body: some View {
        List(trips) { trip in
            Text(trip.name)
        }
        .task {
            let service = TripSyncService(modelContainer: context.container)
            try? await service.syncTrips(from: tripsURL)
        }
    }
}
```

**When NOT to use:**
- Small, fast responses that take <100ms to decode and insert — main-actor insertion is acceptable
- Data that does not come from a network source (user-created content)

**Benefits:**
- UI remains responsive during large imports
- Actor isolation prevents data races between network callbacks and UI reads
- DTOs are `Sendable` and safe to pass across actor boundaries
- Upsert pattern prevents duplicate records from repeated syncs

Reference: [SwiftData Architecture Patterns and Practices — AzamSharp](https://azamsharp.com/2025/03/28/swiftdata-architecture-patterns-and-practices.html)
