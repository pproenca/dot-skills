---
title: Use External Storage for Large Binary Data
impact: MEDIUM
impactDescription: prevents 10-100x SQLite bloat from inline images or files
tags: model, external-storage, attribute, binary, performance
---

## Use External Storage for Large Binary Data

When a model stores large binary data (images, PDFs, audio), mark the property with `@Attribute(.externalStorage)`. SwiftData stores the binary as a separate file on disk and keeps only a reference in the SQLite database. Without this, large blobs are inlined into the database, degrading query performance and inflating backup sizes.

**Incorrect (large Data inlined into SQLite):**

```swift
@Model class Photo {
    var caption: String
    var imageData: Data  // Stored inline — a 5 MB image bloats every query

    init(caption: String, imageData: Data) {
        self.caption = caption
        self.imageData = imageData
    }
}
```

**Correct (external storage for binary data):**

```swift
@Model class Photo {
    var caption: String
    @Attribute(.externalStorage) var imageData: Data  // Stored as separate file

    init(caption: String, imageData: Data) {
        self.caption = caption
        self.imageData = imageData
    }
}
```

**When NOT to use:**
- Small data (< 100 KB) — the overhead of a separate file is not justified
- Data that must be included in SQLite queries or predicates — external storage data cannot be filtered on

**Benefits:**
- SQLite database stays small and fast for queries
- Binary data is loaded on demand, not with every fetch
- Reduces memory pressure when iterating over model collections

Reference: [Preserving Your App's Model Data Across Launches](https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches)
