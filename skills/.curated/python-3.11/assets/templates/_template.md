---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× improvement", "O(n) to O(1)")
tags: prefix, technique, tool, related-concepts
---

## Rule Title Here

Brief explanation (1-3 sentences) of WHY this matters. Focus on performance implications and cascade effects.

**Incorrect (describe the problem/cost):**

```python
def example_function(data: list[str]) -> list[str]:
    # Comment explaining the cost on key line only
    result = []
    for item in data:
        result.append(process(item))  # This line has the problem
    return result
```

**Correct (describe the benefit/solution):**

```python
def example_function(data: list[str]) -> list[str]:
    return [process(item) for item in data]
    # Minimal diff from incorrect - same variable names
```

**Alternative (when applicable):**

```python
# Alternative approach for specific contexts
```

**When NOT to use this pattern:**
- Exception 1
- Exception 2

**Benefits:**
- Benefit 1
- Benefit 2

Reference: [Reference Title](URL)
