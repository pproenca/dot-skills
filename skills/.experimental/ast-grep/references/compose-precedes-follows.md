---
title: Use Precedes and Follows for Sequential Positioning
impact: HIGH
impactDescription: enables matching statement order and sequences
tags: compose, precedes, follows, relational, sequence
---

## Use Precedes and Follows for Sequential Positioning

The `precedes` and `follows` relational rules match nodes based on their order among siblings. Use them to find patterns that depend on statement sequence.

**Incorrect (pattern can't express order):**

```yaml
id: find-ordered-calls
language: javascript
rule:
  all:
    - pattern: setup()
    - pattern: execute()
# Matches both but doesn't verify order
```

**Correct (precedes enforces order):**

```yaml
id: find-setup-before-execute
language: javascript
rule:
  pattern: setup()
  precedes:
    pattern: execute()
```

**Understanding precedes vs follows:**

```yaml
# "A precedes B" means A comes before B
rule:
  pattern: $FIRST
  precedes:
    pattern: $SECOND

# "A follows B" means A comes after B
rule:
  pattern: $SECOND
  follows:
    pattern: $FIRST

# Both match the same relationship, different anchor node
```

**Controlling search depth with stopBy:**

```yaml
# Match immediate next sibling only
rule:
  pattern: const $VAR = $VAL
  precedes:
    pattern: console.log($VAR)
    stopBy: neighbor  # Must be immediate next statement

# Match anywhere after in same block
rule:
  pattern: const $VAR = $VAL
  precedes:
    pattern: console.log($VAR)
    stopBy: end  # Can have statements between
```

**Practical examples:**

```yaml
# Find variable declaration followed by its usage
id: find-immediate-use
language: javascript
rule:
  pattern: const $VAR = $VAL
  precedes:
    pattern: $VAR
    stopBy: neighbor

# Find return not at end of function
id: find-early-return
language: javascript
rule:
  pattern: return $VAL
  precedes:
    kind: expression_statement
    stopBy: end
  inside:
    kind: statement_block

# Find missing cleanup after resource allocation
id: find-unclosed-resource
language: javascript
rule:
  pattern: const $HANDLE = open($PATH)
  not:
    precedes:
      pattern: $HANDLE.close()
      stopBy: end
```

**Key behaviors:**

- `precedes` anchors on the first node, searches forward
- `follows` anchors on the second node, searches backward
- Both operate only among siblings (same parent)
- Use `stopBy: neighbor` for immediate adjacency
- Use `stopBy: end` for anywhere in sequence

Reference: [Relational Rules](https://ast-grep.github.io/reference/rule.html#precedes)
