---
name: ios-chaos-monkey
description: Crash-hunter skill for iOS 26 / Swift 6.2 clinic-architecture codebases that finds and fixes concurrency, memory, and I/O bugs using TDD. Covers data races, actor isolation, retain cycles, SwiftData context misuse, and sync-related failures in Domain/Data/App boundaries. Use when debugging crashes or hard-to-reproduce failures in ios-* and swift-* clinic modules.
---

# iOS Chaos Monkey — Crash-Hunter Best Practices

Adversarial crash-hunting guide for iOS and Swift applications. Contains 47 rules across 8 categories, prioritized by crash severity. Every rule follows TDD: dangerous code first, a failing test that proves the bug, then the fix that makes the test pass.


## Clinic Architecture Contract (iOS 26 / Swift 6.2)

All guidance in this skill assumes the clinic modular MVVM-C architecture:

- Feature modules import `Domain` + `DesignSystem` only (never `Data`, never sibling features)
- App target is the convergence point and owns `DependencyContainer`, concrete coordinators, and Route Shell wiring
- `Domain` stays pure Swift and defines models plus repository, `*Coordinating`, `ErrorRouting`, and `AppError` contracts
- `Data` owns SwiftData/network/sync/retry/background I/O and implements Domain protocols
- Read/write flow defaults to stale-while-revalidate reads and optimistic queued writes
- ViewModels call repository protocols directly (no default use-case/interactor layer)

## When to Apply

Reference these guidelines when:
- Hunting data races, deadlocks, and concurrency crashes in Swift
- Auditing memory management for retain cycles and use-after-free
- Reviewing async/await code for cancellation and continuation leaks
- Stress-testing file I/O and CoreData/SwiftData persistence layers
- Writing proof-of-crash tests before implementing fixes

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Data Races & Thread Safety | CRITICAL | `race-` |
| 2 | Memory Corruption & Leaks | CRITICAL | `mem-` |
| 3 | Deadlocks & Thread Starvation | HIGH | `dead-` |
| 4 | Async/Await & Structured Concurrency | HIGH | `async-` |
| 5 | File I/O & Persistence Corruption | MEDIUM-HIGH | `io-` |
| 6 | Collection & State Mutation | MEDIUM | `mut-` |
| 7 | Resource Exhaustion | MEDIUM | `exhaust-` |
| 8 | Objective-C Interop Traps | LOW-MEDIUM | `objc-` |

## Quick Reference

### 1. Data Races & Thread Safety (CRITICAL)

- [`race-dictionary-concurrent-write`](references/race-dictionary-concurrent-write.md) - Concurrent Dictionary mutation crashes with EXC_BAD_ACCESS
- [`race-array-concurrent-append`](references/race-array-concurrent-append.md) - Concurrent Array append corrupts internal buffer
- [`race-property-access`](references/race-property-access.md) - Unsynchronized property read-write across threads
- [`race-lazy-initialization`](references/race-lazy-initialization.md) - Lazy property double-initialization under concurrency
- [`race-singleton-initialization`](references/race-singleton-initialization.md) - Non-atomic singleton exposes partially constructed state
- [`race-bool-flag`](references/race-bool-flag.md) - Non-atomic Bool flag creates check-then-act race
- [`race-closure-capture-mutation`](references/race-closure-capture-mutation.md) - Closure captures mutable reference across threads
- [`race-delegate-nilification`](references/race-delegate-nilification.md) - Delegate set to nil during active callback

### 2. Memory Corruption & Leaks (CRITICAL)

- [`mem-closure-retain-cycle`](references/mem-closure-retain-cycle.md) - Strong self capture in escaping closures creates retain cycle
- [`mem-timer-retain-cycle`](references/mem-timer-retain-cycle.md) - Timer retains target creating undiscoverable retain cycle
- [`mem-delegate-strong-reference`](references/mem-delegate-strong-reference.md) - Strong delegate reference prevents deallocation
- [`mem-unowned-crash`](references/mem-unowned-crash.md) - Unowned reference crashes after owner deallocation
- [`mem-notification-observer-leak`](references/mem-notification-observer-leak.md) - NotificationCenter observer retains closure after removal needed
- [`mem-combine-sink-retain`](references/mem-combine-sink-retain.md) - Combine sink retains self without cancellable storage
- [`mem-async-task-self-capture`](references/mem-async-task-self-capture.md) - Task captures self extending lifetime beyond expected scope

### 3. Deadlocks & Thread Starvation (HIGH)

