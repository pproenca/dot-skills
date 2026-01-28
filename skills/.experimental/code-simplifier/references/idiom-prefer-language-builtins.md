---
title: Prefer Language and Standard Library Builtins
impact: LOW-MEDIUM
impactDescription: Reduces code by 20-40%, eliminates bugs from manual reimplementations
tags: idiom, all-languages, stdlib, builtins
---

## Prefer Language and Standard Library Builtins

Every language provides optimized, well-tested utilities for common operations. Manual implementations are almost always buggier, slower, and harder to maintain. Before writing utility code, check if the language or standard library already provides it.

**Incorrect (manual implementations):**

```typescript
// TypeScript: Manual array operations
function unique<T>(arr: T[]): T[] {
  const seen = new Set<T>();
  const result: T[] = [];
  for (const item of arr) {
    if (!seen.has(item)) {
      seen.add(item);
      result.push(item);
    }
  }
  return result;
}

function groupBy<T>(arr: T[], key: keyof T): Record<string, T[]> {
  const result: Record<string, T[]> = {};
  for (const item of arr) {
    const k = String(item[key]);
    if (!result[k]) result[k] = [];
    result[k].push(item);
  }
  return result;
}
```

**Correct (use builtins):**

```typescript
// TypeScript: Use Set and Object.groupBy (ES2024)
const uniqueItems = [...new Set(arr)];
const grouped = Object.groupBy(arr, item => item.category);
```

**Incorrect (Python manual operations):**

```python
# Python: Manual implementations
def flatten(nested_list):
    result = []
    for sublist in nested_list:
        for item in sublist:
            result.append(item)
    return result

def find_max_by_key(items, key_func):
    max_item = None
    max_val = float('-inf')
    for item in items:
        val = key_func(item)
        if val > max_val:
            max_val = val
            max_item = item
    return max_item
```

**Correct (Python stdlib):**

```python
# Python: Use itertools and builtins
from itertools import chain

flattened = list(chain.from_iterable(nested_list))
max_item = max(items, key=key_func)

# Other commonly overlooked builtins
from collections import Counter, defaultdict
from functools import lru_cache, reduce
from pathlib import Path  # Instead of os.path string manipulation
```

**Incorrect (Go manual operations):**

```go
// Go: Manual slice operations
func contains(slice []string, item string) bool {
    for _, s := range slice {
        if s == item {
            return true
        }
    }
    return false
}

func min(a, b int) int {
    if a < b {
        return a
    }
    return b
}
```

**Correct (Go stdlib and generics):**

```go
// Go 1.21+: Use slices and cmp packages
import (
    "slices"
    "cmp"
)

found := slices.Contains(slice, item)
minimum := min(a, b)  // builtin since Go 1.21
sorted := slices.SortedFunc(items, func(a, b Item) int {
    return cmp.Compare(a.Priority, b.Priority)
})
```

**Incorrect (Rust manual operations):**

```rust
// Rust: Manual implementations
fn join_strings(strings: &[String], sep: &str) -> String {
    let mut result = String::new();
    for (i, s) in strings.iter().enumerate() {
        if i > 0 {
            result.push_str(sep);
        }
        result.push_str(s);
    }
    result
}
```

**Correct (Rust stdlib):**

```rust
// Rust: Use standard library
let joined = strings.join(", ");

// Other commonly overlooked std features
use std::collections::HashMap;
let counts: HashMap<_, _> = items.iter().fold(HashMap::new(), |mut acc, x| {
    *acc.entry(x).or_insert(0) += 1;
    acc
});
// Or use itertools crate for more complex operations
```

### Common Builtins to Know

| Operation | TypeScript | Python | Go | Rust |
|-----------|------------|--------|-----|------|
| Unique | `new Set()` | `set()` | `slices.Compact` | `.dedup()` |
| Sort | `.sort()` | `sorted()` | `slices.Sort` | `.sort()` |
| Find | `.find()` | `next(x for...)` | `slices.Index` | `.find()` |
| Group | `Object.groupBy` | `itertools.groupby` | manual/lo | `.group_by()` |
| Flatten | `.flat()` | `chain.from_iterable` | manual | `.flatten()` |

### Benefits

- Battle-tested implementations with edge cases handled
- Often optimized at the language/runtime level
- Familiar to other developers reading your code
- Reduces maintenance burden and potential bugs
