---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact description (e.g., "2-10× improvement", "reduces by 50%")
tags: prefix, keyword1, keyword2, keyword3
---

## Rule Title Here

Brief explanation of WHY this matters (1-3 sentences). Focus on the performance implications and user impact.

**Incorrect (description of what's wrong):**

```javascript
// Bad code example with comments on key lines
// Example: Reads storage on every iteration
async function processItems(items) {
  for (const item of items) {
    const { settings } = await chrome.storage.local.get('settings');  // N reads
    applySettings(item, settings);
  }
}
```

**Correct (description of the improvement):**

```javascript
// Good code example with minimal changes from incorrect
// Example: Single read, reused for all items
async function processItems(items) {
  const { settings } = await chrome.storage.local.get('settings');  // 1 read
  for (const item of items) {
    applySettings(item, settings);
  }
}
```

**Alternative (when applicable):**

```javascript
// Alternative approach for specific contexts
```

**When NOT to use this pattern:**
- Exception scenario 1
- Exception scenario 2

Reference: [Reference Title](https://example.com/reference)
