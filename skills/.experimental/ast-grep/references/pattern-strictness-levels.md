---
title: Configure Pattern Strictness Appropriately
impact: CRITICAL
impactDescription: 2-5× more matches with relaxed mode
tags: pattern, strictness, matching, precision
---

## Configure Pattern Strictness Appropriately

The `strictness` parameter controls how precisely patterns must match AST structure. Looser settings match more variations but risk false positives.

**Incorrect (default strictness misses valid variations):**

```yaml
id: find-await-fetch
language: typescript
rule:
  pattern: await fetch($URL)
# Misses: await (fetch(url))
# Misses: await fetch(url, options)
```

**Correct (relaxed strictness catches variations):**

```yaml
id: find-await-fetch
language: typescript
rule:
  pattern:
    context: await fetch($URL)
    strictness: relaxed
```

**Strictness levels:**
- `cst`: Exact match including punctuation (most strict)
- `smart`: Ignores unnamed nodes like parentheses (default)
- `ast`: Ignores node kinds, focuses on structure
- `relaxed`: Matches if pattern is subtree (most lenient)
- `signature`: Ignores non-essential nodes like async/visibility

**When to adjust:**
- Use `relaxed` when matching expressions that may be wrapped in parens
- Use `signature` for function signatures with optional modifiers
- Use `cst` when punctuation matters (template literals, regex)

Reference: [Pattern Strictness](https://ast-grep.github.io/guide/rule-config/atomic-rule.html#strictness)
