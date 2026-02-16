---
title: Place Business Logic in Domain Value Types and Use Cases
impact: HIGH
impactDescription: prevents 2-3x duplicated validation logic and enables unit testing without SwiftData framework
tags: state, architecture, business-logic, domain, usecase, testability
---

## Place Business Logic in Domain Value Types and Use Cases

Validation, transformation, and domain rules belong in pure Swift domain structs and use case protocols — not in `@Model` extensions, SwiftUI views, or ViewModels. Domain structs have zero framework imports, making them testable without Xcode simulators. Use cases encapsulate single business operations behind protocols. ViewModels coordinate use cases and expose display-ready state.

**Incorrect (business logic on @Model extension — coupled to SwiftData framework):**

```swift
import SwiftData

@Model class TripEntity {
    var name: String
    var startDate: Date
    var endDate: Date

    // Business logic on a framework type — requires SwiftData to test
    func validate() throws {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw TripError.emptyName
        }
        guard endDate > startDate else {
            throw TripError.endBeforeStart
        }
    }

    var durationInDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
}
```

**Correct (domain struct owns business logic — zero framework imports):**

```swift
// Domain/Models/Trip.swift — pure Swift

struct Trip: Equatable, Sendable {
    let id: String
    var name: String
    var startDate: Date
    var endDate: Date

    var durationInDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }

    func validated() throws -> Trip {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw TripValidationError.emptyName
        }
        guard endDate > startDate else {
            throw TripValidationError.endBeforeStart
        }
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        guard days <= 365 else {
            throw TripValidationError.tooLong
        }
        return self
    }
}

enum TripValidationError: LocalizedError {
    case emptyName, endBeforeStart, tooLong

    var errorDescription: String? {
        switch self {
        case .emptyName: return "Trip name cannot be empty."
        case .endBeforeStart: return "End date must be after start date."
        case .tooLong: return "Trip cannot exceed 365 days."
        }
    }
}
```

**Use case for cross-model operations:**

```swift
// Domain/UseCases/SaveTripUseCase.swift

protocol SaveTripUseCase: Sendable {
    func execute(_ trip: Trip) async throws
}

final class SaveTripUseCaseImpl: SaveTripUseCase {
    private let tripRepository: TripRepository

    init(tripRepository: TripRepository) {
        self.tripRepository = tripRepository
    }

    func execute(_ trip: Trip) async throws {
        let validated = try trip.validated()
        try await tripRepository.save(validated)
    }
}
```

**ViewModel delegates to domain logic — thin coordinator:**

```swift
@Observable
final class TripEditorViewModel {
    private let saveTripUseCase: SaveTripUseCase

    var trip: Trip
    var validationError: TripValidationError?
    var isSaved = false

    init(trip: Trip, saveTripUseCase: SaveTripUseCase) {
        self.trip = trip
        self.saveTripUseCase = saveTripUseCase
    }

    func save() async {
        do {
            try await saveTripUseCase.execute(trip)
            isSaved = true
        } catch let error as TripValidationError {
            validationError = error
        } catch {
            validationError = nil // Non-validation error — handle separately
        }
    }
}
```

**View is pure template:**

```swift
@Equatable
struct TripEditorView: View {
    @State private var viewModel: TripEditorViewModel
    @Environment(\.dismiss) private var dismiss

    init(trip: Trip, saveTripUseCase: SaveTripUseCase) {
        _viewModel = State(initialValue: TripEditorViewModel(
            trip: trip, saveTripUseCase: saveTripUseCase
        ))
    }

    var body: some View {
        Form {
            TextField("Name", text: $viewModel.trip.name)
            DatePicker("Start", selection: $viewModel.trip.startDate)
            DatePicker("End", selection: $viewModel.trip.endDate)
            Text("Duration: \(viewModel.trip.durationInDays) days")
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await viewModel.save() }
                }
            }
        }
        .onChange(of: viewModel.isSaved) { _, saved in
            if saved { dismiss() }
        }
    }
}
```

**Where to put different kinds of logic:**
- **Validation, computed properties** -> Domain struct methods
- **Single business operation** -> Use case protocol with `execute()`
- **Cross-model coordination** -> Use case composing multiple repositories
- **View-specific formatting** -> ViewModel computed properties
- **Persistence operations** -> Repository implementation (Data layer)

**Benefits:**
- Domain logic is unit-testable without SwiftData, SwiftUI, or Xcode simulators
- Single source of truth for validation rules — no duplication across screens
- Errors surface as typed enums with localized descriptions
- Use case protocols enable independent testing of each business operation

Reference: [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
