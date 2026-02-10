---
title: Define Schema with All Model Types
impact: LOW-MEDIUM
impactDescription: prevents missing table errors when models aren't discovered via relationships
tags: schema, definition, model-container, completeness
---

## Define Schema with All Model Types

When creating a `ModelContainer`, specify all model types in the `Schema`. SwiftData can discover related types through relationships, but standalone models without relationships to other schema types will be silently omitted — their tables are never created, and queries return empty results with no error.

**Incorrect (standalone model omitted — Movie table never created):**

```swift
@Model class Friend {
    var name: String
    init(name: String) { self.name = name }
}

@Model class Movie {
    var title: String
    init(title: String) { self.title = title }
}

// Only Friend is specified — Movie has no relationship to Friend,
// so SwiftData never creates its table
let container = try ModelContainer(for: Friend.self)
// @Query var movies: [Movie] always returns []
```

**Correct (all model types explicitly listed in schema):**

```swift
let schema = Schema([Friend.self, Movie.self])
let container = try ModelContainer(for: schema)
// Both tables are created, both types are queryable
```

**Alternative (shorthand for multiple types):**

```swift
let container = try ModelContainer(for: Friend.self, Movie.self)
```

**When NOT to use:**
- Types that are only embedded values (not `@Model` classes) should not be in the schema — they are stored inline within their parent model

Reference: [Preserving Your App's Model Data Across Launches](https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches)
