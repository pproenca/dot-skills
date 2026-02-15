---
title: Implement Conflict Resolution for Bidirectional Sync
impact: MEDIUM
impactDescription: prevents data loss when local edits and server updates collide
tags: sync, conflict, resolution, timestamp, merge, networking
---

## Implement Conflict Resolution for Bidirectional Sync

When an app supports both local edits and server-side updates, conflicts arise if the same record is modified in both places before syncing. Without a conflict resolution strategy, the last write silently overwrites the other — losing user data. Add a `lastModified` timestamp to every synced model and compare timestamps during merge.

**Incorrect (last write wins silently — local edits lost):**

```swift
@ModelActor
actor TripSyncService {
    func syncTrips(from dtos: [TripDTO]) throws {
        for dto in dtos {
            let predicate = #Predicate<Trip> { $0.remoteId == dto.id }
            let existing = try modelContext.fetch(FetchDescriptor(predicate: predicate))

            if let trip = existing.first {
                // Blindly overwrites local edits with server data
                trip.name = dto.name
                trip.startDate = dto.startDate
            } else {
                modelContext.insert(Trip(remoteId: dto.id, name: dto.name, startDate: dto.startDate))
            }
        }
        try modelContext.save()
    }
}
```

**Correct (timestamp-based server-wins with local change detection):**

```swift
@Model class Trip {
    @Attribute(.unique) var remoteId: String
    var name: String
    var startDate: Date
    var lastModifiedLocally: Date = Date.distantPast
    var lastModifiedRemotely: Date = Date.distantPast
    var hasPendingLocalChanges: Bool = false

    init(remoteId: String, name: String, startDate: Date, serverTimestamp: Date) {
        self.remoteId = remoteId
        self.name = name
        self.startDate = startDate
        self.lastModifiedRemotely = serverTimestamp
    }
}

@ModelActor
actor TripSyncService {
    func syncTrips(from dtos: [TripDTO]) throws -> [SyncConflict] {
        var conflicts: [SyncConflict] = []

        for dto in dtos {
            let predicate = #Predicate<Trip> { $0.remoteId == dto.id }
            let existing = try modelContext.fetch(FetchDescriptor(predicate: predicate))

            if let trip = existing.first {
                if trip.hasPendingLocalChanges && dto.serverTimestamp > trip.lastModifiedRemotely {
                    // Both sides changed — record conflict for user resolution
                    conflicts.append(SyncConflict(
                        tripId: trip.remoteId,
                        localName: trip.name,
                        serverName: dto.name
                    ))
                } else if dto.serverTimestamp > trip.lastModifiedRemotely {
                    // Server is newer, no local changes — safe to overwrite
                    trip.name = dto.name
                    trip.startDate = dto.startDate
                    trip.lastModifiedRemotely = dto.serverTimestamp
                }
                // If local is newer, skip server update — push local changes later
            } else {
                modelContext.insert(Trip(
                    remoteId: dto.id, name: dto.name,
                    startDate: dto.startDate, serverTimestamp: dto.serverTimestamp
                ))
            }
        }
        try modelContext.save()
        return conflicts
    }
}
```

**Common strategies:**
- **Server-wins**: Always apply server data; simplest but loses local edits
- **Last-write-wins**: Compare timestamps; most recent change takes precedence
- **Manual resolution**: Surface conflicts to the user for explicit choice
- **Merge**: Combine non-conflicting field changes from both sides

**When NOT to use:**
- Read-only data from the server (no local edits) — simple overwrite is sufficient
- CloudKit-backed apps — CloudKit has its own built-in conflict resolution

**Benefits:**
- Prevents silent data loss from concurrent edits
- `hasPendingLocalChanges` flag enables reliable push-then-pull sync cycles
- Conflict list surfaces unresolvable cases for user decision

Reference: [Designing Efficient Local-First Architectures with SwiftData — Medium](https://medium.com/@gauravharkhani01/designing-efficient-local-first-architectures-with-swiftdata-cc74048526f2)
