---
name: python
description: Python 3.11+ performance optimization guidelines (formerly python-311). This skill should be used when writing, reviewing, or refactoring Python code to ensure optimal performance patterns. Triggers on tasks involving asyncio, data structures, memory management, concurrency, loops, strings, or Python idioms.
---

# Python 3.11 Best Practices

Comprehensive performance optimization guide for Python 3.11+ applications. Contains 42 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Writing new Python async I/O code
- Choosing data structures for collections
- Optimizing memory usage in data-intensive applications
- Implementing concurrent or parallel processing
- Reviewing Python code for performance issues

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | I/O & Async Patterns | CRITICAL | `io-` |
| 2 | Data Structure Selection | CRITICAL | `ds-` |
| 3 | Memory Optimization | HIGH | `mem-` |
| 4 | Concurrency & Parallelism | HIGH | `conc-` |
| 5 | Loop & Iteration | MEDIUM | `loop-` |
| 6 | String Operations | MEDIUM | `str-` |
| 7 | Function & Call Overhead | LOW-MEDIUM | `func-` |
| 8 | Python Idioms & Micro | LOW | `py-` |

## Quick Reference

### 1. I/O & Async Patterns (CRITICAL)

- [`io-async-gather`](references/io-async-gather.md) - Use asyncio.gather() for concurrent I/O
- [`io-connection-pooling`](references/io-connection-pooling.md) - Use connection pooling for database access
- [`io-defer-await`](references/io-defer-await.md) - Defer await until value needed
- [`io-aiofiles`](references/io-aiofiles.md) - Use aiofiles for async file operations
- [`io-uvloop`](references/io-uvloop.md) - Use uvloop for faster event loop
- [`io-semaphore`](references/io-semaphore.md) - Use semaphores to limit concurrent operations

### 2. Data Structure Selection (CRITICAL)

- [`ds-set-for-membership`](references/ds-set-for-membership.md) - Use Set for O(1) membership testing
- [`ds-dict-for-lookup`](references/ds-dict-for-lookup.md) - Use Dict for O(1) key-value lookup
- [`ds-deque-for-queue`](references/ds-deque-for-queue.md) - Use deque for O(1) queue operations
- [`ds-defaultdict`](references/ds-defaultdict.md) - Use defaultdict to avoid key existence checks
- [`ds-frozenset-for-hashable`](references/ds-frozenset-for-hashable.md) - Use frozenset for hashable set keys
- [`ds-bisect-sorted`](references/ds-bisect-sorted.md) - Use bisect for O(log n) sorted list operations

### 3. Memory Optimization (HIGH)

- [`mem-generators`](references/mem-generators.md) - Use generators for large sequences
- [`mem-slots`](references/mem-slots.md) - Use __slots__ for memory-efficient classes
- [`mem-intern-strings`](references/mem-intern-strings.md) - Intern repeated strings to save memory
- [`mem-array-for-numeric`](references/mem-array-for-numeric.md) - Use array.array for homogeneous numeric data
- [`mem-weak-references`](references/mem-weak-references.md) - Use weakref for caches to prevent memory leaks

### 4. Concurrency & Parallelism (HIGH)

- [`conc-asyncio-for-io`](references/conc-asyncio-for-io.md) - Use asyncio for I/O-bound concurrency
- [`conc-multiprocessing-cpu`](references/conc-multiprocessing-cpu.md) - Use multiprocessing for CPU-bound parallelism
- [`conc-threadpool-blocking`](references/conc-threadpool-blocking.md) - Use ThreadPoolExecutor for blocking calls in async
- [`conc-taskgroup`](references/conc-taskgroup.md) - Use TaskGroup for structured concurrency
- [`conc-queue-communication`](references/conc-queue-communication.md) - Use Queue for thread-safe communication

### 5. Loop & Iteration (MEDIUM)

- [`loop-comprehension`](references/loop-comprehension.md) - Use list comprehensions over explicit loops
- [`loop-hoist-invariants`](references/loop-hoist-invariants.md) - Hoist loop-invariant computations
- [`loop-enumerate`](references/loop-enumerate.md) - Use enumerate() for index-value iteration
- [`loop-itertools`](references/loop-itertools.md) - Use itertools for efficient iteration patterns
- [`loop-any-all`](references/loop-any-all.md) - Use any() and all() for boolean aggregation
- [`loop-dict-items`](references/loop-dict-items.md) - Use dict.items() for key-value iteration

### 6. String Operations (MEDIUM)

- [`str-join-concatenation`](references/str-join-concatenation.md) - Use join() for multiple string concatenation
- [`str-fstring`](references/str-fstring.md) - Use f-strings for simple string formatting
- [`str-startswith-tuple`](references/str-startswith-tuple.md) - Use str.startswith() with tuple for multiple prefixes
- [`str-translate`](references/str-translate.md) - Use str.translate() for character-level replacements

### 7. Function & Call Overhead (LOW-MEDIUM)

- [`func-lru-cache`](references/func-lru-cache.md) - Use lru_cache for expensive function memoization
- [`func-reduce-calls`](references/func-reduce-calls.md) - Reduce function calls in tight loops
- [`func-keyword-only`](references/func-keyword-only.md) - Use keyword-only arguments for API clarity
- [`func-partial`](references/func-partial.md) - Use functools.partial for pre-filled arguments

### 8. Python Idioms & Micro (LOW)

- [`py-local-variables`](references/py-local-variables.md) - Prefer local variables over global lookups
- [`py-walrus-operator`](references/py-walrus-operator.md) - Use walrus operator for assignment in expressions
- [`py-dataclass`](references/py-dataclass.md) - Use dataclass for data-holding classes
- [`py-zero-cost-exceptions`](references/py-zero-cost-exceptions.md) - Leverage zero-cost exception handling
- [`py-match-statement`](references/py-match-statement.md) - Use match statement for structural pattern matching
- [`py-lazy-import`](references/py-lazy-import.md) - Use lazy imports for faster startup

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Full Compiled Document

For the complete guide with all rules in a single file, see [AGENTS.md](AGENTS.md).

## Reference Files

| File | Description |
|------|-------------|
| [AGENTS.md](AGENTS.md) | Complete compiled guide with all rules |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
