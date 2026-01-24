---
title: Test Edge Cases and Boundary Conditions
impact: LOW-MEDIUM
impactDescription: catches 80% of production bugs
tags: test, edge-cases, coverage, robustness
---

## Test Edge Cases and Boundary Conditions

Include edge cases that stress pattern boundaries. Real codebases contain unusual but valid code that breaks naive patterns.

**Incorrect (only happy path):**

```yaml
id: no-console-log
valid:
  - logger.info(msg)
invalid:
  - console.log(msg)
# Missing: multiline, nested, chained, commented
```

**Correct (comprehensive edge cases):**

```yaml
id: no-console-log
valid:
  # Similar patterns that shouldn't match
  - logger.info(msg)
  - window.console  # Just property access
  - 'const console = mock'  # Shadowed
  # Commented code (doesn't match)
  - '// console.log(debug)'

invalid:
  # Basic cases
  - console.log(msg)
  - console.log()
  - console.log(a, b, c)

  # Multiline
  - |
    console.log(
      longMessage
    )

  # Chained
  - console.log(msg) || fallback

  # Nested
  - fn(console.log(msg))

  # In expressions
  - 'x = console.log(y)'

  # Template literals
  - 'console.log(`template ${var}`)'
```

**Edge case categories:**

| Category | Examples |
|----------|----------|
| Whitespace | Multiline, extra spaces |
| Nesting | Inside functions, callbacks |
| Chaining | Method chains, pipelines |
| Context | Different statement types |
| Literals | Strings, templates, regex |
| Comments | Near matches (shouldn't match) |

Reference: [Testing Rules](https://ast-grep.github.io/guide/project/test-rule.html)
