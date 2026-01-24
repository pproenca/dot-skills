---
title: Avoid Matching Inside Comments and Strings
impact: CRITICAL
impactDescription: prevents false positives on non-code content
tags: pattern, comments, strings, false-positives
---

## Avoid Matching Inside Comments and Strings

ast-grep matches AST nodes, not text. Patterns will never match content inside comments or string literals because those are leaf nodes without children matching code structure.

**Incorrect (expects to match commented code):**

```yaml
id: find-todo-console
language: javascript
rule:
  pattern: console.log($MSG)
# Will NOT match: // console.log("debugging")
```

**Correct (use regex for comment/string content):**

```yaml
id: find-todo-comments
language: javascript
rule:
  kind: comment
  regex: 'TODO|FIXME'
```

**For matching inside strings:**

```yaml
id: find-sql-injection-risk
language: javascript
rule:
  kind: string
  regex: 'SELECT.*FROM.*WHERE'
```

**Note:** Comments and strings are terminal AST nodes - their content is not parsed into sub-nodes.

Reference: [Core Concepts](https://ast-grep.github.io/advanced/core-concepts.html)
