---
title: Preserve the underlying error when rethrowing domain errors
tags: conc, error-handling, diagnostics, error-wrapping
---

## Preserve the underlying error when rethrowing domain errors

The wrong default when translating errors at a layer boundary is `catch { throw AppError.fetchFailed }` — the caught error is discarded and a bare sentinel is thrown in its place. The original failure (the URL that 404'd, the key that failed to decode) is destroyed at exactly the moment it becomes diagnostic evidence, and the log upstream can only say "fetch failed". The book's pattern stores the caught error as an associated value so the domain type adds context without erasing the cause.

**Evidence of violation:** a `catch` clause that throws a newly constructed error carrying no reference to the caught `error` — no associated value, no `underlyingError` storage — while the caught error is otherwise discarded (not logged, not attached). PASS: the wrapper embeds the original (`throw DataProcessingError.dataFetchFailed(underlyingError: error)`), or the original error is rethrown as-is. N/A: the `catch` handles the error without rethrowing, or it logs the original before throwing a sentinel and a comment documents that design.

**Incorrect (the cause is destroyed at the boundary — upstream sees only a bare case):**

```swift
struct Bookmark: Decodable {}
struct BookmarkService: Sendable { func fetchAll() async throws -> Data { Data() } }
let bookmarkService = BookmarkService()

enum SyncError: Error {
    case fetchFailed
}

func syncBookmarks() async throws -> [Bookmark] {
    do {
        let data = try await bookmarkService.fetchAll()
        return try JSONDecoder().decode([Bookmark].self, from: data)
    } catch {
        throw SyncError.fetchFailed
    }
}
```

**Correct (the domain error carries the underlying error as an associated value):**

```swift
struct Bookmark: Decodable {}
struct BookmarkService: Sendable { func fetchAll() async throws -> Data { Data() } }
let bookmarkService = BookmarkService()

enum SyncError: Error {
    case fetchFailed(underlyingError: Error)
}

func syncBookmarks() async throws -> [Bookmark] {
    do {
        let data = try await bookmarkService.fetchAll()
        return try JSONDecoder().decode([Bookmark].self, from: data)
    } catch {
        throw SyncError.fetchFailed(underlyingError: error)
    }
}
```

Reference: *Swift Gems* (Natalia Panferova, Nil Coalescing, updated Nov 2025), “Rethrow errors with added context”.
