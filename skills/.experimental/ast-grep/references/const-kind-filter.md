---
title: Use Kind Constraints to Filter Meta Variables
impact: HIGH
impactDescription: reduces false positives by node type
tags: const, kind, filter, meta-variables
---

## Use Kind Constraints to Filter Meta Variables

Constraints filter captured meta variables after pattern matching. Use `kind` constraints to ensure variables match expected node types.

**Incorrect (accepts any node type):**

```yaml
id: find-function-call
language: javascript
rule:
  pattern: $FN($ARGS)
# Matches: getUser(), obj.method(), new Class() - too broad
```

**Correct (constrain to identifiers only):**

```yaml
id: find-simple-call
language: javascript
rule:
  pattern: $FN($ARGS)
constraints:
  FN:
    kind: identifier
# Only matches: getUser(), validate() - not obj.method()
```

**Multiple kind constraints:**

```yaml
id: find-callable-usage
language: javascript
rule:
  pattern: $FN($ARGS)
constraints:
  FN:
    any:
      - kind: identifier
      - kind: member_expression
```

**Important:** Constraints apply after pattern matching. The pattern must first match, then constraints filter the results.

**When to use kind constraints:**
- Filter function calls by callee type
- Distinguish variable declarations from parameters
- Separate property access from subscript access

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)
