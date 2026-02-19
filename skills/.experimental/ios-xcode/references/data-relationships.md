---
title: Define Model Relationships with Properties
impact: HIGH
impactDescription: automatic relationship tracking, cascading updates, referential integrity
tags: data, swiftdata, relationships, one-to-many, many-to-many
---

## Define Model Relationships with Properties

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

SwiftData creates relationships automatically when model properties reference other model types. Use array properties for one-to-many relationships and single properties for one-to-one.

**Incorrect (manual ID references):**

```swift
// Don't use IDs to reference other models
@Model
class Friend {
    var name: String
    var favoriteMovieIds: [UUID] = []  // Manual tracking is error-prone
}

@Model
class Movie {
    var id: UUID = UUID()
    var title: String
}
```

**Correct (direct model references):**

```swift
import SwiftData

@Model
class Friend {
    var name: String

    // One-to-many: Friend has many favorite movies
    var favoriteMovies: [Movie] = []

    init(name: String) {
        self.name = name
    }
}

@Model
class Movie {
    var title: String

    // Inverse relationship (optional but recommended)
    var fans: [Friend] = []

    init(title: String) {
        self.title = title
    }
}

// Usage
let friend = Friend(name: "Sophie")
let movie = Movie(title: "Dune")

// Add to relationship
friend.favoriteMovies.append(movie)
// SwiftData automatically updates movie.fans

// Query with relationships
@Query private var friends: [Friend]

ForEach(friend.favoriteMovies) { movie in
    Text(movie.title)
}
```

**Relationship patterns:**
- Array property -> one-to-many relationship
- Single optional property -> one-to-one relationship
- Define inverse for bidirectional relationships
- SwiftData handles cascading deletes

Reference: [Develop in Swift Tutorials - Work with relationships](https://developer.apple.com/tutorials/develop-in-swift/work-with-relationships)
