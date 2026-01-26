# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Async Runtime Patterns (async)

**Impact:** CRITICAL
**Description:** Wrong async patterns cause deadlocks, starvation, and cascading failures across the entire event loop. These are the hardest bugs to diagnose in production.

## 2. Channel Communication (chan)

**Impact:** CRITICAL
**Description:** Improper channel usage leads to deadlocks, memory leaks, and unbounded growth that crashes systems under load.

## 3. Threading & Synchronization (sync)

**Impact:** HIGH
**Description:** Lock contention and data races are the #1 source of production bugs in concurrent systems. Correct synchronization is essential for reliability.

## 4. Socket & Network I/O (net)

**Impact:** HIGH
**Description:** Network I/O mistakes cause connection leaks, resource exhaustion, and protocol violations that affect all connected clients.

## 5. Terminal & TTY Handling (term)

**Impact:** MEDIUM-HIGH
**Description:** Terminal handling errors leave users with broken shells and unresponsive applications that require process termination.

## 6. Signal & Process Control (sig)

**Impact:** MEDIUM
**Description:** Improper signal handling causes zombie processes, data loss during shutdown, and ungraceful termination.

## 7. File I/O Streaming (io)

**Impact:** MEDIUM
**Description:** Streaming file I/O mistakes cause memory bloat from buffering entire files and blocking the async event loop.

## 8. Event Loop Architecture (loop)

**Impact:** LOW-MEDIUM
**Description:** Architecture patterns for building maintainable, extensible, and testable event-driven systems.
