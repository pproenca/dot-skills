---
title: Spot Off-by-One Errors
impact: MEDIUM
impactDescription: prevents 10-15% of logic errors
tags: pattern, off-by-one, loops, boundaries
---

## Spot Off-by-One Errors

Off-by-one errors occur at boundaries: loop iterations, array indices, string slicing. Check whether conditions should use `<` vs `<=`, whether indices start at 0 or 1, and whether ranges are inclusive or exclusive.

**Incorrect (off-by-one in loop):**

```python
def process_items(items):
    # Bug: Skips last item
    for i in range(len(items) - 1):  # Should be range(len(items))
        process(items[i])

def get_substring(text, start, length):
    # Bug: Returns one character too many
    return text[start:start + length + 1]  # Should be start + length

def validate_page_number(page, total_pages):
    # Bug: Rejects valid last page
    if page > total_pages - 1:  # Should be page > total_pages or page >= total_pages
        raise InvalidPageError()
```

**Correct (boundary-aware code):**

```python
def process_items(items):
    # Correct: Process all items
    for i in range(len(items)):
        process(items[i])
    # Or simply: for item in items: process(item)

def get_substring(text, start, length):
    # Correct: Python slicing is exclusive on end
    return text[start:start + length]

def validate_page_number(page, total_pages):
    # Correct: Pages 1 through total_pages are valid
    if page < 1 or page > total_pages:
        raise InvalidPageError()
```

**Off-by-one checklist:**
- [ ] Does the loop include or exclude the last element?
- [ ] Are indices 0-based or 1-based?
- [ ] Is the range/slice inclusive or exclusive on the end?
- [ ] Does `<=` vs `<` matter for the edge case?

Reference: [FSU - Debugging Techniques](https://www.cs.fsu.edu/~baker/opsys/notes/debugging.html)
