# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group references.

---

## 1. Getting Started (getting)

**Impact:** CRITICAL
**Description:** Foundation for all Effect development — includes the paradigm shift guide (mental model, refactoring recipes, anti-patterns, architecture), plus Effect type, pipelines, generators, and execution patterns.

## 2. Error Management (error)

**Impact:** CRITICAL
**Description:** Prevents unhandled errors and incorrect recovery — covers typed errors, retrying, timeouts, sandboxing.

## 3. Schema (schema)

**Impact:** CRITICAL
**Description:** Prevents invalid data from entering the system — covers schema definitions, transformations, filters, JSON Schema output.

## 4. Data Types (data)

**Impact:** HIGH
**Description:** Enables type-safe data modeling — covers Option, Either, Cause, Chunk, DateTime, Duration, Data.

## 5. Concurrency (conc)

**Impact:** HIGH
**Description:** Prevents race conditions and deadlocks — covers fibers, Deferred, Latch, PubSub, Queue, Semaphore.

## 6. Streams and Sinks (streams)

**Impact:** HIGH
**Description:** Enables efficient streaming data processing — covers stream creation, consumption, operations, sinks.

## 7. Requirements Management (req)

**Impact:** HIGH
**Description:** Foundation for Effect dependency injection — covers services, layers, memoization, default services.

## 8. Resource Management (resource)

**Impact:** HIGH
**Description:** Prevents resource leaks — covers Scope, safe acquisition and release, caching.

## 9. State Management (state)

**Impact:** MEDIUM
**Description:** Enables safe concurrent state — covers Ref, SubscriptionRef, SynchronizedRef.

## 10. Core Concepts (core)

**Impact:** MEDIUM
**Description:** Optimizes Effect application architecture — covers request batching, configuration, runtime.

## 11. Code Style (code)

**Impact:** MEDIUM
**Description:** Ensures idiomatic Effect code — covers branded types, pattern matching, dual APIs, Equal, Hash.

## 12. Observability (obs)

**Impact:** MEDIUM
**Description:** Enables production monitoring and debugging — covers logging, metrics, tracing, Supervisor.

## 13. Platform (plat)

**Impact:** MEDIUM
**Description:** Enables cross-platform I/O — covers FileSystem, Command, Terminal, KeyValueStore, Path.

## 14. Scheduling (sched)

**Impact:** MEDIUM
**Description:** Enables precise timing control — covers built-in schedules, cron, combinators, repetition.

## 15. AI Integration (ai)

**Impact:** LOW
**Description:** Enables LLM tool use with Effect — covers Effect AI packages, execution planning, tool definitions.

## 16. Testing (test)

**Impact:** LOW
**Description:** Enables deterministic time-dependent tests — covers TestClock for simulating time passage.

## 17. Micro (micro)

**Impact:** LOW
**Description:** Reduces bundle size while preserving Effect patterns — lightweight alternative for smaller apps.

## 18. Migration (migration)

**Impact:** LOW
**Description:** Eases adoption from other libraries — covers migration from Promise, fp-ts, neverthrow, ZIO.
