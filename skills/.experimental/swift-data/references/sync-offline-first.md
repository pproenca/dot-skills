---
title: Design Offline-First Architecture with Local Reads and Background Sync
impact: HIGH
impactDescription: eliminates blank-screen loading states and enables 0ms time-to-interactive from cached data
tags: sync, offline-first, architecture, local-first, background, networking
---

## Design Offline-First Architecture with Local Reads and Background Sync

In an offline-first architecture, SwiftData is the source of truth for all reads. Views always query local data via `@Query`, never wait for network responses. Background sync services fetch remote data and merge it into the local store. This ensures the app launches instantly, works offline, and shows fresh data as soon as sync completes.

**Incorrect (network-first — blank screen while waiting for API):**

```swift
struct TripListView: View {
    @State private var trips: [Trip] = []
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView() // User stares at spinner with no data
            } else {
                List(trips) { trip in
                    Text(trip.name)
                }
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

**Correct (local-first — show cached data immediately, sync in background):**

```swift
struct TripListView: View {
    @Query(sort: \.startDate) private var trips: [Trip]
    @Environment(\.modelContext) private var context
    @State private var syncError: Error?

    var body: some View {
        List(trips) { trip in
            TripRow(trip: trip)
        }
        .overlay {
            if trips.isEmpty {
                ContentUnavailableView("No Trips", systemImage: "airplane")
            }
        }
        .task {
            await syncTripsInBackground()
        }
        .refreshable {
            await syncTripsInBackground()
        }
    }

    private func syncTripsInBackground() async {
        let service = TripSyncService(modelContainer: context.container)
        do {
            try await service.syncTrips(from: API.tripsURL)
        } catch {
            syncError = error // Log or show non-blocking error
        }
    }
}
```

**Architecture layers:**
1. **Views** — read from `@Query`, never hold network state
2. **Sync services** — `@ModelActor` types that fetch from API and upsert into SwiftData
3. **Network layer** — pure HTTP client returning `Sendable` DTOs, no persistence awareness

**When NOT to use:**
- Real-time data that must always be fresh (e.g., stock prices, live scores) — show a loading state and fetch on every appearance
- Data that is too large to cache locally (e.g., streaming media catalogs)

**Benefits:**
- App launches instantly with cached data — no network dependency
- Pull-to-refresh and `.task` provide natural sync points
- Works offline by default — sync failures are non-fatal
- SwiftData handles persistence, deduplication, and schema evolution

Reference: [Offline-First SwiftUI with SwiftData — Medium](https://medium.com/@ashitranpura27/offline-first-swiftui-with-swiftdata-clean-fast-and-sync-ready-9a4faefdeedb)
