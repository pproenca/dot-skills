---
title: Plan Migrations Before Changing Models
impact: LOW-MEDIUM
impactDescription: prevents data loss and crashes when existing users update the app
tags: schema, migration, versioning, data-safety
---

## Plan Migrations Before Changing Models

Changing `@Model` properties (renaming, removing, changing types) without a migration plan crashes apps with existing data. SwiftData supports lightweight migrations for additive changes, but destructive changes require explicit `VersionedSchema` and `SchemaMigrationPlan` definitions.

**Incorrect (renamed property without migration — crashes on existing installs):**

```swift
// Version 1 — shipped to users
@Model class Friend {
    var name: String
    var birthday: Date
    init(name: String, birthday: Date) {
        self.name = name
        self.birthday = birthday
    }
}

// Version 2 — renamed property, no migration plan
@Model class Friend {
    var fullName: String   // Was "name" — existing database has no "fullName" column
    var birthday: Date
    init(fullName: String, birthday: Date) {
        self.fullName = fullName
        self.birthday = birthday
    }
}
// Existing users: crash on launch with schema mismatch
```

**Correct (versioned schema with migration plan):**

```swift
enum FriendSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [Friend.self] }

    @Model class Friend {
        var name: String
        var birthday: Date
        init(name: String, birthday: Date) {
            self.name = name
            self.birthday = birthday
        }
    }
}

enum FriendSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] { [Friend.self] }

    @Model class Friend {
        var fullName: String
        var birthday: Date
        init(fullName: String, birthday: Date) {
            self.fullName = fullName
            self.birthday = birthday
        }
    }
}

enum FriendMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [FriendSchemaV1.self, FriendSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: FriendSchemaV1.self,
        toVersion: FriendSchemaV2.self
    ) { context in
        // Custom migration logic here
    }
}

// Apply migration plan to container
let container = try ModelContainer(
    for: FriendSchemaV2.Friend.self,
    migrationPlan: FriendMigrationPlan.self
)
```

**When NOT to use:**
- Additive-only changes (new optional properties with defaults) are handled automatically by lightweight migration
- First version of an app with no existing users

Reference: [Preserving Your App's Model Data Across Launches](https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches)
