---
title: Write Both Valid and Invalid Test Cases
impact: LOW-MEDIUM
impactDescription: catches 70% of false positive/negative bugs
tags: test, valid, invalid, testing
---

## Write Both Valid and Invalid Test Cases

Test files must include both `valid` (should not match) and `invalid` (should match) cases. This verifies both precision and recall.

**Incorrect (only invalid cases):**

```yaml
id: no-console
valid: []  # No valid cases - doesn't test for false positives
invalid:
  - console.log(msg)
  - console.warn(msg)
```

**Correct (both valid and invalid):**

```yaml
id: no-console
valid:
  - logger.info(msg)          # Alternative approach
  - console                   # Just the identifier, not a call
  - 'const console = {}'      # Shadowed variable
invalid:
  - console.log(msg)
  - console.warn(msg)
  - console.error(a, b, c)
```

**Test case categories:**

```yaml
valid:
  # Similar but different patterns
  - logger.log(msg)
  # Edge cases that shouldn't match
  - 'obj.console.log(msg)'
  # Already fixed code
  - 'if (DEBUG) console.log(msg)'

invalid:
  # Basic case
  - console.log(msg)
  # Variations
  - console.log()
  - console.log(a, b)
  # Edge cases that should match
  - 'console.log("literal")'
```

**Running tests:**

```bash
ast-grep test -c sgconfig.yml
# Or for specific test file
ast-grep test -t tests/no-console-test.yml
```

Reference: [Testing Rules](https://ast-grep.github.io/guide/project/test-rule.html)
