---
title: Match Single AST Nodes with Meta Variables
impact: CRITICAL
impactDescription: prevents multi-node capture failures
tags: meta, single-node, ast, matching
---

## Match Single AST Nodes with Meta Variables

A single `$VAR` matches exactly one AST node. It cannot match multiple consecutive nodes like function arguments or statements.

**Incorrect (expects $ARGS to match multiple arguments):**

```yaml
id: find-multi-arg-call
language: javascript
rule:
  pattern: console.log($ARGS)  # Only matches single-arg calls
# Won't match: console.log(a, b, c)
```

**Correct (use $$$ for multiple nodes):**

```yaml
id: find-any-log-call
language: javascript
rule:
  pattern: console.log($$$ARGS)  # Matches zero or more args
```

**Understanding node boundaries:**
- `$VAR` = exactly one node (like regex `.`)
- `$$$` or `$$$VAR` = zero or more nodes (like regex `.*`)
- Each meta variable captures the entire subtree of its matched node

**Common mistake:**

```yaml
# This only matches: fn(singleArg)
pattern: fn($ARG)

# This matches: fn(), fn(a), fn(a, b, c)
pattern: fn($$$ARGS)
```

Reference: [Pattern Syntax](https://ast-grep.github.io/guide/pattern-syntax.html)
