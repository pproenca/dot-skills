---
title: Map @Model Entities to Domain Structs
impact: CRITICAL
impactDescription: decouples domain logic from SwiftData framework — enables 100% domain test coverage without simulator
tags: model, domain, mapping, clean-architecture, value-types, entity
---

## Map @Model Entities to Domain Structs

`@Model` classes are persistence entities — they belong in the Data layer. Domain models must be pure Swift structs conforming to `Equatable` and `Sendable`, with zero framework imports. This separation ensures domain logic is testable without SwiftData, portable across platforms, and immune to framework changes. Every `@Model` class should have a corresponding domain struct and bidirectional mapping methods.

**Incorrect (using @Model classes as domain models — couples business logic to persistence):**

```swift
import SwiftData
import SwiftUI

// @Model class used everywhere — domain logic depends on SwiftData
@Model class Trip {
    var name: String
    var startDate: Date
    var endDate: Date

    init(name: String, startDate: Date, endDate: Date) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
    }

    // Business logic on a framework type — untestable without SwiftData
    func validate() throws {
        guard !name.isEmpty else { throw TripError.emptyName }
        guard endDate > startDate else { throw TripError.endBeforeStart }
    }

    var durationInDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
}

// ViewModel directly references @Model — coupled to persistence framework
@Observable
final class TripListViewModel {
    var trips: [Trip] = [] // SwiftData type in presentation layer
}
```

**Correct (domain struct + @Model entity + mapping — modular Domain/Data layers):**

```swift
// Domain/Models/Trip.swift — pure Swift, zero imports

struct Trip: Equatable, Sendable {
    let id: String
    let name: String
    let startDate: Date
    let endDate: Date

    var durationInDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }

    func validate() throws {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw TripValidationError.emptyName
        }
        guard endDate > startDate else {
            throw TripValidationError.endBeforeStart
        }
    }
}

enum TripValidationError: LocalizedError {
    case emptyName, endBeforeStart

    var errorDescription: String? {
        switch self {
        case .emptyName: return "Trip name cannot be empty."
        case .endBeforeStart: return "End date must be after start date."
        }
    }
}
```

```swift
// Data/Entities/TripEntity.swift — SwiftData persistence

import SwiftData

@Model class TripEntity {
    @Attribute(.unique) var remoteId: String
    var name: String
    var startDate: Date
    var endDate: Date

    init(remoteId: String, name: String, startDate: Date, endDate: Date) {
        self.remoteId = remoteId
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
    }

    func toDomain() -> Trip {
        Trip(id: remoteId, name: name, startDate: startDate, endDate: endDate)
    }

    func update(from domain: Trip) {
        name = domain.name
        startDate = domain.startDate
        endDate = domain.endDate
    }
}
```

**Naming convention:**
- Domain models: `Trip`, `Friend`, `Event` (clean names)
- SwiftData entities: `TripEntity`, `FriendEntity`, `EventEntity` (suffixed)
- DTOs: `TripDTO`, `FriendDTO` (for network responses)

**When NOT to use:**
- Prototype or hackathon apps where speed trumps architecture
- Single-screen utility apps with no business logic beyond CRUD

**Benefits:**
- Domain models are testable without Xcode simulators or SwiftData framework
- Value semantics prevent shared mutable state bugs across ViewModels
- `Equatable` conformance enables efficient SwiftUI diffing
- `Sendable` conformance enables safe actor boundary crossing

Reference: [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
