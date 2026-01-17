---
title: Use str.translate() for Character-Level Replacements
impact: MEDIUM
impactDescription: 10× faster than chained replace()
tags: str, translate, character-replacement, performance
---

## Use str.translate() for Character-Level Replacements

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
