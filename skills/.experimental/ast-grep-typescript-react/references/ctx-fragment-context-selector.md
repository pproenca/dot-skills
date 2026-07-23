---
title: Match TS/React fragments with context and selector
tags: ctx, context, selector, fragments
---

## Match TS/React fragments with context and selector

Tree-sitter parses each pattern as a standalone program, so a fragment that is only meaningful *inside* a larger construct reparses as a different node. A JSX attribute written alone (`variant="primary"`) parses as an `assignment_expression`; a type annotation (`props: ButtonProps`) parses as a `labeled_statement`. The bare pattern then matches the wrong thing — or nothing. Supply the surrounding structure with `context` and point `selector` at the node kind you actually want.

```yaml
# Match a JSX attribute, not the assignment_expression a bare `variant="primary"` becomes.
language: tsx
rule:
  pattern:
    context: <Alert $ATTR />
    selector: jsx_attribute
```

Common TS/React fragments that need this wrapping:

| Fragment | context | selector |
|----------|---------|----------|
| JSX attribute | `<Alert $ATTR />` | `jsx_attribute` |
| Object/prop entry | `const o = { $KEY: $VAL }` | `pair` |
| Type annotation | `let x: $TYPE` | `type_annotation` |
| Union type member | `type T = $A \| $B` | `union_type` |

Confirm the selector name with `--debug-query=ast` on a real snippet before committing to it — kind names come from the tree-sitter-typescript grammar, not intuition.

Reference: [Rule object: pattern with context/selector](https://ast-grep.github.io/reference/rule.html)
