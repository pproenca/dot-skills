# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Ownership and Borrowing (own)

**Impact:** CRITICAL
**Description:** Incorrect ownership patterns cause unnecessary cloning, lifetime errors, and memory waste. Proper borrowing eliminates an entire class of performance and correctness bugs at compile time.

## 2. Error Propagation (errprop)

**Impact:** CRITICAL
**Description:** Clear error chains with .context() annotations transform opaque failures into actionable diagnostics. The difference between a 5-minute fix and a 2-hour debug session is error context quality.

## 3. Type Safety (safe)

**Impact:** HIGH
**Description:** Leveraging the type system (newtypes, enums, builders, From/Into) catches bugs at compile time that would otherwise surface as runtime failures in production.

## 4. Collections and Iterators (iter)

**Impact:** HIGH
**Description:** Choosing the right collection (BTreeMap for determinism, Vec for performance) and using iterator combinators over manual loops produces more correct, readable, and optimizable code.

## 5. Async Patterns (asyncp)

**Impact:** MEDIUM-HIGH
**Description:** Correct async patterns (select!, Pin, Send bounds, cancellation safety) prevent deadlocks, stack overflows, and resource leaks in concurrent Rust applications.

## 6. API Design (api)

**Impact:** MEDIUM
**Description:** Well-designed Rust APIs (impl Into, impl Iterator, Display, Default) reduce caller friction and make the right thing easy and the wrong thing hard.

## 7. Serialization (serial)

**Impact:** MEDIUM
**Description:** Consistent serde patterns (rename_all, deny_unknown_fields, flatten) prevent serialization bugs and ensure backward compatibility.

## 8. Performance (perf)

**Impact:** LOW-MEDIUM
**Description:** Targeted performance patterns (pre-allocation, Cow, Arc str, LazyLock) reduce allocations and improve throughput in hot paths.
