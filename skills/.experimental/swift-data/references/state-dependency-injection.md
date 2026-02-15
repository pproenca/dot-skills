---
title: Inject ModelContainer for Testable Service Architecture
impact: MEDIUM
impactDescription: enables unit testing of persistence logic without launching the full app or SwiftUI views
tags: state, dependency-injection, testing, model-container, architecture
---

## Inject ModelContainer for Testable Service Architecture

Services and `@ModelActor` types should receive their `ModelContainer` via initializer injection, not create it internally or access a global singleton. This makes services testable with in-memory containers, replaceable in previews, and decoupled from the app's storage configuration.

**Incorrect (service creates its own container — untestable, couples to disk):**

```swift
@ModelActor
actor TripSyncService {
    static let shared = {
        // Hardcoded container — cannot be replaced in tests
        let container = try! ModelContainer(for: Trip.self)
        return TripSyncService(modelContainer: container)
    }()

    func importTrips(from dtos: [TripDTO]) throws {
        for dto in dtos {
            modelContext.insert(Trip(name: dto.name, startDate: dto.startDate))
        }
        try modelContext.save()
    }
}

// Test cannot control the store:
func testImport() async throws {
    // Uses real disk store — test data persists between runs
    try await TripSyncService.shared.importTrips(from: testDTOs)
}
```

**Correct (container injected — testable with in-memory store):**

```swift
@ModelActor
actor TripSyncService {
    func importTrips(from dtos: [TripDTO]) throws {
        for dto in dtos {
            modelContext.insert(Trip(name: dto.name, startDate: dto.startDate))
        }
        try modelContext.save()
    }
}

// Production setup (in App init or dependency container):
let container = try ModelContainer(for: Trip.self)
let syncService = TripSyncService(modelContainer: container)

// Test setup (in-memory, isolated):
func testImport() async throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: Trip.self, configurations: [config])
    let service = TripSyncService(modelContainer: container)

    let dtos = [TripDTO(name: "Paris", startDate: .now)]
    try await service.importTrips(from: dtos)

    let context = ModelContext(container)
    let trips = try context.fetch(FetchDescriptor<Trip>())
    XCTAssertEqual(trips.count, 1)
    XCTAssertEqual(trips.first?.name, "Paris")
}
```

**When NOT to use:**
- Simple apps with a single container and no unit tests for persistence logic
- Previews that already use `SampleData.shared` — the preview singleton pattern is sufficient

**Benefits:**
- Tests run with in-memory containers — fast, isolated, no cleanup needed
- Services are decoupled from the app's storage strategy
- Same service code works with disk, in-memory, or App Group configurations

Reference: [How to use MVVM to separate SwiftData from your views — Hacking with Swift](https://www.hackingwithswift.com/quick-start/swiftdata/how-to-use-mvvm-to-separate-swiftdata-from-your-views)
