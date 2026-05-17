---
title: Compile Regex Patterns Once at Module Level
impact: MEDIUM
impactDescription: 5-50× per regex use — compilation typically dominates matching for short inputs
tags: compute, regex, precompile, hoisting, caching
---

## Compile Regex Patterns Once at Module Level

Regex compilation walks the pattern, parses it, builds an NFA/DFA, and allocates. Matching is the cheap part — for short inputs, matching against a precompiled regex can be 10-50× faster than the equivalent `re.match(r'...', s)` call. Python's `re` module caches the last ~512 patterns automatically, so the impact is smaller there than people fear, but you still pay a dict lookup; in JavaScript, `new RegExp(pattern)` in a hot path has no module-level cache and recompiles every time. The portable rule: compile any regex used more than once into a module-level constant.

**Incorrect (recompile per call):**

```javascript
function isEmail(s, locale) {
  // Pattern built from a string — V8 cannot cache this across calls
  const pattern = `^[^@]+@[^@]+\\.[^@]+\\.${locale}$`;
  return new RegExp(pattern).test(s);                    // compile every call
}
// 1,000,000 validations → 1,000,000 compilations
```

**Correct (compile once at module level, or cache by locale):**

```javascript
const EMAIL_RE_BY_LOCALE = new Map();

function isEmail(s, locale) {
  let re = EMAIL_RE_BY_LOCALE.get(locale);
  if (!re) {
    re = new RegExp(`^[^@]+@[^@]+\\.[^@]+\\.${locale}$`);
    EMAIL_RE_BY_LOCALE.set(locale, re);
  }
  return re.test(s);
}
// N distinct locales → N compilations total, regardless of call count
```

**Alternative (Python — module-level constant or `re.compile`):**

```python
import re
_EMAIL_RE = re.compile(r'^[^@]+@[^@]+\.[^@]+$')

def is_email(s):
    return bool(_EMAIL_RE.match(s))
```

**When NOT to use this pattern:**
- When the pattern is genuinely dynamic per call (built from user input) — you must compile each time. Cache compiled patterns in a dict if the *set* of dynamic patterns is small.
- For one-off matches outside any loop — inline regex is clearer and the cost is negligible.

Reference: [Python `re` module — performance considerations](https://docs.python.org/3/library/re.html#re.compile)
