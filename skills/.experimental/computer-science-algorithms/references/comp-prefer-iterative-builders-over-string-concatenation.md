---
title: Build Strings With Join Or Buffers, Not Repeated Concatenation
impact: CRITICAL
impactDescription: O(n²) to O(n) when concatenating in a loop
tags: comp, string, concatenation, join
---

## Build Strings With Join Or Buffers, Not Repeated Concatenation

Strings are immutable in most languages (Python, Java, JavaScript, C#). `s = s + chunk` allocates a brand-new string and copies both operands every time. Done in a loop, this is O(n²) in the total output length — the kth iteration copies a string of size proportional to k, summing to ~n²/2 character copies. CPython sometimes optimizes this for plain string locals, but the optimization is fragile (breaks across references, across CPython versions, on PyPy/Jython). Don't rely on it.

Use a list-and-`join`, an explicit buffer, or a generator — they're O(n) total.

**Incorrect (quadratic concatenation):**

```python
def render_csv(rows: list[list[str]]) -> str:
    # Each `+=` copies the entire accumulated string. For 10⁵ rows this
    # is ~10¹⁰ character copies — minutes instead of milliseconds.
    out = ""
    for row in rows:
        out += ",".join(row) + "\n"
    return out
```

**Correct (collect then join — linear):**

```python
def render_csv(rows: list[list[str]]) -> str:
    # Each row builds a small string in O(|row|); the outer join walks the
    # list once. Total: O(total characters).
    return "\n".join(",".join(row) for row in rows) + "\n"
```

**Language equivalents:**

- Java: `StringBuilder` (not `String +`)
- C#: `StringBuilder` (not `string +`)
- JavaScript: `arr.push(...); arr.join("")` (V8 is somewhat forgiving, but consistency wins)
- Go: `strings.Builder` (`+` allocates each time)

Reference: [Joel on Software — Back to Basics (the Shlemiel the painter problem)](https://www.joelonsoftware.com/2001/12/11/back-to-basics/)
