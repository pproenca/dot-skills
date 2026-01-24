---
title: Use Specific Patterns Over Generic Ones
impact: MEDIUM
impactDescription: reduces matching iterations on large codebases
tags: perf, patterns, specificity, optimization
---

## Use Specific Patterns Over Generic Ones

More specific patterns match fewer nodes, improving scan performance. Avoid overly generic patterns that match most of the codebase.

**Incorrect (matches every expression):**

```yaml
id: find-issues
language: javascript
rule:
  pattern: $EXPR  # Matches every expression in codebase
  # Then filters with complex constraints
constraints:
  EXPR:
    kind: call_expression
    has:
      pattern: console
```

**Correct (specific pattern, fewer matches):**

```yaml
id: find-console-calls
language: javascript
rule:
  pattern: console.$METHOD($$$ARGS)
```

**Pattern specificity hierarchy (fastest to slowest):**
1. Literal patterns: `console.log("debug")`
2. Partial literals: `console.log($MSG)`
3. Kind-specific: `kind: call_expression`
4. Generic captures: `$EXPR`

**Balancing specificity:**

```yaml
# Too specific - misses variations
pattern: console.log($MSG)
# Misses: console.log(a, b)

# Right balance - specific enough, flexible
pattern: console.log($$$ARGS)

# Too generic - matches too much
pattern: $FUNC($$$ARGS)
```

**When generic patterns are unavoidable:**
- Add `kind` to narrow node types
- Use `inside` to limit search scope
- Apply file filtering to reduce scan area

Reference: [Core Concepts](https://ast-grep.github.io/advanced/core-concepts.html)
