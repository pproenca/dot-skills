# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Data Races & Thread Safety (race)

**Impact:** CRITICAL
**Description:** Concurrent access to shared mutable state is the #1 cause of intermittent production crashes. A single unprotected dictionary write from two threads corrupts memory and triggers EXC_BAD_ACCESS that reproduces on 1 in 1000 launches.

## 2. Memory Corruption & Leaks (mem)

**Impact:** CRITICAL
**Description:** Retain cycles, use-after-deallocation, and dangling references cause crashes that manifest far from the source. Memory leaks compound silently until iOS terminates the app under pressure with no stack trace.

## 3. Deadlocks & Thread Starvation (dead)

**Impact:** HIGH
**Description:** Synchronous dispatch on blocked queues, recursive locking, and main thread starvation freeze the app with zero user feedback. The watchdog kills the process after 10 seconds of main thread blockage.

## 4. Async/Await & Structured Concurrency (async)

**Impact:** HIGH
**Description:** Ignored task cancellation, leaked continuations, and actor reentrancy create time-bombs that crash under real-world load. These bugs pass unit tests but detonate in production when timing shifts.

## 5. File I/O & Persistence Corruption (io)

**Impact:** MEDIUM-HIGH
**Description:** CoreData thread violations, concurrent file writes, and SwiftData cross-context access corrupt user data silently. The crash occurs on next launch when the app reads the corrupted store.

## 6. Collection & State Mutation (mut)

**Impact:** MEDIUM
**Description:** Mutating collections during enumeration, KVO observer leaks, and force-unwrapping optionals in production create deterministic crashes that bypass code review because the happy path works.

## 7. Resource Exhaustion (exhaust)

**Impact:** MEDIUM
**Description:** Unbounded task spawning, GCD thread explosion, and file descriptor leaks starve the system until iOS terminates the process. These crashes appear only under sustained load, never in development.

## 8. Objective-C Interop Traps (objc)

**Impact:** LOW-MEDIUM
**Description:** Unrecognized selector crashes, NSNull in decoded JSON, and bridge type mismatches at the Swift/ObjC boundary bypass Swift's type safety and crash at runtime with no compile-time warning.
