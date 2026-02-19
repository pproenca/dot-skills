---
title: Place Business Logic in Domain Types and Repository-Backed ViewModels
impact: HIGH
impactDescription: prevents duplicated validation logic and keeps SwiftData out of feature modules
tags: state, architecture, business-logic, domain, repository, testability
---

## Place Business Logic in Domain Types and Repository-Backed ViewModels

Validation and domain rules belong in pure Domain structs/enums. Persistence and sync orchestration belong in Data repository implementations. ViewModels coordinate repository protocols and expose display-ready state.

**Incorrect (business logic on @Model entity):**

```swift
import SwiftData

@Model
final class TripEntity {
    var name: String
    var startDate: Date
    var endDate: Date

    func validate() throws {
        guard !name.isEmpty else { throw TripError.emptyName }
        guard endDate > startDate else { throw TripError.endBeforeStart }
    }
}
```

**Correct (Domain model + repository-backed ViewModel):**

```swift
struct Trip: Equatable, Sendable {
    let id: UUID
    var name: String
    var startDate: Date
    var endDate: Date

    func validate() throws {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw TripValidationError.emptyName
        }
        guard endDate > startDate else {
            throw TripValidationError.endBeforeStart
        }
    }
}

enum TripValidationError: Error {
    case emptyName
    case endBeforeStart
}

protocol TripRepository: Sendable {
    func save(_ trip: Trip) async throws
}

@Observable
final class TripEditorViewModel {
    private let repository: any TripRepository

    var trip: Trip
    var validationError: TripValidationError?

    init(trip: Trip, repository: any TripRepository) {
        self.trip = trip
        self.repository = repository
    }

    func save() async {
        do {
            try trip.validate()
            try await repository.save(trip)
        } catch let error as TripValidationError {
            validationError = error
        } catch {
            validationError = nil
        }
    }
}
```

**Placement rules:**
- Validation + computed domain rules: Domain types
- Data fetch/save/sync/retry/conflict merge: Data repositories
- UI formatting and screen flow: ViewModel
