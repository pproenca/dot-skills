---
title: "SwiftData Model Accessed from Wrong ModelContext"
impact: MEDIUM-HIGH
impactDescription: "crash or silent data corruption when context is violated"
tags: io, swiftdata, model-context, concurrency, persistence
---

## SwiftData Model Accessed from Wrong ModelContext

SwiftData models are bound to their `ModelContext` and its actor. Passing a `@Model` object to a background task accesses it outside its isolation boundary, causing a crash or silent data corruption. The model's properties are not thread-safe.

**Incorrect (sends SwiftData model to background task, violating actor isolation):**

```swift
import SwiftData
import Foundation

@Model
class Bookmark {
    var title: String
    var url: String
    var isSynced: Bool

    init(title: String, url: String) {
        self.title = title
        self.url = url
        self.isSynced = false
    }
}

@MainActor
class BookmarkManager {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func syncBookmark(_ bookmark: Bookmark) {
        Task.detached {
            // Accessing @Model off its ModelContext actor — crash
            bookmark.isSynced = true
            try await self.uploadToServer(title: bookmark.title)
        }
    }

    private func uploadToServer(title: String) async throws {
        try await Task.sleep(for: .milliseconds(100))
    }
}
```

**Proof Test (exposes the crash by mutating model on wrong actor):**

```swift
import XCTest
import SwiftData

final class BookmarkManagerThreadTests: XCTestCase {
    @MainActor
    func testSyncBookmarkDoesNotCrash() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Bookmark.self, configurations: config
        )
        let context = container.mainContext

        let bookmark = Bookmark(title: "Apple", url: "https://apple.com")
        context.insert(bookmark)
        try context.save()

        let manager = BookmarkManager(modelContext: context)
        manager.syncBookmark(bookmark)

        // Allow background task to execute
        try await Task.sleep(for: .seconds(1))
        // With incorrect code, crash occurs before reaching this assertion
        XCTAssertTrue(bookmark.isSynced)
    }
}
```

**Correct (transfers PersistentIdentifier and refetches in background context):**

```swift
import SwiftData
import Foundation

@MainActor
class BookmarkManager {
    let modelContainer: ModelContainer
    let modelContext: ModelContext

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
    }

    func syncBookmark(_ bookmark: Bookmark) {
        let id = bookmark.persistentModelID  // thread-safe identifier

        Task.detached {
            let bgContext = ModelContext(self.modelContainer)
            guard let bgBookmark = bgContext.model(for: id) as? Bookmark else {
                return
            }
            // Safe — accessing on bgContext's owning thread
            try await self.uploadToServer(title: bgBookmark.title)
            bgBookmark.isSynced = true
            try bgContext.save()
        }
    }

    private func uploadToServer(title: String) async throws {
        try await Task.sleep(for: .milliseconds(100))
    }
}
```
