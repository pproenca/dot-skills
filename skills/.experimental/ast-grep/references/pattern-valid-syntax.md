---
title: Use Valid Parseable Code as Patterns
impact: CRITICAL
impactDescription: prevents silent pattern failures
tags: pattern, syntax, tree-sitter, parsing
---

## Use Valid Parseable Code as Patterns

Patterns must be syntactically valid code that tree-sitter can parse. Invalid patterns silently fail to match anything, wasting debugging time.

**Incorrect (incomplete expression, unparseable):**

```yaml
id: find-console-log
language: javascript
rule:
  pattern: console.log(  # Missing closing paren
```

**Correct (valid, complete expression):**

```yaml
id: find-console-log
language: javascript
rule:
  pattern: console.log($ARG)
```

**Note:** Test patterns in the [ast-grep playground](https://ast-grep.github.io/playground.html) to verify parseability before deployment.

Reference: [Pattern Syntax](https://ast-grep.github.io/guide/pattern-syntax.html)
