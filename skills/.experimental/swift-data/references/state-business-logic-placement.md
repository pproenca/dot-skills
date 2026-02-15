---
title: Place Business Logic in Model Extensions and Service Types
impact: HIGH
impactDescription: prevents 2-3× duplicated validation logic across views and enables unit testing without SwiftUI
tags: state, architecture, business-logic, model, service, testability
---

## Place Business Logic in Model Extensions and Service Types

Validation, transformation, and domain rules should live in `@Model` extensions or dedicated service types — not in SwiftUI view bodies. Putting business logic in views makes it untestable, duplicated across screens, and tangled with presentation concerns. Model extensions keep logic co-located with the data it operates on. Service types (`@ModelActor` or plain classes) handle cross-cutting operations.

**Incorrect (business logic scattered across view body):**

```swift
struct TripEditorView: View {
    @Environment(\.modelContext) private var context
    @Bindable var trip: Trip

    var body: some View {
        Form {
            TextField("Name", text: $trip.name)
            DatePicker("Start", selection: $trip.startDate)
            DatePicker("End", selection: $trip.endDate)

            Button("Save") {
                // Validation logic in the view — untestable, duplicated
                guard !trip.name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                guard trip.endDate > trip.startDate else { return }
                guard trip.endDate.timeIntervalSince(trip.startDate) <= 365 * 24 * 3600 else { return }

                // Derived state computation in the view
                trip.duration = Calendar.current.dateComponents(
                    [.day], from: trip.startDate, to: trip.endDate
                ).day ?? 0

                try? context.save()
            }
        }
    }
}
```

**Correct (validation in model extension — testable without SwiftUI):**

```swift
extension Trip {
    enum ValidationError: LocalizedError {
        case emptyName, endBeforeStart, tooLong
        var errorDescription: String? {
            switch self {
            case .emptyName: return "Trip name cannot be empty."
            case .endBeforeStart: return "End date must be after start date."
            case .tooLong: return "Trip cannot exceed 365 days."
            }
        }
    }

    func validate() throws {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { throw ValidationError.emptyName }
        guard endDate > startDate else { throw ValidationError.endBeforeStart }
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        guard days <= 365 else { throw ValidationError.tooLong }
    }

    var durationInDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
}
```

**View is thin — delegates to model:**

```swift
struct TripEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var trip: Trip
    @State private var validationError: Trip.ValidationError?

    var body: some View {
        Form {
            TextField("Name", text: $trip.name)
            DatePicker("Start", selection: $trip.startDate)
            DatePicker("End", selection: $trip.endDate)
            Text("Duration: \(trip.durationInDays) days")
            Button("Save") {
                do {
                    try trip.validate()
                    try context.save()
                    dismiss()
                } catch let error as Trip.ValidationError {
                    validationError = error
                } catch {}
            }
        }
    }
}
```

**Where to put different kinds of logic:**
- **Validation, computed properties** → `@Model` extension
- **Cross-model operations (batch updates, aggregations)** → `@ModelActor` service
- **View-specific formatting** → View or ViewModifier
- **Network + persistence coordination** → `@ModelActor` sync service

**Benefits:**
- Model logic is unit-testable without instantiating SwiftUI views
- Single source of truth for validation rules — no duplication across screens
- Views remain declarative and focused on presentation
- Errors surface as typed enums with localized descriptions

Reference: [SwiftData Architecture Patterns and Practices — AzamSharp](https://azamsharp.com/2025/03/28/swiftdata-architecture-patterns-and-practices.html)
