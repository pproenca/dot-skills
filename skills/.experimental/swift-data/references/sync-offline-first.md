---
title: Design Offline-First Architecture with Repository Reads and Background Sync
impact: HIGH
impactDescription: eliminates blank-screen loading states and enables 0ms time-to-interactive from cached data
tags: sync, offline-first, architecture, local-first, background, networking
---

## Design Offline-First Architecture with Repository Reads and Background Sync

In an offline-first architecture, the repository is the source of truth for all reads. ViewModels always load data from the repository (which reads from SwiftData locally), never wait for network responses. Background sync services fetch remote data and merge it into the local store via the repository or directly via `@ModelActor`. The ViewModel re-fetches after sync completes. This ensures the app launches instantly, works offline, and shows fresh data as soon as sync completes.

**Incorrect (network-first — blank screen while waiting for API):**

```swift
@Equatable
struct TripListView: View {
    @State private var trips: [Trip] = []
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView() // User stares at spinner with no data
            } else {
                List(trips) { trip in Text(trip.name) }
            }
        }
        .task {
            let response = try? await APIClient.shared.fetchTrips()
            trips = response ?? []
            isLoading = false
            // No data persisted — next launch starts from scratch
        }
    }
}
```

**Correct (local-first via repository, background sync via service):**

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

    func syncInBackground() async {
        do {
            try await syncService.syncTrips()
            await loadTrips() // Refresh from local store after sync
        } catch {
            syncError = error.localizedDescription // Non-fatal — cached data still visible
        }
    }
}

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
            TripRow(trip: trip)
        }
        .overlay {
            if viewModel.trips.isEmpty {
                ContentUnavailableView("No Trips", systemImage: "airplane")
            }
        }
        .task { await viewModel.loadTrips() }
        .task { await viewModel.syncInBackground() }
        .refreshable { await viewModel.syncInBackground() }
    }
}
```

**Architecture layers:**
1. **Views** — read from ViewModel, never hold network or persistence state
2. **ViewModels** — coordinate repository reads and sync service calls
3. **Repository** — reads from local SwiftData store, maps entities to domain structs
4. **Sync services** — `@ModelActor` types that fetch from API and upsert into SwiftData
5. **Network layer** — pure HTTP client returning `Sendable` DTOs, no persistence awareness

**When NOT to use:**
- Real-time data that must always be fresh (e.g., stock prices) — show a loading state and fetch on every appearance
- Data that is too large to cache locally

**Benefits:**
- App launches instantly with cached data — no network dependency
- Pull-to-refresh and `.task` provide natural sync points
- Works offline by default — sync failures are non-fatal
- All layers are independently testable with mock dependencies

Reference: [Offline-First SwiftUI with SwiftData — Medium](https://medium.com/@ashitranpura27/offline-first-swiftui-with-swiftdata-clean-fast-and-sync-ready-9a4faefdeedb)
