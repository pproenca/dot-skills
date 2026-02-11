# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Object Allocation (alloc)

**Impact:** CRITICAL
**Description:** GC accounts for 80% of Ruby slowdowns. Every unnecessary allocation increases GC pressure, pause times, and memory footprint. Reducing allocations is the single highest-leverage optimization.

## 2. Collection & Enumeration (enum)

**Impact:** CRITICAL
**Description:** Chained Enumerable methods create N intermediate arrays per stage. Single-pass transforms and lazy evaluation eliminate multiplicative allocations in data pipelines.

## 3. I/O & Database (io)

**Impact:** HIGH
**Description:** Database queries and network I/O dominate wall-clock time. N+1 queries multiply latency by record count. Eager loading and batch processing eliminate the most common bottlenecks.

## 4. String Handling (str)

**Impact:** HIGH
**Description:** Strings are Ruby's most-allocated object type. Frozen strings reduce GC pressure by ~20% and memory by ~100MB in production Rails applications.

## 5. Method & Dispatch (meth)

**Impact:** MEDIUM-HIGH
**Description:** Method lookup, metaprogramming overhead, and dynamic dispatch patterns affect hot-path throughput. Avoiding unnecessary indirection keeps method calls fast.

## 6. Data Structures (ds)

**Impact:** MEDIUM
**Description:** Hash, Array, and Set choice determines lookup complexity. Symbol keys are 1.3-2x faster than string keys on large hashes. Struct outperforms OpenStruct by 10-50x.

## 7. Concurrency (conc)

**Impact:** MEDIUM
**Description:** The GVL limits true parallelism. Choosing fibers for I/O, threads for blocking operations, and Ractors for CPU-bound work determines throughput under load.

## 8. Runtime & Configuration (runtime)

**Impact:** LOW-MEDIUM
**Description:** YJIT delivers 15-25% latency improvement out of the box. GC tuning and frozen_string_literal defaults reduce baseline overhead with minimal code changes.
