---
title: Use Binary Search to Localize Bugs
impact: CRITICAL
impactDescription: Reduces search space by 50% per iteration; finds bug in O(log n) steps
tags: hypo, binary-search, localization, divide-conquer, bisect
---

## Use Binary Search to Localize Bugs

When you know a bug exists somewhere in a code path, use binary search to find it. Insert a checkpoint halfway through, determine which half contains the bug, and repeat. This finds bugs in O(log n) steps instead of O(n).

**Incorrect (linear search):**

```javascript
// Bug: Data is corrupted somewhere in this pipeline
function transformOrder(input) {
  const step1 = validate(input);      // Check here... OK
  const step2 = normalize(step1);     // Check here... OK
  const step3 = transform(step2);     // Check here... OK
  const step4 = enrich(step3);        // Check here... still looking...
  const step5 = format(step4);        // Check here...
  const step6 = compress(step5);      // Check here...
  const step7 = encrypt(step6);       // Check here...
  const step8 = serialize(step7);     // Found it!
  return step8;
}
// 8 checkpoints examined linearly = 8 iterations
```

**Correct (binary search):**

```javascript
// Bug: Data is corrupted somewhere in this 8-step pipeline
function transformOrder(input) {
  const step1 = validate(input);
  const step2 = normalize(step1);
  const step3 = transform(step2);
  const step4 = enrich(step3);

  console.log('Checkpoint (step 4):', isDataValid(step4));  // Iteration 1
  // Result: VALID - bug is in steps 5-8

  const step5 = format(step4);
  const step6 = compress(step5);

  console.log('Checkpoint (step 6):', isDataValid(step6));  // Iteration 2
  // Result: VALID - bug is in steps 7-8

  const step7 = encrypt(step6);

  console.log('Checkpoint (step 7):', isDataValid(step7));  // Iteration 3
  // Result: INVALID - bug is in step 7 (encrypt)

  const step8 = serialize(step7);
  return step8;
}
// 3 checkpoints examined with binary search = log2(8) = 3 iterations
```

**Binary search debugging process:**
1. Identify the range: first known-good point to first known-bad point
2. Test the midpoint
3. If midpoint is good, bug is in second half
4. If midpoint is bad, bug is in first half
5. Repeat until you've isolated the bug location

**For git history, use git bisect:**
```bash
git bisect start
git bisect bad HEAD          # Current is broken
git bisect good v1.0.0       # This version worked
# Git picks middle commit, test it, mark good/bad
# Finds culprit commit in log2(n) tests
```

**When NOT to use this pattern:**
- Non-deterministic bugs that don't reproduce reliably
- Bugs that depend on specific data only present at certain points

Reference: [Code with Jason - Binary Search Debugging](https://www.codewithjason.com/binary-search-debugging/)
