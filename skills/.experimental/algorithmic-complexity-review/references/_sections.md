# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Categories are ordered by **cascade severity** — how catastrophically the anti-pattern
scales with input size — multiplied by **frequency** in real code. The highest tiers
contain patterns that turn linear-feeling code into quadratic, exponential, or N+1
disasters at production scale.

---

## 1. Nested Iteration Patterns (nested)

**Impact:** CRITICAL  
**Description:** Nested loops over collections produce O(n²), O(n³), or O(n*m) complexity — the most common production performance killer because it often hides behind innocuous-looking helpers (`.includes`, `.find`, `.indexOf`) called inside a loop. Doubling input size quadruples runtime; at 10× input, a quadratic algorithm runs 100× slower while the call site barely changed.

## 2. Loop-Invariant I/O and N+1 Queries (io)

**Impact:** CRITICAL  
**Description:** Performing a database query, network call, or file read inside a loop multiplies latency by collection size. A 50ms query repeated 200 times is 10 seconds — the database isn't slow, the access pattern is. Batching, eager loading, or hoisting the I/O outside the loop typically yields 10-100× wall-clock improvements with no algorithmic change.

## 3. Data Structure Mismatch (ds)

**Impact:** HIGH  
**Description:** Using the wrong container for the access pattern forces O(n) work where O(1) or O(log n) was available — linear search through arrays, repeated `Array.prototype.includes` on large lists, missing hash sets for membership tests, missing trees/heaps for ordered queries. The fix is a one-line container change that flips an entire loop's complexity class.

## 4. Recursion Complexity (rec)

**Impact:** HIGH  
**Description:** Unmemoized recursion with overlapping subproblems explodes exponentially — naive Fibonacci is O(2ⁿ) versus O(n) memoized, a 1,000,000× difference at n=30. Deep recursion also risks stack overflow on otherwise-correct algorithms. Memoization, tabulation, or iterative reformulation transforms exponential recurrences into polynomial ones.

## 5. Redundant Computation (compute)

**Impact:** MEDIUM-HIGH  
**Description:** Recomputing loop-invariant expressions, parsing the same regex repeatedly, calling pure functions with identical arguments in hot paths — work that gives the same answer every iteration. Hoisting invariants out of loops and caching expensive pure-function results are mechanical refactors that often eliminate 50-90% of CPU time.

## 6. Collection Building (build)

**Impact:** MEDIUM  
**Description:** Building strings or arrays by repeated concatenation creates accidental quadratic complexity — each `s = s + part` may copy the entire prefix. The same trap appears with immutable update patterns (`{...obj, k: v}` in a reducer, `arr.concat(x)` in a loop). Use builders, joins, or mutate-then-freeze patterns to keep construction linear.

## 7. Search & Sort Selection (search)

**Impact:** MEDIUM  
**Description:** Choosing the wrong search or sort strategy — linear scanning when the data is already sorted, re-sorting the same array on every iteration, using O(n log n) general sort when O(n) counting sort fits, or pre-sorting solely to do one lookup. Each is a localized fix but flips a hot loop's complexity class.

## 8. Space Complexity Traps (space)

**Impact:** LOW-MEDIUM  
**Description:** Unnecessary memory allocation — loading whole files instead of streaming, accumulating intermediate arrays before reducing, deep-cloning when a shallow reference suffices, retaining references that prevent garbage collection. Space and time interact: extra allocation creates GC pressure that shows up as latency spikes, not memory errors.
