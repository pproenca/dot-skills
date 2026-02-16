---
title: Use Optionals for Optional Relationships
impact: MEDIUM-HIGH
impactDescription: prevents force-unwrap crashes when relationship is absent
tags: rel, optional, relationship, swiftdata
---

## Use Optionals for Optional Relationships

When a model may or may not have a related object (e.g., a friend's favorite movie), declare the relationship as optional. Non-optional relationships crash at runtime if the related object is deleted or was never set, because SwiftData cannot fulfill the non-nil contract.

**Incorrect (non-optional relationship crashes if no movie assigned):**

```swift
import SwiftData

@Model class Friend {
    var name: String
    var favoriteMovie: Movie // Crashes if no movie is assigned or movie is deleted

    init(name: String, favoriteMovie: Movie) {
        self.name = name
        self.favoriteMovie = favoriteMovie
    }
}
```

**Correct (optional relationship safely represents "no favorite"):**

```swift
import SwiftData

@Model class Friend {
    var name: String
    var favoriteMovie: Movie?

    init(name: String, favoriteMovie: Movie? = nil) {
        self.name = name
        self.favoriteMovie = favoriteMovie
    }
}

// Usage in a Picker — include a "None" option with nil tag
@Equatable
struct FriendEditor: View {
    @Bindable var friend: Friend
    @Query(sort: \Movie.title) private var movies: [Movie]

    var body: some View {
        Picker("Favorite Movie", selection: $friend.favoriteMovie) {
            Text("None").tag(nil as Movie?)
            ForEach(movies) { movie in
                Text(movie.title).tag(movie as Movie?)
            }
        }
    }
}
```

**When NOT to use:**
- Required relationships where the child cannot exist without the parent (e.g., an order line item always belongs to an order) should remain non-optional

Reference: [Develop in Swift — Work with Relationships](https://developer.apple.com/tutorials/develop-in-swift/work-with-relationships)
