---
title: Provide Sensible Default Values for Model Properties
impact: MEDIUM
impactDescription: avoids schema migration when adding new properties
tags: model, defaults, initialization, optionals
---

## Provide Sensible Default Values for Model Properties

Default values reduce initializer boilerplate and prevent nil-related crashes. For collections, default to empty arrays. For optional relationships, use `nil`. For dates, use `.now`. This makes model creation simpler at every call site.

**Incorrect (every property required at init):**

```swift
@Model class Trip {
    var destination: String
    var startDate: Date
    var endDate: Date
    var notes: String
    var photos: [String]
    var rating: Int

    // Caller must provide every value, even for a quick draft
    init(destination: String, startDate: Date, endDate: Date,
         notes: String, photos: [String], rating: Int) {
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.photos = photos
        self.rating = rating
    }
}

// Painful to use for a quick entry
let trip = Trip(destination: "Paris", startDate: .now, endDate: .now,
                notes: "", photos: [], rating: 0)
```

**Correct (sensible defaults for optional/collection properties):**

```swift
@Model class Trip {
    var destination: String
    var startDate: Date = .now
    var endDate: Date = .now
    var notes: String = ""
    var photos: [String] = []
    var rating: Int = 0

    init(destination: String, startDate: Date = .now, endDate: Date = .now,
         notes: String = "", photos: [String] = [], rating: Int = 0) {
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.photos = photos
        self.rating = rating
    }
}

// Clean one-liner for quick entries
let trip = Trip(destination: "Paris")
```

**Benefits:**
- Call sites only specify what they care about
- Fewer optionals means fewer force-unwrap crashes
- New properties with defaults don't break existing code

Reference: [Develop in Swift — Model Data with Custom Types](https://developer.apple.com/tutorials/develop-in-swift/model-data-with-custom-types)
