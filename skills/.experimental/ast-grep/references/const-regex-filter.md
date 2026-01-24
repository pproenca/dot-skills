---
title: Use Regex Constraints for Text Patterns
impact: HIGH
impactDescription: reduces false positives by 50-90%
tags: const, regex, filter, text-matching
---

## Use Regex Constraints for Text Patterns

Use `regex` constraints to filter meta variables by their text content. The regex must match the entire node text.

**Incorrect (pattern can't filter by name):**

```yaml
id: find-hook-usage
language: javascript
rule:
  pattern: use$HOOK()  # Invalid! Can't mix text and meta vars
```

**Correct (use regex constraint):**

```yaml
id: find-hook-usage
language: javascript
rule:
  pattern: $HOOK()
constraints:
  HOOK:
    regex: ^use[A-Z]
```

**Common regex patterns:**

```yaml
# Match React hooks (useEffect, useState, etc.)
constraints:
  FN:
    regex: ^use[A-Z]\w*$

# Match private fields (_name, _value)
constraints:
  PROP:
    regex: ^_

# Match test functions (test_*, *_test)
constraints:
  NAME:
    regex: (^test_|_test$)

# Match specific prefixes
constraints:
  VAR:
    regex: ^(temp|tmp|_)
```

**Important:** Regex matches against the full text representation of the captured node, including nested content.

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)
