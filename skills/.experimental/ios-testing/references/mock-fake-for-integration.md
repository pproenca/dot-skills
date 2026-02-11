---
title: "Use In-Memory Fakes for Integration Tests"
impact: MEDIUM
impactDescription: "5-20x faster than real persistence layer"
tags: mock, fake, integration, persistence, in-memory
---

## Use In-Memory Fakes for Integration Tests

Integration tests that spin up a real CoreData or SwiftData stack write to disk, require teardown, and run 5-20x slower than in-memory alternatives. An in-memory fake repository implements the same protocol as the production store, enabling full CRUD integration tests without file system dependencies or cross-test contamination.

**Incorrect (real persistence stack is slow and leaks between tests):**

```swift
func testSaveAndFetchBookmarks() async throws {
    let container = try ModelContainer(for: Bookmark.self) // writes to disk — slow setup, requires cleanup
    let context = container.mainContext
    let repository = BookmarkRepository(context: context)

    try await repository.save(Bookmark(title: "Swift Testing", url: "https://swift.org"))
    let bookmarks = try await repository.fetchAll()

    XCTAssertEqual(bookmarks.count, 1) // may fail if previous test left data behind
}
```

**Correct (in-memory fake is fast and isolated per test):**

```swift
final class InMemoryBookmarkRepository: BookmarkStoring {
    private var storage: [Bookmark] = [] // in-memory — zero disk I/O, no cross-test contamination

    func save(_ bookmark: Bookmark) async throws {
        storage.append(bookmark)
    }

    func fetchAll() async throws -> [Bookmark] {
        return storage
    }

    func delete(_ bookmark: Bookmark) async throws {
        storage.removeAll { $0.id == bookmark.id }
    }
}

func testSaveAndFetchBookmarks() async throws {
    let repository = InMemoryBookmarkRepository() // fresh state every test — runs in microseconds

    try await repository.save(Bookmark(title: "Swift Testing", url: "https://swift.org"))
    let bookmarks = try await repository.fetchAll()

    XCTAssertEqual(bookmarks.count, 1)
    XCTAssertEqual(bookmarks.first?.title, "Swift Testing")
}
```
