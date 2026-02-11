# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Memory Allocation (mem)

**Impact:** CRITICAL
**Description:** Unnecessary allocations are the #1 performance killer in Rust. Each clone/Box/Vec allocation involves heap operations that cascade through execution.

## 2. Ownership & Borrowing (own)

**Impact:** CRITICAL
**Description:** Proper ownership eliminates allocations entirely. Incorrect patterns force defensive cloning that compounds across call chains.

## 3. Data Structure Selection (ds)

**Impact:** HIGH
**Description:** Wrong data structure creates O(n) vs O(1) differences that multiply across all operations on that structure.

## 4. Iterator & Collection Patterns (iter)

**Impact:** HIGH
**Description:** Iterator misuse prevents compiler optimizations and causes unnecessary intermediate allocations.

## 5. Async & Concurrency (async)

**Impact:** MEDIUM-HIGH
**Description:** Blocking async executors starves tasks. Lock contention serializes concurrent code. Proper patterns enable massive parallelism.

## 6. Algorithm Complexity (algo)

**Impact:** MEDIUM
**Description:** O(n²) vs O(n) compounds with data growth. Algorithmic improvements yield multiplicative gains on hot paths.

## 7. Compile-Time Optimization (comp)

**Impact:** MEDIUM
**Description:** Monomorphization bloat, const evaluation, and compile-time computation affect binary size, compile time, and cache efficiency.

## 8. Micro-optimizations (micro)

**Impact:** LOW
**Description:** Branch hints, inlining, cache-friendly access patterns for hot paths. Small gains that add up in tight loops.
