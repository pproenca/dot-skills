---
title: Use nthChild for Index-Based Positional Matching
impact: MEDIUM
impactDescription: enables matching elements by position in sequences
tags: pattern, nthchild, positional, index, atomic
---

## Use nthChild for Index-Based Positional Matching

The `nthChild` atomic rule matches nodes by their position among siblings. Use it to target specific elements in arrays, function parameters, or statement sequences.

**Incorrect (pattern can't express position):**

```yaml
id: find-first-param
language: javascript
rule:
  pattern: function $NAME($FIRST, $$$REST) {}
# Only works if function has 2+ params
# Can't match first param of single-param function
```

**Correct (nthChild targets by position):**

```yaml
id: find-first-param
language: javascript
rule:
  kind: formal_parameters
  has:
    kind: identifier
    nthChild: 1  # 1-based index, matches first child
```

**Index patterns (An+B formula):**

```yaml
# Match first element
nthChild: 1

# Match last element
nthChild:
  position: 1
  reverse: true

# Match every other element (2nd, 4th, 6th...)
nthChild: 2n

# Match odd elements (1st, 3rd, 5th...)
nthChild: 2n+1

# Match first three elements
nthChild:
  position: -n+3
```

**Common use cases:**

```yaml
# Match second argument in function calls
id: find-second-arg
rule:
  kind: arguments
  has:
    nthChild: 2

# Match last statement in block
id: find-last-statement
rule:
  kind: statement_block
  has:
    kind: expression_statement
    nthChild:
      position: 1
      reverse: true
```

**Note:** `nthChild` uses 1-based indexing (first element is 1, not 0). Use `reverse: true` to count from the end.

Reference: [Atomic Rules](https://ast-grep.github.io/reference/rule.html#nthchild)