- [`dead-sync-on-main`](references/dead-sync-on-main.md) - DispatchQueue.main.sync from main thread deadlocks instantly
- [`dead-recursive-lock`](references/dead-recursive-lock.md) - Recursive lock acquisition on same serial queue
- [`dead-actor-reentrancy`](references/dead-actor-reentrancy.md) - Actor reentrancy produces unexpected interleaving
- [`dead-semaphore-in-async`](references/dead-semaphore-in-async.md) - Semaphore.wait() inside async context deadlocks thread pool
- [`dead-queue-hierarchy`](references/dead-queue-hierarchy.md) - Dispatch queue target hierarchy inversion deadlocks
- [`dead-mainactor-blocking`](references/dead-mainactor-blocking.md) - Blocking MainActor with synchronous heavy work

### 4. Async/Await & Structured Concurrency (HIGH)

- [`async-missing-cancellation`](references/async-missing-cancellation.md) - Missing Task.isCancelled check wastes resources after navigation
- [`async-detached-task-leak`](references/async-detached-task-leak.md) - Detached task without cancellation handle leaks work
- [`async-task-group-error`](references/async-task-group-error.md) - TaskGroup silently drops child task errors
- [`async-continuation-leak`](references/async-continuation-leak.md) - CheckedContinuation never resumed leaks awaiting task
- [`async-actor-hop-starvation`](references/async-actor-hop-starvation.md) - Excessive MainActor hops in hot loop starve UI updates
- [`async-unsafe-sendable`](references/async-unsafe-sendable.md) - @unchecked Sendable hides data race from compiler

### 5. File I/O & Persistence Corruption (MEDIUM-HIGH)

- [`io-concurrent-file-write`](references/io-concurrent-file-write.md) - Concurrent file writes corrupt data without coordination
- [`io-coredata-cross-thread`](references/io-coredata-cross-thread.md) - CoreData NSManagedObject accessed from wrong thread
- [`io-swiftdata-background`](references/io-swiftdata-background.md) - SwiftData model accessed from wrong ModelContext
- [`io-plist-concurrent-mutation`](references/io-plist-concurrent-mutation.md) - UserDefaults concurrent read-write produces stale values
- [`io-filemanager-race`](references/io-filemanager-race.md) - FileManager existence check then use is a TOCTOU race
- [`io-keychain-thread-safety`](references/io-keychain-thread-safety.md) - Keychain access from multiple threads returns unexpected errors

### 6. Collection & State Mutation (MEDIUM)

- [`mut-enumerate-and-mutate`](references/mut-enumerate-and-mutate.md) - Collection mutation during enumeration crashes at runtime
- [`mut-kvo-dealloc-crash`](references/mut-kvo-dealloc-crash.md) - KVO observer not removed before deallocation crashes
- [`mut-index-out-of-bounds`](references/mut-index-out-of-bounds.md) - Array index access without bounds check crashes
- [`mut-force-unwrap`](references/mut-force-unwrap.md) - Force unwrapping optional in production crashes on nil
- [`mut-enum-future-cases`](references/mut-enum-future-cases.md) - Non-exhaustive switch crashes on unknown enum case

### 7. Resource Exhaustion (MEDIUM)

- [`exhaust-unbounded-task-spawn`](references/exhaust-unbounded-task-spawn.md) - Unbounded task spawning in loop exhausts memory
- [`exhaust-thread-explosion`](references/exhaust-thread-explosion.md) - GCD creates unbounded threads under concurrent load
- [`exhaust-urlsession-leak`](references/exhaust-urlsession-leak.md) - URLSession not invalidated leaks delegate and connections
- [`exhaust-file-descriptor-leak`](references/exhaust-file-descriptor-leak.md) - File handle not closed leaks file descriptors
- [`exhaust-memory-warning-ignored`](references/exhaust-memory-warning-ignored.md) - Low memory warning ignored triggers Jetsam kill

### 8. Objective-C Interop Traps (LOW-MEDIUM)

- [`objc-unrecognized-selector`](references/objc-unrecognized-selector.md) - Missing @objc annotation crashes with unrecognized selector
- [`objc-nsnull-in-json`](references/objc-nsnull-in-json.md) - NSNull in decoded JSON collection crashes on access
- [`objc-bridge-type-mismatch`](references/objc-bridge-type-mismatch.md) - Swift/ObjC bridge type mismatch crashes at runtime
- [`objc-dynamic-dispatch`](references/objc-dynamic-dispatch.md) - Missing dynamic keyword breaks method swizzling

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
