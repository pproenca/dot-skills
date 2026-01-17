---
title: Reduce Function Calls in Tight Loops
impact: LOW-MEDIUM
impactDescription: 100ms savings per 1M iterations
tags: func, call-overhead, tight-loops, optimization
---

## Reduce Function Calls in Tight Loops

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
