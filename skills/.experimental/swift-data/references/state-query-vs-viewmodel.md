---
title: Choose @Query in Views for Reads, ViewModels for Complex Write Logic
impact: HIGH
impactDescription: prevents over-engineering with unnecessary ViewModels while keeping complex business logic out of views
tags: state, architecture, query, viewmodel, observable, separation
---

## Choose @Query in Views for Reads, ViewModels for Complex Write Logic

`@Query` is the primary data observation mechanism in SwiftData — it only works inside SwiftUI views, automatically updates on changes, and connects directly to the `ModelContext` single source of truth. Do not wrap `@Query` in a ViewModel just for "separation of concerns" — this adds indirection, breaks automatic updates, and requires manual sync. Use `@Observable` ViewModels only when a view has complex write logic that would clutter the view body (multi-step validation, aggregation, coordinating multiple contexts).

**Incorrect (ViewModel wrapping @Query — adds complexity, breaks auto-updates):**

```swift
@Observable
class TripListViewModel {
    var trips: [Trip] = []
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        fetchTrips() // Manual fetch — must be called again after every mutation
    }

    func fetchTrips() {
        trips = (try? context.fetch(FetchDescriptor<Trip>(sortBy: [SortDescriptor(\.startDate)]))) ?? []
    }

    func deleteTrip(_ trip: Trip) {
        context.delete(trip)
        fetchTrips() // Must manually re-fetch after every change
    }
}

struct TripListView: View {
    @State private var viewModel: TripListViewModel

    init(context: ModelContext) {
        _viewModel = State(initialValue: TripListViewModel(context: context))
    }

    var body: some View {
        List(viewModel.trips) { trip in
            Text(trip.name)
        }
    }
}
```

**Correct (@Query for reads, direct context for simple writes):**

```swift
struct TripListView: View {
    @Query(sort: \.startDate) private var trips: [Trip]
    @Environment(\.modelContext) private var context

    var body: some View {
        List {
            ForEach(trips) { trip in
                Text(trip.name)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    context.delete(trips[index])
                }
            }
        }
    }
}
```

**When a ViewModel IS appropriate:**

```swift
@Observable
class TripBudgetViewModel {
    // Complex write logic: validating budget across multiple trips,
    // computing aggregates, coordinating with a sync service
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func redistributeBudget(total: Double, across tripIds: [PersistentIdentifier]) throws {
        let share = total / Double(tripIds.count)
        for id in tripIds {
            guard let trip = context.model(for: id) as? Trip else { continue }
            guard share >= trip.minimumBudget else {
                throw BudgetError.belowMinimum(trip: trip.name)
            }
            trip.budget = share
        }
        try context.save()
    }
}
```

**Decision guide:**
- **Read-only list/detail** → `@Query` in the view
- **Simple CRUD (insert, delete, toggle)** → `@Environment(\.modelContext)` in the view
- **Multi-step validation, aggregation, coordination** → `@Observable` ViewModel with `FetchDescriptor`
- **Background processing** → `@ModelActor` service (not a ViewModel)

**Benefits:**
- `@Query` provides automatic UI updates with zero sync code
- ViewModels are reserved for genuinely complex logic, keeping most views simple
- `ModelContext` remains the single source of truth in all patterns

Reference: [SwiftData Architecture Patterns and Practices — AzamSharp](https://azamsharp.com/2025/03/28/swiftdata-architecture-patterns-and-practices.html)
