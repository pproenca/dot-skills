---
title: Use Double Dollar for Unnamed Node Matching
impact: CRITICAL
impactDescription: enables matching operators and punctuation
tags: meta, unnamed-nodes, operators, tree-sitter
---

## Use Double Dollar for Unnamed Node Matching

Single `$VAR` only matches named AST nodes. Use `$$VAR` to match unnamed nodes like operators and punctuation.

**Incorrect (single dollar misses operators):**

```yaml
id: find-binary-operator
language: javascript
rule:
  pattern: $LEFT $OP $RIGHT  # $OP won't match + or -
```

**Correct (double dollar matches unnamed nodes):**

```yaml
id: find-binary-operator
language: javascript
rule:
  pattern: $LEFT $$OP $RIGHT  # $$OP matches +, -, *, etc.
```

**Named vs Unnamed nodes:**
- **Named nodes**: Have a `kind` property (e.g., `identifier`, `call_expression`)
- **Unnamed nodes**: Operators (`+`, `-`), punctuation (`;`, `,`), keywords

**Common use cases for `$$VAR`:**

```yaml
# Match any binary expression
pattern: $A $$OP $B

# Match any assignment operator
pattern: $TARGET $$ASSIGN $VALUE  # =, +=, -=, etc.

# Match array access brackets
pattern: $ARR$$OPEN$IDX$$CLOSE
```

**Tip:** Use `--debug-query` to see which nodes are named vs unnamed.

Reference: [Core Concepts](https://ast-grep.github.io/advanced/core-concepts.html)
