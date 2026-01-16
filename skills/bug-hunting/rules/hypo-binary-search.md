---
title: Use Binary Search to Localize Bugs
impact: CRITICAL
impactDescription: O(log n) instead of O(n) search through code
tags: hypo, binary-search, divide-and-conquer, git-bisect
---

## Use Binary Search to Localize Bugs

When a bug could be anywhere in a large codebase or commit history, use binary search to narrow down the location. Check the midpoint, determine which half contains the bug, and repeat until you find it.

**Incorrect (linear search through history):**

```bash
# Bug introduced sometime in the last 100 commits
# Approach: Check each commit one by one

git checkout HEAD~1 && npm test   # Pass
git checkout HEAD~2 && npm test   # Pass
git checkout HEAD~3 && npm test   # Pass
# ... 97 more checkouts (O(n) = 100 checks worst case)
```

**Correct (binary search with git bisect):**

```bash
# Bug introduced sometime in the last 100 commits
# Approach: Binary search through history

git bisect start
git bisect bad HEAD              # Current commit is broken
git bisect good HEAD~100         # 100 commits ago was working

# Git checks out the middle commit
# Run: npm test
git bisect good                  # Test passes, bug is in later half

# Git checks out middle of remaining range
# Run: npm test
git bisect bad                   # Test fails, bug is in earlier half

# After ~7 iterations (log2(100) ≈ 7), exact commit found
git bisect reset
```

**Binary search in code:**

```python
def find_bug_location(process_data):
    # 1000-line function, bug somewhere inside
    data = load_data()

    # Check midpoint: Is data correct here?
    midpoint_result = transform_step_500(data)
    assert is_valid(midpoint_result)  # If fails, bug is in first half

    # Repeat: Check midpoint of remaining half
    # 10 iterations to find exact line (log2(1000) ≈ 10)
```

Reference: [GeeksforGeeks - Debugging Approaches](https://www.geeksforgeeks.org/software-engineering-debugging-approaches/)
