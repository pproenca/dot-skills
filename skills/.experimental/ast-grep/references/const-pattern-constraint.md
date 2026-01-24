---
title: Use Pattern Constraints for Structural Filtering
impact: HIGH
impactDescription: reduces false positives by 40-80%
tags: const, pattern, structural, filter
---

## Use Pattern Constraints for Structural Filtering

Use `pattern` constraints to verify that captured meta variables match a specific code structure, not just kind or text.

**Incorrect (kind constraint too broad):**

```yaml
id: find-null-check
language: javascript
rule:
  pattern: if ($COND) { $$$BODY }
constraints:
  COND:
    kind: binary_expression  # Matches any binary expression
```

**Correct (pattern constraint for specific structure):**

```yaml
id: find-null-check
language: javascript
rule:
  pattern: if ($COND) { $$$BODY }
constraints:
  COND:
    pattern: $VAR === null
```

**Combining multiple constraint types:**

```yaml
id: find-hook-call-with-deps
language: javascript
rule:
  pattern: $HOOK($CALLBACK, $DEPS)
constraints:
  HOOK:
    regex: ^use(Effect|Callback|Memo)$
  DEPS:
    pattern: '[$$$ITEMS]'  # Must be array literal
```

**Structural constraint use cases:**
- Verify function arguments have specific shape
- Match only certain binary operators
- Filter by nested structure depth

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)
