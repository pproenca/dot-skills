# Python 3.11

**Version 0.1.0**  
Python Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization guide for Python 3.11+ applications, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (async I/O patterns, data structure selection) to incremental (Python idioms). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [I/O & Async Patterns](#1-io-async-patterns) — **CRITICAL**
   - 1.1 [Defer await Until Value Needed](#11-defer-await-until-value-needed)
   - 1.2 [Use aiofiles for Async File Operations](#12-use-aiofiles-for-async-file-operations)
   - 1.3 [Use asyncio.gather() for Concurrent I/O](#13-use-asynciogather-for-concurrent-io)
   - 1.4 [Use Connection Pooling for Database Access](#14-use-connection-pooling-for-database-access)
   - 1.5 [Use Semaphores to Limit Concurrent Operations](#15-use-semaphores-to-limit-concurrent-operations)
   - 1.6 [Use uvloop for Faster Event Loop](#16-use-uvloop-for-faster-event-loop)
2. [Data Structure Selection](#2-data-structure-selection) — **CRITICAL**
   - 2.1 [Use bisect for O(log n) Sorted List Operations](#21-use-bisect-for-olog-n-sorted-list-operations)
   - 2.2 [Use defaultdict to Avoid Key Existence Checks](#22-use-defaultdict-to-avoid-key-existence-checks)
   - 2.3 [Use deque for O(1) Queue Operations](#23-use-deque-for-o1-queue-operations)
   - 2.4 [Use Dict for O(1) Key-Value Lookup](#24-use-dict-for-o1-key-value-lookup)
   - 2.5 [Use frozenset for Hashable Set Keys](#25-use-frozenset-for-hashable-set-keys)
   - 2.6 [Use Set for O(1) Membership Testing](#26-use-set-for-o1-membership-testing)
3. [Memory Optimization](#3-memory-optimization) — **HIGH**
   - 3.1 [Intern Repeated Strings to Save Memory](#31-intern-repeated-strings-to-save-memory)
   - 3.2 [Use __slots__ for Memory-Efficient Classes](#32-use-slots-for-memory-efficient-classes)
   - 3.3 [Use array.array for Homogeneous Numeric Data](#33-use-arrayarray-for-homogeneous-numeric-data)
   - 3.4 [Use Generators for Large Sequences](#34-use-generators-for-large-sequences)
   - 3.5 [Use weakref for Caches to Prevent Memory Leaks](#35-use-weakref-for-caches-to-prevent-memory-leaks)
4. [Concurrency & Parallelism](#4-concurrency-parallelism) — **HIGH**
   - 4.1 [Use asyncio for I/O-Bound Concurrency](#41-use-asyncio-for-io-bound-concurrency)
   - 4.2 [Use multiprocessing for CPU-Bound Parallelism](#42-use-multiprocessing-for-cpu-bound-parallelism)
   - 4.3 [Use Queue for Thread-Safe Communication](#43-use-queue-for-thread-safe-communication)
   - 4.4 [Use TaskGroup for Structured Concurrency](#44-use-taskgroup-for-structured-concurrency)
   - 4.5 [Use ThreadPoolExecutor for Blocking Calls in Async](#45-use-threadpoolexecutor-for-blocking-calls-in-async)
5. [Loop & Iteration](#5-loop-iteration) — **MEDIUM**
   - 5.1 [Hoist Loop-Invariant Computations](#51-hoist-loop-invariant-computations)
   - 5.2 [Use any() and all() for Boolean Aggregation](#52-use-any-and-all-for-boolean-aggregation)
   - 5.3 [Use dict.items() for Key-Value Iteration](#53-use-dictitems-for-key-value-iteration)
   - 5.4 [Use enumerate() for Index-Value Iteration](#54-use-enumerate-for-index-value-iteration)
   - 5.5 [Use itertools for Efficient Iteration Patterns](#55-use-itertools-for-efficient-iteration-patterns)
   - 5.6 [Use List Comprehensions Over Explicit Loops](#56-use-list-comprehensions-over-explicit-loops)
6. [String Operations](#6-string-operations) — **MEDIUM**
   - 6.1 [Use f-strings for Simple String Formatting](#61-use-f-strings-for-simple-string-formatting)
   - 6.2 [Use join() for Multiple String Concatenation](#62-use-join-for-multiple-string-concatenation)
   - 6.3 [Use str.startswith() with Tuple for Multiple Prefixes](#63-use-strstartswith-with-tuple-for-multiple-prefixes)
   - 6.4 [Use str.translate() for Character-Level Replacements](#64-use-strtranslate-for-character-level-replacements)
7. [Function & Call Overhead](#7-function-call-overhead) — **LOW-MEDIUM**
   - 7.1 [Reduce Function Calls in Tight Loops](#71-reduce-function-calls-in-tight-loops)
   - 7.2 [Use functools.partial for Pre-Filled Arguments](#72-use-functoolspartial-for-pre-filled-arguments)
   - 7.3 [Use Keyword-Only Arguments for API Clarity](#73-use-keyword-only-arguments-for-api-clarity)
   - 7.4 [Use lru_cache for Expensive Function Memoization](#74-use-lrucache-for-expensive-function-memoization)
8. [Python Idioms & Micro](#8-python-idioms-micro) — **LOW**
   - 8.1 [Leverage Zero-Cost Exception Handling](#81-leverage-zero-cost-exception-handling)
   - 8.2 [Prefer Local Variables Over Global Lookups](#82-prefer-local-variables-over-global-lookups)
   - 8.3 [Use dataclass for Data-Holding Classes](#83-use-dataclass-for-data-holding-classes)
   - 8.4 [Use Lazy Imports for Faster Startup](#84-use-lazy-imports-for-faster-startup)
   - 8.5 [Use match Statement for Structural Pattern Matching](#85-use-match-statement-for-structural-pattern-matching)
   - 8.6 [Use Walrus Operator for Assignment in Expressions](#86-use-walrus-operator-for-assignment-in-expressions)

---

## 1. I/O & Async Patterns

**Impact: CRITICAL**

Blocking I/O is the #1 performance bottleneck. Async patterns eliminate sequential waits, yielding 2-10× throughput improvements for I/O-bound workloads.

### 1.1 Defer await Until Value Needed

**Impact: CRITICAL (2-5× faster for dependent operations)**

Start async operations immediately but defer `await` until the value is actually needed. This allows multiple operations to run concurrently while the code proceeds.

**Incorrect (blocks immediately):**

```python
async def process_order(order_id: str) -> dict:
    order = await fetch_order(order_id)  # Blocks here
    user = await fetch_user(order.user_id)  # Waits for order first
    inventory = await check_inventory(order.items)  # Waits for user
    # Total: order + user + inventory
    return {"order": order, "user": user, "inventory": inventory}
```

**Correct (starts early, awaits late):**

```python
async def process_order(order_id: str) -> dict:
    order_task = asyncio.create_task(fetch_order(order_id))  # Starts immediately

    order = await order_task  # Now we need the order

    # Start both in parallel since they only need order data
    user_task = asyncio.create_task(fetch_user(order.user_id))
    inventory_task = asyncio.create_task(check_inventory(order.items))

    user = await user_task
    inventory = await inventory_task
    # Total: order + max(user, inventory)
    return {"order": order, "user": user, "inventory": inventory}
```

**Note:** Use `asyncio.create_task()` to start coroutines immediately. The task runs in the background until awaited.

Reference: [Python asyncio.create_task](https://docs.python.org/3/library/asyncio-task.html#asyncio.create_task)

### 1.2 Use aiofiles for Async File Operations

**Impact: CRITICAL (prevents event loop blocking)**

Standard file operations block the event loop, preventing other coroutines from running. Use `aiofiles` for non-blocking file I/O in async applications.

**Incorrect (blocks event loop):**

```python
async def process_log_files(log_paths: list[str]) -> list[dict]:
    results = []
    for path in log_paths:
        with open(path, "r") as f:  # Blocks entire event loop
            content = f.read()
            results.append(parse_log(content))
    return results
```

**Correct (non-blocking):**

```python
import aiofiles

async def process_log_files(log_paths: list[str]) -> list[dict]:
    async def read_and_parse(path: str) -> dict:
        async with aiofiles.open(path, "r") as f:  # Non-blocking
            content = await f.read()
            return parse_log(content)

    return await asyncio.gather(*[read_and_parse(path) for path in log_paths])
```

**Alternative (thread pool for sync I/O):**

```python
async def process_log_files(log_paths: list[str]) -> list[dict]:
    loop = asyncio.get_running_loop()

    def read_sync(path: str) -> dict:
        with open(path, "r") as f:
            return parse_log(f.read())

    tasks = [loop.run_in_executor(None, read_sync, path) for path in log_paths]
    return await asyncio.gather(*tasks)
```

Reference: [aiofiles documentation](https://github.com/Tinche/aiofiles)

### 1.3 Use asyncio.gather() for Concurrent I/O

**Impact: CRITICAL (2-10× throughput improvement)**

When multiple I/O operations have no dependencies, execute them concurrently with `asyncio.gather()`. Sequential awaits create waterfalls where each operation waits for the previous one to complete.

**Incorrect (sequential execution, 3 round trips):**

```python
async def fetch_user_data(user_id: str) -> dict:
    profile = await fetch_profile(user_id)
    orders = await fetch_orders(user_id)
    preferences = await fetch_preferences(user_id)
    # Total time: profile + orders + preferences
    return {"profile": profile, "orders": orders, "preferences": preferences}
```

**Correct (concurrent execution, 1 round trip):**

```python
async def fetch_user_data(user_id: str) -> dict:
    profile, orders, preferences = await asyncio.gather(
        fetch_profile(user_id),
        fetch_orders(user_id),
        fetch_preferences(user_id),
    )
    # Total time: max(profile, orders, preferences)
    return {"profile": profile, "orders": orders, "preferences": preferences}
```

**When NOT to use this pattern:**
- When operations depend on each other's results
- When you need to handle individual failures differently (use `return_exceptions=True` or `asyncio.TaskGroup`)

Reference: [Python asyncio documentation](https://docs.python.org/3/library/asyncio-task.html#asyncio.gather)

### 1.4 Use Connection Pooling for Database Access

**Impact: CRITICAL (100-200ms saved per connection)**

Creating database connections is expensive, typically taking 100-200ms. Connection pools maintain reusable connections, eliminating this overhead for each query.

**Incorrect (new connection per query):**

```python
async def get_user(user_id: int) -> dict:
    conn = await asyncpg.connect(DATABASE_URL)  # 100-200ms overhead
    try:
        row = await conn.fetchrow("SELECT * FROM users WHERE id = $1", user_id)
        return dict(row)
    finally:
        await conn.close()

async def get_orders(user_id: int) -> list:
    conn = await asyncpg.connect(DATABASE_URL)  # Another 100-200ms overhead
    try:
        rows = await conn.fetch("SELECT * FROM orders WHERE user_id = $1", user_id)
        return [dict(row) for row in rows]
    finally:
        await conn.close()
```

**Correct (shared connection pool):**

```python
pool: asyncpg.Pool | None = None

async def init_pool():
    global pool
    pool = await asyncpg.create_pool(DATABASE_URL, min_size=5, max_size=20)

async def get_user(user_id: int) -> dict:
    async with pool.acquire() as conn:  # Reuses existing connection
        row = await conn.fetchrow("SELECT * FROM users WHERE id = $1", user_id)
        return dict(row)

async def get_orders(user_id: int) -> list:
    async with pool.acquire() as conn:  # Reuses existing connection
        rows = await conn.fetch("SELECT * FROM orders WHERE user_id = $1", user_id)
        return [dict(row) for row in rows]
```

Reference: [asyncpg documentation](https://magicstack.github.io/asyncpg/current/usage.html#connection-pools)

### 1.5 Use Semaphores to Limit Concurrent Operations

**Impact: CRITICAL (prevents resource exhaustion)**

Unbounded concurrency can exhaust resources like file descriptors, memory, or API rate limits. Use `asyncio.Semaphore` to cap concurrent operations.

**Incorrect (unbounded concurrency):**

```python
async def fetch_all_urls(urls: list[str]) -> list[str]:
    async def fetch(url: str) -> str:
        async with aiohttp.ClientSession() as session:
            async with session.get(url) as response:
                return await response.text()

    # Launches all requests simultaneously - may exhaust connections
    return await asyncio.gather(*[fetch(url) for url in urls])
```

**Correct (bounded concurrency):**

```python
async def fetch_all_urls(urls: list[str], max_concurrent: int = 10) -> list[str]:
    semaphore = asyncio.Semaphore(max_concurrent)

    async def fetch(url: str) -> str:
        async with semaphore:  # Limits concurrent requests
            async with aiohttp.ClientSession() as session:
                async with session.get(url) as response:
                    return await response.text()

    return await asyncio.gather(*[fetch(url) for url in urls])
```

**Alternative (connection pool with aiohttp):**

```python
async def fetch_all_urls(urls: list[str]) -> list[str]:
    connector = aiohttp.TCPConnector(limit=10)  # Built-in limiting
    async with aiohttp.ClientSession(connector=connector) as session:
        async def fetch(url: str) -> str:
            async with session.get(url) as response:
                return await response.text()

        return await asyncio.gather(*[fetch(url) for url in urls])
```

Reference: [asyncio.Semaphore documentation](https://docs.python.org/3/library/asyncio-sync.html#asyncio.Semaphore)

### 1.6 Use uvloop for Faster Event Loop

**Impact: CRITICAL (2-4× faster async I/O)**

`uvloop` is a drop-in replacement for asyncio's event loop, built on libuv. It provides 2-4× faster I/O performance with a single configuration change.

**Incorrect (default event loop):**

```python
import asyncio

async def main():
    results = await asyncio.gather(
        fetch_users(),
        fetch_orders(),
        fetch_inventory(),
    )
    return results

if __name__ == "__main__":
    asyncio.run(main())  # Uses default event loop
```

**Correct (uvloop event loop):**

```python
import asyncio
import uvloop

async def main():
    results = await asyncio.gather(
        fetch_users(),
        fetch_orders(),
        fetch_inventory(),
    )
    return results

if __name__ == "__main__":
    uvloop.install()  # Single line change
    asyncio.run(main())  # Now uses uvloop
```

**Alternative (set policy explicitly):**

```python
import asyncio
import uvloop

asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())
```

**When NOT to use this pattern:**
- On Windows (uvloop is Unix-only)
- When debugging with asyncio debug mode

Reference: [uvloop documentation](https://github.com/MagicStack/uvloop)

---

## 2. Data Structure Selection

**Impact: CRITICAL**

Wrong data structure choice causes O(n) lookups instead of O(1). Set and dict lookups are 100× faster than list scans for large collections.

### 2.1 Use bisect for O(log n) Sorted List Operations

**Impact: CRITICAL (O(n) to O(log n) search)**

Linear search through a sorted list wastes the sorted property. The `bisect` module provides O(log n) binary search operations.

**Incorrect (O(n) linear search):**

```python
def find_price_tier(price: float, thresholds: list[float]) -> int:
    # thresholds = [10.0, 25.0, 50.0, 100.0, 250.0] (sorted)
    tier = 0
    for i, threshold in enumerate(thresholds):  # O(n) scan
        if price >= threshold:
            tier = i + 1
        else:
            break
    return tier
```

**Correct (O(log n) binary search):**

```python
import bisect

def find_price_tier(price: float, thresholds: list[float]) -> int:
    # thresholds = [10.0, 25.0, 50.0, 100.0, 250.0] (sorted)
    return bisect.bisect_right(thresholds, price)  # O(log n)
```

**Alternative (maintaining sorted order):**

```python
import bisect

def add_score_sorted(scores: list[int], new_score: int) -> None:
    bisect.insort(scores, new_score)  # O(n) insert but maintains order
    # Better than: scores.append(new_score); scores.sort()  # O(n log n)
```

**Note:** `bisect_left` finds leftmost position, `bisect_right` finds rightmost for equal values.

Reference: [bisect documentation](https://docs.python.org/3/library/bisect.html)

### 2.2 Use defaultdict to Avoid Key Existence Checks

**Impact: CRITICAL (eliminates redundant lookups)**

Checking if a key exists before modifying it requires two lookups. `defaultdict` auto-initializes missing keys, reducing code and improving performance.

**Incorrect (double lookup per key):**

```python
def group_orders_by_user(orders: list[dict]) -> dict[int, list[dict]]:
    grouped = {}
    for order in orders:
        user_id = order["user_id"]
        if user_id not in grouped:  # First lookup
            grouped[user_id] = []
        grouped[user_id].append(order)  # Second lookup
    return grouped
```

**Correct (single lookup):**

```python
from collections import defaultdict

def group_orders_by_user(orders: list[dict]) -> dict[int, list[dict]]:
    grouped = defaultdict(list)
    for order in orders:
        grouped[order["user_id"]].append(order)  # Single lookup, auto-creates list
    return dict(grouped)
```

**Alternative (setdefault):**

```python
def group_orders_by_user(orders: list[dict]) -> dict[int, list[dict]]:
    grouped = {}
    for order in orders:
        grouped.setdefault(order["user_id"], []).append(order)
    return grouped
```

**Note:** Convert back to regular dict if you need strict KeyError behavior later.

Reference: [collections.defaultdict documentation](https://docs.python.org/3/library/collections.html#collections.defaultdict)

### 2.3 Use deque for O(1) Queue Operations

**Impact: CRITICAL (O(n) to O(1) for popleft)**

List `pop(0)` is O(n) because all remaining elements must shift. `collections.deque` provides O(1) operations on both ends.

**Incorrect (O(n) popleft):**

```python
def process_tasks(tasks: list[str]) -> list[str]:
    queue = tasks.copy()
    results = []
    while queue:
        task = queue.pop(0)  # O(n) - shifts all elements left
        results.append(execute_task(task))
    return results
# n tasks × O(n) shift = O(n²) total
```

**Correct (O(1) popleft):**

```python
from collections import deque

def process_tasks(tasks: list[str]) -> list[str]:
    queue = deque(tasks)  # O(n) conversion once
    results = []
    while queue:
        task = queue.popleft()  # O(1) - doubly-linked list
        results.append(execute_task(task))
    return results
# n tasks × O(1) = O(n) total
```

**Benefits:**
- `appendleft()` and `popleft()` are O(1)
- `append()` and `pop()` are O(1)
- Thread-safe for single append/pop operations
- Optional `maxlen` for fixed-size buffers

Reference: [collections.deque documentation](https://docs.python.org/3/library/collections.html#collections.deque)

### 2.4 Use Dict for O(1) Key-Value Lookup

**Impact: CRITICAL (O(n) to O(1) lookup)**

Searching a list of tuples or objects for a key is O(n). Converting to a dict provides O(1) lookup by key, critical for repeated access patterns.

**Incorrect (O(n) search per lookup):**

```python
def get_user_emails(user_ids: list[int], users: list[tuple[int, str]]) -> list[str]:
    emails = []
    for user_id in user_ids:
        for uid, email in users:  # O(n) scan for each user_id
            if uid == user_id:
                emails.append(email)
                break
    return emails
```

**Correct (O(1) lookup):**

```python
def get_user_emails(user_ids: list[int], users: list[tuple[int, str]]) -> list[str]:
    user_map = {uid: email for uid, email in users}  # One-time O(n) conversion
    return [user_map[user_id] for user_id in user_ids if user_id in user_map]
```

**Alternative (with default value):**

```python
def get_user_emails(user_ids: list[int], users: list[tuple[int, str]]) -> list[str]:
    user_map = dict(users)
    return [user_map.get(user_id, "unknown@example.com") for user_id in user_ids]
```

Reference: [Python Data Structures](https://docs.python.org/3/tutorial/datastructures.html#dictionaries)

### 2.5 Use frozenset for Hashable Set Keys

**Impact: CRITICAL (enables set-of-sets patterns)**

Regular sets are mutable and unhashable, so they cannot be dict keys or set members. Use `frozenset` for immutable, hashable sets.

**Incorrect (unhashable set as key):**

```python
def find_duplicate_permission_groups(users: list[dict]) -> list[set]:
    seen = {}
    duplicates = []
    for user in users:
        perms = set(user["permissions"])
        if perms in seen:  # TypeError: unhashable type: 'set'
            duplicates.append(perms)
        seen[perms] = user["id"]
    return duplicates
```

**Correct (hashable frozenset):**

```python
def find_duplicate_permission_groups(users: list[dict]) -> list[set]:
    seen = {}
    duplicates = []
    for user in users:
        perms = frozenset(user["permissions"])  # Immutable and hashable
        if perms in seen:  # O(1) lookup works
            duplicates.append(set(perms))
        seen[perms] = user["id"]
    return duplicates
```

**Alternative (caching computed sets):**

```python
from functools import cache

@cache
def compute_dependencies(package: frozenset[str]) -> frozenset[str]:
    # frozenset enables caching of set-based inputs
    return frozenset(resolve_deps(package))
```

Reference: [frozenset documentation](https://docs.python.org/3/library/stdtypes.html#frozenset)

### 2.6 Use Set for O(1) Membership Testing

**Impact: CRITICAL (O(n) to O(1) lookup)**

List membership testing with `in` is O(n), scanning every element. Set membership is O(1) using hash lookup, making it 100× faster for large collections.

**Incorrect (O(n) per lookup):**

```python
def filter_valid_users(user_ids: list[int], valid_ids: list[int]) -> list[int]:
    result = []
    for user_id in user_ids:
        if user_id in valid_ids:  # O(n) scan on every iteration
            result.append(user_id)
    return result
# 10,000 users × 10,000 valid IDs = 100M comparisons
```

**Correct (O(1) per lookup):**

```python
def filter_valid_users(user_ids: list[int], valid_ids: list[int]) -> list[int]:
    valid_set = set(valid_ids)  # One-time O(n) conversion
    result = []
    for user_id in user_ids:
        if user_id in valid_set:  # O(1) hash lookup
            result.append(user_id)
    return result
# 10,000 users × O(1) = 10,000 operations
```

**Even better (comprehension):**

```python
def filter_valid_users(user_ids: list[int], valid_ids: list[int]) -> list[int]:
    valid_set = set(valid_ids)
    return [user_id for user_id in user_ids if user_id in valid_set]
```

Reference: [Python Wiki - Time Complexity](https://wiki.python.org/moin/TimeComplexity)

---

## 3. Memory Optimization

**Impact: HIGH**

Excessive allocations trigger garbage collection and increase memory footprint. Generators, __slots__, and object reuse reduce memory 20-50%.

### 3.1 Intern Repeated Strings to Save Memory

**Impact: HIGH (reduces duplicate string storage)**

When the same string appears thousands of times (e.g., status codes, keys), each occurrence normally creates a new object. String interning reuses the same object.

**Incorrect (duplicate string objects):**

```python
def process_events(events: list[dict]) -> list[dict]:
    results = []
    for event in events:
        results.append({
            "type": event["type"],  # "click" repeated 1M times = 1M objects
            "status": event["status"],  # "success" repeated = more objects
            "timestamp": event["ts"],
        })
    return results
```

**Correct (interned strings):**

```python
import sys

def process_events(events: list[dict]) -> list[dict]:
    results = []
    for event in events:
        results.append({
            "type": sys.intern(event["type"]),  # Reuses single "click" object
            "status": sys.intern(event["status"]),  # Reuses single "success"
            "timestamp": event["ts"],
        })
    return results
```

**Alternative (pre-intern known values):**

```python
STATUS_SUCCESS = sys.intern("success")
STATUS_FAILURE = sys.intern("failure")
TYPE_CLICK = sys.intern("click")
TYPE_VIEW = sys.intern("view")

def create_event(event_type: str, status: str) -> dict:
    return {"type": event_type, "status": status}
```

**Note:** Python automatically interns string literals and identifiers. Use `sys.intern()` for runtime-generated strings with high repetition.

Reference: [sys.intern documentation](https://docs.python.org/3/library/sys.html#sys.intern)

### 3.2 Use __slots__ for Memory-Efficient Classes

**Impact: HIGH (20-50% memory reduction per instance)**

By default, Python stores instance attributes in a `__dict__` dictionary. `__slots__` replaces this with a fixed-size array, reducing memory and speeding up attribute access.

**Incorrect (dict-based attributes):**

```python
class Point:
    def __init__(self, x: float, y: float, z: float):
        self.x = x
        self.y = y
        self.z = z

# Each instance uses ~296 bytes for __dict__
points = [Point(i, i, i) for i in range(100_000)]
# Total: ~30MB
```

**Correct (slot-based attributes):**

```python
class Point:
    __slots__ = ("x", "y", "z")

    def __init__(self, x: float, y: float, z: float):
        self.x = x
        self.y = y
        self.z = z

# Each instance uses ~64 bytes (fixed slots)
points = [Point(i, i, i) for i in range(100_000)]
# Total: ~6.4MB
```

**Benefits:**
- 20-50% memory reduction per instance
- 10-20% faster attribute access
- Prevents accidental attribute creation

**When NOT to use __slots__:**
- When you need dynamic attribute creation
- When subclasses need their own `__dict__`
- For classes with few instances

Reference: [Python Wiki - Using Slots](https://wiki.python.org/moin/UsingSlots)

### 3.3 Use array.array for Homogeneous Numeric Data

**Impact: HIGH (4-8× memory reduction for numbers)**

Lists store pointers to boxed Python objects (~28 bytes per integer). `array.array` stores raw values compactly (4-8 bytes per number).

**Incorrect (boxed integers in list):**

```python
def load_sensor_readings(filepath: str) -> list[int]:
    readings = []
    with open(filepath) as f:
        for line in f:
            readings.append(int(line.strip()))
    return readings
# 1M integers × 28 bytes = ~28MB
```

**Correct (compact array storage):**

```python
from array import array

def load_sensor_readings(filepath: str) -> array:
    readings = array("i")  # 'i' = signed 32-bit integers
    with open(filepath) as f:
        for line in f:
            readings.append(int(line.strip()))
    return readings
# 1M integers × 4 bytes = ~4MB
```

**Common type codes:**
- `'b'` - signed char (1 byte)
- `'i'` - signed int (4 bytes)
- `'l'` - signed long (4-8 bytes)
- `'f'` - float (4 bytes)
- `'d'` - double (8 bytes)

**When NOT to use array.array:**
- When you need mixed types
- When you need NumPy operations
- For small datasets where overhead doesn't matter

Reference: [array documentation](https://docs.python.org/3/library/array.html)

### 3.4 Use Generators for Large Sequences

**Impact: HIGH (100-1000× memory reduction)**

Lists store all elements in memory simultaneously. Generators produce values on-demand, using constant memory regardless of sequence size.

**Incorrect (loads entire dataset into memory):**

```python
def process_large_file(filepath: str) -> list[dict]:
    with open(filepath) as f:
        lines = f.readlines()  # Loads entire file into memory

    results = []
    for line in lines:
        parsed = parse_line(line)
        if parsed["status"] == "active":
            results.append(transform(parsed))
    return results
# 1GB file = 1GB+ memory usage
```

**Correct (constant memory usage):**

```python
def process_large_file(filepath: str):
    with open(filepath) as f:
        for line in f:  # Yields one line at a time
            parsed = parse_line(line)
            if parsed["status"] == "active":
                yield transform(parsed)
# 1GB file = ~100KB memory usage

# Use the generator
for result in process_large_file("data.csv"):
    save_to_database(result)
```

**Alternative (generator expression):**

```python
def get_active_users(users: list[dict]):
    return (user for user in users if user["status"] == "active")
    # Generator expression uses minimal memory
```

**When NOT to use generators:**
- When you need random access to elements
- When you need to iterate multiple times

Reference: [Python Wiki - Generators](https://wiki.python.org/moin/Generators)

### 3.5 Use weakref for Caches to Prevent Memory Leaks

**Impact: HIGH (prevents unbounded cache growth)**

Strong references in caches prevent garbage collection, causing memory to grow unboundedly. Weak references allow cached objects to be collected when no longer used elsewhere.

**Incorrect (strong reference cache):**

```python
class ImageProcessor:
    _cache: dict[str, Image] = {}

    def get_image(self, path: str) -> Image:
        if path not in self._cache:
            self._cache[path] = load_image(path)  # Strong reference
        return self._cache[path]
        # Images never freed even after UI closes them
```

**Correct (weak reference cache):**

```python
import weakref

class ImageProcessor:
    _cache: weakref.WeakValueDictionary[str, Image]

    def __init__(self):
        self._cache = weakref.WeakValueDictionary()

    def get_image(self, path: str) -> Image:
        image = self._cache.get(path)
        if image is None:
            image = load_image(path)
            self._cache[path] = image  # Weak reference
        return image
        # Images freed when no other references exist
```

**Alternative (LRU cache with size limit):**

```python
from functools import lru_cache

@lru_cache(maxsize=100)  # Bounded cache size
def get_image(path: str) -> Image:
    return load_image(path)
```

**Note:** `WeakValueDictionary` holds weak references to values; `WeakKeyDictionary` holds weak references to keys.

Reference: [weakref documentation](https://docs.python.org/3/library/weakref.html)

---

## 4. Concurrency & Parallelism

**Impact: HIGH**

The GIL limits CPU-bound parallelism. Choosing asyncio vs threading vs multiprocessing correctly determines application throughput.

### 4.1 Use asyncio for I/O-Bound Concurrency

**Impact: HIGH (300% throughput improvement for I/O)**

For I/O-bound workloads (network, disk), asyncio provides the best performance with minimal overhead. Threading adds context-switch costs; multiprocessing adds process overhead.

**Incorrect (blocking synchronous I/O):**

```python
import requests

def fetch_all_apis(urls: list[str]) -> list[dict]:
    results = []
    for url in urls:
        response = requests.get(url)  # Blocks until complete
        results.append(response.json())
    return results
# 100 URLs × 200ms each = 20 seconds sequential
```

**Correct (async concurrent I/O):**

```python
import asyncio
import aiohttp

async def fetch_all_apis(urls: list[str]) -> list[dict]:
    async with aiohttp.ClientSession() as session:
        async def fetch(url: str) -> dict:
            async with session.get(url) as response:
                return await response.json()

        return await asyncio.gather(*[fetch(url) for url in urls])
# 100 URLs × max(200ms) = ~200ms concurrent
```

**When to use each model:**
- **asyncio**: I/O-bound, high concurrency (thousands of connections)
- **threading**: I/O-bound, simpler code, moderate concurrency
- **multiprocessing**: CPU-bound, true parallelism needed

Reference: [Real Python - asyncio](https://realpython.com/async-io-python/)

### 4.2 Use multiprocessing for CPU-Bound Parallelism

**Impact: HIGH (4-8× speedup on multi-core systems)**

The GIL prevents true parallelism in threads for CPU-bound work. Use `multiprocessing` to bypass the GIL and utilize multiple cores.

**Incorrect (GIL-limited threading):**

```python
from concurrent.futures import ThreadPoolExecutor

def compute_hashes(data_chunks: list[bytes]) -> list[str]:
    def hash_chunk(chunk: bytes) -> str:
        return hashlib.sha256(chunk).hexdigest()

    with ThreadPoolExecutor(max_workers=4) as executor:
        return list(executor.map(hash_chunk, data_chunks))
    # GIL prevents parallel execution - effectively single-threaded
```

**Correct (true parallelism):**

```python
from concurrent.futures import ProcessPoolExecutor

def compute_hashes(data_chunks: list[bytes]) -> list[str]:
    def hash_chunk(chunk: bytes) -> str:
        return hashlib.sha256(chunk).hexdigest()

    with ProcessPoolExecutor(max_workers=4) as executor:
        return list(executor.map(hash_chunk, data_chunks))
    # Each process has its own GIL - true parallel execution
```

**Alternative (for large data):**

```python
import multiprocessing as mp

def compute_hashes_large(data_chunks: list[bytes]) -> list[str]:
    with mp.Pool(processes=4) as pool:
        return pool.map(hash_chunk, data_chunks, chunksize=100)
    # chunksize reduces IPC overhead for many small items
```

**When NOT to use multiprocessing:**
- I/O-bound tasks (use asyncio instead)
- Small datasets (process startup overhead dominates)
- When sharing large state between workers

Reference: [multiprocessing documentation](https://docs.python.org/3/library/multiprocessing.html)

### 4.3 Use Queue for Thread-Safe Communication

**Impact: HIGH (prevents race conditions)**

Sharing mutable state between threads causes race conditions. Use `queue.Queue` for thread-safe producer-consumer patterns.

**Incorrect (shared list with race condition):**

```python
import threading

results = []  # Shared mutable state

def worker(items: list[str]) -> None:
    for item in items:
        processed = process_item(item)
        results.append(processed)  # Race condition!

threads = [threading.Thread(target=worker, args=(chunk,)) for chunk in chunks]
for t in threads:
    t.start()
for t in threads:
    t.join()
# results may have corrupted or missing data
```

**Correct (thread-safe queue):**

```python
import threading
from queue import Queue

def worker(input_queue: Queue, output_queue: Queue) -> None:
    while True:
        item = input_queue.get()
        if item is None:  # Poison pill
            break
        output_queue.put(process_item(item))
        input_queue.task_done()

input_queue = Queue()
output_queue = Queue()

threads = [threading.Thread(target=worker, args=(input_queue, output_queue))
           for _ in range(4)]
for t in threads:
    t.start()

for item in items:
    input_queue.put(item)

input_queue.join()  # Wait for all items processed

for _ in threads:
    input_queue.put(None)  # Signal workers to stop
for t in threads:
    t.join()

results = [output_queue.get() for _ in range(len(items))]
```

**Note:** For async code, use `asyncio.Queue` instead.

Reference: [queue documentation](https://docs.python.org/3/library/queue.html)

### 4.4 Use TaskGroup for Structured Concurrency

**Impact: HIGH (prevents resource leaks on failure)**

`asyncio.gather()` doesn't cancel remaining tasks on error by default. `TaskGroup` (Python 3.11+) provides structured concurrency with automatic cancellation.

**Incorrect (tasks continue after failure):**

```python
async def fetch_all_data(user_ids: list[int]) -> list[dict]:
    tasks = [fetch_user(uid) for uid in user_ids]
    results = await asyncio.gather(*tasks)  # If one fails, others continue
    return results
    # Exception from one task doesn't stop others
```

**Correct (automatic cancellation on error):**

```python
async def fetch_all_data(user_ids: list[int]) -> list[dict]:
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(fetch_user(uid)) for uid in user_ids]
    # If any task fails, all others are cancelled
    # ExceptionGroup raised with all errors
    return [task.result() for task in tasks]
```

**Alternative (gather with return_exceptions):**

```python
async def fetch_all_data(user_ids: list[int]) -> list[dict | Exception]:
    tasks = [fetch_user(uid) for uid in user_ids]
    results = await asyncio.gather(*tasks, return_exceptions=True)
    # Exceptions returned as values, not raised
    return [r for r in results if not isinstance(r, Exception)]
```

**Benefits of TaskGroup:**
- Automatic cancellation on first error
- Proper cleanup of all tasks
- Clear lifetime boundaries
- ExceptionGroup for handling multiple errors

Reference: [asyncio.TaskGroup documentation](https://docs.python.org/3/library/asyncio-task.html#asyncio.TaskGroup)

### 4.5 Use ThreadPoolExecutor for Blocking Calls in Async

**Impact: HIGH (prevents event loop blocking)**

Blocking calls in async code freeze the entire event loop. Use `run_in_executor()` to offload blocking operations to a thread pool.

**Incorrect (blocks event loop):**

```python
import asyncio

async def process_image(image_path: str) -> bytes:
    # PIL operations are blocking - freezes all other coroutines
    with Image.open(image_path) as img:
        img = img.resize((800, 600))
        buffer = io.BytesIO()
        img.save(buffer, format="JPEG")
        return buffer.getvalue()
```

**Correct (offloads to thread pool):**

```python
import asyncio
from concurrent.futures import ThreadPoolExecutor

executor = ThreadPoolExecutor(max_workers=4)

def _process_image_sync(image_path: str) -> bytes:
    with Image.open(image_path) as img:
        img = img.resize((800, 600))
        buffer = io.BytesIO()
        img.save(buffer, format="JPEG")
        return buffer.getvalue()

async def process_image(image_path: str) -> bytes:
    loop = asyncio.get_running_loop()
    return await loop.run_in_executor(executor, _process_image_sync, image_path)
```

**Alternative (default executor):**

```python
async def process_image(image_path: str) -> bytes:
    loop = asyncio.get_running_loop()
    return await loop.run_in_executor(None, _process_image_sync, image_path)
    # None uses default ThreadPoolExecutor
```

Reference: [asyncio.loop.run_in_executor](https://docs.python.org/3/library/asyncio-eventloop.html#asyncio.loop.run_in_executor)

---

## 5. Loop & Iteration

**Impact: MEDIUM**

Comprehensions are 2-3× faster than explicit loops. Moving invariant work outside loops avoids N× overhead multiplication.

### 5.1 Hoist Loop-Invariant Computations

**Impact: MEDIUM (avoids N× redundant work)**

Computations that don't change between iterations should be moved outside the loop to avoid repeating the same work N times.

**Incorrect (recomputes constant every iteration):**

```python
def apply_discount(prices: list[float], discount_code: str) -> list[float]:
    result = []
    for price in prices:
        discount = get_discount_rate(discount_code)  # Same result every time
        threshold = calculate_threshold(discount)  # Same result every time
        if price > threshold:
            result.append(price * (1 - discount))
        else:
            result.append(price)
    return result
# 10,000 prices × 2 function calls = 20,000 redundant calls
```

**Correct (compute once before loop):**

```python
def apply_discount(prices: list[float], discount_code: str) -> list[float]:
    discount = get_discount_rate(discount_code)  # Computed once
    threshold = calculate_threshold(discount)  # Computed once
    result = []
    for price in prices:
        if price > threshold:
            result.append(price * (1 - discount))
        else:
            result.append(price)
    return result
# 10,000 prices × 0 redundant calls
```

**Also hoist attribute lookups:**

```python
# Before (attribute lookup each iteration)
for item in items:
    self.processor.transform(item)

# After (single lookup)
transform = self.processor.transform
for item in items:
    transform(item)
```

Reference: [Python Performance Tips](https://wiki.python.org/moin/PythonSpeed/PerformanceTips)

### 5.2 Use any() and all() for Boolean Aggregation

**Impact: MEDIUM (O(n) to O(1) best case)**

Manual loops for checking conditions iterate through all elements. `any()` and `all()` short-circuit on the first conclusive result.

**Incorrect (checks all elements):**

```python
def has_admin_user(users: list[dict]) -> bool:
    found = False
    for user in users:
        if user["role"] == "admin":
            found = True
            # Continues iterating even after finding one!
    return found
```

**Correct (short-circuits immediately):**

```python
def has_admin_user(users: list[dict]) -> bool:
    return any(user["role"] == "admin" for user in users)
    # Stops at first admin found
```

**Common patterns:**

```python
# Check if all items meet condition
all_active = all(user["status"] == "active" for user in users)

# Check if any item fails condition
has_invalid = any(not validate_email(user["email"]) for user in users)

# Combine with filter-like logic
has_large_order = any(order["total"] > 1000 for order in orders if order["status"] == "completed")
```

**Note:** Use generator expressions (parentheses) not list comprehensions (brackets) to get short-circuit behavior.

Reference: [any() documentation](https://docs.python.org/3/library/functions.html#any)

### 5.3 Use dict.items() for Key-Value Iteration

**Impact: MEDIUM (single lookup vs double lookup)**

Iterating over keys then looking up values performs two operations per entry. `dict.items()` provides both in a single iteration.

**Incorrect (double lookup per item):**

```python
def transform_config(config: dict[str, str]) -> dict[str, str]:
    result = {}
    for key in config:  # First: iterate keys
        value = config[key]  # Second: lookup value
        result[key.upper()] = value.strip()
    return result
```

**Correct (single lookup):**

```python
def transform_config(config: dict[str, str]) -> dict[str, str]:
    return {key.upper(): value.strip() for key, value in config.items()}
    # items() yields (key, value) tuples directly
```

**Similarly for values only:**

```python
# When you only need values
total = sum(order["amount"] for order in orders.values())

# When you only need keys
active_keys = [k for k in cache.keys() if not k.startswith("_")]
# Or simply: [k for k in cache if not k.startswith("_")]
```

Reference: [dict.items() documentation](https://docs.python.org/3/library/stdtypes.html#dict.items)

### 5.4 Use enumerate() for Index-Value Iteration

**Impact: MEDIUM (cleaner code, avoids index errors)**

Manual index tracking with `range(len())` is error-prone and requires two lookups. `enumerate()` provides both index and value in one clean pattern.

**Incorrect (manual index tracking):**

```python
def find_duplicates(items: list[str]) -> list[tuple[int, int]]:
    duplicates = []
    for i in range(len(items)):  # Index only
        for j in range(i + 1, len(items)):
            if items[i] == items[j]:  # Separate lookup
                duplicates.append((i, j))
    return duplicates
```

**Correct (enumerate for index + value):**

```python
def find_duplicates(items: list[str]) -> list[tuple[int, int]]:
    duplicates = []
    for i, item_i in enumerate(items):  # Index and value together
        for j, item_j in enumerate(items[i + 1:], start=i + 1):
            if item_i == item_j:  # Direct comparison
                duplicates.append((i, j))
    return duplicates
```

**With custom start index:**

```python
# Line numbers typically start at 1
for line_num, line in enumerate(file_lines, start=1):
    if "ERROR" in line:
        print(f"Error on line {line_num}: {line}")
```

Reference: [enumerate documentation](https://docs.python.org/3/library/functions.html#enumerate)

### 5.5 Use itertools for Efficient Iteration Patterns

**Impact: MEDIUM (2-3× faster iteration patterns)**

The `itertools` module provides C-optimized functions for common iteration patterns, avoiding Python loop overhead.

**Incorrect (manual nested loops):**

```python
def generate_combinations(colors: list[str], sizes: list[str]) -> list[tuple]:
    result = []
    for color in colors:
        for size in sizes:
            result.append((color, size))
    return result
```

**Correct (itertools.product):**

```python
from itertools import product

def generate_combinations(colors: list[str], sizes: list[str]) -> list[tuple]:
    return list(product(colors, sizes))
```

**Common itertools patterns:**

```python
from itertools import chain, groupby, islice, batched

# Flatten nested lists (faster than nested comprehension)
flat = list(chain.from_iterable(nested_lists))

# Group consecutive items
for key, group in groupby(sorted(orders, key=lambda x: x["status"]), key=lambda x: x["status"]):
    print(f"{key}: {list(group)}")

# Slice iterators without loading all into memory
first_1000 = list(islice(huge_generator, 1000))

# Batch items (Python 3.12+)
for batch in batched(items, 100):
    process_batch(batch)
```

Reference: [itertools documentation](https://docs.python.org/3/library/itertools.html)

### 5.6 Use List Comprehensions Over Explicit Loops

**Impact: MEDIUM (2-3× faster iteration)**

List comprehensions are optimized in C and avoid the overhead of repeated `append()` calls. They're 2-3× faster than equivalent for loops.

**Incorrect (explicit loop with append):**

```python
def get_active_user_ids(users: list[dict]) -> list[int]:
    result = []
    for user in users:
        if user["status"] == "active":
            result.append(user["id"])  # Method lookup + call per iteration
    return result
```

**Correct (list comprehension):**

```python
def get_active_user_ids(users: list[dict]) -> list[int]:
    return [user["id"] for user in users if user["status"] == "active"]
    # No append overhead, optimized bytecode
```

**For complex transformations:**

```python
# Multiple operations are still cleaner as comprehension
active_emails = [
    user["email"].lower().strip()
    for user in users
    if user["status"] == "active" and user["email"]
]
```

**When NOT to use comprehensions:**
- Side effects needed (logging, database writes)
- Complex multi-step logic requiring intermediate variables
- Readability suffers with deeply nested conditions

Reference: [Python Wiki - Performance Tips](https://wiki.python.org/moin/PythonSpeed/PerformanceTips)

---

## 6. String Operations

**Impact: MEDIUM**

String concatenation in loops is O(n²) due to immutability. Using join() is 4× faster for combining multiple strings.

### 6.1 Use f-strings for Simple String Formatting

**Impact: MEDIUM (20-30% faster than .format())**

f-strings (formatted string literals) are the fastest option for simple string formatting, outperforming `%` formatting and `.format()`.

**Incorrect (slower formatting methods):**

```python
def format_user_greeting(name: str, age: int) -> str:
    # Old-style % formatting
    return "Hello, %s! You are %d years old." % (name, age)

def format_user_greeting_v2(name: str, age: int) -> str:
    # .format() method
    return "Hello, {}! You are {} years old.".format(name, age)
```

**Correct (f-string):**

```python
def format_user_greeting(name: str, age: int) -> str:
    return f"Hello, {name}! You are {age} years old."
```

**f-string features:**

```python
# Expressions
total = f"Total: ${price * quantity:.2f}"

# Alignment and padding
header = f"{'Name':<20} {'Age':>5} {'Score':^10}"

# Debug format (Python 3.8+)
debug = f"{user_id=}, {status=}"  # Outputs: "user_id=42, status='active'"

# Multiline
message = f"""
Dear {name},
Your order #{order_id} has been shipped.
"""
```

Reference: [PEP 498 - Literal String Interpolation](https://peps.python.org/pep-0498/)

### 6.2 Use join() for Multiple String Concatenation

**Impact: MEDIUM (4× faster for 5+ strings)**

String concatenation with `+` in loops is O(n²) because strings are immutable—each concatenation creates a new string. `join()` pre-allocates the final size for O(n) performance.

**Incorrect (O(n²) concatenation):**

```python
def build_csv_row(values: list[str]) -> str:
    result = ""
    for i, value in enumerate(values):
        if i > 0:
            result += ","  # Creates new string
        result += value  # Creates another new string
    return result
# 100 values = ~5,000 string allocations
```

**Correct (O(n) join):**

```python
def build_csv_row(values: list[str]) -> str:
    return ",".join(values)
    # Single allocation of final size
```

**For conditional inclusion:**

```python
def build_query_params(params: dict[str, str]) -> str:
    return "&".join(f"{key}={value}" for key, value in params.items() if value)
```

**Note:** For 2-3 strings, `+` or f-strings are fine. Use `join()` when concatenating 5+ strings or in loops.

Reference: [Real Python - String Concatenation](https://realpython.com/python-string-concatenation/)

### 6.3 Use str.startswith() with Tuple for Multiple Prefixes

**Impact: MEDIUM (single call vs multiple comparisons)**

Checking multiple prefixes with `or` requires multiple string scans. `startswith()` accepts a tuple of prefixes, checking all in one optimized call.

**Incorrect (multiple comparisons):**

```python
def is_system_file(filename: str) -> bool:
    return (filename.startswith(".") or
            filename.startswith("__") or
            filename.startswith("~"))
```

**Correct (tuple of prefixes):**

```python
def is_system_file(filename: str) -> bool:
    return filename.startswith((".", "__", "~"))
```

**Works with endswith too:**

```python
def is_image_file(filename: str) -> bool:
    return filename.lower().endswith((".png", ".jpg", ".jpeg", ".gif", ".webp"))

def is_config_file(path: str) -> bool:
    return path.endswith((".yaml", ".yml", ".json", ".toml"))
```

**Note:** The argument must be a tuple, not a list. Lists are not supported.

Reference: [str.startswith documentation](https://docs.python.org/3/library/stdtypes.html#str.startswith)

### 6.4 Use str.translate() for Character-Level Replacements

**Impact: MEDIUM (10× faster than chained replace())**

Multiple `replace()` calls each create a new string and scan the entire input. `str.translate()` performs all replacements in a single pass.

**Incorrect (multiple passes):**

```python
def sanitize_filename(name: str) -> str:
    result = name.replace("/", "_")  # Pass 1
    result = result.replace("\\", "_")  # Pass 2
    result = result.replace(":", "_")  # Pass 3
    result = result.replace("*", "_")  # Pass 4
    result = result.replace("?", "_")  # Pass 5
    result = result.replace('"', "_")  # Pass 6
    result = result.replace("<", "_")  # Pass 7
    result = result.replace(">", "_")  # Pass 8
    result = result.replace("|", "_")  # Pass 9
    return result
# 9 passes over the string
```

**Correct (single pass):**

```python
SANITIZE_TABLE = str.maketrans({
    "/": "_", "\\": "_", ":": "_", "*": "_",
    "?": "_", '"': "_", "<": "_", ">": "_", "|": "_"
})

def sanitize_filename(name: str) -> str:
    return name.translate(SANITIZE_TABLE)  # Single pass
```

**For removing characters:**

```python
# Remove all digits
REMOVE_DIGITS = str.maketrans("", "", "0123456789")
clean = text.translate(REMOVE_DIGITS)

# Remove punctuation
import string
REMOVE_PUNCT = str.maketrans("", "", string.punctuation)
clean = text.translate(REMOVE_PUNCT)
```

Reference: [str.translate documentation](https://docs.python.org/3/library/stdtypes.html#str.translate)

---

## 7. Function & Call Overhead

**Impact: LOW-MEDIUM**

Function calls cost 50-100ns each in CPython. In tight loops processing millions of items, reducing calls improves throughput.

### 7.1 Reduce Function Calls in Tight Loops

**Impact: LOW-MEDIUM (100ms savings per 1M iterations)**

Each Python function call costs 50-100ns. In loops processing millions of items, this overhead accumulates significantly.

**Incorrect (function call per iteration):**

```python
def process_values(values: list[float]) -> list[float]:
    def transform(x: float) -> float:
        return x * 2.5 + 10

    return [transform(v) for v in values]
# 1M values × 100ns = 100ms in call overhead alone
```

**Correct (inline simple operations):**

```python
def process_values(values: list[float]) -> list[float]:
    return [v * 2.5 + 10 for v in values]
# No function call overhead
```

**For method calls, cache the lookup:**

```python
# Before (3 lookups per iteration)
for item in items:
    result.append(processor.transform(item))

# After (1 lookup total)
append = result.append
transform = processor.transform
for item in items:
    append(transform(item))
```

**When NOT to inline:**
- When it hurts readability significantly
- When the function is complex
- When profiling shows the call overhead is negligible

Reference: [Python Wiki - Performance Tips](https://wiki.python.org/moin/PythonSpeed/PerformanceTips)

### 7.2 Use functools.partial for Pre-Filled Arguments

**Impact: LOW-MEDIUM (50% faster debugging via introspection)**

When you need a function with some arguments pre-filled, `partial` is cleaner than lambdas and provides better debugging information.

**Incorrect (lambda wrapper):**

```python
def process_items(items: list[str], processor) -> list[str]:
    return [processor(item) for item in items]

# Lambda obscures the actual function
results = process_items(
    items,
    lambda x: format_string(x, uppercase=True, strip=True)
)
```

**Correct (partial application):**

```python
from functools import partial

def process_items(items: list[str], processor) -> list[str]:
    return [processor(item) for item in items]

# Partial shows the actual function
format_upper = partial(format_string, uppercase=True, strip=True)
results = process_items(items, format_upper)

# Better for debugging: partial has __name__ and __func__
print(format_upper.func.__name__)  # 'format_string'
print(format_upper.keywords)  # {'uppercase': True, 'strip': True}
```

**Common use cases:**

```python
from functools import partial

# Pre-configure logging
debug_log = partial(log_message, level="DEBUG")
error_log = partial(log_message, level="ERROR")

# Pre-configure API client
prod_client = partial(api_request, base_url="https://api.example.com")
test_client = partial(api_request, base_url="https://test.example.com")
```

Reference: [functools.partial documentation](https://docs.python.org/3/library/functools.html#functools.partial)

### 7.3 Use Keyword-Only Arguments for API Clarity

**Impact: LOW-MEDIUM (prevents positional argument errors)**

Functions with multiple boolean or similar-typed arguments are error-prone when called positionally. Keyword-only arguments (after `*`) enforce explicit naming.

**Incorrect (ambiguous positional args):**

```python
def create_user(name: str, admin: bool, active: bool, verified: bool) -> User:
    return User(name=name, admin=admin, active=active, verified=verified)

# Easy to get wrong:
user = create_user("alice", True, False, True)  # Which bool is which?
user = create_user("bob", False, True, False)  # Confusing
```

**Correct (keyword-only after *):**

```python
def create_user(
    name: str,
    *,
    admin: bool = False,
    active: bool = True,
    verified: bool = False,
) -> User:
    return User(name=name, admin=admin, active=active, verified=verified)

# Forces clarity:
user = create_user("alice", admin=True, verified=True)
user = create_user("bob", active=True)
# create_user("charlie", True, False, True)  # TypeError!
```

**Positional-only (Python 3.8+):**

```python
def calculate_distance(x1: float, y1: float, x2: float, y2: float, /) -> float:
    # / means all args before it are positional-only
    return ((x2 - x1) ** 2 + (y2 - y1) ** 2) ** 0.5
```

Reference: [PEP 3102 - Keyword-Only Arguments](https://peps.python.org/pep-3102/)

### 7.4 Use lru_cache for Expensive Function Memoization

**Impact: LOW-MEDIUM (avoids repeated computation)**

Functions called with the same arguments repeatedly waste computation. `@lru_cache` stores results automatically, returning cached values on subsequent calls.

**Incorrect (recomputes every call):**

```python
def calculate_fibonacci(n: int) -> int:
    if n < 2:
        return n
    return calculate_fibonacci(n - 1) + calculate_fibonacci(n - 2)
# fib(35) = 9,227,465 recursive calls

def get_user_permissions(user_id: int) -> set[str]:
    user = fetch_user_from_db(user_id)  # DB call every time
    return compute_effective_permissions(user)
```

**Correct (cached results):**

```python
from functools import lru_cache

@lru_cache(maxsize=128)
def calculate_fibonacci(n: int) -> int:
    if n < 2:
        return n
    return calculate_fibonacci(n - 1) + calculate_fibonacci(n - 2)
# fib(35) = 35 unique calls, rest cached

@lru_cache(maxsize=1000)
def get_user_permissions(user_id: int) -> frozenset[str]:
    user = fetch_user_from_db(user_id)  # Cached after first call
    return frozenset(compute_effective_permissions(user))
```

**For unhashable arguments:**

```python
from functools import cache  # Python 3.9+, unbounded cache

@cache
def expensive_computation(x: int, y: int) -> int:
    return x ** y
```

**Note:** Arguments must be hashable. Use `frozenset` instead of `set`, tuple instead of list.

Reference: [functools.lru_cache documentation](https://docs.python.org/3/library/functools.html#functools.lru_cache)

---

## 8. Python Idioms & Micro

**Impact: LOW**

Pythonic patterns leverage C-optimized internals. Local variables, built-in functions, and modern syntax yield incremental but measurable gains.

### 8.1 Leverage Zero-Cost Exception Handling

**Impact: LOW (zero overhead in happy path (Python 3.11+))**

Python 3.11+ implements zero-cost exception handling where try/except blocks have no overhead when no exception is raised. This makes EAFP (Easier to Ask Forgiveness than Permission) efficient.

**Incorrect (LBYL style, always checks):**

```python
def get_user_value(data: dict, key: str) -> str | None:
    if key in data:  # Always performs check
        value = data[key]
        if isinstance(value, str):  # Another check
            return value.strip()
    return None
```

**Correct (EAFP style, zero cost when key exists):**

```python
def get_user_value(data: dict, key: str) -> str | None:
    try:
        return data[key].strip()  # Zero overhead if key exists
    except (KeyError, AttributeError):
        return None
```

**When EAFP is better:**
- Key/attribute usually exists (happy path is common)
- Multiple conditions would need checking
- Race conditions between check and use

**When LBYL is better:**
- Operation has side effects (file creation)
- Check is cheap, exception is expensive to create
- Failure is common (50%+ of cases)

```python
# LBYL better here - side effect
if not path.exists():
    path.mkdir()

# EAFP better here - usually exists
try:
    config = load_config()
except FileNotFoundError:
    config = default_config()
```

Reference: [CPython Exception Handling](https://github.com/python/cpython/blob/main/InternalDocs/exception_handling.md)

### 8.2 Prefer Local Variables Over Global Lookups

**Impact: LOW (faster name resolution)**

Python resolves names using LEGB (Local, Enclosing, Global, Built-in). Local variables are stored in a fixed-size array with O(1) index access, while globals require dictionary lookups.

**Incorrect (global lookup each iteration):**

```python
MULTIPLIER = 2.5
OFFSET = 10

def transform_values(values: list[float]) -> list[float]:
    result = []
    for v in values:
        result.append(v * MULTIPLIER + OFFSET)  # Global lookup × 2 per iteration
    return result
```

**Correct (local variable cache):**

```python
MULTIPLIER = 2.5
OFFSET = 10

def transform_values(values: list[float]) -> list[float]:
    multiplier = MULTIPLIER  # Cache as local
    offset = OFFSET
    result = []
    for v in values:
        result.append(v * multiplier + offset)  # Local lookup (faster)
    return result
```

**For built-in functions:**

```python
# Before (built-in lookup each call)
for item in items:
    result.append(len(item))

# After (local cache)
_len = len
for item in items:
    result.append(_len(item))
```

**Note:** This optimization matters in tight loops with millions of iterations. For typical code, readability is more important.

Reference: [Real Python - LEGB Rule](https://realpython.com/python-scope-legb-rule/)

### 8.3 Use dataclass for Data-Holding Classes

**Impact: LOW (reduces boilerplate by 80%)**

Classes that primarily hold data require boilerplate `__init__`, `__repr__`, `__eq__`, etc. `@dataclass` generates these automatically with optimizations.

**Incorrect (manual boilerplate):**

```python
class User:
    def __init__(self, name: str, email: str, age: int, active: bool = True):
        self.name = name
        self.email = email
        self.age = age
        self.active = active

    def __repr__(self) -> str:
        return f"User(name={self.name!r}, email={self.email!r}, age={self.age}, active={self.active})"

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, User):
            return NotImplemented
        return (self.name, self.email, self.age, self.active) == (other.name, other.email, other.age, other.active)
```

**Correct (dataclass):**

```python
from dataclasses import dataclass

@dataclass
class User:
    name: str
    email: str
    age: int
    active: bool = True
    # __init__, __repr__, __eq__ auto-generated
```

**With slots for memory efficiency:**

```python
@dataclass(slots=True)  # Python 3.10+
class Point:
    x: float
    y: float
    z: float
```

**Frozen for immutability:**

```python
@dataclass(frozen=True)  # Hashable, immutable
class Coordinate:
    lat: float
    lng: float
```

Reference: [dataclasses documentation](https://docs.python.org/3/library/dataclasses.html)

### 8.4 Use Lazy Imports for Faster Startup

**Impact: LOW (10-15% faster startup)**

Top-level imports execute at module load time, slowing startup. Import heavy modules inside functions when they're only needed occasionally.

**Incorrect (always imports heavy module):**

```python
import pandas as pd  # Imports at module load, even if never used
import numpy as np
from sklearn.ensemble import RandomForestClassifier

def simple_stats(values: list[float]) -> dict:
    return {"mean": sum(values) / len(values)}

def advanced_ml_analysis(data: list[dict]) -> dict:
    # Only called rarely, but pandas/sklearn always loaded
    df = pd.DataFrame(data)
    model = RandomForestClassifier()
    return {"prediction": model.fit_predict(df)}
```

**Correct (lazy import when needed):**

```python
def simple_stats(values: list[float]) -> dict:
    return {"mean": sum(values) / len(values)}

def advanced_ml_analysis(data: list[dict]) -> dict:
    import pandas as pd  # Only imports when function called
    from sklearn.ensemble import RandomForestClassifier

    df = pd.DataFrame(data)
    model = RandomForestClassifier()
    return {"prediction": model.fit_predict(df)}
```

**For frequently called functions:**

```python
_pandas = None

def get_dataframe(data: list[dict]):
    global _pandas
    if _pandas is None:
        import pandas
        _pandas = pandas
    return _pandas.DataFrame(data)
```

**Note:** Python caches imports, so subsequent calls don't re-import.

Reference: [Python 3.11 - Faster Startup](https://docs.python.org/3/whatsnew/3.11.html#faster-cpython)

### 8.5 Use match Statement for Structural Pattern Matching

**Impact: LOW (reduces branch complexity)**

Python 3.10+ `match` statement provides structural pattern matching that's clearer and often faster than chained if/elif for complex conditions.

**Incorrect (verbose if/elif chain):**

```python
def process_event(event: dict) -> str:
    event_type = event.get("type")
    if event_type == "click":
        if "target" in event and "position" in event:
            return f"Click on {event['target']} at {event['position']}"
        return "Invalid click event"
    elif event_type == "keypress":
        if "key" in event:
            return f"Key pressed: {event['key']}"
        return "Invalid keypress event"
    elif event_type == "scroll":
        return f"Scroll by {event.get('delta', 0)}"
    else:
        return "Unknown event"
```

**Correct (structural pattern matching):**

```python
def process_event(event: dict) -> str:
    match event:
        case {"type": "click", "target": target, "position": pos}:
            return f"Click on {target} at {pos}"
        case {"type": "click"}:
            return "Invalid click event"
        case {"type": "keypress", "key": key}:
            return f"Key pressed: {key}"
        case {"type": "keypress"}:
            return "Invalid keypress event"
        case {"type": "scroll", "delta": delta}:
            return f"Scroll by {delta}"
        case {"type": "scroll"}:
            return "Scroll by 0"
        case _:
            return "Unknown event"
```

**With guards:**

```python
match user:
    case {"role": "admin", "active": True}:
        grant_admin_access()
    case {"role": role} if role in ("editor", "moderator"):
        grant_limited_access()
    case _:
        grant_read_only()
```

Reference: [PEP 634 - Structural Pattern Matching](https://peps.python.org/pep-0634/)

### 8.6 Use Walrus Operator for Assignment in Expressions

**Impact: LOW (eliminates redundant computations)**

The walrus operator (`:=`) assigns a value while also returning it, avoiding duplicate computations or function calls.

**Incorrect (duplicate computation):**

```python
def process_data(items: list[str]) -> list[str]:
    results = []
    for item in items:
        if len(item.strip()) > 10:  # Computes strip() once
            results.append(item.strip())  # Computes strip() again
    return results
```

**Correct (single computation with walrus):**

```python
def process_data(items: list[str]) -> list[str]:
    results = []
    for item in items:
        if len(stripped := item.strip()) > 10:  # Assign and test
            results.append(stripped)  # Reuse assigned value
    return results
```

**Common patterns:**

```python
# Regex match and use
if match := pattern.search(text):
    print(f"Found: {match.group()}")

# Read until empty
while chunk := file.read(8192):
    process(chunk)

# Filter with computed value
valid_users = [user for user in users if (age := calculate_age(user)) >= 18]
```

**Note:** Introduced in Python 3.8 (PEP 572).

Reference: [PEP 572 - Assignment Expressions](https://peps.python.org/pep-0572/)

---

## References

1. [https://docs.python.org/3/whatsnew/3.11.html](https://docs.python.org/3/whatsnew/3.11.html)
2. [https://peps.python.org/pep-0008/](https://peps.python.org/pep-0008/)
3. [https://wiki.python.org/moin/PythonSpeed/PerformanceTips](https://wiki.python.org/moin/PythonSpeed/PerformanceTips)
4. [https://realpython.com/async-io-python/](https://realpython.com/async-io-python/)
5. [https://realpython.com/python-scope-legb-rule/](https://realpython.com/python-scope-legb-rule/)
6. [https://realpython.com/python-string-concatenation/](https://realpython.com/python-string-concatenation/)
7. [https://docs.python.org/3/tutorial/datastructures.html](https://docs.python.org/3/tutorial/datastructures.html)
8. [https://github.com/python/cpython/blob/main/InternalDocs/exception_handling.md](https://github.com/python/cpython/blob/main/InternalDocs/exception_handling.md)
9. [https://www.datacamp.com/tutorial/python-generators](https://www.datacamp.com/tutorial/python-generators)
10. [https://blog.jetbrains.com/pycharm/2025/11/10-smart-performance-hacks-for-faster-python-code/](https://blog.jetbrains.com/pycharm/2025/11/10-smart-performance-hacks-for-faster-python-code/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |