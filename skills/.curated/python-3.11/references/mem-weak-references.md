---
title: Use weakref for Caches to Prevent Memory Leaks
impact: HIGH
impactDescription: prevents unbounded cache growth
tags: mem, weakref, cache, garbage-collection
---

## Use weakref for Caches to Prevent Memory Leaks

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
