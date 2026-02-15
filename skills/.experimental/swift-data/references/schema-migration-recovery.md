---
title: Plan Migration Recovery for Schema Changes
impact: MEDIUM
impactDescription: prevents 100% crash rate for existing users when a migration fails on app update
tags: schema, migration, recovery, crash, versioning, error
---

## Plan Migration Recovery for Schema Changes

When you change your `@Model` properties without providing a `SchemaMigrationPlan`, SwiftData attempts a lightweight migration. If the change is incompatible (renaming a property, changing a type, removing a required field), the migration fails and `ModelContainer` creation crashes on launch — every existing user is stuck. Always version your schema, provide explicit migration stages, and test migration paths before shipping.

**Incorrect (breaking change with no migration plan — existing users crash):**

```swift
// Version 1 shipped with:
@Model class Trip {
    var destination: String // v1 property
    var startDate: Date
}

// Version 2 renames "destination" to "name" — no migration plan
@Model class Trip {
    var name: String // Renamed — lightweight migration cannot handle this
    var startDate: Date
}

// App crashes on launch for all existing users:
// "Failed to find a currently active managed object model"
```

**Correct (versioned schema with explicit migration stages):**

```swift
enum TripSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [Trip.self] }

    @Model class Trip {
        var destination: String
        var startDate: Date
        init(destination: String, startDate: Date) {
            self.destination = destination
            self.startDate = startDate
        }
    }
}

enum TripSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] { [Trip.self] }

    @Model class Trip {
        var name: String
        var startDate: Date
        init(name: String, startDate: Date) {
            self.name = name
            self.startDate = startDate
        }
    }
}

enum TripMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [TripSchemaV1.self, TripSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: TripSchemaV1.self,
        toVersion: TripSchemaV2.self
    ) { context in
        let trips = try context.fetch(FetchDescriptor<TripSchemaV1.Trip>())
        for trip in trips {
            // Map old "destination" to new "name"
            trip.setValue(trip.destination, forKey: "name")
        }
        try context.save()
    }
}

// App setup with migration plan:
let container = try ModelContainer(
    for: TripSchemaV2.Trip.self,
    migrationPlan: TripMigrationPlan.self
)
```

**Testing migration before shipping:**
- Create a unit test that loads a v1 store file and applies the migration plan
- Verify all records survive the migration with correct field mappings
- Test on a real device with production data if possible

**When NOT to use:**
- Additive-only changes (new optional property with default) — lightweight migration handles these automatically
- First version of an app with no existing users

**Benefits:**
- Existing users' data survives schema changes across app updates
- Explicit migration stages document the evolution of your data model
- Custom migration logic handles complex transformations (renames, type changes, data merges)

Reference: [Model your schema with enumerations — WWDC23](https://developer.apple.com/videos/play/wwdc2023/10195/)
