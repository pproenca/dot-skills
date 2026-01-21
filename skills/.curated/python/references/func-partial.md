---
title: Use functools.partial for Pre-Filled Arguments
impact: LOW-MEDIUM
impactDescription: 50% faster debugging via introspection
tags: func, partial, functools, currying
---

## Use functools.partial for Pre-Filled Arguments

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
