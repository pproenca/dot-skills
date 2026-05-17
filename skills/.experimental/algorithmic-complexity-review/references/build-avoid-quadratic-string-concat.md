---
title: Build Strings With Joins or Builders, Not Repeated Concatenation
impact: HIGH
impactDescription: O(n²) to O(n) — orders of magnitude on large strings
tags: build, string, concatenation, quadratic, join
---

## Build Strings With Joins or Builders, Not Repeated Concatenation

Strings are immutable in most languages: `s = s + part` allocates a fresh string and copies both `s` and `part` into it. Inside a loop, each iteration copies the entire prefix accumulated so far — the work is 1 + 2 + 3 + … + n bytes, which is O(n²). Building a 1MB string this way moves a terabyte of memory. The fix is `''.join(parts)` (Python), `parts.join('')` (JS), `StringBuilder` (Java), or `strings.Builder` (Go) — each appends to a growing buffer in amortized O(1), final concat is O(n).

CPython does have an optimization that **sometimes** in-places `s = s + part` for refcount-1 strings, but the optimization is contingent on internal refcount details and breaks under many normal conditions (aliasing, attribute access, augmented assignment in a class). Do not rely on it.

**Incorrect (quadratic concatenation):**

```python
s = ""
for part in parts:                  # 10,000 parts × ~100 chars
    s = s + part
# Work: 100 + 200 + 300 + ... + 1,000,000 = 5 * 10^9 bytes copied
# ~5 seconds wall-clock for a 1MB result
```

**Correct (`join` — linear total work):**

```python
s = "".join(parts)
# Single pass, ~1 million bytes copied total. Milliseconds.
```

**Alternative (Java / Go — explicit builder):**

```java
StringBuilder sb = new StringBuilder();
for (String part : parts) sb.append(part);
String s = sb.toString();
```

```go
var b strings.Builder
for _, part := range parts {
    b.WriteString(part)
}
s := b.String()
```

**When NOT to use this pattern:**
- When you genuinely only concatenate two or three strings — single `+` is clearer and the runtime is fine.
- When you're streaming output (writing to a file or network) — write each chunk directly, don't accumulate into a string at all.

Reference: [Python performance tips — string concatenation](https://wiki.python.org/moin/PythonSpeed/PerformanceTips#String_Concatenation)
