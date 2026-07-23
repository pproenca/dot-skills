---
title: Place JSX attribute metavariables in a valid value position
tags: jsx, attributes, metavariable, jsx-expression
---

## Place JSX attribute metavariables in a valid value position

A JSX attribute value must be a string or a `{expression}` — the grammar accepts nothing else there. So a bare metavariable, `variant=$V`, is not valid JSX: it fails to parse as a value, `$V` never binds, and any `fix`/`transform` that references it errors with *"Undefined meta var"*. Write the metavariable where a real value would go.

```yaml
# Capture a string attribute value — metavar sits inside the quotes.
language: tsx
rule:
  pattern:
    context: <Alert variant="$V" />
    selector: jsx_attribute
```

Three valid capture positions, depending on the value form:

- **String value:** `variant="$V"` → `$V` binds to the string contents.
- **Expression value:** `onClick={$HANDLER}` → `$HANDLER` binds inside the `jsx_expression` container.
- **Whole attribute:** `<Alert $ATTR />` → `$ATTR` binds the entire `jsx_attribute` node (narrow further with a `regex` constraint on the name).

Reference: [Meta variable syntax](https://ast-grep.github.io/guide/pattern-syntax.html#meta-variable)
