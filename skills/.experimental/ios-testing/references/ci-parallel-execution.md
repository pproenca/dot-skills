---
title: "Enable Parallel Test Execution"
impact: LOW-MEDIUM
impactDescription: "reduces CI suite time by 40-70%"
tags: ci, parallel, performance, xcode, swift-testing
---

## Enable Parallel Test Execution

Serial test execution leaves most CPU cores idle while a single test runs at a time. Enabling parallel execution in XCTest distributes test classes across multiple simulator clones, cutting wall-clock time by 40-70% on multi-core CI runners. Swift Testing runs tests in parallel by default -- only serialize when tests share mutable state.

**Incorrect (serial execution wastes CI capacity):**

```swift
// Scheme > Test > Options: "Execute in parallel" is UNCHECKED
// CI runs ~200 tests serially — 12 minutes on 8-core runner

// XCTest: all tests run one-by-one on a single simulator
final class SearchServiceTests: XCTestCase {
    func testSearchReturnsResults() async throws {
        let service = SearchService(client: MockAPIClient())
        let results = try await service.search(query: "london")
        XCTAssertFalse(results.isEmpty)
    }

    func testSearchHandlesEmptyQuery() async throws {
        let service = SearchService(client: MockAPIClient())
        let results = try await service.search(query: "")
        XCTAssertTrue(results.isEmpty)
    }
}

// Swift Testing: forcing serial execution unnecessarily
@Suite(.serialized) // blocks parallel execution for no reason
struct PaymentValidationTests {
    @Test func validCardAccepted() {
        let validator = PaymentValidator()
        #expect(validator.validate(card: .stub(number: "4242424242424242")) == .valid)
    }

    @Test func expiredCardRejected() {
        let validator = PaymentValidator()
        #expect(validator.validate(card: .stub(expiry: .distantPast)) == .expired)
    }
}
```

**Correct (parallel execution maximizes CI throughput):**

```swift
// Scheme > Test > Options: "Execute in parallel" is CHECKED
// CI runs ~200 tests in parallel — 4 minutes on 8-core runner

// XCTest: each test class runs on its own simulator clone
final class SearchServiceTests: XCTestCase {
    func testSearchReturnsResults() async throws {
        let service = SearchService(client: MockAPIClient()) // no shared state — safe to parallelize
        let results = try await service.search(query: "london")
        XCTAssertFalse(results.isEmpty)
    }

    func testSearchHandlesEmptyQuery() async throws {
        let service = SearchService(client: MockAPIClient())
        let results = try await service.search(query: "")
        XCTAssertTrue(results.isEmpty)
    }
}

// Swift Testing: parallel by default, only serialize when truly needed
@Suite(.serialized) // justified — tests share a single database instance
struct DatabaseMigrationTests {
    @Test func migratesV1ToV2() async throws {
        let db = try await TestDatabase.shared.reset(to: .v1)
        try await db.migrate()
        #expect(db.schemaVersion == 2)
    }

    @Test func migratesV2ToV3() async throws {
        let db = try await TestDatabase.shared.reset(to: .v2)
        try await db.migrate()
        #expect(db.schemaVersion == 3)
    }
}

// Swift Testing: stateless tests run in parallel automatically
struct PaymentValidationTests {
    @Test func validCardAccepted() {
        let validator = PaymentValidator()
        #expect(validator.validate(card: .stub(number: "4242424242424242")) == .valid)
    }

    @Test func expiredCardRejected() {
        let validator = PaymentValidator() // each test creates its own instance — parallel-safe
        #expect(validator.validate(card: .stub(expiry: .distantPast)) == .expired)
    }
}
```
