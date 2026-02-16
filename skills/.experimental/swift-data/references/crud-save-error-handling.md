---
title: Handle Repository Save Failures With User Feedback
impact: HIGH
impactDescription: prevents silent data loss when persistence writes fail
tags: crud, save, error, handling, repository, data-integrity
---

## Handle Repository Save Failures With User Feedback

Repository `save()` calls can fail due to uniqueness constraint violations, validation errors, or underlying store issues. The ViewModel must catch errors and surface them to the view as display-ready state. Silently swallowing errors with `try?` means the user thinks their data was saved when it was not.

**Incorrect (save error silently ignored in ViewModel):**

```swift
@Observable
final class TripEditorViewModel {
    private let tripRepository: TripRepository

    func save(_ trip: Trip) async {
        try? await tripRepository.save(trip) // Failure silently swallowed
        // User thinks trip was saved — it was not
    }
}
```

**Correct (ViewModel catches error, view presents it):**

```swift
@Observable
final class TripEditorViewModel {
    private let tripRepository: TripRepository
    var trip: Trip
    var saveError: String?
    var isSaved = false

    init(trip: Trip, tripRepository: TripRepository) {
        self.trip = trip
        self.tripRepository = tripRepository
    }

    func save() async {
        do {
            try await tripRepository.save(trip)
            isSaved = true
        } catch {
            saveError = error.localizedDescription
        }
    }
}
```

```swift
@Equatable
struct TripEditorView: View {
    @State private var viewModel: TripEditorViewModel
    @Environment(\.dismiss) private var dismiss

    init(trip: Trip, tripRepository: TripRepository) {
        _viewModel = State(initialValue: TripEditorViewModel(trip: trip, tripRepository: tripRepository))
    }

    var body: some View {
        Form {
            TextField("Name", text: $viewModel.trip.name)
            DatePicker("Start", selection: $viewModel.trip.startDate)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { Task { await viewModel.save() } }
            }
        }
        .onChange(of: viewModel.isSaved) { _, saved in
            if saved { dismiss() }
        }
        .alert("Unable to Save", isPresented: Binding(
            get: { viewModel.saveError != nil },
            set: { if !$0 { viewModel.saveError = nil } }
        )) {
            Button("Retry") { Task { await viewModel.save() } }
            Button("Discard", role: .destructive) { dismiss() }
        } message: {
            Text(viewModel.saveError ?? "An unknown error occurred.")
        }
    }
}
```

**When NOT to use:**
- Preview and test code where save failures should crash immediately to surface bugs

**Benefits:**
- User always knows whether their data was persisted
- Retry option recovers from transient failures
- Error state is testable in the ViewModel without SwiftUI

Reference: [SwiftData — Saving Models with ModelContext — Medium](https://medium.com/@nicrofilm/swiftdata-saving-models-with-modelcontext-747e29605980)
