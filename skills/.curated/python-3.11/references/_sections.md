# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. I/O & Async Patterns (io)

**Impact:** CRITICAL
**Description:** Blocking I/O is the #1 performance bottleneck. Async patterns eliminate sequential waits, yielding 2-10× throughput improvements for I/O-bound workloads.

## 2. Data Structure Selection (ds)

**Impact:** CRITICAL
**Description:** Wrong data structure choice causes O(n) lookups instead of O(1). Set and dict lookups are 100× faster than list scans for large collections.

## 3. Memory Optimization (mem)

**Impact:** HIGH
**Description:** Excessive allocations trigger garbage collection and increase memory footprint. Generators, __slots__, and object reuse reduce memory 20-50%.

## 4. Concurrency & Parallelism (conc)

**Impact:** HIGH
**Description:** The GIL limits CPU-bound parallelism. Choosing asyncio vs threading vs multiprocessing correctly determines application throughput.

## 5. Loop & Iteration (loop)

**Impact:** MEDIUM
**Description:** Comprehensions are 2-3× faster than explicit loops. Moving invariant work outside loops avoids N× overhead multiplication.

## 6. String Operations (str)

**Impact:** MEDIUM
**Description:** String concatenation in loops is O(n²) due to immutability. Using join() is 4× faster for combining multiple strings.

## 7. Function & Call Overhead (func)

**Impact:** LOW-MEDIUM
**Description:** Function calls cost 50-100ns each in CPython. In tight loops processing millions of items, reducing calls improves throughput.

## 8. Python Idioms & Micro (py)

**Impact:** LOW
**Description:** Pythonic patterns leverage C-optimized internals. Local variables, built-in functions, and modern syntax yield incremental but measurable gains.
